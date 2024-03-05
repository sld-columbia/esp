#include "gcm.h"

//#include "enc.cpp"
//#include "dec.cpp"

#ifdef __MENTOR_CATAPULT_HLS__
#include <ac_int.h>

template<typename T>
void memset(T *ptr, int value, size_t num)
{
MEMSET_L_1:
    for (size_t i = 0; i < num / 4/*sizeof(uint32)*/; i++)
        ptr[i] = value;
}

#endif // __MENTOR_CATAPULT_HLS__

/* Galois/Counter Mode */

#ifdef __MENTOR_CATAPULT_HLS__
void gf_inner(ac_int<128, false> &_v,
              ac_int<128, false> &_z,
              uint32 x)
{
    ac_int<128, false> R = ac_int<128, false>(225) << 120;
#else
void gf_inner(ap_uint<128> &_v,
              ap_uint<128> &_z,
              uint32 x)
{
    ap_uint<128> R = ap_uint<128>("e1", 16) << 120;
#endif

GF_MULT_L_3_1:
        for (unsigned j = 0; j < 32; ++j)
        {
            #pragma HLS unroll complete

#ifdef __MENTOR_CATAPULT_HLS__
            bool bit = _v[0];
#else
            bool bit = _v[0].to_bool();
#endif

            if (x & BIT(31 - j))
                _z ^= _v;

            _v >>= 1;

            if (bit)
                _v ^= R;
        }
}

void gf_mult(uint32 x[AES_BLOCK_WORDS],
             uint32 y[AES_BLOCK_WORDS],
             uint32 z[AES_BLOCK_WORDS])
{
    #pragma HLS inline

#ifdef C_SIMULATION

    // Simulation only

    uint32 v[AES_BLOCK_WORDS];

GF_MULT_L_1:
    for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
    {
        v[k] = y[k];
        z[k] = 0;
    }

GF_MULT_L_2:
    for (unsigned i = 0; i < AES_BLOCK_WORDS; i++)
    {
GF_MULT_L_2_1:
        for (unsigned j = 0; j < 32; j++)
        {
            bool bit = v[3] & 0x01;

            if (x[i] & BIT(31 - j))
GF_MULT_L_2_1_1:
                for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
                    z[k] ^= v[k];

            shiftr(v);

            if (bit)
            {
			    uint32 tmp = (uint32) (v[0] >> 24) ^ 0xe1;
		        v[0] = (v[0] & 0x00FFFFFF) | (tmp << 24);
			}
        }
    }

#else /* !C_SIMULATION */

    // Synthesis only

#ifdef __MENTOR_CATAPULT_HLS__
    ac_int<128, false> _v = 0;
    ac_int<128, false> _z = 0;
    /* ac_int<128, false> R = ac_int<128, false>(225) << 120; */

    _v.set_slc(0, ac_int<32, false>(y[3]));
    _v.set_slc(32, ac_int<32, false>(y[2]));
    _v.set_slc(64, ac_int<32, false>(y[1]));
    _v.set_slc(96, ac_int<32, false>(y[0]));
#else
    ap_uint<128> _v = 0;
    ap_uint<128> _z = 0;
    /* ap_uint<128> R = ap_uint<128>("e1", 16) << 120; */

    _v.range( 31, 0)  = y[3];
    _v.range( 63, 32) = y[2];
    _v.range( 95, 64) = y[1];
    _v.range(127, 96) = y[0];
#endif
GF_MULT_L_3:
    for (unsigned i = 0; i < AES_BLOCK_WORDS; ++i)
    {
        #pragma HLS unroll complete

        gf_inner(_v, _z, x[i]);
    }

#ifdef __MENTOR_CATAPULT_HLS__
    z[3] = _z.slc<32>(0);
    z[2] = _z.slc<32>(32);
    z[1] = _z.slc<32>(64);
    z[0] = _z.slc<32>(96);
#else
    z[3] = _z.range( 31, 0);
    z[2] = _z.range( 63, 32);
    z[1] = _z.range( 95, 64);
    z[0] = _z.range(127, 96);
#endif

#endif /* C_SIMULATION */
}

void ghash(uint32 h[AES_BLOCK_WORDS],
           uint32 x[AES_BLOCK_WORDS],
           uint32 y[AES_BLOCK_WORDS])
{
    #pragma HLS inline off

GHASH_L_1:
    for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
    {
        #pragma HLS unroll complete

        y[k] = y[k] ^ x[k];
    }

    gf_mult(y, h, x);

GHASH_L_2:
    for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
    {
        #pragma HLS unroll complete

        y[k] = x[k];
    }
}

void gcm_init(uint32 key_bytes,
              uint32 iv_bytes,
              uint32 aad_bytes,
              uint32 ekey[AES_EXP_KEY_SIZE],
              uint32 iv[AES_MAX_IV_WORDS],
              uint32 aad[AES_MAX_IN_WORDS],
              uint32 S[AES_BLOCK_WORDS],
              uint32 H[AES_BLOCK_WORDS],
              uint32 L[AES_BLOCK_WORDS],
              uint32 J[AES_BLOCK_WORDS])
{
    #pragma HLS inline

    uint32 LL[AES_BLOCK_WORDS] = { 0 };
    uint32 tmp[AES_BLOCK_WORDS] = { 0 };

    #pragma HLS array_partition variable=LL complete
    #pragma HLS array_partition variable=tmp complete

    aes_encrypt(key_bytes, tmp, H, ekey);

    if (iv_bytes == 12)
    {
GCM_INIT_L_1:
        for (unsigned k = 0; k < AES_BLOCK_WORDS - 1; ++k)
        {
            #pragma HLS pipeline II=1

            J[k] = iv[k];
        }

        J[AES_BLOCK_WORDS - 1] = 0x01 << 24U;

GCM_INIT_L_2:
		for (unsigned k = 0; k < AES_BLOCK_WORDS;++k)
		{
            #pragma HLS unroll complete

            J[k] = AES_SWAP(J[k]);
		}
    }
    else
    {
GCM_INIT_L_3:
        for (unsigned i = 0; i < iv_bytes; i += AES_BLOCK_BYTES)
        {
            /* Considering an aad of 16 bytes. */
            #pragma HLS loop_tripcount max=1
            #pragma HLS pipeline II=20

GCM_INIT_L_3_1:
            for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
            {
                #pragma HLS unroll complete

                tmp[k] = (i + (k << 2) < iv_bytes) ?
                     iv[(i >> 2) + k] : uint32(0);
            }

GCM_INIT_L_3_2:
            for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
            {
                #pragma HLS unroll complete

                tmp[k] = AES_SWAP(tmp[k]);
            }

            ghash(H, tmp, J);
        }

        LL[2] = iv_bytes >> 29;
        LL[3] = iv_bytes << 3;
        ghash(H, LL, J);
	}

GCM_INIT_L_4:
    for (unsigned i = 0; i < aad_bytes; i += AES_BLOCK_BYTES)
    {
        /* Considering an aad of 64 bytes. */
        #pragma HLS loop_tripcount max=4
        #pragma HLS pipeline II=20

GCM_INIT_L_4_1:
        for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
        {
            #pragma HLS unroll complete

            tmp[k] = (i + (k << 2) < aad_bytes) ?
                 aad[(i >> 2) + k] : uint32(0);
        }

GCM_INIT_L_4_2:
        for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
        {
            #pragma HLS unroll complete

            tmp[k] = AES_SWAP(tmp[k]);
        }

        ghash(H, tmp, S);
    }

    L[1] = aad_bytes << 3;
}

void gcm_core(uint32 encryption,
              uint32 key_bytes,
              uint32 input_bytes,
              uint32 total_blocks,
              uint32 in[AES_MAX_IN_WORDS],
              uint32 out[AES_MAX_IN_WORDS],
              uint32 ekey[AES_EXP_KEY_SIZE],
              uint32 cb[AES_BLOCK_WORDS],
              uint32 S[AES_BLOCK_BYTES],
              uint32 H[AES_BLOCK_BYTES],
              uint32 J[AES_BLOCK_BYTES],
              uint32 T[AES_BLOCK_BYTES])
{
    #pragma HLS inline

    uint32 in_tmp[AES_BLOCK_WORDS];
    uint32 out_tmp[AES_BLOCK_WORDS];
    uint32 hash_tmp[AES_BLOCK_WORDS];

    unsigned j = (input_bytes >> 4) << 2;
    uint32 rem_bytes = AES_WORDS((input_bytes - (j << 2)));
    uint32 clear_bits = ((rem_bytes << 2) - input_bytes) << 3;

    #pragma HLS array_partition variable=in_tmp complete
    #pragma HLS array_partition variable=out_tmp complete
    #pragma HLS array_partition variable=hash_tmp complete

    if (total_blocks == 0)
    {
GCM_CORE_L_1:
        for (unsigned i = 0; i < AES_BLOCK_WORDS; ++i)
        {
            #pragma HLS unroll complete

            cb[i] = J[i];
        }
    }

GCM_CORE_L_2:
    for (unsigned i = 0; i < input_bytes; i += AES_BLOCK_BYTES)
    {
        /* Considering an input of 65536 bytes. */
        #pragma HLS loop_tripcount min=1 max=4096
        #pragma HLS pipeline II=20

        incr(cb);

GCM_CORE_L_2_1:
        for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
        {
            #pragma HLS unroll complete

            if (i + (k << 2) < input_bytes)
                in_tmp[k] = in[(i >> 2) + k];
        }

        aes_encrypt(key_bytes, cb, out_tmp, ekey);

GCM_CORE_L_2_2:
        for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
        {
            #pragma HLS unroll complete

            out_tmp[k] = AES_SWAP(out_tmp[k]);
        }

GCM_CORE_L_2_3:
    	for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
    	{
            #pragma HLS unroll complete

    		out_tmp[k] = out_tmp[k] ^ in_tmp[k];
        }

GCM_CORE_L_2_4:
    	for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
    	{
            #pragma HLS unroll complete

            if (i + (k << 2) < input_bytes)
                out[(i >> 2) + k] = out_tmp[k];
        }

GCM_CORE_L_2_5:
        for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
        {
            #pragma HLS unroll complete

            hash_tmp[k] = (i + (k << 2) < input_bytes) ?
                ((encryption == AES_DECRYPTION_MODE) ?
                 in_tmp[k] : out_tmp[k]) : uint32(0);
        }

GCM_CORE_L_2_6:
        for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
        {
            #pragma HLS unroll complete

            hash_tmp[k] = AES_SWAP(hash_tmp[k]);
        }

        if (i + AES_BLOCK_BYTES > input_bytes)
        {
            hash_tmp[rem_bytes - 1] >>= clear_bits;
            hash_tmp[rem_bytes - 1] <<= clear_bits;
        }

        ghash(H, hash_tmp, S);
    }

GCM_CORE_L_3:
    for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
    {
        #pragma HLS unroll complete

        in_tmp[k] = J[k];
    }

    aes_encrypt(key_bytes, in_tmp, T, ekey);
}

uint32 gcm_final(uint32 encryption,
                   uint32 tag_bytes,
                   uint32 total_bytes,
                   uint32 tag[AES_MAX_IN_WORDS],
                   uint32 S[AES_BLOCK_BYTES],
                   uint32 H[AES_BLOCK_BYTES],
                   uint32 L[AES_BLOCK_BYTES],
                   uint32 T[AES_BLOCK_BYTES])
{
    #pragma HLS inline

    uint32 check = 0;

    L[2] = total_bytes >> 29;
    L[3] = total_bytes << 3;
    ghash(H, L, S);

GCM_FINAL_L_1:
    for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
    {
        #pragma HLS unroll complete

        T[k] = T[k] ^ S[k];
    }

GCM_FINAL_L_2:
    for (unsigned k = 0; k < AES_BLOCK_WORDS; ++k)
    {
        #pragma HLS unroll complete

        T[k] = AES_SWAP(T[k]);
    }

    if (encryption == AES_DECRYPTION_MODE)
    {
GCM_FINAL_L_3:
        for (unsigned k = 0; k < tag_bytes >> 2; ++k)
        {
            #pragma HLS loop_tripcount max=16

            if (tag[k] != T[k])
                check = 1;
        }
    }
    else if (encryption == AES_ENCRYPTION_MODE)
    {
GCM_FINAL_L_4:
        for (unsigned k = 0; k < AES_WORDS(tag_bytes); ++k)
        {
            #pragma HLS loop_tripcount max=16

            tag[k] = T[k];
        }
    }

    return check;
}

int aes_gcm_cipher(uint32 encryption,
                   uint32 key_bytes,
                   uint32 input_bytes,
                   uint32 iv_bytes,
                   uint32 aad_bytes,
                   uint32 tag_bytes,
                   uint32 ekey[AES_EXP_KEY_SIZE],
                   uint32 iv[AES_MAX_IV_WORDS],
                   uint32 in[AES_MAX_IN_WORDS],
                   uint32 out[AES_MAX_IN_WORDS],
                   uint32 aad[AES_MAX_IN_WORDS],
                   uint32 tag[AES_MAX_IN_WORDS])
{
    #pragma HLS inline

    int check = 0;
    static bool init_done = false;
	static uint32 total_bytes = 0;
	static uint32 total_blocks = 0;
    static uint32 cb[AES_BLOCK_WORDS] = { 0 };
    static uint32 S[AES_BLOCK_WORDS] = { 0 };
    static uint32 H[AES_BLOCK_WORDS] = { 0 };
    static uint32 L[AES_BLOCK_WORDS] = { 0 };
    static uint32 J[AES_BLOCK_WORDS] = { 0 };
    static uint32 T[AES_BLOCK_WORDS] = { 0 };

    #pragma HLS array_partition variable=cb complete
    #pragma HLS array_partition variable=S complete
    #pragma HLS array_partition variable=H complete
    #pragma HLS array_partition variable=L complete
    #pragma HLS array_partition variable=J complete
    #pragma HLS array_partition variable=T complete

    if (!init_done)
    {
        gcm_init(key_bytes, iv_bytes, aad_bytes,
                ekey, iv, aad, S, H, L, J);
        init_done = true;
	}

    if (tag_bytes == 0)
    {
        gcm_core(encryption, key_bytes, input_bytes,
                total_blocks, in, out, ekey, cb, S, H, J, T);

        total_blocks += input_bytes >> AES_BLOCK_BYTES_LOG;
        total_bytes += input_bytes;
    }
    else // tag_bytes != 0
    {
        check = gcm_final(encryption, tag_bytes,
                total_bytes, tag, S, H, L, T);

        init_done = false;
        total_blocks = 0;
        total_bytes = 0;
        memset(cb, 0, AES_BLOCK_WORDS * sizeof(uint32));
        memset(S, 0, AES_BLOCK_WORDS * sizeof(uint32));
        memset(H, 0, AES_BLOCK_WORDS * sizeof(uint32));
        memset(L, 0, AES_BLOCK_WORDS * sizeof(uint32));
        memset(J, 0, AES_BLOCK_WORDS * sizeof(uint32));
        memset(T, 0, AES_BLOCK_WORDS * sizeof(uint32));
    }

    return check;
}
