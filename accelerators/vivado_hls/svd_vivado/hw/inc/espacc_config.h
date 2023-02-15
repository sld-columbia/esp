#ifndef INC_ESPACC_CONFIG_H
#define INC_ESPACC_CONFIG_H

// User defined constants

// Data type

// if using floating point, also change the datatype in hls/custom.tcl
#define IS_TYPE_FIXED_POINT 1
#define IS_TYPE_MIXED 0
#define FRAC_BITS 21
#define IS_TYPE_UINT 0
#define IS_TYPE_INT 0
#define IS_TYPE_FLOAT 0

#define IS_TYPE_OUT_FIXED_POINT 1

// In/out arrays

#define SIZE_IN_CHUNK_DATA 64010 //P*Q+M*M+P*M+Q*M+1

#define SIZE_OUT_CHUNK_DATA 1510 //M*M+P*M+Q*M+1

#endif
