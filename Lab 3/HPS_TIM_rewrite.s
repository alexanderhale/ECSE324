			.text
			.equ TIM_0, 0xFFC08000				// base address of first timer
			.equ TIM_1, 0xFFC09000				// base address of second tmer
			.equ TIM_2, 0xFFD00000				// base address of third timer
			.equ TIM_3, 0xFFD01000				// base address of fourth timer
			.global HPS_TIM_config_ASM
			.global HPS_TIM_read_INT_ASM
			.global HPS_TIM_clear_INT_ASM

// remember: input value in R0 is HPS_TIM_config_t *param
HPS_TIM_config_ASM:
	PUSH {R1-R8}		// store all registers used to be recovered later (except R0, which holds the input)
	MOV R1, #0			// start loop counter at 0 in R1
	LDR R2, [R0]		// load starting address of timer struct into R2
	AND R2, R2, #0xF 	// remove everything except the last four bits, which is our encoded string of timers to use

CONFIG_LOOP:
	CMP R1, #4			// check loop counter
	BGE CONFIG_DONE		// if the counter has reached the fourth (last) digit of the 4-bit input string, leave
	AND R3, R2, #1		// put the rightmost bit of the input string in R3
	LSR R2, R2, #1		// shift input string one bit to the right to be ready for the next loop
	CMP R3, #0			// check if rightmost bit is 1 or zero (updates flags, which are used later in this block)
	BGT CONFIG_ONE 		// if rightmost bit is 1, perform config for that timer
	ADD R1, R1, #1		// if rightmost bit is 1, skip the process below and go back to top of loop: increment counter
	B CONFIG_LOOP		// back to top of loop

CONFIG_ONE:
	// load timer base address into R4 using the counter
	CMP R1, #0
	LDREQ R4, =TIM_0
	CMP R1, #1
	LDREQ R4, =TIM_1
	CMP R1, #2
	LDREQ R4, =TIM_2
	CMP R1, #3
	LDREQ R4, =TIM_3

	// disable timer while configuring
	MOV R5, #0x0 			// get some zeros ready
	STR R5, [R4, #0x8]		// store the zeros into the control word in the chosen timer
								// it's ok that we overwrite the bits that are currently there, because we'll be loading new ones in later anyway

	// set timeout (i.e. starting value)
	LDR R5, [R0, #0x4]		// load second value from input struct (timeout) into R5
	STR R5, [R2]			// store timeout value into the "load" memory location of our timer

	//  get M bit ready (M bit instructs timer to start at the value we loaded above when it restarts)
	LDR R5, [R0, #0x8]		// load third value from input struct (LD_en = load enable bit = M) into R5
	LSL R5, R5, #1			// shift by one bit left to get aligned with M bit location

	// get I bit ready (I bit is whether or not interrupts are enabled)
	LDR R6, [R0, #0xC]		// load fourth value from input struct (INT_en = interrupt enable bit (I)) into R6
	LSL R6, R6, #2			// shift by two bits left to get aligned with I bit location

	// get enable bit ready (enable bit = 1 when timer is running, 0 when it is stopped)
	LDR R7, [R0, 0x10]

	// combine M, I, and enable into one binary string
	ORR R8, R5, R6			// get M and I into R8
	ORR R8, R8, R7			// get enable into R8 			(couldn't do all three in one instruction)

	STR R8, [R4, #0x8]		// store the control word into the control memory location of our timer

	ADD R1, R1, #1			// increment loop counter
	B CONFIG_LOOP			// go back to the start of the loop

CONFIG_DONE:
	POP {R1-R8}				// recover the registers that we stored on the stack
	BX LR 					// leave



// remember: input value in R0 is HPS_TIM_t tim
	// only supports one timer => assumes the input string is one-hot encoded
	// TODO: same loop structure as previous subroutine is used - maybe condense some code?
HPS_TIM_read_INT_ASM:
	PUSH {R1-R5}		// store all registers used to be recovered later (except R0, which holds the input)
	MOV R1, #0			// start loop counter at 0 in R1
	AND R2, R2, #0xF 	// remove everything except the last four bits, which is our encoded string of timers to use

READ_LOOP:
	CMP R1, #4			// check loop counter
	BGE READ_DONE		// if the counter has reached the fourth (last) digit of the 4-bit input string, leave
	AND R3, R2, #1		// put the rightmost bit of the input string in R3
	LSR R2, R2, #1		// shift input string one bit to the right to be ready for the next loop
	CMP R3, #0			// check if rightmost bit is 1 or zero (updates flags, which are used later in this block)
	BGT READ_ONE 		// if rightmost bit is 1, perform config for that timer
	ADD R1, R1, #1		// if rightmost bit is 1, skip the process below and go back to top of loop: increment counter
	B READ_LOOP			// back to top of loop

READ_ONE:
	// load timer base address into R4 using the counter
	CMP R1, #0
	LDREQ R4, =TIM_0
	CMP R1, #1
	LDREQ R4, =TIM_1
	CMP R1, #2
	LDREQ R4, =TIM_2
	CMP R1, #3
	LDREQ R4, =TIM_3

	LDR R5, [R4, #0x10]			// load s-bit (interrupt status bit) from chosen timer into R3 using offset from base address
	AND R0, R5, #1				// put the s-bit into the rightmost bit of R0, ensuring that all other bits are 0
						 	// we're only supporting one timer, so since we already found that one timer, we can leave the loop
READ_DONE:
	POP {R1-R5}				// recover the registers that we stored on the stack
	BX LR 					// leave



// remember: input value in R0 is HPS_TIM_t tim
	// supports multiple timers => can't assume that the input string is one-hot encoded
HPS_TIM_clear_ASM:
	PUSH {R1-R5}		// store all registers used to be recovered later (except R0, which holds the input)
	MOV R1, #0			// start loop counter at 0 in R1
	LDR R2, [R0]		// load starting address of timer struct into R2
	AND R2, R2, #0xF 	// remove everything except the last four bits, which is our encoded string of timers to use

CLEAR_LOOP:
	CMP R1, #4			// check loop counter
	BGE CLEAR_DONE		// if the counter has reached the fourth (last) digit of the 4-bit input string, leave
	AND R3, R2, #1		// put the rightmost bit of the input string in R3
	LSR R2, R2, #1		// shift input string one bit to the right to be ready for the next loop
	CMP R3, #0			// check if rightmost bit is 1 or zero (updates flags, which are used later in this block)
	BGT CLEAR_ONE 		// if rightmost bit is 1, perform config for that timer
	ADD R1, R1, #1		// if rightmost bit is 1, skip the process below and go back to top of loop: increment counter
	B CLEAR_LOOP		// back to top of loop

CLEAR_ONE:
	// load timer base address into R4 using the counter
	CMP R1, #0
	LDREQ R4, =TIM_0
	CMP R1, #1
	LDREQ R4, =TIM_1
	CMP R1, #2
	LDREQ R4, =TIM_2
	CMP R1, #3
	LDREQ R4, =TIM_3

	LDR R5, [R4, #0xC]		// as stated in the manual, reading the F bit clears everything 

	ADD R1, R1, #1			// increment loop counter
	B CLEAR_LOOP			// go back to the start of the loop

CLEAR_DONE:
	POP {R1-R5}				// recover the registers that we stored on the stack
	BX LR 					// leave