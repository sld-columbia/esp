/* Copyright 2019 Columbia University, SLD Group */

#ifndef __HANDSHAKE_HPP__
#define __HANDSHAKE_HPP__

#include "systemc.h"

// Forward declaration

class handshake_t;

// Handshake request

class handshake_req_t
{
    public:

        // Friend zone
        friend class handshake_t;

        // Constructor
        handshake_req_t(sc_module_name name)
          : __req(std::string(name).append("_get").c_str()) { }

        // Clock and reset binding
        template<typename CLK, typename RST>
        void clk_rst(CLK& clk, RST& rst)
          { __req.clk_rst(clk,rst); }

        // Reset method
        void reset_req()
          { __req.reset_get(); }

        // Req method
        void req()
          { __req.get(); }

    private:

        // Request channel
        b_get_initiator<bool> __req;

};

// Handshake acknowledge

class handshake_ack_t
{

    public:

        // Friend zone
        friend class handshake_t;

        // Constructor
        handshake_ack_t(sc_module_name name)
          : __ack(std::string(name).append("_put").c_str()) { }

        // Clock and reset binding
        template<typename CLK, typename RST>
        void clk_rst(CLK& clk, RST& rst)
          { __ack.clk_rst(clk,rst); }

        // Reset method
        void reset_ack()
          { __ack.reset_put(); }

        // Ack method
        void ack()
          { __ack.put(true); }

    private:

        // Ack channel
        b_put_initiator<bool> __ack;

};

// Interface

class handshake_t
{
    public:

        // Constructor
        handshake_t(sc_module_name name)
          : req(std::string(name).append("_req").c_str()),
            ack(std::string(name).append("_ack").c_str()),
            __channel(name)
        {
            req.__req.bind(__channel);
            ack.__ack.bind(__channel);
        }

        // Req and ack
        handshake_req_t req;
        handshake_ack_t ack;

    private:

        // Channel
        put_get_channel<bool> __channel;
};

#endif // __HANDSHAKE_HPP__
