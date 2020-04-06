#!/usr/bin/env python3

# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

import sys
import soc as soclib
import socmap_gen as socgen
import NoCConfiguration as noclib 

from tkinter import *

def print_ariane_devtree(fp, esp_config):

  # Get CPU base frequency
  with open("top.vhd") as top_fp:
    for line in top_fp:
      if line.find("constant CPU_FREQ : integer") != -1:
        line.strip();
        items = line.split()
        CPU_FREQ = int(items[5].replace(";",""))
        top_fp.close()
        break


  fp.write("/dts-v1/;\n")
  fp.write("\n")
  fp.write("/ {\n")
  fp.write("  #address-cells = <2>;\n")
  fp.write("  #size-cells = <2>;\n")
  fp.write("  compatible = \"eth,ariane-bare-dev\";\n")
  fp.write("  model = \"eth,ariane-bare\";\n")
  fp.write("  chosen {\n")
  fp.write("    stdout-path = \"/soc/uart@" + format(socgen.AHB2APB_HADDR[esp_config.cpu_arch], '03X') + "00100:38400\";\n")
  fp.write("  };\n")
  fp.write("  cpus {\n")
  fp.write("    #address-cells = <1>;\n")
  fp.write("    #size-cells = <0>;\n")
  fp.write("    timebase-frequency = <" + str(int((CPU_FREQ * 1000) / 2)) + ">; // CPU_FREQ / 2\n")
  for i in range(esp_config.ncpu):
    fp.write("    CPU" + str(i) + ": cpu@" + str(i) + " {\n")
    fp.write("      clock-frequency = <" + str(CPU_FREQ) + "000>;\n")
    fp.write("      device_type = \"cpu\";\n")
    fp.write("      reg = <" + str(i) + ">;\n")
    fp.write("      status = \"okay\";\n")
    fp.write("      compatible = \"eth, ariane\", \"riscv\";\n")
    fp.write("      riscv,isa = \"rv64imafdc\";\n")
    fp.write("      mmu-type = \"riscv,sv39\";\n")
    fp.write("      tlb-split;\n")
    fp.write("      // HLIC - hart local interrupt controller\n")
    fp.write("      CPU" + str(i) + "_intc: interrupt-controller {\n")
    fp.write("        #interrupt-cells = <1>;\n")
    fp.write("        interrupt-controller;\n")
    fp.write("        compatible = \"riscv,cpu-intc\";\n")
    fp.write("      };\n")
    fp.write("    };\n")
  fp.write("  };\n")
  fp.write("  memory@" + format(socgen.DDR_HADDR[esp_config.cpu_arch], '03X') + "00000 {\n")
  fp.write("    device_type = \"memory\";\n")
  # TODO: increase memory address space.
  fp.write("    reg = <0x0 0x" + format(socgen.DDR_HADDR[esp_config.cpu_arch], '03X') + "00000 0x0 0x20000000>;\n")
  fp.write("  };\n")
  fp.write("  reserved-memory {\n")
  fp.write("    #address-cells = <2>;\n")
  fp.write("    #size-cells = <2>;\n")
  fp.write("    ranges;\n")
  fp.write("\n")
  fp.write("    greth_reserved: buffer@A0000000 {\n")
  fp.write("      compatible = \"shared-dma-pool\";\n")
  fp.write("      no-map;\n")
  fp.write("      reg = <0x0 0xA0000000 0x0 0x100000>;\n")
  fp.write("    };\n")
  for i in range(esp_config.nacc):
    acc = esp_config.accelerators[i]
    if acc.vendor != "sld":
      mem_address = format(THIRDPARTY_MEM_RESERVED_ADDR[acc.lowercase_name], "08X")
      mem_size = format(THIRDPARTY_MEM_RESERVED_SIZE[acc.lowercase_name], "08X")
      fp.write("\n")
      fp.write("    " + acc.lowercase_name + "_reserved: buffer@" + mem_address + " {\n")
      fp.write("      compatible = \"shared-dma-pool\";\n")
      fp.write("      no-map;\n")
      fp.write("      reg = <0x0 0x" + mem_address + " 0x0 0x" + mem_size + ">;\n")
      fp.write("    };\n")
  fp.write("  };\n")
  fp.write("  L26: soc {\n")
  fp.write("    #address-cells = <2>;\n")
  fp.write("    #size-cells = <2>;\n")
  fp.write("    compatible = \"eth,ariane-bare-soc\", \"simple-bus\";\n")
  fp.write("    ranges;\n")
  # TODO: make clint/plic remote devices w/ remote AXI proxy and variable address to be passed over
  fp.write("    clint@2000000 {\n")
  fp.write("      compatible = \"riscv,clint0\";\n")
  fp.write("      interrupts-extended = <\n")
  for i in range(esp_config.ncpu):
    fp.write("                             &CPU" + str(i) + "_intc 3 &CPU" + str(i) + "_intc 7\n")
  fp.write("                            >;\n")
  fp.write("      reg = <0x0 0x2000000 0x0 0xc0000>;\n")
  fp.write("      reg-names = \"control\";\n")
  fp.write("    };\n")
  fp.write("    PLIC0: interrupt-controller@6c000000 {\n")
  fp.write("      #address-cells = <0>;\n")
  fp.write("      #interrupt-cells = <1>;\n")
  fp.write("      compatible = \"riscv,plic0\";\n")
  fp.write("      interrupt-controller;\n")
  fp.write("      interrupts-extended = <\n")
  for i in range(esp_config.ncpu):
    fp.write("                             &CPU" + str(i) + "_intc 11 &CPU" + str(i) + "_intc 9\n")
  fp.write("                            >;\n")
  fp.write("      reg = <0x0 0x6c000000 0x0 0x4000000>;\n")
  fp.write("      riscv,max-priority = <7>;\n")
  fp.write("      riscv,ndev = <16>;\n")
  fp.write("    };\n")
  # TODO add GPTIMER/Accelerators/Caches/SVGA/DVFS to devtree (and remove leon3 IRQ from socmap
  fp.write("    uart@" + format(socgen.AHB2APB_HADDR[esp_config.cpu_arch], '03X') + "00100 {\n")
  fp.write("      compatible = \"gaisler,apbuart\";\n")
  fp.write("      reg = <0x0 0x" + format(socgen.AHB2APB_HADDR[esp_config.cpu_arch], '03X') + "00100 0x0 0x100>;\n")
  fp.write("      freq = <" + str(CPU_FREQ) + "000>;\n")
  fp.write("      interrupt-parent = <&PLIC0>;\n")
  fp.write("      interrupts = <3>;\n")
  fp.write("      reg-shift = <2>; // regs are spaced on 32 bit boundary\n")
  fp.write("      reg-io-width = <4>; // only 32-bit access are supported\n")
  fp.write("    };\n")
  fp.write("    eth: greth@" + format(socgen.AHB2APB_HADDR[esp_config.cpu_arch], '03X') + "80000 {\n")
  fp.write("      #address-cells = <1>;\n")
  fp.write("      #size-cells = <1>;\n")
  fp.write("      compatible = \"gaisler,ethmac\";\n")
  fp.write("      device_type = \"network\";\n")
  fp.write("      interrupt-parent = <&PLIC0>;\n")
  fp.write("      interrupts = <13 0>;\n")
  # Use randomly generated MAC address
  mac = " ".join(esp_config.linux_mac[i:i+2] for i in range(0, len(esp_config.linux_mac), 2))
  fp.write("      local-mac-address = [" + mac + "];\n")
  fp.write("      reg = <0x0 0x" + format(socgen.AHB2APB_HADDR[esp_config.cpu_arch], '03X') + "80000 0x0 0x10000>;\n")
  fp.write("      phy-handle = <&phy0>;\n")
  fp.write("      phy-connection-type = \"sgmii\";\n")
  fp.write("      memory-region = <&greth_reserved>;\n")
  fp.write("\n")
  fp.write("      phy0: mdio@60001000 {\n")
  fp.write("            #address-cells = <1>;\n")
  fp.write("            #size-cells = <0>;\n")
  fp.write("            compatible = \"gaisler,sgmii\";\n")
  fp.write("            reg = <0x0 0x" + format(socgen.AHB2APB_HADDR[esp_config.cpu_arch], '03X') + "01000 0x0 0x1000>;\n")
  fp.write("            interrupt-parent = <&PLIC0>;\n")
  fp.write("            interrupts = <12 0>;\n")
  fp.write("      };\n")
  fp.write("    };\n")

  for i in range(esp_config.nacc):
    acc = esp_config.accelerators[i]
    if acc.vendor == "sld":
      address = format(socgen.SLD_APB_ADDR + acc.idx, "03x")
      size = "0x100"
    else:
      address = format(THIRDPARTY_APB_ADDR[acc.lowercase_name], "03x")
      size = hex(THIRDPARTY_APB_ADDR_SIZE[acc.lowercase_name])
    fp.write("    " + acc.lowercase_name + "@" + format(socgen.AHB2APB_HADDR[esp_config.cpu_arch], '03x') + str(address) + "00 {\n")
    fp.write("      compatible = \"" + acc.vendor + "," + acc.lowercase_name + "\";\n")
    fp.write("      reg = <0x0 0x" + format(socgen.AHB2APB_HADDR[esp_config.cpu_arch], '03X') + str(address) + "00 0x0 " + size + ">;\n")
    fp.write("      interrupt-parent = <&PLIC0>;\n")
    fp.write("      interrupts = <" + str(acc.irq + 1) + ">;\n")
    fp.write("      reg-shift = <2>; // regs are spaced on 32 bit boundary\n")
    fp.write("      reg-io-width = <4>; // only 32-bit access are supported\n")
    if acc.vendor != "sld":
      fp.write("      memory-region = <&" + acc.lowercase_name + "_reserved>;\n")
    fp.write("    };\n")
  fp.write("  };\n")
  fp.write("};\n")


def main(argv):

  if len(sys.argv) != 4:
    sys.exit(1)

  root = Tk()
  DMA_WIDTH = int(sys.argv[1])
  TECH      = sys.argv[2]
  LINUX_MAC = sys.argv[3]
 
  soc = soclib.SoC_Config(DMA_WIDTH, TECH, LINUX_MAC)
  soc.noc = noclib.NoC()
  soc.read_config(False)

  esp_config = socgen.soc_config(soc)
 
  # Device tree
  if esp_config.cpu_arch == "ariane":

    fp = open('ariane.dts', 'w')

    print_ariane_devtree(fp, esp_config)

    fp.close()

    print("Created device-tree into 'ariane.dts'")

if __name__ == "__main__":
    main(sys.argv)

