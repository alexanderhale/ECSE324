	.text
	.equ SW_BASE, 0xFF200040
	.equ LED_BASE, 0xFF200000
	.global read_LEDs_ASM
	.global write_LEDs_ASM

read_LEDs_ASM:
	PUSH {R1}
	PUSH {LR}
	LDR R1, =SW_BASE	// load the memory address from which we'll get the value
	LDR R0, [R1]		// get the value and put it into R0
	POP {LR}
	POP {R1}
	BX LR				// leave

write_LEDs_ASM:
	PUSH {R1}
	PUSH {LR}
	LDR R1, =LED_BASE	// load the memory address where we'll put the value
	STR R0, [R1]		// store value of R0 to memory address in R1
	POP {LR}
	POP {R1}
	BX LR

	.end
