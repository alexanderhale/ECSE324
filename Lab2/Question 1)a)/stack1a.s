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

LOOP: 		LDR R0, [R11]			//R0 holds the next number in the list
			STR R0, [R12, #4]!		// push value from R0 to top of stack, increment stack pointer
			ADD R11, R11, #4		// point to next number
			SUBS R10, R10, #1		// decrement loop counter
			BEQ NEXT				// leave loop if finished
			B LOOP					// back to start of loop

NEXT: 		LDMDA	R12!, {R0-R2}	// pop top 3 values of stack to R0, R1, and R2; decrement stack pointer after each pop

END: 		B END					// infinite loop

N:			 .word	4			//length of list
NUMBERS:	 .word	4, 5, 3, 6	//the list data
BOTTOMSTACK: .word	0			// location for the bottom of the stack