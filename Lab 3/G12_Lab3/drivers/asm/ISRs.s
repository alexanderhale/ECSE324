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
	.global pb_int_flag

hps_tim0_int_flag:
	.word 0x0

pb_int_flag:
	.word 0x0

A9_PRIV_TIM_ISR:
	BX LR
	
HPS_GPIO1_ISR:
	BX LR
	
HPS_TIM0_ISR:
	PUSH {R14}					//Push LR to stack
	
	MOV R0, #0x1
	BL HPS_TIM_clear_INT_ASM			//Clear tim0

	LDR R0, =hps_tim0_int_flag			//Load spot in memory into R0
	MOV R1, #1					
	STR R1, [R0]					//Set flag in memory to 1 

	POP {R14}					//Pop LR from stack
	BX LR
	
HPS_TIM1_ISR:
	BX LR
	
HPS_TIM2_ISR:
	BX LR
	
HPS_TIM3_ISR:
	BX LR
	
FPGA_INTERVAL_TIM_ISR:
	BX LR
	
FPGA_PB_KEYS_ISR:
	PUSH {R14}					//Push LR to stack

	BL read_PB_edgecap_ASM			//Get pushbutton that was pressed

	LDR R1, =pb_int_flag
	STR R0, [R1]				//Set flag to value of pb

	BL PB_clear_edgecap_ASM			//Clear edgecap to reset interrupt

	POP {R14}					//Pop LR from stack
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
