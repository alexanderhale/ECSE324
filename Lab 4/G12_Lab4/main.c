#include <stdio.h>

#include "./drivers/inc/pushbuttons.h"
#include "./drivers/inc/slider_switches.h"
#include "./drivers/inc/VGA.h"
#include "./drivers/inc/ps2_keyboard.h"
#include "./drivers/inc/AUDIO.h"


void test_char() {
	int x, y;
	char c = 0;

	for (y = 0; y <= 59; y++) {
		for (x = 0; x <= 79; x++) {
			VGA_write_char_ASM(x, y, c++);
		}
	}
}

void test_byte(){
	int x, y;
	char c = 0;

	for (y = 0; y <= 59; y++) {
		for (x = 0; x <= 79; x += 3) {
			VGA_write_byte_ASM(x, y, c++);
		}
	}
}

void test_pixel(){
	int x, y;
	unsigned short colour = 0;

	for(y=0; y<=239; y++) {
		for(x=0; x<=319; x++) {
			VGA_draw_point_ASM(x, y, colour++);
		}
	}
}

int main() {
	/* ------------------ PART 1 - VGA ---------------------
	while(1) {
		int number = 0x1FF & read_slider_switches_ASM();	// keep all 9 slider digits
		int keys = 0xF & read_PB_data_ASM();				// keep all 4 key digits

		if (0x1 & keys) {					// if first button is pressed
			if (number) {			// if any switches are on
				test_byte();
			} else {
				test_char();
			}
		} else if (0x2 & keys) {					// if second key is pressed
			test_pixel();
		} else if (0x4 & keys) {					// if third key is pressed
			VGA_clear_charbuff_ASM();
		} else if (0x8 & keys) {					// if fourth keys is pressed
			VGA_clear_pixelbuff_ASM();
		}
	}*/

	/* ------------------- PART 2 - PS/2 KEYBOARD --------- */
	int x = 0;
	int y = 0;
	int clock = 0;
	int delay = 1;
	char * data;		// PS/2 port address
	char current = 0;
	char previous = 0;
	VGA_clear_charbuff_ASM();		// clear screen of old stuff

	while(1) {
		int keys = 0xF & read_PB_data_ASM();  		// keep all 4 key digits

		if (keys) {
			VGA_clear_charbuff_ASM();		// allow user to clear screen by pushing a button
		} else {
			// if the RVALID flag is 1, enter this if block
			if (read_PS2_data_ASM(data)) {
				char input = *data;

				// typematic situation requires more logic, so put it here separately
				if (input == current) {
					if (previous == 0xF0 || previous == 0xFE || previous == 0xFA) {
						// if the previous is a break code, print the new keystroke and update our list
						previous = current;
						current = input;
						
						VGA_write_byte_ASM(x += 3, y, current);		// write the new key press to the screen
					} else {
						// otherwise, a key is being held, so start the typematic process
						
						// if input data is the current input, do nothing (i.e. can only hit each key once)
						clock += 1;		// increment "timer"
						
						if (delay) {
							// if we're still in the typematic delay phase, wait until the "clock" gets to 20
							if (clock < 8) {
								clock++;
							} else {
								VGA_write_byte_ASM(x += 3, y, current);	// output current key
								clock = 0;						// reset "clock"
								delay = 0;						// indicate that we've left the typematic delay phase
							}
						} else {
							if (clock < 2) {
								clock++;
							} else {
								VGA_write_byte_ASM(x += 3, y, current);	// output current key
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
						// if input data is empty, do nothing
					} else if (input == 0xF0 || input == 0xFE || input == 0xFA) {
						// if input data is a break code, print nothing but update our list
						previous = current;
						current = input;
					} else if (input == previous) {
						// current status is: previous = key, current = break code, input = same key
							// this must be the code sent after the break code, so we don't need to print anything
							// we need to update our list
						previous = current;
						current = input;
					} else {
						// input is a new key press
						// update list
						previous = current;
						current = input;
						
						VGA_write_byte_ASM(x += 3, y, current);		// write the new key press to the screen
					}
				}

				// if x or y have wrapped around, reset them
				if (x >= 78) {
					x = 0;
					y++;
					
					if (y > 59) {
						y = 0;
					}
				}
			}
		}
	} 

	/* ------------------- PART 3 - AUDIO ------------------ 
	// sample rate = 48 000 samples / second
	// square wave is 100 Hz
	// (48 000 samples / sec) / (100 cycles / sec) = 480 samples / cycle
		// 240 samples low, 240 samples high, repeat
	int samples = 0;
	int signal = 0x00FFFFFF;
	while(1) {
		// if there's space, send a value
		if (audio_port_ASM(signal)) {
			samples++;	// increment number of samples sent

			// when samples sent reaches 240, switch the signal
			if (samples > 239) {
				samples = 0;
				if (signal == 0) {
					signal = 0x00FFFFFF;
				} else {
					signal = 0;
				}
			}
		}
	}*/
}
