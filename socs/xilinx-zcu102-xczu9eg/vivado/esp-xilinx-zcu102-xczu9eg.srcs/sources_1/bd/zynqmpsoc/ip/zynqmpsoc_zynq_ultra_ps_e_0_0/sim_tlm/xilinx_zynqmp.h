/*
 Xilinx SystemC/TLM-2.0 ZynqMP Wrapper.

 Written by Edgar E. Iglesias <edgar.iglesias@xilinx.com>

 Copyright (c) 2016, Xilinx Inc.
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the <organization> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */

#include "systemc.h"

#include "tlm_utils/simple_initiator_socket.h"
#include "tlm_utils/simple_target_socket.h"
#include "tlm_utils/tlm_quantumkeeper.h"

#include "remote_port_tlm.h"
#include "remote_port_tlm_memory_master.h"
#include "remote_port_tlm_memory_slave.h"
#include "remote_port_tlm_wires.h"
#include "wire_splitter.h"

class xilinx_emio_bank
{
private:
public:
	sc_vector<sc_signal<bool> > in;
	sc_vector<sc_signal<bool> > out;
	sc_vector<sc_signal<bool> > out_enable;
	xilinx_emio_bank(const char *name_in, const char *name_out,
		         const char *name_out_en, int num);
};

class xilinx_zynqmp
: public remoteport_tlm
{
private:
	remoteport_tlm_memory_master rp_axi_hpm0_fpd;
	remoteport_tlm_memory_master rp_axi_hpm1_fpd;
	remoteport_tlm_memory_master rp_axi_hpm_lpd;
	remoteport_tlm_memory_master rp_lpd_reserved;

	remoteport_tlm_memory_slave rp_axi_hpc0_fpd;
	remoteport_tlm_memory_slave rp_axi_hpc1_fpd;
	remoteport_tlm_memory_slave rp_axi_hp0_fpd;
	remoteport_tlm_memory_slave rp_axi_hp1_fpd;
	remoteport_tlm_memory_slave rp_axi_hp2_fpd;
	remoteport_tlm_memory_slave rp_axi_hp3_fpd;
	remoteport_tlm_memory_slave rp_axi_lpd;
	remoteport_tlm_memory_slave rp_axi_acp_fpd;
	remoteport_tlm_memory_slave rp_axi_ace_fpd;

	remoteport_tlm_wires rp_wires_in;
	remoteport_tlm_wires rp_wires_out;
	remoteport_tlm_wires rp_irq_out;
	remoteport_tlm_wires rp_emio0;
	remoteport_tlm_wires rp_emio1;
	remoteport_tlm_wires rp_emio2;

	/*
	 * In order to get Master-IDs right, we need to proxy all
	 * transactions and inject generic attributes with Master IDs.
	 */
	sc_vector<tlm_utils::simple_target_socket_tagged<xilinx_zynqmp> > proxy_in;
	sc_vector<tlm_utils::simple_initiator_socket_tagged<xilinx_zynqmp> > proxy_out;

	/*
	 * Proxies for friendly named pl_resets.
	 */
	wire_splitter *pl_resetn_splitter[4];

	virtual void b_transport(int id,
				 tlm::tlm_generic_payload& trans,
				 sc_time& delay);
    virtual tlm::tlm_sync_enum nb_transport_fw(int id,tlm::tlm_generic_payload& trans,
			tlm::tlm_phase& phase, sc_core::sc_time& delay);
    virtual tlm::tlm_sync_enum nb_transport_bw(int id,tlm::tlm_generic_payload& trans,
			tlm::tlm_phase& phase, sc_core::sc_time& delay);
	virtual unsigned int transport_dbg(int id,
					   tlm::tlm_generic_payload& trans);
public:
	/*
	 * HPM0 - 1 _FPD.
	 * These sockets represent the High speed PS to PL interfaces.
	 * These are AXI Slave ports on the PS side and AXI Master ports
	 * on the PL side.
	 *
	 * HPM_LPD
	 * Used to transfer data quickly from the LPD to the PL.
	 *
	 * Used to transfer data from the PS to the PL.
	 */
	tlm_utils::simple_initiator_socket<remoteport_tlm_memory_master> *s_axi_hpm_fpd[2];
	tlm_utils::simple_initiator_socket<remoteport_tlm_memory_master> *s_axi_hpm_lpd;
	tlm_utils::simple_initiator_socket<remoteport_tlm_memory_master> *s_lpd_reserved;

	/*
	 * HPC0 - 1.
	 * These sockets represent the High speed IO Coherent PL to PS
	 * interfaces.
	 *
	 * HP0 - 3.
	 * These sockets represent the High speed PL to PS interfaces.
	 *
	 * PL_LPD
	 * Low-Power interface used to transfer data to the Low Power Domain.
	 *
	 * ACP
	 * Accelerator Coherency Port, used to transfered coherent data to
	 * the PS via the Cortex-A53 subsystem.
	 *
	 * These are AXI Master ports on the PS side and AXI Slave ports
	 * on the PL side.
	 *
	 * Used to transfer data from the PL to the PS.
	 */
	tlm_utils::simple_target_socket_tagged<xilinx_zynqmp> *s_axi_hpc_fpd[2];
	tlm_utils::simple_target_socket_tagged<xilinx_zynqmp> *s_axi_hp_fpd[4];
	tlm_utils::simple_target_socket_tagged<xilinx_zynqmp> *s_axi_lpd;
	tlm_utils::simple_target_socket_tagged<xilinx_zynqmp> *s_axi_acp_fpd;
	tlm_utils::simple_target_socket_tagged<xilinx_zynqmp> *s_axi_ace_fpd;

	sc_vector<sc_signal<bool> > pl2ps_irq;
	sc_vector<sc_signal<bool> > ps2pl_irq;

	xilinx_emio_bank *emio[3];
	/*
	 * 4 PL resets, same as EMIO[2][31:28] but with friendly names.
	 * See the TRM, Chapter 27 GPIO, page 761.
	 */
	sc_vector<sc_signal<bool> > pl_resetn;

	xilinx_zynqmp(sc_core::sc_module_name name, const char *sk_descr);
	~xilinx_zynqmp(void);
	void tie_off(void);
};
