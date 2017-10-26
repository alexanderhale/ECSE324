  	.text
	.equ HEX_0to3, 0xFF200020
	.equ HEX_4to5, 0xFF200030
	// .global HEX_clear_ASM
	// .global HEX_flood_ASM
	// .global HEX_write_ASM
	.global _start

_start:
	MOV R0, #63
	B HEX_flood_ASM

CLEAR:	MOV R0, #63

HEX_clear_ASM:						// turn off all the segments of all the HEX displays passed in
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

/*------------------------------------------------------------------------------------*/

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

HEX_write_ASM:			// display the corresponding hexadecimal digit
	PUSH {LR}
						// check which displays are to be altered

						// get the number that will be displayed on those displays

						// decide the segments that need to be illuminated

						// loop through those displays, turning on the appropriate
						// segments on each of the specified displays

	POP {LR}
WRITEEND: BX LR			// leave

	.end
