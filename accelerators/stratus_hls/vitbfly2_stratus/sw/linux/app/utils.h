// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#ifndef INCLUDED_UTILS_H
#define INCLUDED_UTILS_H


//#include <ieee802-11/api.h>
//#include <ieee802-11/mapper.h>
//#include <gnuradio/config.h>
//#include <cinttypes>
//#include <iostream>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>

#define MAX_PAYLOAD_SIZE    1500
#define MAX_PSDU_SIZE       (MAX_PAYLOAD_SIZE + 28) // MAC, CRC
#define MAX_SYM             (((16 + 8 * MAX_PSDU_SIZE + 6) / 24) + 1)
#define MAX_ENCODED_BITS    ((16 + 8 * MAX_PSDU_SIZE + 6) * 2 + 288)


enum Encoding {
         BPSK_1_2  = 0,
         BPSK_3_4  = 1,
         QPSK_1_2  = 2,
         QPSK_3_4  = 3,
         QAM16_1_2 = 4,
         QAM16_3_4 = 5,
         QAM64_2_3 = 6,
         QAM64_3_4 = 7,
};

struct mac_header {
	//protocol version, type, subtype, to_ds, from_ds, ...
	uint16_t frame_control;
	uint16_t duration;
	uint8_t addr1[6];
	uint8_t addr2[6];
	uint8_t addr3[6];
	uint16_t seq_nr;
}__attribute__((packed));

/**
 * WIFI parameters
 */
typedef struct {
	//ofdm_param(Encoding e); use init_ofdm_param instead

	// data rate
	enum Encoding encoding;
	// rate field of the SIGNAL header
	char     rate_field;
	// number of coded bits per sub carrier
	int      n_bpsc;
	// number of coded bits per OFDM symbol
	int      n_cbps;
	// number of data bits per OFDM symbol
	int      n_dbps;

	//void print(ofdm_param* ofdm_param);
} ofdm_param;

/**
 * packet specific parameters
 */
typedef struct {
	//frame_param(ofdm_param &ofdm, int psdu_length); use init_frame_param isntead
	// PSDU size in bytes
	int psdu_size;
	// number of OFDM symbols (17-11)
	int n_sym;
	// number of padding bits in the DATA field (17-13)
	int n_pad;
	int n_encoded_bits;
	// number of data bits, including service and padding (17-12)
	int n_data_bits;

	//void print();
} frame_param;


#endif
