// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __TOP_HPP__
#define __TOP_HPP__

#pragma once

#include "mem_wrap.hpp"
#include "<accelerator_name>_data_types.hpp"
#include "<accelerator_name>_specs.hpp"
#include "<accelerator_name>_conf_info.hpp"

#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)

SC_MODULE(<acc_full_name>)
{
public:
  sc_in<bool> CCS_INIT_S1(clk);
  sc_in<bool> CCS_INIT_S1(rst);
  sc_out<bool> CCS_INIT_S1(acc_done);

  Connections::In<conf_info_t >  CCS_INIT_S1(conf_info);
  Connections::In< ac_int<DMA_WIDTH> >  CCS_INIT_S1(dma_read_chnl);
  Connections::Out< ac_int<DMA_WIDTH> > CCS_INIT_S1(dma_write_chnl);
  Connections::Out<dma_info_t> CCS_INIT_S1(dma_read_ctrl);
  Connections::Out<dma_info_t> CCS_INIT_S1(dma_write_ctrl);

  void config(void);
  void load(void);
  void compute_dataReq(void);
  void compute(void);
  void store_dataReq(void);
  void store(void);

  SC_CTOR(<acc_full_name>):  plm_in_ping("plm_in_ping"), plm_in_pong("plm_in_pong"), plm_out_ping("plm_out_ping"), plm_out_pong("plm_out_pong"){

      SC_THREAD(config);
      sensitive << clk.pos();
      async_reset_signal_is(rst, false);

      SC_THREAD(load);
      sensitive << clk.pos();
      async_reset_signal_is(rst, false);

      SC_THREAD(compute_dataReq);
      sensitive << clk.pos();
      async_reset_signal_is(rst, false);

      SC_THREAD(compute);
      sensitive << clk.pos();
      async_reset_signal_is(rst, false);

      SC_THREAD(store_dataReq);
      sensitive << clk.pos();
      async_reset_signal_is(rst, false);

      SC_THREAD(store);
      sensitive << clk.pos();
      async_reset_signal_is(rst, false);

      plm_in_ping.clk(clk);
      plm_in_ping.rst(rst);
      plm_in_ping.write_req(in_ping_w);
      plm_in_ping.read_req(in_ping_ra);
      plm_in_ping.read_rsp(in_ping_rd);

      plm_in_pong.clk(clk);
      plm_in_pong.rst(rst);
      plm_in_pong.write_req(in_pong_w);
      plm_in_pong.read_req(in_pong_ra);
      plm_in_pong.read_rsp(in_pong_rd);

      plm_out_ping.clk(clk);
      plm_out_ping.rst(rst);
      plm_out_ping.write_req(out_ping_w);
      plm_out_ping.read_req(out_ping_ra);
      plm_out_ping.read_rsp(out_ping_rd);

      plm_out_pong.clk(clk);
      plm_out_pong.rst(rst);
      plm_out_pong.write_req(out_pong_w);
      plm_out_pong.read_req(out_pong_ra);
      plm_out_pong.read_rsp(out_pong_rd);
    }

  Connections::SyncChannel CCS_INIT_S1(sync12);
  Connections::SyncChannel CCS_INIT_S1(sync12b);
  Connections::SyncChannel CCS_INIT_S1(sync23);
  Connections::SyncChannel CCS_INIT_S1(sync2b3);
  Connections::SyncChannel CCS_INIT_S1(sync23b);
  Connections::SyncChannel CCS_INIT_S1(sync2b3b);

  Connections::Combinational<bool> CCS_INIT_S1(sync01);
  Connections::Combinational<bool> CCS_INIT_S1(sync02);
  Connections::Combinational<bool> CCS_INIT_S1(sync02b);
  Connections::Combinational<bool> CCS_INIT_S1(sync03);
  Connections::Combinational<bool> CCS_INIT_S1(sync03b);

  Connections::Combinational<conf_info_t> CCS_INIT_S1(conf1);
  Connections::Combinational<conf_info_t> CCS_INIT_S1(conf2);
  Connections::Combinational<conf_info_t> CCS_INIT_S1(conf2b);
  Connections::Combinational<conf_info_t> CCS_INIT_S1(conf3);
  Connections::Combinational<conf_info_t> CCS_INIT_S1(conf3b);

  mem_wrap<inbks, inrp,
           inwp, inebks,
           DATA_TYPE, NVUINTW(in_as),
           plm_WR<in_as, inwp>,
           plm_RRq<in_as,inrp>,
           plm_RRs<inrp>> CCS_INIT_S1(plm_in_ping);
  mem_wrap<inbks, inrp,
           inwp, inebks,
           DATA_TYPE, NVUINTW(in_as),
           plm_WR<in_as, inwp>,
           plm_RRq<in_as, inrp>,
           plm_RRs<inrp>> CCS_INIT_S1(plm_in_pong);
  mem_wrap<outbks, outrp,
           outwp, outebks,
           DATA_TYPE, NVUINTW(out_as),
           plm_WR<out_as, outwp>,
           plm_RRq<out_as, outrp>,
           plm_RRs<outrp>> CCS_INIT_S1(plm_out_ping);
  mem_wrap<outbks, outrp,
           outwp, outebks,
           DATA_TYPE, NVUINTW(out_as),
           plm_WR<out_as, outwp>,
           plm_RRq<out_as, outrp>,
           plm_RRs<outrp>> CCS_INIT_S1(plm_out_pong);

  Connections::Combinational<plm_WR<in_as,inwp>> in_ping_w;
  Connections::Combinational<plm_RRq<in_as,inrp>> in_ping_ra;
  Connections::Combinational<plm_RRs<inrp>> in_ping_rd;

  Connections::Combinational<plm_WR<in_as,inwp>> in_pong_w;
  Connections::Combinational<plm_RRq<in_as,inrp>> in_pong_ra;
  Connections::Combinational<plm_RRs<inrp>> in_pong_rd;

  Connections::Combinational<plm_WR<out_as,outwp>> out_ping_w;
  Connections::Combinational<plm_RRq<out_as,outrp>> out_ping_ra;
  Connections::Combinational<plm_RRs<outrp>> out_ping_rd;

  Connections::Combinational<plm_WR<out_as,outwp>> out_pong_w;
  Connections::Combinational<plm_RRq<out_as,outrp>> out_pong_ra;
  Connections::Combinational<plm_RRs<outrp>> out_pong_rd;
};

#endif
