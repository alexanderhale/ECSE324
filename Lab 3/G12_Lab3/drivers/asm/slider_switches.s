	.text
	.equ SW_BASE, 0xFF200040
	.global read_slider_switches_ASM
	
read_slider_switches_ASM:
	LDR R1, =SW_BASE
	LDR R0, [R1]
	BX LR

	.end	
