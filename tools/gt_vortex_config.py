#!/usr/bin/env python3

# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

"""Helpers for the ESP GT_VORTEX integration.

These routines mirror the AXI memory tag-width path used by the current ESP
GT_VORTEX build:

- single Vortex cluster
- single external AXI bank
- ICACHE/DCACHE enabled in the ESP flow
- optional L2/L3 enables exposed by the ESP GUI
- `UUID_WIDTH` forced to 1 in `VX_define.vh`

The GUI uses these helpers to expose only configurations whose derived AXI ID
width fits ESP's third-party accelerator limit, and socket generation uses the
same logic so the generated wrapper matches Vortex's real RTL width.
"""

GT_VORTEX_DEFAULT_CORES = 1
GT_VORTEX_DEFAULT_WARPS = 4
GT_VORTEX_DEFAULT_THREADS = 4
GT_VORTEX_DEFAULT_L2_ENABLED = False
GT_VORTEX_DEFAULT_L3_ENABLED = False
GT_VORTEX_MAX_TID_WIDTH = 10

# The GUI needs a finite range for drop-down lists. Core/thread ranges are
# naturally bounded by the 10-bit AXI ID limit; warps do not affect the AXI ID
# width, so keep a practical UI cap here.
GT_VORTEX_GUI_MAX_CORES = 64
GT_VORTEX_GUI_MAX_WARPS = 64
GT_VORTEX_GUI_MAX_THREADS = 64


def _clog2(value):
    if value <= 1:
        return 0
    return (value - 1).bit_length()


def _cdiv(lhs, rhs):
    return (lhs + rhs - 1) // rhs


def _up(value):
    if value != 0:
        return value
    return 1


def _arb_sel_bits(num_inputs, num_outputs):
    if num_inputs <= num_outputs:
        return 0
    return _clog2(_cdiv(num_inputs, _up(num_outputs)))


def _as_enabled(value):
    if isinstance(value, str):
        return value.strip().lower() in ("1", "y", "yes", "true", "on")
    return bool(value)


def _cache_mem_tag_width(mshr_size, num_banks):
    return _clog2(mshr_size) + _clog2(num_banks)


def _cache_bypass_tag_width(num_reqs, line_size, word_size, tag_width):
    return _clog2(num_reqs) + _clog2(line_size // word_size) + tag_width


def _cache_nc_mem_tag_width(
        mshr_size,
        num_banks,
        num_reqs,
        line_size,
        word_size,
        tag_width):
    return max(
        _cache_mem_tag_width(mshr_size, num_banks),
        _cache_bypass_tag_width(num_reqs, line_size, word_size, tag_width)) + 1


def gt_vortex_xlen_bits(cpu_arch):
    if str(cpu_arch).lower() == "ibex":
        return 32
    return 64


def gt_vortex_supported_core_count(num_cores):
    return num_cores > 0 and (num_cores <= 4 or num_cores % 4 == 0)


def gt_vortex_supported_thread_count(num_threads):
    return num_threads > 0 and min(num_threads, 4) in (1, 2, 4)


def gt_vortex_supported_warp_count(num_warps):
    return num_warps > 0


def gt_vortex_core_candidates(max_cores=GT_VORTEX_GUI_MAX_CORES):
    return [
        num_cores for num_cores in range(1, max_cores + 1)
        if gt_vortex_supported_core_count(num_cores)
    ]


def gt_vortex_warp_candidates(max_warps=GT_VORTEX_GUI_MAX_WARPS):
    return list(range(1, max_warps + 1))


def gt_vortex_thread_candidates(max_threads=GT_VORTEX_GUI_MAX_THREADS):
    return [
        num_threads for num_threads in range(1, max_threads + 1)
        if gt_vortex_supported_thread_count(num_threads)
    ]


def gt_vortex_tid_width(
        num_cores,
        num_warps,
        num_threads,
        xlen_bits=64,
        l2_enabled=GT_VORTEX_DEFAULT_L2_ENABLED,
        l3_enabled=GT_VORTEX_DEFAULT_L3_ENABLED):
    del num_warps

    if not gt_vortex_supported_core_count(num_cores):
        raise ValueError(
            "GT_VORTEX NUM_CORES must be 1-4 or a positive multiple of 4")
    if not gt_vortex_supported_thread_count(num_threads):
        raise ValueError(
            "GT_VORTEX NUM_THREADS must be positive and cannot be 3")
    if xlen_bits not in (32, 64):
        raise ValueError("GT_VORTEX XLEN must be either 32 or 64")

    mem_block_size = 8
    l1_line_size = mem_block_size
    l2_line_size = mem_block_size
    l3_line_size = mem_block_size
    uuid_width = 1
    num_clusters = 1
    l2_enabled = _as_enabled(l2_enabled)
    l3_enabled = _as_enabled(l3_enabled)

    socket_size = min(4, num_cores)
    num_sockets = _up(num_cores // socket_size)

    icache_mshr_size = 16
    num_icaches = _up(socket_size // 4)
    icache_mem_tag_width = _cache_mem_tag_width(icache_mshr_size, 1) + _arb_sel_bits(
        _up(num_icaches), 1)

    num_lsu_lanes = num_threads
    lsu_word_size = xlen_bits // 8
    lsu_line_size = min(num_lsu_lanes * lsu_word_size, l1_line_size)
    dcache_word_size = lsu_line_size
    dcache_channels = _up((num_lsu_lanes * lsu_word_size) // dcache_word_size)
    dcache_num_reqs = dcache_channels
    dcache_merged_reqs = (num_lsu_lanes * lsu_word_size) // dcache_word_size
    dcache_mem_batches = _cdiv(dcache_merged_reqs, dcache_channels)

    lsuq_in_size = 2 * (num_threads // num_lsu_lanes)
    lsuq_out_size = max(lsuq_in_size, lsu_line_size // lsu_word_size)
    dcache_tag_id_bits = _clog2(lsuq_out_size) + _clog2(dcache_mem_batches)
    dcache_tag_width = uuid_width + dcache_tag_id_bits

    num_dcaches = _up(socket_size // 4)
    dcache_num_banks = min(num_lsu_lanes, 4)
    if dcache_num_banks not in (1, 2, 4):
        raise ValueError(
            "GT_VORTEX NUM_THREADS drives an unsupported DCACHE bank count")

    dcache_core_tag_width = dcache_tag_width + _arb_sel_bits(
        socket_size, _up(num_dcaches))
    dcache_cache_mem_tag_width = _clog2(16) + _clog2(dcache_num_banks)
    dcache_bypass_tag_width = _clog2(dcache_num_reqs) + _clog2(
        l1_line_size // dcache_word_size) + dcache_core_tag_width
    dcache_mem_tag_width = max(
        dcache_cache_mem_tag_width, dcache_bypass_tag_width) + 1

    l1_mem_tag_width = max(icache_mem_tag_width, dcache_mem_tag_width)
    l1_mem_arb_tag_width = l1_mem_tag_width + _clog2(2)

    l2_num_reqs = num_sockets
    l2_num_banks = min(4, num_sockets)
    l2_tag_width = l1_mem_arb_tag_width
    l2_word_size = l1_line_size
    if l2_enabled:
        l2_mem_tag_width = _cache_nc_mem_tag_width(
            16,
            l2_num_banks,
            l2_num_reqs,
            l2_line_size,
            l2_word_size,
            l2_tag_width)
    else:
        l2_mem_tag_width = _cache_bypass_tag_width(
            l2_num_reqs,
            l2_line_size,
            l2_word_size,
            l2_tag_width)

    l3_num_reqs = num_clusters
    l3_num_banks = min(4, num_clusters)
    l3_tag_width = l2_mem_tag_width
    l3_word_size = l2_line_size
    if l3_enabled:
        l3_mem_tag_width = _cache_nc_mem_tag_width(
            16,
            l3_num_banks,
            l3_num_reqs,
            l3_line_size,
            l3_word_size,
            l3_tag_width)
    else:
        l3_mem_tag_width = _cache_bypass_tag_width(
            l3_num_reqs,
            l3_line_size,
            l3_word_size,
            l3_tag_width)

    return l3_mem_tag_width


def gt_vortex_is_compatible(
        num_cores,
        num_warps,
        num_threads,
        xlen_bits=64,
        max_tid_width=GT_VORTEX_MAX_TID_WIDTH,
        l2_enabled=GT_VORTEX_DEFAULT_L2_ENABLED,
        l3_enabled=GT_VORTEX_DEFAULT_L3_ENABLED):
    if not gt_vortex_supported_warp_count(num_warps):
        return False
    try:
        return gt_vortex_tid_width(
            num_cores,
            num_warps,
            num_threads,
            xlen_bits,
            l2_enabled=l2_enabled,
            l3_enabled=l3_enabled) <= max_tid_width
    except ValueError:
        return False


def gt_vortex_compatible_core_choices(
        num_warps,
        num_threads,
        xlen_bits=64,
        max_tid_width=GT_VORTEX_MAX_TID_WIDTH,
        l2_enabled=GT_VORTEX_DEFAULT_L2_ENABLED,
        l3_enabled=GT_VORTEX_DEFAULT_L3_ENABLED):
    return [
        num_cores for num_cores in gt_vortex_core_candidates()
        if gt_vortex_is_compatible(
            num_cores,
            num_warps,
            num_threads,
            xlen_bits,
            max_tid_width,
            l2_enabled=l2_enabled,
            l3_enabled=l3_enabled)
    ]


def gt_vortex_compatible_thread_choices(
        num_cores,
        num_warps,
        xlen_bits=64,
        max_tid_width=GT_VORTEX_MAX_TID_WIDTH,
        l2_enabled=GT_VORTEX_DEFAULT_L2_ENABLED,
        l3_enabled=GT_VORTEX_DEFAULT_L3_ENABLED):
    return [
        num_threads for num_threads in gt_vortex_thread_candidates()
        if gt_vortex_is_compatible(
            num_cores,
            num_warps,
            num_threads,
            xlen_bits,
            max_tid_width,
            l2_enabled=l2_enabled,
            l3_enabled=l3_enabled)
    ]


def gt_vortex_compatible_pairs(
        num_warps,
        xlen_bits=64,
        max_tid_width=GT_VORTEX_MAX_TID_WIDTH,
        l2_enabled=GT_VORTEX_DEFAULT_L2_ENABLED,
        l3_enabled=GT_VORTEX_DEFAULT_L3_ENABLED):
    pairs = []
    for num_cores in gt_vortex_core_candidates():
        for num_threads in gt_vortex_thread_candidates():
            if gt_vortex_is_compatible(
                    num_cores,
                    num_warps,
                    num_threads,
                    xlen_bits,
                    max_tid_width,
                    l2_enabled=l2_enabled,
                    l3_enabled=l3_enabled):
                pairs.append((num_cores, num_threads))
    return pairs
