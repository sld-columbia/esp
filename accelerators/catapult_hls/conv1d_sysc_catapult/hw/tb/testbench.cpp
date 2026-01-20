// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "testbench.hpp"
#include "conv1d_pv.hpp"
#include <mc_connections.h>
#include <mc_scverify.h>

#include <cmath>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <string>
#include <vector>

#define ERR_THRESHOLD 0.01f

namespace {

const char kInputFile[] = "../tb/data/input1.bin";
const char kWeightFile[] = "../tb/data/l1_w1.bin";
const char kBiasFile[] = "../tb/data/l1_b1.bin";
const uint32_t kDebugCount = 8;

bool load_bin_file(const char *path, std::vector<float> &dst)
{
    std::ifstream file(path, std::ios::binary);
    if (!file) {
        std::cerr << "Error opening " << path << std::endl;
        return false;
    }
    file.read(reinterpret_cast<char *>(dst.data()), dst.size() * sizeof(float));
    if (!file) {
        std::cerr << "Error reading " << path << std::endl;
        return false;
    }
    return true;
}

FPDATA_WORD float_to_word(float val)
{
    FPDATA fp = FPDATA(val);
    FPDATA_WORD word;
    fx2int(fp, word);
    return word;
}

float word_to_float(const FPDATA_WORD &word)
{
    FPDATA fp;
    int2fx(word, fp);
    return static_cast<float>(fp.to_double());
}

void write_floats_to_mem(ac_int<DMA_WIDTH> *mem, uint32_t base_addr_words,
                         const std::vector<float> &src)
{
    if (DMA_WORD_PER_BEAT == 0) {
        std::cerr << "Unsupported DMA_WORD_PER_BEAT=0" << std::endl;
        return;
    }
    if ((base_addr_words % DMA_WORD_PER_BEAT) != 0) {
        std::cerr << "Unaligned base address " << base_addr_words
                  << " (DMA_WORD_PER_BEAT=" << DMA_WORD_PER_BEAT << ")" << std::endl;
        return;
    }

    uint32_t words = static_cast<uint32_t>(src.size());
    uint32_t beats = (words + DMA_WORD_PER_BEAT - 1) / DMA_WORD_PER_BEAT;
    uint32_t base_beat = base_addr_words / DMA_WORD_PER_BEAT;
    uint32_t word_idx = 0;

    for (uint32_t b = 0; b < beats; ++b) {
        ac_int<DMA_WIDTH> data_bv = 0;
        for (uint32_t lane = 0; lane < DMA_WORD_PER_BEAT; ++lane) {
            if (word_idx < words) {
                FPDATA_WORD word = float_to_word(src[word_idx]);
                data_bv.set_slc(lane * DATA_WIDTH, word);
                ++word_idx;
            }
        }
        mem[base_beat + b] = data_bv;
    }
}

void read_floats_from_mem(ac_int<DMA_WIDTH> *mem, uint32_t base_addr_words, uint32_t count,
                          std::vector<float> &dst)
{
    if (DMA_WORD_PER_BEAT == 0) {
        std::cerr << "Unsupported DMA_WORD_PER_BEAT=0" << std::endl;
        return;
    }
    if ((base_addr_words % DMA_WORD_PER_BEAT) != 0) {
        std::cerr << "Unaligned base address " << base_addr_words
                  << " (DMA_WORD_PER_BEAT=" << DMA_WORD_PER_BEAT << ")" << std::endl;
        return;
    }

    dst.assign(count, 0.0f);

    uint32_t beats = (count + DMA_WORD_PER_BEAT - 1) / DMA_WORD_PER_BEAT;
    uint32_t base_beat = base_addr_words / DMA_WORD_PER_BEAT;
    uint32_t word_idx = 0;

    for (uint32_t b = 0; b < beats; ++b) {
        ac_int<DMA_WIDTH> data_bv = mem[base_beat + b];
        for (uint32_t lane = 0; lane < DMA_WORD_PER_BEAT; ++lane) {
            if (word_idx < count) {
                FPDATA_WORD word = data_bv.slc<DATA_WIDTH>(lane * DATA_WIDTH);
                dst[word_idx] = word_to_float(word);
                ++word_idx;
            }
        }
    }
}

} // namespace

void testbench::proc()
{
    conf_info.Reset();
    wait();

    CCS_LOG("--------------------------------");
    CCS_LOG("ESP - conv1d [Catapult HLS SystemC]");
    CCS_LOG("--------------------------------");

    const int n_ch = 1;
    const int len = 240;
    const int filters = 16;
    const int k = 7;
    const int stride = 2;
    const int batch = 1;

    const uint32_t input_off = 0;
    const uint32_t weight_off = input_off + (len * n_ch);
    const uint32_t bias_off = weight_off + (k * n_ch * filters);
    const uint32_t out_off = bias_off + filters;

    const uint32_t out_len = len / stride;
    const uint32_t out_words = filters * out_len;

    std::vector<float> input(static_cast<size_t>(len * n_ch));
    std::vector<float> weights(static_cast<size_t>(k * n_ch * filters));
    std::vector<float> bias(static_cast<size_t>(filters));

    if (!load_bin_file(kInputFile, input) ||
        !load_bin_file(kWeightFile, weights) ||
        !load_bin_file(kBiasFile, bias)) {
        CCS_LOG("Failed to load input/weight/bias binaries");
        sc_stop();
        wait();
        return;
    }

    write_floats_to_mem(mem, input_off, input);
    write_floats_to_mem(mem, weight_off, weights);
    write_floats_to_mem(mem, bias_off, bias);

    std::cout << "Memory layout (word offsets):" << std::endl;
    std::cout << "  input_off=" << input_off
              << " weight_off=" << weight_off
              << " bias_off=" << bias_off
              << " out_off=" << out_off << std::endl;

    std::cout << "Input[0.." << (kDebugCount - 1) << "]:";
    for (uint32_t i = 0; i < kDebugCount && i < input.size(); ++i) {
        std::cout << " " << std::fixed << std::setprecision(6) << input[i];
    }
    std::cout << std::endl;

    std::cout << "Weight[0.." << (kDebugCount - 1) << "]:";
    for (uint32_t i = 0; i < kDebugCount && i < weights.size(); ++i) {
        std::cout << " " << std::fixed << std::setprecision(6) << weights[i];
    }
    std::cout << std::endl;

    std::cout << "Bias[0.." << (kDebugCount - 1) << "]:";
    for (uint32_t i = 0; i < kDebugCount && i < bias.size(); ++i) {
        std::cout << " " << std::fixed << std::setprecision(6) << bias[i];
    }
    std::cout << std::endl;

    CCS_LOG("load memory completed");

    conf_info_t config;
    config.kernel_size = k;
    config.n_channels = n_ch;
    config.stride = stride;
    config.is_relu = 1;
    config.addrB = bias_off;
    config.addrO = out_off;
    config.addrI = input_off;
    config.addrW = weight_off;
    config.batch_size = batch;
    config.n_filters = filters;
    config.feature_map_len = len;
    config.padding = 0;

    conf_info.Push(config);
    CCS_LOG("config done");

    do {
        wait();
    } while (!acc_done.read());

    std::vector<float> output;
    read_floats_from_mem(mem, out_off, out_words, output);

    std::vector<float> golden(out_words);
    conv1d_golden(input.data(), weights.data(), bias.data(), golden.data(),
                  n_ch, len, filters, k, stride);

    std::cout << "Output[0.." << (kDebugCount - 1) << "]:";
    for (uint32_t i = 0; i < kDebugCount && i < output.size(); ++i) {
        std::cout << " " << std::fixed << std::setprecision(6) << output[i];
    }
    std::cout << std::endl;

    std::cout << "Golden[0.." << (kDebugCount - 1) << "]:";
    for (uint32_t i = 0; i < kDebugCount && i < golden.size(); ++i) {
        std::cout << " " << std::fixed << std::setprecision(6) << golden[i];
    }
    std::cout << std::endl;

    int err = 0;
    for (uint32_t i = 0; i < out_words; ++i) {
        float acc_result = output[i];
        float gold = golden[i];
        if (gold != acc_result) {
            float mse = (gold - acc_result) * (gold - acc_result);
            if (std::fabs(gold) > 0.001f) {
                mse /= (gold * gold);
            }
            if (mse > ERR_THRESHOLD) {
                std::cerr << "ERROR: idx " << i << " got " << std::fixed << std::setprecision(6)
                          << acc_result << " expected " << gold << " mse " << mse << std::endl;
                err++;
            }
        }
    }

    if (err == 0) CCS_LOG("SIMULATION PASSED !");
    else
        CCS_LOG("SIMULATION FAILED ! \n - errors " << err);

    sc_stop();
    wait();
}
