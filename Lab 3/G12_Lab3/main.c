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

	/* -------------	PART 2 Polling-based Stopwatch   ---------------- */
	// variables that hold time counters and the timer enable boolean
	int ms = 0;
	int s = 0;
	int min = 0;
	int tim_en = 0;

	// configure the timer that displays the digits
	HPS_TIM_config_t hps_tim;
	hps_tim.tim = TIM0;
	hps_tim.timeout = 1000000;
	hps_tim.LD_en = 1;
	hps_tim.INT_en = 0;
	hps_tim.enable = 1;
	HPS_TIM_config_ASM(&hps_tim);

	// configure the timer that detects button presses
	HPS_TIM_config_t hps_tim_pb;
	hps_tim_pb.tim = TIM1;
	hps_tim_pb.timeout = 5000;
	hps_tim_pb.LD_en = 1;
	hps_tim_pb.INT_en = 0;
	hps_tim_pb.enable = 1;
	HPS_TIM_config_ASM(&hps_tim_pb);

	while(1) {

		// if the stopwatch is on and there's something to read from the stopwatch timer, enter here
		if (HPS_TIM_read_INT_ASM(TIM0) && tim_en) {
			
			HPS_TIM_clear_INT_ASM(TIM0);		// clear the timer
			
			ms += 10; 							// 10ms has passed since the last time we were here

			// if we have overflow of milliseconds, increase the number of seconds
			if (ms == 1000) {
				ms = 0;
				s++;
			}

			// if we have an overflow of seconds, increase the number of minutes
			if (s == 60) {
				s = 0;
				min++;
			}

			// if we have an overflow of minutes, go back to zero. No hour unit is available
			if (min == 60) {
				min = 0;
			}

			// write the digits to the hex displays
			HEX_write_ASM(HEX0, ((ms % 100) / 10));
			HEX_write_ASM(HEX1, (ms / 100));
			HEX_write_ASM(HEX2, (s % 10));
			HEX_write_ASM(HEX3, (s / 10));
			HEX_write_ASM(HEX4, (min % 10));
			HEX_write_ASM(HEX5, (min / 10));
		}

		// if there's something to read from the pushbutton timer, enter here
		if (HPS_TIM_read_INT_ASM(TIM1)) {
			
			HPS_TIM_clear_INT_ASM(TIM1);		// clear the timer
			int pb = 0xF & read_PB_data_ASM();	// get the last four digits of the pushbuttons

			if ((pb_int_flag & 1) && (!tim_en)) { 				// if PB0 is pressed and the timer is off, start the timer
				tim_en = 1;
			} else if ((pb_int_flag & 2) && (tim_en)) { 		// if PB1 is pressed and the timer is on, stop the timer
				tim_en = 0;
			} else if (pb_int_flag & 4) { 						// if PB2 is pressed at any time, reset the timer and stop it
				ms = 0;
				s = 0;
				min = 0;
				tim_en = 0;
				HEX_write_ASM(HEX0 | HEX1 | HEX2 | HEX3 | HEX4 | HEX5, 0);
			}
		}
	}


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


	/*	------------	PART 3 - Interrupt-based Stopwatch  --------------- 
	int_setup(2, (int []) {73, 199});				// enable interrupts for timer with supplied code
	enable_PB_INT_ASM(PB0 | PB1 | PB2);				// enable interrupts for pushbuttons with written code
	
	// variables that hold time counters and the timer enable boolean
	int ms = 0;
	int s = 0;
	int min = 0;
	int tim_en = 0;

	// configure the timer that updates the stopwatch displays
	HPS_TIM_config_t hps_tim;
	hps_tim.tim = TIM0;
	hps_tim.timeout = 1000000;
	hps_tim.LD_en = 1;
	hps_tim.INT_en = 0;
	hps_tim.enable = 1;
	HPS_TIM_config_ASM(&hps_tim);

	// loop forever
	while(1) {

		// if we get a timer interrupt, enter this block
		if (hps_tim0_int_flag) { 

			// if the timer is on, increase the counts of each unit and display them to the hex displays
			if (tim_en) {

				ms += 10; // 10ms has passed since the last time an interrupt was raised

				// if we have overflow of milliseconds, increase the number of seconds
				if (ms == 1000) {
					ms = 0;
					s++;
				}

				// if we have an overflow of seconds, increase the number of minutes
				if (s == 60) {
					s = 0;
					min++
				}

				// if we have an overflow of minutes, go back to zero. No hour unit is available
				if (min == 60) {
					min = 0;
				}

				// write the digits to the hex displays
				HEX_write_ASM(HEX0, ((ms % 100) / 10));
				HEX_write_ASM(HEX1, (ms / 100));
				HEX_write_ASM(HEX2, (s % 10));
				HEX_write_ASM(HEX3, (s / 10));
				HEX_write_ASM(HEX4, (min % 10));
				HEX_write_ASM(HEX5, (min / 10));
			}

			hps_tim0_int_flag = 0;		// lower the timer interrupt flag
		}

		// look out for interrupts from the pushbuttons on every iteration
		if (pb_int_flag > 0) { 
			if ((pb_int_flag & 1) && (!tim_en)) { 				// if PB0 is pressed and the timer is off, start the timer
				tim_en = 1;
			} else if ((pb_int_flag & 2) && (tim_en)) { 		// if PB1 is pressed and the timer is on, stop the timer
				tim_en = 0;
			} else if (pb_int_flag & 4) { 						// if PB2 is pressed at any time, reset the timer and stop it
				ms = 0;
				s = 0;
				min = 0;
				tim_en = 0;
				HEX_write_ASM(HEX0 | HEX1 | HEX2 | HEX3 | HEX4 | HEX5, 0);
			}

			pb_int_flag = 0;			// lower the pushbutton interrupt flag
		}
	}*/

	return 0;
}
