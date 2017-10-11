#include<stdio.h>


int main() {
	int a[5] = {1,20,3,4,5};
	int max_val;
	int i;
	max_val=a[0];
	for (i=1; i<5; i++){
		if (max_val<a[i]){
			max_val=a[i];
		}
	}
	return max_val;
}


