			.text
			.equ TIM_0, 0xFFC08000				// base address of first timer
			.equ TIM_1, 0xFFC09000				// base address of second tmer
			.equ TIM_2, 0xFFD00000				// base address of third timer
			.equ TIM_3, 0xFFD01000				// base address of fourth timer
			.global HPS_TIM_config_ASM
			.global HPS_TIM_read_INT_ASM
			.global HPS_TIM_clear_INT_ASM


// input value in R0 holds: HPS_TIM_config_t *param
HPS_TIM_config_ASM:
			PUSH {R1-R7}				// store the registers that we're planning to use so we can recover them later
			LDR R3, [R0]				// load starting address of timer struct into R3
			AND R3, R3, #0xF			// remove everything from the input except the last four bits (our encoded string of timers to use)
			MOV R1, #0					// start loop counter at 0 in R1
			
HPS_TIM_config_ASM_LOOP:
			CMP R1, #4					// check loop counter
			BGE HPS_TIM_config_ASM_DONE	// if the counter has reached the fourth (last) digit of the 4-bit input string, leave
			AND R5, R3, #1				// put the rightmost bit of the input in R5
			CMP R5, #0					// check if the rightmost bit is 1 or 0 (updates flags, which are used later in this block)
			ASR R3, R3, #1				// shift input string one bit to the right (TODO: should this be LSL? no need to preserve sign bit, since it gets ANDed away anyway)
			ADDEQ R1, R1, #1			// if rightmost bit was zero, skip the process below. Increment counter
			BEQ HPS_TIM_config_ASM_LOOP	// if rightmost bit was zero, skip the process below. Branch back to start of loop

			// load timer into R2, using the counter to determine which counter we're loading
			CMP R1, #0
			LDREQ R2, =TIM_0
			CMP R1, #1
			LDREQ R2, =TIM_1
			CMP R1, #2
			LDREQ R2, =TIM_2
			CMP R1, #3
			LDREQ R2, =TIM_3
		
			// disable timer before configuring
			LDR R4, [R0, #0x8]			// put third value from input struct (LD_en = load enable bit??) into R4
			AND R4, R4, #0x6			// set enable bit to zero while keeping the others by ANDing with 110
			STR	R4, [R2, #0x8] 			// store the control bits into the correct timer (which we determined above)
	
			// configure timeout (i.e. starting value)
			LDR R4, [R0, #0x4]			// load second value from input struct (timeout) into R4
			STR R4, [R2] 				// store timeout value into the "load" memory location of our timer

			// get M bit ready (M bit instructs timer to start at the value we loaded above when it restarts)
			LDR R4, [R0, #0x8]			// load third value from input struct (LD_en = load enable bit = M) into R4
			LSL R4, R4, #1				// shift by one bit left to get aligned with M bit location
			// TODO: why do we use the same input string for both the entire control word (above) _and_ just the M bit?

			// get I bit ready (I bit is whether or not interrupts are enabled)
			LDR R5, [R0, #0xC]			// load fourth value from input struct (INT_en = interrupt enable bit (I)) into R5
			LSL R5, R5, #2				// shift by two bits left to get aligned with I bit location

			// get enable bit ready (enable bit = 1 when timer is running, 0 when it is stopped)
			LDR R6, [R0, #0x10]			// load fifth value from input struct (enable = enable bit (E)) into R6

			ORR R7, R4, R5				// get M and I into R7
			ORR R7, R7, R6				// get E into R7

			STR R7, [R2, #0x8]			// store the control word into the control memory location of our timer

			ADD R1, R1, #1				// increment loop counter
			B HPS_TIM_config_ASM_LOOP	// go back to the start of the loop

HPS_TIM_config_ASM_DONE:
			POP {R1-R7}		// recover the registers that we stored on the stack
			BX LR 			// leave


// input value in R0 holds: HPS_TIM_t tim
	// only supports one timer => assumes the input string is one-hot encoded
HPS_TIM_read_INT_ASM:
			PUSH {R1-R4}				// store the values of the registers that we're planning to use so we can recover them later
			AND R0, R0, #0xF			// remove everything from the input except the last four bits, which contain our encoded string
			MOV R1, #0					// start loop counter at 0 in R1
			
HPS_TIM_read_ASM_LOOP:
			CMP R1, #4					// check loop counter
			BGE HPS_TIM_read_ASM_DONE	// if the counter has reached the fourth (last) digit of the 4-bit input string, leave
			AND R4, R0, #1 				// put the rightmost bit of the input in R4
			CMP R4, #0					// check if the rightmost bit of the input is 1 or 0 (updates flags, which are used later in this block)
			ASR R0, R0, #1				// shift input string one bit to the right (TODO: should this be LSL? no need to preserve sign bit, since it gets ANDed away anyway)
			ADDEQ R1, R1, #1			// if rightmost bit was zero, skip the process below. Increment counter
			BEQ HPS_TIM_read_ASM_LOOP	// if rightmost bit was zero, skip the process below. Branch back to start of loop

			// load timer into R2, using the counter to determine which counter we're loading
			CMP R1, #0
			LDREQ R2, =TIM_0
			CMP R1, #1
			LDREQ R2, =TIM_1
			CMP R1, #2
			LDREQ R2, =TIM_2
			CMP R1, #3
			LDREQ R2, =TIM_3

			LDR R3, [R2, #0x10]			// load s-bit (interrupt status bit) from chosen timer into R3 using offset from base address
			AND R0, R3, #1				// put the s-bit into the rightmost bit of R0, ensuring that all other bits are 0
			B HPS_TIM_read_ASM_DONE 	// we're only supporting one timer, so since we already found that one timer, we can leave

HPS_TIM_read_ASM_DONE:
			POP {R1-R4}			// recover the registers that we stored on the stack
			BX LR 				// leave


// input value in R0 holds: HPS_TIM_t tim
	// supports multiple timers => can't assume that the input string is one-hot encoded
HPS_TIM_clear_INT_ASM:
			PUSH {R1-R4}				// store the values of the registers that we're planning to use so we can recover them later
			AND R0, R0, #0xF			// remove everything from the input except the last four bits, which contain our encoded string
			MOV R1, #0					// start loop counter at 0 in R1
			
HPS_TIM_clear_INT_ASM_LOOP:
			CMP R1, #4							// check loop counter
			BGE HPS_TIM_clear_INT_ASM_DONE		// if the counter has reached the fourth (last) digit of the 4-bit input string, leave
			AND R4, R0, #1 						// put the rightmost bit of the input in R4
			CMP R4, #0							// check if the rightmost bit of the input is 1 or 0 (updates flags, which are used later in this block)
			ASR R0, R0, #1						// shift input string one bit to the right (TODO: should this be LSL? no need to preserve sign bit, since it gets ANDed away anyway)
			ADDEQ R1, R1, #1					// if rightmost bit was zero, skip the process below. Increment counter
			BEQ HPS_TIM_clear_INT_ASM_LOOP	//Branch back to loop if 0

			// load timer into R2, using the counter to determine which counter we're loading
			CMP R1, #0
			LDREQ R2, =TIM_0
			CMP R1, #1
			LDREQ R2, =TIM_1
			CMP R1, #2
			LDREQ R2, =TIM_2
			CMP R1, #3
			LDREQ R2, =TIM_3

			LDR R4, [R2, #0xC]			// as stated in manual, reading the F bit clears everything 

			ADD R1, R1, #1					// increment loop counter
			B HPS_TIM_clear_INT_ASM_LOOP	// go back to the start of the loop

HPS_TIM_clear_INT_ASM_DONE:
			POP {R1-R4}		// recover the registers that we stored on the stack
			BX LR			// leave

			.end