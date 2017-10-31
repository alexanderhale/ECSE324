#include <stdio.h>

#include "./drivers/inc/LEDs.h"
#include "./drivers/inc/slider_switches.h"
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/pushbuttons.h"

int main() {
	// perform continuously
	while (1) {	
		// illuminate LED for each switch
		write_LEDs_ASM(read_slider_switches_ASM());
		
		
		// determine number created by SW0-SW3
		int number = read_slider_switches_ASM();
		number %= 16;	// only keep last four digits of binary representation
		
		// TODO: convert to appropriate hexadecimal digit (might not be necessary?)

		// illuminate the appropriate hex displays with the correct number
		if (read_PB_edgecap_ASM() > 0) {
			int keys = read_PB_data_ASM();
			keys %= 16; 	// only keep last four digits of binary representation		

			switch (keys) {
				case 0 :
					// do nothing
				case 1 :
					HEX_write_ASM(HEX0, number);
				case 2 :
					HEX_write_ASM(HEX1, number);
				case 3:
					HEX_write_ASM(HEX0 | HEX1, number);
				case 4:
					HEX_write_ASM(HEX2, number);
				case 5:
					HEX_write_ASM(HEX0 | HEX2, number);
				case 6:
					HEX_write_ASM(HEX1 | HEX2, number);
				case 7:
					HEX_write_ASM(HEX0 | HEX1 | HEX2, number);
				case 8:
					HEX_write_ASM(HEX3, number);
				case 9:
					HEX_write_ASM(HEX0 | HEX3, number);
				case 10:
					HEX_write_ASM(HEX2 | HEX3, number);
				case 11:
					HEX_write_ASM(HEX0 | HEX1 | HEX3, number);
				case 12:
					HEX_write_ASM(HEX2 | HEX3, number);
				case 13:
					HEX_write_ASM(HEX0 | HEX2 | HEX3, number);
				case 14:
					HEX_write_ASM(HEX1 | HEX2 | HEX3, number);
				case 15:
					HEX_write_ASM(HEX0 | HEX1 | HEX2 | HEX3, number);
			}

			// if any pushbuttons are pressed, light up 
			HEX_flood_ASM(HEX4 | HEX5);
		}
		/*
		// clear all hex displays when slider 9 is on
		int slider9 = read_slider_switches_ASM();
		
		// if slider 9 is on, the value will be at least 2^9 = 512
		if (slider9 >= 512) {
			HEX_clear_ASM(HEX0 | HEX1 | HEX2 | HEX3 | HEX4 | HEX5);
		} 
			*/
	}
	return 0;
}
