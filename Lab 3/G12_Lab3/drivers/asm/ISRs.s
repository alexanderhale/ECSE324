	.text
	
	.global A9_PRIV_TIM_ISR
	.global HPS_GPIO1_ISR
	.global HPS_TIM0_ISR
	.global HPS_TIM1_ISR
	.global HPS_TIM2_ISR
	.global HPS_TIM3_ISR
	.global FPGA_INTERVAL_TIM_ISR
	.global FPGA_PB_KEYS_ISR
	.global FPGA_Audio_ISR
	.global FPGA_PS2_ISR
	.global FPGA_JTAG_ISR
	.global FPGA_IrDA_ISR
	.global FPGA_JP1_ISR
	.global FPGA_JP2_ISR
	.global FPGA_PS2_DUAL_ISR

	.global hps_tim0_int_flag
	.global hps_tim1_int_flag
	.global hps_tim2_int_flag
	.global hps_tim3_int_flag
	.global pb_int_flag

hps_tim0_int_flag:
	.word 0x0

hps_tim1_int_flag:
	.word 0x0

hps_tim2_int_flag:
	.word 0x0

hps_tim3_int_flag:
.word 0x0

pb_int_flag:
	.word 0x0

A9_PRIV_TIM_ISR:
	BX LR
	
HPS_GPIO1_ISR:
	BX LR
	
HPS_TIM0_ISR:
	PUSH {R14}							// push LR to stack
	
	MOV R0, #0x1						// move 0000....00001 to R0 choose Timer 0
	BL HPS_TIM_clear_INT_ASM			// clear timer 0 to get it ready

	LDR R0, =hps_tim0_int_flag			// load address set aside for timer flag
	MOV R1, #1							// load a 1 into R1
	STR R1, [R0]						// store 1 into the flag address => sets flag to 1

	POP {R14}							// pop LR from stack
	BX LR
	
HPS_TIM1_ISR:
	PUSH {R14}							// push LR to stack
	
	MOV R0, #0x2						// move 0000....00010 to R0 choose Timer 1
	BL HPS_TIM_clear_INT_ASM			// clear timer 1 to get it ready

	LDR R0, =hps_tim1_int_flag			// load address set aside for timer flag
	MOV R1, #1							// load a 1 into R1
	STR R1, [R0]						// store 1 into the flag address => sets flag to 1

	POP {R14}							// pop LR from stack
	BX LR
	
HPS_TIM2_ISR:
	PUSH {R14}							// push LR to stack
	
	MOV R0, #0x4						// move 0000....00100 to R0 choose Timer 2
	BL HPS_TIM_clear_INT_ASM			// clear timer 2 to get it ready

	LDR R0, =hps_tim2_int_flag			// load address set aside for timer flag
	MOV R1, #1							// load a 1 into R1
	STR R1, [R0]						// store 1 into the flag address => sets flag to 1

	POP {R14}							// pop LR from stack
	BX LR
	
HPS_TIM3_ISR:
	PUSH {R14}							// push LR to stack
	
	MOV R0, #0x8						// move 0000....01000 to R0 choose Timer 3
	BL HPS_TIM_clear_INT_ASM			// clear timer 3 to get it ready

	LDR R0, =hps_tim3_int_flag			// load address set aside for timer flag
	MOV R1, #1							// load a 1 into R1
	STR R1, [R0]						// store 1 into the flag address => sets flag to 1

	POP {R14}							// pop LR from stack
	BX LR
	
FPGA_INTERVAL_TIM_ISR:
	BX LR
	
FPGA_PB_KEYS_ISR:
	PUSH {R14}						// push LR to stack

	BL read_PB_edgecap_ASM			// get pushbutton that was pressed

	LDR R1, =pb_int_flag			// load address set aside for pushbutton flag
	STR R0, [R1]					// set the flag to the same value as the pushbutton that was pressed

	BL PB_clear_edgecap_ASM			// clear edgecap to reset interrupt. Pushbutton required is still stored in R0

	POP {R14}						// pop LR from stack
	BX LR
	
FPGA_Audio_ISR:
	BX LR
	
FPGA_PS2_ISR:
	BX LR
	
FPGA_JTAG_ISR:
	BX LR
	
FPGA_IrDA_ISR:
	BX LR
	
FPGA_JP1_ISR:
	BX LR
	
FPGA_JP2_ISR:
	BX LR
	
FPGA_PS2_DUAL_ISR:
	BX LR
	
	.end
