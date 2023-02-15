// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

// Optional application-specific helper functions
void vitbfly2::viterbi_butterfly2_generic()
{
    // These are used to "virtually" rename the uses below (for symmetry; reduces code size)
    //  Really these are functionally "offset pointers" into the above arrays....
    unsigned char *metric0, *metric1;
    unsigned char *path0, *path1;

    // Operate on 4 symbols (2 bits) at a time

    unsigned char m0[16], m1[16], m2[16], m3[16], decision0[16], decision1[16], survivor0[16], survivor1[16];
    unsigned char metsv[16], metsvm[16];
    unsigned char shift0[16], shift1[16];
    unsigned char tmp0[16], tmp1[16];
    unsigned char sym0v[16], sym1v[16];
    unsigned short simd_epi16;
    unsigned int   first_symbol;
    unsigned int   second_symbol;

    // Set up for the first two symbols (0 and 1)
    metric0 = mm0;
    path0 = pp0;
    metric1 = mm1;
    path1 = pp1;
    first_symbol = 0;
    second_symbol = first_symbol+1;
    for (int j = 0; j < 16; j++) {
        sym0v[j] = symbols[first_symbol];
        sym1v[j] = symbols[second_symbol];
    }

    for (int s = 0; s < 2; s++) { // iterate across the 2 symbol groups
        // This is the basic viterbi butterfly for 2 symbols (we need therefore 2 passes for 4 total symbols)
        for (int i = 0; i < 2; i++) {
            if (symbols[first_symbol] == 2) {
                for (int j = 0; j < 16; j++) {
                    //metsvm[j] = d_branchtab27_generic[1].c[(i*16) + j] ^ sym1v[j];
                    metsvm[j] = d_brtab27[1][(i*16) + j] ^ sym1v[j];
                    metsv[j] = 1 - metsvm[j];
                }
            }
            else if (symbols[second_symbol] == 2) {
                for (int j = 0; j < 16; j++) {
                    //metsvm[j] = d_branchtab27_generic[0].c[(i*16) + j] ^ sym0v[j];
                    metsvm[j] = d_brtab27[0][(i*16) + j] ^ sym0v[j];
                    metsv[j] = 1 - metsvm[j];
                }
            }
            else {
                for (int j = 0; j < 16; j++) {
                    //metsvm[j] = (d_branchtab27_generic[0].c[(i*16) + j] ^ sym0v[j]) + (d_branchtab27_generic[1].c[(i*16) + j] ^ sym1v[j]);
                    metsvm[j] = (d_brtab27[0][(i*16) + j] ^ sym0v[j]) + (d_brtab27[1][(i*16) + j] ^ sym1v[j]);
                    metsv[j] = 2 - metsvm[j];
                }
            }

            for (int j = 0; j < 16; j++) {
                m0[j] = metric0[(i*16) + j] + metsv[j];
                m1[j] = metric0[((i+2)*16) + j] + metsvm[j];
                m2[j] = metric0[(i*16) + j] + metsvm[j];
                m3[j] = metric0[((i+2)*16) + j] + metsv[j];
            }

            for (int j = 0; j < 16; j++) {
                decision0[j] = ((m0[j] - m1[j]) > 0) ? 0xff : 0x0;
                decision1[j] = ((m2[j] - m3[j]) > 0) ? 0xff : 0x0;
                survivor0[j] = (decision0[j] & m0[j]) | ((~decision0[j]) & m1[j]);
                survivor1[j] = (decision1[j] & m2[j]) | ((~decision1[j]) & m3[j]);
            }

            for (int j = 0; j < 16; j += 2) {
                simd_epi16 = path0[(i*16) + j];
                simd_epi16 |= path0[(i*16) + (j+1)] << 8;
                simd_epi16 <<= 1;
                shift0[j] = simd_epi16;
                shift0[j+1] = simd_epi16 >> 8;

                simd_epi16 = path0[((i+2)*16) + j];
                simd_epi16 |= path0[((i+2)*16) + (j+1)] << 8;
                simd_epi16 <<= 1;
                shift1[j] = simd_epi16;
                shift1[j+1] = simd_epi16 >> 8;
            }
            for (int j = 0; j < 16; j++) {
                shift1[j] = shift1[j] + 1;
            }

            for (int j = 0, k = 0; j < 16; j += 2, k++) {
                metric1[(2*i*16) + j] = survivor0[k];
                metric1[(2*i*16) + (j+1)] = survivor1[k];
            }
            for (int j = 0; j < 16; j++) {
                tmp0[j] = (decision0[j] & shift0[j]) | ((~decision0[j]) & shift1[j]);
            }

            for (int j = 0, k = 8; j < 16; j += 2, k++) {
                metric1[((2*i+1)*16) + j] = survivor0[k];
                metric1[((2*i+1)*16) + (j+1)] = survivor1[k];
            }
            for (int j = 0; j < 16; j++) {
                tmp1[j] = (decision1[j] & shift0[j]) | ((~decision1[j]) & shift1[j]);
            }

            for (int j = 0, k = 0; j < 16; j += 2, k++) {
                path1[(2*i*16) + j] = tmp0[k];
                path1[(2*i*16) + (j+1)] = tmp1[k];
            }
            for (int j = 0, k = 8; j < 16; j += 2, k++) {
                path1[((2*i+1)*16) + j] = tmp0[k];
                path1[((2*i+1)*16) + (j+1)] = tmp1[k];
            }
        }

        // Set up for the second two symbols (2 and 3)
        metric0 = mm1;
        path0 = pp1;
        metric1 = mm0;
        path1 = pp0;
        first_symbol = 2;
        second_symbol = first_symbol+1;
        for (int j = 0; j < 16; j++) {
            sym0v[j] = symbols[first_symbol];
            sym1v[j] = symbols[second_symbol];
        }
    }
}
