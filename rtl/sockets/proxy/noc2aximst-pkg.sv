// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDC-License-Identifier: Apache-2.0

`timescale 1ns / 1ps

package noc2aximst_pkg;

import esp_global_sv::*;

`define PREAMBLE_WIDTH 2
`define MSG_TYPE_WIDTH 5
`define RESERVED_WIDTH 8
`define NEXT_ROUTING_WIDTH 5

parameter integer DMA_NOC_FLIT_SIZE = `PREAMBLE_WIDTH + DMA_NOC_WIDTH;
parameter integer MAX_NOC_FLIT_SIZE = `PREAMBLE_WIDTH + MAX_NOC_WIDTH;

//`define RSP_AHB_RD 30
//`define RSP_DATA 24
//`define RSP_DATA_DMA
parameter integer XRESP_OKAY = 0;
parameter integer XRESP_EXOKAY = 1;
parameter integer XRESP_SLVERR = 2;
parameter integer XRESP_DECERR = 3;
parameter integer XBURST_FIXED = 0;
parameter integer XBURST_INCR  = 1;
parameter integer XBURST_WRAP  = 2;

typedef enum logic [4:0] {
    RSP_DATA     = 5'b11000,
    RSP_EDATA    = 5'b11001,
    RSP_DATA_DMA = 5'b11011,
    RSP_AHB_RD   = 5'b11110

} resp_type;

typedef enum logic [4:0] {
    REQ_GETS_W  = 5'b11000,
    REQ_GETM_W  = 5'b11001,
    REQ_GETS_B  = 5'b11100,
    REQ_GETS_HW = 5'b11101,
    REQ_GETM_B  = 5'b11110,
    REQ_GETM_HW = 5'b11111,
    AHB_RD      = 5'b11010,
    AHB_WR      = 5'b11011
} req_type;

typedef enum logic [4:0] {
    DMA_TO_DEV    = 5'b11001,
    DMA_FROM_DEV  = 5'b11010,
    REQ_DMA_READ  = 5'b11110,
    REQ_DMA_WRITE = 5'b11111
} dma_req_type;

typedef enum logic [2:0] {
    XSIZE_BYTE  = 3'b000,
    XSIZE_HWORD = 3'b001,
    XSIZE_WORD  = 3'b010,
    XSIZE_DWORD = 3'b011
} transfer_size;

typedef enum logic [1:0] {
    PREAMBLE_HEADER = 2'b10,
    PREAMBLE_TAIL   = 2'b01,
    PREAMBLE_BODY   = 2'b00,
    PREAMBLE_1FLIT  = 2'b11
} preamble_type;


typedef struct {
    logic [DMA_NOC_FLIT_SIZE-`PREAMBLE_WIDTH-1 : 0] dma_noc_data;
    logic [DMA_NOC_FLIT_SIZE-1 : 0]					dma_flit;
    logic [2 : 0]									ax_prot;
    logic [$clog2(DMA_NOC_WIDTH/ARCH_BITS) : 0]		word_cnt;
    logic [`MSG_TYPE_WIDTH-1 : 0]					msg;
	logic [`PREAMBLE_WIDTH-1 : 0]					preamble_flag;
    logic [GLOB_PHYS_ADDR_BITS-1 : 0]				aw_addr;
    logic [GLOB_PHYS_ADDR_BITS-1 : 0]				ar_addr;
    logic [AXIDW-1 : 0]	w_data;
    logic [7 : 0]		ar_len;
    logic [2 : 0]		ar_size;
    logic [2 : 0]		ar_prot;
	logic				ar_valid;
	logic				r_ready;
    logic [7 : 0]		aw_len;
    logic [7 : 0]		word_rem;
    logic [2 : 0]		aw_size;
    logic [2 : 0]		aw_prot;
    logic [AW-1 : 0]	w_strb;
    logic				aw_valid;
    logic				w_last;
    logic				w_valid;
    logic				b_ready;
	logic [31 : 0]		count;
    logic [1 : 0]		sample_flag;
    logic				burst_flag;
    logic				coh_dma_flag;
    logic				hsize_msb;
} reg_type;

endpackage

