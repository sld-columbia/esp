#ifndef __MMI64_REGS_H__
#define __MMI64_REGS_H__

#define DDRS_NUM 1
#define MEMS_NUM 1
#define NOCS_NUM 2
#define TILES_NUM 4
#define XLEN 2
#define YLEN 2
#define ACCS_NUM 0
#define VF_OP_POINTS 4
#define DIRECTIONS 5
#define L2S_NUM 1
#define LLCS_NUM 1
#define MONITOR_REG_COUNT 0
#define MONITOR_RESET_offset 0
#define MONITOR_WINDOW_SIZE_offset 1
#define MONITOR_WINDOW_LO_offset 2
#define MONITOR_WINDOW_HI_offset 3
#define TOTAL_REG_COUNT 4

struct local_yx {
unsigned y;
unsigned x;
};

enum tile_type {
empty_tile,
cpu_tile,
accelerator_tile,
misc_tile,
memory_tile,
};

struct tile_info {
unsigned id;
int type;
struct local_yx position;
char *name;
int has_pll; /* this tile's PLL drives all tiles in the domain */
int domain; /* if 0 then no DVFS */
int domain_master; /* ID of the tile where the PLL for this domain is located */
};

const struct tile_info tiles[TILES_NUM] = {
	{0, 4, {0, 0}, "mem", 0, 0, 0 },
	{1, 1, {0, 1}, "cpu", 0, 0, 0 },
	{2, 0, {1, 0}, "empty", 0, 0, 0 },
	{3, 3, {1, 1}, "IO", 0, 0, 0 }
};

#endif /*  __MMI64_REGS_H__ */
