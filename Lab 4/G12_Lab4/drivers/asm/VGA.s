.text
	.equ HEX_0to3, 0xFF200020
	.equ HEX_4to5, 0xFF200030
	.global VGA_clear_charbuff_ASM
	.global VGA_clear_pixelbuff_ASM
	.global VGA_write_char_ASM
	.global VGA_write_byte_ASM
	.global VGA_draw_point_ASM

// set all valid memory locations in character buffer to 0
	// inputs: R0 = 
VGA_clear_charbuff_ASM:

// set all valid memory locations in pixel buffer to 0
VGA_clear_pixelbuff_ASM:

// write ASCII code passed in 3rd input
	// store value of 3rd input at address calculated with first 2 inputs
	// check that the supplied coordinates are valid
VGA_write_char_ASM:

// write hexadecimal representation of value passed in 3rd input
	// this means that two characters are printed, starting at coordinates
	// passed in through first 2 arguments
VGA_write_byte_ASM:

// the previous two subroutines only access the character buffer memory

// draw a point on the screen with the indicated colour, accessing
// only pixel buffer memory
	// similar to VGA_write_char_ASM
VGA_draw_point_ASM:

// hint: use suffixes B and H to read/modify bytes or half-words