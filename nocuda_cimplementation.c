#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image.h"
#include "stb_image_write.h"

#define MASK_SIZE 3 // Size of the mask or kernel for median filtering

void bubbleSort(unsigned char *window, int size)
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

void medianFilter(const unsigned char *inputImage, unsigned char *outputImage, int width, int height, int channels)
{
    for (int row = 0; row < height; ++row)
    {
        for (int col = 0; col < width; ++col)
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
}

int main()
{
    int width, height, channels;
    unsigned char *inputImage = stbi_load("NoiseAngelina.jpeg", &width, &height, &channels, 3);
    size_t imageSize = width * height * channels * sizeof(unsigned char);

    // Allocate memory for output image
    unsigned char *outputImage = (unsigned char *)malloc(imageSize);

    // Apply the median filter
    medianFilter(inputImage, outputImage, width, height, channels);

    // Save the result to a file
    stbi_write_jpg("output_image.jpg", width, height, 3, outputImage, 100);

    printf("Image processing complete.\n");

    // Free memory and clean up
    free(outputImage);

    return 0;
}