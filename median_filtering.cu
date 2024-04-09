#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image.h"
#include "stb_image_write.h"

#define MASK_SIZE 3 // Size of the mask or kernel for median filtering

__device__ void bubbleSort(unsigned char *window, int size)
{
    for (int i = 0; i < size - 1; ++i)
    {
        for (int j = 0; j < size - i - 1; ++j)
        {
            if (window[j] > window[j + 1])
            {
                unsigned char temp = window[j];
                window[j] = window[j + 1];
                window[j + 1] = temp;
            }
        }
    }
}

__global__ void medianFilterKernel(const unsigned char *inputImage, unsigned char *outputImage, int width, int height, int channels)
{
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;

    if (col < width && row < height)
    {
        int index = (row * width + col) * channels;

        // Check boundaries to avoid out-of-bounds access
        if (row >= MASK_SIZE / 2 && row < height - MASK_SIZE / 2 && col >= MASK_SIZE / 2 && col < width - MASK_SIZE / 2)
        {
            unsigned char windowR[MASK_SIZE * MASK_SIZE];
            unsigned char windowG[MASK_SIZE * MASK_SIZE];
            unsigned char windowB[MASK_SIZE * MASK_SIZE];
            int k = 0;

            // Fill the window with pixel values from the neighborhood
            for (int i = -MASK_SIZE / 2; i <= MASK_SIZE / 2; ++i)
            {
                for (int j = -MASK_SIZE / 2; j <= MASK_SIZE / 2; ++j)
                {
                    windowR[k] = inputImage[((row + i) * width + (col + j)) * channels];
                    windowG[k] = inputImage[((row + i) * width + (col + j)) * channels + 1];
                    windowB[k] = inputImage[((row + i) * width + (col + j)) * channels + 2];
                    k++;
                }
            }

            // Sort the window to find the median
            bubbleSort(windowR, MASK_SIZE * MASK_SIZE);
            bubbleSort(windowG, MASK_SIZE * MASK_SIZE);
            bubbleSort(windowB, MASK_SIZE * MASK_SIZE);

            // Assign the median value to the output pixel
            outputImage[index] = windowR[MASK_SIZE * MASK_SIZE / 2];
            outputImage[index + 1] = windowG[MASK_SIZE * MASK_SIZE / 2];
            outputImage[index + 2] = windowB[MASK_SIZE * MASK_SIZE / 2];
        }
        else
        {
            // If the pixel is on the image boundary, just copy the input to the output
            outputImage[index] = inputImage[index];
        }
    }
}

int main()
{
    int width, height, channels;
    unsigned char *inputImage = stbi_load("inp4.jpg", &width, &height, &channels, 3);
    size_t imageSize = width * height * channels * sizeof(unsigned char);

    // Allocate device memory for input and output images
    unsigned char *d_inputImage, *d_outputImage;
    cudaMalloc((void **)&d_inputImage, imageSize);
    cudaMalloc((void **)&d_outputImage, imageSize);

    cudaMemcpy(d_inputImage, inputImage, imageSize, cudaMemcpyHostToDevice);

    // record time
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);
    // Define grid and block dimensions
    dim3 blockSize(32, 32);
    dim3 gridSize((width + blockSize.x - 1) / blockSize.x, (height + blockSize.y - 1) / blockSize.y);

    // Launch the median filter kernel
    medianFilterKernel<<<gridSize, blockSize>>>(d_inputImage, d_outputImage, width, height, channels);
    cudaDeviceSynchronize();
    // stop time
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    float elapsed;
    cudaEventElapsedTime(&elapsed, start, stop);
    // Copy the result back to host memory and do further processing or save to file
    unsigned char *outputImage = (unsigned char *)malloc(imageSize);
    cudaMemcpy(outputImage, d_outputImage, imageSize, cudaMemcpyDeviceToHost);
    stbi_write_jpg("output.jpg", width, height, 3, outputImage, 100);

    printf("Image processing complete.\n");
    printf("Processing time: %.3f milliseconds\n", elapsed);
    // Free device memory and clean up
    cudaFree(d_inputImage);
    cudaFree(d_outputImage);
    free(outputImage);

    return 0;
}