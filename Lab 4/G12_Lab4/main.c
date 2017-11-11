#include <stdio.h>

#include "./drivers/inc/pushbuttons.h"
#include "./drivers/inc/slider_switches.h"
#include "./drivers/inc/VGA.h"
#include "./drivers/inc/ps2_keyboard.h"

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
	// ------------------ PART 1 - VGA --------------------- //
	/*while(1) {
		int number = 0x1FF & read_slider_switches_ASM();	// keep all 9 slider digits
		int keys = 0xF & read_PB_data_ASM();				// keep all 4 key digits

		// TODO: change to (if - else if) if we only want one at a time to be possible
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
	int * PS2_port = (int *) 0xFF200100;		// PS/2 port address
	int previous = 0;
	while(1) {
		int keys = 0xF & read_PB_data_ASM();  		// keep all 4 key digits

		if (keys) {
			VGA_clear_charbuff_ASM();
		} else {
			// if the RVALID flag is 1, enter this if block
			if (read_PS2_data_ASM(PS2_port)) {
				int current = 0xFF & *PS2_port;

				if (current < 240 && current != previous) {		// do not print break codes or the previously typed value
					// the most recent input is a break code
					VGA_write_byte_ASM(x += 3, y, current);		// write the value stored in the first 8 bits of the PS2_data register
					
					// if x or y have wrapped around, reset them
					if (x > 79) {
						x = 0;
						y++;

						if (y > 59) {
							y = 0;
						}
					}
					// store this value for future use
					previous = current;
				}
			}
		}
	}

	/* ------------------- PART 3 - AUDIO ------------------
	// TODO: check all of this. C ain't my first language
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
