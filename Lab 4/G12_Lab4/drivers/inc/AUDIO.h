// asdf
#ifndef __AUDIO
#define __AUDIO
		
		// return: 1 if both FIFOs have space, 0 otherwise
		// argument: integer to be written to the L and R FIFOs
		// functionality: check if the L and R FIFOs have space using
				// the WSLC and WSRC values. If both have space, write
				// the int to both and return 1. Otherwise, return 0.
		int audio_port_ASM(int data);

	#endif
