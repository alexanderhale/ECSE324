  	.text
	.equ HEX_0to3, 0xFF200020
	.equ HEX_4to5, 0xFF200030
	// .global HEX_clear_ASM
	//.global HEX_flood_ASM
	//.global HEX_write_ASM
	.global _start

_start:	MOV R0, #0x4
		MOV R1, #12
		B HEX_write_ASM


HEX_clear_ASM:			// turn off everything in the requested hex displays
	LDR R2, ZEROS		// load 00000000 into R2
	B RUN

HEX_flood_ASM:			// light up everything in the requested hex displays
	LDR R2, ONES		// load 11111111 into R1
	B RUN

HEX_write_ASM:			// display the corresponding hexadecimal digit in the requested hex displays
	LDR R2, =LIGHTS		// hold address of first encoded light sequence
	MOV R3, #4			// multiple for use on next line
	MUL R3, R3, R1      // multiply input shift by four
	LDR R2, [R2, R3]	// put appropriate 1 byte encoded light sequence into R2, using base address + shift according to 4*input
	B RUN

RUN:
	PUSH {R0}
	PUSH {LR}
	MOV R8, #32			// R8 holds the current power of 2 that is being used for comparison
	MOV R9, #1			// R9 holds the memory offset counter
	ROR R2, #24			// shift input value to be aligned with 2nd bit (in accordance with offset counter)
	MOV R6, #31			// load binary string 00000000 00000000 00000000 00011111, to be used to reduce the input string
	LDR R10, =HEX_4to5	// R10 holds the starting address of the area in memory
	
LOOP:
	CMP R8, #0			// check if power-of-2 counter has reached zero
	BEQ	END				// if so, branch to end
	CMP R8, #8			// check if power-of-2 counter has reached 8, meaning it's on HEX0-HEX4
	BEQ N				// if on threshold, go to 'change values' block (N)
A: 	CMP R0, R8			// check if input value >= power-of-2 counter
	BLT S				// if no, the leftmost bit must be zero => skip to incrementing loop (S)
	
	LDR R7, =CLEARING	// get starting address of clearing word
	MOV R3, #4			// multiple for use on next line
	MUL R3, R9, R3		// multiply offset by four
	LDR R7, [R7, R3]	// get some zeros ready in the correct byte according to the current shift
	LDR R5, [R10]		// load the current value in memory into a register
	AND R5, R5, R7		// clear the required bits
	ORR R5, R5, R2		// enter the required bits			// TODO NEEDS TO BE OR
	STR R5, [R10]		// store back to memory

S:  LSR R8, #1			// decrease power-of-2 counter by one power of 2
	SUB R9, R9, #1		// decrease memory offset counter by one
	ROR R2, #8			// shift input value one byte right (alignment according to offset counter)
	AND R0, R6			// remove leftmost zero
	LSR R6, #1			// remove leftmost 1 from removal string
	B LOOP


END:	POP {LR}
		POP {R0}
		BX LR			// leave

N:	LDR R10, =HEX_0to3	// change to other memory location
	MOV R9, #3			// update memory offset counter
	ROR R2, #8			// shift input value one byte right (alignment according to offset counter)
	B A					// go back

CLEARING:	.word 0xFFFFFF00
			.word 0xFFFF00FF
			.word 0xFF00FFFF
			.word 0x00FFFFFF
ZEROS:		.word 0x00000000
ONES:		.word 0x000000FF
LIGHTS:		.word 0x0000003F, 0x00000006, 0x0000005B, 0x0000004F
				// 00111111	00000110 01011011 01001111
				//	   0        1        2        3
			.word 0x00000066, 0x0000006D, 0x0000007D, 0x000000007
				// 01100110	01101101 01111101 00000111
				//	   4	    5        6        7
			.word 0x0000007F, 0x00000067, 0x00000077, 0x0000007C
				// 01111111	01100111 01110111 01111100
				//	   8	    9        A        b
			.word 0x00000039, 0x0000005E, 0x00000079, 0x00000071
				// 00111001	01011110 01111001 01110001
				//	   C	    d        E        F
	.end
