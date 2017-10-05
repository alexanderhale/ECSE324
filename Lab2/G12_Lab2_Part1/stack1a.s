/* 1.1 - the stack
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
*/

// RECURSIVE VERSION

.text
.global _start

_start:		

	LDR R4, = LASTNUMBER // Memory for the final number
	LDR R2,[R4, #4] // Number of iterations of fibonacci
	LDR R3,[R4, #8] //Comparing value for the number of iterations
	LDR R6,[R4, #12] //Initializes value of 2
	LDR R5, = POINTER // Initiates Pointer
	LDR R0, [R5] //Initiates F(0)
	LDR R0, = ONE
	SUB R5, R5, #4
	LDR R1,[R5] // Initiates F(1)
LDR R1, = ONE
	
INIT:	CMP R6, R2
	BLE FIB
	LDR R5, [R1]
	B END

FIB: 	SUBS R2, R2, #1
	CMP R3, R2 
	BLE FIB
	LDR R0, [R5, #-4]
	LDR R1, [R5] 
	SUBS R5, R5, #-4
	ADD R7, R1, R0
	LDR R5, [R7]
	B END


END: B END


LASTNUMBER: 		.word 0
N:				.word 5
ZERO:				.word 0
TWO:				.word 2
POINTER:			.word 0
ONE: 				.word 1

