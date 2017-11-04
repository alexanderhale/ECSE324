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
	PUSH {R1-R8, R12}		// store all registers used to be recovered later (except R0, which holds the input)
	MOV R1, #0				// start loop counter at 0 in R1
	MOV R12, #1				// states that we are operating in config mode for loop
	LDR R2, [R0]			// load starting address of timer struct into R2
	AND R2, R2, #0xF 		// remove everything except the last four bits, which is our encoded string of timers to use
	B LOOP

// remember: input value in R0 is HPS_TIM_t tim
HPS_TIM_read_INT_ASM:
	PUSH {R1-R5, R12}		// store all registers used to be recovered later (except R0, which holds the input)
	MOV R1, #0				// start loop counter at 0 in R1
	MOV R12, #2				// states that we are operating in read mode for loop
	LDR R2, [R0]
	AND R2, R2, #0xF 		// remove everything except the last four bits, which is our encoded string of timers to use
	B LOOP

// remember: input value in R0 is HPS_TIM_t tim
HPS_TIM_clear_INT_ASM:
	PUSH {R1-R5, R12}		// store all registers used to be recovered later (except R0, which holds the input)
	MOV R1, #0			// start loop counter at 0 in R1
	MOV R12, #3		// states that we are operating in clear mode for loop
	LDR R2, [R0]		// load starting address of timer struct into R2
	AND R2, R2, #0xF	// remove everything except the last four bits, which is our encoded string of timers to use
	B LOOP

LOOP:
	CMP R1, #4			// check loop counter
	BGE LOOP_DONE		// if the counter has reached the fourth (last) digit of the 4-bit input string, leave
	AND R3, R2, #1		// put the rightmost bit of the input string in R3
	CMP R3, #0			// check if rightmost bit is 1 or zero (updates flags, which are used later in this block)
	ASR R2, R2, #1		// shift input string one bit to the right to be ready for the next loop
	ADDEQ R1, R1, #1		// if rightmost bit is 1, skip the process below and go back to top of loop: increment counter
	BEQ LOOP				// back to top of loop
	B LOOP_OUT
LOOP_OUT:
	// load timer base address into R4 using the counter
	CMP R1, #0
	LDREQ R4, =TIM_0
	CMP R1, #1
	LDREQ R4, =TIM_1
	CMP R1, #2
	LDREQ R4, =TIM_2
	CMP R1, #3
	LDREQ R4, =TIM_3
	
	CMP R12, #1
	BEQ CONFIG 		//begins config mode
	CMP R12, #2
	BEQ READ		//begins read mode
	CMP R12, #3
	BEQ CLEAR		//begins clear mode

LOOP_DONE:

	CMP R12, #1
	BEQ CONFIG_DONE			//finishes config mode
	CMP R12, #2	
	BEQ READ_DONE
	CMP R12, #3
	BEQ CLEAR_DONE			//finishes clear mode

CONFIG:
	// disable timer while configuring
	LDR R5, [R0, #0x8] 			// get some zeros ready
	AND R5, R5, #0x6
	STR R5, [R4, #0x8]		// store the zeros into the control word in the chosen timer
								// it's ok that we overwrite the bits that are currently there, because we'll be loading new ones in later anyway
	// set timeout (i.e. starting value)
	LDR R5, [R0, #0x4]		// load second value from input struct (timeout) into R5
	STR R5, [R4]			// store timeout value into the "load" memory location of our timer

	//  get M bit ready (M bit instructs timer to start at the value we loaded above when it restarts)
	LDR R5, [R0, #0x8]		// load third value from input struct (LD_en = load enable bit = M) into R5
	LSL R5, R5, #1			// shift by one bit left to get aligned with M bit location

	// get I bit ready (I bit is whether or not interrupts are enabled)
	LDR R6, [R0, #0xC]		// load fourth value from input struct (INT_en = interrupt enable bit (I)) into R6
	LSL R6, R6, #2			// shift by two bits left to get aligned with I bit location

	// get enable bit ready (enable bit = 1 when timer is running, 0 when it is stopped)
	LDR R7, [R0, #0x10]

	// combine M, I, and enable into one binary string
	ORR R8, R5, R6			// get M and I into R8
	ORR R8, R8, R7			// get enable into R8 			(couldn't do all three in one instruction)

	STR R8, [R4, #0x8]		// store the control word into the control memory location of our timer

	ADD R1, R1, #1			// increment loop counter
	B LOOP				// go back to the start of the loop

CONFIG_DONE:
	POP {R1-R8, R12}				// recover the registers that we stored on the stack
	BX LR 					// leave

READ:
	LDR R5, [R4, #0x10]			// load s-bit (interrupt status bit) from chosen timer into R3 using offset from base address
	AND R0, R5, #1				// put the s-bit into the rightmost bit of R0, ensuring that all other bits are 0
	B READ_DONE

READ_DONE:								// we're only supporting one timer, so since we already found that one timer, we can leave the loop
	POP {R1-R5, R12}			// recover the registers that we stored on the stack
	BX LR 					// leave

CLEAR:
	LDR R5, [R4, #0xC]		// as stated in the manual, reading the F bit clears everything 
	ADD R1, R1, #1			// increment loop counter
	B LOOP				// go back to the start of the loop

CLEAR_DONE:
	POP {R1-R5, R12}			// recover the registers that we stored on the stack
	BX LR 					// leave
