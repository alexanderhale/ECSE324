#ifndef __ps2_keyboard
#define __ps2_keyboard
		
		// return: integer denoting whether the data read is valid or not
		// argument: char pointer, in which the data to be read is stored
		// functionality: check the RVALID bit in the PS/2 data register
			// if valid (1), store the data from the PS/2 data register
				// at the address of the char pointer argument. Return
				// 1 to indicate valid data.
			// if invalid, return 0
		int read_PS2_data_ASM(char * data);

	#endif
