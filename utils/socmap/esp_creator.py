#!/usr/bin/env python3

# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: MIT

###############################################################################
#
# Graphic User Interface for ESP SoC-map
#
###############################################################################

from tkinter import *
from tkinter import messagebox
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
  print("Usage                    : ./esp_creator.py <dma_width> <tech>")
  print("")
  print("")
  print("      <dma_width>        : Bit-width for the DMA channel (currently supporting 32 bits only)")
  print("      <tech>             : Target technology (e.g. virtex7, virtexup, ...)")
  print("")

#Configuration Frame (top-left)
class ConfigFrame(Frame):

  def __init__(self, soc, top_frame):

    Frame.__init__(self, top_frame, width=75, borderwidth=2, relief=RIDGE) 
    self.pack(side=LEFT, expand=NO, fill=Y)
    Label(self, text="General SoC configuration:", font="TkDefaultFont 11 bold").pack(side=TOP)
    self.tech_label = Label(self, text=soc.TECH, fg="darkgreen")
    self.tech_label.pack(side=TOP)
    self.fpu_label = Label(self, text="No FPU",fg="red")
    self.fpu_label.pack(side=TOP)      
    self.jtag_label = Label(self, text="No JTAG",fg="red")
    self.jtag_label.pack(side=TOP)      
    self.eth_label = Label(self, text="No Ethernet",fg="red")
    self.eth_label.pack(side=TOP)
    if soc.CPU_ARCH.get() == "ariane":
       self.fpu_label.config(text="ETH FPnew",fg="darkgreen")
    elif soc.HAS_FPU == "7":
       self.fpu_label.config(text="SLD FPU",fg="darkgreen")
    elif soc.HAS_FPU == "(1+0)":
       self.fpu_label.config(text="GRFPU",fg="darkgreen")
    if soc.HAS_JTAG == 1:
       self.jtag_label.config(text="JTAG support",fg="darkgreen")
    if soc.HAS_ETH == 1:
       self.eth_label.config(text="Eth (" + soc.IP_ADDR + ")",fg="darkgreen")
       if soc.HAS_SGMII == 1:    
         Label(self, text="Use SGMII",fg="darkgreen").pack(side=TOP)
       else:
         Label(self, text="No SGMII",fg="red").pack(side=TOP)
    self.svga_label = Label(self, text="No SVGA",fg="red")
    self.svga_label.pack(side=TOP)      
    if soc.HAS_SVGA == True:
       self.svga_label.config(text="SVGA+FB",fg="darkgreen")
    self.sync_label = Label(self, text="With synchronizers", fg="darkgreen")
    self.sync_label.pack(side=TOP)    

class OptionFrame(Frame):

  def __init__(self, soc, top_frame):
    self.soc = soc
    Frame.__init__(self, top_frame, width=50, borderwidth=2, relief=RIDGE) 
    self.pack(side=LEFT, expand=NO, fill=Y)      
    Label(self, text = "Data transfers: ", font="TkDefaultFont 11 bold").pack(side = TOP)
    Radiobutton(self, text = "Bigphysical area", variable = soc.transfers, value = 0).pack(side = TOP)
    Radiobutton(self, text = "Scatter/Gather  ", variable = soc.transfers, value = 1).pack(side = TOP)


class CacheFrame(Frame):

  def __init__(self, soc, top_frame):
    self.soc = soc
    Frame.__init__(self, top_frame, width=50, borderwidth=2, relief=RIDGE)
    self.pack(side=LEFT, expand=NO, fill=Y)
    Label(self, text = "Cache Configuration: ", font="TkDefaultFont 11 bold").pack(side = TOP)

    cache_config_frame = Frame(self)
    cache_config_frame.pack(side=TOP)

    sets_choices = [32, 64, 128, 256, 512, 1024, 2048, 4096]
    ways_choices = [2, 4, 8, 16, 32]

    Label(cache_config_frame, text = "Cache En.: ", font="TkDefaultFont 9 bold").grid(row=1, column=1)
    Checkbutton(cache_config_frame, text="", variable=soc.cache_en).grid(row=1, column=2)
    Label(cache_config_frame, text = "L2 SETS: ").grid(row=2, column=1)
    OptionMenu(cache_config_frame, soc.l2_sets, *sets_choices).grid(row=2, column=2)
    Label(cache_config_frame, text = "L2 WAYS: ").grid(row=3, column=1)
    OptionMenu(cache_config_frame, soc.l2_ways, *ways_choices).grid(row=3, column=2)
    Label(cache_config_frame, text = "LLC SETS: ").grid(row=4, column=1)
    OptionMenu(cache_config_frame, soc.llc_sets, *sets_choices).grid(row=4, column=2)
    Label(cache_config_frame, text = "LLC WAYS: ").grid(row=5, column=1)
    OptionMenu(cache_config_frame, soc.llc_ways, *ways_choices).grid(row=5, column=2)
    Label(cache_config_frame, text = "ACC L2 SETS: ").grid(row=6, column=1)
    OptionMenu(cache_config_frame, soc.acc_l2_sets, *sets_choices).grid(row=6, column=2)
    Label(cache_config_frame, text = "ACC L2 WAYS: ").grid(row=7, column=1)
    OptionMenu(cache_config_frame, soc.acc_l2_ways, *ways_choices).grid(row=7, column=2)

class CpuFrame(Frame):

  def __init__(self, soc, top_frame):
    self.soc = soc
    Frame.__init__(self, top_frame, width=50, borderwidth=2, relief=RIDGE)
    self.pack(side=LEFT, expand=NO, fill=Y)
    Label(self, text = "CPU Architecture: ", font="TkDefaultFont 11 bold").pack(side = TOP)

    general_config_frame = Frame(self)
    general_config_frame.pack(side=TOP)

    cpu_choices = ["leon3", "ariane"]

    Label(general_config_frame, text = "Core: ").grid(row=1, column=1)
    OptionMenu(general_config_frame, soc.CPU_ARCH, *cpu_choices).grid(row=1, column=2)


class EspCreator(Frame):

  def __init__(self, master, _soc):
    self.soc = _soc
    self.soc.noc = NoC()
    self.noc = self.soc.noc
    self.ParentFrame = master

    # Read configuration file
    self.soc.read_config(True)

    #.:: creating the general layout
    #top frame (configuration of SoC and peripherals)
    self.top_frame = Frame(self.ParentFrame, borderwidth=5, relief=RIDGE) 
    self.top_frame.pack(side=TOP, expand=NO,  padx=10, pady=5, ipadx=5, ipady=5, fill=BOTH)    
    #bottom frame (configuration of components)
    self.bottom_frame = Frame(self.ParentFrame, borderwidth=5, relief=RIDGE)
    self.bottom_frame.pack(side=TOP, expand=YES,  padx=10, pady=5, ipadx=5, ipady=5, fill=BOTH)    
    #message frame
    self.message_frame = Frame(self.ParentFrame, borderwidth=5, relief=RIDGE)
    self.message_frame.pack(side=TOP, expand=NO,  padx=10, pady=5, ipadx=5, ipady=5, fill=BOTH)
    self.message_bar = Frame(self.message_frame)
    self.message_bar.pack(side=LEFT,fill=BOTH,expand=YES)
    self.message_buttons = Frame(self.message_frame, width=50)
    self.message_buttons.pack(side=RIGHT, expand=NO, fill=X)
    #final button
    self.done = Button(self.message_buttons, text="Generate SoC config", width=15, state=DISABLED, command=self.generate_files)
    self.done.pack()

    #.:: creating the configuration frame (read-only)
    cfg_frame = ConfigFrame(self.soc, self.top_frame) 
    #.:: creating the selection frame
    self.select_frame = OptionFrame(self.soc, self.top_frame)
    #.:: creating the cache frame
    self.cache_frame = CacheFrame(self.soc, self.top_frame)
    #.:: creating the CPU frame
    self.cpu_frame = CpuFrame(self.soc, self.top_frame)

    #noc frame
    self.bottom_frame_noccfg = NoCFrame(self.soc, self.bottom_frame) 
    self.bottom_frame_noccfg.noc_config_frame.pack(side=LEFT, expand=NO, fill=Y)
    self.bottom_frame_noccfg.create_noc()
    self.done.config(state=DISABLED)

    #message box
    self.message=Text(self.message_bar, width = 75, height = 7, wrap = WORD)
    self.message.pack()
    self.bottom_frame_noccfg.set_message(self.message, cfg_frame, self.done)   

    self.bottom_frame_noccfg.update_frame()

  def generate_files(self):
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
    self.soc.write_config()
    esp_config = soc_config(soc)
    create_socmap(esp_config, soc)
 
  def generate_power(self):
      create_power(soc)

  def generate_mmi64_regs(self):
      create_mmi64_regs(soc)

if len(sys.argv) != 3:
    print_usage()
    sys.exit(1)

DMA_WIDTH = int(sys.argv[1])
TECH = sys.argv[2]

root = Tk()
root.title("ESP SoC Generator")
soc = SoC_Config(DMA_WIDTH, TECH)

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
    soc.write_config()
    root.destroy()

root.protocol("WM_DELETE_WINDOW", on_closing)
root.mainloop()

