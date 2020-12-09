#==============================================================
# TCL proc for inserting an IBUF on a port net
#==============================================================
proc insert_ibuf { net } {

   set port [get_ports -quiet -of [get_nets $net] -filter DIRECTION==IN]
   if {[llength $port]} {
      set cell "${port}_ibuf_inserted"
      disconnect_net -net $net -objects $port
      create_cell -reference IBUF $cell
      create_net ${net}_inserted
      connect_net -net ${net}_inserted -objects [list $port $cell/I]
      connect_net -net ${net} -objects $cell/O
   } else {
      puts "ERROR: Could not find port for net $net. Make sure the specified net connects directly to a port."
   }
}

#==============================================================
# TCL proc for inserting a clock buffer (BUFG, BUFHCE, BUFR, etc)
# on the specified net(s). 
#==============================================================
proc insert_clock_buffer { type nets } {

   foreach net $nets {
      set driver [get_pins -quiet -of [get_nets $net] -filter "IS_LEAF==1 && DIRECTION==OUT"]
      if {[llength $driver]} {
         set cell "${net}_${type}_inserted"
         disconnect_net -net $net -objects $driver
         create_cell -reference $type $cell
         create_net ${net}_inserted
         connect_net -net ${net}_inserted -objects [list $driver $cell/I]
         connect_net -net ${net} -objects $cell/O
      } else {
         puts "ERROR: Could not find leaf level driver for net $net. Make sure the specified net is at the same level of hierarchy as the leaf level driver."
      }
   }
}

#==============================================================
# TCL proc for removing a buffer (BUFG, BUFR) on the
# specified net(s). Should work for any buffer with I/O ports
#==============================================================
proc remove_buffer { buffers } {
   reset_property -quiet LOC [get_cells -quiet -hier -filter {(LOC!="") && (PRIMITIVE_LEVEL==LEAF)}]
   place_design -unplace
   foreach buf $buffers {
      set inputNet [get_nets -of [get_pins $buf/I]]
      set outputNet [get_nets -of [get_pins $buf/O]]
      set loads [get_pins -of [get_nets $outputNet] -filter NAME!=$buf/O]
      remove_cell $buf
      remove_net $outputNet
      connect_net -net $inputNet -objects [get_pins $loads]
   }
}

#==============================================================
# TCL proc to replace IBUF/OBUF on PS7 ports from ISE/EDK with 
# BIBUF for Vivado (ie PSCLK, PSSRSTB, PSPORB, DDRWEB)
#==============================================================
proc replace_iobuf_bibuf { pins } {
   set core [get_cells -hier -filter REF_NAME==PS7]
   set site [get_sites -of [get_cells $core]]
   if {[get_property IS_FIXED [get_cells $core]]} {
      unplace_cell [get_cells $core]
   }
   foreach pin $pins { 
      puts "Fixing pin $pin on PS7 instance $core"
      set buf [get_cells -of [get_pins -leaf -of [get_nets -of [get_pins $core/$pin]]] -filter REF_NAME=~*BUF*]
      set port [get_ports -of [get_nets -of [get_cells $buf]]]
      set cell "${port}_BIBUF_inserted"
      set net1 [get_nets -of [get_pins $buf/O]]
      set net2 [get_nets -of [get_pins $buf/I]]
      set type [get_property REF_NAME [get_cells $buf]]
      if {[string match $type IBUF]} {
         remove_cell $buf
         create_cell -reference BIBUF $cell
         connect_net -net $net1 -objects $cell/IO
         connect_net -net $net2 -objects $cell/PAD
      } elseif  {[string match $type OBUF]} {
         remove_cell $buf
         create_cell -reference BIBUF $cell
         connect_net -net $net1 -objects $cell/PAD
         connect_net -net $net2 -objects $cell/IO
      }
   }
   if {![get_property IS_FIXED [get_cells $core]] && [llength $site]} {
      puts "Placing PS7 instance $core at site $site"
      place_cell [get_cells $core] $site
   }
}

#==============================================================
# TCL proc for swapping the specified clock buffer 
#(BUFG, BUFR, etc) with the specified type
#==============================================================
proc swap_clock_buffers { buffer type } {
   set ref [get_property REF_NAME [get_cells $buffer]]
   if {[string match "BUFG*" $ref] || [string match "BUFR*" $ref] || [string match "BUFH*" $ref]} {
      set inputNet [get_nets -of [get_pins -of [get_cells $buffer] -filter DIRECTION==IN]]
      set outputNet [get_nets -of [get_pins -of [get_cells $buffer] -filter DIRECTION==OUT]]
      remove_cell $buffer
      create_cell -reference $type ${buffer}_$type
      connect_net -net $inputNet -objects [get_pins ${buffer}_$type/I]
      connect_net -net $outputNet -objects [get_pins -of [get_cells ${buffer}_$type] -filter DIRECTION==OUT]
   } else {
      puts "Invalid buffer $buffer of type $ref specifed."
      return
   }
}

#==============================================================
# TCL proc for inserting an FFD on specfied net with specfied clock
#==============================================================
proc insert_flop { net clock } {
   if {![llength [get_clocks -quiet $clock]} {
      set errMsg "Error: Specifiec clock \"$clock\" can not be found in design"
   }

   set driver [get_pins -quiet -of [get_nets $net] -filter "IS_LEAF==1 && DIRECTION==OUT"]
   if {[llength $driver]} {
      set cell "${net}_${type}_inserted"
      disconnect_net -net $net -objects $driver
      create_cell -reference $type $cell
      create_net ${net}_inserted
      connect_net -net ${net}_inserted -objects [list $driver $cell/I]
      connect_net -net ${net} -objects $cell/O
   } else {
      puts "ERROR: Could not find leaf level driver for net $net. Make sure the specified net is at the same level of hierarchy as the leaf level driver."
   }
}
