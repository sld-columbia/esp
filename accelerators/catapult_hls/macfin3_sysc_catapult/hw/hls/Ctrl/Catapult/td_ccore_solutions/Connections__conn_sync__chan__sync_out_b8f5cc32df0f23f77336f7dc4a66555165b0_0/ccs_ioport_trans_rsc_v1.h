#ifndef INCLUDED_CCS_IOPORT_TRANS_RSC_H
#define INCLUDED_CCS_IOPORT_TRANS_RSC_H

#include "mc_transactors.h"

////////////////////////////////////////////////////////////////////////////////
// ccs_in_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
//
// This is a purely combinational interface component
//
template<int streamcnt, int width>
class ccs_in_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::port_type port_type;
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_out<data_type>       dat;

  // Next three functions are overrides for combinational behavior
  virtual bool is_combinational() { return true; }
  virtual void require_driving_value_adjustments(int RH, int BaseAddr, int CH, int BaseBit) {
    const int row = this->get_current_in_row();
    if (BaseAddr <= row && row <= RH) {
      this->_value_changed.notify(SC_ZERO_TIME);
    }
  }
  virtual void adjust_driving_value(int row, int idx_lhs, int vwidth, sc_lv_base& rhs, int rhs_idx) {
    if (row == this->get_current_in_row()) {
      this->set_value(DRV, idx_lhs, vwidth, rhs, rhs_idx);
    }
  }

  SC_HAS_PROCESS(ccs_in_trans_rsc_v1);
  ccs_in_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0)
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    MC_METHOD(update_z);
    this->sensitive << this->_value_changed;
    this->dont_initialize();

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  // a simple wire without handshake cannot be used for streamed data. force row to always be zero
  virtual int get_current_in_row() const { return 0; }

  void clk_skew_delay() {
    this->exchange_value();
  }

  void update_z() {
      const int row = this->get_current_in_row();
      this->write_row(DRV, this->read_row(row));
      if (this->is_combinational()) 
        this->initiate_driving_value_adjustments(row, row, COLS - 1, 0);
      dat = this->read_row(DRV);
  }

  void my_at_active_clk() { base::at_active_clk(); }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_in_rdy_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int width>
class ccs_in_rdy_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_out<data_type>       dat;
  sc_in<sc_dt::sc_logic>  rdy;

  SC_HAS_PROCESS(ccs_in_rdy_trans_rsc_v1);
  ccs_in_rdy_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
    , rdy("rdy")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(update_z);
    this->sensitive << this->_value_changed;
    this->dont_initialize();

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    if (rdy.read() == SC_LOGIC_1) {
      this->incr_current_in_row(); // value is being read right now, so advance index
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - input index now " << this->get_current_in_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
      this->_value_changed.notify(SC_ZERO_TIME); // display next row
    }
    this->exchange_value();
  }

  void update_z() {
      const int row = this->get_current_in_row();
      this->write_row(DRV, this->read_row(row));
      if (this->is_combinational()) 
        this->initiate_driving_value_adjustments(row, row, COLS - 1, 0);
      dat = this->read_row(DRV);
  }

  void my_at_active_clk() { base::at_active_clk(); }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_in_rdy_coupled_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int width>
class ccs_in_rdy_coupled_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_out<data_type>       dat;
  sc_in<sc_dt::sc_logic>  rdy;

  SC_HAS_PROCESS(ccs_in_rdy_coupled_trans_rsc_v1);
  ccs_in_rdy_coupled_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
    , rdy("rdy")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(update_z);
    this->sensitive << this->_value_changed;
    this->dont_initialize();

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    if (rdy.read() == SC_LOGIC_1) {
      this->incr_current_in_row(); // value is being read right now, so advance index
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - input index now " << this->get_current_in_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
      this->_value_changed.notify(SC_ZERO_TIME); // display next row
    }
    this->exchange_value();
  }

  void update_z() {
      const int row = this->get_current_in_row();
      this->write_row(DRV, this->read_row(row));
      if (this->is_combinational()) 
        this->initiate_driving_value_adjustments(row, row, COLS - 1, 0);
      dat = this->read_row(DRV);
  }

  void my_at_active_clk() { base::at_active_clk(); }
  
  virtual bool is_coupled() { return true; }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_in_vld_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int width>
class ccs_in_vld_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_out<data_type>       dat;
  sc_out<sc_dt::sc_logic> vld;

  SC_HAS_PROCESS(ccs_in_vld_trans_rsc_v1);
  ccs_in_vld_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
    , vld("vld")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(update_z);
    this->sensitive << this->_value_changed;
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
    this->sensitive << this->_wait_cycles_changed[0/*input*/];

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    bool waiting = this->wait_signal_active(0/*input*/) && io_request(0/*input*/);
    if (!waiting) {
      this->incr_current_in_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - input index now " << this->get_current_in_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
      this->_value_changed.notify(SC_ZERO_TIME); // display next row
    }
    this->exchange_value(waiting);
  }

  void update_z() {
      const int row = this->get_current_in_row();
      this->write_row(DRV, this->read_row(row));
      if (this->is_combinational()) 
        this->initiate_driving_value_adjustments(row, row, COLS - 1, 0);
      dat = this->read_row(DRV);
  }

  void my_at_active_clk() { base::at_active_clk(); }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void my_wait_controller() { base::wait_controller(0/*input*/); }

  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'vld' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) { vld = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; }

  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir)                 { return (vld.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'rdy' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir) { return true; }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_in_reg_vld_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int rscid, int width, int ph_clk, int ph_en, int ph_arst , int ph_srst >
class ccs_in_reg_vld_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_out<data_type>       dat;
  sc_out<sc_dt::sc_logic> vld;
  sc_in<sc_dt::sc_logic>  arst; 
  sc_in<sc_dt::sc_logic>  srst; 
  sc_in<sc_dt::sc_logic>  en; 

  SC_HAS_PROCESS(ccs_in_reg_vld_trans_rsc_v1);
  ccs_in_reg_vld_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
    , vld("vld")
    , arst("arst")
    , srst("srst")
    , en("en")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(update_z);
    this->sensitive << this->_value_changed;
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
    this->sensitive << this->_wait_cycles_changed[0/*input*/];

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    bool waiting = this->wait_signal_active(0/*input*/) && io_request(0/*input*/);
    if (!waiting) {
      this->incr_current_in_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - input index now " << this->get_current_in_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
      this->_value_changed.notify(SC_ZERO_TIME); // display next row
    }
    this->exchange_value(waiting);
  }

  void update_z() {
      const int row = this->get_current_in_row();
      this->write_row(DRV, this->read_row(row));
      if (this->is_combinational()) 
        this->initiate_driving_value_adjustments(row, row, COLS - 1, 0);
      dat = this->read_row(DRV);
  }

  void my_at_active_clk() { base::at_active_clk(); }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void my_wait_controller() { 
      if (ph_srst == srst || ph_arst == arst ) {
        drive_wait_signals(true,0);
        base::_wait_cycles_cntr[0]=1;
      }
      else  
        base::wait_controller(0/*input*/); 
  }


  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'vld' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) { 
          vld = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; 
  } 



  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir)                 { return (vld.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'rdy' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir) { return true; }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_ctrl_in_buf_vld_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int rscid, int width, int ph_clk, int ph_en, int ph_arst, int ph_srst>
class ccs_ctrl_in_buf_vld_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_out<data_type>       dat;
  sc_out<sc_dt::sc_logic> vld;
  sc_in<sc_dt::sc_logic>  arst; // unused in this model
  sc_in<sc_dt::sc_logic>  srst; // unused in this model
  sc_in<sc_dt::sc_logic>  en; // unused in this model

  SC_HAS_PROCESS(ccs_ctrl_in_buf_vld_trans_rsc_v1);
  ccs_ctrl_in_buf_vld_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
    , vld("vld")
    , arst("arst")
    , srst("srst")
    , en("en")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(update_z);
    this->sensitive << this->_value_changed;
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
    this->sensitive << this->_wait_cycles_changed[0/*input*/];

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    bool waiting = this->wait_signal_active(0/*input*/) && io_request(0/*input*/);
    if (!waiting) {
      this->incr_current_in_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - input index now " << this->get_current_in_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
      this->_value_changed.notify(SC_ZERO_TIME); // display next row
    }
    this->exchange_value(waiting);
  }

  void update_z() {
      const int row = this->get_current_in_row();
      this->write_row(DRV, this->read_row(row));
      if (this->is_combinational()) 
        this->initiate_driving_value_adjustments(row, row, COLS - 1, 0);
      dat = this->read_row(DRV);
  }

  void my_at_active_clk() { base::at_active_clk(); }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void my_wait_controller() { base::wait_controller(0/*input*/); }

  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'vld' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) { vld = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; }

  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir)                 { return (vld.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'rdy' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir) { return true; }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_in_wait_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int width>
class ccs_in_wait_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_out<data_type>       dat;
  sc_in<sc_dt::sc_logic>  rdy;
  sc_out<sc_dt::sc_logic> vld;

  SC_HAS_PROCESS(ccs_in_wait_trans_rsc_v1);
  ccs_in_wait_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
    , rdy("rdy")
    , vld("vld")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(update_z);
    this->sensitive << this->_value_changed;
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
    this->sensitive << this->_wait_cycles_changed[0/*input*/];

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    bool waiting = this->wait_signal_active(0/*input*/) && io_request(0/*input*/);
    if ((rdy.read() == SC_LOGIC_1) && !waiting) {
      this->incr_current_in_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - input index now " << this->get_current_in_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
      this->_value_changed.notify(SC_ZERO_TIME); // display next row
    }
    this->exchange_value(waiting);
  }

  void update_z() {
      const int row = this->get_current_in_row();
      this->write_row(DRV, this->read_row(row));
      if (this->is_combinational()) 
        this->initiate_driving_value_adjustments(row, row, COLS - 1, 0);
      dat = this->read_row(DRV);
  }

  void my_at_active_clk() { base::at_active_clk(); }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void my_wait_controller() { base::wait_controller(0/*input*/); }

  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'vld' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) { vld = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; }

  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir)                 { return (vld.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'rdy' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir) { return (rdy.read() == SC_LOGIC_1); }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_in_wait_coupled_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int width>
class ccs_in_wait_coupled_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_out<data_type>       dat;
  sc_in<sc_dt::sc_logic>  rdy;
  sc_out<sc_dt::sc_logic> vld;

  SC_HAS_PROCESS(ccs_in_wait_coupled_trans_rsc_v1);
  ccs_in_wait_coupled_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
    , rdy("rdy")
    , vld("vld")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(update_z);
    this->sensitive << this->_value_changed;
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
    this->sensitive << this->_wait_cycles_changed[0/*input*/];

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    bool waiting = this->wait_signal_active(0/*input*/) && io_request(0/*input*/);
    if ((rdy.read() == SC_LOGIC_1) && !waiting) {
      this->incr_current_in_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - input index now " << this->get_current_in_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
      this->_value_changed.notify(SC_ZERO_TIME); // display next row
    }
    this->exchange_value(waiting);
  }

  void update_z() {
      const int row = this->get_current_in_row();
      this->write_row(DRV, this->read_row(row));
      if (this->is_combinational()) 
        this->initiate_driving_value_adjustments(row, row, COLS - 1, 0);
      dat = this->read_row(DRV);
  }

  void my_at_active_clk() { base::at_active_clk(); }

  virtual bool is_coupled() { return true; }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void my_wait_controller() { base::wait_controller(0/*input*/); }

  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'vld' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) { vld = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; }

  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir)                 { return (vld.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'rdy' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir) { return (rdy.read() == SC_LOGIC_1); }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_in_wait_gated_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int width>
class ccs_in_wait_gated_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_out<data_type>       dat;
  sc_in<sc_dt::sc_logic>  rdy;
  sc_out<sc_dt::sc_logic> vld;

  SC_HAS_PROCESS(ccs_in_wait_gated_trans_rsc_v1);
  ccs_in_wait_gated_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
    , rdy("rdy")
    , vld("vld")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(update_z);
    this->sensitive << this->_value_changed;
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
    this->sensitive << this->_wait_cycles_changed[0/*input*/];

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    bool waiting = this->wait_signal_active(0/*input*/) && io_request(0/*input*/);
    if ((rdy.read() == SC_LOGIC_1) && !waiting) {
      this->incr_current_in_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - input index now " << this->get_current_in_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
      this->_value_changed.notify(SC_ZERO_TIME); // display next row
    }
    this->exchange_value(waiting);
  }

  void update_z() {
      const int row = this->get_current_in_row();
      this->write_row(DRV, this->read_row(row));
      if (this->is_combinational()) 
        this->initiate_driving_value_adjustments(row, row, COLS - 1, 0);
      dat = this->read_row(DRV);
  }

  void my_at_active_clk() { base::at_active_clk(); }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void my_wait_controller() { base::wait_controller(0/*input*/); }

  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'vld' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) { vld = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; }

  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir)                 { return (vld.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'rdy' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir) { return (rdy.read() == SC_LOGIC_1); }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_ctrl_in_buf_wait_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int rscid, int width, int ph_clk, int ph_en, int ph_arst, int ph_srst>
class ccs_ctrl_in_buf_wait_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_out<data_type>       dat;
  sc_in<sc_dt::sc_logic>  rdy;
  sc_out<sc_dt::sc_logic> vld;
  sc_in<sc_dt::sc_logic>  arst; // unused in this model
  sc_in<sc_dt::sc_logic>  srst; // unused in this model
  sc_in<sc_dt::sc_logic>  en; // unused in this model

  SC_HAS_PROCESS(ccs_ctrl_in_buf_wait_trans_rsc_v1);
  ccs_ctrl_in_buf_wait_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
    , rdy("rdy")
    , vld("vld")
    , arst("arst")
    , srst("srst")
    , en("en")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(update_z);
    this->sensitive << this->_value_changed;
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
    this->sensitive << this->_wait_cycles_changed[0/*input*/];

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    bool waiting = this->wait_signal_active(0/*input*/) && io_request(0/*input*/);
    if ((rdy.read() == SC_LOGIC_1) && !waiting) {
      this->incr_current_in_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - input index now " << this->get_current_in_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
      this->_value_changed.notify(SC_ZERO_TIME); // display next row
    }
    this->exchange_value(waiting);
  }

  void update_z() {
      const int row = this->get_current_in_row();
      this->write_row(DRV, this->read_row(row));
      if (this->is_combinational()) 
        this->initiate_driving_value_adjustments(row, row, COLS - 1, 0);
      dat = this->read_row(DRV);
  }

  void my_at_active_clk() { base::at_active_clk(); }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void my_wait_controller() { base::wait_controller(0/*input*/); }

  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'vld' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) { vld = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; }

  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir)                 { return (vld.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'rdy' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir) { return (rdy.read() == SC_LOGIC_1); }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_in_buf_wait_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int rscid, int width, int ph_clk, int ph_en, int ph_arst, int ph_srst>
class ccs_in_buf_wait_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_out<data_type>       dat;
  sc_in<sc_dt::sc_logic>  rdy;
  sc_out<sc_dt::sc_logic> vld;
  sc_in<sc_dt::sc_logic>  arst; // unused in this model
  sc_in<sc_dt::sc_logic>  srst; // unused in this model
  sc_in<sc_dt::sc_logic>  en; // unused in this model

  SC_HAS_PROCESS(ccs_in_buf_wait_trans_rsc_v1);
  ccs_in_buf_wait_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
    , rdy("rdy")
    , vld("vld")
    , arst("arst")
    , srst("srst")
    , en("en")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(update_z);
    this->sensitive << this->_value_changed;
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
    this->sensitive << this->_wait_cycles_changed[0/*input*/];

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    bool waiting = this->wait_signal_active(0/*input*/) && io_request(0/*input*/);
    if ((rdy.read() == SC_LOGIC_1) && !waiting) {
      this->incr_current_in_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - input index now " << this->get_current_in_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
      this->_value_changed.notify(SC_ZERO_TIME); // display next row
    }
    this->exchange_value(waiting);
  }

  void update_z() {
      const int row = this->get_current_in_row();
      this->write_row(DRV, this->read_row(row));
      if (this->is_combinational()) 
        this->initiate_driving_value_adjustments(row, row, COLS - 1, 0);
      dat = this->read_row(DRV);
  }

  void my_at_active_clk() { base::at_active_clk(); }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void my_wait_controller() { base::wait_controller(0/*input*/); }

  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'vld' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) { vld = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; }

  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir)                 { return (vld.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'rdy' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir) { return (rdy.read() == SC_LOGIC_1); }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_in_wait_szchan_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int width, int sz_width>
class ccs_in_wait_szchan_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_out<data_type>       dat;
  sc_in<sc_dt::sc_logic>  rdy;
  sc_out<sc_dt::sc_logic> vld;
  sc_out<sc_lv<sz_width> > sz;
  sc_in<sc_dt::sc_logic>  sz_rdy;

  SC_HAS_PROCESS(ccs_in_wait_szchan_trans_rsc_v1);
  ccs_in_wait_szchan_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
    , rdy("rdy")
    , vld("vld")
    , sz("sz")
    , sz_rdy("sz_rdy")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(update_z);
    this->sensitive << this->_value_changed;
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
    this->sensitive << this->_wait_cycles_changed[0/*input*/];

    SC_METHOD(sz_rdy_event);
    this->sensitive << this->_update_sz;
    this->dont_initialize();

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  virtual void start_of_simulation() {
    sz.write(0); // Drive initial value on size port to avoid X's
  }

  void sz_rdy_event() {
    int tmp = this->count_sizelz_event(sz_rdy.read()==SC_LOGIC_1); // record fact that H/W attempted sz read
    if (sz_rdy.read() != SC_LOGIC_0) {
       sz.write(this->in_used()); // update sz with current fifo used count from transactor
    }
  }

  void clk_skew_delay() {
    this->_update_sz.notify(SC_ZERO_TIME);
    bool waiting = this->wait_signal_active(0/*input*/) && io_request(0/*input*/);
    if ((rdy.read() == SC_LOGIC_1) && !waiting) {
      this->incr_current_in_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - input index now " << this->get_current_in_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
     this->_value_changed.notify(SC_ZERO_TIME); // display next row
    }
    this->exchange_value(waiting);
  }

  void update_z() {
      sz.write(this->in_used()); // update sz with current fifo used count from transactor
      const int row = this->get_current_in_row();
      this->write_row(DRV, this->read_row(row));
      if (this->is_combinational()) 
        this->initiate_driving_value_adjustments(row, row, COLS - 1, 0);
      dat = this->read_row(DRV);
  }
  sc_event _update_sz; // need to update sz (if sz_rdy hi)

  void my_at_active_clk() { base::at_active_clk(); }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void         my_wait_controller()                 { base::wait_controller(0/*input*/); }

  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'vld' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) { vld = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; }

  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir)                 { return (vld.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'rdy' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir)                    { return (rdy.read() == SC_LOGIC_1); }
};
////////////////////////////////////////////////////////////////////////////////
// ccs_sync_in_wait_trans_rsc_v1
////////////////////////////////////////////////////////////////////////////////
class ccs_sync_in_wait_trans_rsc_v1 : public mc_wire_trans_rsc_base<1,1>
{
public:
  typedef mc_wire_trans_rsc_base<1,1> base;
  MC_EXPOSE_NAMES_OF_BASE(base);

  enum { COLS = base::COLS };
  enum { DRV = 1 }; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_in<sc_dt::sc_logic>  rdy;
  sc_out<sc_dt::sc_logic> vld;

  SC_HAS_PROCESS(ccs_sync_in_wait_trans_rsc_v1);
  ccs_sync_in_wait_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , rdy("rdy")
    , vld("vld")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(update_z);
    this->sensitive << this->_value_changed;
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
    this->sensitive << this->_wait_cycles_changed[0/*input*/];

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    bool waiting = this->wait_signal_active(0/*input*/) && io_request(0/*input*/);
    if ((rdy.read() == SC_LOGIC_1) && !waiting) {
      this->incr_current_in_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - input index now " << this->get_current_in_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
      this->_value_changed.notify(SC_ZERO_TIME); // display next row
    }
    this->exchange_value(waiting);
  }

  void update_z() {
    const int row = this->get_current_in_row();
    this->write_row(DRV, this->read_row(row));
    if (this->is_combinational()) 
      this->initiate_driving_value_adjustments(row, row, COLS - 1, 0);
  }

  void my_at_active_clk() { base::at_active_clk(); }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void my_wait_controller() { base::wait_controller(0/*input*/); }

  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'vld' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) { vld = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; }

  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir)                 { return (vld.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'rdy' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir) { return (rdy.read() == SC_LOGIC_1); }
};


////////////////////////////////////////////////////////////////////////////////
// ccs_sync_in_vld_trans_rsc_v1
////////////////////////////////////////////////////////////////////////////////
class ccs_sync_in_vld_trans_rsc_v1 : public mc_wire_trans_rsc_base<1,1>
{
public:
  typedef mc_wire_trans_rsc_base<1,1> base;
  MC_EXPOSE_NAMES_OF_BASE(base);

  enum { COLS = base::COLS };
  enum { DRV = 1 }; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_out<sc_dt::sc_logic> vld;

  SC_HAS_PROCESS(ccs_sync_in_vld_trans_rsc_v1);
  ccs_sync_in_vld_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , vld("vld")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(update_z);
    this->sensitive << this->_value_changed;
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
    this->sensitive << this->_wait_cycles_changed[0/*input*/];

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    bool waiting = this->wait_signal_active(0/*input*/) && io_request(0/*input*/);
    if (!waiting) {
      this->incr_current_in_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - input index now " << this->get_current_in_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
      this->_value_changed.notify(SC_ZERO_TIME); // display next row
    }
    this->exchange_value(waiting);
  }

  void update_z() {
    const int row = this->get_current_in_row();
    this->write_row(DRV, this->read_row(row));
    if (this->is_combinational()) 
      this->initiate_driving_value_adjustments(row, row, COLS - 1, 0);
  }

  void my_at_active_clk() { base::at_active_clk(); }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void my_wait_controller() { base::wait_controller(0/*input*/); }

  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'vld' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) { vld = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; }

  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir)                 { return (vld.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'rdy' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir) { return true; } 
};

////////////////////////////////////////////////////////////////////////////////
// ccs_out_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int width>
class ccs_out_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_in<data_type>        dat;

  SC_HAS_PROCESS(ccs_out_trans_rsc_v1);
  ccs_out_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  // a simple wire without handshake cannot be used for streamed data. force row to always be zero
  virtual int get_current_in_row() const { return 0; }

  void clk_skew_delay() {
    this->write_row(0, this->dat.read());
    this->exchange_value();
  }

  void my_at_active_clk() { base::at_active_clk(); }
};

template<int streamcnt, int width>
class ccs_out_prereg_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_in<data_type>        dat;

  SC_HAS_PROCESS(ccs_out_prereg_trans_rsc_v1);
  ccs_out_prereg_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  // a simple wire without handshake cannot be used for streamed data. force row to always be zero
  virtual int get_current_in_row() const { return 0; }
//  virtual void inject_value(int row, int idx_lhs, int vwidth, sc_lv_base& rhs, int idx_rhs) {
//    this->set_value(row, idx_lhs, vwidth, rhs, idx_rhs);
//  }

//  virtual void extract_value(int row, int idx_rhs, int vwidth, sc_lv_base& lhs, int idx_lhs) {
//    this->get_value(row, idx_rhs, vwidth, lhs, idx_lhs);
//  }

  void clk_skew_delay() {
    this->exchange_value();
    this->write_row(0, this->dat.read());
  }

  void my_at_active_clk() { base::at_active_clk(); }
};
////////////////////////////////////////////////////////////////////////////////
// ccs_out_prereg_vld_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
// mc_rsc_registered_wire
//    Derived resource class suitable for wires with registered inputs.
//
// This resource block has (logically) registers for all inputs. So it
// does not need any combinational process at all. If at clock edge
// both, lzin and triosy are high (ie. the call to exchange_value does
// modify the contents), then we need to show the NEW value, since the
// correponding triosync operation happened at the previous clock
// edge, but the corresponding read operation happens at this current
// edge, thus AFTER the tiosync operation. If lzout and triosy are
// high, then we also write to the NEW value for the very same
// reasons. Thus exchange_value(...) needs to be called before we
// react to the port values.
//
// For channels, which don't rely on triosy, the capture occurs when
// lz is active. This means the exchange_value() call must not be early.
// Use _capture_data_reg to control when exchange_value() is called.
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int width>
class ccs_out_prereg_vld_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_in<data_type>        dat;
  sc_in<sc_dt::sc_logic>  vld;
  const bool _capture_data_reg;

  SC_HAS_PROCESS(ccs_out_prereg_vld_trans_rsc_v1);
  ccs_out_prereg_vld_trans_rsc_v1(const sc_module_name& name, bool phase, bool capture_data_reg=true, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
    , vld("vld")
    , _capture_data_reg(capture_data_reg)
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  virtual void inject_value(int row, int idx_lhs, int vwidth, sc_lv_base& rhs, int idx_rhs) {
    this->set_value(row, idx_lhs, vwidth, rhs, idx_rhs);
  }

  virtual void extract_value(int row, int idx_rhs, int vwidth, sc_lv_base& lhs, int idx_lhs) {
    this->get_value(row, idx_rhs, vwidth, lhs, idx_lhs);
  }

  void clk_skew_delay() {
    if (this->_capture_data_reg)
        this->exchange_value();
    if (this->vld.read() == SC_LOGIC_1) {
      this->write_row(this->get_current_out_row(), this->dat.read());
      this->incr_current_out_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - output index now " << this->get_current_out_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
    }
    if (!this->_capture_data_reg)
        this->exchange_value();
  }

  void my_at_active_clk() { base::at_active_clk(); }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_out_rdy_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int width>
class ccs_out_rdy_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_in<data_type>        dat;
  sc_out<sc_dt::sc_logic> rdy;

  SC_HAS_PROCESS(ccs_out_rdy_trans_rsc_v1);
  ccs_out_rdy_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
    , rdy("rdy")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
  }

  void clk_skew_delay() {
    bool waiting = this->wait_signal_active(1/*output*/) && io_request(1/*output*/);
    if (!waiting) {
      this->write_row(this->get_current_out_row(), this->dat.read());
      this->incr_current_out_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - output index now " << this->get_current_out_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
    }
    this->exchange_value(waiting);
  }

  void my_at_active_clk() { base::at_active_clk(); }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void         my_wait_controller()                 { base::wait_controller(1/*output*/); }

  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'rdy' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) {rdy = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; }

  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir)                 { return (rdy.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'vld' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir)                    { return true; }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_out_vld_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int width>
class ccs_out_vld_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_in<data_type>        dat;
  sc_in<sc_dt::sc_logic>  vld;

  SC_HAS_PROCESS(ccs_out_vld_trans_rsc_v1);
  ccs_out_vld_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
    , vld("vld")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    if (this->vld.read() == SC_LOGIC_1) {
      this->write_row(this->get_current_out_row(), this->dat.read());
      this->incr_current_out_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - output index now " << this->get_current_out_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
    }
    this->exchange_value();
  }

  void my_at_active_clk() { base::at_active_clk(); }
};


////////////////////////////////////////////////////////////////////////////////
// ccs_out_wait_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
//
//
template<int streamcnt, int width>
class ccs_out_wait_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_in<data_type>        dat;
  sc_in<sc_dt::sc_logic>  vld;
  sc_out<sc_dt::sc_logic> rdy;

  SC_HAS_PROCESS(ccs_out_wait_trans_rsc_v1);
  ccs_out_wait_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
    , vld("vld")
    , rdy("rdy")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
    this->sensitive << this->_wait_cycles_changed[1/*output*/];

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    bool waiting = this->wait_signal_active(1/*output*/) && io_request(1/*output*/);
    if ((this->vld.read() == SC_LOGIC_1) && !waiting) {
      this->write_row(this->get_current_out_row(), this->dat.read());
      this->incr_current_out_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - output index now " << this->get_current_out_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
    }
    // always prepare for exchange (should triosy be true) unless we are waiting AND
    // output is currently being written.
    this->exchange_value(waiting & (this->vld.read() == SC_LOGIC_1));
  }

  void my_at_active_clk() { base::at_active_clk(); }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void         my_wait_controller()                 { base::wait_controller(1/*output*/); }

  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'rdy' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) {rdy = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; }

  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir)                 { return (rdy.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'vld' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir)                    { return (vld.read() == SC_LOGIC_1); }
};


////////////////////////////////////////////////////////////////////////////////
// ccs_out_skidbuf_wait_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int rscid, int width, int ph_clk, int ph_en, int ph_arst, int ph_srst, int rst_val>
class ccs_out_skidbuf_wait_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_in<data_type>        dat;
  sc_in<sc_dt::sc_logic>  vld;
  sc_out<sc_dt::sc_logic> rdy;
  sc_in<sc_dt::sc_logic>  arst; // unused in this model
  sc_in<sc_dt::sc_logic>  srst; // unused in this model
  sc_in<sc_dt::sc_logic>  en; // unused in this model

  SC_HAS_PROCESS(ccs_out_skidbuf_wait_trans_rsc_v1);
  ccs_out_skidbuf_wait_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
    , vld("vld")
    , rdy("rdy")
    , arst("arst")
    , srst("srst")
    , en("en")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
    this->sensitive << this->_wait_cycles_changed[1/*output*/];

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    bool waiting = this->wait_signal_active(1/*output*/) && io_request(1/*output*/);
    if ((this->vld.read() == SC_LOGIC_1) && !waiting) {
      this->write_row(this->get_current_out_row(), this->dat.read());
      this->incr_current_out_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - output index now " << this->get_current_out_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
    }
    // always prepare for exchange (should triosy be true) unless we are waiting AND
    // output is currently being written.
    this->exchange_value(waiting & (this->vld.read() == SC_LOGIC_1));
  }

  void my_at_active_clk() { base::at_active_clk(); }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void         my_wait_controller()                 { base::wait_controller(1/*output*/); }

  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'rdy' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) {rdy = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; }

  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir)                 { return (rdy.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'vld' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir)                    { return (vld.read() == SC_LOGIC_1); }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_out_buf_wait_trans_rsc_v1
//    
////////////////////////////////////////////////////////////////////////////////
//
//
template<int streamcnt, int rscid, int width, int ph_clk, int ph_en, int ph_arst, int ph_srst, int rst_val>
class ccs_out_buf_wait_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_in<data_type>        dat;
  sc_in<sc_dt::sc_logic>  vld;
  sc_out<sc_dt::sc_logic> rdy;
  sc_in<sc_dt::sc_logic>  arst; // unused in this model
  sc_in<sc_dt::sc_logic>  srst; // unused in this model
  sc_in<sc_dt::sc_logic>  en; // unused in this model

  SC_HAS_PROCESS(ccs_out_buf_wait_trans_rsc_v1);
  ccs_out_buf_wait_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , dat("dat")
    , vld("vld")
    , rdy("rdy")
    , arst("arst")
    , srst("srst")
    , en("en")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
    this->sensitive << this->_wait_cycles_changed[1/*output*/];

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    bool waiting = this->wait_signal_active(1/*output*/) && io_request(1/*output*/);
    if ((this->vld.read() == SC_LOGIC_1) && !waiting) {
      this->write_row(this->get_current_out_row(), this->dat.read());
      this->incr_current_out_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - output index now " << this->get_current_out_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
    }
    // always prepare for exchange (should triosy be true) unless we are waiting AND
    // output is currently being written.
    this->exchange_value(waiting & (this->vld.read() == SC_LOGIC_1));
  }

  void my_at_active_clk() { base::at_active_clk(); }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void         my_wait_controller()                 { base::wait_controller(1/*output*/); }

  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'rdy' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) {rdy = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; }

  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir)                 { return (rdy.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'vld' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir)                    { return (vld.read() == SC_LOGIC_1); }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_sync_out_wait_trans_rsc_v1 
////////////////////////////////////////////////////////////////////////////////
class ccs_sync_out_wait_trans_rsc_v1 : public mc_wire_trans_rsc_base<1,1>
{
public:
  typedef mc_wire_trans_rsc_base<1,1> base;
  MC_EXPOSE_NAMES_OF_BASE(base);

  enum { COLS = base::COLS };
  enum { DRV = 1}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_in<sc_dt::sc_logic>  vld;
  sc_out<sc_dt::sc_logic> rdy;

  SC_HAS_PROCESS(ccs_sync_out_wait_trans_rsc_v1);
  ccs_sync_out_wait_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , vld("vld")
    , rdy("rdy")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
    this->sensitive << this->_wait_cycles_changed[1/*output*/];

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    bool waiting = this->wait_signal_active(1/*output*/) && io_request(1/*output*/);
    if ((this->vld.read() == SC_LOGIC_1) && !waiting) {
      this->write_row(this->get_current_out_row(), sc_lv<1>("1"));//this->z.read());
      this->incr_current_out_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - output index now " << this->get_current_out_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
    }
    // always prepare for exchange (should triosy be true) unless we are waiting AND
    // output is currently being written.
    this->exchange_value(waiting & (this->vld.read() == SC_LOGIC_1));
  }

  void my_at_active_clk() { base::at_active_clk(); }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void         my_wait_controller()                 { base::wait_controller(1/*output*/); }

  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'vzout' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) { rdy = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; }

  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir)                 { return (rdy.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'lzout' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir)                    { return (vld.read() == SC_LOGIC_1); }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_sync_out_vld_trans_rsc_v1 
////////////////////////////////////////////////////////////////////////////////
class ccs_sync_out_vld_trans_rsc_v1 : public mc_wire_trans_rsc_base<1,1>
{
public:
  typedef mc_wire_trans_rsc_base<1,1> base;
  MC_EXPOSE_NAMES_OF_BASE(base);

  enum { COLS = base::COLS };
  enum { DRV = 1}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_out<sc_dt::sc_logic> vld;

  SC_HAS_PROCESS(ccs_sync_out_vld_trans_rsc_v1);
  ccs_sync_out_vld_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , vld("vld")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    if (this->vld.read() == SC_LOGIC_1) {
      this->write_row(this->get_current_out_row(), sc_lv<1>("1"));
      this->incr_current_out_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - output index now " << this->get_current_out_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
    }
    this->exchange_value();
  }

  void my_at_active_clk() { base::at_active_clk(); }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_in_pipe_trans_rsc_v1
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int rscid, int width, int fifo_sz, int ph_clk, int ph_en, int ph_arst, int ph_srst>
class ccs_in_pipe_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_in<sc_dt::sc_logic>  en;   // unused in this model
  sc_in<sc_dt::sc_logic>  arst; // unused in this model
  sc_in<sc_dt::sc_logic>  srst; // unused in this model

  sc_in<sc_dt::sc_logic>  rdy;
  sc_out<sc_dt::sc_logic> vld;
  sc_out<data_type>       dat;

  SC_HAS_PROCESS(ccs_in_pipe_trans_rsc_v1);
  ccs_in_pipe_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , en("en")
    , arst("arst")
    , srst("srst")
    , rdy("rdy")
    , vld("vld")
    , dat("dat")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(update_z);
    this->sensitive << this->_value_changed;
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
    this->sensitive << this->_wait_cycles_changed[0/*input*/];

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    bool waiting = this->wait_signal_active(0/*input*/) && io_request(0/*input*/);
    if ((rdy.read() == SC_LOGIC_1) && !waiting) {
      this->incr_current_in_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - input index now " << this->get_current_in_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
      this->_value_changed.notify(SC_ZERO_TIME); // display next row
    }
    this->exchange_value(waiting);
  }

  void update_z() {
      const int row = this->get_current_in_row();
      this->write_row(DRV, this->read_row(row));
      if (this->is_combinational()) 
        this->initiate_driving_value_adjustments(row, row, COLS - 1, 0);
      dat = this->read_row(DRV);
  }

  void my_at_active_clk() { base::at_active_clk(); }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void my_wait_controller() { base::wait_controller(0/*input*/); }

  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'vld' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) { vld = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; }

  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir) { return (vld.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'rdy' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir) { return (rdy.read() == SC_LOGIC_1); }
};

////////////////////////////////////////////////////////////////////////////////
// ccs_out_pipe_trans_rsc_v1
////////////////////////////////////////////////////////////////////////////////
template<int streamcnt, int rscid, int width, int fifo_sz,/* int sz_width,*/ int ph_clk, int ph_en, int ph_arst, int ph_srst>
class ccs_out_pipe_trans_rsc_v1
  : public mc_wire_trans_rsc_base<width,streamcnt>
{
public:
  typedef mc_wire_trans_rsc_base<width,streamcnt> base;
  MC_EXPOSE_NAMES_OF_BASE(base);
  typedef typename base::data_type data_type;
  //typedef mc_sc_logic2sc_lv_traits<sc_lv<sz_width> > sz_port_traits;
  //typedef typename sz_port_traits::data_type         sz_port_type;

  enum { COLS = base::COLS };
  enum { DRV = streamcnt}; // driving value is stored at row position streamcnt of data

  sc_in<bool>             clk;
  sc_in<sc_dt::sc_logic>  en;   // unused in this model
  sc_in<sc_dt::sc_logic>  arst; // unused in this model
  sc_in<sc_dt::sc_logic>  srst; // unused in this model
  sc_in<data_type>        dat;
  sc_in<sc_dt::sc_logic>  vld;
  sc_out<sc_dt::sc_logic> rdy;
  //sc_in<sz_port_type>     sz;
  //sc_out<sc_dt::sc_logic> sz_req;

  SC_HAS_PROCESS(ccs_out_pipe_trans_rsc_v1);
  ccs_out_pipe_trans_rsc_v1(const sc_module_name& name, bool phase, double clk_skew_delay=0.0) 
    : base(name,phase,clk_skew_delay)
    , clk("clk")
    , en("en")
    , arst("arst")
    , srst("srst")
    , dat("dat")
    , vld("vld")
    , rdy("rdy")
    //, sz("sz")
    //, sz_req("sz_req")
  {
    MC_METHOD(my_at_active_clk);
    this->sensitive << (phase ? this->clk.pos() : this->clk.neg()); //active edge
    this->dont_initialize();

    SC_METHOD(my_wait_controller);
    this->sensitive << (phase ? this->clk.neg() : this->clk.pos()); // wait control restored on inactive clk edge
    this->sensitive << this->_wait_cycles_changed[1/*output*/];

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  void clk_skew_delay() {
    //sz_req.write(SC_LOGIC_1); // not used 
    bool waiting = this->wait_signal_active(1/*output*/) && io_request(1/*output*/);
    if ((this->vld.read() == SC_LOGIC_1) && !waiting) {
      this->write_row(this->get_current_out_row(), this->dat.read());
      this->incr_current_out_row();
      if (this->is_stream() && this->log_event(MC_TRANSACTOR_STREAMCNT)) {
        std::ostringstream msg;
        msg << "MC_TRANSACTOR_STREAMCNT - output index now " << this->get_current_out_row() << " @ " << sc_time_stamp();
        SC_REPORT_INFO(this->name(), msg.str().c_str());
      }
    }
    // always prepare for exchange (should triosy be true) unless we are waiting AND
    // output is currently being written.
    this->exchange_value(waiting & (this->vld.read() == SC_LOGIC_1));
  }

  void my_at_active_clk() { base::at_active_clk(); }

  // Wait controller
  //   Define function sensitive to this transactor resource's clock and the _wait_cycles_changed event
  //   (this function must always only call the wait_controller() in the base transactor resource class).
  void         my_wait_controller()                 { base::wait_controller(1/*output*/); }

  //   Define function which drives this transactor resource's handshake signals high/low based on
  //   the boolean argument. If you copy this transactor resource class, change the 'rdy' to match the
  //   wait handshake signal of your interface component and adjust the polarity as needed.
  virtual void drive_wait_signals(bool wait_active, unsigned short iodir) { rdy = wait_active ? SC_LOGIC_0 : SC_LOGIC_1; }

  //   Define function which returns true if the wait handshake signal is active (waiting).
  virtual bool wait_signal_active(unsigned short iodir)                 { return (rdy.read() == SC_LOGIC_0); }

  //   Define function which returns true if the design is actively requesting data from this transactor resource.
  //   If you copy this transactor resource class, change the 'vld' to match the data requested handshake
  //   signal of your interface component and adjust the polarity as needed.
  virtual bool io_request(unsigned short iodir)                    { return (vld.read() == SC_LOGIC_1); }
};
#endif // INCLUDED_CCS_IOPORT_TRANS_RSC_H
