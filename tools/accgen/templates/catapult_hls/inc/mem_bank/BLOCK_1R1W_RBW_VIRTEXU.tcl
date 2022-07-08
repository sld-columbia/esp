flow package require MemGen
flow run /MemGen/MemoryGenerator_BuildLib {
VENDOR           Xilinx
RTLTOOL          Vivado
TECHNOLOGY       VIRTEX-u
LIBRARY          BLOCK_1R1W_RBW
MODULE           BLOCK_1R1W_RBW
OUTPUT_DIR       ../inc/mem_bank
FILES {
  { FILENAME ../inc/mem_bank/BLOCK_1R1W_RBW.v FILETYPE Verilog MODELTYPE generic PARSE 1 PATHTYPE copy STATICFILE 1 VHDL_LIB_MAPS work }
}
VHDLARRAYPATH    {}
WRITEDELAY       0.1
INITDELAY        1
READDELAY        0.1
VERILOGARRAYPATH {}
TIMEUNIT         1ns
INPUTDELAY       0.01
WIDTH            data_width
AREA             0
WRITELATENCY     1
RDWRRESOLUTION   RBW
READLATENCY      1
DEPTH            depth
PARAMETERS {
  { PARAMETER addr_width TYPE hdl IGNORE 0 MIN {} MAX {} DEFAULT 0 }
  { PARAMETER data_width TYPE hdl IGNORE 0 MIN {} MAX {} DEFAULT 0 }
  { PARAMETER depth      TYPE hdl IGNORE 0 MIN {} MAX {} DEFAULT 0 }
}
PORTS {
  { NAME port_0 MODE Read  }
  { NAME port_1 MODE Write }
}
PINMAPS {
  { PHYPIN clk   LOGPIN CLOCK        DIRECTION in  WIDTH 1.0        PHASE 1  DEFAULT {} PORTS {port_0 port_1} }
  { PHYPIN clken LOGPIN ENABLE       DIRECTION in  WIDTH 1.0        PHASE 1  DEFAULT {} PORTS {port_0 port_1} }
  { PHYPIN d     LOGPIN DATA_IN      DIRECTION in  WIDTH data_width PHASE {} DEFAULT {} PORTS port_1          }
  { PHYPIN q     LOGPIN DATA_OUT     DIRECTION out WIDTH data_width PHASE {} DEFAULT {} PORTS port_0          }
  { PHYPIN radr  LOGPIN ADDRESS      DIRECTION in  WIDTH addr_width PHASE {} DEFAULT {} PORTS port_0          }
  { PHYPIN wadr  LOGPIN ADDRESS      DIRECTION in  WIDTH addr_width PHASE {} DEFAULT {} PORTS port_1          }
  { PHYPIN we    LOGPIN WRITE_ENABLE DIRECTION in  WIDTH 1.0        PHASE 1  DEFAULT {} PORTS port_1          }
}

}
