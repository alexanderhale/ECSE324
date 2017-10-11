.text
.global _start

_start:		

	LDR R4, = LASTNUMBER // Memory location for what was supposed to be the final number, ended up just being a memory reference for other values
	LDR R2, [R4, #4] // Number of iterations of fibonacci
	LDR R3, [R4, #12] //Comparing value for the inner loop
	LDR R6, [R4, #8] //Comparing value for init
	LDR R0, [R4, #12] //Lower value of the 2 most recent fibonacci numbers
	LDR R5, = POINTER //Pointer memory
	STR R0, [R5] //Assigns 1 to initial pointer memory
	SUB R5, R5, #4 //Reassigns pointer's memory location
	LDR R1, [R4, #12]  // Higher value of the 2 most recent fibonacci numbers
	STR R1, [R5] //Assigns more recent 1 to pointer
	
INIT:	CMP R6, R2 //Initial compare to see if n<2 , returns 1 
		BLE FIB
		B DONE

FIB: 	
		CMP R3, R2 //Initial compare statements, outer compare serves as a flag to see if the fibonacci sequence is done
		BEQ DONE
		SUBS R2, R2, #1
		CMP R2, R3  // Inner loop, acts as a down counter for the inner loop 
		BGT FIB 
		LDR R0, [R5, #4] //Reloads R0 and R1 values, necessary to reassign what R0 and R1 are after each number iteration
		LDR R1, [R5]
		ADD R7, R0, R1
		SUB R5, R5, #4 //Changes pointer position
		STR R7, [R5] //Stores new highest number at the pointer head
		LDR R2, [R4,#4] //Reloads outer loop counter
		ADD R3, R3, #1 //Increases inner loop counter
		B FIB

DONE:  LDR R10, [R5] //Stores the Fibonacci value in R10, makes it a bit easier to find the value 

END: B END


POINTER:			.word 0
LASTNUMBER: 		.word 0
N:					.word 13
TWO:				.word 2
ONE: 				.word 1
