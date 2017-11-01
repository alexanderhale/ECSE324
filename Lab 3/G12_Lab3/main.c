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
		int number = 0xF & read_slider_switches_ASM();	// only keep first four digits of binary representation
		int keys = 0xF & read_PB_data_ASM();			// only keep first four digits of binary representation	

		// illuminate the appropriate hex displays with the correct number
		if ((keys > 0) && ((0x200 & read_slider_switches_ASM()) != 512) {
			// if any pushbuttons are pressed, flood HEX4 and HEX5
			HEX_flood_ASM(HEX4 | HEX5);
			
			// if any other pushbuttons are pressed, send the number to the appropriate HEX displays 
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
		} else if ((0x200 & read_slider_switches_ASM()) == 512) {
			// switch 9 is flipped => clear displays
			HEX_clear_ASM(HEX0 | HEX1 | HEX2 | HEX3 | HEX4 | HEX5);
		}
	}
	return 0;
}
