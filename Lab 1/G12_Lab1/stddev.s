		.text
		.global _start

_start:
			LDR R4, =RESULT		//R4 points to the max result location
			LDR R6, =RESULTMIN	// R6 points to the min result location
			LDR R10, =STDDEVRESULT	// R10 points to the standard deviation result location
			LDR R2, [R4, #4]	//R2 holds the number of elements in the list
			ADD R3, R4, #8		//R3 points to the first number
			LDR R0, [R3]		//R0 holds the first number in the list
			LDR R5, [R3] 		// R5 also holds the first number in the list

LOOP:		SUBS R2, R2, #1		// decrement the loop counter
			BEQ DONE			// end loop if counter has reached 0
			ADD R3, R3, #4		// R3 points to next number in the list
			LDR R1, [R3]		// R1 holds the next number in the list
			CMP R0, R1			// check if it is greater than the maximum
			BGE MINIMUM			// branch if new number is NOT greater than current max
			MOV R0, R1
			B LOOP				// if no, branch to the loop

MINIMUM:	CMP R5, R1
			BLE LOOP
			MOV R5, R1			// if yes, update the current min
			B LOOP				// branch back to the loop

DONE:		STR R0, [R4]		// store the result to the memory location
			STR R5, [R6]		

STDDEV: 	SUBS R11, R0, R5	// subtract Xmax - Xmin and store in R12
			LSR R12, R11, #2	// divide difference by 2^2 = 4 (i.e. shift by two bits to the right)
			STR R12, [R10]		// store the result to the memory location

END:		B END				// infinite loop!

RESULT:		.word	0			// memory assigned for max result location
N:			.word	8			// number of entries in the list
NUMBERS:	.word	4, 5, 3, 6	// the list data
			.word	1, 8, 2, 9
RESULTMIN: 	.word  	5			// memory assigned for min result location
STDDEVRESULT:	.word  6		// memory assigned for standard deviation locations