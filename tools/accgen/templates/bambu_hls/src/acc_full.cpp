// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

// acc_full_name — bambu-flow ESP accelerator skeleton.
//
// Three dataflow stages (load / compute / store) overlap through ding-dong
// (ping-pong) buffers. The inter-stage control queues carry the ready bank
// index: the consumer claims a bank with a blocking peek() and releases it
// with a destructive pop (plain .read(); requires bambu dev/panda or later).
// load/store are DMA MASTERS: they write a {length[63:32], index[31:0]}
// descriptor (lengths in 64-bit beats) to dma_*_ctrl BEFORE moving data.
//
// The workload geometry is RUNTIME-configurable: the first configuration
// register (acc_full_first_param) gives the total number of 32-bit words per
// invocation — a positive multiple of BATCH_ITEM_NUMBER — and the batch
// count and output base derive from it below. Every configuration register
// reaches this function as a scalar argument: bambu emits an input port per
// argument and the ESP socket wrapper connects the conf_info_* registers.
//
// The skeleton computes out[i] = in[i] * in[i]. Replace the compute body
// (and the address map in load/store if needed) with your kernel.
//
// Parallelism: unroll the compute loop and give it memory bandwidth to match,
// e.g. `#pragma unroll 4` (or #pragma HLS unroll) on the inner loop plus
// `#pragma HLS array_partition variable = buffer2 cyclic factor = 4 dim = 1`.

#include <hls_stream.h>

#define BATCH_ITEM_NUMBER 16                      // words per ping-pong bank (compile-time)
#define BEATS_PER_BATCH   (BATCH_ITEM_NUMBER / 2) // 64-bit beats per batch

typedef unsigned long long dma_req_t;
typedef unsigned long long beat_t; // 64-bit DMA beat = 2 words
static inline dma_req_t mk_req(unsigned index, unsigned length)
{
    return ((dma_req_t)length << 32) | (dma_req_t)index; // index/length in BEATS
}

// LOAD — DMA master: request a batch, unpack each 64-bit beat into 2 words.
extern "C" void __attribute__((noinline))
load(hls::stream<dma_req_t> &dma_read_ctrl, hls::stream<beat_t> &dma_read_chnl,
     hls::stream<unsigned char> &ctrl_out, unsigned int array_out[BATCH_ITEM_NUMBER * 2],
     unsigned total_batches)
{
    static unsigned char ob = 0;
    for (unsigned b = 0; b < total_batches; ++b) {
        dma_read_ctrl.write(mk_req(b * BEATS_PER_BATCH, BEATS_PER_BATCH));
        for (int i = 0; i < BEATS_PER_BATCH; ++i) {
            beat_t x                                      = dma_read_chnl.read();
            array_out[BATCH_ITEM_NUMBER * ob + 2 * i]     = (unsigned int)(x & 0xffffffffu);
            array_out[BATCH_ITEM_NUMBER * ob + 2 * i + 1] = (unsigned int)(x >> 32);
        }
        ctrl_out.write(ob);
        ob = (ob + 1) % 2;
    }
}

// COMPUTE — blocking peek claims the filled bank, pop releases it.
extern "C" void __attribute__((noinline))
compute(hls::stream<unsigned char> &ctrl_in, hls::stream<unsigned char> &ctrl_out,
        unsigned int array_in[BATCH_ITEM_NUMBER * 2], unsigned int array_out[BATCH_ITEM_NUMBER * 2],
        unsigned total_batches)
{
    static unsigned char ob = 0;
    for (unsigned b = 0; b < total_batches; ++b) {
        unsigned char ib = ctrl_in.peek();
        for (int i = 0; i < BATCH_ITEM_NUMBER; ++i) {
            unsigned int v                        = array_in[BATCH_ITEM_NUMBER * ib + i];
            array_out[BATCH_ITEM_NUMBER * ob + i] = v * v; // <-- your kernel here
        }
        ctrl_in.read();
        ctrl_out.write(ob);
        ob = (ob + 1) % 2;
    }
}

// STORE — DMA master: request, then pack 2 words into each 64-bit beat.
extern "C" void __attribute__((noinline))
store(hls::stream<unsigned char> &ctrl_in, unsigned int array_in[BATCH_ITEM_NUMBER * 2],
      hls::stream<dma_req_t> &dma_write_ctrl, hls::stream<beat_t> &dma_write_chnl,
      unsigned total_batches, unsigned out_base_beats)
{
    for (unsigned b = 0; b < total_batches; ++b) {
        unsigned char ib = ctrl_in.peek();
        dma_write_ctrl.write(mk_req(out_base_beats + b * BEATS_PER_BATCH, BEATS_PER_BATCH));
        for (int i = 0; i < BEATS_PER_BATCH; ++i) {
            beat_t lo = array_in[BATCH_ITEM_NUMBER * ib + 2 * i];
            beat_t hi = array_in[BATCH_ITEM_NUMBER * ib + 2 * i + 1];
            dma_write_chnl.write((hi << 32) | lo);
        }
        ctrl_in.read();
    }
}

#pragma HLS interface port = dma_read_ctrl mode = axis
#pragma HLS interface port = dma_read_chnl mode = axis
#pragma HLS interface port = dma_write_ctrl mode = axis
#pragma HLS interface port = dma_write_chnl mode = axis
extern "C" void acc_full_name_core(hls::stream<dma_req_t> &dma_read_ctrl,
                                   hls::stream<beat_t> &dma_read_chnl,
                                   hls::stream<dma_req_t> &dma_write_ctrl,
                                   hls::stream<beat_t> &dma_write_chnl /* <<--params-args-->> */)
{
#pragma HLS DATAFLOW
    hls::stream<unsigned char> ctrl1;
    hls::stream<unsigned char> ctrl2;
    unsigned int buffer1[BATCH_ITEM_NUMBER * 2]; // ding-dong banks
    unsigned int buffer2[BATCH_ITEM_NUMBER * 2];
    const unsigned total_batches  = acc_full_first_param / BATCH_ITEM_NUMBER;
    const unsigned out_base_beats = ACC_FULL_OUT_BASE;
    load(dma_read_ctrl, dma_read_chnl, ctrl1, buffer1, total_batches);
    compute(ctrl1, ctrl2, buffer1, buffer2, total_batches);
    store(ctrl2, buffer2, dma_write_ctrl, dma_write_chnl, total_batches, out_base_beats);
}
