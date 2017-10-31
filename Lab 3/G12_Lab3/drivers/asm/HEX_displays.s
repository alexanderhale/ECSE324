  	.text
	.equ HEX_0to3, 0xFF200020
	.equ HEX_4to5, 0xFF200030
	.global HEX_clear_ASM
	.global HEX_flood_ASM
	.global HEX_write_ASM

HEX_clear_ASM:			// turn off everything in the requested hex displays
	LDRB R2, ZEROS		// load 00000000 into R2
	B RUN

HEX_flood_ASM:			// light up everything in the requested hex displays
	LDRB R2, ONES		// load 11111111 into R1
	B RUN

HEX_write_ASM:			// display the corresponding hexadecimal digit in the requested hex displays
	LDR R2, =LIGHTS		// hold address of first encoded light sequence
	LDRB R2, [R2, R1]	// put appropriate 1 byte encoded light sequence into R2, using base address + shift according to input
	B RUN

RUN:
	PUSH {LR}
	MOV R8, #32			// R8 holds the current power of 2 that is being used for comparison
	MOV R9, #1			// R9 holds the memory offset counter
	LDR R10, =HEX_4to5	// R10 holds the starting address of the area in memory
	
LOOP:
	CMP R8, #0			// check if power-of-2 counter has reached zero
	BEQ	END				// if so, branch to end
	CMP R8, #8			// check if power-of-2 counter has reached 8, meaning it's on HEX0-HEX4
	BEQ N				// if on threshold, go to 'change values' block
A: 	CMP R0, R8			// check if input value >= power-of-2 counter
	BLT S				// if no, the leftmost bit must be zero => skip a line
	STRB R2, [R10, R9]	// if yes, leftmost bit is 1 => store the predetermined byte into the base memory location + the offset
S:  LSR R8, #1			// decrease power-of-2 counter by one power of 2
	SUB R9, R9, #1		// decrease memory offset counter by four
	B LOOP


END:	B END
		POP {LR}
		BX LR			// leave

N:	LDR R10, =HEX_0to3	// change to other memory location
	MOV R9, #3			// update memory offset counter
	B A					// go back

ZEROS:		.byte 0
ONES:		.byte 127
LIGHTS:		.byte 31, 6, 91, 79
				// 00011111	00000110 01011011 01001111
				//	   0        1        2        3
			.byte 102, 109, 125, 7
				// 01100110	01101101 01111101 00000111
				//	   4	    5        6        7
			.byte 63, 103, 119, 124
				// 00111111	01100111 01110111 01111100
				//	   8	    9        A        b
			.byte 60, 6, 124, 120
				// 00111100	00000110 01111100 01111000
				//	   C	    d        E        F
	.end