#include <stdio.h>

#include "./drivers/inc/LEDs.h"
#include "./drivers/inc/slider_switches.h"
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/pushbuttons.h"
#include "./drivers/inc/HPS_TIM.h"
#include "./drivers/inc/int_setup.h"
#include "./drivers/inc/ISRs.h"

int main() {
	/*	------------	PART 1 - Basic I/O Demonstration   --------------- 
	// perform continuously
	while (1) {	
		// illuminate LED for each switch
		write_LEDs_ASM(read_slider_switches_ASM());
		
		// determine number created by SW0-SW3
		int number = 0xF & read_slider_switches_ASM();	// only keep first four digits of binary representation
		int keys = 0xF & read_PB_data_ASM();			// only keep first four digits of binary representation	

		// illuminate the appropriate hex displays with the correct number
		if ((keys > 0) && (0x200 & read_slider_switches_ASM()) != 512) {
			// if any pushbuttons are pressed, flood HEX4 and HEX5
			HEX_flood_ASM(HEX4 | HEX5);
			
			// if any other pushbuttons are pressed, send the number to the appropriate HEX displays 
			switch (keys) {
				case 1 :
					HEX_write_ASM(HEX0, number);
					break;
				case 2 :
					HEX_write_ASM(HEX1, number);
					break;
				case 3:
					HEX_write_ASM(HEX0 | HEX1, number);
					break;
				case 4:
					HEX_write_ASM(HEX2, number);
					break;
				case 5:
					HEX_write_ASM(HEX0 | HEX2, number);
					break;
				case 6:
					HEX_write_ASM(HEX1 | HEX2, number);
					break;
				case 7:
					HEX_write_ASM(HEX0 | HEX1 | HEX2, number);
					break;
				case 8:
					HEX_write_ASM(HEX3, number);
					break;
				case 9:
					HEX_write_ASM(HEX0 | HEX3, number);
					break;
				case 10:
					HEX_write_ASM(HEX1 | HEX3, number);
					break;
				case 11:
					HEX_write_ASM(HEX0 | HEX1 | HEX3, number);
					break;
				case 12:
					HEX_write_ASM(HEX2 | HEX3, number);
					break;
				case 13:
					HEX_write_ASM(HEX0 | HEX2 | HEX3, number);
					break;
				case 14:
					HEX_write_ASM(HEX1 | HEX2 | HEX3, number);
					break;
				case 15:
					HEX_write_ASM(HEX0 | HEX1 | HEX2 | HEX3, number);
					break;
				default:
					// do nothing
					break;
			}
		} else if ((0x200 & read_slider_switches_ASM()) == 512) {
			// switch 9 is flipped => clear displays
			HEX_clear_ASM(HEX0 | HEX1 | HEX2 | HEX3 | HEX4 | HEX5);
		} else {
			// no buttons pressed => clear HEX0 to HEX3, but leave HEX4 and HEX5
			HEX_clear_ASM(HEX0 | HEX1 | HEX2 | HEX3);
		}
	} */


	/*	------------	PART 2 - SAMPLE TESTING CODE   ---------------

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
	} */

	/* -------------	PART 2 Timer-based Stopwatch   ---------------- 
	//Initialize first timer parameters
	HPS_TIM_config_t hps_tim;
	hps_tim.tim = TIM0;
	hps_tim.timeout = 1000000;
	hps_tim.LD_en = 1;
	hps_tim.INT_en = 0;
	hps_tim.enable = 1;

	HPS_TIM_config_ASM(&hps_tim); //Config timer 1

	//Initialize second timer parameters
	HPS_TIM_config_t hps_tim_pb;
	hps_tim_pb.tim = TIM1;
	hps_tim_pb.timeout = 5000;
	hps_tim_pb.LD_en = 1;
	hps_tim_pb.INT_en = 0;
	hps_tim_pb.enable = 1;

	HPS_TIM_config_ASM(&hps_tim_pb); //config timer 2

	int push_buttons = 0;
	int ms_count = 0;
	int sec_count = 0;
	int min_count = 0;

	int timer_start = 0; //Bit that holds whether time is running

	while(1) {
		if (HPS_TIM_read_INT_ASM(TIM0) && timer_start) {
			HPS_TIM_clear_INT_ASM(TIM0);
			ms_count += 10; //Timer is for 10 milliseconds

			//Ensure ms, sec and min are within their ranges
			if (ms_count >= 1000) {
				ms_count -= 1000;
				sec_count++;
				
				if (sec_count >= 60) {
					sec_count -= 60;
					min_count++;

					if (min_count >= 60) {
						min_count = 0;
					}
				}
			}

			//Get corecsponding digit and convert to ASCII
			HEX_write_ASM(HEX0, ((ms_count % 100) / 10));		// removed +48
			HEX_write_ASM(HEX1, (ms_count / 100));
			HEX_write_ASM(HEX2, (sec_count % 10));
			HEX_write_ASM(HEX3, (sec_count / 10));
			HEX_write_ASM(HEX4, (min_count % 10));
			HEX_write_ASM(HEX5, (min_count / 10));
		}

		if (HPS_TIM_read_INT_ASM(TIM1)) { //Timer to read push buttons
			HPS_TIM_clear_INT_ASM(TIM1);
			int pb = 0xF & read_PB_data_ASM();

			if ((pb & 1) && (!timer_start)) { //Start timer
				timer_start = 1;
			} else if ((pb & 2) && (timer_start)) { //Stop timer
				timer_start = 0;
			} else if (pb & 4) { //Reset timer
				ms_count = 0;
				sec_count = 0;
				min_count = 0;

				timer_start = 0; //Stop timer
				
				//Set every number to 0
				HEX_write_ASM(HEX0 | HEX1 | HEX2 | HEX3 | HEX4 | HEX5, 0);
			}
		}
	} */


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


	/*	------------	PART 3 - Interrupt-based Stopwatch  --------------- */
	int_setup(2, (int []) {73, 199}); //Enable interupts for push buttons and hps timer 0

	enable_PB_INT_ASM(PB0 | PB1 | PB2);	//Enable interrupts for pushbuttons

	//Initialize timer parameters
	HPS_TIM_config_t hps_tim;
	hps_tim.tim = TIM0;
	hps_tim.timeout = 1000000;
	hps_tim.LD_en = 1;
	hps_tim.INT_en = 0;
	hps_tim.enable = 1;

	HPS_TIM_config_ASM(&hps_tim); //Config timer

	// int push_buttons = 0;
	int ms_count = 0;
	int sec_count = 0;
	int min_count = 0;

	int timer_start = 0; //Bit that holds whether time is running

	while(1) {
		if (hps_tim0_int_flag) { //Check if timer interrupt occurs
			hps_tim0_int_flag = 0;

			if (timer_start) {
				ms_count += 10; //Timer is for 10 milliseconds

				//Ensure ms, sec and min are within their ranges
				if (ms_count >= 1000) {
					ms_count -= 1000;
					sec_count++;
				
					if (sec_count >= 60) {
						sec_count -= 60;
						min_count++;

						if (min_count >= 60) {
							min_count = 0;
						}
					}
				}

				//Get corecsponding digit and convert to ASCII
				HEX_write_ASM(HEX0, ((ms_count % 100) / 10));		// removed +48
				HEX_write_ASM(HEX1, (ms_count / 100));
				HEX_write_ASM(HEX2, (sec_count % 10));
				HEX_write_ASM(HEX3, (sec_count / 10));
				HEX_write_ASM(HEX4, (min_count % 10));
				HEX_write_ASM(HEX5, (min_count / 10));
			}
		}

		if (pb_int_flag != 0) { //Check if pb interrupt occurs
			if ((pb_int_flag & 1) && (!timer_start)) { //Start timer
				timer_start = 1;
			} else if ((pb_int_flag & 2) && (timer_start)) { //Stop timer
				timer_start = 0;
			} else if (pb_int_flag & 4) { //Reset timer
				ms_count = 0;
				sec_count = 0;
				min_count = 0;

				timer_start = 0; //Stop timer
				
				//Set every number to 0
				HEX_write_ASM(HEX0 | HEX1 | HEX2 | HEX3 | HEX4 | HEX5, 0);
			}

			pb_int_flag = 0;
		}
	}

	return 0;
}
