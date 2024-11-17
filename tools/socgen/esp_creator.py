#!/usr/bin/env python3

# Copyright (c) 2011-2024 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

###############################################################################
#
# Graphic User Interface for ESP SoC-map
#
###############################################################################

import customtkinter as ctk
import math

import os.path
import shutil
from subprocess import Popen, PIPE

from NoCConfiguration import *
from soc import *
from socmap_gen import *
from mmi64_gen import *

def print_usage():
  print("Usage                    : ./esp_creator.py <arch_bits> <tech_type> <tech> <linux_mac> <leon3_stack> <fpga_board> <emu_tech> <emu_freq>")
  print("")
  print("")
  print("      <arch_bits>        : Word size for CPU architecture (32 for Leon3/Ibex, 64 for Ariane)")
  print("      <tech_type>        : Technology type (fpga or asic)")
  print("      <tech>             : Target technology (e.g. virtex7, virtexu, virtexup, ...)")
  print("      <linux_mac>        : MAC Address for Linux network interface")
  print("      <leon3_stack>      : Stack Pointer for LEON3")
  print("      <fpga_board>       : Target FPGA board")
  print("      <emu_tech>         : Target technology override for FPGA emulation of ASIC design")
  print("      <emu_freq>         : Ethernet MDC scaler override for FPGA emulation of ASIC design")
  print("")

class SocConfigFrame:
  def __init__(self, soc, left_panel):
    self.soc = soc
    self.left_panel = left_panel
    
    self.soc_config_frame = ctk.CTkFrame(self.left_panel, fg_color="#ebebeb")
    self.soc_config_frame.pack(fill="x", padx=(8, 3), pady=10)
    self.soc_config_label = ctk.CTkLabel(self.soc_config_frame, text="SoC Configuration", font=("Arial", 12, "bold"), pady=15)
    self.soc_config_label.grid(row=0, column=0, columnspan=2)

    # Target Technology
    self.tech_label = ctk.CTkLabel(self.soc_config_frame, text="Target Technology", font=("Arial", 10))
    self.tech_label.grid(row=1, column=0, sticky="w", pady=5, padx=15)
    self.tech_value_frame = ctk.CTkFrame(self.soc_config_frame)
    self.tech_value_frame.grid(row=1, column=1, pady=5, padx=15)
    self.tech_value = ctk.CTkLabel(self.tech_value_frame, text="virtex7", width=200, font=("Arial", 10, "bold"))
    self.tech_value.pack(anchor="center", padx=3, pady=3)

    # FPGA Board
    self.fpga_label = ctk.CTkLabel(self.soc_config_frame, text="FPGA Board", font=("Arial", 10))
    self.fpga_label.grid(row=2, column=0, sticky="w", pady=5, padx=15)
    self.fpga_value_frame = ctk.CTkFrame(self.soc_config_frame)
    self.fpga_value_frame.grid(row=2, column=1, pady=5, padx=15)
    self.fpga_value = ctk.CTkLabel(self.fpga_value_frame, text="xilinx-vcu138-xcvu37p", width=200, font=("Arial", 10, "bold"))
    self.fpga_value.pack(anchor="center", padx=3, pady=3)

    # CPU Architecture
    self.cpu_label = ctk.CTkLabel(self.soc_config_frame, text="CPU Architecture", font=("Arial", 10))
    self.cpu_label.grid(row=3, column=0, sticky="w", pady=5, padx=15)
    self.cpu_value_frame = ctk.CTkFrame(self.soc_config_frame)
    self.cpu_value_frame.grid(row=3, column=1, pady=5, padx=15)
    self.cpu_value_menu = ctk.CTkOptionMenu(self.cpu_value_frame, values=["ariane", "leon3"], fg_color="white", 
                          bg_color="#e8e8e8", button_color="#e8e8e8", width=200, text_color="black",
                          font=("Arial", 10), button_hover_color="lightgrey", anchor="center", 
                          dropdown_fg_color="white", dropdown_font=("Arial", 10), 
                          dropdown_hover_color="#e8e8e8")
    self.cpu_value_menu.pack(anchor="center", padx=3, pady=3)

    # NoC/DMA Width
    self.noc_label = ctk.CTkLabel(self.soc_config_frame, text="NoC/DMA Width", font=("Arial", 10))
    self.noc_label.grid(row=4, column=0, sticky="w", pady=5, padx=15)
    self.noc_value_frame = ctk.CTkFrame(self.soc_config_frame)
    self.noc_value_frame.grid(row=4, column=1, pady=5, padx=15)
    self.noc_value = ctk.CTkLabel(self.noc_value_frame, text="64", width=200, font=("Arial", 10, "bold"))
    self.noc_value.pack(anchor="center", padx=3, pady=3)

    # Data Allocation Strategy
    self.das_label = ctk.CTkLabel(self.soc_config_frame, text="Data Allocation Strategy", font=("Arial", 10))
    self.das_label.grid(row=5, column=0, sticky="w", pady=5, padx=15)
    self.das_value_frame = ctk.CTkFrame(self.soc_config_frame)
    self.das_value_frame.grid(row=5, column=1, pady=5, padx=15)
    self.das_value_menu = ctk.CTkOptionMenu(self.das_value_frame, values=["Big physical area", "Scatter/Gatter"], fg_color="white", 
                        bg_color="#e8e8e8", button_color="#e8e8e8", width=200, text_color="black", 
                        font=("Arial", 10), button_hover_color="lightgrey", anchor="center", 
                        dropdown_fg_color="white", dropdown_font=("Arial", 10), 
                        dropdown_hover_color="#e8e8e8")
    self.das_value_menu.pack(anchor="center", padx=3, pady=3)

    # SLM KB per Tile
    self.slm_label = ctk.CTkLabel(self.soc_config_frame, text="SLM KB Per Tile", font=("Arial", 10))
    self.slm_label.grid(row=6, column=0, sticky="w", pady=(5,20), padx=15)
    self.slm_value_frame = ctk.CTkFrame(self.soc_config_frame)
    self.slm_value_frame.grid(row=6, column=1, pady=(5,20), padx=15)
    self.slm_value_menu = ctk.CTkOptionMenu(self.slm_value_frame, values=["64", "138", "256", "513", "1024", "2048", "4096"], fg_color="white", 
                      bg_color="#e8e8e8", button_color="#e8e8e8", width=200, text_color="black",font=("Arial", 10),
                      button_hover_color="lightgrey", anchor="center", dropdown_fg_color="white", dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8")
    self.slm_value_menu.pack(anchor="center", padx=3, pady=3)

class PeripheralsConfigFrame:
  def __init__(self, soc, left_panel):
    self.soc = soc
    self.left_panel = left_panel

    peripherals = [
    ("UART", True), ("JTAG", False), ("Ethernet", True), 
    ("Custom IO Link", False), ("SVGA", False), 
    ("FPGA Memory Link", False)]

    self.peripherals_frame = ctk.CTkFrame(self.left_panel, fg_color="#ebebeb")
    self.peripherals_frame.pack(fill="x", padx=(8,3), pady=(0,10))
    self.peripherals_label = ctk.CTkLabel(self.peripherals_frame, text="Peripherals", font=("Arial", 12, "bold"))
    self.peripherals_label.grid(row=0, column=0, columnspan=2, pady=(10, 15), padx=(15, 0))

    columns = 2
    rows = math.ceil(len(peripherals) / columns)

    for i, (label_text, is_present) in enumerate(peripherals):
        row = (i // columns) + 1
        column = i % columns

        self.pair_frame = ctk.CTkFrame(self.peripherals_frame, fg_color="transparent")
        self.pair_frame.grid(row=row, column=column, padx=(20,10))

        self.checkbox = ctk.CTkCheckBox(
            self.pair_frame,
            text="",
            state="normal",  # Enable only "Ethernet"
            fg_color="green",
            border_color="grey",
            corner_radius=0,
            width=0,
            checkbox_width=18,
            checkbox_height=18,
            hover=False
        )

        self.label = ctk.CTkLabel(self.pair_frame, text=label_text, font=("Arial", 11), width=140, anchor="w")
        self.label.pack(side="right", pady=10)
        
        if is_present:
            self.label.configure(text_color="black")
            self.checkbox.select()
        self.checkbox.pack(side="left", anchor="e")

class DebugLinkConfigFrame:
  def __init__(self, soc, left_panel):
    self.soc = soc
    self.left_panel = left_panel

    self.debug_link_frame = ctk.CTkFrame(self.left_panel, fg_color="#ebebeb")
    self.debug_link_frame.pack(fill="x", padx=(8,3), pady=10)
    self.debug_link_label = ctk.CTkLabel(self.debug_link_frame, text="Debug Link", font=("Arial", 12, "bold"), pady=15)
    self.debug_link_label.grid(row=0, column=0, columnspan=2)

    # IP Address (dec) 
    self.ip_addr_label = ctk.CTkLabel(self.debug_link_frame, text="IP Address (dec)", font=("Arial", 10))
    self.ip_addr_value_frame = ctk.CTkFrame(self.debug_link_frame)
    self.ip_addr_value_frame.grid(row=1, column=1, pady=5, padx=15)
    self.ip_addr_value = ctk.CTkLabel(self.ip_addr_value_frame, text="192.168.1.12", width=200, font=("Arial", 10, "bold"))
    self.ip_addr_value.pack(anchor="center")
    self.ip_addr_label.grid(row=1, column=0, sticky="w", pady=5, padx=20)

    # IP Address (hex) 
    self.ip_addr_label = ctk.CTkLabel(self.debug_link_frame, text="IP Address (hex)", font=("Arial", 10))
    self.ip_addr_value_frame = ctk.CTkFrame(self.debug_link_frame)
    self.ip_addr_value_frame.grid(row=2, column=1, pady=5, padx=15)
    self.ip_addr_value = ctk.CTkEntry(self.ip_addr_value_frame, placeholder_text="C0A8010C", width=200, font=("Arial", 10), 
                         placeholder_text_color="black", border_width=0)
    self.ip_addr_value.pack(anchor="center", padx=3, pady=3)
    self.ip_addr_label.grid(row=2, column=0, sticky="w", pady=5, padx=20)

    # MAC Address (hex)
    self.mac_addr_label = ctk.CTkLabel(self.debug_link_frame, text="MAC Address (hex)", font=("Arial", 10))
    self.mac_addr_value_frame = ctk.CTkFrame(self.debug_link_frame)
    self.mac_addr_value_frame.grid(row=3, column=1, pady=5, padx=15)
    self.mac_addr_value = ctk.CTkEntry(self.mac_addr_value_frame, placeholder_text="A6A7A0F80442", width=200, font=("Arial", 10), 
                          placeholder_text_color="black", border_width=0)
    self.mac_addr_value.pack(anchor="center", padx=3, pady=3)
    self.mac_addr_label.grid(row=3, column=0, sticky="w", pady=5, padx=20)

class CachesConfigFrame:
  def __init__(self, soc, left_panel):
    self.soc = soc
    self.left_panel = left_panel

    self.caches_frame = ctk.CTkFrame(self.left_panel, fg_color="#ebebeb")
    self.caches_frame.pack(padx=(8, 3), pady=(10,20), fill="x")
    self.title_label = ctk.CTkLabel(self.caches_frame, text="Caches Configuration", font=("Arial", 12, "bold"))
    self.title_label.grid(row=0, column=0, columnspan=2, pady=10)


    self.enable_caches_cb = ctk.CTkCheckBox(self.caches_frame, text="Enable Caches", fg_color="green", border_color="grey",
                            width=0, corner_radius=0, checkbox_width=18, checkbox_height=18, font=("Arial", 10), hover=False)
    self.enable_caches_cb.grid(row=1, column=0, sticky="w", padx=20, pady=20)

    self.l2_label = ctk.CTkLabel(self.caches_frame, text="Implementation", font=("Arial", 10))
    self.l2_label.grid(row=2, column=0, padx=20, pady=(10, 5), sticky="w")

    self.esp_rtl_frame = ctk.CTkFrame(self.caches_frame)
    self.esp_rtl_frame.grid(row=2, column=1, padx=20, pady=5)
    self.esp_rtl_dd = ctk.CTkOptionMenu(self.esp_rtl_frame, values=["ESP RTL"], fg_color="white", bg_color="#e8e8e8", 
                      button_color="#e8e8e8", text_color="black", font=("Arial", 10), 
                      button_hover_color="lightgrey", width=160)
    self.esp_rtl_dd.set("ESP RTL")
    self.esp_rtl_dd.pack(padx=3, pady=3)

    self.l2_label = ctk.CTkLabel(self.caches_frame, text="Cache Line Size", font=("Arial", 10))
    self.l2_label.grid(row=3, column=0, padx=20, pady=(10, 5), sticky="w")

    self.cache_line_frame = ctk.CTkFrame(self.caches_frame)
    self.cache_line_frame.grid(row=3, column=1, padx=20, pady=5)
    self.cache_line_dd = ctk.CTkOptionMenu(self.cache_line_frame, values=["128", "256"], fg_color="white", 
                         bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black",
                         font=("Arial", 10), button_hover_color="lightgrey", width=160)
    self.cache_line_dd.set("128")
    self.cache_line_dd.pack(padx=3, pady=3)

    self.l2_label = ctk.CTkLabel(self.caches_frame, text="L2 Properties", font=("Arial", 10))
    self.llc_label = ctk.CTkLabel(self.caches_frame, text="LLC Properties", font=("Arial", 10))
    self.acc_l2_label = ctk.CTkLabel(self.caches_frame, text="Acc L2 Properties", font=("Arial", 10))

    self.l2_label.grid(row=4, column=0, padx=20, pady=(10, 5), sticky="w")
    self.llc_label.grid(row=4, column=1, padx=20, pady=(10, 5), sticky="w")
    self.acc_l2_label.grid(row=7, column=0, padx=20, pady=(10, 5), sticky="w")

    ways_options = ["4 ways", "8 ways", "16 ways"]
    sets_options = ["512 sets", "1024 sets", "2048 sets"]

    self.l2_ways_frame = ctk.CTkFrame(self.caches_frame)
    self.l2_ways_frame.grid(row=5, column=0, padx=20, pady=5)
    self.l2_ways_dd = ctk.CTkOptionMenu(self.l2_ways_frame, values=ways_options, fg_color="white",
                      bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black",
                      font=("Arial", 10), button_hover_color="lightgrey", width=165)
    self.l2_ways_dd.set(ways_options[0])
    self.l2_ways_dd.pack(padx=3, pady=3)

    self.l2_sets_frame = ctk.CTkFrame(self.caches_frame)
    self.l2_sets_frame.grid(row=6, column=0, padx=20, pady=5)
    self.l2_sets_dd = ctk.CTkOptionMenu(self.l2_sets_frame, values=sets_options, fg_color="white",
                      bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black",
                      font=("Arial", 10), button_hover_color="lightgrey", width=165)
    self.l2_sets_dd.set(sets_options[0])
    self.l2_sets_dd.pack(padx=3, pady=3)

    self.llc_ways_frame = ctk.CTkFrame(self.caches_frame)
    self.llc_ways_frame.grid(row=5, column=1, padx=20, pady=5)
    self.llc_ways_dd = ctk.CTkOptionMenu(self.llc_ways_frame, values=ways_options, fg_color="white",
                       bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black",
                       font=("Arial", 10), button_hover_color="lightgrey", width=165)
    self.llc_ways_dd.set(ways_options[2])
    self.llc_ways_dd.pack(padx=3, pady=3)

    self.llc_sets_frame = ctk.CTkFrame(self.caches_frame)
    self.llc_sets_frame.grid(row=6, column=1, padx=20, pady=5)
    self.llc_sets_dd = ctk.CTkOptionMenu(self.llc_sets_frame, values=sets_options, fg_color="white",
                       bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black",
                       font=("Arial", 10), button_hover_color="lightgrey", width=165)
    self.llc_sets_dd.set(sets_options[1])
    self.llc_sets_dd.pack(padx=3, pady=3)

    self.acc_l2_ways_frame = ctk.CTkFrame(self.caches_frame)
    self.acc_l2_ways_frame.grid(row=8, column=0, padx=20, pady=5)
    self.acc_l2_ways_dd = ctk.CTkOptionMenu(self.acc_l2_ways_frame, values=ways_options, fg_color="white",
                          bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black",
                          font=("Arial", 10), button_hover_color="lightgrey", width=165)
    self.acc_l2_ways_dd.set(ways_options[0])
    self.acc_l2_ways_dd.pack(padx=3, pady=3)

    self.acc_l2_sets_frame = ctk.CTkFrame(self.caches_frame)
    self.acc_l2_sets_frame.grid(row=9, column=0, padx=20, pady=5)
    self.acc_l2_sets_dd = ctk.CTkOptionMenu(self.acc_l2_sets_frame, values=sets_options, fg_color="white",
                          bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black",
                          font=("Arial", 10), button_hover_color="lightgrey", width=165)
    self.acc_l2_sets_dd.set(sets_options[0])
    self.acc_l2_sets_dd.pack(padx=3, pady=3)

class NoCConfigFrame:
  def __init__(self, soc, left_panel):
    self.soc = soc
    self.left_panel = left_panel

    self.noc_select_frame = ctk.CTkFrame(self.left_panel, fg_color="#ebebeb")
    self.noc_select_frame.pack(padx=(8,3), pady=(10,20), fill="x")
    self.title_label = ctk.CTkLabel(self.noc_select_frame, text="NoC Configuration", font=("Arial", 12, "bold"))
    self.title_label.grid(row=0, column=0, columnspan=2, pady=10)

    # noc_rows_label = ctk.CTkLabel(noc_select_frame, text="Rows:")
    # noc_rows_label.grid(row=1, column=0, padx=5, pady=5, sticky="e")
    # noc_rows = ctk.CTkEntry(noc_select_frame, width=50)
    # noc_rows.insert(0, "2")
    # noc_rows.grid(row=1, column=1, padx=5, pady=5)

    # noc_columns_label = ctk.CTkLabel(noc_select_frame, text="Columns:")
    # noc_columns_label.grid(row=1, column=2, padx=5, pady=5, sticky="e")
    # noc_columns = ctk.CTkEntry(noc_select_frame, width=50)
    # noc_columns.insert(0, "2")
    # noc_columns.grid(row=1, column=3, padx=5, pady=5)

    # update_noc_button = ctk.CTkButton(noc_select_frame, text="Update NoC", width=100, font=("Arial", 12))
    #update_noc_button.grid(row=1, column=4, padx=10, pady=5)

    self.noc_planes_label = ctk.CTkLabel(self.noc_select_frame, text="Coherence NoC Planes (1,2,3) Bitwidth", font=("Arial", 10))
    self.noc_planes_frame = ctk.CTkFrame(self.noc_select_frame)
    self.noc_planes_frame.grid(row=2, column=1, pady=5, padx=15)
    self.noc_planes_value_menu = ctk.CTkOptionMenu(self.noc_planes_frame, values=["64", "32"], fg_color="white", 
                      bg_color="#e8e8e8", button_color="#e8e8e8", width=100, text_color="black",font=("Arial", 10),
                      button_hover_color="lightgrey", anchor="center", dropdown_fg_color="white", dropdown_font=("Arial", 10), 
					  dropdown_hover_color="#e8e8e8")
    self.noc_planes_value_menu.pack(anchor="center", padx=3, pady=3)
    self.noc_planes_label.grid(row=2, column=0, sticky="w", pady=5, padx=15)

    self.dma_planes_label = ctk.CTkLabel(self.noc_select_frame, text="DMA NoC Planes (4,6) Bitwidth", font=("Arial", 10))
    self.dma_planes_value_frame = ctk.CTkFrame(self.noc_select_frame)
    self.dma_planes_value_frame.grid(row=3, column=1, pady=5, padx=15)
    self.dma_planes_value_menu = ctk.CTkOptionMenu(self.dma_planes_value_frame, values=["64", "32"], fg_color="white", 
                      bg_color="#e8e8e8", button_color="#e8e8e8", width=100, text_color="black",font=("Arial", 10),
                      button_hover_color="lightgrey", anchor="center", dropdown_fg_color="white", dropdown_font=("Arial", 10), 
					  dropdown_hover_color="#e8e8e8")
    self.dma_planes_value_menu.pack(anchor="center", padx=3, pady=3)
    self.dma_planes_label.grid(row=3, column=0, sticky="w", pady=5, padx=15)

    self.enable_multicast_cb = ctk.CTkCheckBox(self.noc_select_frame, text="Enable Multicast on DMA Planes", font=("Arial", 11),
                               fg_color="green", border_color="grey", width=0, corner_radius=0, checkbox_width=18,
                               checkbox_height=18, hover=False)
    self.enable_multicast_cb.grid(row=4, column=0, sticky="w", padx=15, pady=10)

    self.max_multicast_label = ctk.CTkLabel(self.noc_select_frame, text="Maximum Multicast Destinations", font=("Arial", 11))
    self.max_multicast_value_frame = ctk.CTkFrame(self.noc_select_frame)
    self.max_multicast_value_frame.grid(row=5, column=1, pady=5, padx=15)
    self.max_multicast_value_menu = ctk.CTkOptionMenu(self.max_multicast_value_frame, values=["2", "3"], fg_color="white", 
                      bg_color="#e8e8e8", button_color="#e8e8e8", width=100, text_color="black",font=("Arial", 10),
                      button_hover_color="lightgrey", anchor="center", dropdown_fg_color="white", dropdown_font=("Arial", 10),
					  dropdown_hover_color="#e8e8e8")
    self.max_multicast_value_menu.pack(anchor="center", padx=3, pady=3)
    self.max_multicast_label.grid(row=5, column=0, sticky="w", pady=5, padx=15)

class ProbeConfigFrame:
	def __init__(self, soc, left_panel):
		self.soc = soc
		self.left_panel = left_panel

		self.probe_frame = ctk.CTkFrame(self.left_panel, fg_color="#ebebeb")
		self.probe_frame.pack(padx=(8,3), pady=10, fill="x")
		self.title_label = ctk.CTkLabel(self.probe_frame, text="Probe Configuration", font=("Arial", 12, "bold"))
		self.title_label.pack(pady=10)

		self.ddr_cb = ctk.CTkCheckBox(self.probe_frame, text="Monitor DDR bandwidth", font=("Arial", 11), fg_color="green",
					  border_color="grey", width=0, corner_radius=0, checkbox_width=18, checkbox_height=18,
					  hover=False)
		self.ddr_cb.pack(padx=15, pady=10, anchor="w")

		self.mem_access_cb = ctk.CTkCheckBox(self.probe_frame, text="Monitor Memory Access", font=("Arial", 11), fg_color="green",
						   border_color="grey", width=0, corner_radius=0, checkbox_width=18, checkbox_height=18,
						   hover=False)
		self.mem_access_cb.pack(padx=15, pady=10, anchor="w")

		self.inj_rate_cb = ctk.CTkCheckBox(self.probe_frame, text="Monitor Injection Rate", font=("Arial", 11), fg_color="green",
						   border_color="grey", width=0, corner_radius=0, checkbox_width=18, checkbox_height=18,
						   hover=False)
		self.inj_rate_cb.pack(padx=15, pady=10, anchor="w")

		self.router_ports_cb = ctk.CTkCheckBox(self.probe_frame, text="Monitor Router Ports", font=("Arial", 11), fg_color="green",
						   border_color="grey", width=0, corner_radius=0, checkbox_width=18, checkbox_height=18,
						   hover=False)
		self.router_ports_cb.pack(padx=15, pady=10, anchor="w")

		self.acc_status_cb = ctk.CTkCheckBox(self.probe_frame, text="Monitor Accelerator Status", font=("Arial", 11), fg_color="green",
						   border_color="grey", width=0, corner_radius=0, checkbox_width=18, checkbox_height=18,
						   hover=False)
		self.acc_status_cb.pack(padx=15, pady=10, anchor="w")

		self.l2_hm_cb = ctk.CTkCheckBox(self.probe_frame, text="Monitor L2 Hit/Miss", font=("Arial", 11), fg_color="green",
						   border_color="grey", width=0, corner_radius=0, checkbox_width=18, checkbox_height=18,
						   hover=False)
		self.l2_hm_cb.pack(padx=15, pady=10, anchor="w")

		self.llc_hm_cb = ctk.CTkCheckBox(self.probe_frame, text="Monitor LLC Hit/Miss", font=("Arial", 11), fg_color="green",
						 border_color="grey", width=0, corner_radius=0, checkbox_width=18, checkbox_height=18,
						 hover=False)
		self.llc_hm_cb.pack(padx=15, pady=10, anchor="w")

		self.dvfs_cb = ctk.CTkCheckBox(self.probe_frame, text="Monitor DVFS", font=("Arial", 11), fg_color="green",
					   border_color="grey", width=0, corner_radius=0, checkbox_width=18, checkbox_height=18,
					   hover=False)
		self.dvfs_cb.pack(padx=15, pady=10, anchor="w")

class EspCreator:
  def __init__(self, root, _soc):
    self.soc = _soc
    # self.noc = self.soc.noc
    self.root = root

    # Scrollable main frame
    self.main_frame = ctk.CTkScrollableFrame(self.root)
    self.main_frame.pack(padx=10, pady=10, fill="both", expand=True)

    # Scrollable left panel
    self.left_panel = ctk.CTkScrollableFrame(self.main_frame, width=440, height=900)
    self.left_panel.grid(row=0, column=0, sticky="ns", padx=10, pady=10)

    # Static configuration frames
    self.soc_config_frame = SocConfigFrame(self.soc, self.left_panel)
    self.peripherals_config_frame = PeripheralsConfigFrame(self.soc, self.left_panel)
    self.debug_link_config_frame = DebugLinkConfigFrame(self.soc, self.left_panel)
    self.caches_config_frame = CachesConfigFrame(self.soc, self.left_panel)
    self.noc_config_frame = NoCConfigFrame(self.soc, self.left_panel)
    self.probe_config_frame = ProbeConfigFrame(self.soc, self.left_panel)
    
    self.gen_soc_config = ctk.CTkButton(self.left_panel, text="Generate SoC Configuration", font=("Arial", 12), height=40, width=150)
    self.gen_soc_config.pack(fill="x", pady=15)

ARCH_BITS = int(sys.argv[1])
TECH_TYPE = sys.argv[2]
TECH = sys.argv[3]
LINUX_MAC = sys.argv[4]
LEON3_STACK = sys.argv[5]
FPGA_BOARD = sys.argv[6]
EMU_TECH = sys.argv[7]
EMU_FREQ = sys.argv[8]

ctk.set_appearance_mode("light")
ctk.set_default_color_theme("dark-blue")

root = ctk.CTk()
root.title("ESP SoC Generator")
soc = SoC_Config(ARCH_BITS, TECH_TYPE, TECH, LINUX_MAC, LEON3_STACK, FPGA_BOARD, EMU_TECH, EMU_FREQ, True)
root.geometry("1300x800")
# w, h = root.winfo_screenwidth(), root.winfo_screenheight()
# root.geometry("%dx%d+0+0" % (w, h))
app = EspCreator(root, soc)

def on_closing():
  if messagebox.askokcancel("Quit", "Do you want to quit?"):
    # soc.write_config(app.peripheral_frame.DSU_IP.get(), app.peripheral_frame.DSU_ETH.get())
    root.destroy()

root.protocol("WM_DELETE_WINDOW", on_closing)
root.mainloop()