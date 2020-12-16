#include <stddef.h>
#include <stdint.h>

#include "init_dev.h"

void init_dev(const struct init_dev *table)
{
        volatile uint32_t *addr;

        while (NULL != (addr = (uint32_t *) table->addr)) {
                *addr = table->value;
                table++;
        };
}

