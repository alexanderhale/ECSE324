#ifndef __HPS_TIM
#define __HPS_TIM

typedef enum {
	TIM0 = 0x00000001,
	TIM1 = 0x00000002,
	TIM2 = 0x00000004,
	TIM3 = 0x00000008
} HPS_TIM_t;

typedef struct {
	HPS_TIM_t tim;		// the enum declared above													// accessible at address in R0
	int timeout; 		// in microseconds															// accessible at address in R0 + 0x4
	int LD_en;			// load enable bit (M) - tells timer to restart at the value we loaded		// accessible at address in R0 + 0x8
	int INT_en;			// interrupt enable bit (I)											 		// accessible at address in R0 + 0xC
	int enable;			// enable bit																// accessible at address in R0 + 0x10
} HPS_TIM_config_t;

/* the argument is a struct pointer */
extern void HPS_TIM_config_ASM(HPS_TIM_config_t *param);

/* Reads the value of the s-bit (offset = 16). The nature
of the return value will depend on whether this function 
is able to read the s-bit value of multiple timers in the
same call (not required) */
extern int HPS_TIM_read_INT_ASM(HPS_TIM_t tim);

/* resets the s-bit and the f-bit. This function should
support multiple timers in the argument. */
extern void HPS_TIM_clear_INT_ASM(HPS_TIM_t tim);

#endif
