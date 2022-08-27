#ifndef FINE_GRAINED_H
#define FINE_GRAINED_H
#include "fpga.h"

#ifndef FBDN
#define FBDN         3
#define CENTRAL_CLK  4
#endif

#ifndef CLB
#define CLB          0
#define BRAM         1
#define DSP          2
#endif

typedef struct {
    int type_of_res;
    int slice_1;
    int slice_2;
}finegrained_res_description;

typedef  struct {
    unsigned long slice_x1;
    unsigned long slice_x2;
    unsigned long slice_y1;
    unsigned long slice_y2;
}slice_addres;

typedef slice_addres slice[4];

#endif // FINE_GRAINED_H
