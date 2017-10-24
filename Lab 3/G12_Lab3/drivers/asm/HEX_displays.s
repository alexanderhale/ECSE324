  	.text
	.equ HEX_0to3, 0xFF200020
	.equ HEX_4to5, 0xFF200030
	.global HEX_clear_ASM
	.global HEX_flood_ASM
	.global HEX_write_ASM

HEX_clear_ASM:			// turn off all the segments of all the HEX displays passed in
	PUSH {R1}
	PUSH {LR}
						// check which displays are to be altered

						// loop through those displays, turning off all 7 segments
						// of each of the specified displays


	POP {LR}
	POP {R1}
CLEAREND: BX LR			// leave


HEX_flood_ASM:			// turn on all the segments of all the HEX displays passed in
	PUSH {R1}
	PUSH {LR}
						// check which displays are to be altered
						
						// loop through those displays, turning on all 7 segments
						// of each of the specified displays


	POP {LR}
	POP {R1}
FLOODEND: BX LR			// leave


HEX_write_ASM:			// display the corresponding hexadecimal digit
	PUSH {R1}
	PUSH {LR}
						// check which displays are to be altered

						// get the number that will be displayed on those displays

						// decide the segments that need to be illuminated

						// loop through those displays, turning on the appropriate
						// segments on each of the specified displays

	POP {LR}
	POP {R1}
WRITEEND: BX LR			// leave

	.end