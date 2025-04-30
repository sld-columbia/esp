#ifndef __INCLUDED_DUAL_PORT_RBW_trans_rsc_H__
#define __INCLUDED_DUAL_PORT_RBW_trans_rsc_H__
#include <mc_transactors.h>

template < 
  int AddressSz
  ,int data_width
  ,int Sz
>
class DUAL_PORT_RBW_trans_rsc : public mc_wire_trans_rsc_base<data_width,Sz>
{
public:
  sc_in< bool >   clk;
  sc_in< sc_logic >   clk_en;
  sc_in< sc_lv<data_width> >   din;
  sc_out< sc_lv<data_width> >   qout;
  sc_in< sc_lv<AddressSz> >   r_adr;
  sc_in< sc_lv<AddressSz> >   w_adr;
  sc_in< sc_logic >   w_en;

  typedef mc_wire_trans_rsc_base<data_width,Sz> base;
  MC_EXPOSE_NAMES_OF_BASE(base);

  SC_HAS_PROCESS( DUAL_PORT_RBW_trans_rsc );
  DUAL_PORT_RBW_trans_rsc(const sc_module_name& name, bool phase, double clk_skew_delay=0.0)
    : base(name, phase, clk_skew_delay)
    ,clk("clk")
    ,clk_en("clk_en")
    ,din("din")
    ,qout("qout")
    ,r_adr("r_adr")
    ,w_adr("w_adr")
    ,w_en("w_en")
    ,_is_connected_port_1(true)
    ,_is_connected_port_1_messaged(false)
  {
    SC_METHOD(at_active_clock_edge);
    sensitive << (phase ? clk.pos() : clk.neg());
    this->dont_initialize();

    MC_METHOD(clk_skew_delay);
    this->sensitive << this->_clk_skew_event;
    this->dont_initialize();
  }

  virtual void start_of_simulation() {
    if ((base::_holdtime == 0.0) && this->get_attribute("CLK_SKEW_DELAY")) {
      base::_holdtime = ((sc_attribute<double>*)(this->get_attribute("CLK_SKEW_DELAY")))->value;
    }
    if (base::_holdtime > 0) {
      std::ostringstream msg;
      msg << "DUAL_PORT_RBW_trans_rsc CLASS_STARTUP - CLK_SKEW_DELAY = "
        << base::_holdtime << " ps @ " << sc_time_stamp();
      SC_REPORT_INFO(this->name(), msg.str().c_str());
    }
    reset_memory();
  }

  virtual void inject_value(int addr, int idx_lhs, int mywidth, sc_lv_base& rhs, int idx_rhs) {
    this->set_value(addr, idx_lhs, mywidth, rhs, idx_rhs);
  }

  virtual void extract_value(int addr, int idx_rhs, int mywidth, sc_lv_base& lhs, int idx_lhs) {
    this->get_value(addr, idx_rhs, mywidth, lhs, idx_lhs);
  }

private:
  void at_active_clock_edge() {
    base::at_active_clk();
  }

  void clk_skew_delay() {
    this->exchange_value(0);
    if ( clk_en.read() == 0 ) return; //  everything stalls if enable is inactive

    if (clk_en.get_interface())
      _clk_en = clk_en.read();
    if (din.get_interface())
      _din = din.read();
    else {
      _is_connected_port_1 = false;
    }
    if (r_adr.get_interface())
      _r_adr = r_adr.read();
    if (w_adr.get_interface())
      _w_adr = w_adr.read();
    else {
      _is_connected_port_1 = false;
    }
    if (w_en.get_interface())
      _w_en = w_en.read();

    //  Sync Read
    if (1) {
      const int addr = get_addr(_r_adr, "r_adr");
      if (addr >= 0)
        extract_value(addr, 0, data_width, _qout, 0);
      else { 
        sc_lv<data_width> dc; // X
        _qout = dc;
      }
    }
    if (qout.get_interface())
      qout = _qout;
    //  Write
    int _w_addr_port_1 = -1;
    if ( _is_connected_port_1 && (_w_en==1)) {
      _w_addr_port_1 = get_addr(_w_adr, "w_adr");
      if (_w_addr_port_1 >= 0)
        inject_value(_w_addr_port_1, 0, data_width, _din, 0);
    }
    if( !_is_connected_port_1 && !_is_connected_port_1_messaged) {
      std::ostringstream msg;msg << "port_1 is not fully connected and writes on it will be ignored";
      SC_REPORT_WARNING(this->name(), msg.str().c_str());
      _is_connected_port_1_messaged = true;
    }

    this->_value_changed.notify(SC_ZERO_TIME);
  }

  int get_addr(const sc_lv<AddressSz>& addr, const char* pin_name) {
    if (addr.is_01()) {
      const int cur_addr = addr.to_uint();
      if (cur_addr < 0 || cur_addr >= Sz) {
#ifdef CCS_SYSC_DEBUG
        std::ostringstream msg;
        msg << "Invalid address '" << cur_addr << "' out of range [0:" << Sz-1 << "]";
        SC_REPORT_WARNING(pin_name, msg.str().c_str());
#endif
        return -1;
      } else {
        return cur_addr;
      }
    } else {
#ifdef CCS_SYSC_DEBUG
      std::ostringstream msg;
      msg << "Invalid Address '" << addr << "' contains 'X' or 'Z'";
      SC_REPORT_WARNING(pin_name, msg.str().c_str());
#endif
      return -1;
    }
  }

  void reset_memory() {
    this->zero_data();
    _clk_en = SC_LOGIC_X;
    _din = sc_lv<data_width>();
    _r_adr = sc_lv<AddressSz>();
    _w_adr = sc_lv<AddressSz>();
    _w_en = SC_LOGIC_X;
    _is_connected_port_1 = true;
    _is_connected_port_1_messaged = false;
  }

  sc_logic _clk_en;
  sc_lv<data_width>  _din;
  sc_lv<data_width>  _qout;
  sc_lv<AddressSz>  _r_adr;
  sc_lv<AddressSz>  _w_adr;
  sc_logic _w_en;
  bool _is_connected_port_1;
  bool _is_connected_port_1_messaged;
};
#endif // ifndef __INCLUDED_DUAL_PORT_RBW_trans_rsc_H__


