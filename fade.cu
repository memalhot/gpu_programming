__global__ void fade(unsigned char *d_in, unsigned char *d_out, float f, int xmax, int ymax) {

unsigned int idx, v;
int x = blockDim.x * blockIdx.x + threadIdx.x;
int y = blockDim.y * blockIdx.y + threatIdx.y;

if ((x >= xmax) || (y >= ymax)) {
    return;
}

idx = y * xmax + x;
v = d_in[idx] * f;
if (v>255) {
    v=255;
}
d_out[idx]=v;

}

int main(void) {
    dim3 nblocks(7,3);
    dim3 nthreads(16, 16);
    fade <<<nblocks, nthreads>>>(d_in, d_out, f, xmax, ymax); 
    cudaDeviceSynchronize();
    cudaDeviceReset();
}