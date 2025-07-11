/* Copyright 2021 Columbia University, SLD Group */

#include "divider.hpp"

void divider_hls::beh()
{
    // Reset
    {
        // Create reset state: protocol region prevents
        // Stratus from ignoring the wait() statement
        HLS_DEFINE_PROTOCOL("reset");
        wait();
    }

    while (true) {
        HLS_CONSTRAIN_LATENCY(1, HLS_ACHIEVABLE, "divlat");
        // HLS_DPOPT_REGION("division_opt");
        // HLS_DEFINE_PROTOCOL("division");

        wait();
        dividend_t n = dividend.read();
        divisor_t d  = divisor.read();
        quotient_t q = n / d;

        // quotient_t q = 0;
        // if (d != 0)
        //     q = n / d;

        quotient.write(q);
    }
}
