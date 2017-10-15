// 1.2 - find max with stack
		.text
		.global _start

_start:	LDR R10, =N 		// R10 points to the number of elements in the list
		LDR R0, [R10, #4]	// R0 holds the first number
		LDR R1, [R10, #8]	// R1 holds the second number
		LDR R2, [R10, #12]	// R2 holds the third number
		LDR R3, [R10, #16]	// R3 holds the fourth number
		LDR R10, [R10]		// R10 holds the number of elements in the list
		BL FINDMAX 			// branch to the subroutine
		LDR R11, =RESULT 	// R11 points to the result location
		STR R0, [R11]		// store the result in the defined location

END: 	B END 	// infinite loop

FINDMAX:	STR R1, [SP, #-4]!	// push R1 onto stack
			STR R2, [SP, #-4]!	// push R2 onto stack
			STR R3, [SP, #-4]!	// push R3 onto stack

LOOP:		SUBS R10, R10, #1	// decrement loop counter
			BEQ DONE			// end loop if counter reaches 0
			LDR R12, [SP], #4	// pop top of stack into R12
			CMP R0, R12			// compare R0 to R12
			BGE	LOOP			// if R0 > R12, branch to loop
			MOV R0, R12			// else, replace with new max
			B LOOP 				// branch back to loop

DONE:		BX LR


RESULT: 	.word	0			// location for result to be stored
N:			.word	4			//length of list
NUMBERS:	.word	4, 5, 3, 6	//the list data