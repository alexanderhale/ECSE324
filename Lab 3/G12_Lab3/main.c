#include <stdio.h>

#include "./drivers/inc/LEDs.h"
#include "./drivers/inc/slider_switches.h"
#include "./drivers/inc/HEX_displays.h"

int main() {
	while(1) {
		// write_LEDs_ASM(read_slider_switches_ASM());
		HEX_flood_ASM(HEX0);
	}
	return 0;
}
