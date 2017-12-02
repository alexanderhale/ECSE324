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
	while (octave < 1){
		base = (float)base / (float)base;
		octave++;
	}
	while (octave > 1){
		base = base*base;
		octave--;
	}
	return base;
}

int signal(float f, int t, int octave) {
	int temp = (int)((float)(f * t) * (float)pow(2.0, (octave - 3)));
	int index = temp % 48000;				// TODO: make this a float
	int indexLeftOfDecimal = (int)index;
	float decimals = index - indexLeftOfDecimal;
	float interpolated = (1-decimals)*sine[indexLeftOfDecimal] + (decimals)*sine[indexLeftOfDecimal+1];

	// multiply signal by current volume to get appropriate signal amplitude
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

void piano(float f, int octave){
	pianoBase();
	int x, r;
	int j = ((int)f-100)/14 - 1;
	
	// update the volume and octave
    VGA_write_char_ASM(7, 0, volume + 48);
	VGA_write_char_ASM(7, 2, octave + 48);	

	if (j > 6){
		j = j - 1;
		if (j > 7){
			j = j - 1;
		}
	}
	for (x = 3; x <= 37; x++){
		for (r = 120; r <= 239; r++){
			VGA_draw_point_ASM((j - 1) * 40 + x, r, 16000);
		}
	}
}

void wave(float f, int volume, int octave) {
	// clear the screen of old data
	VGA_clear_pixelbuff_ASM();

	if (f) {											// only display anything if the frequency is above 0
		int x, y;
		short colour = 16777215; // white

		// update the volume and octave
	    VGA_write_char_ASM(7, 0, volume + 48);
		VGA_write_char_ASM(7, 2, octave + 48);	

		// iterate through all of the pixels on the screen
		int increment = (int)((float)(48000 / ((320.00 / f) * 50.00)) * (float)(pow(2.0, (octave - 3))));
			// 48000 = sample frequency
			// 320 = number of spaces in the x direction in the pixel buffer
			// 50 Hz = base frequency
			// f = current signal frequency
			// adjustment made for current octave

		int xposition = 0; //initial x position is set in the sine wave
		
		// iterate through the x direction of the pixel buffer
		for(x = 0; x <= 319; x++) {
			// generate the y position of the wave at the current x position
				// uses the provided wavetable, sine[x]
				// amplitude of wave on screen increases by 15 for each volume increment
			y = -1*(int)((float)sine[xposition] * ((float)30 / (float)(sine[12000]))) * ((float)volume / (float)2) + 120;		
			
			// draw the point on the screen
			VGA_draw_point_ASM(x, y, colour);
			
			// increase the x position by the appropriate increment for this frequency
			xposition = xposition + increment;
			
			// reset when the number of samples is exceeded
			if (xposition > 48000){
				xposition = xposition - 48000; //Resets iteration of the sine wave
			} 
			
			// change the wave colour as we go for extra #funtimes
			//colour=colour+128;
		}
	}
}

void displayInstructions() {
	VGA_clear_charbuff_ASM();
	VGA_clear_pixelbuff_ASM();

	// Display initial volume
	VGA_write_char_ASM(0,0, 'V');
	VGA_write_char_ASM(1,0, 'O');
	VGA_write_char_ASM(2,0, 'L');
	VGA_write_char_ASM(3,0, 'U');
	VGA_write_char_ASM(4,0, 'M');
	VGA_write_char_ASM(5,0, 'E');
	VGA_write_char_ASM(6,0, ':');
	VGA_write_char_ASM(7,0, '1');

	// Display intial octave
	VGA_write_char_ASM(0,2, 'O');
	VGA_write_char_ASM(1,2, 'C');
	VGA_write_char_ASM(2,2, 'T');
	VGA_write_char_ASM(3,2, 'A');
	VGA_write_char_ASM(4,2, 'V');
	VGA_write_char_ASM(5,2, 'E');
	VGA_write_char_ASM(6,2, ':');
	VGA_write_char_ASM(7,2, '3');

	// display instructions
	VGA_write_char_ASM(61,0, 'C');
	VGA_write_char_ASM(62,0, ' ');
	VGA_write_char_ASM(63,0, '=');
	VGA_write_char_ASM(64,0, ' ');
	VGA_write_char_ASM(65,0, 'D');
	VGA_write_char_ASM(66,0, 'E');
	VGA_write_char_ASM(67,0, 'C');
	VGA_write_char_ASM(68,0, 'R');
	VGA_write_char_ASM(69,0, 'E');
	VGA_write_char_ASM(70,0, 'A');
	VGA_write_char_ASM(71,0, 'S');
	VGA_write_char_ASM(72,0, 'E');
	VGA_write_char_ASM(73,0, ' ');
	VGA_write_char_ASM(74,0, 'V');
	VGA_write_char_ASM(75,0, 'O');
	VGA_write_char_ASM(76,0, 'L');
	VGA_write_char_ASM(77,0, 'U');
	VGA_write_char_ASM(78,0, 'M');
	VGA_write_char_ASM(79,0, 'E');

	VGA_write_char_ASM(61,1, 'V');
	VGA_write_char_ASM(62,1, ' ');
	VGA_write_char_ASM(63,1, '=');
	VGA_write_char_ASM(64,1, ' ');
	VGA_write_char_ASM(65,1, 'I');
	VGA_write_char_ASM(66,1, 'N');
	VGA_write_char_ASM(67,1, 'C');
	VGA_write_char_ASM(68,1, 'R');
	VGA_write_char_ASM(69,1, 'E');
	VGA_write_char_ASM(70,1, 'A');
	VGA_write_char_ASM(71,1, 'S');
	VGA_write_char_ASM(72,1, 'E');
	VGA_write_char_ASM(73,1, ' ');
	VGA_write_char_ASM(74,1, 'V');
	VGA_write_char_ASM(75,1, 'O');
	VGA_write_char_ASM(76,1, 'L');
	VGA_write_char_ASM(77,1, 'U');
	VGA_write_char_ASM(78,1, 'M');
	VGA_write_char_ASM(79,1, 'E');

	VGA_write_char_ASM(61,2, 'B');
	VGA_write_char_ASM(62,2, ' ');
	VGA_write_char_ASM(63,2, '=');
	VGA_write_char_ASM(64,2, ' ');
	VGA_write_char_ASM(65,2, 'D');
	VGA_write_char_ASM(66,2, 'E');
	VGA_write_char_ASM(67,2, 'C');
	VGA_write_char_ASM(68,2, 'R');
	VGA_write_char_ASM(69,2, 'E');
	VGA_write_char_ASM(70,2, 'A');
	VGA_write_char_ASM(71,2, 'S');
	VGA_write_char_ASM(72,2, 'E');
	VGA_write_char_ASM(73,2, ' ');
	VGA_write_char_ASM(74,2, 'O');
	VGA_write_char_ASM(75,2, 'C');
	VGA_write_char_ASM(76,2, 'T');
	VGA_write_char_ASM(77,2, 'A');
	VGA_write_char_ASM(78,2, 'V');
	VGA_write_char_ASM(79,2, 'E');

	VGA_write_char_ASM(61,3, 'N');
	VGA_write_char_ASM(62,3, ' ');
	VGA_write_char_ASM(63,3, '=');
	VGA_write_char_ASM(64,3, ' ');
	VGA_write_char_ASM(65,3, 'I');
	VGA_write_char_ASM(66,3, 'N');
	VGA_write_char_ASM(67,3, 'C');
	VGA_write_char_ASM(68,3, 'R');
	VGA_write_char_ASM(69,3, 'E');
	VGA_write_char_ASM(70,3, 'A');
	VGA_write_char_ASM(71,3, 'S');
	VGA_write_char_ASM(72,3, 'E');
	VGA_write_char_ASM(73,3, ' ');
	VGA_write_char_ASM(74,3, 'O');
	VGA_write_char_ASM(75,3, 'C');
	VGA_write_char_ASM(76,3, 'T');
	VGA_write_char_ASM(77,3, 'A');
	VGA_write_char_ASM(78,3, 'V');
	VGA_write_char_ASM(79,3, 'E');
}

int main() {
	int samples = 0;
	char* data;		// PS/2 port address
	float f = 0;	// frequency of note to play

	int mode = 0;  			//mode of the synth (wave or piano keyboard)
	int oldmode = 0;
	int octave = 3;			// current octave (range 1 to 5)
	int oldoctave = 3;
	float oldf = 0;			// old frequency (used for updating screen)
	int oldv = 0; 			// old volume (used for updating screen)

	int clock = 0;			// typematic variables
	int delay = 1;
	int bcode = 0;
	char current = 0;		// store 3 codes from keyboard
	char previous = 0;			// from oldest to newest: previous, current, input

	int keystate[8] = {0, 0, 0, 0, 0, 0, 0, 0, 0};		// TODO: make sure we're still using this
	float freqs[8] = {130.813, 146.832, 164.814, 174.614, 195.998, 220.000, 246.942, 261.626};

	displayInstructions();	// display info to the user

	while(1) {
		int output = 0;
		char input = *data;

		// move into piano mode if any of the slider switches are on
		if (read_slider_switches_ASM()) {
			mode = 1;
		} else {
			mode = 0;
		}

		// if the RVALID flag is 1, enter this if block
		if (read_ps2_data_ASM(data)) {
			VGA_write_byte_ASM(20 + delay++, 7, input);	// TODO: remove

			if (bcode) {						// if the previous code was a break code, turn off the appropriate key in the array
				if (input == 0x1C) {
					keystate[0] = 0;
				} else if (input == 0x1B) {
					keystate[1] = 0;
				} else if (input == 0x23) {
					keystate[2] = 0;
				} else if (input == 0x2B) {
					keystate[3] = 0;
				} else if (input == 0x3B) {
					keystate[4] = 0;
				} else if (input == 0x42) {
					keystate[5] = 0;
				} else if (input == 0x4B) {
					keystate[6] = 0;
				} else if (input == 0x4C) {
					keystate[7] = 0;
				}
				bcode = 0;
			} else {
				if (input == 0xF0 || input == 0xFE || input == 0xFA) {		// if we see a break code, we'll head to a different section on the next loop
					bcode = 1;
				} else if (input == 0x1C) {		// keyboard keypresses
					keystate[0] = 1;
				} else if (input == 0x1B) {
					keystate[1] = 1;
				} else if (input == 0x23) {
					keystate[2] = 1;
				} else if (input == 0x2B) {
					keystate[3] = 1;
				} else if (input == 0x3B) {
					keystate[4] = 1;
				} else if (input == 0x42) {
					keystate[5] = 1;
				} else if (input == 0x4B) {
					keystate[6] = 1;
				} else if (input == 0x4C) {
					keystate[7] = 1;
				} else if (input == 0x2A && volume < 7) {	// volume adjustments
					volume++;
				} else if (input == 0x21 && volume > 0) {
					volume--;			
				} else if (input ==  0x31 && octave < 5) {	// octave adjustments
					octave++;
				} else if (input == 0x32 && octave > 1) {
					octave--;
				}
			}

			// TODO: remove
			int t;
			for (t = 0; t < 8; t++) {
				VGA_write_char_ASM(t + 20, 5, keystate[t] + 48);
			}
		}

		// count the number of keys that are pressed and add the corresponding frequencies together
		float total = 0;
		int hits = 0;
		int i;
		for (i = 0; i < 8; i++) {
			if (keystate[i]) {
				total = total + freqs[i];
				hits++;
			}
		}

		if (hits) {
			// average the frequencies of all the key presses
			f = total / hits;
		} else {
			// all the keys are not pressed, no frequency
			f = 0;
		}

		// display update graphics on screen if frequency, volume, mode, or octave have changed
		if (oldf != f || oldv != volume || oldmode != mode || oldoctave != octave) {
			// update variables
			oldf = f;
			oldv = volume;

			// depending on the mode, display the wave or the on-screen piano keyboard
			if (mode == 0){
				wave(f, volume, octave);
			} else {
				piano(f, octave);
			}
			
			// update remaining variables
			oldmode = mode;
			oldoctave = octave;
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
