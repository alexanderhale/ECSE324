// 1.1 - the stack
			.text
			.global _start

_start:	
			// create our own stack pointer
			// stack pointer points to the top of the stack
			// the stack has no data yet, so the top is also the bottom
			LDR R12, =BOTTOMSTACK

			LDR R10, =N			//R10 points to the number of elements in the list
			LDR R10, [R10]		// R10 holds the number of elements in the list
			LDR R11, =NUMBERS	//R1 points to the first number

LOOP: 		SUBS R10, R10, #1		// decrement loop counter
			BEQ NEXT			// leave loop if finished
			LDR R0, [R11]		//R0 holds the next number in the list
			STR R0, [R12, #4]!	// push value from R0 to top of stack, increment stack pointer
			ADD R11, R11, #4		// point to next number
			B LOOP				// back to start of loop

NEXT: 		LDMIA	R12!, {R0-R2}	// 

END: 		B END

// TODO:
	// LDMIA was in 50, 54, 58; should be in 48, 4C, 50
	// skipped storing anything in 1st spot of stack
	// ended loop 1 iteration too soon

N:			.word	4			//length of list
NUMBERS:	.word	4, 5, 3, 6	//the list data
BOTTOMSTACK: .word	0			// location for the bottom of the stack
