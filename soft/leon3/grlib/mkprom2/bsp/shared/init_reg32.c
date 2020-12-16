#include <stdint.h>

/*
 * offset-value pair
 *
 * offset:      address offset from some base address
 * value:       value to write to base+offset
 */
struct init_reg32 {
        uint32_t offset;
        uint32_t value;
};

/* Initialize registers given an array of offset-value pairs
 *
 * base:        Added to the offset of the corresponding table entry
 * table:       Array of init_reg32, terminated with 0xffffffff
 */
uintptr_t init_reg32(uintptr_t base, const struct init_reg32 *table);

static const uint32_t TABLE_TERM = 0xffffffff;
uintptr_t init_reg32(uintptr_t base, const struct init_reg32 *table)
{
        uint32_t t;

        while (TABLE_TERM != (t = table->offset)) {
                volatile uint32_t *addr;

                t += base;
                addr = (uint32_t *) t;
                *addr = table->value;
                table++;
        };

        return base;
}

