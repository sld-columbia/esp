#!/usr/bin/python3

from tkinter import *
import Pmw

from soc import *

class Bus():

  def update_list(self, list_bus_added):
    self.list_accelerators = list_bus_added.get(0, END)

  def __init__(self):
    self.list_accelerators = []

#Bus configuration Frame (middle)
class BusFrame(Pmw.ScrolledFrame):

  def add_bus(self, event):
    selection = event.widget.curselection()
    value = event.widget.get(selection[0])
    self.list_bus_added.insert(END, value)
    self.soc.bus.update_list(self.list_bus_added)

  def remove_bus(self, event):
    selection = event.widget.curselection()
    event.widget.delete(selection[0])
    self.soc.bus.update_list(self.list_bus_added)

  def update_frame(self):
    for acc in self.soc.bus.list_accelerators:
      self.list_bus_added.insert(END, acc)

  def __init__(self, soc, bottom_frame):
    self.soc = soc
    Pmw.ScrolledFrame.__init__(self, bottom_frame,
           labelpos = 'n',
           label_text = 'Bus Configuration',
           label_font="TkDefaultFont 11 bold",
           usehullsize = 1,
           horizflex='expand',
           hull_width = 400,
           hull_height = 300)
    self.bottom_frame_busl = self.interior()
    #frame for available accelerators
    Label(self.bottom_frame_busl, text="Available Accelerators:", font="TkDefaultFont 9 italic").pack(side=TOP)
    self.avail = Frame(self.bottom_frame_busl)
    self.added = Frame(self.bottom_frame_busl)
    self.avail.pack()
    self.added.pack()
    self.scroll_avail = Scrollbar(self.avail, orient=VERTICAL)
    self.scroll_avail.pack(side=RIGHT, fill=Y)
    self.list_bus_avail = Listbox(self.avail,yscrollcommand=self.scroll_avail.set)
    self.list_bus_avail.config(width=75)
    self.list_bus_avail.pack(side=TOP, fill=BOTH, expand=True)
    self.scroll_avail.config(command=self.list_bus_avail.yview)
    #frame for accelerators added to the architecture
    Label(self.added, text="Accelerators added to the architecture:", font="TkDefaultFont 9 italic").pack(side=TOP)
    self.scroll_added = Scrollbar(self.added, orient=VERTICAL)
    self.scroll_added.pack(side=RIGHT, fill=Y)
    self.list_bus_added = Listbox(self.added,yscrollcommand=self.scroll_added.set)
    self.list_bus_added.config(width=75)
    self.list_bus_added.pack(side=TOP, fill=BOTH, expand=True)
    self.scroll_added.config(command=self.list_bus_added.yview)
    self.list_bus_avail.bind("<Double-Button-1>", self.add_bus)
    self.list_bus_added.bind("<Double-Button-1>", self.remove_bus)
    #initialize list
    for item in soc.IPs.ACCELERATORS:
      self.list_bus_avail.insert(END, item)

