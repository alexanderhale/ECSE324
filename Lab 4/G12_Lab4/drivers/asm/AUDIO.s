	.text
	.equ FIFOSPACE, 0xFF203044
	.equ LEFTDATA, 0xFF203048
	.equ RIGHTDATA, 0xFF20303C
	.global audio_port_ASM

audio_port_ASM:
	PUSH {R1-R8, LR}	// store registers that will be used

	// check for space
	LDR R1, =FIFOSPACE	// get address of FIFOSPACE
	LDR R1, [R1]		// get contents of FIFOSPACE
	CMP R1, 0x01000000	// check if anything remaining in WSLC
	MOVLT R0, #0		// if no, return a 0 and leave
	BLT END
	AND R1, 0x00FF0000	// remove WSLC and, since we're at it, RALC and RARC
	CMP R1, 0x00010000	// check if anything remaining in WSRC
	MOVLT R0, #0		// if no, return a 0 and leave
	BLT END

	// if we're here, we have space! Let's write to the FIFOs 
	LDR R1, =LEFTDATA	// load memory locations
	LDR R2, =RIGHTDATA
	STR R0, [R1]		// store input value to memory
	STR R0, [R2]
	MOV R0, #1			// get a 1 ready for return

END:
	POP {R1-R8, LR}		// restore saved registers
	BX LR				// leave