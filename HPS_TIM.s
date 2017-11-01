		.text
		.equ Tim_0, 0xFFF00000
		.equ Tim_1, 0xFFF01000
		.equ Tim_2, 0xFFF02000
		.equ Tim_3, 0xFFF03000
		.global HPS_TIM_config_ASM
		.global HPS_TIM_read_ASM
		.global HPS_TIM_clear_INT_ASM

HPS_TIM_config_ASM:			
	
	PUSH {R1-R8} 
	LDR R1, [R0] //stores new mem pointer, needed in asr shifts
	AND R1, R1, #0xF //clears future space
	MOV R2, #0 //sets counter

HPS_TIM_config_LOOP:

	CMP R2, #3 //compares counter to 3, branches out if greater
	BGT DONE //ends loop
	AND R3, R1, #1 //compares bits, stores end result in r3
	CMP R3, #0
	ADDEQ R2, R2, #1 //increments counter by 1
	ASR R1, R1, #1 //shifts r1 by 1 bit
	BEQ HPS_TIM_config_LOOP
	

	CMP R2, #0				//Comparison section, finds what timer position in memory to use
	LDREQ R4 =Tim_0			
	CMP R2, #1
	LDREQ R4 =Tim_1
	CMP R2, #2
	LDREQ R4 =Tim_2
	CMP R3, #3
	LDREG R4 =Tim_3

	LDR R5, [R0, 0x4] //loads timeout into R5
	LDR R6, [R0, 0x8] //loads LD_en into R6
	LDR R7, [R0, 0xC] // loads Int_en into R7
	LDR R8, [R0, 0x10]// loads enable into R8


	STR R5, [R4] //Stores timeout into rightmost bit in timer memory
	ASR R6, R6, #1 // Shifts LD_en right one bit
	ASR R7, R7, #2 // Shifts Int_in right into third bit
	ORR R9, R6, R7 
	ORR R9, R9, R8	//Centralizes information into a word
