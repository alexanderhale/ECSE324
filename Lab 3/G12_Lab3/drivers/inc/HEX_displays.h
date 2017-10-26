#ifndef __HEX_DISPLAYS
#define __HEX_DISPLAYS

	typedef enum {
		HEX0 = 0x00000001,	// 000001
		HEX1 = 0x00000002,  // 000010
		HEX2 = 0x00000004,	// 000100
		HEX3 = 0x00000008,	// 001000
		HEX4 = 0x00000010,	// 010000
		HEX5 = 0x00000020   // 100000		// 111111
	} HEX_t;

	extern void HEX_clear_ASM(HEX_t hex);
	extern void HEX_flood_ASM(HEX_t hex);
	extern void HEX_write_ASM(HEX_t hex, char val);

#endif