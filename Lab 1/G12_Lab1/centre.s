		.text
		.global _start

_start:
		LDR R4, =AVERAGE	//R4 points to the average location
		LDR R6, [R4, #4]		// start with value of 0 for number of shits (determine length of list)
		LDR R5, [R4, #8]		// start with value of 1 for loop later
		LDR R2, [R4, #12]	//R2 holds the number of elements in the list
		ADD R3, R4, #16		//R3 points to the first number
		LDR R0, [R3]		//R0 holds the first number in the list

LOOP:	SUBS R2, R2, #1		// decrement the loop counter
		BEQ AVG				// end loop if counter has reached 0
		ADD R3, R3, #4		// R3 points to next number in the list
		LDR R1, [R3]		// R1 holds the next number in the list
		ADD R0, R0, R1		// add the new value to the existing total
		B LOOP				// if no, branch to the loop

AVG: 	LDR R2, [R4, #12]	//R2 holds the number of elements in the list
		
AVGLOOP: CMP R5, R2
		 BGE FOUND		//R5 has reached the length of the list
		 ADD R6, R6, #1	// increase count by 1
		 LSL R5, R5, #1	// increase by a power of 2
		 B AVGLOOP		// loop back

FOUND: 	LSR R0, R0, R6	// divide the total by the number of items in the list to get the average
		ADD R3, R4, #16	// point to the first number in the list
		LDR R1, [R3]	// load the first number of the list into R1

NEWLOOP: SUBS R1, R1, R0	// subtract the average from this number
		 STR R1, [R3]
		 SUBS R2, R2, #1	// decrement the loop counter
		 BEQ END			// if reached end of list, leave loop
		 ADD R3, R3, #4		// move to next number
		 LDR R1, [R3]
		 B NEWLOOP			// branch to top of loop	

END:	B END

AVERAGE:	.word	0			// memory assigned for average location
ZERO: 		.word 	0
ONE:		.word 	1
N:			.word	8			// number of entries in the list
NUMBERS:	.word	4, 5, 3, 6	// the list data
			.word	1, 8, 2, 7