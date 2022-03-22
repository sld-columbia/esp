#include "esplink.h"

#define DRAM_BASE 0x80000000
#ifdef OVERRIDE_DRAM_SIZE
#define DRAM_SIZE OVERRIDE_DRAM_SIZE
#else
#define DRAM_SIZE 0x20000000
#endif
