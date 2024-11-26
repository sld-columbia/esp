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

class StyledComponents:
  @staticmethod
  def Panel(frame, fg_color="#ebebeb"):
    """Styled panel."""
    return ctk.CTkFrame(frame, fg_color=fg_color)

  @staticmethod
  def Header(frame, text, row, column, font=("Arial", 12, "bold")):
    """Styled header."""
    label = ctk.CTkLabel(frame, text=text, font=font, pady=15)
    label.grid(row=row, column=column, columnspan=2)
    return label
  
  @staticmethod
  def KeyLabel(frame, text, row, column, font=("Arial", 10)):
    """Styled label for the key columns."""
    label = ctk.CTkLabel(frame, text=text, font=font)
    label.grid(row=row, column=column, sticky="w", pady=5, padx=15)
    return label
  
  @staticmethod
  def ValueLabel(frame, text, width=200, font=("Arial", 10, "bold")):
    """Styled label for the value columns."""
    label = ctk.CTkLabel(frame, text=text, width=width, font=font)
    label.pack(anchor="center", padx=3, pady=3)
    return label

  @staticmethod
  def ValueFrame(frame, row, column):
    """Styled label for the value columns."""
    frame = ctk.CTkFrame(frame)
    frame.grid(row=row, column=column, pady=5, padx=15)
    return frame

  @staticmethod
  def OptionMenu(parent, variable, values, width=200, command=None):
    """Create a styled option menu."""
    menu = ctk.CTkOptionMenu(
      parent, variable=variable, values=values, fg_color="white",
      bg_color="#e8e8e8", button_color="#e8e8e8", width=width, text_color="black",
      font=("Arial", 10), button_hover_color="lightgrey", anchor="center",
      dropdown_fg_color="white", dropdown_font=("Arial", 10),
      dropdown_hover_color="#e8e8e8", command=command
    )
    menu.pack(anchor="center", padx=3, pady=3)
    return menu
  
  @staticmethod
  def CheckBoxWithLabel(frame, variable, text, state, row, column, command=None):
    """Create a styled checkbox with label."""
    check_frame = ctk.CTkFrame(frame, fg_color="transparent")
    check_frame.grid(row=row, column=column, padx=(20,10))
    label = ctk.CTkLabel(check_frame, text=text, font=("Arial", 11), width=140, anchor="w")
    label.pack(side="right", pady=10)
    checkbox = ctk.CTkCheckBox(check_frame, variable=variable, text="", state=state, fg_color="green", border_color="grey",
        corner_radius=0, width=0, checkbox_width=18, checkbox_height=18, onvalue = 1, offvalue = 0, hover=False)
    checkbox.pack(side="left", anchor="e")
    return label, checkbox

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

  def __init__(self, soc, left_panel, main_frame):
    self.soc = soc
    self.left_panel = left_panel
    self.main_frame = main_frame
    
    self.soc_config_frame = ctk.CTkFrame(self.left_panel)
    self.soc_config_frame.pack(fill="x", padx=(8, 3), pady=10)
    self.soc_config_label = StyledComponents.Header(self.soc_config_frame, "SoC Configuration", 0, 0)

    # Target Technology
    self.tech_label = StyledComponents.KeyLabel(self.soc_config_frame, "Target Technology", 1, 0)
    self.tech_value_frame = ctk.CTkFrame(self.soc_config_frame)
    self.tech_value_frame.grid(row=1, column=1, pady=5, padx=15)
    self.tech_value = StyledComponents.ValueLabel(self.tech_value_frame, self.soc.TECH)

    # FPGA Board
    self.fpga_board_text = self.soc.FPGA_BOARD[:22] + (self.soc.FPGA_BOARD[22:] and ' ..')
    self.fpga_label = StyledComponents.KeyLabel(self.soc_config_frame, "FPGA Board", 2, 0)
    self.fpga_value_frame = ctk.CTkFrame(self.soc_config_frame)
    self.fpga_value_frame.grid(row=2, column=1, pady=5, padx=15)
    self.fpga_value = StyledComponents.ValueLabel(self.fpga_value_frame, self.fpga_board_text)

    # CPU Architecture
    self.cpu_choices = ["leon3", "ariane", "ibex"]
    self.cpu_label = StyledComponents.KeyLabel(self.soc_config_frame, "CPU Architecture", 3, 0)
    self.cpu_value_frame = ctk.CTkFrame(self.soc_config_frame)
    self.cpu_value_frame.grid(row=3, column=1, pady=5, padx=15)
    self.cpu_value_menu = StyledComponents.OptionMenu(self.cpu_value_frame, self.soc.CPU_ARCH, self.cpu_choices, 
              command=main_frame.update_noc_config)

    # FPU
    self.fpu_label = StyledComponents.KeyLabel(self.soc_config_frame, "Floating-Point Unit", 4,0)
    self.fpu_value_frame = ctk.CTkFrame(self.soc_config_frame)
    self.fpu_value_frame.grid(row=4, column=1, pady=5, padx=15)
    self.fpu_value = StyledComponents.ValueLabel(self.fpu_value_frame, "None")
    self.set_cpu_specific_labels(self.soc)

    # Data Allocation Strategy
    self.das_label = StyledComponents.KeyLabel(self.soc_config_frame, "Data Allocation Strategy", 5, 0)
    self.das_value_frame = ctk.CTkFrame(self.soc_config_frame)
    self.das_value_frame.grid(row=5, column=1, pady=5, padx=15)
    self.das_value_menu = StyledComponents.OptionMenu(self.das_value_frame, self.soc.transfers, [
              "Big physical area", "Scatter/Gatter"])

    # SLM KB per Tile
    self.slm_kbytes_choices = ["64", "128", "256", "512", "1024", "2048", "4096"]
    self.slm_label = StyledComponents.KeyLabel(self.soc_config_frame, "SLM KB Per Tile", 6, 0)
    self.slm_value_frame = ctk.CTkFrame(self.soc_config_frame)
    self.slm_value_frame.grid(row=6, column=1, pady=(5,20), padx=15)
    self.slm_value_menu = StyledComponents.OptionMenu(self.slm_value_frame, self.soc.slm_kbytes, self.slm_kbytes_choices, 
              command=main_frame.update_noc_config)

class PeripheralsConfigFrame:
  def __init__(self, soc, left_panel, main_frame):
    self.soc = soc
    self.left_panel = left_panel
    self.main_frame = main_frame

    self.peripherals_frame = StyledComponents.Panel(self.left_panel, fg_color="#ebebeb")
    self.peripherals_frame.pack(fill="x", padx=(8, 3), pady=(0, 10))
    self.peripherals_label = StyledComponents.Header(self.peripherals_frame, "Peripherals", 0, 0)

    # UART
    self.uart_label, self.uart_checkbox = StyledComponents.CheckBoxWithLabel(self.peripherals_frame, None, "UART", "disabled", 1, 0)
    self.uart_checkbox.select()

    # JTAGssh
    self.jtag_label, self.jtag_checkbox = StyledComponents.CheckBoxWithLabel(self.peripherals_frame, self.soc.jtag_en, "JTAG", "disabled", 1, 1,
                     command=main_frame.update_noc_config)
    if soc.TECH_TYPE == "asic" or soc.TECH == "inferred" or soc.ESP_EMU_TECH != "none":
      self.jtag_checkbox.configure(state="normal")
      self.jtag_label.configure(text_color="black")
    else:
      self.jtag_label.configure(text_color="grey")

    # Ethernet
    self.eth_label, self.eth_checkbox = StyledComponents.CheckBoxWithLabel(self.peripherals_frame, self.soc.eth_en, "Ethernet", "normal", 2, 0,
            command=main_frame.update_noc_config)
    if not(soc.TECH_TYPE == "asic" or soc.TECH == "inferred" or soc.ESP_EMU_TECH != "none"):
      self.eth_checkbox.select()
      self.eth_checkbox.configure(state="disabled")

    # Custom IO Link
    iolink_width_choices = ["8", "16", "32"]
    self.custom_io_label, self.custom_io_checkbox = StyledComponents.CheckBoxWithLabel(self.peripherals_frame, self.soc.iolink_en, "Custom IO Link", 
          "normal", 4, 0, command=main_frame.update_noc_config)
    if soc.TECH_TYPE == "asic" or soc.TECH == "inferred" or soc.ESP_EMU_TECH != "none":
      self.menu_frame = ctk.CTkFrame(self.peripherals_frame, fg_color="transparent")
      self.menu_frame.grid(row=4, column=1, padx=(20,10))
      self.custom_io_menu = ctk.CTkOptionMenu(self.menu_frame, values=iolink_width_choices, variable=self.soc.iolink_width, fg_color="white", 
                        bg_color="#e8e8e8", button_color="#e8e8e8", width=200, text_color="black", 
                        font=("Arial", 10), button_hover_color="lightgrey", anchor="center", 
                        dropdown_fg_color="white", dropdown_font=("Arial", 10), 
                        dropdown_hover_color="#e8e8e8", command=main_frame.update_noc_config)
      self.custom_io_menu.pack()
    else:
      self.custom_io_checkbox.configure(state="disabled")
      self.custom_io_label.configure(text_color="grey")

    # FPGA Memory Link
    self.fpga_mem_label, self.fpga_mem_checkbox = StyledComponents.CheckBoxWithLabel(self.peripherals_frame, None, "FPGA Memory Link", "disabled", 3, 0)
    if not(soc.TECH_TYPE == "asic" or soc.TECH == "inferred" or soc.ESP_EMU_TECH != "none"):
      self.fpga_mem_label.configure(text_color="grey")

    # SVGA
    self.pair_frame = ctk.CTkFrame(self.peripherals_frame, fg_color="transparent")
    self.pair_frame.grid(row=2, column=1, padx=(20,10))
    self.svga_checkbox = ctk.CTkCheckBox(
        self.pair_frame,
        text="",
        variable=self.soc.svga_en,
        state="normal",
        onvalue = 1, 
        offvalue = 0,
        fg_color="green",
        border_color="grey",
        corner_radius=0,
        width=0,
        checkbox_width=18,
        checkbox_height=18,
        hover=False,
        command=main_frame.update_noc_config
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
    self.debug_link_label = StyledComponents.Header(self.debug_link_frame, "Debug Link", 0, 0)
    # self.debug_link_label.grid(row=0, column=0, columnspan=2)

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
  def __init__(self, soc, left_panel, main_frame):
    self.soc = soc
    self.left_panel = left_panel
    self.main_frame = main_frame

    self.sets_choices = ["32", "64", "128", "256", "512", "1024", "2048", "4096", "8192"]
    self.l2_ways_choices = ["2", "4", "8"]
    self.llc_ways_choices = ["4", "8", "16"]
    self.cache_choices = ["ESP RTL", "SPANDEX HLS", "ESP HLS"]
    self.cache_line_choices = ["128", "256", "512"]

    self.caches_frame = ctk.CTkFrame(self.left_panel, fg_color="#ebebeb")
    self.caches_frame.pack(padx=(8, 3), pady=(10,20), fill="x")
    self.title_label = StyledComponents.Header(self.caches_frame, "Caches Configuration", 0, 0)
    # self.title_label.grid(row=0, column=0, columnspan=2, pady=10)

    self.enable_caches_cb = ctk.CTkCheckBox(self.caches_frame, variable=self.soc.cache_en, text="Enable Caches", fg_color="green", 
              border_color="grey", width=0, corner_radius=0, checkbox_width=18, checkbox_height=18, 
              onvalue = 1, offvalue = 0, font=("Arial", 10), hover=False, command=main_frame.update_noc_config)
    self.enable_caches_cb.grid(row=1, column=0, sticky="w", padx=20, pady=20)

    self.l2_label = ctk.CTkLabel(self.caches_frame, text="Implementation", font=("Arial", 10))
    self.l2_label.grid(row=2, column=0, padx=20, pady=(10, 5), sticky="w")

    self.esp_rtl_frame = ctk.CTkFrame(self.caches_frame)
    self.esp_rtl_frame.grid(row=2, column=1, padx=20, pady=5)
    self.esp_rtl_dd = ctk.CTkOptionMenu(self.esp_rtl_frame, variable=self.soc.cache_impl, values=self.cache_choices, fg_color="white", 
                      bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black", font=("Arial", 10), dropdown_fg_color="white", 
                      dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8", hover=False, 
                      button_hover_color="lightgrey", width=160, command=main_frame.update_noc_config)
    self.esp_rtl_dd.pack(padx=3, pady=3)

    self.l2_label = ctk.CTkLabel(self.caches_frame, text="Cache Line Size", font=("Arial", 10))
    self.l2_label.grid(row=3, column=0, padx=20, pady=(10, 5), sticky="w")

    self.cache_line_frame = ctk.CTkFrame(self.caches_frame)
    self.cache_line_frame.grid(row=3, column=1, padx=20, pady=5)
    self.cache_line_dd = ctk.CTkOptionMenu(self.cache_line_frame, variable=self.soc.cache_line_size, values=self.cache_line_choices, 
                         fg_color="white", bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black", dropdown_fg_color="white",
                         dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8", font=("Arial", 10), hover=False, 
                         button_hover_color="lightgrey", width=160, command=main_frame.update_noc_config)
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
                      button_hover_color="lightgrey", width=165, command=main_frame.update_noc_config)
    self.l2_ways_dd.pack(padx=3, pady=3)

    self.l2_sets_frame = ctk.CTkFrame(self.caches_frame)
    self.l2_sets_frame.grid(row=6, column=0, padx=20, pady=5)
    self.l2_sets_dd = ctk.CTkOptionMenu(self.l2_sets_frame, variable=self.soc.l2_sets, values=self.sets_choices,
                      fg_color="white", bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black", dropdown_fg_color="white",
                      dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8", font=("Arial", 10), hover=False, 
                      button_hover_color="lightgrey", width=165, command=main_frame.update_noc_config)
    self.l2_sets_dd.pack(padx=3, pady=3)

    self.llc_ways_frame = ctk.CTkFrame(self.caches_frame)
    self.llc_ways_frame.grid(row=5, column=1, padx=20, pady=5)
    self.llc_ways_dd = ctk.CTkOptionMenu(self.llc_ways_frame, variable=self.soc.llc_ways, values=self.llc_ways_choices,
                       fg_color="white", bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black", dropdown_fg_color="white",
                       dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8", font=("Arial", 10), hover=False, 
                       button_hover_color="lightgrey", width=165, command=main_frame.update_noc_config)
    self.llc_ways_dd.pack(padx=3, pady=3)

    self.llc_sets_frame = ctk.CTkFrame(self.caches_frame)
    self.llc_sets_frame.grid(row=6, column=1, padx=20, pady=5)
    self.llc_sets_dd = ctk.CTkOptionMenu(self.llc_sets_frame, variable=self.soc.llc_sets, values=self.sets_choices,
                       fg_color="white", bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black", dropdown_fg_color="white",
                       dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8", font=("Arial", 10), hover=False,
                       button_hover_color="lightgrey", width=165, command=main_frame.update_noc_config)
    self.llc_sets_dd.pack(padx=3, pady=3)

    self.acc_l2_ways_frame = ctk.CTkFrame(self.caches_frame)
    self.acc_l2_ways_frame.grid(row=8, column=0, padx=20, pady=5)
    self.acc_l2_ways_dd = ctk.CTkOptionMenu(self.acc_l2_ways_frame, variable=self.soc.acc_l2_ways, values=self.l2_ways_choices,
                          fg_color="white", bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black", dropdown_fg_color="white",
                          dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8", font=("Arial", 10), hover=False, 
                          button_hover_color="lightgrey", width=165, command=main_frame.update_noc_config)
    self.acc_l2_ways_dd.pack(padx=3, pady=3)

    self.acc_l2_sets_frame = ctk.CTkFrame(self.caches_frame)
    self.acc_l2_sets_frame.grid(row=9, column=0, padx=20, pady=5)
    self.acc_l2_sets_dd = ctk.CTkOptionMenu(self.acc_l2_sets_frame, variable=self.soc.acc_l2_sets, values=self.sets_choices,
                          fg_color="white", bg_color="#e8e8e8", button_color="#e8e8e8", text_color="black", dropdown_fg_color="white",
                          dropdown_font=("Arial", 10), dropdown_hover_color="#e8e8e8", font=("Arial", 10), hover=False, 
                          button_hover_color="lightgrey", width=165, command=main_frame.update_noc_config)
    self.acc_l2_sets_dd.pack(padx=3, pady=3)

class AdvancedConfigFrame:
  def __init__(self, soc, left_panel, main_frame):
    self.soc = soc
    self.left_panel = left_panel
    self.main_frame = main_frame

    self.adv_frame = ctk.CTkFrame(self.left_panel, fg_color="#ebebeb")
    self.adv_frame.pack(padx=(8,3), pady=(10,20), fill="x")
    self.title_label = StyledComponents.Header(self.adv_frame, "Advanced Settings", 0, 0)
    # self.title_label.grid(row=0, column=0, columnspan=2, pady=10)

    self.clk_label = ctk.CTkLabel(self.adv_frame, text="Clock Strategy", font=("Arial", 10))
    self.clk_label.grid(row=1, column=0, sticky="w", pady=5, padx=(20, 40))
    self.clk_value_frame = ctk.CTkFrame(self.adv_frame)
    self.clk_value_frame.grid(row=1, column=1, pady=5, padx=20)

    if soc.TECH_TYPE == "asic" or soc.TECH == "inferred" or soc.ESP_EMU_TECH != "none":
      self.clk_value_menu = ctk.CTkOptionMenu(self.clk_value_frame, variable=self.soc.clk_str, values=["Dual external", "Multi DCO", "Single DCO"], fg_color="white", 
                            bg_color="#e8e8e8", button_color="#e8e8e8", width=200, text_color="black", 
                            font=("Arial", 10), button_hover_color="lightgrey", anchor="center", 
                            dropdown_fg_color="white", dropdown_font=("Arial", 10), 
                            dropdown_hover_color="#e8e8e8", command=main_frame.update_noc_config)
      self.clk_value_menu.pack(anchor="center", padx=3, pady=3)
    else:
      self.clk_value = ctk.CTkLabel(self.clk_value_frame, text="Dual external clocks", width=200, font=("Arial", 10, "bold"))
      self.clk_value.pack(anchor="center", padx=3, pady=3)

class EspCreator:
  def __init__(self, root, _soc):
    self.soc = _soc
    self.noc = self.soc.noc
    self.root = root

    # Scrollable main frame
    self.main_frame = ctk.CTkFrame(self.root)
    self.main_frame.pack(padx=10, pady=10, fill="both", expand=True)

    self.main_frame.grid_rowconfigure(0, weight=1)  # Allow rows to expand
    self.main_frame.grid_columnconfigure(0, weight=0)  # Fixed width for left panel
    self.main_frame.grid_columnconfigure(1, weight=1)  # Expandable for right panel

    # Scrollable left panel
    self.left_panel = ctk.CTkScrollableFrame(self.main_frame, width=440, height=680)
    self.left_panel.grid(row=0, column=0, sticky="ns", padx=10, pady=10)

    # Canvas for right panel with both horizontal and vertical scrolling
    self.right_canvas = Canvas(self.main_frame)
    self.right_canvas.grid(row=0, column=1, sticky="nsew", padx=10, pady=10)

    # Horizontal scrollbar
    self.h_scrollbar = ctk.CTkScrollbar(self.main_frame, orientation="horizontal", command=self.right_canvas.xview)
    self.h_scrollbar.grid(row=1, column=1, sticky="ew")

    # Vertical scrollbar
    self.v_scrollbar = ctk.CTkScrollbar(self.main_frame, orientation="vertical", command=self.right_canvas.yview)
    self.v_scrollbar.grid(row=0, column=2, sticky="ns")

    # Configure the canvas to use the scrollbars
    self.right_canvas.configure(xscrollcommand=self.h_scrollbar.set, yscrollcommand=self.v_scrollbar.set)

    # Embed a frame within the canvas
    self.right_panel_frame = ctk.CTkFrame(self.right_canvas)
    self.right_canvas.create_window((0, 0), window=self.right_panel_frame, anchor="nw")

    # Configure the scroll region
    def configure_canvas(event):
        self.right_canvas.configure(scrollregion=self.right_canvas.bbox("all"))

    self.right_panel_frame.bind("<Configure>", configure_canvas)

    # Static configuration frames
    self.soc_config_frame = SocConfigFrame(self.soc, self.left_panel, self)
    self.peripherals_config_frame = PeripheralsConfigFrame(self.soc, self.left_panel, self)
    self.debug_link_config_frame = DebugLinkConfigFrame(self.soc, self.left_panel)
    self.debug_link_config_frame.update_frame()
    self.adv_config_frame = AdvancedConfigFrame(self.soc, self.left_panel, self)
    self.caches_config_frame = CachesConfigFrame(self.soc, self.left_panel, self)
    self.noc_config_frame = NoCConfigFrame(self.soc, self.left_panel, self.right_panel_frame) 

    self.message_frame = ctk.CTkFrame(self.left_panel, fg_color="#ebebeb")
    self.message_frame.pack(padx=(8,3), pady=(10,20), fill="x")
    self.title_label = ctk.CTkLabel(self.message_frame, text="Messages", font=("Arial", 10, "bold"))
    self.title_label.pack(fill="x", expand=True, pady=10)
    self.message = ctk.CTkTextbox(self.message_frame, height=150, wrap=WORD)
    self.message.pack(fill="x", expand=True)

    self.gen_soc_config = ctk.CTkButton(self.left_panel, text="Generate SoC Configuration", font=("Arial", 12), height=40, command=self.generate_files)
    self.gen_soc_config.pack(fill="x", pady=15)
    self.gen_soc_config.configure(state="disabled")

    self.noc_config_frame.set_message(self.message, self.soc_config_frame, self.gen_soc_config)
    self.noc_config_frame.create_noc()

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
    self.soc.write_config(self.debug_link_config_frame.ip_addr_value.get(), self.debug_link_config_frame.mac_addr_value.get())
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
    soc.write_config(app.debug_link_config_frame.ip_addr_value.get(), app.debug_link_config_frame.mac_addr_value.get())
    root.destroy()

root.protocol("WM_DELETE_WINDOW", on_closing)
root.mainloop()