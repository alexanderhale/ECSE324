extern int MAX_2(int x, int y);		// assembly reference

int main() {
	int a[11]={1,20,3,4,5,25,43,23,53,128,92};		// array
	int c, n, i, b;									// working variables
														// remove b
	c = a[0];										// get first array value
	n = sizeof(a) / sizeof(int);					// length of array
	for (i = 1; i < n; i++){						// count from element 1 to end of array
		b = MAX_2(a[i-1], a[i]);					// check whether current element is greater than current max
														// should be c = MAX_2(c, a[i]);
		//if (b > c){									
		//	c = b;
		//}
	}
	return c;
}