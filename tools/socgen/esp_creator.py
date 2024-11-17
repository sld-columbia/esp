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
  def set_cpu_specific_labels(self, soc):
    if soc.CPU_ARCH.get() == "ariane":
      self.fpu_value.configure(text="ETH FPnew")
    elif soc.CPU_ARCH.get() == "leon3" and soc.LEON3_HAS_FPU == "7":
      self.fpu_value.configure(text="SLD FPU")
    elif soc.CPU_ARCH.get() == "leon3" and soc.LEON3_HAS_FPU == "(1+0)":
      self.fpu_value.configure(text="GRFPU")
    else:
      self.fpu_value.configure(text="None")

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
    self.tech_value = ctk.CTkLabel(self.tech_value_frame, text=self.soc.TECH, width=200, font=("Arial", 10, "bold"))
    self.tech_value.pack(anchor="center", padx=3, pady=3)

    # FPGA Board
    self.fpga_label = ctk.CTkLabel(self.soc_config_frame, text="FPGA Board", font=("Arial", 10))
    self.fpga_label.grid(row=2, column=0, sticky="w", pady=5, padx=15)
    self.fpga_value_frame = ctk.CTkFrame(self.soc_config_frame)
    self.fpga_value_frame.grid(row=2, column=1, pady=5, padx=15)
    self.fpga_value = ctk.CTkLabel(self.fpga_value_frame, text=self.soc.FPGA_BOARD, width=200, font=("Arial", 10, "bold"))
    self.fpga_value.pack(anchor="center", padx=3, pady=3)

    # CPU Architecture
    self.cpu_choices = ["leon3", "ariane", "ibex"]
    self.cpu_label = ctk.CTkLabel(self.soc_config_frame, text="CPU Architecture", font=("Arial", 10))
    self.cpu_label.grid(row=3, column=0, sticky="w", pady=5, padx=15)
    self.cpu_value_frame = ctk.CTkFrame(self.soc_config_frame)
    self.cpu_value_frame.grid(row=3, column=1, pady=5, padx=15)
    self.cpu_value_menu = ctk.CTkOptionMenu(self.cpu_value_frame, values=self.cpu_choices, fg_color="white", 
                          bg_color="#e8e8e8", button_color="#e8e8e8", width=200, text_color="black",
                          font=("Arial", 10), button_hover_color="lightgrey", anchor="center", 
                          dropdown_fg_color="white", dropdown_font=("Arial", 10), 
                          dropdown_hover_color="#e8e8e8")
    self.cpu_value_menu.pack(anchor="center", padx=3, pady=3)

    # FPU
    self.fpu_label = ctk.CTkLabel(self.soc_config_frame, text="Floating-Point Unit", font=("Arial", 10))
    self.fpu_label.grid(row=4, column=0, sticky="w", pady=5, padx=15)
    self.fpu_value_frame = ctk.CTkFrame(self.soc_config_frame)
    self.fpu_value_frame.grid(row=4, column=1, pady=5, padx=15)
    self.fpu_value = ctk.CTkLabel(self.fpu_value_frame, width=200, font=("Arial", 10, "bold"))
    self.fpu_value.pack(anchor="center", padx=3, pady=3)
    self.set_cpu_specific_labels(self.soc)

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
    self.slm_kbytes_choices = ["64", "128", "256", "512", "1024", "2048", "4096"]
    self.slm_label = ctk.CTkLabel(self.soc_config_frame, text="SLM KB Per Tile", font=("Arial", 10))
    self.slm_label.grid(row=6, column=0, sticky="w", pady=(5,20), padx=15)
    self.slm_value_frame = ctk.CTkFrame(self.soc_config_frame)
    self.slm_value_frame.grid(row=6, column=1, pady=(5,20), padx=15)
    self.slm_value_menu = ctk.CTkOptionMenu(self.slm_value_frame, values=self.slm_kbytes_choices, fg_color="white", 
                      bg_color="#e8e8e8", button_color="#e8e8e8", width=200, text_color="black",font=("Arial", 10),
                      button_hover_color="lightgrey", anchor="center", dropdown_fg_color="white", dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8")
    self.slm_value_menu.pack(anchor="center", padx=3, pady=3)

class PeripheralsConfigFrame:
  def __init__(self, soc, left_panel):
    self.soc = soc
    self.left_panel = left_panel

    # peripherals = [
    # ("UART", True), ("JTAG", False), ("Ethernet", True), 
    # ("Custom IO Link", False), ("SVGA", False), 
    # ("FPGA Memory Link", False)]

    self.peripherals_frame = ctk.CTkFrame(self.left_panel, fg_color="#ebebeb")
    self.peripherals_frame.pack(fill="x", padx=(8,3), pady=(0,10))
    self.peripherals_label = ctk.CTkLabel(self.peripherals_frame, text="Peripherals", font=("Arial", 12, "bold"))
    self.peripherals_label.grid(row=0, column=0, columnspan=2, pady=(10, 15), padx=(15, 0))

    # UART
    self.pair_frame = ctk.CTkFrame(self.peripherals_frame, fg_color="transparent")
    self.pair_frame.grid(row=1, column=0, padx=(20,10))
    self.uart_checkbox = ctk.CTkCheckBox(
        self.pair_frame,
        text="",
        state="disabled",
        fg_color="green",
        border_color="grey",
        corner_radius=0,
        width=0,
        checkbox_width=18,
        checkbox_height=18,
        hover=False
    )
    self.uart_checkbox.select()
    self.uart_label = ctk.CTkLabel(self.pair_frame, text="UART", font=("Arial", 11), width=140, anchor="w")
    self.uart_label.pack(side="right", pady=10)
    self.uart_checkbox.pack(side="left", anchor="e")

    # JTAG
    self.pair_frame = ctk.CTkFrame(self.peripherals_frame, fg_color="transparent")
    self.pair_frame.grid(row=1, column=1, padx=(20,10))
    self.jtag_checkbox = ctk.CTkCheckBox(
        self.pair_frame,
        text="",
        variable=self.soc.jtag_en,
        # command=main_frame.update_noc_config,
        state="disabled",
        onvalue = 1, 
        offvalue = 0,
        fg_color="green",
        border_color="grey",
        corner_radius=0,
        width=0,
        checkbox_width=18,
        checkbox_height=18,
        hover=False
    )
    if soc.TECH_TYPE == "asic" or soc.TECH == "inferred" or soc.ESP_EMU_TECH != "none":
      self.jtag_checkbox.configure(state="normal")
      self.jtag_label = ctk.CTkLabel(self.pair_frame, text="JTAG", font=("Arial", 11), width=140, anchor="w")
    else:
      self.jtag_label = ctk.CTkLabel(self.pair_frame, text="JTAG", font=("Arial", 11), text_color="grey", width=140, anchor="w")
    
    self.jtag_label.pack(side="right", pady=10)
    self.jtag_checkbox.pack(side="left", anchor="e")

    # Ethernet
    self.pair_frame = ctk.CTkFrame(self.peripherals_frame, fg_color="transparent")
    self.pair_frame.grid(row=2, column=0, padx=(20,10))
    self.eth_checkbox = ctk.CTkCheckBox(
        self.pair_frame,
        text="",
        variable=self.soc.eth_en,
        # command=main_frame.update_noc_config,
        state="normal",
        onvalue = 1, 
        offvalue = 0,
        fg_color="green",
        border_color="grey",
        corner_radius=0,
        width=0,
        checkbox_width=18,
        checkbox_height=18,
        hover=False
    )
    if soc.TECH_TYPE == "asic" or soc.TECH == "inferred" or soc.ESP_EMU_TECH != "none":
      self.eth_label = ctk.CTkLabel(self.pair_frame, text="Ethernet", font=("Arial", 11), width=140, anchor="w")
    else:
      self.eth_checkbox.select()
      self.eth_checkbox.configure(state="disabled")
      self.eth_label = ctk.CTkLabel(self.pair_frame, text="Ethernet", font=("Arial", 11), width=140, anchor="w")

    self.eth_label.pack(side="right", pady=10)
    self.eth_checkbox.pack(side="left", anchor="e")

    # Custom IO Link
    iolink_width_choices = ["8", "16", "32"]
    self.pair_frame = ctk.CTkFrame(self.peripherals_frame, fg_color="transparent")
    self.pair_frame.grid(row=4, column=0, padx=(20,10))
    self.custom_io_checkbox = ctk.CTkCheckBox(
        self.pair_frame,
        text="",
        variable=self.soc.iolink_en,
        # command=main_frame.update_noc_config,
        state="normal",
        onvalue = 1, 
        offvalue = 0,
        fg_color="green",
        border_color="grey",
        corner_radius=0,
        width=0,
        checkbox_width=18,
        checkbox_height=18,
        hover=False
    )
    if soc.TECH_TYPE == "asic" or soc.TECH == "inferred" or soc.ESP_EMU_TECH != "none":
      self.custom_io_label = ctk.CTkLabel(self.pair_frame, text="Custom IO Link", font=("Arial", 11), width=140, anchor="w")
      self.menu_frame = ctk.CTkFrame(self.peripherals_frame, fg_color="transparent")
      self.menu_frame.grid(row=4, column=1, padx=(20,10))
      self.custom_io_menu = ctk.CTkOptionMenu(self.menu_frame, values=iolink_width_choices, variable=self.soc.iolink_width, fg_color="white", 
                        bg_color="#e8e8e8", button_color="#e8e8e8", width=200, text_color="black", 
                        font=("Arial", 10), button_hover_color="lightgrey", anchor="center", 
                        dropdown_fg_color="white", dropdown_font=("Arial", 10), 
                        dropdown_hover_color="#e8e8e8")
      self.custom_io_menu.pack()
    else:
      self.custom_io_checkbox.configure(state="disabled")
      self.custom_io_label = ctk.CTkLabel(self.pair_frame, text="Custom IO Link", text_color="grey", font=("Arial", 11), width=140, anchor="w")

    self.custom_io_label.pack(side="right", pady=(10, 20))
    self.custom_io_checkbox.pack(side="left", anchor="e", pady=(10, 20))

    # FPGA Memory Link
    self.pair_frame = ctk.CTkFrame(self.peripherals_frame, fg_color="transparent")
    self.pair_frame.grid(row=3, column=0, padx=(20,10))
    self.fpga_mem_checkbox = ctk.CTkCheckBox(
        self.pair_frame,
        text="",
        # command=main_frame.update_noc_config,
        state="disabled",
        onvalue = 1, 
        offvalue = 0,
        fg_color="green",
        border_color="grey",
        corner_radius=0,
        width=0,
        checkbox_width=18,
        checkbox_height=18,
        hover=False
    )
    if soc.TECH_TYPE == "asic" or soc.TECH == "inferred" or soc.ESP_EMU_TECH != "none":
      self.fpga_mem_label = ctk.CTkLabel(self.pair_frame, text="FPGA Memory Link", font=("Arial", 11), width=140, anchor="w")
    else:
      self.fpga_mem_label = ctk.CTkLabel(self.pair_frame, text="FPGA Memory Link", font=("Arial", 11), width=140, anchor="w", text_color="grey")
    self.fpga_mem_label.pack(side="right", pady=10)
    self.fpga_mem_checkbox.pack(side="left", anchor="e")

    # SVGA
    self.pair_frame = ctk.CTkFrame(self.peripherals_frame, fg_color="transparent")
    self.pair_frame.grid(row=2, column=1, padx=(20,10))
    self.svga_checkbox = ctk.CTkCheckBox(
        self.pair_frame,
        text="",
        variable=self.soc.svga_en,
        # command=main_frame.update_noc_config,
        state="normal",
        onvalue = 1, 
        offvalue = 0,
        fg_color="green",
        border_color="grey",
        corner_radius=0,
        width=0,
        checkbox_width=18,
        checkbox_height=18,
        hover=False
    )
    if soc.FPGA_BOARD.find("profpga") != -1 and (soc.TECH == "virtex7" or soc.TECH == "virtexu"):
      self.svga_label = ctk.CTkLabel(self.pair_frame, text="SVGA", font=("Arial", 11), width=140, anchor="w")
    else:
      self.svga_checkbox.configure(state="disabled")
      self.svga_label = ctk.CTkLabel(self.pair_frame, text="SVGA", font=("Arial", 11), width=140, anchor="w", text_color="grey")
    self.svga_label.pack(side="right", pady=10)
    self.svga_checkbox.pack(side="left", anchor="e")


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
    self.ip_addr_value = ctk.CTkEntry(self.ip_addr_value_frame, placeholder_text="", width=200, font=("Arial", 10), 
                         placeholder_text_color="black", border_width=0)
    self.ip_addr_value.pack(anchor="center", padx=3, pady=3)
    self.ip_addr_label.grid(row=2, column=0, sticky="w", pady=5, padx=20)

    # MAC Address (hex)
    self.mac_addr_label = ctk.CTkLabel(self.debug_link_frame, text="MAC Address (hex)", font=("Arial", 10))
    self.mac_addr_value_frame = ctk.CTkFrame(self.debug_link_frame)
    self.mac_addr_value_frame.grid(row=3, column=1, pady=5, padx=15)
    self.mac_addr_value = ctk.CTkEntry(self.mac_addr_value_frame, placeholder_text="", width=200, font=("Arial", 10), 
                          placeholder_text_color="black", border_width=0)
    self.mac_addr_value.pack(anchor="center", padx=3, pady=3)
    self.mac_addr_label.grid(row=3, column=0, sticky="w", pady=5, padx=20)

  def update_frame(self):
    if len(self.soc.dsu_ip) == 8 and len(self.soc.dsu_eth) == 12:
      self.ip_addr_value.insert(0, self.soc.dsu_ip)
      self.mac_addr_value.insert(0, self.soc.dsu_eth)

class CachesConfigFrame:
  def __init__(self, soc, left_panel):
    self.soc = soc
    self.left_panel = left_panel

    self.sets_choices = ["32", "64", "128", "256", "512", "1024", "2048", "4096", "8192"]
    self.l2_ways_choices = ["2", "4", "8"]
    self.llc_ways_choices = ["4", "8", "16"]
    self.cache_choices = ["ESP RTL", "SPANDEX HLS", "ESP HLS"]
    self.cache_line_choices = ["128", "256", "512"]

    self.caches_frame = ctk.CTkFrame(self.left_panel, fg_color="#ebebeb")
    self.caches_frame.pack(padx=(8, 3), pady=(10,20), fill="x")
    self.title_label = ctk.CTkLabel(self.caches_frame, text="Caches Configuration", font=("Arial", 12, "bold"))
    self.title_label.grid(row=0, column=0, columnspan=2, pady=10)


    self.enable_caches_cb = ctk.CTkCheckBox(self.caches_frame, variable=self.soc.cache_en, text="Enable Caches", fg_color="green", 
              border_color="grey", width=0, corner_radius=0, checkbox_width=18, checkbox_height=18, 
              onvalue = 1, offvalue = 0, font=("Arial", 10), hover=False)
    self.enable_caches_cb.grid(row=1, column=0, sticky="w", padx=20, pady=20)

    self.l2_label = ctk.CTkLabel(self.caches_frame, text="Implementation", font=("Arial", 10))
    self.l2_label.grid(row=2, column=0, padx=20, pady=(10, 5), sticky="w")

    self.esp_rtl_frame = ctk.CTkFrame(self.caches_frame)
    self.esp_rtl_frame.grid(row=2, column=1, padx=20, pady=5)
    self.esp_rtl_dd = ctk.CTkOptionMenu(self.esp_rtl_frame, variable=self.soc.cache_impl, values=self.cache_choices, fg_color="white", 
                      bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black", font=("Arial", 10), dropdown_fg_color="white", 
                      dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8", hover=False, 
                      button_hover_color="lightgrey", width=160)
    self.esp_rtl_dd.pack(padx=3, pady=3)

    self.l2_label = ctk.CTkLabel(self.caches_frame, text="Cache Line Size", font=("Arial", 10))
    self.l2_label.grid(row=3, column=0, padx=20, pady=(10, 5), sticky="w")

    self.cache_line_frame = ctk.CTkFrame(self.caches_frame)
    self.cache_line_frame.grid(row=3, column=1, padx=20, pady=5)
    self.cache_line_dd = ctk.CTkOptionMenu(self.cache_line_frame, variable=self.soc.cache_line_size, values=self.cache_line_choices, 
                         fg_color="white", bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black", dropdown_fg_color="white",
                         dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8", font=("Arial", 10), hover=False, 
                         button_hover_color="lightgrey", width=160)
    self.cache_line_dd.pack(padx=3, pady=3)

    self.l2_label = ctk.CTkLabel(self.caches_frame, text="L2 Properties", font=("Arial", 10))
    self.llc_label = ctk.CTkLabel(self.caches_frame, text="LLC Properties", font=("Arial", 10))
    self.acc_l2_label = ctk.CTkLabel(self.caches_frame, text="Acc L2 Properties", font=("Arial", 10))

    self.l2_label.grid(row=4, column=0, padx=20, pady=(10, 5), sticky="w")
    self.llc_label.grid(row=4, column=1, padx=20, pady=(10, 5), sticky="w")
    self.acc_l2_label.grid(row=7, column=0, padx=20, pady=(10, 5), sticky="w")

    self.l2_ways_frame = ctk.CTkFrame(self.caches_frame)
    self.l2_ways_frame.grid(row=5, column=0, padx=20, pady=5)
    self.l2_ways_dd = ctk.CTkOptionMenu(self.l2_ways_frame, variable=self.soc.l2_ways, values=self.l2_ways_choices, 
                      fg_color="white", bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black", dropdown_fg_color="white",
                      dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8", font=("Arial", 10), hover=False, 
                      button_hover_color="lightgrey", width=165)
    self.l2_ways_dd.pack(padx=3, pady=3)

    self.l2_sets_frame = ctk.CTkFrame(self.caches_frame)
    self.l2_sets_frame.grid(row=6, column=0, padx=20, pady=5)
    self.l2_sets_dd = ctk.CTkOptionMenu(self.l2_sets_frame, variable=self.soc.l2_sets, values=self.sets_choices,
                      fg_color="white", bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black", dropdown_fg_color="white",
                      dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8", font=("Arial", 10), hover=False, 
                      button_hover_color="lightgrey", width=165)
    self.l2_sets_dd.pack(padx=3, pady=3)

    self.llc_ways_frame = ctk.CTkFrame(self.caches_frame)
    self.llc_ways_frame.grid(row=5, column=1, padx=20, pady=5)
    self.llc_ways_dd = ctk.CTkOptionMenu(self.llc_ways_frame, variable=self.soc.llc_ways, values=self.llc_ways_choices,
                       fg_color="white", bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black", dropdown_fg_color="white",
                       dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8", font=("Arial", 10), hover=False, 
                       button_hover_color="lightgrey", width=165)
    self.llc_ways_dd.pack(padx=3, pady=3)

    self.llc_sets_frame = ctk.CTkFrame(self.caches_frame)
    self.llc_sets_frame.grid(row=6, column=1, padx=20, pady=5)
    self.llc_sets_dd = ctk.CTkOptionMenu(self.llc_sets_frame, variable=self.soc.llc_sets, values=self.sets_choices,
                       fg_color="white", bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black", dropdown_fg_color="white",
                       dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8", font=("Arial", 10), hover=False,
                       button_hover_color="lightgrey", width=165)
    self.llc_sets_dd.pack(padx=3, pady=3)

    self.acc_l2_ways_frame = ctk.CTkFrame(self.caches_frame)
    self.acc_l2_ways_frame.grid(row=8, column=0, padx=20, pady=5)
    self.acc_l2_ways_dd = ctk.CTkOptionMenu(self.acc_l2_ways_frame, variable=self.soc.acc_l2_ways, values=self.l2_ways_choices,
                          fg_color="white", bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black", dropdown_fg_color="white",
                          dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8", font=("Arial", 10), hover=False, 
                          button_hover_color="lightgrey", width=165)
    self.acc_l2_ways_dd.pack(padx=3, pady=3)

    self.acc_l2_sets_frame = ctk.CTkFrame(self.caches_frame)
    self.acc_l2_sets_frame.grid(row=9, column=0, padx=20, pady=5)
    self.acc_l2_sets_dd = ctk.CTkOptionMenu(self.acc_l2_sets_frame, variable=self.soc.acc_l2_sets, values=self.sets_choices,
                          fg_color="white", bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black", dropdown_fg_color="white",
                          dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8", font=("Arial", 10), hover=False, 
                          button_hover_color="lightgrey", width=165)
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
    self.debug_link_config_frame.update_frame()
    self.caches_config_frame = CachesConfigFrame(self.soc, self.left_panel)
    self.noc_config_frame = NoCConfigFrame(self.soc, self.left_panel)
    self.probe_config_frame = ProbeConfigFrame(self.soc, self.left_panel)
    
    self.gen_soc_config = ctk.CTkButton(self.left_panel, text="Generate SoC Configuration", font=("Arial", 12), height=40, width=150)
    self.gen_soc_config.pack(fill="x", pady=15)

  def update_noc_config(self, *args):
    if soc.CPU_ARCH.get() == "ariane":
      self.soc.ARCH_BITS = 64
    else:
      self.soc.ARCH_BITS = 32
    self.soc.IPs = Components(self.soc.TECH, self.noc.dma_noc_width.get(), soc.CPU_ARCH.get())
    self.soc.update_list_of_ips()
    self.soc.changed()
    self.noc_config_frame.changed()

  def generate_files(self):
    self.noc_config_frame.changed()
    self.generate_socmap()
    self.generate_mmi64_regs()
    if os.path.isfile(".esp_config.bak") == True:
      shutil.move(".esp_config.bak", ".esp_config")

  def generate_socmap(self):
    self.soc.write_config(self.peripheral_frame.DSU_IP.get(), self.peripheral_frame.DSU_ETH.get())
    esp_config = soc_config(soc)
    create_socmap(esp_config, soc)

  def generate_mmi64_regs(self):
    create_mmi64_regs(soc)

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

# # Frames
# main_frame = ctk.CTkScrollableFrame(root, scrollbar_button_color="grey")
# main_frame.pack(padx=10, pady=10, fill="both", expand=True)

# # Left panel for "SoC Configuration" and other sections
# left_panel = ctk.CTkScrollableFrame(main_frame, width=440, height=900, scrollbar_button_color="grey")
# left_panel.grid(row=0, column=0, sticky="ns", padx=10, pady=10)

# # "SoC Configuration" Section
# soc_config_frame = ctk.CTkFrame(left_panel, fg_color="#ebebeb")
# soc_config_frame.pack(fill="x", padx=(8,3), pady=10)

# soc_config_label = ctk.CTkLabel(soc_config_frame, text="SoC Configuration", font=("Arial", 12, "bold"), pady=15)
# soc_config_label.grid(row=0, column=0, columnspan=2)

# # Target Technology 
# tech_label = ctk.CTkLabel(soc_config_frame, text="Target Technology", font=("Arial", 10))
# tech_value_frame = ctk.CTkFrame(soc_config_frame)
# tech_value_frame.grid(row=1, column=1, pady=5, padx=15)
# tech_value = ctk.CTkLabel(tech_value_frame, text="virtex7", width=200, font=("Arial", 10, "bold"))
# tech_value.pack(anchor="center", padx=3, pady=3)
# tech_label.grid(row=1, column=0, sticky="w", pady=5, padx=15)

# # FPGA Board 
# fpga_label = ctk.CTkLabel(soc_config_frame, text="FPGA Board", font=("Arial", 10))
# fpga_value_frame = ctk.CTkFrame(soc_config_frame)
# fpga_value_frame.grid(row=2, column=1, pady=5, padx=15)
# fpga_value = ctk.CTkLabel(fpga_value_frame, text="xilinx-vcu138-xcvu37p", width=200, font=("Arial", 10, "bold"))
# fpga_value.pack(anchor="center", padx=3, pady=3)
# fpga_label.grid(row=2, column=0, sticky="w", pady=5, padx=15)

# # CPU Architecture 
# cpu_label = ctk.CTkLabel(soc_config_frame, text="CPU Architecture", font=("Arial", 10))
# cpu_value_frame = ctk.CTkFrame(soc_config_frame)
# cpu_value_frame.grid(row=3, column=1, pady=5, padx=15)
# cpu_value_menu = ctk.CTkOptionMenu(cpu_value_frame, values=["ariane", "leon3"], fg_color="white", 
# 								   bg_color="#e8e8e8", button_color="#e8e8e8", width=200, text_color="black",font=("Arial", 10),
# 								   button_hover_color="lightgrey", anchor="center", dropdown_fg_color="white", dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8")
# cpu_value_menu.pack(anchor="center", padx=3, pady=3)
# cpu_label.grid(row=3, column=0, sticky="w", pady=5, padx=15)

# # NoC/DMA Width 
# noc_label = ctk.CTkLabel(soc_config_frame, text="NoC/DMA Width", font=("Arial", 10))
# noc_value_frame = ctk.CTkFrame(soc_config_frame)
# noc_value_frame.grid(row=4, column=1, pady=5, padx=15)
# noc_value = ctk.CTkLabel(noc_value_frame, text="64", width=200, font=("Arial", 10, "bold"))
# noc_value.pack(anchor="center", padx=3, pady=3)
# noc_label.grid(row=4, column=0, sticky="w", pady=5, padx=15)

# # Data Allocation Strategy 
# das_label = ctk.CTkLabel(soc_config_frame, text="Data Allocation Strategy", font=("Arial", 10))
# das_value_frame = ctk.CTkFrame(soc_config_frame)
# das_value_frame.grid(row=5, column=1, pady=5, padx=15)
# das_value_menu = ctk.CTkOptionMenu(das_value_frame, values=["Big physical area", "Scatter/Gatter"], fg_color="white", 
# 								   bg_color="#e8e8e8", button_color="#e8e8e8", width=200, text_color="black",font=("Arial", 10),
# 								   button_hover_color="lightgrey", anchor="center", dropdown_fg_color="white", dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8")
# das_value_menu.pack(anchor="center", padx=3, pady=3)
# das_label.grid(row=5, column=0, sticky="w", pady=5, padx=15)

# # SLM KB per tile 
# slm_label = ctk.CTkLabel(soc_config_frame, text="SLM KB Per Tile", font=("Arial", 10))
# slm_value_frame = ctk.CTkFrame(soc_config_frame)
# slm_value_frame.grid(row=6, column=1, pady=(5,20), padx=15)
# slm_value_menu = ctk.CTkOptionMenu(slm_value_frame, values=["64", "138", "256", "513", "1024", "2048", "4096"], fg_color="white", 
# 								   bg_color="#e8e8e8", button_color="#e8e8e8", width=200, text_color="black",font=("Arial", 10),
# 								   button_hover_color="lightgrey", anchor="center", dropdown_fg_color="white", dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8")
# slm_value_menu.pack(anchor="center", padx=3, pady=3)
# slm_label.grid(row=6, column=0, sticky="w", pady=(5,20), padx=15)

# # Sample peripherals list for demonstration
# peripherals = [
#     ("UART", True), ("JTAG", False), ("Ethernet", True), 
#     ("Custom IO Link", False), ("SVGA", False), 
#     ("FPGA Memory Link", False)
# ]

# # Create the main frame for peripherals section
# peripherals_frame = ctk.CTkFrame(left_panel, fg_color="#ebebeb")
# peripherals_frame.pack(fill="x", padx=(8,3), pady=(0,10))  # Adjust padx for less space around the frame

# # Title for peripherals section, centered across all columns
# peripherals_label = ctk.CTkLabel(peripherals_frame, text="Peripherals", font=("Arial", 12, "bold"))
# peripherals_label.grid(row=0, column=0, columnspan=2, pady=(10, 15), padx=(15, 0))  # Centered across 4 columns

# # Determine the number of rows needed for a 4-column layout
# columns = 2
# rows = math.ceil(len(peripherals) / columns)

# # Populate peripherals in a 4-column layout with checkboxes and labels side-by-side
# for i, (label_text, is_present) in enumerate(peripherals):
#     row = (i // columns) + 1
#     column = i % columns

#     # Frame for each (checkbox, label) pair
#     pair_frame = ctk.CTkFrame(peripherals_frame, fg_color="transparent")
#     pair_frame.grid(row=row, column=column, padx=(20,10))

#     # Checkbox for availability, styled based on presence
#     checkbox = ctk.CTkCheckBox(
#         pair_frame,
#         text="",
#         state="normal",  # Enable only "Ethernet"
#         fg_color="green",  # Green for present, red for absent
# 		border_color="grey",
# 		corner_radius=0,
#         width=0,
#         checkbox_width=18,
#         checkbox_height=18,
#         hover=False  # Remove hover effect for a cleaner look
#     )
#     # Label for peripheral next to the checkbox
#     label = ctk.CTkLabel(pair_frame, text=label_text, font=("Arial", 11), width=140, anchor="w")
#     label.pack(side="right", pady=10)  # Place label on the right within the pair frame
    
#     if is_present:
#         label.configure(text_color="black")
#         checkbox.select()
#     checkbox.pack(side="left", anchor="e")  # Place checkbox on the left within the pair frame
    
# # Debug Link Section
# debug_link_frame = ctk.CTkFrame(left_panel, fg_color="#ebebeb")
# debug_link_frame.pack(fill="x", padx=(8,3), pady=10)

# debug_link_label = ctk.CTkLabel(debug_link_frame, text="Debug Link", font=("Arial", 12, "bold"), pady=15)
# debug_link_label.grid(row=0, column=0, columnspan=2)

# # Target Technology 
# ip_add_label = ctk.CTkLabel(debug_link_frame, text="IP Address (hex)", font=("Arial", 10))
# ip_add_value_frame = ctk.CTkFrame(debug_link_frame)
# ip_add_value_frame.grid(row=2, column=1, pady=5, padx=15)
# ip_add_value = ctk.CTkEntry(ip_add_value_frame, placeholder_text="C0A8010C", width=200, font=("Arial", 10), placeholder_text_color="black", border_width=0)
# ip_add_value.pack(anchor="center", padx=3, pady=3)
# ip_add_label.grid(row=2, column=0, sticky="w", pady=5, padx=20)

# # Target Technology 
# ip_add_label = ctk.CTkLabel(debug_link_frame, text="IP Address (dec)", font=("Arial", 10))
# ip_add_value_frame = ctk.CTkFrame(debug_link_frame)
# ip_add_value_frame.grid(row=1, column=1, pady=5, padx=15)
# ip_add_value = ctk.CTkLabel(ip_add_value_frame, text="192.168.1.12", width=200, font=("Arial", 10, "bold"))
# ip_add_value.pack(anchor="center")
# ip_add_label.grid(row=1, column=0, sticky="w", pady=5, padx=20)

# ip_add_label = ctk.CTkLabel(debug_link_frame, text="MAC Address (hex)", font=("Arial", 10))
# ip_add_value_frame = ctk.CTkFrame(debug_link_frame)
# ip_add_value_frame.grid(row=3, column=1, pady=5, padx=15)
# ip_add_value = ctk.CTkEntry(ip_add_value_frame, placeholder_text="A6A7A0F80442", width=200, font=("Arial", 10), placeholder_text_color="black", border_width=0)
# ip_add_value.pack(anchor="center", padx=3, pady=3)
# ip_add_label.grid(row=3, column=0, sticky="w", pady=5, padx=20)

# # Caches Configuration Frame
# caches_frame = ctk.CTkFrame(left_panel, fg_color="#ebebeb")
# caches_frame.pack(padx=(8, 3), pady=(10,20), fill="x")

# # Title label for the Caches Configuration section
# title_label = ctk.CTkLabel(caches_frame, text="Caches Configuration", font=("Arial", 12, "bold"))
# title_label.grid(row=0, column=0, columnspan=2, pady=10)

# # Enable Caches checkbox
# enable_caches_cb = ctk.CTkCheckBox(caches_frame, text="Enable Caches",
#                                    fg_color="green",
#                                    border_color="grey",
#                                    width=0,
# 								   corner_radius=0,
#                                    checkbox_width=18,
#                                    checkbox_height=18,
# 								   font=("Arial", 10),
#                                    hover=False)
# enable_caches_cb.grid(row=1, column=0, sticky="w", padx=20, pady=20)

# # Implementation Dropdown (ESP RTL)
# l2_label = ctk.CTkLabel(caches_frame, text="Implementation", font=("Arial", 10))
# l2_label.grid(row=2, column=0, padx=20, pady=(10, 5), sticky="w")

# esp_rtl_frame = ctk.CTkFrame(caches_frame)
# esp_rtl_frame.grid(row=2, column=1, padx=20, pady=5)
# esp_rtl_dd = ctk.CTkOptionMenu(esp_rtl_frame, values=["ESP RTL"], fg_color="white", 
#                                bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black",
#                                font=("Arial", 10), button_hover_color="lightgrey", width=160)
# esp_rtl_dd.set("ESP RTL")
# esp_rtl_dd.pack(padx=3, pady=3)

# # Cache Line Size Dropdown
# l2_label = ctk.CTkLabel(caches_frame, text="Cache Line Size", font=("Arial", 10))
# l2_label.grid(row=3, column=0, padx=20, pady=(10, 5), sticky="w")

# cache_line_frame = ctk.CTkFrame(caches_frame)
# cache_line_frame.grid(row=3, column=1, padx=20, pady=5)
# cache_line_dd = ctk.CTkOptionMenu(cache_line_frame, values=["128", "256"], fg_color="white", 
#                                   bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black",
#                                   font=("Arial", 10), button_hover_color="lightgrey", width=160)
# cache_line_dd.set("128")
# cache_line_dd.pack(padx=3, pady=3)

# # Section Labels
# l2_label = ctk.CTkLabel(caches_frame, text="L2 Properties", font=("Arial", 10))
# llc_label = ctk.CTkLabel(caches_frame, text="LLC Properties", font=("Arial", 10))
# acc_l2_label = ctk.CTkLabel(caches_frame, text="Acc L2 Properties", font=("Arial", 10))

# l2_label.grid(row=4, column=0, padx=20, pady=(10, 5), sticky="w")
# llc_label.grid(row=4, column=1, padx=20, pady=(10, 5), sticky="w")
# acc_l2_label.grid(row=7, column=0, padx=20, pady=(10, 5), sticky="w")

# ways_options = ["4 ways", "8 ways", "16 ways"]
# sets_options = ["512 sets", "1024 sets", "2048 sets"]

# # L2 Properties Dropdowns
# l2_ways_frame = ctk.CTkFrame(caches_frame)
# l2_ways_frame.grid(row=5, column=0, padx=20, pady=5)
# l2_ways_dd = ctk.CTkOptionMenu(l2_ways_frame, values=ways_options, fg_color="white",
#                                bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black",
#                                font=("Arial", 10), button_hover_color="lightgrey", width=165)
# l2_ways_dd.set(ways_options[0])
# l2_ways_dd.pack(padx=3, pady=3)

# l2_sets_frame = ctk.CTkFrame(caches_frame)
# l2_sets_frame.grid(row=6, column=0, padx=20, pady=5)
# l2_sets_dd = ctk.CTkOptionMenu(l2_sets_frame, values=sets_options, fg_color="white",
#                                bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black",
#                                font=("Arial", 10), button_hover_color="lightgrey", width=165)
# l2_sets_dd.set(sets_options[0])
# l2_sets_dd.pack(padx=3, pady=3)

# # LLC Properties Dropdowns
# llc_ways_frame = ctk.CTkFrame(caches_frame)
# llc_ways_frame.grid(row=5, column=1, padx=20, pady=5)
# llc_ways_dd = ctk.CTkOptionMenu(llc_ways_frame, values=ways_options, fg_color="white",
#                                 bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black",
#                                 font=("Arial", 10), button_hover_color="lightgrey", width=165)
# llc_ways_dd.set(ways_options[2])
# llc_ways_dd.pack(padx=3, pady=3)

# llc_sets_frame = ctk.CTkFrame(caches_frame)
# llc_sets_frame.grid(row=6, column=1, padx=20, pady=5)
# llc_sets_dd = ctk.CTkOptionMenu(llc_sets_frame, values=sets_options, fg_color="white",
#                                 bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black",
#                                 font=("Arial", 10), button_hover_color="lightgrey", width=165)
# llc_sets_dd.set(sets_options[1])
# llc_sets_dd.pack(padx=3, pady=3)

# # Acc L2 Properties Dropdowns
# acc_l2_ways_frame = ctk.CTkFrame(caches_frame)
# acc_l2_ways_frame.grid(row=8, column=0, padx=20, pady=5)
# acc_l2_ways_dd = ctk.CTkOptionMenu(acc_l2_ways_frame, values=ways_options, fg_color="white",
#                                    bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black",
#                                    font=("Arial", 10), button_hover_color="lightgrey", width=165)
# acc_l2_ways_dd.set(ways_options[0])
# acc_l2_ways_dd.pack(padx=3, pady=3)

# acc_l2_sets_frame = ctk.CTkFrame(caches_frame)
# acc_l2_sets_frame.grid(row=9, column=0, padx=20, pady=5)
# acc_l2_sets_dd = ctk.CTkOptionMenu(acc_l2_sets_frame, values=sets_options, fg_color="white",
#                                    bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black",
#                                    font=("Arial", 10), button_hover_color="lightgrey", width=165)
# acc_l2_sets_dd.set(sets_options[0])
# acc_l2_sets_dd.pack(padx=3, pady=3)

# noc_select_frame = ctk.CTkFrame(left_panel, fg_color="#ebebeb")
# noc_select_frame.pack(padx=(8,3), pady=(10,20), fill="x")

# # Title label for the NoC Configuration section
# title_label = ctk.CTkLabel(noc_select_frame, text="NoC Configuration", font=("Arial", 12, "bold"))
# title_label.grid(row=0, column=0, columnspan=2, pady=10)

# # noc_rows_label = ctk.CTkLabel(noc_select_frame, text="Rows:")
# # noc_rows_label.grid(row=1, column=0, padx=5, pady=5, sticky="e")
# # noc_rows = ctk.CTkEntry(noc_select_frame, width=50)
# # noc_rows.insert(0, "2")
# # noc_rows.grid(row=1, column=1, padx=5, pady=5)

# # noc_columns_label = ctk.CTkLabel(noc_select_frame, text="Columns:")
# # noc_columns_label.grid(row=1, column=2, padx=5, pady=5, sticky="e")
# # noc_columns = ctk.CTkEntry(noc_select_frame, width=50)
# # noc_columns.insert(0, "2")
# # noc_columns.grid(row=1, column=3, padx=5, pady=5)

# # update_noc_button = ctk.CTkButton(noc_select_frame, text="Update NoC", width=100, font=("Arial", 12))
# #update_noc_button.grid(row=1, column=4, padx=10, pady=5)

# cpu_label = ctk.CTkLabel(noc_select_frame, text="Coherence NoC Planes (1,2,3) Bitwidth", font=("Arial", 10))
# cpu_value_frame = ctk.CTkFrame(noc_select_frame)
# cpu_value_frame.grid(row=2, column=1, pady=5, padx=15)
# cpu_value_menu = ctk.CTkOptionMenu(cpu_value_frame, values=["64", "32"], fg_color="white", 
# 								   bg_color="#e8e8e8", button_color="#e8e8e8", width=100, text_color="black",font=("Arial", 10),
# 								   button_hover_color="lightgrey", anchor="center", dropdown_fg_color="white", dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8")
# cpu_value_menu.pack(anchor="center", padx=3, pady=3)
# cpu_label.grid(row=2, column=0, sticky="w", pady=5, padx=15)



# cpu_label = ctk.CTkLabel(noc_select_frame, text="DMA NoC Planes (4,6) Bitwidth", font=("Arial", 10))
# cpu_value_frame = ctk.CTkFrame(noc_select_frame)
# cpu_value_frame.grid(row=3, column=1, pady=5, padx=15)
# cpu_value_menu = ctk.CTkOptionMenu(cpu_value_frame, values=["64", "32"], fg_color="white", 
# 								   bg_color="#e8e8e8", button_color="#e8e8e8", width=100, text_color="black",font=("Arial", 10),
# 								   button_hover_color="lightgrey", anchor="center", dropdown_fg_color="white", dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8")
# cpu_value_menu.pack(anchor="center", padx=3, pady=3)
# cpu_label.grid(row=3, column=0, sticky="w", pady=5, padx=15)

# enable_caches_cb = ctk.CTkCheckBox(noc_select_frame, text="Enable Multicast on DMA Planes",
# 								   font=("Arial", 11),
#                                    fg_color="green",
#                                    border_color="grey",
#                                    width=0,
# 								   corner_radius=0,
#                                    checkbox_width=18,
#                                    checkbox_height=18,
#                                    hover=False)
# enable_caches_cb.grid(row=4, column=0, sticky="w", padx=15, pady=10)

# cpu_label = ctk.CTkLabel(noc_select_frame, text="Maximum Multicast Destinations", font=("Arial", 11))
# cpu_value_frame = ctk.CTkFrame(noc_select_frame)
# cpu_value_frame.grid(row=5, column=1, pady=5, padx=15)
# cpu_value_menu = ctk.CTkOptionMenu(cpu_value_frame, values=["2", "3"], fg_color="white", 
# 								   bg_color="#e8e8e8", button_color="#e8e8e8", width=100, text_color="black",font=("Arial", 10),
# 								   button_hover_color="lightgrey", anchor="center", dropdown_fg_color="white", dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8")
# cpu_value_menu.pack(anchor="center", padx=3, pady=3)
# cpu_label.grid(row=5, column=0, sticky="w", pady=5, padx=15)

# probe_frame = ctk.CTkFrame(left_panel, fg_color="#ebebeb")
# probe_frame.pack(padx=(8,3), pady=10, fill="x")

# # Title label for the NoC Configuration section
# title_label = ctk.CTkLabel(probe_frame, text="Probe Configuration", font=("Arial", 12, "bold"))
# title_label.pack(pady=10)

# enable_caches_cb = ctk.CTkCheckBox(probe_frame, text="Monitor DDR bandwidth",
#                                    font=("Arial", 11),
#                                    fg_color="green",
#                                    border_color="grey",
#                                    width=0,
# 								   corner_radius=0,
#                                    checkbox_width=18,
#                                    checkbox_height=18,
#                                    hover=False)
# enable_caches_cb.pack(padx=15, pady=10, anchor="w")

# enable_caches_cb = ctk.CTkCheckBox(probe_frame, text="Monitor Memory Access",
#                                    font=("Arial", 11),
#                                    fg_color="green",
#                                    border_color="grey",
#                                    width=0,
# 								   corner_radius=0,
#                                    checkbox_width=18,
#                                    checkbox_height=18,
#                                    hover=False)
# enable_caches_cb.pack(padx=15, pady=10, anchor="w")

# enable_caches_cb = ctk.CTkCheckBox(probe_frame, text="Monitor Injection Rate",
#                                    font=("Arial", 11),
#                                    fg_color="green",
#                                    border_color="grey",
#                                    width=0,
# 								   corner_radius=0,
#                                    checkbox_width=18,
#                                    checkbox_height=18,
#                                    hover=False)
# enable_caches_cb.pack(padx=15, pady=10, anchor="w")

# enable_caches_cb = ctk.CTkCheckBox(probe_frame, text="Monitor Router Ports",
#                                    font=("Arial", 11),
#                                    fg_color="green",
#                                    border_color="grey",
#                                    width=0,
# 								   corner_radius=0,
#                                    checkbox_width=18,
#                                    checkbox_height=18,
#                                    hover=False)
# enable_caches_cb.pack(padx=15, pady=10, anchor="w")

# enable_caches_cb = ctk.CTkCheckBox(probe_frame, text="Monitor Accelerator Status",
#                                    font=("Arial", 11),
#                                    fg_color="green",
#                                    border_color="grey",
#                                    width=0,
# 								   corner_radius=0,
#                                    checkbox_width=18,
#                                    checkbox_height=18,
#                                    hover=False)
# enable_caches_cb.pack(padx=15, pady=10, anchor="w")

# enable_caches_cb = ctk.CTkCheckBox(probe_frame, text="Monitor L2 Hit/Miss",
#                                    font=("Arial", 11),
#                                    fg_color="green",
#                                    border_color="grey",
#                                    width=0,
# 								   corner_radius=0,
#                                    checkbox_width=18,
#                                    checkbox_height=18,
#                                    hover=False)
# enable_caches_cb.pack(padx=15, pady=10, anchor="w")

# enable_caches_cb = ctk.CTkCheckBox(probe_frame, text="Monitor LLC Hit/Miss",
#                                    font=("Arial", 11),
#                                    fg_color="green",
#                                    border_color="grey",
#                                    width=0,
# 								   corner_radius=0,
#                                    checkbox_width=18,
#                                    checkbox_height=18,
#                                    hover=False)
# enable_caches_cb.pack(padx=15, pady=10, anchor="w")

# enable_caches_cb = ctk.CTkCheckBox(probe_frame, text="Monitor DVFS",
#                                    font=("Arial", 11),
#                                    fg_color="green",
#                                    border_color="grey",
#                                    width=0,
# 								   corner_radius=0,
#                                    checkbox_width=18,
#                                    checkbox_height=18,
#                                    hover=False)
# enable_caches_cb.pack(padx=15, pady=10, anchor="w")

# gen_soc_config = ctk.CTkButton(left_panel, text="Generate SoC Configuration", font=("Arial", 12), height=40, width=150)
# gen_soc_config.pack(fill="x", pady=15)

# # # Right panel for tiles configuration
# # right_panel = ctk.CTkFrame(main_frame)
# # right_panel.grid(row=0, column=1, sticky="ns", padx=10, pady=10)

# # # Example for configuring Tile 0
# # tile_frame = ctk.CTkFrame(right_panel, fg_color="lightblue")
# # tile_frame.grid(row=0, column=0, padx=5, pady=5)

# # tile_label = ctk.CTkLabel(tile_frame, text="Tile 0")
# # tile_label.grid(row=0, column=0, columnspan=2)

# # tile_type = ctk.CTkOptionMenu(tile_frame, values=["Accelerator", "Empty"])
# # tile_type.grid(row=1, column=0, columnspan=2)

# # # Additional options under "Tile 0"
# # clock_domain_label = ctk.CTkLabel(tile_frame, text="Clock domain:")
# # clock_domain_entry = ctk.CTkEntry(tile_frame)
# # clock_domain_label.grid(row=2, column=0, sticky="w", padx=10)
# # clock_domain_entry.grid(row=2, column=1, padx=10)

# # # Repeat similar layout for other tiles (Tile 1, Tile 2, etc.)

# # Run the app