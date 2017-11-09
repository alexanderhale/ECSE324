#include <stdio.h>

#include "./drivers/inc/VGA.h"


void test_char();
int main() {
	
	//if (pb_t && 1){
	//	test_char();
	//}
	//else if (pb && 2){
	//	test_byte();
	//}
	//else if (pb && 4){
	//	test_pixel();
	//}*/
	test_char();

}
void test_char() {
	int x,y;
	char c = 0;

	for (y=0; y<=59; y++){
		for (x=0; x<=79; x++){
			VGA_write_char_ASM(x,y,c++);
	}
}
}


void test_byte(){
	int x,y;
	char c=0;

	for (y=0; y<=59; y++)
		for (x=0; x<=79; x+=3)
			VGA_write_byte_ASM(x,y,c++);
	}

void test_pixel(){
	int x,y;
	unsigned short colour=0;

	for(y=0; y<=239; y++)
		for(x=0; x<=319; x++)
			VGA_draw_point_ASM(x,y,colour++);
	}
