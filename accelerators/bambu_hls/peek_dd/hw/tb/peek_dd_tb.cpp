// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

// C++ testbench for peek_dd, used by both `make peek_dd-exe`
// (native execution) and `make peek_dd-sim` (bambu --generate-tb RTL
// co-simulation). The kernel is a DMA master with a deterministic request
// pattern, so the testbench pre-fills the read data channel in request
// order, calls the top function, then checks the emitted read/write
// descriptors, the output data and that no extra traffic was produced.
// Stimulus is parity-based — w(b,i) = (b&1)*BATCH_ITEM_NUMBER + i + 1 — so
// adjacent batches carry distinct data (catches ping-pong bank
// mismanagement) while remaining consistent under sequential C execution
// of the dataflow stages (native run and RTL agree).
// Configuration registers are passed as scalar arguments with the wizard's
// default values. It must print PASS on success and return non-zero on
// failure.

#include <cstdio>
#include <hls_stream.h>
#ifdef __BAMBU__
    #include <mdpi/mdpi_user.h>
#endif

#define BATCH_ITEM_NUMBER 16
#define BEATS_PER_BATCH   (BATCH_ITEM_NUMBER / 2)

typedef unsigned long long dma_req_t;
typedef unsigned long long beat_t;
static inline dma_req_t mk_req(unsigned index, unsigned length)
{
    return ((dma_req_t)length << 32) | (dma_req_t)index;
}

extern "C" void peek_dd_core(hls::stream<dma_req_t> &dma_read_ctrl,
                             hls::stream<beat_t> &dma_read_chnl,
                             hls::stream<dma_req_t> &dma_write_ctrl,
                             hls::stream<beat_t> &dma_write_chnl, unsigned len, unsigned base_in,
                             unsigned base_out);

int main()
{
    const unsigned len            = 128;
    const unsigned base_in        = 0;
    const unsigned base_out       = 64;
    const unsigned total_batches  = len / BATCH_ITEM_NUMBER;
    const unsigned out_base_beats = base_out;

    hls::stream<dma_req_t> rd_ctrl, wr_ctrl;
    hls::stream<beat_t> rd_data, wr_data;

    for (unsigned b = 0; b < total_batches; ++b)
        for (int i = 0; i < BEATS_PER_BATCH; ++i) {
            beat_t lo = (b & 1) * BATCH_ITEM_NUMBER + 2 * i + 1;
            beat_t hi = (b & 1) * BATCH_ITEM_NUMBER + 2 * i + 2;
            rd_data.write((hi << 32) | lo);
        }

    peek_dd_core(rd_ctrl, rd_data, wr_ctrl, wr_data, len, base_in, base_out);

    int pass = 1;

    for (unsigned b = 0; b < total_batches; ++b) {
        dma_req_t expected = mk_req(base_in + b * BEATS_PER_BATCH, BEATS_PER_BATCH);
        dma_req_t got      = rd_ctrl.read();
        if (got != expected) {
            printf("FAIL read req[%u]: got %llx, expected %llx\n", b, got, expected);
            pass = 0;
        }
    }
    if (!rd_ctrl.empty()) {
        printf("FAIL: extra read requests\n");
        pass = 0;
    }

    for (unsigned b = 0; b < total_batches; ++b) {
        dma_req_t expected = mk_req(out_base_beats + b * BEATS_PER_BATCH, BEATS_PER_BATCH);
        dma_req_t got      = wr_ctrl.read();
        if (got != expected) {
            printf("FAIL write req[%u]: got %llx, expected %llx\n", b, got, expected);
            pass = 0;
        }
        for (int i = 0; i < BEATS_PER_BATCH; ++i) {
            beat_t lo         = (b & 1) * BATCH_ITEM_NUMBER + 2 * i + 1;
            beat_t hi         = (b & 1) * BATCH_ITEM_NUMBER + 2 * i + 2;
            beat_t expected_d = (((hi * hi) & 0xffffffffULL) << 32) | ((lo * lo) & 0xffffffffULL);
            beat_t computed   = wr_data.read();
            if (computed != expected_d) {
                printf("FAIL data[%u][%d]: got %llx, expected %llx\n", b, i, computed, expected_d);
                pass = 0;
            }
        }
    }
    if (!wr_ctrl.empty() || !wr_data.empty()) {
        printf("FAIL: extra write traffic\n");
        pass = 0;
    }

    if (pass) printf("PASS\n");

    return pass ? 0 : 1;
}
