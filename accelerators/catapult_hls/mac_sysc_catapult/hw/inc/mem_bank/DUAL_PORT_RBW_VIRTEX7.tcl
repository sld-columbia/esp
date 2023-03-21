#Copyright (c) 2011-2023 Columbia University, System Level Design Group
#SPDX-License-Identifier: Apache-2.0

flow package require MemGen
flow run /MemGen/MemoryGenerator_BuildLib {
VENDOR           Xilinx
RTLTOOL          Vivado
TECHNOLOGY       VIRTEX-7
LIBRARY          DUAL_PORT_RBW
MODULE           DUAL_PORT_RBW
OUTPUT_DIR       ../inc/mem_bank
FILES {
    { FILENAME ../inc/mem_bank/DUAL_PORT_RBW.v FILETYPE Verilog MODELTYPE generic PARSE 1 PATHTYPE copy STATICFILE 1 VHDL_LIB_MAPS work }
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
DEPTH            Sz
PARAMETERS {
  { PARAMETER AddressSz TYPE hdl IGNORE 0 MIN {} MAX {} DEFAULT 0 }
  { PARAMETER data_width TYPE hdl IGNORE 0 MIN {} MAX {} DEFAULT 0 }
  { PARAMETER Sz      TYPE hdl IGNORE 0 MIN {} MAX {} DEFAULT 0 }
}
PORTS {
  { NAME port_0 MODE Read  }
  { NAME port_1 MODE Write }
}
PINMAPS {
  { PHYPIN clk   LOGPIN CLOCK        DIRECTION in  WIDTH 1.0        PHASE 1  DEFAULT {} PORTS {port_0 port_1} }
  { PHYPIN clk_en LOGPIN ENABLE       DIRECTION in  WIDTH 1.0        PHASE 1  DEFAULT {} PORTS {port_0 port_1} }
  { PHYPIN din     LOGPIN DATA_IN      DIRECTION in  WIDTH data_width PHASE {} DEFAULT {} PORTS port_1          }
  { PHYPIN qout     LOGPIN DATA_OUT     DIRECTION out WIDTH data_width PHASE {} DEFAULT {} PORTS port_0          }
  { PHYPIN r_adr  LOGPIN ADDRESS      DIRECTION in  WIDTH AddressSz PHASE {} DEFAULT {} PORTS port_0          }
  { PHYPIN w_adr  LOGPIN ADDRESS      DIRECTION in  WIDTH AddressSz PHASE {} DEFAULT {} PORTS port_1          }
  { PHYPIN w_en    LOGPIN WRITE_ENABLE DIRECTION in  WIDTH 1.0        PHASE 1  DEFAULT {} PORTS port_1          }
}

}
