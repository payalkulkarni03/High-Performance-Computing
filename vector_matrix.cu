#include <stdio.h>
#include<cuda.h>
#include <stdlib.h>
#include<time.h>

#define SIZE 45

__global__ void matrixvectmult(int *mat,int *vect,int *res)
{
	int tid=blockIdx.x*blockDim.x;
	int mult=0;
	for(int i=0;i<SIZE;i++)
	{
		mult=mult+(mat[tid+i]*vect[i]);
	}
	res[blockIdx.x]=mult;
}

int main(void)
{
	int i,j;
	srand(time(NULL));
	int a[SIZE][SIZE],b[SIZE],c[SIZE];

	int *dev_a,*dev_b,*dev_c;

	cudaMalloc((void **)&dev_a, SIZE*SIZE*sizeof(int));
	cudaMalloc((void **)&dev_b, SIZE*sizeof(int));
	cudaMalloc((void **)&dev_c, SIZE*sizeof(int));

	for(i=0;i<SIZE;i++)
	{
		for(j=0;j<SIZE;j++)
		{
			a[i][j] = rand()%20+1;
		}
	}

	printf("\nThe matrix is:\n");
	for(i=0;i<SIZE;i++)
	{
		for(j=0;j<SIZE;j++)
		{
			printf("%d\t",a[i][j]);
		}
		printf("\n");
	}

	for(i=0;i<SIZE;i++)
	{
		b[i] = rand()%20+1;
	}

	printf("\nThe vector is:\n");
	for(i=0;i<SIZE;i++)
	{
		printf("%d  ",b[i]);
	}

	cudaMemcpy(dev_a,a,sizeof(a),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b,b,sizeof(b),cudaMemcpyHostToDevice);
	matrixvectmult<<<SIZE,SIZE>>>(dev_a,dev_b,dev_c);
	cudaMemcpy(&c,dev_c,sizeof(c),cudaMemcpyDeviceToHost);

	printf("\nThe result is:\n");
	for(int i=0;i<SIZE;i++)
	{
		printf("%d ",c[i]);
	}


	return 0;
}
