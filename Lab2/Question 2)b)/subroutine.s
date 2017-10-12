	.text
	.global MAX_2

MAX_2:
	CMP R0, R1		// compare two inputs
	BXGE LR			// if R1 < R0, branch back
	MOV R0, R1		// else, replace R0 with R1
	BX LR			// branch back
	.end