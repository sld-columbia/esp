#!/usr/bin/env python3

# Copyright (c) 2011-2024 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

import customtkinter as ctk
from tkinter import *
import tkinter as tk
from tkinter.ttk import Separator
from thirdparty import *
import Pmw
import xml.etree.ElementTree

import functools

from soc import *
from socmap_gen import NCPU_MAX
from socmap_gen import NMEM_MAX
from socmap_gen import NSLM_MAX
from socmap_gen import NACC_MAX
from socmap_gen import NTILE_MAX
from socmap_gen import NFULL_COHERENT_MAX
from socmap_gen import NLLC_COHERENT_MAX

class StyledComponents:
  @staticmethod
  def OptionMenu(parent, variable, values, width=140, font=("Arial", 10), anchor="center", state="normal", command=None):
    """Styled option menu."""
    menu = ctk.CTkOptionMenu(
      parent, variable=variable, values=values, fg_color="white",
      bg_color="#e8e8e8", button_color="lightgrey", width=width, text_color="black",
      font=font, button_hover_color="grey", anchor=anchor,
      dropdown_fg_color="white", dropdown_font=("Arial", 10),
      dropdown_hover_color="#e8e8e8", state=state, command=command
    )
    return menu

  @staticmethod
  def CheckBox(frame, variable, text, row, column, command=None, onvalue=1, offvalue=0):
    """Styled checkbox."""
    checkbox = ctk.CTkCheckBox(frame, text=text, variable=variable, onvalue=onvalue, offvalue=offvalue,
                                fg_color="green", border_color="grey", font=("Arial", 10), width=72,
                                checkbox_width=18, checkbox_height=18, corner_radius=0, hover=False, command=command)
    checkbox.grid(row=row, column=column, padx=15, pady=10, sticky="e")
    return checkbox

  @staticmethod
  def LabelPack(frame, text, font=("Arial", 10), text_color="black", side="left", padx=(14,24), pady=10):
    """Styled label."""
    label = ctk.CTkLabel(frame, text=text, font=font, text_color=text_color)
    label.pack(side=side, padx=padx, pady=pady)
    return label

  @staticmethod
  def LabelGrid(frame, text, font=("Arial", 12, "bold"), text_color="black", row=0, column=0, padx=5, pady=20, columnspan=None, sticky="nsew"):
    """Styled label."""
    label = ctk.CTkLabel(frame, text=text, font=font, text_color=text_color)
    label.grid(row=row, column=column, columnspan=columnspan, padx=padx, pady=pady, sticky=sticky)
    return label
  
  @staticmethod
  def Entry(frame, variable=None, width=45, font=("Arial", 10), placeholder_text_color="black"):
    """Styled entry box."""
    entry = ctk.CTkEntry(frame, textvariable=variable, width=width, font=font, placeholder_text_color=placeholder_text_color, border_width=0)
    return entry
  
  @staticmethod
  def CheckBox(frame, variable, text, row, column, command=None, onvalue=1, offvalue=0):
    """Styled checkbox."""
    checkbox = ctk.CTkCheckBox(frame, text=text, variable=variable, onvalue=onvalue, offvalue=offvalue,
                                fg_color="green", border_color="grey", font=("Arial", 10), width=72,
                                checkbox_width=18, checkbox_height=18, corner_radius=0, hover=False, command=command)
    checkbox.grid(row=row, column=column, padx=15, pady=10, sticky="e")
    return checkbox

  @staticmethod
  def CheckBoxPack(frame, text, variable):
    checkbox = ctk.CTkCheckBox(frame, text=text, font=("Arial", 11), fg_color="green",
                  border_color="grey", width=0, corner_radius=0, checkbox_width=18, checkbox_height=18,
                  hover=False, variable=variable)
    checkbox.pack(padx=15, pady=10, anchor="w")
    return checkbox
  
  @staticmethod
  def Button(frame, text, font=("Arial", 10), width=100, command=None):
    """Styled button."""
    button = ctk.CTkButton(frame, text=text, font=font, width=width, command=command)
    return button

def isInt(s):
  try:
    int(s)
    return True
  except ValueError:
    return False


class Characterization():
  ip = ""

class VFPoint():
  voltage = 0
  frequency = 0
  energy = 0

class Tile():

  def update_tile(self, soc):
    selection = self.ip_type.get()
    self.ip_list.forget()
    self.ip_list.configure(values=soc.list_of_ips)
    self.ip_list.pack(pady=10)
    if soc.IPs.PROCESSORS.count(selection):
       self.frame.configure(fg_color="#ef6865")
    elif soc.IPs.MISC.count(selection):
       self.frame.configure(fg_color="#fdfda0")
    elif soc.IPs.MEM.count(selection):
       self.frame.configure(fg_color="#6ab0d4")
    elif soc.IPs.SLM.count(selection):
       self.frame.configure(fg_color="#c9a6e4")
    elif soc.IPs.ACCELERATORS.count(selection):
       self.frame.configure(fg_color="#78cbbb")
       self.point_label.configure(text_color="black")
       self.vendor = soc.IPs.VENDOR[selection]
       dma_width = str(soc.noc.dma_noc_width.get())
       display_points = [point for point in soc.IPs.POINTS[selection] if "dma" + str(dma_width) in point]
       self.point_select.configure(values=display_points)
       point = self.point.get()
       self.point_select.set("")
       for p in display_points:
         if point == p:
           self.point_select.set(point)
           break;
         else:
           self.point_select.set(str(display_points[0]))
       self.point_select.configure(state="normal")
    else:
       self.frame.configure(fg_color='white')
       if self.ip_type.get() != "empty":
         self.ip_type.set("empty")

    try:
      if soc.IPs.ACCELERATORS.count(selection) and soc.cache_en.get() == 1 and soc.noc.dma_noc_width.get() == soc.ARCH_BITS:
        self.has_l2_selection.configure(state="normal")
      else:
        if soc.IPs.PROCESSORS.count(selection) and soc.cache_en.get() == 1:
          self.has_l2.set(1)
        else:
          self.has_l2.set(0)
        self.has_l2_selection.configure(state="disabled")
      if soc.IPs.ACCELERATORS.count(selection) and (soc.TECH == "asic" or soc.TECH == "inferred"):
        self.has_tdvfs_selection.configure(state="normal")
      else:
        self.has_tdvfs_selection.configure(state="disabled")
      if soc.IPs.SLM.count(selection) and soc.TECH == "asic":
        self.has_ddr_selection.configure(state="normal")
      else:
        # DDR SLM tile only supported w/ ASIC technology
        self.has_ddr.set(0)
        self.has_ddr_selection.configure(state="disabled")
    except:
      pass

  def center(self, toplevel):
    toplevel.update_idletasks()
    w = toplevel.winfo_screenwidth()
    h = toplevel.winfo_screenheight()
    size = tuple(int(_) for _ in toplevel.geometry().split('+')[0].split('x'))
    x = w/2 - size[0]/2 + 100
    y = h/2 - size[1]/2
    toplevel.geometry("%dx%d+%d+%d" % (size + (x, y)))

  def __init__(self, top, x, y):
    self.row = x
    self.col = y
    self.ip_type = StringVar()
    self.point = StringVar()
    self.vendor = ""
    self.has_l2 = IntVar()
    self.has_tdvfs = IntVar()
    self.has_ddr = IntVar()


class NoC():

  rows = 0
  cols = 0
  top = ""

  topology = []

  def create_topology(self, top, _R, _C):
    self.top = top
    new_topology = []
    for y in range(_R):
      new_topology.append([])
      for x in range(_C):
        new_topology[y].append(Tile(top, y, x))
        if x < self.cols and y < self.rows:
          new_topology[y][x].ip_type.set(self.topology[y][x].ip_type.get())
          new_topology[y][x].has_l2.set(self.topology[y][x].has_l2.get())
          new_topology[y][x].has_tdvfs.set(self.topology[y][x].has_tdvfs.get())
          new_topology[y][x].has_ddr.set(self.topology[y][x].has_ddr.get())
          new_topology[y][x].point.set(self.topology[y][x].point.get())
          new_topology[y][x].vendor = self.topology[y][x].vendor
    self.topology = new_topology
    self.rows = _R
    self.cols = _C

  def has_dvfs(self):
    for y in range(0, self.rows):
      for x in range(0, self.cols):
         tile = self.topology[y][x]
         if tile.has_tdvfs.get():
           return True
    return False

  def get_cpu_num(self, soc):
    tot_cpu = 0
    for y in range(0, self.rows):
      for x in range(0, self.cols):
         tile = self.topology[y][x]
         selection = tile.ip_type.get()
         if soc.IPs.PROCESSORS.count(selection):
            tot_cpu += 1
    return tot_cpu

  def get_acc_num(self, soc):
    tot_acc = 0
    for y in range(0, self.rows):
      for x in range(0, self.cols):
         tile = self.topology[y][x]
         selection = tile.ip_type.get()
         if soc.IPs.ACCELERATORS.count(selection):
            tot_acc += 1
    return tot_acc

  def get_acc_l2_num(self, soc):
    tot_acc_l2 = 0
    for y in range(0, self.rows):
      for x in range(0, self.cols):
         tile = self.topology[y][x]
         selection = tile.ip_type.get()
         if soc.IPs.ACCELERATORS.count(selection):
           if tile.has_l2.get() != 0:
             tot_acc_l2 += 1
    return tot_acc_l2

  def get_acc_impl_valid(self, soc):
    for y in range(0, self.rows):
      for x in range(0, self.cols):
         tile = self.topology[y][x]
         selection = tile.ip_type.get()
         if soc.IPs.ACCELERATORS.count(selection):
           if tile.point_select.get() == "" and (not tile.ip_type.get().lower() in THIRDPARTY_COMPATIBLE):
             return False
    return True

  def get_mem_num(self, soc):
    tot_mem = 0
    for y in range(0, self.rows):
      for x in range(0, self.cols):
         tile = self.topology[y][x]
         selection = tile.ip_type.get()
         if soc.IPs.MEM.count(selection):
            tot_mem += 1
    return tot_mem

  def get_slm_num(self, soc):
    tot_slm = 0
    for y in range(0, self.rows):
      for x in range(0, self.cols):
         tile = self.topology[y][x]
         selection = tile.ip_type.get()
         if soc.IPs.SLM.count(selection) and tile.has_ddr.get() == 0:
            tot_slm += 1
    return tot_slm

  def get_slmddr_num(self, soc):
    tot_slmddr = 0
    for y in range(0, self.rows):
      for x in range(0, self.cols):
         tile = self.topology[y][x]
         selection = tile.ip_type.get()
         if soc.IPs.SLM.count(selection) and tile.has_ddr.get() != 0:
            tot_slmddr += 1
    return tot_slmddr

  # WARNING: Geometry in this class only uses x=rows, y=cols, but socmap uses y=row, x=cols!
  def __init__(self):
    self.cols = 0
    self.rows = 0
    self.coh_noc_width = IntVar()
    self.dma_noc_width = IntVar()
    self.multicast_en = IntVar()
    self.max_mcast_dests = IntVar()
    self.monitor_ddr = IntVar()
    self.monitor_mem = IntVar()
    self.monitor_inj = IntVar()
    self.monitor_routers = IntVar()
    self.monitor_accelerators = IntVar()
    self.monitor_l2 = IntVar()
    self.monitor_llc = IntVar()
    self.monitor_dvfs = IntVar()

#NoC configuration frame (middle)
class NoCConfigFrame:
  current_nocx = 0
  current_nocy = 0

  noc_tiles = []
  row_frames = []

  def changed(self,*args):
    if isInt(self.ROWS.get()) == False or isInt(self.COLS.get()) == False:
       return
    for y in range(0, int(self.ROWS.get())):
      for x in range(0, int(self.COLS.get())):
         self.noc.topology[y][x].update_tile(self.soc)
    self.update_msg()

  def update_frame(self):
    if self.noc.cols > 0 and self.noc.rows > 0:
       self.COLS.insert(0, str(self.noc.cols))
       self.ROWS.insert(0, str(self.noc.rows))
    self.create_noc()
    self.changed()

  def create_tile(self, frame, tile):
    #computing the width of the widget
    list_items = self.soc.list_of_ips
    width = 0
    for x in range(0, len(list_items)):
      if len(list_items[x]) > width:
        width = len(list_items[x])
    tile.frame = frame

    #creating tile
    tile.type_frame = ctk.CTkFrame(frame, fg_color="#e8e8e8")
    tile.type_frame.pack(anchor="center", pady=(15,0))

    impl_frame = ctk.CTkFrame(frame, width=0, height=0, fg_color="#e8e8e8")
    impl_frame.pack(anchor="center")

    config_frame = ctk.CTkFrame(frame, fg_color="#e8e8e8")
    config_frame.pack(anchor="center", padx=15, pady=(0,15))

    tile_type_label = StyledComponents.LabelPack(tile.type_frame, text="Tile", font=("Arial", 11), text_color="black")
    tile.ip_list = StyledComponents.OptionMenu(tile.type_frame, variable=tile.ip_type, values=list_items, command=self.changed)
    tile.ip_list.pack(side="right", padx=20, pady=10)
  
    tile.point_label = StyledComponents.LabelPack(impl_frame, text="Impl.", font=("Arial", 10), text_color="grey", side="left", padx=(12,0), pady=10)
    tile.point_select = StyledComponents.OptionMenu(impl_frame, variable=tile.point, values=[], state="disabled", command=self.changed)
    tile.point_select.pack(side="right", padx=(18,1), pady=10)
 
    tile.has_l2_selection = StyledComponents.CheckBox(config_frame, variable=tile.has_l2, text="Cache", row=0, column=0, command=self.changed)
    tile.has_ddr_selection = StyledComponents.CheckBox(config_frame, variable=tile.has_ddr, text="DDR", row=0, column=1, command=self.changed)
    tile.has_tdvfs_selection = StyledComponents.CheckBox(config_frame, variable=tile.has_tdvfs, text="DVFS", row=1, column=0, command=self.changed)


  def __init__(self, soc, left_panel, right_panel):
    self.soc = soc
    self.noc = self.soc.noc
    self.left_panel = left_panel
    self.right_panel = right_panel
    
    self.noc_select_frame = ctk.CTkFrame(self.left_panel, fg_color="#ebebeb")
    self.noc_select_frame.pack(padx=(8, 3), pady=(10, 20), fill="x")
    self.title_label = StyledComponents.LabelGrid(self.noc_select_frame, text="NoC Configuration", font=("Arial", 12, "bold"), row=0, column=0, columnspan=5, padx=0, pady=10)

    self.noc_rows_label = StyledComponents.LabelGrid(self.noc_select_frame, text="Rows:", font=("Arial", 10), row=1, column=0, padx=20, pady=20, sticky="e")
    self.noc_rows = StyledComponents.Entry(self.noc_select_frame)
    self.ROWS = self.noc_rows
    self.noc_rows.insert(0, "2")
    self.noc_rows.grid(row=1, column=1, padx=5, pady=20)

    self.noc_columns_label = StyledComponents.LabelGrid(self.noc_select_frame, text="Columns:", font=("Arial", 10), row=1, column=2, padx=20, pady=20, sticky="e")
    self.noc_columns = StyledComponents.Entry(self.noc_select_frame)
    self.COLS = self.noc_columns
    self.noc_columns.insert(0, "2")
    self.noc_columns.grid(row=1, column=3, padx=5, pady=20)

    self.update_noc_button = StyledComponents.Button(self.noc_select_frame, text="Update NoC", font=("Arial", 10), command=self.create_noc)
    self.update_noc_button.grid(row=1, column=4, padx=20, pady=20)

    self.noc_config_frame = ctk.CTkFrame(self.noc_select_frame, fg_color="#ebebeb")
    self.noc_config_frame.grid(row=2, column=0, columnspan=5, pady=10)

    self.noc_width_choices = ["32", "64", "128", "256", "512", "1024"]

    # Coherence NoC Planes
    self.noc_planes_label = StyledComponents.LabelGrid(self.noc_config_frame, text="Coherence NoC Planes (1,2,3) Bitwidth", font=("Arial", 10), row=2, column=0, padx=15, pady=5, sticky="w")
    
    self.noc_planes_frame = ctk.CTkFrame(self.noc_config_frame)
    self.noc_planes_frame.grid(row=2, column=1, pady=5, padx=15)
    self.noc_planes_value_menu = StyledComponents.OptionMenu(self.noc_planes_frame, variable=self.noc.coh_noc_width, values=self.noc_width_choices, width=100, font=("Arial", 10))
    self.noc_planes_value_menu.pack(anchor="center", padx=3, pady=3)

    # DMA NoC Planes
    self.dma_planes_label = StyledComponents.LabelGrid(self.noc_config_frame, text="DMA NoC Planes (4,6) Bitwidth", font=("Arial", 10), row=3, column=0, padx=15, pady=5, sticky="w")

    self.dma_planes_value_frame = ctk.CTkFrame(self.noc_config_frame)
    self.dma_planes_value_frame.grid(row=3, column=1, pady=5, padx=15)
    self.dma_planes_value_menu = StyledComponents.OptionMenu(self.dma_planes_value_frame, variable=self.noc.dma_noc_width, values=self.noc_width_choices, width=100, font=("Arial", 10))
    self.dma_planes_value_menu.pack(anchor="center", padx=3, pady=3)

    self.mmio_label = StyledComponents.LabelGrid(self.noc_config_frame, text="MMIO/Irq NoC Plane (5) Bitwidth", font=("Arial", 10), row=4, column=0, padx=15, pady=5, sticky="w")

    self.mmio_value_frame = ctk.CTkFrame(self.noc_config_frame)
    self.mmio_value_frame.grid(row=4, column=1, pady=5, padx=15)
    self.mmio_value = ctk.CTkLabel(self.mmio_value_frame, text="32", width=100, font=("Arial", 10, "bold"))
    self.mmio_value.pack(anchor="center", padx=3, pady=3)

    # Enable Multicast
    self.enable_multicast_cb = ctk.CTkCheckBox(
        self.noc_config_frame, variable=self.noc.multicast_en, text="Enable Multicast on DMA Planes", font=("Arial", 11),
        fg_color="green", border_color="grey", width=0, corner_radius=0, checkbox_width=18, checkbox_height=18, hover=False
    )
    self.enable_multicast_cb.grid(row=5, column=0, sticky="w", padx=15, pady=10)

    self.max_multicast_choices = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16"]
    # Maximum Multicast Destinations
    self.max_multicast_label = StyledComponents.LabelGrid(self.noc_config_frame, text="Maximum Multicast Destinations", font=("Arial", 11), row=6, column=0, padx=15, pady=5, sticky="w")

    self.max_multicast_value_frame = ctk.CTkFrame(self.noc_config_frame)
    self.max_multicast_value_frame.grid(row=6, column=1, pady=5, padx=15)
    self.max_multicast_value_menu = StyledComponents.OptionMenu(self.max_multicast_value_frame, variable=self.noc.max_mcast_dests, values=self.max_multicast_choices, width=100, font=("Arial", 10))
    self.max_multicast_value_menu.pack(anchor="center", padx=3, pady=3)

    self.probe_frame = ctk.CTkFrame(self.left_panel, fg_color="#ebebeb")
    self.probe_frame.pack(padx=(8,3), pady=10, fill="x")
    self.title_label = ctk.CTkLabel(self.probe_frame, text="Probe Configuration", font=("Arial", 12, "bold"))
    self.title_label.pack(pady=10)

    self.ddr_cb = ctk.CTkCheckBox(self.probe_frame, text="Monitor DDR bandwidth", variable=self.noc.monitor_ddr)

    self.mem_access_cb = StyledComponents.CheckBoxPack(self.probe_frame, text="Monitor Memory Access", variable=self.noc.monitor_mem)

    self.inj_rate_cb = StyledComponents.CheckBoxPack(self.probe_frame, text="Monitor Injection Rate", variable=self.noc.monitor_inj)

    self.router_ports_cb = StyledComponents.CheckBoxPack(self.probe_frame, text="Monitor Router Ports", variable=self.noc.monitor_routers)

    self.acc_status_cb = StyledComponents.CheckBoxPack(self.probe_frame, text="Monitor Accelerator Status", variable=self.noc.monitor_accelerators)

    self.l2_hm_cb = StyledComponents.CheckBoxPack(self.probe_frame, text="Monitor L2 Hit/Miss", variable=self.noc.monitor_l2)

    self.llc_hm_cb = StyledComponents.CheckBoxPack(self.probe_frame, text="Monitor LLC Hit/Miss", variable=self.noc.monitor_llc)

    self.dvfs_cb = StyledComponents.CheckBoxPack(self.probe_frame, text="Monitor DVFS", variable=self.noc.monitor_dvfs)

  def update_msg(self):
    self.gen_soc_config.configure(state="disabled")
    tot_tiles = self.noc.rows * self.noc.cols
    tot_cpu = self.noc.get_cpu_num(self.soc)
    if self.soc.cache_en.get():
      tot_full_coherent = self.noc.get_acc_l2_num(self.soc) + self.noc.get_cpu_num(self.soc)
      tot_llc_coherent = self.noc.get_acc_num(self.soc)
    else:
      tot_full_coherent = 0
      tot_llc_coherent = 0
    tot_io = 0
    tot_mem = self.noc.get_mem_num(self.soc)
    tot_slm = self.noc.get_slm_num(self.soc)
    tot_slm_size = tot_slm * self.soc.slm_kbytes.get()
    tot_slmddr = self.noc.get_slmddr_num(self.soc)
    tot_acc = self.noc.get_acc_num(self.soc)
    acc_impl_valid = self.noc.get_acc_impl_valid(self.soc)
    for y in range(0, self.noc.rows):
      for x in range(0, self.noc.cols):
        tile = self.noc.topology[y][x]
        selection = tile.ip_type.get()
        if self.soc.IPs.MISC.count(selection):
          tot_io += 1

    if self.soc.noc.get_acc_num(self.soc) > 0:
      self.acc_status_cb.configure(state="normal")
    else:
      self.acc_status_cb.configure(state="disabled")
      self.noc.monitor_accelerators.set(0)

    if self.soc.noc.has_dvfs():
      self.dvfs_cb.configure(state="normal")
    else:
      self.dvfs_cb.configure(state="disabled")
      self.noc.monitor_dvfs.set(0)

    #update message box
    self.message.delete(0.0, END)
    self.soc_config_frame.set_cpu_specific_labels(self.soc)

    string = ""
    if (tot_cpu > 0) and \
       (tot_cpu <= NCPU_MAX) and \
       (tot_mem > 0 or (tot_slm > 0 and (self.soc.cache_en.get() == 0) and self.soc.CPU_ARCH.get() == "ibex")) and \
       (tot_mem <= self.soc.nmem_max) and \
       (tot_mem != 3) and \
       (tot_slm <= NSLM_MAX) and \
       (tot_slm <= 1 or self.soc.slm_kbytes.get() >= 1024) and \
       (tot_acc <= NACC_MAX) and \
       (tot_io == 1 ) and \
       (tot_tiles <= NTILE_MAX) and \
       (self.noc.cols <= 16 and self.noc.rows <= 16) and \
       (tot_full_coherent <= NFULL_COHERENT_MAX) and \
       (tot_llc_coherent <= NLLC_COHERENT_MAX) and \
       (not (self.soc.TECH == "virtexu" and tot_mem >= 2 and (self.noc.rows < 3 or self.noc.cols < 3))) and \
       (self.soc.cache_spandex.get() == 0 or self.soc.CPU_ARCH.get() == "ariane" or self.soc.cache_en.get() == 0) and \
       (tot_cpu == 1 or self.soc.cache_en.get()) and \
       (self.soc.llc_sets.get() < 8192 or self.soc.llc_ways.get() < 16 or tot_mem > 1) and \
       (self.soc.cache_en.get() != 1 or self.soc.cache_line_size.get() >= self.noc.coh_noc_width.get()) and \
       (self.soc.cache_en.get() != 1 or self.soc.cache_line_size.get() >= self.noc.dma_noc_width.get()) and \
       (self.soc.TECH != "asic" or self.soc.cache_line_size.get() >= self.soc.mem_link_width.get()) and \
       (self.soc.TECH != "asic" or self.noc.coh_noc_width.get() >= self.soc.mem_link_width.get()) and \
       (self.soc.TECH != "asic" or self.noc.dma_noc_width.get() >= self.soc.mem_link_width.get()) and \
       ((self.soc.cache_en.get() == 1) or (self.noc.coh_noc_width.get() == self.soc.ARCH_BITS)) and \
       (self.noc.coh_noc_width.get() >= self.soc.ARCH_BITS) and \
       (self.noc.dma_noc_width.get() >= self.soc.ARCH_BITS) and acc_impl_valid and \
       (self.soc.cache_line_size.get() == 128 or (self.soc.cache_spandex.get() == 0 and self.soc.cache_rtl.get() == 1)) and \
       (self.soc.jtag_en.get() == 0 or (self.noc.dma_noc_width.get() == 64 and self.noc.coh_noc_width.get() == 64)) and \
       ((self.soc.TECH != "asic" and self.soc.TECH != "inferred" and self.soc.ESP_EMU_TECH == "none") \
         or tot_mem == 0 or self.soc.cache_en.get() == 1) and \
       (not self.noc.multicast_en.get() or self.noc.dma_noc_width.get() > 128 or \
       (self.noc.dma_noc_width.get() == 128 and self.noc.max_mcast_dests.get() <= 11) or \
       (self.noc.dma_noc_width.get() == 64 and self.noc.max_mcast_dests.get() <= 4)):
      # Spandex beta warning
      if self.soc.cache_spandex.get() != 0 and self.soc.cache_en.get() == 1:
        string += "INFO: Spandex cache hierarchy is in beta testing\n"
        string += "The default HLS configuration is 512x4 L2 and 1024x8 LLC\n"
        if self.soc.TECH != "asic" and self.soc.TECH != "virtexu" and self.soc.TECH != "virtexup":
          string += "    Use a smaller implementation if not using a Virtex US/US+\n"
      if (self.soc.clk_str.get() == 0 and self.soc.TECH_TYPE == "asic"):
        string += "INFO: Clock strategy: two external clocks - 1 for the NoC and 1 for the Tiles. \n"
      if (self.soc.clk_str.get() == 1 and self.soc.TECH_TYPE == "asic"):
        string += "INFO: Clock strategy: 1 DCO per tile plus 1 DCO for the NoC inside the IO tile. \n"
      if (self.soc.clk_str.get() == 2 and self.soc.TECH_TYPE == "asic"):
        string += "INFO: Clock strategy: 1 DCO inside the IO tile for the full chip. \n"
      if self.noc.multicast_en.get():
        string += "INFO: Multicast NoC is in beta testing\n"
      if self.noc.dma_noc_width.get() != self.soc.ARCH_BITS:
        string += "INFO: to enable accelerator private caches, DMA NoC width must match CPU architecture size (64 bits for Ariane, 32 for Leon3 and Ibex)\n"
      self.gen_soc_config.configure(state="normal")
    else:
      if (self.noc.cols > 16 or self.noc.rows > 16):
        string += "Maximum number of rows and columns is 16.\n"
      if (tot_cpu == 0):
        string += "ERROR: At least one CPU is required.\n"
      if (tot_cpu > 1 and not self.soc.cache_en.get()):
        string += "ERROR: Caches are required for multicore SoCs.\n"
      if (tot_io == 0):
        string += "ERROR: At least I/O tile is required.\n"
      if (tot_cpu > NCPU_MAX):
        new_err = "ERROR: Maximum number of supported CPUs is " + str(NCPU_MAX) + ".\n"
        string += new_err
      if (tot_io > 1):
        string += "ERROR: Multiple I/O tiles are not supported.\n"
      if (tot_mem < 1 and tot_slm < 1):
        string += "ERROR: There must be at least 1 memory tile or 1 SLM tile.\n"
      if (tot_mem > self.soc.nmem_max):
        string += "ERROR: There must be no more than " + str(self.soc.nmem_max) + " memory tiles.\n"
      if (tot_mem == 0 and (self.soc.CPU_ARCH.get() != "ibex")):
        string += "ERROR: SLM tiles can be used in place of memory tiles only with the lowRISC ibex core.\n"
      if (tot_mem == 0 and (self.soc.cache_en.get() == 1)):
        string += "ERROR: There must be at least 1 memory tile to enable the ESP cache hierarchy.\n"
      if (tot_mem == 3): 
        string += "ERROR: Number of memory tiles must be a power of 2.\n" 
      if (tot_slm > NSLM_MAX):
        string += "ERROR: There must be no more than " + str(NSLM_MAX) + " SLM tiles.\n"
      if (tot_slm > 1 and self.soc.slm_kbytes.get() < 1024):
        string += "ERROR: SLM size must be 1024 KB or more if placing more than one SLM tile.\n"
      if (self.soc.llc_sets.get() >= 8192 and self.soc.llc_ways.get() >= 16 and tot_mem == 1): 
        string += "ERROR: A 2MB LLC (8192 sets and 16 ways) requires multiple memory tiles.\n"
      if (self.soc.TECH == "virtexu" and tot_mem >= 2 and (self.noc.rows < 3 or self.noc.cols < 3)):
        string += "ERROR: A 3x3 NoC or larger is recommended for multiple memory tiles for virtexu (profpga-xcvu440).\n" 
      if (tot_acc > NACC_MAX):
        string += "ERROR: There must no more than " + str(NACC_MAX) + " (can be relaxed).\n"
      if (tot_tiles > NTILE_MAX):
        string += "ERROR: Maximum number of supported tiles is " + str(NTILE_MAX) + ".\n"
      if (tot_full_coherent > NFULL_COHERENT_MAX):
        string += "ERROR: Maximum number of supported fully-coherent devices is " + str(NFULL_COHERENT_MAX) + ".\n"
      if (tot_llc_coherent > NLLC_COHERENT_MAX):
        string += "ERROR: Maximum number of supported LLC-coherent devices is " + str(NLLC_COHERENT_MAX) + ".\n"
      if (self.soc.cache_spandex.get() != 0 and self.soc.CPU_ARCH.get() != "ariane" and self.soc.cache_en.get() == 1):
        string += "ERROR: Spandex currently supports only RISC-V Ariane processor core.\n"
      if (self.soc.cache_en.get() == 1 and self.soc.cache_line_size.get() < self.noc.coh_noc_width.get()):
        string += "ERROR: Cache line size must be greater than or equal to coherence NoC bitwidth.\n"
      if (self.soc.cache_en.get() == 1 and self.soc.cache_line_size.get() < self.noc.dma_noc_width.get()):
        string += "ERROR: Cache line size must be greater than or equal to DMA NoC bitwidth.\n"
      if (self.soc.TECH == "asic" and self.soc.cache_line_size.get() < self.soc.mem_link_width.get()):
        string += "ERROR: Cache line size must be greater than or equal to mem link bitwidth.\n"
      if (self.soc.TECH == "asic" and self.noc.coh_noc_width.get() < self.soc.mem_link_width.get()):
        string += "ERROR: Coherence NoC bitwdith must be greater than or equal to mem link bitwidth.\n"
      if (self.soc.TECH == "asic" and self.noc.dma_noc_width.get() < self.soc.mem_link_width.get()):
        string += "ERROR: DMA NoC bitwdith must be greater than or equal to mem link bitwidth.\n"
      if (self.soc.cache_en.get() != 1) and (self.noc.coh_noc_width.get() > self.soc.ARCH_BITS):
        string += "ERROR: Caches must be enabled to support a coherence NoC width larger than the CPU architecture size.\n"
      if (self.noc.coh_noc_width.get() < self.soc.ARCH_BITS):
        string += "ERROR: Coherence NoC width must be greater than or equal to the CPU architecture size.\n"
      if (self.noc.dma_noc_width.get() < self.soc.ARCH_BITS):
        string += "ERROR: DMA NoC width must be greater than or equal to the CPU architecture size.\n"
      if (not acc_impl_valid):
        string += "ERROR: All accelerators must have a selected implementation.\n"
      if (self.soc.cache_line_size.get() > 128 and (self.soc.cache_spandex.get() == 1 or self.soc.cache_rtl.get() == 0)):
        string += "ERROR: Only ESP RTL caches support cache line size greater than 128 bits.\n"
      if (self.soc.jtag_en.get() == 1 and (self.noc.dma_noc_width.get() != 64 or self.noc.coh_noc_width.get() != 64)):
        string += "ERROR: JTAG is only supported for 64-bit coherence and DMA NoC planes.\n"
      if ((self.soc.TECH == "asic" or self.soc.TECH == "inferred" or self.soc.ESP_EMU_TECH != "none") \
           and tot_mem >= 1 and self.soc.cache_en.get() == 0):
        string += "ERROR: Caches must be enabled for ASIC design with memory tiles.\n"
      if (self.noc.multicast_en.get() and self.noc.dma_noc_width.get() == 64 and self.noc.max_mcast_dests.get() > 4):
        string += "ERROR: 64-bit DMA NoC supports up to 4 multicast destinations.\n"
      if (self.noc.multicast_en.get() and self.noc.dma_noc_width.get() == 128 and self.noc.max_mcast_dests.get() > 11):
        string += "ERROR: 128-bit DMA NoC supports up to 11 multicast destinations.\n"
      if (self.noc.multicast_en.get() and self.noc.dma_noc_width.get() == 32):
        string += "ERROR: 32-bit DMA NoC does not support multicast.\n"

    # Update message box
    self.message.insert(0.0, string)

  def set_message(self, message, soc_config_frame, gen_soc_config):
    self.message = message
    self.soc_config_frame = soc_config_frame
    self.gen_soc_config = gen_soc_config

  def create_noc(self):
    #self.pack(side=LEFT,fill=BOTH,expand=YES)
    if isInt(self.ROWS.get()) == False or isInt(self.COLS.get()) == False:
       return
    #destroy current topology
    if len(self.row_frames) > 0:
      for x in range(0, len(self.row_frames)):
        self.row_frames[x].destroy()
      self.noc_tiles = []
      self.row_frames = []
    #create new topology
    self.noc.create_topology(self.right_panel, int(self.ROWS.get()), int(self.COLS.get()))
    for y in range(0, int(self.ROWS.get())):
      self.row_frames.append(ctk.CTkFrame(self.right_panel))
      self.row_frames[y].pack(side=TOP)
      self.noc_tiles.append([])
      for x in range(0, int(self.COLS.get())):
        self.noc_tiles[y].append(ctk.CTkFrame(self.row_frames[y]))
        self.noc_tiles[y][x].pack(side=LEFT)
        # Label(self.noc_tiles[y][x], text="("+str(y)+","+str(x)+")").pack()
        self.create_tile(self.noc_tiles[y][x], self.noc.topology[y][x])
        if len(self.noc.topology[y][x].ip_type.get()) == 0:
          self.noc.topology[y][x].ip_type.set("empty") # default value
    #set call-backs and default value
    for y in range(0, int(self.ROWS.get())):
      for x in range(0, int(self.COLS.get())):
        tile = self.noc.topology[y][x]
        # tile.ip_type.trace('w', self.changed)
    self.soc.IPs = Components(self.soc.TECH, self.noc.dma_noc_width.get(), self.soc.CPU_ARCH.get())
    self.soc.update_list_of_ips()
    self.changed()