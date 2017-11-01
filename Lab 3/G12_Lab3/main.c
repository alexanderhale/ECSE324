#include <stdio.h>

#include "./drivers/inc/LEDs.h"
#include "./drivers/inc/slider_switches.h"
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/pushbuttons.h"
#include "./drivers/inc/HPS_TIM.h"
#include "./drivers/inc/int_setup.h"
#include "./drivers/inc/ISRs.h"

int main() {
	/*	------------	PART 1 - Basic I/O Demonstration   --------------- */

	// perform continuously
	while (1) {	
		// illuminate LED for each switch
		write_LEDs_ASM(read_slider_switches_ASM());
		
		// determine number created by SW0-SW3
		int number = 0xF & read_slider_switches_ASM();	// only keep first four digits of binary representation
		int keys = 0xF & read_PB_data_ASM();			// only keep first four digits of binary representation	

		// illuminate the appropriate hex displays with the correct number
		if ((keys > 0) && ((0x200 & read_slider_switches_ASM()) != 512)) {
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


	/*	------------	PART 2 - Timer-based Stopwatch   --------------- 

	int count0 = 0, count1 = 0, count2 = 0, count3 = 0;

	HPS_TIM_config_t hps_tim;

	hps_tim.tim = TIM0|TIM1|TIM2|TIM3;
	hps_tim.timeout = 1000000;
	hps_tim.LD_en = 1;
	hps_tim.INT_en = 1;
	hps_tim.enable = 1;

	HPS_TIM_config_ASM(&hps_tim);

	while(1) {
		if (HPS_TIM_read_INT_ASM(TIM0)) {
			
			HPS_TIM_clear_INT_ASM(TIM0);

			if (++count0 == 16) {
				count0 = 0;
			}

			HEX_write_ASM(HEX0, count0);
		}

		if (HPS_TIM_read_INT_ASM(TIM1)) {
			
			HPS_TIM_clear_INT_ASM(TIM1);

			if (++count1 == 16) {
				count1 = 0;
			}

			HEX_write_ASM(HEX1, count1);
		}

		if (HPS_TIM_read_INT_ASM(TIM2)) {
			
			HPS_TIM_clear_INT_ASM(TIM2);

			if (++count2 == 16) {
				count2 = 0;
			}

			HEX_write_ASM(HEX2, count2);
		}

		if (HPS_TIM_read_INT_ASM(TIM3)) {
			
			HPS_TIM_clear_INT_ASM(TIM3);

			if (++count3 == 16) {
				count3 = 0;
			}

			HEX_write_ASM(HEX3, count3);
		}
	}*/


	/*	------------	PART 3 - INTERRUPTS EXAMPLE   --------------- 

	int_setup(1, (int []){199});

	int count = 0;
	HPS_TIM_config_t hps_tim;

	hps_tim.tim = TIM0;
	hps_tim.timeout = 1000000;
	hps_tim.LD_en = 1;
	hps_tim.INT_en = 1;
	hps_tim.enable = 1;

	HPS_TIM_config_ASM(&hps_tim);

	while(1) {

		if (hps_tim0_int_flag) {
			hps_tim0_int_flag = 0;

			if (+count == 15) {
				count = 0;
			}

			HEX_write_ASM(HEX0, count);
		}
	}*/

	return 0;


	/*	------------	PART 3 - Interrupt-based Stopwatch  --------------- */
}
