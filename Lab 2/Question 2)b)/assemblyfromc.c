extern int MAX_2(int x, int y);		// assembly reference

int main() {
	int a[11]={1,20,3,4,5,25,43,23,53,128,92};		// array
	int c, n, i;									// working variables
	c = a[0];										// get first array value
	n = sizeof(a) / sizeof(int);					// length of array

	for (i = 1; i < n; i++){						// count from element 1 to end of array
		c = MAX_2(c, a[i]);							// check whether current element is greater than current max
	}
	return c;
}
