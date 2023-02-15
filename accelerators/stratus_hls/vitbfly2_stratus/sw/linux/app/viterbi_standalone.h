// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef INCLUDED_VITERBI_STANDALONE_H
#define INCLUDED_VITERBI_STANDALONE_H

#include "utils.h"

extern ofdm_param ofdm;
extern frame_param frame;

extern uint8_t deinterleaved_bits[MAX_ENCODED_BITS];
extern uint8_t DECODER_VERIF_DATA[7000][4][64];

extern uint8_t result[MAX_ENCODED_BITS]; // This is generous; only need 12264 entries?	

void decode_wrapper();

#endif
