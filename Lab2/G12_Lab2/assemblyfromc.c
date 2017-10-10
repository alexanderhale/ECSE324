extern int MAX_2(int x, int y);

int main() {

	int a[11]={1,20,3,4,5,25,43,23,53,128,92};
	int c, n, i,b;
	c=a[0];
	n=sizeof(a)/sizeof(int);
	for (i=1; i<n; i++){
		b=MAX_2(a[i-1],a[i]);
		if (b>c){
			c=b;
		}
	}
	return c;
}