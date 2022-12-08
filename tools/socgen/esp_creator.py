#!/usr/bin/env python3

# Copyright (c) 2011-2022 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

###############################################################################
#
# Graphic User Interface for ESP SoC-map
#
###############################################################################

from tkinter import *
from tkinter import messagebox
from tkinter import ttk

import Pmw
import os.path
import shutil
from subprocess import Popen, PIPE

from NoCConfiguration import *
from soc import *
from socmap_gen import *
from mmi64_gen import *
from power_gen import *

def print_usage():
  print("Usage                    : ./esp_creator.py <dma_width> <tech> <linux_mac> <leon3_stack> <fpga_board> <emu_tech> <emu_freq>")
  print("")
  print("")
  print("      <dma_width>        : Bit-width for the DMA channel (currently supporting 32 bits only)")
  print("      <tech>             : Target technology (e.g. virtex7, virtexu, virtexup, ...)")
  print("      <linux_mac>        : MAC Address for Linux network interface")
  print("      <leon3_stack>      : Stack Pointer for LEON3")
  print("      <fpga_board>       : Target FPGA board")
  print("      <emu_tech>         : Target technology override for FPGA emulation of ASIC design")
  print("      <emu_freq>         : Ethernet MDC scaler override for FPGA emulation of ASIC design")
  print("")

#Configuration Frame (top-left)
class ConfigFrame(Frame):

  def __init__(self, soc, top_frame):

    Frame.__init__(self, top_frame, width=75, borderwidth=2, relief=RIDGE) 
    self.pack(side=LEFT, expand=NO, fill=Y)

    Label(self, text="Technology", font="TkDefaultFont 11 bold").pack(side=TOP)
    
    tech_config_frame = Frame(self)
    tech_config_frame.pack(side=TOP)

    self.tech_label = Label(tech_config_frame, text="Target technology: ").grid(row=1, column=1)
    self.tech_label = Label(tech_config_frame, text=soc.TECH, fg="darkgreen").grid(row=2, column=1)

    ttk.Separator(self, orient="horizontal").pack(anchor="nw", fill=X, pady=10)

    Label(self, text="FPGA Prototyping", font="TkDefaultFont 11 bold").pack(side=TOP)
    
    fpga_config_frame = Frame(self)
    fpga_config_frame.pack(side=TOP)

    self.fpga_label = Label(fpga_config_frame, text="Target FPGA board: ").grid(row=1, column=1)
    self.fpga_label = Label(fpga_config_frame, text=soc.FPGA_BOARD, fg="darkgreen").grid(row=2, column=1)
    
class CacheFrame(Frame):

  def __init__(self, soc, top_frame, main_frame):
    self.soc = soc
    Frame.__init__(self, top_frame, width=50, borderwidth=2, relief=RIDGE)
    self.pack(side=LEFT, expand=NO, fill=Y)
    Label(self, text = "Cache Hierarchy ", font="TkDefaultFont 11 bold").pack(side = TOP)

    cache_config_frame = Frame(self)
    cache_config_frame.pack(side=TOP)

    sets_choices = [32, 64, 128, 256, 512, 1024, 2048, 4096, 8192]
    l2_ways_choices = [2, 4, 8]
    llc_ways_choices = [4, 8, 16]
    cache_choices = ["ESP RTL", "SPANDEX HLS", "ESP HLS"]

    Label(cache_config_frame, text = "Caches: ").grid(row=1, column=1)
    Checkbutton(cache_config_frame, text="", variable=soc.cache_en,
                onvalue = 1, offvalue = 0, command=main_frame.update_noc_config).grid(row=1, column=2)
    Label(cache_config_frame, text = "Implementation: ").grid(row=2, column=1)
    OptionMenu(cache_config_frame, soc.cache_impl, *cache_choices, command=main_frame.update_noc_config).grid(row=2,column=2)
    Label(cache_config_frame, text = "L2 SETS: ").grid(row=3, column=1)
    OptionMenu(cache_config_frame, soc.l2_sets, *sets_choices, command=main_frame.update_noc_config).grid(row=3, column=2)
    Label(cache_config_frame, text = "L2 WAYS: ").grid(row=4, column=1)
    OptionMenu(cache_config_frame, soc.l2_ways, *l2_ways_choices, command=main_frame.update_noc_config).grid(row=4, column=2)
    Label(cache_config_frame, text = "LLC SETS (per mem tile): ").grid(row=5, column=1)
    OptionMenu(cache_config_frame, soc.llc_sets, *sets_choices, command=main_frame.update_noc_config).grid(row=5, column=2)
    Label(cache_config_frame, text = "LLC WAYS: ").grid(row=6, column=1)
    OptionMenu(cache_config_frame, soc.llc_ways, *llc_ways_choices, command=main_frame.update_noc_config).grid(row=6, column=2)
    Label(cache_config_frame, text = "ACC L2 SETS: ").grid(row=7, column=1)
    OptionMenu(cache_config_frame, soc.acc_l2_sets, *sets_choices, command=main_frame.update_noc_config).grid(row=7, column=2)
    Label(cache_config_frame, text = "ACC L2 WAYS: ").grid(row=8, column=1)
    OptionMenu(cache_config_frame, soc.acc_l2_ways, *l2_ways_choices, command=main_frame.update_noc_config).grid(row=8, column=2)

class PRCFrame(Frame):

    def __init__(self, soc, top_frame, main_frame):
        self.soc = soc
        Frame.__init__(self, top_frame, width=80, borderwidth=2, relief=RIDGE)
        self.pack(side=LEFT, expand=NO, fill=Y)
        Label(self, text = "Partial-reconfiguration: ", font="TkDefaultFont 11 bold").pack(side = TOP)
    
        prc_config_frame = Frame(self)
        prc_config_frame.pack(side=TOP)

        Label(prc_config_frame, text = "Enable Partial-reconf: ", font="TkDefaultFont 9 bold").grid(row=1, column=1)
        Checkbutton(prc_config_frame, text="", variable=soc.prc, 
                onvalue = 1, offvalue = 0, command=main_frame.update_noc_config).grid(row=1, column=2)
class PeripheralFrame(Frame):

  def __init__(self, soc, top_frame, main_frame):
    self.soc = soc

    #
    # Peripherals
    #
    Frame.__init__(self, top_frame, width=50, borderwidth=2, relief=RIDGE)
    self.pack(side=LEFT, expand=NO, fill=Y)
    Label(self, text = "Peripherals ", font="TkDefaultFont 11 bold").pack(side = TOP)

    periph_config_frame = Frame(self)
    periph_config_frame.pack(side=TOP)

    # UART
    Label(periph_config_frame, text = "UART ", fg="darkgreen").grid(row=1, column=1)

    # JTAG
    if soc.TECH == "gf12":
      Label(periph_config_frame, text = "JTAG (test) :").grid(row=2, column=1)
      Checkbutton(periph_config_frame, text="", variable=soc.jtag_en,
                  onvalue = 1, offvalue = 0, command=main_frame.update_noc_config).grid(row=2, column=2)
    else:
      Label(periph_config_frame, text = "JTAG (test) ", fg="red").grid(row=2, column=1)

    # Ethernet
    # if soc.HAS_SGMII == 1:
    #   eth_text = "Ethernet (use SGMII): "
    # else:
    #   eth_text = "Ethernet (no SGMII): "
    Label(periph_config_frame, text = "Ethernet :").grid(row=3, column=1)
    Checkbutton(periph_config_frame, text="", variable=soc.eth_en,
                onvalue = 1, offvalue = 0, command=main_frame.update_noc_config).grid(row=3, column=2)

    # SVGA
    if soc.FPGA_BOARD.find("profpga") != -1:
      Label(periph_config_frame, text = "SVGA: ").grid(row=4, column=1)
      Checkbutton(periph_config_frame, text="", variable=soc.svga_en,
                  onvalue = 1, offvalue = 0, command=main_frame.update_noc_config).grid(row=4, column=2)
    else:
      Label(periph_config_frame, text = "No SVGA", fg="red").grid(row=4, column=1)

    #
    # Debug Link
    #
    ttk.Separator(self, orient="horizontal").pack(anchor="nw", fill=X, pady=10)
    Label(self, text = "Debug Link ", font="TkDefaultFont 11 bold").pack(side=TOP)

    Label(self, text = "Ethernet link (EDCL)").pack(side = TOP)

    dsu_config_frame = Frame(self)
    dsu_config_frame.pack(side=TOP, pady=5)

    Label(dsu_config_frame, text="IP address (hex): ").grid(row=2, column=1)
    self.DSU_IP = Entry(dsu_config_frame, width=10)
    self.DSU_IP.grid(row=2, column=2)
    Label(dsu_config_frame, text="IP address (dec): ").grid(row=3, column=1)
    self.DSU_IP_DEC = Label(dsu_config_frame, text=soc.IP_ADDR, fg="darkgreen").grid(row=3, column=2)
    Label(dsu_config_frame, text="MAC address (hex): ").grid(row=4, column=1)
    self.DSU_ETH = Entry(dsu_config_frame, width=13)
    self.DSU_ETH.grid(row=4, column=2)

  def update_frame(self):
    if len(self.soc.dsu_ip) == 8 and len(self.soc.dsu_eth) == 12:
      self.DSU_IP.insert(0, self.soc.dsu_ip)
      self.DSU_ETH.insert(0, self.soc.dsu_eth)

class CpuFrame(Frame):

  def set_cpu_specific_labels(self, soc):

    if soc.CPU_ARCH.get() == "ariane":
      self.fpu_label.config(text="ETH FPnew", fg="darkgreen")
    elif soc.CPU_ARCH.get() == "leon3" and soc.LEON3_HAS_FPU == "7":
      self.fpu_label.config(text="SLD FPU", fg="darkgreen")
    elif soc.CPU_ARCH.get() == "leon3" and soc.LEON3_HAS_FPU == "(1+0)":
      self.fpu_label.config(text="GRFPU", fg="darkgreen")
    else:
      self.fpu_label.config(text="None", fg="red")
    
  def __init__(self, soc, top_frame, main_frame):
    self.soc = soc
    Frame.__init__(self, top_frame, width=70, borderwidth=2, relief=RIDGE)
    self.pack(side=LEFT, expand=NO, fill=Y)
    Label(self, text = "CPU ", font="TkDefaultFont 11 bold").pack(side=TOP)

    self.cpu_frame = Frame(self)
    self.cpu_frame.pack(side=TOP, pady=5)

    cpu_choices = ["leon3", "ariane", "ibex"]

    Label(self.cpu_frame, text = "Core: ").grid(row=1, column=1)
    Pmw.OptionMenu(self.cpu_frame, menubutton_textvariable=soc.CPU_ARCH,
                   items=cpu_choices, command=main_frame.update_noc_config).grid(row=1, column=2)

    Label(self.cpu_frame, text="FPU: ").grid(row=2, column=1)
    self.fpu_label = Label(self.cpu_frame, text="None", fg="red")
    self.fpu_label.grid(row=2, column=2)
    self.set_cpu_specific_labels(soc)
    
    ttk.Separator(self, orient="horizontal").pack(anchor="nw", fill=X, pady=10)

    Label(self, text = "Shared Local Memory ", font="TkDefaultFont 11 bold").pack(side=TOP)

    slm_config_frame = Frame(self)
    slm_config_frame.pack(side=TOP, pady=5)

    slm_kbytes_choices = [64, 128, 256, 512, 1024, 2048, 4096]

    Label(slm_config_frame, text = "KB per tile: ").grid(row=1, column=1)
    OptionMenu(slm_config_frame, soc.slm_kbytes, *slm_kbytes_choices, command=main_frame.update_noc_config).grid(row=1, column=2)

    ttk.Separator(self, orient="horizontal").pack(anchor="nw", fill=X, pady=10)

    Label(self, text = "Accelerators ", font="TkDefaultFont 11 bold").pack(side = TOP, pady=5)
    Label(self, text = "Data allocation strategy:").pack(side = TOP)
    Radiobutton(self, text = "Big physical area", variable = soc.transfers, value = 0).pack(side = TOP)
    Radiobutton(self, text = "Scatter/Gather  ", variable = soc.transfers, value = 1).pack(side = TOP)

class EspCreator(Frame):

  def __init__(self, master, _soc):
    self.soc = _soc
    self.noc = self.soc.noc
    self.master = master

    # Create scroll bar
    self.y_axis_scrollbar = Scrollbar(self.master)
    self.x_axis_scrollbar = Scrollbar(self.master, orient='horizontal')

    # Create canvas with yscrollcommmand from scrollbar, use xscrollcommand for horizontal scroll
    self.main_canvas = Canvas(self.master, yscrollcommand=self.y_axis_scrollbar.set,
                              xscrollcommand=self.x_axis_scrollbar.set)

    # Configure and pack/grid scrollbar to master
    self.y_axis_scrollbar.config(command=self.main_canvas.yview)
    self.y_axis_scrollbar.pack(side=RIGHT, fill=BOTH, expand=NO)
    self.x_axis_scrollbar.config(command=self.main_canvas.xview)
    self.x_axis_scrollbar.pack(side=BOTTOM, fill=BOTH, expand=NO)

    # This is the frame all content will go to. The 'master' of the frame is the canvas
    self.ParentFrame = Frame(self.main_canvas, borderwidth=5, relief=RIDGE)
    self.ParentFrame.pack(side=TOP, expand=YES, fill=BOTH)
        
    # Place canvas on app pack/grid
    self.main_canvas.pack(side=TOP, fill=BOTH, expand=YES)

    # create_window draws the Frame on the canvas. Imagine it as another pack/grid
    self.main_canvas.create_window((0, 0), window=self.ParentFrame, anchor=E)

    #, width=self.master.winfo_screenwidth(), height=self.master.winfo_screenheight())
    
    #.:: creating the general layout
    #top frame (configuration of SoC and peripherals)
    self.top_frame = Frame(self.ParentFrame, borderwidth=5, relief=RIDGE) 
    self.top_frame.pack(side=TOP, expand=YES,  padx=10, pady=5, ipadx=5, ipady=5, fill=BOTH)    
    #bottom frame (configuration of components)
    self.bottom_frame = Frame(self.ParentFrame, borderwidth=5, relief=RIDGE)
    self.bottom_frame.pack(side=TOP, expand=YES,  padx=10, pady=5, ipadx=5, ipady=5, fill=BOTH)    
    #message frame
    self.message_frame = Frame(self.ParentFrame, borderwidth=5, relief=RIDGE)
    self.message_frame.pack(side=TOP, expand=YES,  padx=10, pady=5, ipadx=5, ipady=5, fill=BOTH)
    self.message_bar = Frame(self.message_frame)
    self.message_bar.pack(side=LEFT,fill=BOTH,expand=YES)
    self.message_buttons = Frame(self.message_frame, width=50)
    self.message_buttons.pack(side=RIGHT, expand=YES, fill=BOTH)
    #final button
    self.done = Button(self.message_buttons, text="Generate SoC config", width=25, state=DISABLED, command=self.generate_files)
    self.done.pack(side=RIGHT)

    #.:: creating the configuration frame (read-only)
    cfg_frame = ConfigFrame(self.soc, self.top_frame) 
    #.:: creating the CPU frame
    self.cpu_frame = CpuFrame(self.soc, self.top_frame, self)
    #.:: creating the cache frame
    self.cache_frame = CacheFrame(self.soc, self.top_frame, self)
    # PRC frame
    self.prc_frame = PRCFrame(self.soc, self.top_frame, self)
    #.:: creating the peripherals frame
    self.peripheral_frame = PeripheralFrame(self.soc, self.top_frame, self)
    self.peripheral_frame.update_frame()

    #noc frame
    self.bottom_frame_noccfg = NoCFrame(self.soc, self.bottom_frame) 
    self.bottom_frame_noccfg.noc_config_frame.pack(side=LEFT, expand=NO, fill=Y)
    self.bottom_frame_noccfg.create_noc()
    self.done.config(state=DISABLED)

    #message box
    self.message=Text(self.message_bar, width = 150, height = 7, wrap = WORD)
    self.message.pack()
    self.bottom_frame_noccfg.set_message(self.message, cfg_frame, self.cpu_frame, self.done)   

    self.bottom_frame_noccfg.update_frame()

    # Call this method after every update to the canvas
    self.update_scroll_region()

  def update_scroll_region(self):
    ''' Call after every update to content in self.main_canvas '''
    self.master.update()
    self.main_canvas.config(scrollregion=self.main_canvas.bbox('all'))

  def update_noc_config(self, *args):
    if soc.CPU_ARCH.get() == "ariane":
      self.soc.DMA_WIDTH = 64
    else:
      self.soc.DMA_WIDTH = 32
    self.soc.IPs = Components(self.soc.TECH, self.soc.DMA_WIDTH, soc.CPU_ARCH.get())
    self.soc.update_list_of_ips()
    self.soc.changed()
    self.bottom_frame_noccfg.changed()

  def generate_files(self):
    self.bottom_frame_noccfg.changed()
    self.generate_socmap()
    self.generate_mmi64_regs()
    self.generate_power()
    if os.path.isfile(".esp_config.bak") == True:
      shutil.move(".esp_config.bak", ".esp_config")

  def generate_socmap(self):
    try:
      int(self.bottom_frame_noccfg.vf_points_entry.get())
    except:
      return
    self.soc.noc.vf_points = int(self.bottom_frame_noccfg.vf_points_entry.get())
    self.soc.write_config(self.peripheral_frame.DSU_IP.get(), self.peripheral_frame.DSU_ETH.get())
    esp_config = soc_config(soc)
    create_socmap(esp_config, soc)
 
  def generate_power(self):
      create_power(soc)

  def generate_mmi64_regs(self):
      create_mmi64_regs(soc)

if len(sys.argv) != 8:
    print_usage()
    sys.exit(1)

DMA_WIDTH = int(sys.argv[1])
TECH = sys.argv[2]
LINUX_MAC = sys.argv[3]
LEON3_STACK = sys.argv[4]
FPGA_BOARD = sys.argv[5]
EMU_TECH = sys.argv[6]
EMU_FREQ = sys.argv[7]

root = Tk()
root.title("ESP SoC Generator")
soc = SoC_Config(DMA_WIDTH, TECH, LINUX_MAC, LEON3_STACK, FPGA_BOARD, EMU_TECH, EMU_FREQ, True)

root.geometry("1024x768")
w, h = root.winfo_screenwidth(), root.winfo_screenheight()
root.geometry("%dx%d+0+0" % (w, h))
app = EspCreator(root, soc)

def on_closing():
  try:
    int(app.bottom_frame_noccfg.vf_points_entry.get())
  except:
    return
  soc.noc.vf_points = int(app.bottom_frame_noccfg.vf_points_entry.get())
  if messagebox.askokcancel("Quit", "Do you want to quit?"):
    soc.write_config(app.peripheral_frame.DSU_IP.get(), app.peripheral_frame.DSU_ETH.get())
    root.destroy()

root.protocol("WM_DELETE_WINDOW", on_closing)
root.mainloop()

