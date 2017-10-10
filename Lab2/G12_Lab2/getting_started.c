// Calculates for change in array size, don’t know if that’s needed or not
#include<stdio.h>

int main() {
	int a[11] = {1,20,3,4,5,25,32,128,30,4,2};
	int max_val;
	int i;
	max_val=a[0];
	int n= sizeof(a)/sizeof(int);
	for (i=1; i<n; i++){
		if (max_val<a[i]){
			max_val=a[i];
			}
			}
	return max_val;
}