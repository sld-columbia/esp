/* Copyright 2021 Columbia University, SLD Group */

#ifndef __DIVIDER_HPP__
#define __DIVIDER_HPP__

#include "utils.hpp"

class divider_hls : public sc_module
{
public:
    sc_in<bool> clk;
    sc_in<bool> rstn;
    sc_in<dividend_t> dividend;
    sc_in<divisor_t> divisor;
    sc_out<quotient_t> quotient;


    // Constructor
    SC_HAS_PROCESS(divider_hls);
    divider_hls(const sc_module_name &name)
        : sc_module(name)
        , clk("clk")
        , rstn("rstn")
        , dividend("dividend")
        , divisor("divisor")
        , quotient("quotient")
    {
        SC_CTHREAD(beh, clk.pos());
        reset_signal_is(rstn, false);
    }

    // Processes
    void beh();

};


#endif /* __DIVIDER_HPP__ */
