		.text
		.equ PUSH_data, 0xFF20050
		.equ PUSH_mask, 0xFF20058
		.equ PUSH_edge, 0xFF2005C
		.global read_PB_data_ASM
		.global PB_data_is_pressed_ASM
		.global read_PB_edgecap_ASM
		.global PB_edgecap_is_pressed_ASM
		.global PB_clear_edgecap_ASM
		.global enable_PB_INT_ASM
		.global disable_PB_INT_ASM

read_PB_data_ASM:
	PUSH {LR}
	LDR R0, =PUSH_data	// load the memory address from which we'll get the value
	LDR R0, [R0]		// get the value and put it into R0
	POP {LR}
	BX LR 				// leave

PB_data_is_pressed_ASM:
	PUSH {R1}
	PUSH {LR}
	LDR R1, =PUSH_data	// load the memory address where we'll put the value
	STR R0, [R1]		// store value of R0 to memory address in R1
	POP {LR}
	POP {R1}
	BX LR 				// leave

read_PB_edgecap_ASM:
	PUSH {LR}
	LDR R0, =PUSH_edge	// load the memory address from which we'll get the value
	LDR R0, [R0]		// get the value and put it into R0
	POP {LR}
	BX LR 				// leave

PB_edgecap_is_pressed_ASM:
	PUSH {R1}
	PUSH {LR}
	LDR R1, =PUSH_edge	// load the memory address where we'll put the value
	STR R0, [R1]		// store value of R0 to memory address in R1
	POP {LR}
	POP {R1}
	BX LR 				// leave

PB_clear_edgecap_ASM:
enable_PB_INT_ASM:
disable_PB_INT_ASM: