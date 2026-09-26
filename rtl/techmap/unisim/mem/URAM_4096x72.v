`timescale 1 ps / 1 ps
// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
//
// 4096 x 72-bit dual-port URAM wrapper for Xilinx UltraScale+.
// Matches the CLK0/A0/D0/Q0/WE0/CE0 dual-port interface of all BRAM wrappers.
// WEM0/WEM1 are accepted but unused (URAM uses byte-granularity BWE internally).
// URAM288 has a single CLK shared by both ports; CLK0 is used and CLK1 is ignored.
//
module URAM_4096x72 (
    CLK0,
    A0,
    D0,
    Q0,
    WE0,
    WEM0,
    CE0,
    CLK1,
    A1,
    D1,
    Q1,
    WE1,
    WEM1,
    CE1
);
    input         CLK0;
    input  [11:0] A0;
    input  [71:0] D0;
    output [71:0] Q0;
    input         WE0;
    input  [71:0] WEM0;
    input         CE0;
    input         CLK1;
    input  [11:0] A1;
    input  [71:0] D1;
    output [71:0] Q1;
    input         WE1;
    input  [71:0] WEM1;
    input         CE1;

    URAM288 #(
        .OREG_A             ("FALSE"),
        .OREG_B             ("FALSE"),
        .CASCADE_ORDER_A    ("NONE"),
        .CASCADE_ORDER_B    ("NONE"),
        .EN_AUTO_SLEEP_MODE ("FALSE"),
        .EN_ECC_RD_A        ("FALSE"),
        .EN_ECC_RD_B        ("FALSE"),
        .EN_ECC_WR_A        ("FALSE"),
        .EN_ECC_WR_B        ("FALSE"),
        .RST_MODE_A         ("SYNC"),
        .RST_MODE_B         ("SYNC"),
        .BWE_MODE_A         ("PARITY_INTERLEAVED"),
        .BWE_MODE_B         ("PARITY_INTERLEAVED"),
        .USE_EXT_CE_A       ("FALSE"),
        .USE_EXT_CE_B       ("FALSE")
    ) uram (
        .CLK              (CLK0),
        .ADDR_A           ({11'b0, A0}),
        .ADDR_B           ({11'b0, A1}),
        .DIN_A            (D0),
        .DIN_B            (D1),
        .DOUT_A           (Q0),
        .DOUT_B           (Q1),
        .BWE_A            ({9{WE0}}),
        .BWE_B            ({9{WE1}}),
        .EN_A             (CE0),
        .EN_B             (CE1),
        .RDB_WR_A         (WE0),
        .RDB_WR_B         (WE1),
        .RST_A            (1'b0),
        .RST_B            (1'b0),
        .SLEEP            (1'b0),
        .OREG_CE_A        (1'b1),
        .OREG_CE_B        (1'b1),
        .OREG_ECC_CE_A    (1'b0),
        .OREG_ECC_CE_B    (1'b0),
        .INJECT_SBITERR_A (1'b0),
        .INJECT_SBITERR_B (1'b0),
        .INJECT_DBITERR_A (1'b0),
        .INJECT_DBITERR_B (1'b0),
        .CAS_IN_ADDR_A    (23'b0),
        .CAS_IN_ADDR_B    (23'b0),
        .CAS_IN_BWE_A     (9'b0),
        .CAS_IN_BWE_B     (9'b0),
        .CAS_IN_DIN_A     (72'b0),
        .CAS_IN_DIN_B     (72'b0),
        .CAS_IN_DOUT_A    (72'b0),
        .CAS_IN_DOUT_B    (72'b0),
        .CAS_IN_EN_A      (1'b0),
        .CAS_IN_EN_B      (1'b0),
        .CAS_IN_RDACCESS_A(1'b0),
        .CAS_IN_RDACCESS_B(1'b0),
        .CAS_IN_RDB_WR_A  (1'b0),
        .CAS_IN_RDB_WR_B  (1'b0),
        .CAS_IN_SBITERR_A (1'b0),
        .CAS_IN_SBITERR_B (1'b0),
        .CAS_IN_DBITERR_A (1'b0),
        .CAS_IN_DBITERR_B (1'b0),
        .CAS_OUT_ADDR_A   (),
        .CAS_OUT_ADDR_B   (),
        .CAS_OUT_BWE_A    (),
        .CAS_OUT_BWE_B    (),
        .CAS_OUT_DIN_A    (),
        .CAS_OUT_DIN_B    (),
        .CAS_OUT_DOUT_A   (),
        .CAS_OUT_DOUT_B   (),
        .CAS_OUT_EN_A     (),
        .CAS_OUT_EN_B     (),
        .CAS_OUT_RDACCESS_A(),
        .CAS_OUT_RDACCESS_B(),
        .CAS_OUT_RDB_WR_A (),
        .CAS_OUT_RDB_WR_B (),
        .CAS_OUT_SBITERR_A(),
        .CAS_OUT_SBITERR_B(),
        .CAS_OUT_DBITERR_A(),
        .CAS_OUT_DBITERR_B(),
        .RDACCESS_A       (),
        .RDACCESS_B       (),
        .SBITERR_A        (),
        .SBITERR_B        (),
        .DBITERR_A        (),
        .DBITERR_B        ()
    );

endmodule
