// three matrixes, two rows in each matrix, three (columns) elements in each row
// int arr1[3][2][3] = {
//     {
//         {1, 2, 3},
//         {4, 5, 6}
//     },
//     {
//         {7, 8, 9},
//         {10, 11, 12}
//     },
//     {
// 		{13, 14, 15},
// 		{16, 17, 18}
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
// 		{13, 14, 15},
// 		{16, 17, 18}
//     }
// };


#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <assert.h>
#include <inttypes.h>
#include <time.h>


__global__ void f_siggen(float* A, float* B, float* C, int rows, int cols) {
    
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

    //    for (int i = 0; i < rows * cols; ++i) {

    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            h_A[i,j]=(float) ((i+j)%100)/2.0;
            h_B[i,j]=(float) 3.25*((i+j)%100);
        }
    }

    // cudaMemcpy(dest,src,cudaMemcpyDeviceToHost);
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

    // ADD PARAMS
    dim3 threadsPerBlocks();
    dim3 numBlocks();

    f_siggen<<<block, threadsPerBlocks>>(d_A, d_B, D_C, rows, cols);

    cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

    //cleanup deivce
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    cudaDeviceReset();

    //cleanup host
    free(h_A);
    free(h_B);
    free(h_C);
    
}