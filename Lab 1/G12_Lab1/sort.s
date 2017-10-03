			.text
			.global _start

_start:
			LDR R10, =ZERO		// get address of zero
			LDR R10, [R10]		// hold value of zero
			LDR R11, =ONE		// get address of one
			LDR R11, [R11]		// hold address of one
			LDR R12, =N			// get address of signal length
			LDR R9, [R12]		// hold value of signal length (constant, never changed)
			LDR R12, [R12]		// hold value of signal length (used as counter)

OUTER:		SUBS R12, R12, #1	// reduce outer counter by one
			BEQ END				// if counter reaches zero, go to end
			LDR R2, =NUMBERS	// get address of first number
			ADD R3, R2, #4		// get address of second number
			LDR R0, [R2]		// hold first number in R0
			LDR R1, [R3]		// hold second number in R1
			CPY R8, R9			// copy signal length to R8 to be used as inner counter
			
INNER: 		SUBS R8, R8, #1		// reducer inner counter by one
			BEQ OUTER			// if counter reaches zero, go to outer loop

COMPARE:	CMP R1, R0			// check which value is greater
			BGE FORWARD			// if second value greater, don't need to swap => skip forward
			MOV R7, R1			// move second value to holding register
			MOV R1, R0			// move first value to second register
			MOV R0, R7			// move holding value to first register

FORWARD:	STR R0, [R2]		// store values back to the same memory addresses
			STR R1, [R3]
			ADD R2, R2, #4		// increment pointers
			ADD R3, R3, #4
			LDR R0, [R2]		// load next values
			LDR R1, [R3]
			B INNER

END:		B END

ZERO: 		.word   0
ONE:	 	.word 	1			
N: 			.word	7			// number of entries in the list
NUMBERS:	.word	4, 5, 3, 6	//the list data
			.word	1, 8, 2