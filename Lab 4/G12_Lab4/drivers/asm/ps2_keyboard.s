	.text
	.equ PS2_data, 0xFF200100
	.equ PS2_Control, 0xFF200104
	.global read_PS2_data_ASM

read_PS2_data_ASM:
	PUSH {R1-R5, LR}		// store registers that we're using
	LDR R1, =PS2_data
	LDR R1, [R1]
	AND R1, 0x8000			// clear all bits except the RVALID bit

	CMP R1, #1			
	MOVLT R0, #0		// if RVALID = 0, leave and return 0
	BLT END

	LDR R1, =PS2_data
	LDR R1, [R1]
	AND R1, 0xFF 		// clear all bits except data bits
	STR R1, [R0]		// store data to input char
	MOV R0, #1			// return 1 to indicate valid data

END:
	POP {R1-R5, LR}		// recover stored registers
	BX LR 				// leave