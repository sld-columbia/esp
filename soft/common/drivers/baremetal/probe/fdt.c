// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
/*
 * Copyright (c) 2013, The Regents of the University of California (Regents).
 * All Rights Reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the Regents nor the
 *    names of its contributors may be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * IN NO EVENT SHALL REGENTS BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,
 * SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING
 * OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF REGENTS HAS
 * BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * REGENTS SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED
 * HEREUNDER IS PROVIDED "AS IS". REGENTS HAS NO OBLIGATION TO PROVIDE
 * MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */

#include "fdt.h"
#include <stdint.h>
#include <string.h>

static inline uint32_t bswap(uint32_t x)
{
    // #if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
    uint32_t y = (x & 0x00FF00FF) << 8 | (x & 0xFF00FF00) >> 8;
    uint32_t z = (y & 0x0000FFFF) << 16 | (y & 0xFFFF0000) >> 16;
    return z;
    // #else
    //   /* No need to swap on big endian */
    //   return x;
    // #endif
}

static inline int isstring(char c)
{
    if (c >= 'A' && c <= 'Z') return 1;
    if (c >= 'a' && c <= 'z') return 1;
    if (c >= '0' && c <= '9') return 1;
    if (c == '\0' || c == ' ' || c == ',' || c == '-') return 1;
    return 0;
}

static uint32_t *fdt_scan_helper(uint32_t *lex, const char *strings, struct fdt_scan_node *node,
                                 const struct fdt_cb *cb)
{
    struct fdt_scan_node child;
    struct fdt_scan_prop prop;
    int last = 0;

    child.parent = node;
    // these are the default cell counts, as per the FDT spec
    child.address_cells = 2;
    child.size_cells    = 1;
    prop.node           = node;

    while (1) {
        switch (bswap(lex[0])) {
            case FDT_NOP: {
                lex += 1;
                break;
            }
            case FDT_PROP: {
                // assert (!last);
                prop.name  = strings + bswap(lex[2]);
                prop.len   = bswap(lex[1]);
                prop.value = lex + 3;
                if (node && !strcmp(prop.name, "#address-cells")) {
                    node->address_cells = bswap(lex[3]);
                }
                if (node && !strcmp(prop.name, "#size-cells")) { node->size_cells = bswap(lex[3]); }
                lex += 3 + (prop.len + 3) / 4;
                cb->prop(&prop, cb->extra);
                break;
            }
            case FDT_BEGIN_NODE: {
                uint32_t *lex_next;
                if (!last && node && cb->done) cb->done(node, cb->extra);
                last       = 1;
                child.name = (const char *)(lex + 1);
                if (cb->open) cb->open(&child, cb->extra);
                lex_next = fdt_scan_helper(lex + 2 + strlen(child.name) / 4, strings, &child, cb);
                if (cb->close && cb->close(&child, cb->extra) == -1)
                    while (lex != lex_next)
                        *lex++ = bswap(FDT_NOP);
                lex = lex_next;
                break;
            }
            case FDT_END_NODE: {
                if (!last && node && cb->done) cb->done(node, cb->extra);
                return lex + 1;
            }
            default: { // FDT_END
                if (!last && node && cb->done) cb->done(node, cb->extra);
                return lex;
            }
        }
    }
}

void fdt_scan(uintptr_t fdt, const struct fdt_cb *cb)
{
    struct fdt_header *header = (struct fdt_header *)fdt;

    // Only process FDT that we understand
    if (bswap(header->magic) != FDT_MAGIC || bswap(header->last_comp_version) > FDT_VERSION) return;

    const char *strings = (const char *)(fdt + bswap(header->off_dt_strings));
    uint32_t *lex       = (uint32_t *)(fdt + bswap(header->off_dt_struct));

    fdt_scan_helper(lex, strings, 0, cb);
}

uint32_t fdt_size(uintptr_t fdt)
{
    struct fdt_header *header = (struct fdt_header *)fdt;

    // Only process FDT that we understand
    if (bswap(header->magic) != FDT_MAGIC || bswap(header->last_comp_version) > FDT_VERSION)
        return 0;
    return bswap(header->totalsize);
}

const uint32_t *fdt_get_address(const struct fdt_scan_node *node, const uint32_t *value,
                                uint64_t *result)
{
    *result = 0;
    for (int cells = node->address_cells; cells > 0; --cells)
        *result = (*result << 32) + bswap(*value++);
    return value;
}

const uint32_t *fdt_get_size(const struct fdt_scan_node *node, const uint32_t *value,
                             uint64_t *result)
{
    *result = 0;
    for (int cells = node->size_cells; cells > 0; --cells)
        *result = (*result << 32) + bswap(*value++);
    return value;
}

uint32_t fdt_get_value(const struct fdt_scan_prop *prop, uint32_t index)
{
    return bswap(prop->value[index]);
}

int fdt_string_list_index(const struct fdt_scan_prop *prop, const char *str)
{
    const char *list = (const char *)prop->value;
    const char *end  = list + prop->len;
    int index        = 0;
    while (end - list > 0) {
        if (!strcmp(list, str)) return index;
        ++index;
        list += strlen(list) + 1;
    }
    return -1;
}
