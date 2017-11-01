#include <stdio.h>

#include "./drivers/inc/LEDs.h"
#include "./drivers/inc/slider_switches.h"
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/pushbuttons.h"

int main() {

	HEX_write_ASM(HEX1, 10);

	/* perform continuously
	while (1) {	
		// illuminate LED for each switch
		write_LEDs_ASM(read_slider_switches_ASM());
		
		// determine number created by SW0-SW3
		int number = 0xF & read_slider_switches_ASM();	// only keep first four digits of binary representation
		
		// convert to hexadecimal using ASCII chart
		if (number < 10) {
			number += 48;
		} else {
			number += 55;
		}

		int keys = 0xF & read_PB_data_ASM();	// only keep first four digits of binary representation	
		// HEX_write_ASM(keys, number);
		/* illuminate the appropriate hex displays with the correct number
		if (read_PB_data_ASM() > 0) {
			int keys = 0xF & read_PB_data_ASM();	// only keep first four digits of binary representation	
			
			switch (keys) {
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
		
		// if slider 9 is on, the value will be at least 2^9 = 512
		if (read_slider_switches_ASM() >= 512) {
			HEX_clear_ASM(HEX0 | HEX1 | HEX2 | HEX3 | HEX4 | HEX5);
		} 
	} */
	return 0;
}
