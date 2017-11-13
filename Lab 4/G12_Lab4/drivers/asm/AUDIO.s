	.text
	.equ FIFOSPACE, 0xFF203044
	.equ LEFTDATA, 0xFF203048
	.equ RIGHTDATA, 0xFF20304C			// manual says 3C, which is wrong
	.global audio_port_ASM

audio_port_ASM:
	PUSH {R1-R2, LR}	// store registers that will be used

	// check for space
	LDR R1, =FIFOSPACE	// get address of FIFOSPACE
	LDR R1, [R1]		// get contents of FIFOSPACE
	AND R2, R1, #0xFF000000	// remove everything except WSLC
	ROR R2, #24			// rotate to LSB
	CMP R2, #0			// check if anything remaining in WSLC
	MOVLE R0, #0		// if no, return a 0 and leave
	BLE END
	AND R1, #0x00FF0000	// remove WSLC and, since we're at it, RALC and RARC
	ROR R1, #16
	CMP R1, #0			// check if anything remaining in WSRC
	MOVLE R0, #0		// if no, return a 0 and leave
	BLE END

	// if we're here, we have space! Let's write to the FIFOs 
	LDR R1, =LEFTDATA	// load memory locations
	LDR R2, =RIGHTDATA
	STR R0, [R1]		// store input value to memory
	STR R0, [R2]
	MOV R0, #1			// get a 1 ready for return

END:
	POP {R1-R2, LR}		// restore saved registers
	BX LR				// leave