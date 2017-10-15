#include<stdio.h>


int main() {
	int a[5] = {1,20,3,4,5};	// array
	int max_val = a[0];			// take first value of array
	int i;						// counter

	for (i = 1; i < 5; i++){	// iterate from element 1 to 4
		if (max_val < a[i]){	// if this value is greater than our current max 
			max_val = a[i];		// replace the max
		}
	}

	return max_val;				// return the max
}