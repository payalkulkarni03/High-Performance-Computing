#include <stdio.h>
#include <sys/time.h>

#define N 10
// helper for main()
long readList(long**);

// data[], size, threads, blocks, 
void mergesort(long*, long, dim3, dim3);
// A[]. B[], size, width, slices, nThreads
__global__ void gpu_mergesort(long*, long*, long, long, long, dim3*, dim3*);
__device__ void gpu_bottomUpMerge(long*, long*, long, long, long);
int tm();



#define min(a, b) (a < b ? a : b)

void printHelp(char* program) {

    
}


int main(int argc, char** argv) {

    dim3 threadsPerBlock;
    dim3 blocksPerGrid;

    threadsPerBlock.x = 32;
    

    blocksPerGrid.x = 8;
    


    long* data = (long*)malloc(N*sizeof(long));;

   for(int i = 0; i < N; i++) {
       data[i] = rand()%100;
}

    
         printf("sorting %d numbers\n",N);

    // merge-sort the data
    mergesort(data, N, threadsPerBlock, blocksPerGrid);

   

    
    for (int i = 0; i < N; i++) {
         printf("%ld\n", data[i] );
    } 

   
      
   
}

void mergesort(long* data, long size, dim3 threadsPerBlock, dim3 blocksPerGrid) {

    
    // Allocate two arrays on the GPU
   
    
    long* D_data;
    long* D_swp;
    dim3* D_threads;
    dim3* D_blocks;
    
    
    cudaMalloc((void**) &D_data, size * sizeof(long));
   cudaMalloc((void**) &D_swp, size * sizeof(long));
   
       

    // Copy from our input list into the first array
    cudaMemcpy(D_data, data, size * sizeof(long), cudaMemcpyHostToDevice);
 
      
 
  
    // Copy the thread / block info to the GPU as well
   
    cudaMalloc((void**) &D_threads, sizeof(dim3));
    cudaMalloc((void**) &D_blocks, sizeof(dim3));

   
      
   cudaMemcpy(D_threads, &threadsPerBlock, sizeof(dim3), cudaMemcpyHostToDevice);
    cudaMemcpy(D_blocks, &blocksPerGrid, sizeof(dim3), cudaMemcpyHostToDevice);

   
       

    long* A = D_data;
    long* B = D_swp;

    long nThreads = threadsPerBlock.x * threadsPerBlock.y * threadsPerBlock.z *
                    blocksPerGrid.x * blocksPerGrid.y * blocksPerGrid.z;

    //
    // Slice up the list and give pieces of it to each thread, letting the pieces grow
    // bigger and bigger until the whole list is sorted
    //
    for (int width = 2; width < (size << 1); width <<= 1) {
        long slices = size / ((nThreads) * width) + 1;

        
         
        gpu_mergesort<<<blocksPerGrid, threadsPerBlock>>>(A, B, size, width, slices, D_threads, D_blocks);

        // Switch the input / output arrays instead of copying them around
        A = A == D_data ? D_swp : D_data;
        B = B == D_data ? D_swp : D_data;
    }

    //
    // Get the list back from the GPU
    //
    
    cudaMemcpy(data, A, size * sizeof(long), cudaMemcpyDeviceToHost);
   
    
    
    
    // Free the GPU memory
  cudaFree(A);
    cudaFree(B);
   
      
}

__device__ void gpu_Merge(long* source, long* dest, long start, long middle, long end) {
    long i = start;
    long j = middle;
    for (long k = start; k < end; k++) {
        if (i < middle && (j >= end || source[i] < source[j])) {
            dest[k] = source[i];
            i++;
        } else {
            dest[k] = source[j];
            j++;
        }
    }
}


//
// Perform a full mergesort on our section of the data.
//
__global__ void gpu_mergesort(long* source, long* dest, long size, long width, long slices, dim3* threads, dim3* blocks) {
   
	unsigned int idx=(blockIdx.x*blockDim.x)+threadIdx.x;
    	long start = width*idx*slices,
         middle, 
         end;

    for (long slice = 0; slice < slices; slice++) {
        if (start >= size)
            break;

        middle = min(start + (width >> 1), size);
        end = min(start + width, size);
        gpu_Merge(source, dest, start, middle, end);
        start += width;
    }
}

//
// Finally, sort something
// gets called by gpu_mergesort() for each slice
//

// read data into a minimal linked list

     
    





