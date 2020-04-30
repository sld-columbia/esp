/* Copyright 2018 Columbia University, SLD Group */

#ifndef __PV_OBFUSCATOR_H__
#define __PV_OBFUSCATOR_H__

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

#include "data.h"

int obfuscate(
    image_t *input,            /* input image */
    image_t *output,           /* output image */
    unsigned num_rows,         /* number of rows of the images */
    unsigned num_cols,         /* number of cols of the images */
    unsigned i_row_blur,       /* start applying blurring from this row */
    unsigned i_col_blur,       /* start applying blurring from this col */
    unsigned e_row_blur,       /* stop applying blurring from this row */
    unsigned e_col_blur,       /* stop applying blurring from this col */
    unsigned kernel_size);     /* size of the kernel for blurring */

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // __PV_OBFUSCATOR_H__
