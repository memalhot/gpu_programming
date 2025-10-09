// three matrixes, two rows in each matrix, three (columns) elements in each row
// int arr1[3][2][3] = {
//     {
//         {1, 2, 3},
//         {4, 5, 6}
//     },
//     {
//        {7, 8, 9},
//        {10, 11, 12}
//     },
//     {
//                {13, 14, 15},
//                {16, 17, 18}
//     }
// };


// int arr2[3][2][3] = {
//     {
//         {1, 2, 3},
//         {4, 5, 6}
//     },
//     {
//         {7, 8, 9},
//         {10, 11, 12}
//     },
//     {
//                 {13, 14, 15},
//                 {16, 17, 18}
//     }
// };


#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <assert.h>
#include <inttypes.h>
#include <time.h>

#define CLOCK_SOURCE CLOCK_MONOTONIC
#define NSEC_IN_SECOND (1000000000)

typedef struct timespec ts_t;

__global__ void f_siggen(float* A, float* B, float* C, int rows, int cols) {
    
    //int col = blockIdx.x * blockDim.x + threadIdx.x
    //int row = blockIdx.y * blockDim.y + threadIdx.y

    // i = row
    // j = col
    int i = threadIdx.y;
    int j = threadIdx.x;

    C[i * cols + j] = A[(i-1) * cols + j] + A[i * cols + j] + A[(i+1) * cols + j] - B[i * cols + j-2] - B[i * cols + j-1] - B[i * cols + j];
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <rows> <cols>\n", argv[0]);
        return 1;
    }

    int rows = atoi(argv[1]);
    int cols = atoi(argv[2]);
    int size = rows * cols * sizeof(float);

    // host
    float* h_A;
    float* h_B;
    float* h_C;

    // device
    float* d_A;
    float* d_B;
    float* d_C;

    // allocate for host
    h_A = (float*)malloc(size);
    h_B = (float*)malloc(size);
    h_C = (float*)malloc(size);
    
    // allocate on device
    cudaMalloc((void**)&d_A, size);
    cudaMalloc((void**)&d_B, size);
    cudaMalloc((void**)&d_C, size);

    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            int index = i * cols + j;

            h_A[index]=(float) ((i+j)%100)/2.0;
            h_B[index]=(float) 3.25*((i+j)%100);
        }
    }

    // cudaMemcpy(dest,src,cudaMemcpyDeviceToHost);
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

    // generic thread blocks
    dim3 threadsPerBlock(rows, cols);

    // round up
    //int x = (cols + threadsPerBlock.x - 1) / threadsPerBlock.x;
    //int y = (rows + threadsPerBlock.y - 1) / threadsPerBlock.y;

    dim3 numBlocks(1, 1);


    static inline int ts_now(ts_t *now) {
    if (clock_gettime(CLOCK_SOURCE, now) == -1) {
        perror("clock_gettime");
        assert(0);
        return 0;
    }
    return 1;
    }

    f_siggen<<<numBlocks, threadsPerBlock>>>(d_A, d_B, d_C, rows, cols);
    cudaError_t err = cudaDeviceSynchronize();

    if (err != cudaSuccess) {
        fprintf(stderr, "error: %s\n", cudaGetErrorString(err));
    }

    cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);


    static inline uint64_t ts_diff(ts_t start, ts_t end)
        {
        uint64_t diff =
            ((end.tv_sec - start.tv_sec) * NSEC_IN_SECOND) +
            (end.tv_nsec - start.tv_nsec);
        return diff;
        } 

    //cleanup deivce
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    cudaDeviceReset();

    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; ++j) {
            printf("%f ", h_C[i * cols + j]);
        }
        printf("\n");
    }

    //cleanup host
    free(h_A);
    free(h_B);
    free(h_C);

    
}