#include <stdio.h>

#include "./drivers/inc/pushbuttons.h"
#include "./drivers/inc/slider_switches.h"
#include "./drivers/inc/VGA.h"
#include "./drivers/inc/ps2_keyboard.h"

void test_pixel();
int main() {
	// ------------------ PART 1 - VGA --------------------- //
	while(1) {
		test_pixel();




		/*int number = 0x1FF & read_slider_switches_ASM();	// keep all 9 slider digits
		int keys = 0xF & read_PB_data_ASM();				// keep all 4 key digits

		// TODO: change to (if - else if) if we only want one at a time to be possible
		if (0x1 & keys) {					// if first button is pressed
			if (number) {			// if any switches are on
				test_byte();
			} else {
				test_char();
			}
		}
		if (0x2 & keys) {					// if second key is pressed
			test_pixel();
		}
		if (0x4 & keys) {					// if third key is pressed
			VGA_clear_charbuff_ASM();
		}
		if (0x8 & keys) {					// if fourth keys is pressed
			VGA_clear_pixelbuff_ASM();
		}*/
	}

	/* ------------------- PART 2 - PS/2 KEYBOARD --------- 
	while(1) {
		if (read_PS2_data_ASM(/*char to display, from keyboard)) {

		}
	}*/

}

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
