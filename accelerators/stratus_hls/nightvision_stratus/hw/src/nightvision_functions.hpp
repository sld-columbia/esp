// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __NIGHTVISION_FUNCTIONS_HPP__
#define __NIGHTVISION_FUNCTIONS_HPP__

#include "nightvision.hpp"

// Optional application-specific helper functions
#define MIN(A, B) (A < B) ? A : B
#define MAX(A, B) (A > B) ? A : B

void nightvision::kernel_nf(uint32_t n_Rows, uint32_t n_Cols)
{
    // printf("======= Start kernel_nf =======\n");

    uint16_t pxl_list[9];
    HLS_FLAT(pxl_list);

    min_bin = 0;
    max_bin = 0;

    for (uint32_t r = 1; r < n_Rows - 1; r++) {
        for (uint32_t c = 1; c < n_Cols - 1; c++) {
            int k = 0;
            for (int i = -1; i <= 1; i++) {
                for (int j = -1; j <= 1; j++) {
                    pxl_list[k++] = mem_buff_1[(r + i) * n_Cols + c + j];
                    // ESP_REPORT_INFO("nf %d:%d::%d - %d", r, c, (r+i) * n_Cols + c + j, pxl_list[k-1]);
                }
            }
            // Sort the array of 9 elements
            // Here I use bubble sort for now
            for (int i = 8; i >= 0; i--) {
                for (int j = 1; j <= i; j++) {
                    if (pxl_list[j - 1] > pxl_list[j]) {
                        uint16_t temp   = pxl_list[j - 1];
                        pxl_list[j - 1] = pxl_list[j];
                        pxl_list[j]     = temp;
                    }
                }
            }

            uint32_t index    = r * n_Cols + c;
            mem_buff_2[index] = pxl_list[4];

            if (pxl_list[4] > max_bin)
                max_bin = pxl_list[4];
        }
    }

    // copy mem_buff_2 to mem_buff_1 for validating the output
    // for (uint32_t a = 0 ; a < n_Rows*n_Cols ; a++)
    // {
    //     mem_buff_1[a] = mem_buff_2[a];
    // }

    // printf("======= Finish kernel_nf =======\n");
}

void nightvision::kernel_hist(uint32_t n_Rows, uint32_t n_Cols)
{
    // printf("======= Start kernel_hist =======\n");

    // uint32_t nInBpp = 16;             // hard code nInBpp as 16 here
    uint32_t nInBpp = MAX_PXL_WIDTH;
    // printf("======= Start kernel_hist =======\n");

    uint32_t n_Bins   = 1 << nInBpp;
    uint32_t n_Pixels = n_Rows * n_Cols;

    for (uint32_t i = min_bin; i <= max_bin; i++)
        mem_hist_1[i] = 0;

    mem_hist_1[n_Bins - 1] = 0;

    for (uint32_t i = 0; i < n_Pixels; i++) {
        uint16_t temp = mem_buff_2[i];

        if (temp >= n_Bins) {
            uint32_t tmp           = mem_hist_1[n_Bins - 1] + 1;
            mem_hist_1[n_Bins - 1] = tmp;
        } else {
            uint32_t tmp     = mem_hist_1[temp] + 1;
            mem_hist_1[temp] = tmp;
        }
    }

    // printf("======= Finish kernel_hist =======\n");
}

void nightvision::kernel_histEq(uint32_t n_Rows, uint32_t n_Cols)
{
    // hard code nInBpp as 16 here (data type is 16 bits)
    // hard code nOutBpp as 10 here
#if (MAX_PXL_WIDTH == 8)
    uint32_t nOutBpp = 8;
#else
    uint32_t nOutBpp = 10;
#endif

    // printf("======= Start kernel_histEq =======\n");

    nOutBpp          = 10;
    int32_t nOutBins = (1 << nOutBpp);
    // printf("nOutBins = %d\n", nOutBins);

    uint32_t n_Pixels = n_Rows * n_Cols;

    int32_t CDFmin = 99999999; // INT_MAX
    int32_t sum    = 0;

    for (uint32_t i = min_bin; i <= max_bin; i++) {
        HLS_PIPE_H1("accumulate-pipeline");

        int32_t val = mem_hist_1[i];
        CDFmin      = MIN(CDFmin, val);
        sum += val;
        mem_hist_2[i] = sum;
    }

    const uint32_t MUL_FACTOR = (nOutBins - 1);
    const uint32_t DIV_FACTOR = (n_Pixels - CDFmin);

    for (uint32_t i = min_bin; i <= max_bin; i++) {

        HLS_PIPE_H1("div-pipeline");

        // NB: Need two temp variable to avoid flase detection of loop-carried dependencies
        uint32_t temp1;
        uint32_t temp2;

        temp1 = mem_hist_2[i];

        temp2 = ((temp1 - CDFmin) * MUL_FACTOR) / DIV_FACTOR;

        mem_hist_1[i] = temp2;
    }

    for (uint32_t i = 0; i < n_Pixels; i++) {
        HLS_PIPE_H1("swap-data-pipeline");

        int16_t temp      = mem_buff_2[i];
        int32_t for_print = mem_hist_1[temp];
        mem_buff_1[i]     = for_print;
    }

    // printf("======= Finish kernel_histEq =======\n");
}

void nightvision::kernel_dwt(uint32_t n_Rows, uint32_t n_Cols)
{
    // printf("======= Start kernel_dwt =======\n");
    uint32_t n_Pixels = n_Rows * n_Cols;

    // Do the rows
    dwt_row_transpose(n_Rows, n_Cols, mem_buff_1, mem_buff_2);
    // Do the cols
    dwt_row_transpose(n_Cols, n_Rows, mem_buff_2, mem_buff_1);

    // printf("======= Finish kernel_dwt =======\n");
}

void nightvision::dwt_row_transpose(uint32_t n_Rows, uint32_t n_Cols, int16_t buff1[PLM_IMG_SIZE],
                                    int16_t buff2[PLM_IMG_SIZE])
{
    // input: buff1, output: buff2
    // printf("------- Start dwt_row_transpose -------\n");

    uint32_t cur;
    int16_t  temp1;
    int16_t  temp2;
    int16_t  temp3;
    int16_t  temp4;
    int16_t  temp5;

    for (uint32_t i = 0; i < n_Rows; i++) {
        // Predict the odd pixels using linear interpolation of the even pixels
        {
            // Prefetch first element
            temp1 = buff1[i * n_Cols];

            for (uint32_t j = 1; j < n_Cols - 1; j += 2) {
                HLS_PIPE_H1("dwt-xpose-odd-pipeline");
                HLS_DWT_XPOSE_CONSTR(buff1, "dwt-odd-xpose-constrain");

                cur = i * n_Cols + j;

                // Read 2 sequential words
                temp2 = buff1[cur];
                temp3 = buff1[cur + 1];

                temp4 = (temp1 + temp3) >> 1;
                temp5 = temp2 - temp4;

                // Write 1 word
                buff1[cur] = temp5;

                // Prepare for next iteration
                temp1 = temp3;
            }
        }

        // The last odd pixel only has its left neighboring even pixel
        {
            cur   = i * n_Cols + n_Cols - 1;
            temp2 = buff1[cur];
            temp3 = temp2 - temp3;

            buff1[cur] = temp3;
        }

        {
            HLS_PROTO("dwt-xpose-odd-last");
            wait();
        }

        {

            // Prefetch first element
            temp1 = buff1[i * n_Cols + 1];

            for (uint32_t j = 2; j < n_Cols; j += 2) {
                HLS_PIPE_H1("dwt-xpose-even-pipeline");
                HLS_DWT_XPOSE_CONSTR(buff1, "dwt-xpose-even-constrain");

                cur = i * n_Cols + j;

                // Read 2 sequential words
                temp2 = buff1[cur];
                temp3 = buff1[cur + 1];

                temp4 = (temp1 + temp3) >> 2;

                // Write 1 word
                buff1[cur] = temp4 + temp2;

                // Prepare for next iteration
                temp1 = temp3;
            }
        }

        // The first even pixel only has its right neighboring odd pixel
        {
            cur   = i * n_Cols;
            temp1 = buff1[cur + 1];
            temp1 = temp1 >> 1;
            temp2 = buff1[cur] + temp1;

            {
                HLS_PROTO("dwt-xpose-even-first");
                wait();
            }

            buff1[cur] = temp2;
        }

        {
            for (uint32_t j = 0; j < n_Cols / 2; j++) {
                HLS_PIPE_H2("dwt-xpose-swp-pipeline");

                temp2 = buff1[i * n_Cols + 2 * j];
                temp3 = buff1[i * n_Cols + 2 * j + 1];

                {
                    HLS_PROTO("dwt-xpose-swp-w1");
                    wait();
                    buff2[j * n_Rows + i] = temp2;
                }

                {
                    HLS_PROTO("dwt-xpose-swp-w2");
                    wait();
                    buff2[(j + n_Cols / 2) * n_Rows + i] = temp3;
                }
            }
        }

        {
            HLS_PROTO("dwt-xpose-end");
            wait();
        }
    }

    // printf("------- Finsih dwt_row_transpose -------\n");
}

#endif // __NIGHTVISION_FUNCTIONS_HPP__
