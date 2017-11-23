#include <stdio.h>
#include <math.h>
// #include <fenv.h>

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

int signal(float f, int t) {
	int temp = (int)(f*t);
	int index = temp % 48000;				// TODO: make this a float
	int indexLeftOfDecimal = (int)index;
	float decimals = index - indexLeftOfDecimal;
	float interpolated = (1-decimals)*sine[indexLeftOfDecimal] + (decimals)*sine[indexLeftOfDecimal+1];

	// TODO: replace amplitude here
	return 1 * interpolated;
}

int main() {
	int samples = 0;

	while(1) {
		/* ------------------- PART 1 - Make Waves ------------------ */
		/*char* data;		// PS/2 port address
		float f = 0;		// frequency of note to play
		// if the RVALID flag is 1, enter this if block
		if (read_ps2_data_ASM(data)) {
			char input = *data;

			// typematic situation requires more logic, so put it here separately
			if (input == 0x1C) {
				// hit A, play a C
				f = 130.813;
			} else if (input == 0x1B) {
				// hit S, play a D
				f = 146.832;
			} else if (input == 0x23) {
				// hit D, play an E
				f = 164.814;
			} else if (input == 0x2B) {
				// hit F, play an F
				f = 174.614;
			} else if (input == 0x3B) {
				f = 195.998;
			} else if (input == 0x42) {
				f = 220.000;
			} else if (input == 0x4B) {
				f = 246.942;
			} else if (input == 0x4C) {
				f = 261.626;
			} else {
				f = 0.1;
				samples = 0;
			}
		}*/

		// TODO: deal with multiple key presses at the same time

		// generate sample
		int f = 100;
		int endOfSignal = 48000 / f;
		while(1) {
			// if there's space, send a value
			int s = signal(f, samples);
			audio_write_data_ASM(s, s);
			samples++;	// increment number of samples sent
			// when samples sent reaches the end of the period, go back to the start
			if (samples > endOfSignal) {
				samples = 0;
			}
		}
	}

	return 0;
}
