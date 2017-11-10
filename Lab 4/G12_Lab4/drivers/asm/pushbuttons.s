		.text
		.equ PUSH_data, 0xFF200050
		.equ PUSH_mask, 0xFF200058
		.equ PUSH_edge, 0xFF20005C
		.global read_PB_data_ASM
		.global PB_data_is_pressed_ASM
		.global read_PB_edgecap_ASM
		.global PB_edgecap_is_pressed_ASM
		.global PB_clear_edgecap_ASM
		.global enable_PB_INT_ASM
		.global disable_PB_INT_ASM

read_PB_data_ASM:		// return a binary string, where the final 4 bits hold the status of the buttons (pressed or not)
	PUSH {LR}
	LDR R1, =PUSH_data	// load the memory address from which we'll get the value
	LDR R0, [R1]		// get the value and put it into R0
	POP {LR}
	BX LR 				// leave

PB_data_is_pressed_ASM:	// check if the indicated buttons are pressed. If yes, return 1. Otherwise, return 0.
	PUSH {R1}
	PUSH {LR}
	LDR R1, =PUSH_data	// load the memory address where the value is stored
	LDR R1, [R1]		// get the value and put it into R1
	CMP R0, R1			// check if the input string matches the string in memory
	BEQ	O
	MOV R0, #0			// if no, return false
	B E
O:	MOV R0, #1			// if yes, return true
E:	POP {LR}
	POP {R1}
	BX LR 				// leave

read_PB_edgecap_ASM:	// return a binary string, where the final 4 bits hold the edgecap bits
	PUSH {LR}
	LDR R0, =PUSH_edge	// load the memory address from which we'll get the value
	LDR R0, [R0]		// get the value and put it into R0 for return
	POP {LR}
	BX LR 				// leave

PB_edgecap_is_pressed_ASM:	// check if the indicated buttons are pressed. If yes, return 1. Otherwise, return 0.
	PUSH {R1}
	PUSH {LR}
	LDR R1, =PUSH_edge	// load the memory address where the value is stored
	LDR R1, [R1]		// get the value and put it into R1
	CMP R0, R1			// check if the input string matches the string in memory
	BEQ	Z
	MOV R0, #0			// if no, return false
	B D
Z:	MOV R0, #1			// if yes, return true
D:	POP {LR}
	POP {R1}
	BX LR 				// leave

PB_clear_edgecap_ASM:	// write the input string into the edge capture memory location
						// no alterations required, since the input value is already the appropriate binary string
	PUSH {R1}
	PUSH {LR}
	LDR R1, =PUSH_edge	// load the target memory address	
	STR R0, [R1]		// store the input value (which is in R0) to the memory address in R1
	POP {LR}
	POP {R1}
	BX LR 				// leave

enable_PB_INT_ASM:		// write the input string into the interrupt mask memory location
	PUSH {R1}
	PUSH {LR}
	LDR R1, =PUSH_mask	// load the target memory address
	STR R0, [R1]		// store the input value (which is in R0) to the memory address in R1
	POP {LR}
	POP {R1}
	BX LR 				// leave

disable_PB_INT_ASM:		// write the opposite of the input string into the interrupt mask memory location
	PUSH {R1}
	PUSH {LR}
	LDR R1, =PUSH_mask	// load the target memory address
	MVN R0, R0			// invert the input string
	STR R0, [R1]		// store the input value (which is in R0) to the memory address in R1
	POP {LR}
	POP {R1}
	BX LR 				// leave
