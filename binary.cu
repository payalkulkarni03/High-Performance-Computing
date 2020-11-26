#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <cstring>
#include <ctime>
#include <math.h>
#define N 1024*40000
__device__ int binarySearch1(float *, int , int , int );
int binarySearch(float *, int , int , int );



__global__ void binary (float *Array, float *A2,float  key ,int size)   //Kernel Code For Reduction
 {
   	//holds intermediates in shared memory rr
   	int result;

    	int i = blockIdx.x * blockDim.x + threadIdx.x;

      int split=4;

     
     
        if(key>Array[(size/split)*i]&&key<Array[(size/split)*(i+1)])
        {
        A2[0]=(size/split)*i;  //low
        A2[1]=(size/split)*(i+1); //high
        result=binarySearch1(Array,A2[0],A2[1],key);
        A2[2]=result; //high - low
       
        
      
    }

}

__device__ int binarySearch1(float *arr, int l, int r, int x)
{
   if (r >= l)
   {
        int mid = l + (r - l)/2;

        // If the element is present at the middle
        // itself
        if (arr[mid] == x)
            return mid;

        // If element is smaller than mid, then
        // it can only be present in left subarray
        if (arr[mid] > x)
            return binarySearch1(arr, l, mid-1, x);

        // Else the element can only be present
        // in right subarray
        return binarySearch1(arr, mid+1, r, x);
   }

   // We reach here when element is not
   // present in array
   return -1;
}
int binarySearch(float *arr, int l, int r, int x)
{
   if (r >= l)
   {
        int mid = l + (r - l)/2;

        // If the element is present at the middle
        // itself
        if (arr[mid] == x)
            return mid;

        // If element is smaller than mid, then
        // it can only be present in left subarray
        if (arr[mid] > x)
            return binarySearch(arr, l, mid-1, x);

        // Else the element can only be present
        // in right subarray
        return binarySearch(arr, mid+1, r, x);
   }

   // We reach here when element is not
   // present in array
   return -1;
}


int main()
{

	size_t size = N * sizeof(float);
	clock_t start,stop; //to measure time of excecution
  printf("\nName of the Model= Parllel Binary Search\n");
//Thread allocation
  int threadsPerBlock;
  if (N<=1024)
  		threadsPerBlock=1;
  else
		 threadsPerBlock=N/1024;
  int blocksPerGrid =(N + threadsPerBlock - 1) / threadsPerBlock;
  printf("\nblocksPerGrid=%d\n",blocksPerGrid);
// Memory Allocation
  float* device_Array; //input array
  float* device_output;
  float result;
  float *host_out = (float *) malloc(3 * sizeof(float));
  float* host_Array = (float*)malloc(size);				// Allocate input vectors h_A and h_B in host memory
	float host_key  ;
  host_key=(float)50;

  cudaMalloc(&device_Array, size);
  cudaMalloc(&device_output,3*sizeof(float));						// Allocate vector in device memory

  FILE *f;
	f=fopen("Binary.txt","a"); //to store the result in to file


	for(int i = 0; i < N; i++) {					// Initialize input vectors
        	host_Array[i] = i;//rand()%100;
        //  printf("%f\n",host_Array[i] );
    	}
   
 /* for(int i = 0; i < N; i++) {
     //  printf("%d\t",i);
       printf("%f\n",host_Array[i] );
       fprintf(f,"\t\t%d\t",i );
       fprintf(f,"%f\n",host_Array[i] );
    	}*/
//Actual Logic
 
  cudaMemcpy(device_Array, host_Array, size, cudaMemcpyHostToDevice); //copy data to GPU
   start = std::clock();
  binary<<<1,4>>>(device_Array,device_output,host_key,N); // Invoke kernel
  stop = std::clock();
  cudaMemcpy(host_out,device_output, 3*sizeof(float), cudaMemcpyDeviceToHost);//copy to CPU
  
	
  long int GPU_time=stop - start;
  printf("Start of Partition   \t%f\n",host_out[0] );
  printf("End of Partition     \t%f\n",host_out[1]);
 
  printf("_______________________________________________________________________	\n\n"); //print to console
  printf("Result By GPU= %f ",host_out[2]);
  printf("\n\nExecution GPU_time of parllel Implementation= %ld (ms)\n", GPU_time );
  printf("_______________________________________________________________________	\n");

  fprintf(f,"_______________________________________________________________________	\n\n"); //print to file
  fprintf(f,"\t\tResult By GPU= %f \n\n ",host_out[2]);
  fprintf(f,"\n\n\t\tExecution GPU_time of parllel Implementation= %ld (ms)\n\n", GPU_time );
  fprintf(f,"_______________________________________________________________________\n	");

  start = std::clock();
  result= binarySearch( host_Array,0,N,host_key); // Calculation by cpu
  stop = std::clock();
  long int CPU_time=stop - start;
  printf("\nCPU Result= %f ",result);
  printf("\n\nExecution Time of Sequential Implementation= %ld (ms)\n",CPU_time );
  printf("_______________________________________________________________________	");

  fprintf(f,"\n\t\tCPU Result= %f ",result);                                                //cpu result print in file
  fprintf(f,"\n\n\t\tExecution Time of Sequential Implementation= %ld (ms)\n",CPU_time );
  fprintf(f,"_______________________________________________________________________	");

  float eff=float(CPU_time)/float(GPU_time);
  printf("\n\nSpeedup=CPU_TIME / GPU_TIME  =  %f\n",eff);
	printf("_______________________________________________________________________	");

  fprintf(f,"\n\nSpeedup=CPU_TIME / GPU_TIME  =  %f\n",eff);
  fprintf(f,"_______________________________________________________________________	");

  // Free device memory
	cudaFree(device_Array);
	cudaFree(device_output);

  // Free host memory
  free(host_Array);
  free(host_out);
}
