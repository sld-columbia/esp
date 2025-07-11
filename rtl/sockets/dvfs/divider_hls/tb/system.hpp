#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include "divider.hpp"
#include "divider_wrap.h"

#define TEST_SAMPLES 10

class system_t : public sc_module {
  public:
    sc_in<bool> clk;
    sc_in<bool> rstn;

    sc_signal<dividend_t> dividend_ch;
    sc_signal<divisor_t> divisor_ch;
    sc_signal<quotient_t> quotient_ch;

    divider_hls_wrapper *dut;

    // Constructor
    SC_HAS_PROCESS(system_t);
    system_t(sc_module_name name) :
        sc_module(name), err(0), dividend_ch("dividend_ch"), divisor_ch("divisor_ch"),
        quotient_ch("quotient_ch")
    {
        SC_CTHREAD(source, clk.pos());
        reset_signal_is(rstn, false);
        SC_CTHREAD(sink, clk.pos());
        reset_signal_is(rstn, false);

        dut = new divider_hls_wrapper("divider_hls_wrapper");

        dut->clk(clk);
        dut->rstn(rstn);
        dut->dividend(dividend_ch);
        dut->divisor(divisor_ch);
        dut->quotient(quotient_ch);
    }

    void source();
    void sink();

    sc_uint<DIVIDEND_WIDTH> n[TEST_SAMPLES];
    sc_uint<DIVISOR_WIDTH> d[TEST_SAMPLES];
    sc_uint<QUOTIENT_WIDTH> q[TEST_SAMPLES];

    int err;
};

#endif // __SYSTEM_HPP__
