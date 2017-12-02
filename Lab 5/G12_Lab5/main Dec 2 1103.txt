#include "./drivers/inc/vga.h"
#include "./drivers/inc/ISRs.h"
#include "./drivers/inc/LEDs.h"
#include "./drivers/inc/audio.h"
#include "./drivers/inc/HPS_TIM.h"
#include "./drivers/inc/int_setup.h"
#include "./drivers/inc/wavetable.h"
#include "./drivers/inc/pushbuttons.h"
#include "./drivers/inc/ps2_keyboard.h"
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/slider_switches.h"


int volume = 1;

float pow(float base, int octave){
	while (octave<1){
		base=(float)base/(float)base;
		octave++;
	}
	while (octave>1){
		base=base*base;
		octave--;
	}
	return base;
}

int signal(float f, int t, int octave) {
	int temp = (int)((float)(f*t)*(float)pow(2.0,(octave-3)));
	int index = temp % 48000;				// TODO: make this a float
	int indexLeftOfDecimal = (int)index;
	float decimals = index - indexLeftOfDecimal;
	float interpolated = (1-decimals)*sine[indexLeftOfDecimal] + (decimals)*sine[indexLeftOfDecimal+1];

	// TODO: replace amplitude here with the volume control
	return volume * interpolated;
}

void pianoBase(){
	int x,y,j,h,k;
	for (x=0; x<=319; x++){
		for (y=120; y<=239; y++){ //draws white for keys
			VGA_draw_point_ASM(x,y,16777215);
			}
		for (j=0; j<=119; j++){ //draws background on top
			VGA_draw_point_ASM(x,j,31);
			}
	}
	for (x=38; x<=319; x=x+40){
		for (h=120; h<=239; h++){
			VGA_draw_point_ASM(x,h,0);
			VGA_draw_point_ASM(x+1,h,0);
			VGA_draw_point_ASM(x+2,h,0);
			VGA_draw_point_ASM(x+3,h,0);
			VGA_draw_point_ASM(x+4,h,0);
		}	
	}
	for (x=0; x<=2; x++){
		for (k=120; k<=239; k++){
			VGA_draw_point_ASM(x,k,0);
		}
	}
}
		
void piano(float f){
	pianoBase();
	int x,r;
	int j = ((int)f-100)/14-1;
	if (j>6){
		j=j-1;
		if (j>7){
			j=j-1;
		}
	}
	for (x=3; x<=37; x++){
		for (r=120; r<=239; r++){
			VGA_draw_point_ASM((j-1)*40+x,r,16000);
		}
	}
}
			
				

void wave(float f, int volume, int octave) {
	VGA_clear_pixelbuff_ASM();
	int x, y;
	short colour = 16777215; //produces the color white
	void VGA_write_char_ASM(7,0, (char)volume);
	void VGA_write_char_ASM(7,1, (char)octave);	

	// iterate through all of the pixels on the screen
	int increment=(int)((float)(48000/((320.00/f)*50.00))*(float)(pow(2.0,(octave-3)))); //48000 is sine wave, divided by number of x pixels per full iteration at the frequency, based frequency is 50 Hz 
	int xposition=0; //initial x position is set in the sine wave
		for(x=0; x<=319; x++) {
			// TODO: only draw if that pixel is part of the sin wave
			y=-1*(int)((float)sine[xposition]*((float)30/(float)(sine[12000])))*((float)volume/(float)2)+120; //Added volume multiplier, amplitude increases by 15 per volume increase 			
			VGA_draw_point_ASM(x, y, colour);
			xposition=xposition+increment;
			if (xposition>48000){
				xposition=xposition-48000; //Resets iteration of the sine wave
			} 
			//colour=colour+128;
		}
}

int main() {
	int samples = 0;
	char* data;		// PS/2 port address
	float f = 0;	// frequency of note to play
	
					// TODO: start at f = 0
	int mode=0;  	//mode of the synth
	int oldmode=0;
	int octave=3;
	int oldoctave=3;
	float oldf = 0;
	int oldv = 0; 
	int clock = 0;
	int delay = 1;
	char current = 0;
	char previous = 0;

	// TODO: handle more than one keypress
	void VGA_write_char_ASM(0,0,(char)V);
	void VGA_write_char_ASM(1,0, 'O');
	void VGA_write_char_ASM(2,0, 'L');
	void VGA_write_char_ASM(3,0, 'U');
	void VGA_write_char_ASM(4,0, 'M');
	void VGA_write_char_ASM(5,0, 'E');
	void VGA_write_char_ASM(6,0, ':');
	void VGA_write_char_ASM(7,0, '1');

	void VGA_write_char_ASM(0,2, 'O');
	void VGA_write_char_ASM(1,2, 'C');
	void VGA_write_char_ASM(2,2, 'T');
	void VGA_write_char_ASM(3,2, 'A');
	void VGA_write_char_ASM(4,2, 'V');
	void VGA_write_char_ASM(5,2, 'E');
	void VGA_write_char_ASM(6,2, ':');
	void VGA_write_char_ASM(7,2, '3');

	while(1) {
		int output = 0;
		char input = *data;
		
		if (read_slider_switches_ASM()>0){
			mode=1;
			}
		if (read_slider_switches_ASM()==0){
			mode=0;
			}


		// if the RVALID flag is 1, enter this if block
		if (read_ps2_data_ASM(data)) {
			// typematic situation requires more logic, so put it here separately
			if (input == current) {
				if (previous == 0xF0 || previous == 0xFE || previous == 0xFA) {
					// if the previous is a break code, we have a recurring keystroke
						// register the keystroke and update our list
					previous = current;
					current = input;
				} else {
					// otherwise, a key is being held, so start the typematic process
					
					// if input data is the current input, do nothing (i.e. can only hit each key once)
					clock += 1;		// increment "timer"
					
					// if we're still in the typematic delay phase, wait until the "clock" gets to 20
					if (delay) {
						if (clock < 8) {
							clock++;		// stay in typematic delay
						} else {
							clock = 0;						// reset "clock"
							delay = 0;						// indicate that we've left the typematic delay phase
						}
					} else {
						// if we're out of the typematic delay phase, implement a shorter delay for rapid key output
						if (clock < 2) {
							clock++;
						} else {
							clock = 0;						// reset "clock"
						}
					}
				}
			} else {
				// reset typematic variables
				clock = 0;
				delay = 1;

				// all other cases go here
				if (input == 0) {
					// if input data is empty, no keys are pressed, so set frequency to 0
					output = 2;
				} else if (input == 0xF0 || input == 0xFE || input == 0xFA) {
					// if input data is a break code, a key has been released
					// update our list
					previous = current;
					current = input;

					// output = 2;		// the key has been released, so set the frequency to zero
				} else if (input == previous) {
					// the input is the same as two codes ago and NOT the same as one code ago
						// this must be the code automatically sent right after the break code
					// current status is: previous = key, current = break code, input = same key
						// we need to update our list
					previous = current;
					current = input;
				} else {
					// input is a new key press

					// if the previous value is a break code, the prior key was released
					if (previous == 0xF0 || previous == 0xFE || previous == 0xFA) {
						output = 1;
					} else {
						// (at least) 2 keys are simultaneously pressed
						output = 3;
					}

					// update list
					previous = current;
					current = input;
				}
			}
		}


		// frequency adjustment
		if (output == 1) {
			
			if (input == 0x2A) {
				// volume up
				volume++;
			} else if (input == 0x21 && volume>0) {
				// volume down
				volume--;			
			} else if (input ==  0x31 && octave<5){
				octave++;
			} else if (input == 0x32 && octave>1){
				octave--;
			} else if (input == 0x1C) {
				// hit A, play a C
				f = 130.813;
			} else if (input == 0x1B) {
				// hit S, play a D
				f = 146.832;
			} else if (input == 0x23) {
				// hit D, play an E
				f = 164.814;
			} else if (input == 0x2B) {
				// hit F, play an F
				f = 174.614;
			} else if (input == 0x3B) {
				f = 195.998;
			} else if (input == 0x42) {
				f = 220.000;
			} else if (input == 0x4B) {
				f = 246.942;
			} else if (input == 0x4C) {
				f = 261.626;
			} else {
				f = 0;
			}
			output = 0;
		} else if (output == 2) {
			f = 0;
			output = 0;
		} else if (output == 3) {
			// volume adjustment
			if (input == 0x2A) {
				// volume up
				volume++;
			} else if (input == 0x21 && volume>0) {
				// volume down
				volume--;
			} else if (input ==  0x31 && octave<5){
				octave++;
			} else if (input == 0x32 && octave>1){
				octave--;
			} 
			 else {
				// frequency adjustment
				float f1 = 0;
				if (input == 0x1C) {
					// hit A, play a C
					f1 = 130.813;
				} else if (input == 0x1B) {
					// hit S, play a D
					f1 = 146.832;
				} else if (input == 0x23) {
					// hit D, play an E
					f1 = 164.814;
				} else if (input == 0x2B) {
					// hit F, play an F
					f1 = 174.614;
				} else if (input == 0x3B) {
					f1 = 195.998;
				} else if (input == 0x42) {
					f1 = 220.000;
				} else if (input == 0x4B) {
					f1 = 246.942;
				} else if (input == 0x4C) {
					f1 = 261.626;
				} else {
					f1 = 0;
				}
				f = (f+f1)/2;
			}
			output = 0;
		}

		// display wave to screen ONLY IF the frequency has changed
		if (oldf != f || oldv !=volume || oldmode!=mode || oldoctave!=octave) {
			oldf = f;
			oldv = volume;
			if (oldmode!= mode){
				if (mode==0){
					wave(f,volume,octave);
					}
				if (mode==1){
					piano(f);
					}
				}
			if (mode==0){
			wave(f, volume, octave);
			}
			if (mode==1){
			piano(f);
		}
			oldmode=mode;
			oldoctave=octave;
		}

		// if frequency is 0, don't play anything
		if (f) {
			// generate audio sample
			int endOfSignal = 48000 / f;
			while (samples < endOfSignal) {		// iterate one period
				// send a value
				int s = signal(f, samples, octave);
				audio_write_data_ASM(s, s);								// send the signal to be outputted
																			// don't need to check if there's space because the 
				//if (audio_write_data_ASM(s, s)) {						// decide whether keeping or removing this if condition changes the tune
					samples++;	// increment number of samples sent
				//}
			}
			samples = 0;
		}
	}

	return 0;
}
