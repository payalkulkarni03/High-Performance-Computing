#include<stdio.h>
#include<math.h>
//	#include<omp.h>
#define SIZE 1024
__global__ void min(int * A, int * C)
{
	int i=blockIdx.x*blockDim.x+threadIdx.x;
	A[2*i]<A[2*i+1]?C[i]=A[2*i]:C[i]=A[2*i+1];
			
}
int main()
{
	int A[SIZE];
	int *devA,*devC;
	//double start,end;
	for(int j=0;j<SIZE;j++)
	{
		A[j]=SIZE-j;
	}
	cudaMalloc((void **)&devA,SIZE*sizeof(int));
	cudaMalloc((void **)&devC,SIZE*sizeof(int));
	//start=omp_get_wtime();
	//printf("\nStart time:%f",start);
	for(int j=1;j<log2((double)SIZE);j++)
	{
		cudaMemcpy(devA,A,SIZE*sizeof(int),cudaMemcpyHostToDevice);
		min<<<1,SIZE/pow(2,j)>>>(devA,devC);
		cudaMemcpy(&A,devC,SIZE*sizeof(int),cudaMemcpyDeviceToHost);
	}
	//end=omp_get_wtime();
	//printf("\nEnd time:%f",end);
	//printf("\nTotal time:%f\n",end-start);
	A[0]<A[1]?printf("\nMin is:%d\n",A[0]):printf("\nMin is:%d\n",A[1]);
	cudaFree(devA);
	cudaFree(devC);
	return 0;
}
