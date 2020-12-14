#include <stdio.h>
#include <math.h>
#include <defines.h>
#include <stdlib.h>
#include <time.h>

/* arch_spinlock_t lock = 0; */
/* int sem; */
/* int cnt; */

void evict(int *ptr, int offset, int ways, int max_range, int hsize)
{
    int i;
    int curr_offset = offset;
    int tag_offset;
    short *ptr_short;
    char *ptr_char;

    /* if (hsize == WORD) { */
    tag_offset = 256 * 4;
    /* } else if (hsize == HALFWORD) { */
    /* 	tag_offset = 1 << (int) log2(SETS * WORDS_PER_LINE * 2); */
    /* 	ptr_short = (short *) ptr; */
    /* } else { */
    /* 	tag_offset = 1 << (int) log2(SETS * LINE_SIZE); */
    /* 	ptr_char = (char *) ptr; */
    /* } */

    for (i = 0; i <= ways; i++)
    {
	curr_offset += tag_offset;
	/* curr_offset = curr_offset % max_range; */

	/* if (hsize == WORD) */
	ptr[curr_offset] = 0xEEEEEEEE;
	/* else if (hsize == HALFWORD) */
	/*     ptr_short[curr_offset] = 0xEEEE; */
	/* else */
	/*     ptr_char[curr_offset] = 0xEE; */
    }
}
