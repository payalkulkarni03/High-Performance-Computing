#include<stdio.h>
#include<math.h>
#include<omp.h>
#define SIZE 1024
__global__ void sort(int * A, int j)
{
        int temp=0;
        int i=blockIdx.x*blockDim.x+threadIdx.x;
        if(j%2==0)
        {
                if(A[2*i]>A[2*i+1])
                {
                        temp=A[2*i];
                        A[2*i]=A[2*i+1];
                        A[2*i+1]=temp;
                }
        }
        else
        {
                if(A[2*i+1]>A[2*i+2])
                {
                        temp=A[2*i+1];
                        A[2*i+1]=A[2*i+2];
                        A[2*i+2]=temp;
                }
        }

}
int main()
{
        int A[SIZE];
        int *devA;
       // double start,end;
        for(int j=0;j<SIZE;j++) //initialize array
        {
                A[j]=SIZE-j;
        }
 
        cudaMalloc((void **)&devA,SIZE*sizeof(int)); //allocate memory to gpu devices
        
        //calculate start time 
       // start=omp_get_wtime();
        //printf("\nStart time:%f",start);

	cudaMemcpy(devA,A,SIZE*sizeof(int),cudaMemcpyHostToDevice);
        for(int j=0;j<(SIZE);j++)
        {

                if(j%2==0)
                {
                        sort<<<1,SIZE/2>>>(devA,j);
                }
                else
                        sort<<<1,((SIZE/2)-1)>>>(devA,j);

        }
        cudaMemcpy(&A,devA,SIZE*sizeof(int),cudaMemcpyDeviceToHost);
     
        //calculate end time
	//end=omp_get_wtime();
        //printf("\nEnd time:%f",end);
        //printf("\nTotal time:%f\n",end-start);

        printf("Sorted array is:\n");
        for(int i=0;i<SIZE;i++)
        {
                printf("\t%d",A[i]);
        }
        cudaFree(devA);

        return 0;
}


