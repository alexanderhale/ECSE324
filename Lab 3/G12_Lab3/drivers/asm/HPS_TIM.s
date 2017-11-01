			.text
			.equ TIM_0, 0xFFC08000
			.equ TIM_1, 0xFFC09000
			.equ TIM_2, 0xFFD00000
			.equ TIM_3, 0xFFD01000
			.global HPS_TIM_config_ASM
			.global HPS_TIM_read_INT_ASM
			.global HPS_TIM_clear_INT_ASM

//R0: HPS_TIM_config_t *param
HPS_TIM_config_ASM:
			PUSH {R1-R7}
			LDR R3, [R0]				//Load TIM into R3
			AND R3, R3, #0xF			//Get rid of random numbers ahead of our one-hot string
			MOV R1, #0					//Initialize counter
			
HPS_TIM_config_ASM_LOOP:
			CMP R1, #4					//if counter >= 4
			BGE HPS_TIM_config_ASM_DONE	//done
			AND R5, R3, #1
			CMP R5, #0
			ASR R3, R3, #1				//Shift input by 1
			ADDEQ R1, R1, #1			//Increment counter if 0
			BEQ HPS_TIM_config_ASM_LOOP	//Branch back to loop if 0

			//Load timer into R2 depending on which one it is
			CMP R1, #0
			LDREQ R2, =TIM_0
			CMP R1, #1
			LDREQ R2, =TIM_1
			CMP R1, #2
			LDREQ R2, =TIM_2
			CMP R1, #3
			LDREQ R2, =TIM_3
		
			LDR R4, [R0, #0x8]			//Disable timer before doing config
			AND R4, R4, #0x6			//Disable E bit, keep other the same
			STR	R4, [R2, #0x8] 		
	
			LDR R4, [R0, #0x4]			//Load "timeout"
			STR R4, [R2] 				//Config "Timeout"

			LDR R4, [R0, #0x8]			//Load "LD_en"
			LSL R4, R4, #1				//Shift by one (M bit)

			LDR R5, [R0, #0xC]			//Load "INT_en"
			LSL R5, R5, #2				//Shift twice (I bit)

			LDR R6, [R0, #0x10]			//Load "enable"

			ORR R7, R4, R5
			ORR R7, R7, R6				//Get string of M, I and E bits

			STR R7, [R2, #0x8]			//Store into control

			ADD R1, R1, #1				//Increment counter
			B HPS_TIM_config_ASM_LOOP

HPS_TIM_config_ASM_DONE:
			POP {R1-R7}
			BX LR
			

//R0: HPS_TIM_t tim
HPS_TIM_read_INT_ASM:
			PUSH {R1-R4}
			AND R0, R0, #0xF			//Get rid of random numbers ahead of our one-hot string
			MOV R1, #0					//Initialize counter
			
HPS_TIM_read_ASM_LOOP:
			CMP R1, #4					//if counter >= 4
			BGE HPS_TIM_read_ASM_DONE	//done
			AND R4, R0, #1
			CMP R4, #0
			ASR R0, R0, #1				//Shift input by 1
			ADDEQ R1, R1, #1			//Increment counter if 0
			BEQ HPS_TIM_read_ASM_LOOP	//Branch back to loop if 0

			//Load timer into R2 depending on which one it is
			CMP R1, #0
			LDREQ R2, =TIM_0
			CMP R1, #1
			LDREQ R2, =TIM_1
			CMP R1, #2
			LDREQ R2, =TIM_2
			CMP R1, #3
			LDREQ R2, =TIM_3

			LDR R3, [R2, #0x10]			//Load S-bit
			AND R0, R3, #1
			B HPS_TIM_read_ASM_DONE 	//Only supports single timer, so done

HPS_TIM_read_ASM_DONE:
			POP {R1-R4}
			BX LR

//R0: HPS_TIM_t tim
HPS_TIM_clear_INT_ASM:
			PUSH {R1-R4}
			AND R0, R0, #0xF			//Get rid of random numbers ahead of our one-hot string
			MOV R1, #0					//Initialize counter
			
HPS_TIM_clear_INT_ASM_LOOP:
			CMP R1, #4					//if counter >= 4
			BGE HPS_TIM_clear_INT_ASM_DONE	//done
			AND R4, R0, #1
			CMP R4, #0
			ASR R0, R0, #1				//Shift input by 1
			ADDEQ R1, R1, #1			//Increment counter if 0
			BEQ HPS_TIM_clear_INT_ASM_LOOP	//Branch back to loop if 0

			//Load timer into R2 depending on which one it is
			CMP R1, #0
			LDREQ R2, =TIM_0
			CMP R1, #1
			LDREQ R2, =TIM_1
			CMP R1, #2
			LDREQ R2, =TIM_2
			CMP R1, #3
			LDREQ R2, =TIM_3

			LDR R4, [R2, #0xC]			//Reading F bit clears everything... 

			ADD R1, R1, #1				//Increment counter
			B HPS_TIM_clear_INT_ASM_LOOP

HPS_TIM_clear_INT_ASM_DONE:
			POP {R1-R4}
			BX LR			

			.end