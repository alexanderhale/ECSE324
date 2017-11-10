	.text
	.equ PIXEL_buffer, 0xC8000000
	.equ CHARACTER_buffer, 0xC9000000
	.global VGA_clear_charbuff_ASM
	.global VGA_clear_pixelbuff_ASM
	.global VGA_write_char_ASM
	.global VGA_write_byte_ASM
	.global VGA_draw_point_ASM

// set all valid memory locations in character buffer to 0
	// inputs: none
VGA_clear_charbuff_ASM:
	
	PUSH {R0-R8,LR}				// store registers in use for recovery later
	MOV R0, #59 				// start x counter at 59
	MOV R1, #79					// start y counter at 79
	MOV R8, R1					// copy of y counter for inner loop reset
	LDR R2, =CHARACTER_buffer	// base address
	LDRB R3, ZEROS					// TODO: check if this should be a byte

CHAR_LOOP_O:
	CMP R0, #0
	BLT CHAR_END_CLEAR 	// Outer loop counter, looks at x address
	MOV R1, R8			// Reset inner loop

CHAR_LOOP_I:
	CMP R1, #0			// Inner loop, looks at y address
	SUBLT R0, R0, #1	// Decrement outer loop
	BLT CHAR_LOOP_O		// back to outer loop

	MOV R4, R1			// take y counter
	ROR R4, #25			// rotate y counter into correct position
	ORR R4, R2			// get base address in there
	ORR R4, R0 			// add in the x counter

	STRB R3, [R4] 		// store 0s into the location we determined		// TODO check if storing a byte resolved the problem
	SUB R1, R1, #1 		// decrement y counter
	B CHAR_LOOP_I

CHAR_END_CLEAR: 
	POP {R0-R8,LR}			// restore used registers
	BX LR 					// leave
	
// set all valid memory locations in pixel buffer to 0
	// inputs: none
VGA_clear_pixelbuff_ASM:

	PUSH {R0-R8,LR}
	MOV R0, #300 			// start x counter at 319
	ADD R0, R0, #19				// immediate value structure can't handle 319, use addition instead
	MOV R1, #239			// start y counter at 239
	MOV R8, R1				// copy of y counter for inner loop reset
	LDR R2, =PIXEL_buffer	// base address
	LDRB R3, ZEROS				// TODO: check if this should be a byte

LOOP_OUTER:
		CMP R0, #0
		BLT END_CLEAR 		// Outer loop counter, looks at x address
		MOV R1, R8			// Reset inner loop

LOOP_INNER:
		CMP R1, #0			// Inner loop, looks at y address
		SUBLT R0, R0, #1		// Decrement outer loop
		BLT LOOP_OUTER		// back to outer loop

		MOV R4, R1			// take y counter
		ROR R4, #22			// rotate y counter into correct position
		ORR R4, R2			// get base address in there		// TODO: check if this syntax works properly
		MOV R6, R0 			// make a copy of the x counter
		LSL R6, #1			// shift one digit left
		ORR R4, R6 			// add in the x counter

		STR R3, [R4] 		// store 0s into the location we determined
		SUB R1, R1, #1 		// decrement y counter
		B LOOP_INNER

END_CLEAR: 
	POP {R0-R8,LR}			// restore used registers
	BX LR 					// leave


// write ASCII code passed in 3rd input
	// store value of 3rd input at address calculated with first 2 inputs
	// check that the supplied coordinates are valid
	// inputs: R0 = x coordinate, R1 = y coordinate, R2 = ASCII code for char
VGA_write_char_ASM:

	PUSH {R0-R5, LR}			// save the registers we're about to use
	LDR R5, =CHARACTER_buffer	// base address

	CMP R0, #79				// check that x is within the allowed range
	BGT END_WRITE_CHAR
	CMP R0, #0
	BLT END_WRITE_CHAR
	CMP R1, #59				// check that y is within the allowed range
	BGT END_WRITE_CHAR
	CMP R1, #0
	BLT END_WRITE_CHAR

	MOV R4, R1			// take y value
	ROR R4, #25			// rotate y value into correct position
	ORR R4, R5			// get base address in there
	ORR R4, R0 			// add in the x value
	STRB R2, [R4]		// store the input value to the address			// TODO: check that STRB is ok

END_WRITE_CHAR:
	POP {R0-R5, LR}		// recover saved registers
	BX LR	 			// leave


// write hexadecimal representation of value passed in 3rd input
	// this means that two characters are printed, starting at coordinates
	// passed in through first 2 arguments
	// inputs: R0 = x coordinate, R1 = y coordinate, R2 = byte to be written
VGA_write_byte_ASM:

	PUSH {R0-R5, LR}
	LDR R5, =CHARACTER_buffer

	CMP R0, #79			// check that x is within the allowed range
	BGT END_WRITE_BYTE
	CMP R0, #0
	BLT END_WRITE_BYTE
	CMP R1, #59			// check that y is within the allowed range
	BGT END_WRITE_BYTE
	CMP R1, #0
	BLT END_WRITE_BYTE

	// store first four bits in memory location indicated by input
	MOV R3, R2		// copy input into another register
	LSR R3, #4		// remove rightmost bits from input
	MOV R4, R1		// take y value
	ROR R4, #25		// rotate y value into correct position
	ORR R4, R5		// get base address in there
	ORR R4, R0 		// add in the x counter
	STRB R2, [R4]	// store the input value to the address			// TODO: check that STRB is ok

	ADD R0, R0, #1	// increment x address by 1 to go to next grid spot
	CMP R0, #79		// check if the x counter has reached the right side of the screen
	MOVGT R0, #0	// if yes, send x back to 0 (left side)
	ADDGT R1, #1	// if yes, increment y by 1
	CMP R1, #59		// check if the y counter has reached the bottom of the screen
	MOVGT R1, #0		// if yes, send y back to 0 (top)

	// store second four bits in memory location indicated by x and y
	MOV R3, #0xF	// get 1s in the last 4 bits
	AND R1, R3		// keep last four bits of input
	MOV R4, R1		// take y value
	ROR R4, #25		// rotate y value into correct position
	ORR R4, R5		// get base address in there
	ORR R4, R0 		// add in the x value
	STRB R2, [R4]	// store the input value to the address			// TODO: check that STRB is ok
	

END_WRITE_BYTE:
	POP {R0-R5, LR}	// recover saved registers
	BX LR			// leave
	

// draw a point on the screen with the indicated colour, accessing
// only pixel buffer memory
	// similar to VGA_write_char_ASM
	// inputs: R0 = x coordinate, R1 = y coordinate, R2 = colour
VGA_draw_point_ASM:

	PUSH {R0-R6, LR}
	LDR R5, =PIXEL_buffer

	MOV R3, #300 			// use R3 as comparison register
	ADD R3, R3, #19				// immediate value structure can't handle 319, use addition instead
	CMP R0, R3				// check that x is within the allowed range
	BGT END_DRAW_POINT
	CMP R0, #0 
	BLT END_DRAW_POINT
	CMP R1, #239			// check that y is within the allowed range
	BGT END_DRAW_POINT
	CMP R1, #0
	BLT END_DRAW_POINT

	MOV R4, R1			// take y value
	ROR R4, #22			// rotate y value into correct position
	ORR R4, R5			// get base address in there
	MOV R6, R0 			// make a copy of the x counter
	LSL R6, #1			// shift one digit left
	ORR R4, R6 			// add in the x counter
	STRB R2, [R4]		// store the input value to the address		// TODO: check that STRB is ok

END_DRAW_POINT:
	POP {R0-R6, LR}		// recover saved registers
	BX LR				// leave

ZEROS:	.word 0x0
	.end
