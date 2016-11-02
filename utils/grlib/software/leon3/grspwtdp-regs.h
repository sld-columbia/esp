#ifndef GRSPWTDP_REGS_H_
#define GRSPWTDP_REGS_H_

#include <stdint.h>

struct grspwtdp_regs {
        /* Configuration */
        uint32_t conf[4];       /*  00 */
        uint32_t stat[4];       /*  10 */

        /* Command */
        uint32_t cmd_ctrl;      /*  20 */
        uint32_t cmd_et[5];     /*  24 */
        uint32_t resv1[2];      /*  38 */

        /* Datation */
        uint32_t dat_ctrl;      /*  40 */
        uint32_t dat_et[5];     /*  44 */
        uint32_t resv2[2];      /*  58 */

        /* Time-Stamp */
        uint32_t ts_rx_ctrl;    /*  60 */
        uint32_t ts_rx_et[5];   /*  64 */
        uint32_t resv3[2];      /*  78 */
        uint32_t ts_tx_ctrl;    /*  80 */
        uint32_t ts_tx_et[5];   /*  84 */
        uint32_t resv4[2];      /*  98 */

        /* Latency */
        uint32_t lat_ctrl;      /*  A0 */
        uint32_t lat_et[5];     /*  A4 */
        uint32_t resv5[2];      /*  B8 */

        /* Interrupt */
        uint32_t ien;           /*  C0 */
        uint32_t ists;          /*  C4 */
        uint32_t resv6[2];      /*  C8.. CC */

        uint32_t resv7[12];     /*  D0.. FC */

        /* External Datation */
        uint32_t edmask[4];       /* 100..10C */
        struct {
                uint32_t ctrl;          /* 110 */
                uint32_t et[5];         /* 114..124 */
                uint32_t resv0[2];      /* 128..12C */
        } ed[4];
};

#endif /* GRSPWTDP_REGS_H_ */
