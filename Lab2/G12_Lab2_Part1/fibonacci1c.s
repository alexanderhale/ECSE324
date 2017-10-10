/* 1c - fibonacci
.text
.global _start

_start:		

	LDR R4, = LASTNUMBER 		// Memory for the final number
	LDR R2, = N 				// Number of iterations of fibonacci
	LDR R3, = ZERO 				//Comparing value for the number of iterations
	LDR R0, = ONE 				//Initiates F(0)
	LDR R1, = ONE 				// Initiates F(1)
	LDR R5, = ZERO 				//Initiates temp value of R5

LOOP: SUBS R2, R2, #1
	CMP R3, R2 
	BGE DONE 				//BGE since if N=0, it would make a value of -1, requiring BGE
	ADD R5, R0, R1 //Finds new highest value for fibonacci
	MOV R0, R1 //Moves old largest value to smaller value
	MOV R1, R5 //Moves highest value for iteration into R1
	B LOOP

DONE: STR R1, [R4] //Stores highest value into R4 in memory


END: B END


LASTNUMBER: 		.word 0
N:				.word 5
ONE: 				.word 1
ZERO:				.word 0 */

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
N:					.word 5
ZERO:				.word 0
TWO:				.word 2
POINTER:			.word 0
ONE: 				.word 1
