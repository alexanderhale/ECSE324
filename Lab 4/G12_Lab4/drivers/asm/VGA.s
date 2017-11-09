	.text
	.equ PIXEL_buffer, 0xC8000000
	.equ CHARACTER_buffer, 0xC9000000
	.global VGA_clear_charbuff_ASM
	.global VGA_clear_pixelbuff_ASM
	.global VGA_write_char_ASM
	.global VGA_write_byte_ASM
	.global VGA_draw_point_ASM

// set all valid memory locations in character buffer to 0
	// inputs: R0 = 
VGA_clear_charbuff_ASM:
	
	PUSH {R0-R8,LR}
	MOV R0, #59 //X address
	MOV R1, #79	//Y address
	LDR R2, =CHARACTER_buffer
	LDR R3, ZEROS
	MOV R4, #128 //Y address multiplier
	B LOOP_OUTER
	
// set all valid memory locations in pixel buffer to 0
VGA_clear_pixelbuff_ASM:

	PUSH {R0-R8,LR}
	MOV R0, #200 //figuring out how to get the #319 there, currently too big
	MOV R1, #79
	MOV R8, R1
	LDR R2, =PIXEL_buffer
	LDR R3, ZEROS
	MOV R4, #1024 //Y address buffer
	B LOOP_OUTER

LOOP_OUTER:
		CMP R0, #0
		BLT END_CLEAR 	//Outer loop counter, looks at x address
		MOV R1, R8		//Resets inner loop
		B LOOP_INNER

LOOP_INNER:
		CMP R1, #0		//Inner loop, looks at y address
		SUBLT R0,R0,#1	//Decrements outer loop
		BLT LOOP_OUTER
		B RUN
RUN:
		MLA R5, R1, R4, R0 //offset
		STR R3, [R2,R5] //applied offset to base, stores 0's into that location in memory
		SUB R1, R1, #1 //loop counter decrements
		B LOOP_INNER

END_CLEAR: 
	POP {R0-R8,LR}
	BX LR


// write ASCII code passed in 3rd input
	// store value of 3rd input at address calculated with first 2 inputs
	// check that the supplied coordinates are valid
VGA_write_char_ASM: //Should be good

	PUSH {R0-R5, LR}
	LDR R5,= CHARACTER_buffer
	//CMP R0, #79
	//BGT END_WRITE_CHAR
	//CMP R0, #0
	//BLT END_WRITE_CHAR
	//CMP R1, #59
	//BGT END_WRITE_CHAR
	//CMP R1, #0
	//BLT END_WRITE_CHAR
	MOV R3, #128  
	MLA R4, R1, R3, R0 //Address offset
	STR R2, [R5,R4]	
	B END_WRITE_CHAR

END_WRITE_CHAR:
	POP {R0-R5, LR}
	BX LR	



// write hexadecimal representation of value passed in 3rd input
	// this means that two characters are printed, starting at coordinates
	// passed in through first 2 arguments
VGA_write_byte_ASM: //think we need to have a char to byte converter, have not done yet

	PUSH {R0-R5, LR}
	LDR R5,= CHARACTER_buffer
	CMP R0, #79
	BGT END_WRITE_CHAR
	CMP R0, #0
	BLT END_WRITE_CHAR
	CMP R1, #59
	BGT END_WRITE_CHAR
	CMP R1, #0
	BLT END_WRITE_CHAR
	MOV R3, #128
	LDR R5, [R5, R0]  
	MLA R4, R1, R3, R5 //Address
	STR R2, [R4]	
	B END_WRITE_BYTE

END_WRITE_BYTE:
	POP {R0-R5, LR}
	BX LR	
	


// draw a point on the screen with the indicated colour, accessing
// only pixel buffer memory
	// similar to VGA_write_char_ASM
VGA_draw_point_ASM: //Should be good

	PUSH {R0-R5, LR}
	LDR R5,= PIXEL_buffer
	CMP R0, #200 //trying to figure out how to get the number 319 there
	BGT END_WRITE_CHAR
	CMP R0, #0 
	BLT END_WRITE_CHAR
	CMP R1, #239
	BGT END_WRITE_CHAR
	CMP R1, #0
	BLT END_WRITE_CHAR
	MOV R3, #1024  
	MLA R4, R1, R3, R0 //Address
	LDR R5, [R5,R4]
	STR R2, [R5]	
	B END_DRAW_POINT

END_DRAW_POINT:
	POP {R0-R5, LR}
	BX LR	



ZEROS:	.word 0x00000000

	.end
