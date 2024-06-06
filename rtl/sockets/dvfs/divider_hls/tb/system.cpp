#include <iostream>
#include <stdlib.h>
#include <time.h>

#include "system.hpp"

// Process
void system_t::source()
{

    // Reset
    {
        // Avoid div by zero during C simulation
        divisor_ch.write(1);
        wait();
    }

    // Wait some time after reset
    wait(3);

    // init random seed
    srand(time(NULL));

    // init input
    for (int i = 0; i < TEST_SAMPLES; i++)
        n[i] = rand() % (1 << DIVIDEND_WIDTH);

    for (int i = 0; i < TEST_SAMPLES; i++)
        do
            d[i] = rand() % (1 << DIVISOR_WIDTH);
        while (d[i] == 0);

    // sync with sink process
    wait(3);

    for (int i = 0; i < TEST_SAMPLES; i++) {
        // Drive inputs
        dividend_ch.write(n[i]);
        divisor_ch.write(d[i]);

        // RTL latency
        wait(2);
        // Behavioral latency
        // wait();
        wait(SC_ZERO_TIME);
    }
}

void system_t::sink()
{
    // Reset
    {
        wait();
    }

    // sync with source proces
    wait(6);

    // compute golden output
    for (int i = 0; i < TEST_SAMPLES; i++)
        q[i] = n[i] / d[i];


    for (int i = 0; i < TEST_SAMPLES; i++) {

        // RTL latency
        wait(2);
        // Behavioral latency
        // wait();

        // make sure DUT process runs first in the simulator
        wait(SC_ZERO_TIME);

        sc_uint<QUOTIENT_WIDTH> tmp = quotient_ch.read();
        std::cout << n[i] << " / " << d[i] << " = " << q[i] << " *** " << tmp << std::endl;
        if (tmp != q[i]) {
            err++;
        }
    }

    std::cout << "@ " << sc_time_stamp() << ": Simulation complete --- ";
    std::cout << err << " errors" << std::endl;
    if (err)
        std::cout << "TEST FAILED!" << std::endl;

    sc_stop();
}
