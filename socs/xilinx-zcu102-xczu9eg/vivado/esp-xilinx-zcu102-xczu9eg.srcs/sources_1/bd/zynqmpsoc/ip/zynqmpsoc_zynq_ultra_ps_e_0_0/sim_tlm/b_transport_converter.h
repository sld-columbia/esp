// (c) Copyright(C) 2013 - 2018 by Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.

#ifndef _B_TRANSPORT_CONVERTER_H_
#define _B_TRANSPORT_CONVERTER_H_

#include <systemc>
#include "tlm_utils/simple_target_socket.h"
#include "tlm_utils/simple_initiator_socket.h"
#include <utility>
#include <vector>

template<int IN_WIDTH, int OUT_WIDTH>
class b_transport_converter: public sc_core::sc_module 
{
    enum TLM_IF_TYPE
    {
        B_TRANSPORT = 0,
        NB_TRANSPORT,
        TRANSPORT_DBG,
        DMI_IF,
        INVALID_IF
    };
    typedef std::vector<std::pair<sc_dt::uint64, sc_dt::uint64>> addr_range_list;

    public:
        SC_HAS_PROCESS(b_transport_converter);
        b_transport_converter<IN_WIDTH, OUT_WIDTH>(sc_core::sc_module_name name): 
            sc_module(name)
    {
        target_socket.register_b_transport(
                this, &b_transport_converter<IN_WIDTH, OUT_WIDTH>::b_transport);
        initiator_socket.register_nb_transport_bw(
                this, &b_transport_converter<IN_WIDTH, OUT_WIDTH>::nb_transport_bw);

    }

        //simple tlm target/initiator socket...
        tlm_utils::simple_target_socket<b_transport_converter<IN_WIDTH, OUT_WIDTH>, IN_WIDTH>    target_socket;
        tlm_utils::simple_initiator_socket<b_transport_converter<IN_WIDTH, OUT_WIDTH>, OUT_WIDTH> initiator_socket;


    public:
        void b_transport(tlm::tlm_generic_payload& payload, sc_core::sc_time& time)
        {
            tlm::tlm_phase phase = tlm::BEGIN_REQ; //for nb_transport_fw
            switch(get_tlm_if_type(payload.get_address()))
            {
                case B_TRANSPORT:
                    initiator_socket->b_transport(payload, time);
                    break;

                case NB_TRANSPORT:
                    initiator_socket->nb_transport_fw(payload, phase, time);
                    wait(resp_complete_event); //! Wait for the response to complete
                    break;

                case TRANSPORT_DBG:
                    initiator_socket->transport_dbg(payload);
                    break;

                case DMI_IF:
                    break;

                default:
                    SC_REPORT_ERROR(this->name(), "Address not mapped to any of the TLM IF type");
            }
        }

        tlm::tlm_sync_enum
            nb_transport_bw(tlm::tlm_generic_payload& payload, 
                    tlm::tlm_phase& phase, sc_core::sc_time& time)
            {
                if(phase == tlm::BEGIN_RESP) {
                    resp_complete_event.notify();
                    phase = tlm::END_RESP;
                    return tlm::TLM_UPDATED;
                }
                return tlm::TLM_ACCEPTED;
            }

    private:
        TLM_IF_TYPE get_tlm_if_type(unsigned long long address)
        {
            //check for b_transport addresses
            for(auto& addr_range: m_b_transport_addr_list) {
                if(address >= addr_range.first && address < addr_range.second) {
                    return B_TRANSPORT;
                }
            }

            //check for nb_transport addresses
            for(auto& addr_range: m_nb_transport_addr_list) {
                if(address >= addr_range.first && address < addr_range.second) {
                    return NB_TRANSPORT;
                }
            }
            //check for dbg_transport addresses
            for(auto& addr_range: m_dbg_transport_addr_list) {
                if(address >= addr_range.first && address < addr_range.second) {
                    return TRANSPORT_DBG;
                }
            }

            //By default return NB_TRANSPORT
            return NB_TRANSPORT;
        }

        //Start and End Address List for each of interfaces...
        static addr_range_list  m_b_transport_addr_list;
        static addr_range_list  m_nb_transport_addr_list;
        static addr_range_list  m_dbg_transport_addr_list;

        //event to notify completion of transaction
        sc_core::sc_event  resp_complete_event;
};

template<int IN_WIDTH, int OUT_WIDTH>
typename b_transport_converter<IN_WIDTH,OUT_WIDTH>::addr_range_list b_transport_converter<IN_WIDTH,OUT_WIDTH>::m_b_transport_addr_list = {std::make_pair(0x0, 0x0)};
template<int IN_WIDTH, int OUT_WIDTH>
typename b_transport_converter<IN_WIDTH,OUT_WIDTH>::addr_range_list b_transport_converter<IN_WIDTH,OUT_WIDTH>::m_nb_transport_addr_list = {std::make_pair(0, 0)};
template<int IN_WIDTH, int OUT_WIDTH>
typename b_transport_converter<IN_WIDTH,OUT_WIDTH>::addr_range_list b_transport_converter<IN_WIDTH,OUT_WIDTH>::m_dbg_transport_addr_list = {std::make_pair(0, 0)};


#endif /* _B_TRANSPORT_CONVERTER_H_ */

