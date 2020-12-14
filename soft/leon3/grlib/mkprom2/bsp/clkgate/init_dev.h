#ifndef _INIT_DEV_H_
#define _INIT_DEV_H_

#include <stdint.h>

struct init_dev {
	uint32_t addr;
	uint32_t value;
};

/*
 * Initialize data locations given (addr, value) pairs.
 *
 * struct init_dev contains 32-bit addr and value fields. For each such pair,
 * write value to addr. The function returns when addr=NULL.
 */
void init_dev(const struct init_dev *table);

#endif
