/* Copyright 2018 Columbia University, SLD Group */

#ifndef __OBFUSCATOR_UTILS_H__
#define __OBFUSCATOR_UTILS_H__

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

#include "data.h"

int read_image_from_file(
    image_t **data,            /* input image */
    unsigned *num_rows,        /* number of rows of the input image */
    unsigned *num_cols,        /* number of cols of the input image */
    const char *name);         /* name of the input file */

int write_image_to_file(
    image_t *data,             /* output image */
    unsigned num_rows,         /* number of rows of the output image */
    unsigned num_cols,         /* number of cols of the output image */
    const char *name);         /* name of the output file */

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // __OBFUSCATOR_UTILS_H__
