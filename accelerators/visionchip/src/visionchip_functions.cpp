// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: MIT

#ifndef __VISIONCHIP_FUNCTIONS_HPP__
#define __VISIONCHIP_FUNCTIONS_HPP__

#include "visionchip.hpp"

// Optional application-specific helper functions
#define MIN(A, B)	(A < B) ? A : B
#define MAX(A, B)	(A > B) ? A : B

int visionchip::kernel_nf(int n_Rows, int n_Cols)
{
	int16_t pxl_list[9];
	HLS_FLATTEN_ARRAY(pxl_list);

	for (int r = 1 ; r < n_Rows - 1 ; r++)
	{
		for (int c = 1 ; c < n_Cols - 1 ; c++)
		{
			int k = 0;
			for (int i = -1 ; i <= 1 ; i++)
			{
				for (int j = -1 ; j <= 1 ; j++)
				{
					pxl_list[k++] = mem_buff_1.port3[0][(r+i) * n_Cols + c + j];
					// ESP_REPORT_INFO("nf %d:%d::%d - %d", r, c, (r+i) * n_Cols + c + j, pxl_list[k-1]);
				}
			}
			// Sort the array of 9 elements
			// Here I use bubble sort for now
			for (int i = 8 ; i >= 0 ; i--)
			{
				for (int j = 1 ; j <= i ; j++)
				{
					if (pxl_list[j-1] > pxl_list[j])
					{
						int16_t temp = pxl_list[j-1];
						pxl_list[j-1] = pxl_list[j];
						pxl_list[j] = temp;
					}
				}
			}

			int index = r * n_Cols + c;
			mem_buff_2.port1[0][index] = pxl_list[4];
		}
	}


	{
		HLS_DEFINE_PROTOCOL("wait-after-nf-kernel");
		wait();
	}

	// printf("======= Finish kernel_nf =======\n");
	return 0;
}

int visionchip::kernel_hist(int n_Rows, int n_Cols)
{
	// hard code nInBpp as 16 here
	int nInBpp = 16;
	// printf("======= Start kernel_hist =======\n");

	int n_Bins = 1 << nInBpp;
	int n_Pixels = n_Rows * n_Cols;


	for (int i = 0 ; i < n_Pixels ; i++)
	{
		int16_t temp = mem_buff_2.port2[0][i];

		if (temp >= n_Bins)
		{
			int32_t tmp = mem_hist.port2[0][n_Bins-1] + 1;
			mem_hist.port1[0][n_Bins-1] = tmp;
		}
		else
		{
			int32_t tmp = mem_hist.port2[0][temp] + 1;
			mem_hist.port1[0][temp] = tmp;
		}
	}

	{
		HLS_DEFINE_PROTOCOL("wait-after-hist-kernel");
		wait();
	}

	// printf("======= Finish kernel_hist =======\n");
	return 0;
}

int visionchip::kernel_histEq(int n_Rows, int n_Cols)
{
	// hard code nInBpp as 16 here
	// hard code nOutBpp as 10 here
	int nInBpp = 16;
	int nOutBpp = 10;

	// printf("======= Start kernel_histEq =======\n");


	int32_t nOutBins = (1 << nOutBpp);
	int32_t nInpBins = (1 << nInBpp);

	int n_Pixels = n_Rows * n_Cols;

	int32_t CDFmin = 99999999;	// INT_MAX
	int32_t sum = 0;

	for (int i = 0; i < nInpBins; i++)
	{
		sum += mem_hist.port2[0][i];
		mem_CDF.port1[0][i] = sum;
	}

	for (int i = 0; i < nInpBins; i++)
	{

		CDFmin = MIN(CDFmin, mem_hist.port2[0][i]);
	}

	for (int i = 0; i < nInpBins; i++)
	{
		int32_t temp = mem_CDF.port2[0][i];
		mem_LUT.port1[0][i] = ((temp - CDFmin) * (nOutBins - 1)) / (n_Pixels - CDFmin);
	}

	for (int i = 0; i < n_Pixels; i++)
	{
		int16_t temp = mem_buff_2.port2[0][i];
		int32_t for_print = mem_LUT.port2[0][temp];
		mem_buff_1.port1[0][i] = for_print;
	}

	{
		HLS_DEFINE_PROTOCOL("wait-after-histeq-kernel");
		wait();
	}

	// printf("======= Finish kernel_histEq =======\n");
	return 0;
}


int visionchip::kernel_dwt(int n_Rows, int n_Cols)
{
	// printf("======= Start kernel_dwt =======\n");
	int n_Pixels = n_Rows * n_Cols;


	// Do the rows
	dwt_row_transpose(n_Rows, n_Cols);
	// Do the cols
	dwt_col_transpose(n_Rows, n_Cols);

	{
		HLS_DEFINE_PROTOCOL("wait-after-dwt-kernel");
		wait();
	}

	// printf("======= Finish kernel_dwt =======\n");
	return 0;
}

int visionchip::dwt_row_transpose(int n_Rows, int n_Cols)
{
	// input: mem_buff_1, output: mem_buff_2
	// printf("------- Start dwt_row_transpose -------\n");

	int32_t cur;
	int16_t temp;

	for (int i = 0 ; i < n_Rows ; i++)
	{
		// Predict the odd pixels using linear interpolation of the even pixels
		{
			for (int j = 1 ; j < n_Cols - 1 ; j += 2)
			{
				{
					HLS_DEFINE_PROTOCOL("dwt-row");
					wait();
				}

				cur = i * n_Cols + j;
				wait();
				temp = mem_buff_1.port3[0][cur - 1];
				int16_t temp3 = mem_buff_1.port3[0][cur + 1] + temp;
				int16_t temp2 = mem_buff_1.port3[0][cur];

				{
					HLS_DEFINE_PROTOCOL("dwt-row-0");
					wait();
				}

				temp = temp3 >> 1;
				mem_buff_1.port1[0][cur] = temp2 - temp;

				{
					HLS_DEFINE_PROTOCOL("dwt-row-0");
					wait();
				}
			}
		}


		// The last odd pixel only has its left neighboring even pixel
		{
			{
				HLS_DEFINE_PROTOCOL("dwt-row-0");
				wait();
			}

			cur = i * n_Cols + n_Cols - 1;
			int16_t temp2 = mem_buff_1.port3[0][cur];
			int16_t temp3 = temp2 - mem_buff_1.port3[0][cur-1];

			{
				HLS_DEFINE_PROTOCOL("dwt-row-0");
				wait();
			}

			mem_buff_1.port1[0][cur] = temp3;

			{
				HLS_DEFINE_PROTOCOL("dwt-row-0");
				wait();
			}
		}

		{
			for (int j = 2 ; j < n_Cols ; j += 2)
			{
				{
					HLS_DEFINE_PROTOCOL("dwt-row-0");
					wait();
				}

				cur = i * n_Cols + j;
				int16_t temp2 = mem_buff_1.port3[0][cur - 1];
				int16_t temp3 = mem_buff_1.port3[0][cur + 1];
				int16_t temp4 = mem_buff_1.port3[0][cur];
				temp = temp2 + temp3;

				{
					HLS_DEFINE_PROTOCOL("dwt-row-0");
					wait();
				}

				temp = temp >> 2;
				mem_buff_1.port1[0][cur] = temp4 + temp;

				{
					HLS_DEFINE_PROTOCOL("dwt-row-0");
					wait();
				}
			}
		}

		// The first even pixel only has its right neighboring odd pixel
		{
			{
				HLS_DEFINE_PROTOCOL("dwt-row-0");
				wait();
			}

			cur = i * n_Cols;
			temp = mem_buff_1.port3[0][cur + 1];
			temp = temp >> 1;
			int16_t temp2 = mem_buff_1.port3[0][cur] + temp;

			{
				HLS_DEFINE_PROTOCOL("dwt-row-0");
				wait();
			}

			mem_buff_1.port1[0][cur] = temp2;

			{
				HLS_DEFINE_PROTOCOL("dwt-row-0");
				wait();
			}
		}

		{
			for (int j = 0 ; j < n_Cols / 2 ; j++)
			{
				{
					HLS_DEFINE_PROTOCOL("dwt-row-0");
					wait();
				}

				int16_t temp2 = mem_buff_1.port3[0][i * n_Cols + 2 * j];
				int16_t temp3 = mem_buff_1.port3[0][i * n_Cols + 2 * j + 1];

				{
					HLS_DEFINE_PROTOCOL("dwt-row-0");
					wait();
				}

				mem_buff_2.port1[0][j * n_Rows + i] = temp2;
				mem_buff_2.port1[0][(j + n_Cols / 2) * n_Rows + i] = temp3;

				{
					HLS_DEFINE_PROTOCOL("dwt-row-0");
					wait();
				}
			}
		}
	}

	{
		HLS_DEFINE_PROTOCOL("wait-after-dwt-row-kernel");
		wait();
	}

	// printf("------- Finsih dwt_row_transpose -------\n");
	return 0;
}


int visionchip::dwt_col_transpose(int n_Rows, int n_Cols)
{
	// input: mem_buff_2, output: mem_buff_1
	// printf("------- Start dwt_col_transpose -------\n");

	int32_t cur;
	int16_t temp;

	for (int i = 0 ; i < n_Cols ; i++)
	{
		// Predict the odd pixels using linear interpolation of the even pixels
		{
			for (int j = 1 ; j < n_Rows - 1 ; j += 2)
			{
				{
					HLS_DEFINE_PROTOCOL("dwt-row-0");
					wait();
				}

				cur = i * n_Rows + j;
				int16_t temp2 = mem_buff_2.port2[0][cur - 1];
				int16_t temp3 = mem_buff_2.port2[0][cur + 1];
				temp = temp2 + temp3;
				temp = temp >> 1;
				int16_t temp4 = mem_buff_2.port2[0][cur];

				{
					HLS_DEFINE_PROTOCOL("dwt-row-0");
					wait();
				}

				temp = temp4 - temp;
				mem_buff_2.port1[0][cur] = temp;

				{
					HLS_DEFINE_PROTOCOL("dwt-row-0");
					wait();
				}
			}
		}

		// The last odd pixel only has its left neighboring even pixel
		{
			{
				HLS_DEFINE_PROTOCOL("dwt-row-0");
				wait();
			}

			cur = i * n_Rows + n_Rows - 1;
			int16_t temp2 = mem_buff_2.port2[0][cur];
			int16_t temp3 = temp2 - mem_buff_2.port2[0][cur-1];

			{
				HLS_DEFINE_PROTOCOL("dwt-row-0");
				wait();
			}

			mem_buff_2.port1[0][cur] = temp3;

			{
				HLS_DEFINE_PROTOCOL("dwt-row-0");
				wait();
			}
		}


		// Update the even pixels using the odd pixels
		// to preserve the mean value of the pixels
		{
			for (int j = 2 ; j < n_Rows ; j += 2)
			{
				{
					HLS_DEFINE_PROTOCOL("dwt-row-0");
					wait();
				}

				cur = i * n_Rows + j;
				int16_t temp2 = mem_buff_2.port2[0][cur - 1];
				int16_t temp3 = mem_buff_2.port2[0][cur + 1];
				temp = temp2 + temp3;
				temp = temp >> 2;
				int16_t temp4 = mem_buff_2.port2[0][cur];

				{
					HLS_DEFINE_PROTOCOL("dwt-row-0");
					wait();
				}

				mem_buff_2.port1[0][cur] = temp4 + temp;

				{
					HLS_DEFINE_PROTOCOL("dwt-row-0");
					wait();
				}
			}
		}

		{
			{
				HLS_DEFINE_PROTOCOL("dwt-row-0");
				wait();
			}

			// The first even pixel only has its right neighboring odd pixel
			cur = i * n_Rows;
			temp = mem_buff_2.port2[0][cur + 1];
			temp = temp >> 1;
			int16_t temp2 = mem_buff_2.port2[0][cur];

			{
				HLS_DEFINE_PROTOCOL("dwt-row-0");
				wait();
			}

			mem_buff_2.port1[0][cur] = temp2 + temp;

			{
				HLS_DEFINE_PROTOCOL("dwt-row-0");
				wait();
			}
		}

		// Now rearrange the data by putting the low frequency components at the front
		// and the high frequency components at the back
		// transposing the data at the same time

		{
			for (int j = 0 ; j < n_Rows / 2 ; j++)
			{
				{
					HLS_DEFINE_PROTOCOL("dwt-row-0");
					wait();
				}

				int16_t temp2 = mem_buff_2.port2[0][i * n_Rows + 2 * j];
				int16_t temp3 = mem_buff_2.port2[0][i * n_Rows + 2 * j + 1];


				{
					HLS_DEFINE_PROTOCOL("dwt-row-0");
					wait();
				}

				mem_buff_1.port1[0][j * n_Cols + i] = temp2;
				mem_buff_1.port1[0][(j + n_Rows / 2) * n_Cols + i] = temp3;

				{
					HLS_DEFINE_PROTOCOL("dwt-row-0");
					wait();
				}
			}
		}

	}

	{
		HLS_DEFINE_PROTOCOL("wait-after-dwt-col-kernel");
		wait();
	}

	// printf("------- Finsih dwt_col_transpose -------\n");
	return 0;
}

#endif /* __VISIONCHIP_FUNCTIONS_HPP__ */
