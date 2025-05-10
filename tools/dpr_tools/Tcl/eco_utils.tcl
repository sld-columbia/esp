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
   #place_design -unplace
   foreach buf $buffers {
      set inputNet [get_nets -of [get_pins $buf/I]]
      set outputNet [get_nets -of [get_pins $buf/O]]
      set loads [get_pins -of [get_nets $outputNet] -filter NAME!=$buf/O]
      set port  [get_ports -of [get_nets $outputNet]]
      puts "Buffer: $buffers"
      puts "Output net: $outputNet"
      puts "Ports: $port"
      puts "Loads: $loads"
      remove_cell $buf
      remove_net $outputNet
      #Check if no net was not connect to any pins.  May be a port instead.
      if {[llength $loads]} {
         connect_net -net $inputNet -objects [get_pins $loads]
      } 
      if {[llength $port]} {
         connect_net -net $inputNet -objects [get_ports $port]
      }
      if {![llength $port] && ![llength $loads]} {
         puts "Critical Warning: No pin or port connections found on output of buffer $buf. Buffer was removed, but input net $inputNet was not connected to any loads."
      }
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


#================================================================
# Tcl proc to replicate BUFG_GT to separate out GT and fabric 
# loads from TX/RXUSRCLK2. This makes delay matching between
# TX/RXUSRCLK and TX/RXUSRCLK2 unnecessary since both only have
# a single GT load.
#================================================================
proc split_BUFG_GT_load {BUFG_GT_cells} {
   foreach BUFG_GT [get_cells $BUFG_GT_cells -filter LIB_CELL=~BUFG*] {
      puts "re-wiring BUFG_GT connections for $BUFG_GT"
		set clk_src_net [get_nets -of [get_pins -of $BUFG_GT -filter REF_PIN_NAME==I]]
		
		create_cell -reference [get_lib_cells -of $BUFG_GT] [get_property NAME $BUFG_GT]_GT
		set BUFG_GT_GT [get_cells [get_property NAME $BUFG_GT]_GT]
		
		#connect all pins of original BUFG_GT to copy
		foreach pin [get_pins -of $BUFG_GT -filter DIRECTION==IN] {
			set source_net [get_nets -of $pin]
			connect_net -net $source_net -obj [get_pins -of $BUFG_GT_GT -filter REF_PIN_NAME==[get_property REF_PIN_NAME $pin]]
		}
		
		set BUFG_GT_net [get_nets -of [get_pins -of $BUFG_GT -filter DIRECTION==OUT]]
		set BUFG_GT_GT_net [get_property NAME $BUFG_GT_net]_GT
		create_net $BUFG_GT_GT_net
		connect_net -net  $BUFG_GT_GT_net -objects [get_pins -of $BUFG_GT_GT -filter DIRECTION==OUT]
		
		set BUFG_GT_fo [get_property FLAT_PIN_COUNT $BUFG_GT_net] 
		
		# For PRIMITIVE Cells
		set dtc [get_cells -hier -filter {DONT_TOUCH==1 && IS_DEBUG_CORE!=1}]
		set check [llength $dtc]

		if {$check > 0} {set_property DONT_TOUCH 0 $dtc}
		
		set total_pins [get_pins -leaf -of $BUFG_GT_net -filter DIRECTION==IN]
		set GT_pins [get_pins -leaf -of $BUFG_GT_net -filter REF_NAME=~GT*CHANNEL&&DIRECTION==IN]
		set user_pins [get_pins -leaf -of $BUFG_GT_net -filter REF_NAME!~GT*CHANNEL&&DIRECTION==IN]
		
		puts "total loads: [llength $total_pins]\nGT_CHANNEL loads: [llength $GT_pins]\nUser Logic loads: [llength $user_pins]\n"

		set legalIpins ""
		array set netToDisconnect [list]
		# Replacing internal pins with macro pins + consolidating pairs of net-pins to disconnect to save runtime
		foreach ipin $GT_pins {
		  if {[get_property PRIMITIVE_LEVEL [get_cells -of $ipin]] == "INTERNAL"} {
			set tmp [get_pins -filter "REF_NAME == [get_property REF_NAME [get_property PARENT [get_cells -of $ipin]]]" -of [get_nets -of $ipin]]
		  } else {
			set tmp $ipin
		  }
		  lappend legalIpins $tmp
		  lappend netToDisconnect([get_nets -of $tmp]) $tmp
		}
		
		# Disconnecting leaf pins from original BUFGCE fanout
		foreach {net pins} [array get netToDisconnect] {
		  disconnect_net -net $net -objects [lsort -unique $pins]
		}
		
		# Connecting leaf pins to new BUFGCE fanout
		connect_net -net $BUFG_GT_GT_net -objects [lsort -unique $legalIpins] -hier
		puts "total loads: [llength $total_pins]\nGT_CHANNEL loads: [expr [get_property FLAT_PIN_COUNT [get_nets $BUFG_GT_GT_net]] - 1]\nUser Logic loads: [expr [get_property FLAT_PIN_COUNT [get_nets $BUFG_GT_net]] - 1]\n"
		
		
		if {$check > 0} {set_property DONT_TOUCH 1 $dtc}
		set dtc [get_cells -hier -filter {DONT_TOUCH==1 && IS_DEBUG_CORE!=1}]
		set check [llength $dtc]
	}

}

