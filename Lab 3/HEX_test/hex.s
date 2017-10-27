  	.text
	.equ HEX_0to3, 0xFF200020
	.equ HEX_4to5, 0xFF200030
	// .global HEX_clear_ASM
	// .global HEX_flood_ASM
	// .global HEX_write_ASM
	.global _start

_start:
	MOV R0, #63
	MOV R1, #10
	B HEX_write_ASM

CLEAR:	MOV R0, #63

/*HEX_clear_ASM:						// turn off all the segments of all the HEX displays passed in
					PUSH {LR}
					CMP R0, #16		// if HEX4 and HEX 5 aren't requested, skip the first section
					BLT ZEROTOTHREE

					MOV R2, #32			// R2 holds the current power of 2 that is being used for comparison
					MOV R3, #255		// R3 holds a block of 1s that is 8 bits long, starting at positions 0 to 7
					LSL R3, #8			// move the block of 1s to positions 24 to 31
					LDR R4, =HEX_4to5	// R4 holds the starting address of the area in memory
					LDR R5, [R4]		// load the value stored at that address

CLEARFOURTOFIVE:		CMP R2, #8			// check value of counter
						BEQ	ZEROTOTHREE		// go to end if we've run through all HEX displays
						CMP R0, R2			// check if leftmost bit is 1 or 0 by checking the the value in R0 is <= 2^n. Skip a line if 0.
						BLT CLEARDONE		// if 0, branch to SKIP:
						SUB R5, R5, R3 		// clear all bits in nth hex spot
SKIPFOURTOFIVE:			LSR R2, #1			// decrease power of 2 counter by one power of 2
						LSR R3, #8			// move the block of 1s 8 spots right
						B CLEARFOURTOFIVE  // branch back to start of loop

CLEARDONE:				STR R5, [R4]	// store the finished value back to the memory location

ZEROTOTHREE:			MOV R2, #8			// R2 holds the current power of 2 that is being used for comparison
						MOV R3, #255		// R3 holds a block of 1s that is 8 bits long, starting at positions 0 to 7
						LSL R3, #24			// move the block of 1s to positions 24 to 31
						LDR R4, =HEX_0to3	// R4 holds the starting address of the area in memory
						LDR R5, [R4]		// load the value stored at that address

CLEARZEROTOTHREE:		CMP R2, #0			// check value of counter
						BEQ	CLEAREND		// go to end if we've run through all HEX displays
						CMP R0, R2			// check if leftmost bit is 1 or 0 by checking the the value in R0 is <= 2^n. Skip a line if 0.
						BLT SKIPZEROTOTHREE	// if 0, branch to SKIP:
						SUB R5, R5, R3 		// clear all bits in nth hex spot			// TODO THIS WILL NOT WORK UNLESS BITS ARE ALL 1 BEFORE!
SKIPZEROTOTHREE:		LSR R2, #1			// decrease power of 2 counter by one power of 2
						LSR R3, #8			// move the block of 1s 8 spots right
						B CLEARZEROTOTHREE  // branch back to start of loop


CLEAREND:	STR R5, [R4]	// store the finished value back to the memory location
STOPEND:	B STOPEND

			POP {LR}
 			BX LR			// leave

///////////////////////////////////////////////////////////////////////////

HEX_flood_ASM:			// turn on all the segments of all the HEX displays passed in
					PUSH {LR}
					CMP R0, #16			// if HEX4 and HEX 5 aren't requested, skip the first section
					BLT FLDZEROTOTHREE

					MOV R2, #32			// R2 holds the current power of 2 that is being used for comparison
					MOV R3, #255		// R3 holds a block of 1s that is 8 bits long, starting at positions 0 to 7
					LSL R3, #8			// move the block of 1s to positions 24 to 31
					LDR R4, =HEX_4to5	// R4 holds the starting address of the area in memory
					LDR R5, [R4]		// load the value stored at that address

FLOODFOURTOFIVE:		CMP R2, #8			// check value of counter
						BEQ	FLOODDONE		// go to end if we've run through all HEX displays
						CMP R0, R2			// check if leftmost bit is 1 or 0 by checking the the value in R0 is <= 2^n
						BLT FLDSKIPFOURTOFIVE	// if 0, branch to SKIP:
						ADD R5, R5, R3 		// clear all bits in nth hex spot
FLDSKIPFOURTOFIVE:		LSR R2, #1			// decrease power of 2 counter by one power of 2
						LSR R3, #8			// move the block of 1s 8 spots right
						B FLOODFOURTOFIVE  // branch back to start of loop

FLOODDONE:				STR R5, [R4]	// store the finished value back to the memory location

FLDZEROTOTHREE:			MOV R2, #8			// R2 holds the current power of 2 that is being used for comparison
						MOV R3, #255		// R3 holds a block of 1s that is 8 bits long, starting at positions 0 to 7
						LSL R3, #24			// move the block of 1s to positions 24 to 31
						LDR R4, =HEX_0to3	// R4 holds the starting address of the area in memory
						LDR R5, [R4]		// load the value stored at that address

FLOODZEROTOTHREE:		CMP R2, #0			// check value of counter
						BEQ	FLOODEND		// go to end if we've run through all HEX displays
						CMP R0, R2			// check if leftmost bit is 1 or 0 by checking the the value in R0 is <= 2^n
						BLT FLDSKIPZEROTOTHREE	// if 0, branch to SKIP:
						ADD R5, R5, R3 		// FLOOD all bits in nth hex spot
FLDSKIPZEROTOTHREE:		LSR R2, #1			// decrease power of 2 counter by one power of 2
						LSR R3, #8			// move the block of 1s 8 spots right
						B FLOODZEROTOTHREE  // branch back to start of loop


FLOODEND:	STR R5, [R4]	// store the finished value back to the memory location
			POP {LR}
 			// BX LR			// leave
			B CLEAR

/*------------------------------------------------------------------------------------*/

HEX_clear_ASM:			// turn off everything in the requested hex displays
	LDRB R2, #0			// load 00000000 into R2
	B RUN

HEX_flood_ASM:			// light up everything in the requested hex displays
	LDRB R2, #128		// load 11111111 into R1
	B RUN

HEX_write_ASM:			// display the corresponding hexadecimal digit in the requested hex displays
	LDR R2, =LIGHTS		// hold address of first encoded light sequence
	LDRB R2, [R2, R1]	// put appropriate 1 byte encoded light sequence into R2, using base address + shift according to input
	B RUN

RUN:
	PUSH {LR}
	MOV R8, #32			// R8 holds the current power of 2 that is being used for comparison
	MOV R9, #20			// R9 holds the memory offset counter
	LDR R10, =HEX_0to3	// R10 holds the starting address of the area in memory
	
LOOP:
	CMP R8, #0			// check if power-of-2 counter has reached zero
	BEQ	END				// if so, branch to end
	CMP R0, R8			// check if input value >= power-of-2 counter
	BLT S				// if no, the leftmost bit must be zero => skip a line
	LDRB R10, [R10, R9]	// if yes, leftmost bit is 1 => load the predetermined byte into the base memory location + the offset
S:  LSR R8, #1			// decrease power-of-2 counter by one power of 2
	SUB R9, R9, #4		// decrease memory offset counter by four
	B LOOP


END:	POP {LR}
		BX LR			// leave

// ZEROS:		.word 0
// ONES:		.word 127
LIGHTS:		.word 31, 6, 91, 79
				// 00011111	00000110 01011011 01001111
				//	   0        1        2        3
			.word 102, 109, 125, 7
				// 01100110	01101101 01111101 00000111
				//	   4	    5        6        7
			.word 63, 103, 119, 124
				// 00111111	01100111 01110111 01111100
				//	   8	    9        A        b
			.word 60, 6, 124, 120
				// 00111100	00000110 01111100 01111000
				//	   C	    d        E        F
	.end