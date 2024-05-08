#!/usr/bin/env python3

# Copyright (c) 2011-2024 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

from tkinter import *
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


def isInt(s):
    try:
        int(s)
        return True
    except ValueError:
        return False


class Characterization():
    ip = ""
    vf_points = []


class VFPoint():
    voltage = 0
    frequency = 0
    energy = 0


class Tile():

    def update_tile(self, soc):
        selection = self.ip_type.get()
        self.label.config(text=selection)
        self.point_label.forget()
        self.point_select.forget()
        self.ip_list.forget()
        self.ip_list.setitems(soc.list_of_ips)
        self.ip_list.pack(side=LEFT)
        if soc.IPs.PROCESSORS.count(selection):
            self.label.config(bg="#ef6865")
        elif soc.IPs.MISC.count(selection):
            self.label.config(bg="#fdfda0")
        elif soc.IPs.MEM.count(selection):
            self.label.config(bg="#6ab0d4")
        elif soc.IPs.SLM.count(selection):
            self.label.config(bg="#c9a6e4")
        elif soc.IPs.ACCELERATORS.count(selection):
            self.label.config(bg="#78cbbb")
            self.point_label.pack(side=LEFT)
            self.vendor = soc.IPs.VENDOR[selection]
            dma_width = str(soc.noc.dma_noc_width.get())
            display_points = [
                point for point in soc.IPs.POINTS[selection] if "dma" +
                str(dma_width) in point]
            self.point_select.setitems(display_points)
            point = self.point.get()
            self.point_select.setvalue("")
            for p in display_points:
                if point == p:
                    self.point_select.setvalue(point)
                    break
                else:
                    self.point_select.setvalue(str(display_points[0]))
            self.point_select.pack(side=LEFT)
        else:
            self.label.config(bg='white')
            if self.ip_type.get() != "empty":
                self.ip_type.set("empty")
        self.clk_reg_selection.config(to=soc.noc.get_clk_regions_max())

        try:
            if soc.IPs.PROCESSORS.count(
                    selection) or soc.IPs.ACCELERATORS.count(selection):
                self.clk_reg_selection.config(state='readonly')
                if self.clk_region.get() != 0:
                    self.pll_selection.config(state=NORMAL)
                else:
                    self.pll_selection.config(state=DISABLED)
                    if self.has_pll.get() == 1:
                        self.has_pll.set(0)
                if self.has_pll.get() == 1:
                    self.clkbuf_selection.config(state=NORMAL)
                else:
                    self.clkbuf_selection.config(state=DISABLED)
                    if self.has_clkbuf.get() == 1:
                        self.has_clkbuf.set(0)
            else:
                self.clk_reg_selection.config(state=DISABLED)
                self.pll_selection.config(state=DISABLED)
                self.clkbuf_selection.config(state=DISABLED)
                if self.clk_region.get() > 0:
                    self.clk_region.set(0)
                if self.has_pll.get() == 1:
                    self.has_pll.set(0)
                if self.has_clkbuf.get() == 1:
                    self.has_clkbuf.set(0)
            if soc.IPs.ACCELERATORS.count(selection) and soc.cache_en.get(
            ) == 1 and soc.noc.noc_width.get() == soc.ARCH_BITS:
                self.has_l2_selection.config(state=NORMAL)
            else:
                if soc.IPs.PROCESSORS.count(
                        selection) and soc.cache_en.get() == 1:
                    self.has_l2.set(1)
                else:
                    self.has_l2.set(0)
                self.has_l2_selection.config(state=DISABLED)
            # if soc.IPs.SLM.count(selection) and soc.TECH == "gf12":
            if soc.IPs.SLM.count(selection) and soc.TECH == "asic":
                self.has_ddr_selection.config(state=NORMAL)
            else:
                # DDR SLM tile only supported w/ GF12 technology
                self.has_ddr.set(0)
                self.has_ddr_selection.config(state=DISABLED)
        except BaseException:
            pass

        self.load_characterization(soc, soc.noc.vf_points)

    def get_clk_region(self):
        return self.clk_region.get()

    def center(self, toplevel):
        toplevel.update_idletasks()
        w = toplevel.winfo_screenwidth()
        h = toplevel.winfo_screenheight()
        size = tuple(int(_)
                     for _ in toplevel.geometry().split('+')[0].split('x'))
        x = w / 2 - size[0] / 2 + 100
        y = h / 2 - size[1] / 2
        toplevel.geometry("%dx%d+%d+%d" % (size + (x, y)))

    def create_characterization(self, soc, num_points):
        self.energy_values = Characterization()
        self.energy_values.ip = self.ip_type.get()
        self.energy_values.vf_points = [VFPoint() for x in range(num_points)]

    def load_characterization(self, soc, num_points):
        ESP_ROOT = os.path.realpath(
            os.path.dirname(
                os.path.realpath(__file__)) +
            "/../../")
        selection = self.ip_type.get()
        if self.energy_values is None or len(
                self.energy_values.vf_points) == 0:
            self.create_characterization(soc, num_points)
        if self.energy_values.ip != selection and soc.IPs.ACCELERATORS.count(
                selection):
            e = xml.etree.ElementTree.parse(
                ESP_ROOT + "/tools/socgen/power.xml").getroot()
            self.energy_values.ip = selection
            for atype in e.findall('accelerator'):
                if atype.get('name') == self.ip_type.get():
                    xml_vf_points = atype.findall('vf_point')
                    end_point = num_points
                    if len(xml_vf_points) < end_point:
                        end_point = len(xml_vf_points)
                    for x in range(end_point):
                        self.energy_values.vf_points[x].voltage = float(
                            xml_vf_points[x].get('voltage'))
                        self.energy_values.vf_points[x].frequency = float(
                            xml_vf_points[x].get('frequency'))
                        self.energy_values.vf_points[x].energy = float(
                            xml_vf_points[x].get('energy'))
                else:
                    end_point = num_points
                    for x in range(end_point):
                        self.energy_values.vf_points[x].voltage = 0.0
                        self.energy_values.vf_points[x].frequency = 0.0
                        self.energy_values.vf_points[x].energy = 0.0
        else:
            new_vf_points = [VFPoint() for x in range(num_points)]
            end_point = num_points
            if len(self.energy_values.vf_points) < end_point:
                end_point = len(self.energy_values.vf_points)
            for x in range(end_point):
                new_vf_points[x] = self.energy_values.vf_points[x]
            self.energy_values.vf_points = new_vf_points

    def power_window(self, event, soc, nocframe):
        selection = self.ip_type.get()
        if soc.IPs.ACCELERATORS.count(
                selection) == 0 or self.clk_region.get() == 0:
            return
        try:
            int(nocframe.vf_points_entry.get())
        except BaseException:
            return
        self.toplevel = Toplevel()
        label1 = Label(
            self.toplevel,
            text="Power Information for \"" +
            selection +
            "\"",
            height=0,
            width=50,
            font="TkDefaultFont 11 bold")
        label1.pack()
        entry = [Frame(self.toplevel)
                 for x in range(int(nocframe.vf_points_entry.get()))]
        for x in range(len(entry)):
            entry[x].pack(side=LEFT)
            Label(
                entry[x],
                text="Voltage (" + str(x) + ") (V)",
                height=0,
                width=20).pack(
                side=TOP)
            entry[x].e1 = Entry(entry[x], width=10)
            entry[x].e1.pack(side=TOP)
            Label(
                entry[x],
                text="Frequency (" + str(x) + ") (MHz)",
                height=0,
                width=20).pack(
                side=TOP)
            entry[x].e2 = Entry(entry[x], width=10)
            entry[x].e2.pack(side=TOP)
            Label(
                entry[x],
                text="Tot Energy (" + str(x) + ") (pJ)",
                height=0,
                width=20).pack(
                side=TOP)
            entry[x].e3 = Entry(entry[x], width=10)
            entry[x].e3.pack(side=TOP)
            entry[x].e1.delete(0, END)
            entry[x].e2.delete(0, END)
            entry[x].e3.delete(0, END)
            entry[x].e1.insert(0, str(self.energy_values.vf_points[x].voltage))
            entry[x].e2.insert(
                0, str(
                    self.energy_values.vf_points[x].frequency))
            entry[x].e3.insert(0, str(self.energy_values.vf_points[x].energy))
            Label(entry[x], height=1).pack(side=TOP)
        self.toplevel.entry = entry
        self.center(self.toplevel)
        self.toplevel.protocol(
            "WM_DELETE_WINDOW",
            functools.partial(
                self.on_closing,
                toplevel=self.toplevel))

    def on_closing(self, toplevel):
        if messagebox.askyesno("Save",
                               "Do you want to save the modifications?"):
            for x in range(len(self.energy_values.vf_points)):
                self.energy_values.vf_points[x].voltage = float(
                    toplevel.entry[x].e1.get())
                self.energy_values.vf_points[x].frequency = float(
                    toplevel.entry[x].e2.get())
                self.energy_values.vf_points[x].energy = float(
                    toplevel.entry[x].e3.get())
        toplevel.destroy()

    def __init__(self, top, x, y):
        self.row = x
        self.col = y
        self.ip_type = StringVar()
        self.point = StringVar()
        self.vendor = ""
        self.clk_region = IntVar()
        self.has_l2 = IntVar()
        self.has_ddr = IntVar()
        self.has_pll = IntVar()
        self.has_clkbuf = IntVar()
        self.clk_reg_active = StringVar()
        self.label = Label(top)
        self.energy_values = None


class NoC():

    rows = 0
    cols = 0
    top = ""

    vf_points = 4

    topology = []

    def create_topology(self, top, _R, _C):
        self.top = top
        new_topology = []
        for y in range(_R):
            new_topology.append([])
            for x in range(_C):
                new_topology[y].append(Tile(top, y, x))
                if x < self.cols and y < self.rows:
                    new_topology[y][x].ip_type.set(
                        self.topology[y][x].ip_type.get())
                    new_topology[y][x].has_l2.set(
                        self.topology[y][x].has_l2.get())
                    new_topology[y][x].has_ddr.set(
                        self.topology[y][x].has_ddr.get())
                    new_topology[y][x].clk_region.set(
                        self.topology[y][x].clk_region.get())
                    new_topology[y][x].has_pll.set(
                        self.topology[y][x].has_pll.get())
                    new_topology[y][x].has_clkbuf.set(
                        self.topology[y][x].has_clkbuf.get())
                    new_topology[y][x].point.set(
                        self.topology[y][x].point.get())
                    new_topology[y][x].vendor = self.topology[y][x].vendor
                    new_topology[y][x].energy_values = self.topology[y][x].energy_values
        self.topology = new_topology
        self.rows = _R
        self.cols = _C

    def get_clk_regions(self):
        regions = []
        for y in range(0, self.rows):
            for x in range(0, self.cols):
                tile = self.topology[y][x]
                if tile.clk_region is not None and regions.count(
                        tile.clk_region.get()) == 0:
                    regions.append(tile.clk_region.get())
        return regions

    def get_clk_regions_max(self):
        region_max = 0
        max_count = 0
        for y in range(0, self.rows):
            for x in range(0, self.cols):
                tile = self.topology[y][x]
                if tile.clk_region is not None and tile.clk_region.get() > region_max:
                    region_max = tile.clk_region.get()
        for y in range(0, self.rows):
            for x in range(0, self.cols):
                tile = self.topology[y][x]
                if tile.clk_region is not None and tile.clk_region.get() == region_max:
                    max_count = max_count + 1
        if max_count > 1:
            region_max = region_max + 1
        return region_max

    def get_clkbuf_num(self, soc):
        tot_clkbuf = 0
        for y in range(0, self.rows):
            for x in range(0, self.cols):
                tile = self.topology[y][x]
                selection = tile.ip_type.get()
                if soc.IPs.ACCELERATORS.count(
                        selection) and tile.has_clkbuf.get() == 1:
                    tot_clkbuf += 1
        return tot_clkbuf

    def has_dvfs(self):
        regions = []
        for y in range(0, self.rows):
            for x in range(0, self.cols):
                tile = self.topology[y][x]
                if tile.clk_region is not None and tile.clk_region.get() != 0:
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
                    if tile.point_select.getvalue() == "" and (
                            not tile.ip_type.get().lower() in THIRDPARTY_COMPATIBLE):
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

    # WARNING: Geometry in this class only uses x=rows, y=cols, but socmap
    # uses y=row, x=cols!
    def __init__(self):
        self.cols = 0
        self.rows = 0
        self.coh_noc_width = IntVar()
        self.dma_noc_width = IntVar()
        self.monitor_ddr = IntVar()
        self.monitor_mem = IntVar()
        self.monitor_inj = IntVar()
        self.monitor_routers = IntVar()
        self.monitor_accelerators = IntVar()
        self.monitor_l2 = IntVar()
        self.monitor_llc = IntVar()
        self.monitor_dvfs = IntVar()

# NoC configuration frame (middle)


class NoCFrame(Pmw.ScrolledFrame):

    current_nocx = 0
    current_nocy = 0

    noc_tiles = []
    row_frames = []

    def changed(self, *args):
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
        # computing the width of the widget
        list_items = self.soc.list_of_ips
        width = 0
        for x in range(0, len(list_items)):
            if len(list_items[x]) > width:
                width = len(list_items[x])
        # creating tile
        select_frame = Frame(frame)
        select_frame.pack(side=TOP)

        display_frame = Frame(frame)
        display_frame.pack(side=TOP)

        config_frame = Frame(frame)
        config_frame.pack(side=TOP)

        tile.ip_list = Pmw.OptionMenu(
            select_frame,
            menubutton_font="TkDefaultFont 8",
            menubutton_textvariable=tile.ip_type,
            menubutton_width=width + 2,
            items=list_items)
        tile.ip_list.pack(side=LEFT)
        tile.point_label = Label(select_frame, text="Impl.: ", width=5)
        tile.point_select = Pmw.OptionMenu(
            select_frame,
            menubutton_font="TkDefaultFont 8",
            menubutton_textvariable=tile.point,
            menubutton_width=10,
            items=[])

        tile.label = Label(display_frame, text=tile.ip_type.get())
        tile.label.config(height=4, bg='white', width=width + 25)
        tile.label.pack()

        tile.has_l2_selection = Checkbutton(
            config_frame,
            text="Has cache",
            variable=tile.has_l2,
            onvalue=1,
            offvalue=0,
            command=self.changed)
        tile.has_l2_selection.grid(row=1, column=1)
        tile.has_ddr_selection = Checkbutton(
            config_frame,
            text="Has DDR",
            variable=tile.has_ddr,
            onvalue=1,
            offvalue=0,
            command=self.changed)
        tile.has_ddr_selection.grid(row=1, column=4)
        Separator(
            config_frame,
            orient="horizontal").grid(
            row=2,
            column=1,
            columnspan=4,
            ipadx=140,
            pady=3)

        tile.label.bind(
            "<Double-Button-1>",
            lambda event: tile.power_window(
                event,
                self.soc,
                self))
        Label(
            config_frame,
            text="Clk Reg: ",
            justify=LEFT,
            anchor="w").grid(
            sticky=W,
            row=3,
            column=1)
        tile.clk_reg_selection = Spinbox(
            config_frame,
            state='readonly',
            from_=0,
            to=len(
                self.soc.noc.get_clk_regions()),
            wrap=True,
            textvariable=tile.clk_region,
            width=3,
            justify=RIGHT)
        tile.clk_reg_selection.grid(sticky=E, row=3, column=1)
        tile.pll_selection = Checkbutton(
            config_frame,
            text="Has PLL",
            variable=tile.has_pll,
            onvalue=1,
            offvalue=0,
            command=self.changed)
        tile.pll_selection.grid(row=3, column=2)
        tile.clkbuf_selection = Checkbutton(
            config_frame,
            text="CLK BUF",
            variable=tile.has_clkbuf,
            onvalue=1,
            offvalue=0,
            command=self.changed)
        tile.clkbuf_selection.grid(row=3, column=3)
        try:
            int(self.vf_points_entry.get())
            tile.load_characterization(
                self.soc, int(self.vf_points_entry.get()))
        except BaseException:
            pass

    def __init__(self, soc, bottom_frame):
        self.soc = soc
        self.noc = self.soc.noc
        # configuration frame
        self.noc_config_frame = Frame(bottom_frame)
        Label(
            self.noc_config_frame,
            text="NoC configuration",
            font="TkDefaultFont 11 bold").pack(
            side=TOP)
        self.config_noc_frame = Frame(self.noc_config_frame)
        self.config_noc_frame.pack(side=TOP)
        Label(self.config_noc_frame, text="Rows: ").pack(side=LEFT)
        self.ROWS = Entry(self.config_noc_frame, width=3)
        self.ROWS.pack(side=LEFT)
        Label(self.config_noc_frame, text="Cols: ").pack(side=LEFT)
        self.COLS = Entry(self.config_noc_frame, width=3)
        self.COLS.pack(side=LEFT)

        noc_width_choices = ["32", "64", "128", "256", "512", "1024"]
        Label(
            self.noc_config_frame,
            text="Coherence NoC Planes (1,2,3) Bitwidth: ",
            height=1).pack()
        OptionMenu(
            self.noc_config_frame,
            self.noc.coh_noc_width,
            *noc_width_choices).pack()
        Label(
            self.noc_config_frame,
            text="DMA NoC Planes (4,6) Bitwidth: ",
            height=1).pack()
        OptionMenu(
            self.noc_config_frame,
            self.noc.dma_noc_width,
            *noc_width_choices).pack()
        Label(
            self.noc_config_frame,
            text="MMIO/Irq NoC Plane (5) Bitwidth is always 32",
            height=1).pack(
            side=TOP)
        Button(
            self.noc_config_frame,
            text="Config",
            command=self.create_noc).pack(
            side=TOP)

        Label(self.noc_config_frame, height=1).pack()
        Checkbutton(
            self.noc_config_frame,
            text="Monitor DDR bandwidth",
            variable=self.noc.monitor_ddr,
            anchor=W,
            width=20).pack()
        Checkbutton(
            self.noc_config_frame,
            text="Monitor memory access",
            variable=self.noc.monitor_mem,
            anchor=W,
            width=20).pack()
        Checkbutton(
            self.noc_config_frame,
            text="Monitor injection rate",
            variable=self.noc.monitor_inj,
            anchor=W,
            width=20).pack()
        Checkbutton(
            self.noc_config_frame,
            text="Monitor router ports",
            variable=self.noc.monitor_routers,
            anchor=W,
            width=20).pack()
        self.monitor_acc_selection = Checkbutton(
            self.noc_config_frame,
            text="Monitor accelerator status",
            variable=self.noc.monitor_accelerators,
            anchor=W,
            width=20)
        self.monitor_acc_selection.pack()
        Checkbutton(
            self.noc_config_frame,
            text="Monitor L2 Hit/Miss",
            variable=self.noc.monitor_l2,
            anchor=W,
            width=20).pack()
        Checkbutton(
            self.noc_config_frame,
            text="Monitor LLC Hit/Miss",
            variable=self.noc.monitor_llc,
            anchor=W,
            width=20).pack()
        self.monitor_dvfs_selection = Checkbutton(
            self.noc_config_frame,
            text="Monitor DVFS",
            variable=self.noc.monitor_dvfs,
            width=20,
            anchor=W)
        self.monitor_dvfs_selection.pack()

        # statistics
        Label(self.noc_config_frame, height=1).pack()
        self.TOT_CPU = Label(self.noc_config_frame, anchor=W, width=20)
        self.TOT_MEM = Label(self.noc_config_frame, anchor=W, width=25)
        self.TOT_SLM = Label(self.noc_config_frame, anchor=W, width=25)
        self.TOT_SLMDDR = Label(self.noc_config_frame, anchor=W, width=25)
        self.TOT_MISC = Label(self.noc_config_frame, anchor=W, width=20)
        self.TOT_ACC = Label(self.noc_config_frame, anchor=W, width=20)
        self.TOT_IVR = Label(self.noc_config_frame, anchor=W, width=20)
        self.TOT_CLKBUF = Label(self.noc_config_frame, anchor=W, width=20)
        self.TOT_CPU.pack(side=TOP, fill=BOTH)
        self.TOT_MEM.pack(side=TOP, fill=BOTH)
        self.TOT_SLM.pack(side=TOP, fill=BOTH)
        self.TOT_SLMDDR.pack(side=TOP, fill=BOTH)
        self.TOT_MISC.pack(side=TOP, fill=BOTH)
        self.TOT_ACC.pack(side=TOP, fill=BOTH)
        Label(self.noc_config_frame, height=1).pack()
        self.TOT_IVR.pack(side=TOP, fill=BOTH)
        Label(self.noc_config_frame, height=1).pack()
        self.TOT_CLKBUF.pack(side=TOP, fill=BOTH)

        Label(self.noc_config_frame, height=1).pack()

        self.vf_frame = Frame(self.noc_config_frame)
        self.vf_frame.pack(side=TOP, fill=BOTH)
        Label(
            self.vf_frame,
            anchor=W,
            width=10,
            text=" VF points: ").pack(
            side=LEFT)
        self.vf_points_entry = Entry(self.vf_frame, width=3)
        self.vf_points_entry.pack(side=LEFT)
        self.vf_points_entry.delete(0, END)
        self.vf_points_entry.insert(0, "4")

        # frame for the tiles
        Pmw.ScrolledFrame.__init__(self, bottom_frame,
                                   labelpos='n',
                                   label_text='NoC Tile Configuration',
                                   label_font="TkDefaultFont 11 bold",
                                   usehullsize=1,
                                   horizflex='expand',
                                   hull_width=1180,
                                   hull_height=520,)
        self.noc_frame = self.interior()

    def update_msg(self):
        self.done.config(state=DISABLED)
        tot_tiles = self.noc.rows * self.noc.cols
        tot_cpu = self.noc.get_cpu_num(self.soc)
        if self.soc.cache_en.get():
            tot_full_coherent = self.noc.get_acc_l2_num(
                self.soc) + self.noc.get_cpu_num(self.soc)
            tot_llc_coherent = self.noc.get_acc_num(self.soc)
        else:
            tot_full_coherent = 0
            tot_llc_coherent = 0
        tot_io = 0
        tot_clkbuf = self.noc.get_clkbuf_num(self.soc)
        tot_mem = self.noc.get_mem_num(self.soc)
        tot_slm = self.noc.get_slm_num(self.soc)
        tot_slm_size = tot_slm * self.soc.slm_kbytes.get()
        tot_slmddr = self.noc.get_slmddr_num(self.soc)
        tot_acc = self.noc.get_acc_num(self.soc)
        regions = self.noc.get_clk_regions()
        acc_impl_valid = self.noc.get_acc_impl_valid(self.soc)
        for y in range(0, self.noc.rows):
            for x in range(0, self.noc.cols):
                tile = self.noc.topology[y][x]
                selection = tile.ip_type.get()
                if self.soc.IPs.MISC.count(selection):
                    tot_io += 1
        # update statistics
        self.TOT_CPU.config(text=" Num CPUs: " + str(tot_cpu))
        self.TOT_MEM.config(text=" Num memory controllers: " + str(tot_mem))
        self.TOT_SLM.config(
            text=" Num local memory tiles using on-chip memory: " +
            str(tot_slm))
        self.TOT_SLMDDR.config(
            text=" Num local memory tiles using off-chip DDR memory: " +
            str(tot_slmddr))
        self.TOT_MISC.config(text=" Num I/O tiles: " + str(tot_io))
        self.TOT_ACC.config(text=" Num accelerators: " + str(tot_acc))
        self.TOT_IVR.config(text=" Num CLK regions: " + str(len(regions)))
        self.TOT_CLKBUF.config(text=" Num CLKBUF: " + str(tot_clkbuf))
        clkbuf_ok = True
        if tot_clkbuf <= 9:
            self.TOT_CLKBUF.config(fg="black")
        else:
            clkbuf_ok = False
            self.TOT_CLKBUF.config(fg="red")

        if self.soc.noc.get_acc_num(self.soc) > 0:
            self.monitor_acc_selection.config(state=NORMAL)
        else:
            self.monitor_acc_selection.config(state=DISABLED)
            self.noc.monitor_accelerators.set(0)

        if self.soc.noc.has_dvfs():
            self.monitor_dvfs_selection.config(state=NORMAL)
            self.vf_points_entry.config(state=NORMAL)
        else:
            self.monitor_dvfs_selection.config(state=DISABLED)
            self.vf_points_entry.config(state=DISABLED)
            self.noc.monitor_dvfs.set(0)

        pll_string = ""
        num_pll = [0 for x in range(self.noc.cols * self.noc.rows)]
        num_components = [0 for x in range(self.noc.cols * self.noc.rows)]
        for y in range(0, self.noc.rows):
            for x in range(0, self.noc.cols):
                tile = self.noc.topology[y][x]
                selection = tile.ip_type.get()
                if self.soc.IPs.EMPTY.count(selection) == 0:
                    num_components[tile.clk_region.get()] += 1
                if tile.has_pll.get() == 1:
                    num_pll[tile.clk_region.get()] += 1
        pll_ok = True
        for x in range(len(regions)):
            if num_pll[x] == 0 and x > 0 and num_components[x] > 0:
                pll_ok = False
                pll_string += "Region \"" + \
                    str(x) + "\" requires at least one PLL\n"
            if num_pll[x] > 1 and x > 0:
                pll_ok = False
                pll_string += "Region \"" + \
                    str(x) + "\" cannot have more than one PLL\n"

        clk_region_skip = 0
        regions = self.noc.get_clk_regions()
        regions = sorted(regions, key=int)
        current_region = regions[0]
        for r in regions:
            if r > current_region + 1:
                clk_region_skip = current_region + 1
                break
            current_region = r

        # update message box
        self.message.delete(0.0, END)
        self.cpu_frame.set_cpu_specific_labels(self.soc)

        string = ""
        if (tot_cpu > 0) and \
           (tot_cpu <= NCPU_MAX) and \
           (tot_mem > 0 or (tot_slm > 0 and (self.soc.cache_en.get() == 0) and self.soc.CPU_ARCH.get() == "ibex")) and \
           (tot_mem <= self.soc.nmem_max) and \
           (tot_mem != 3) and \
           (tot_slm <= NSLM_MAX) and \
           (tot_slm <= 1 or self.soc.slm_kbytes.get() >= 1024) and \
           (tot_acc <= NACC_MAX) and \
           (tot_io == 1) and \
           (pll_ok) and \
           (clkbuf_ok) and \
           (clk_region_skip == 0) and \
           (tot_tiles <= NTILE_MAX) and \
           (self.noc.cols <= 8 and self.noc.rows <= 8) and \
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
           ((self.soc.TECH != "asic" and self.soc.TECH != "inferred" and self.soc.ESP_EMU_TECH == "none")
                or tot_mem == 0 or self.soc.cache_en.get() == 1):
            # Spandex beta warning
            if self.soc.cache_spandex.get() != 0 and self.soc.cache_en.get() == 1:
                string += "***              Spandex support is still beta                 ***\n"
                string += "    The default HLS configuration is 512x4 L2 and 1024x8 LLC\n"
                # if self.soc.TECH != "gf12" and self.soc.TECH != "virtexu" and
                # self.soc.TECH != "virtexup":
                if self.soc.TECH != "asic" and self.soc.TECH != "virtexu" and self.soc.TECH != "virtexup":
                    string += "    Use a smaller implementation if not using a Virtex US/US+\n"
            self.done.config(state=NORMAL)
        else:
            if (self.noc.cols > 8 or self.noc.rows > 8):
                string += "Maximum number of rows and columns is 8.\n"
            if (tot_cpu == 0):
                string += "At least one CPU is required.\n"
            if (tot_cpu > 1 and not self.soc.cache_en.get()):
                string += "Caches are required for multicore SoCs.\n"
            if (tot_io == 0):
                string += "At least I/O tile is required.\n"
            if (tot_cpu > NCPU_MAX):
                new_err = "Maximum number of supported CPUs is " + \
                    str(NCPU_MAX) + ".\n"
                string += new_err
            if (tot_io > 1):
                string += "Multiple I/O tiles are not supported.\n"
            if (tot_mem < 1 and tot_slm < 1):
                string += "There must be at least 1 memory tile or 1 SLM tile.\n"
            if (tot_mem > self.soc.nmem_max):
                string += "There must be no more than " + \
                    str(self.soc.nmem_max) + " memory tiles.\n"
            if (tot_mem == 0 and (self.soc.CPU_ARCH.get() != "ibex")):
                string += "SLM tiles can be used in place of memory tiles only with the lowRISC ibex core.\n"
            if (tot_mem == 0 and (self.soc.cache_en.get() == 1)):
                string += "There must be at least 1 memory tile to enable the ESP cache hierarchy.\n"
            if (tot_mem == 3):
                string += "Number of memory tiles must be a power of 2.\n"
            if (tot_slm > NSLM_MAX):
                string += "There must be no more than " + \
                    str(NSLM_MAX) + " SLM tiles.\n"
            if (tot_slm > 1 and self.soc.slm_kbytes.get() < 1024):
                string += "SLM size must be 1024 KB or more if placing more than one SLM tile.\n"
            if (self.soc.llc_sets.get() >=
                    8192 and self.soc.llc_ways.get() >= 16 and tot_mem == 1):
                string += "A 2MB LLC (8192 sets and 16 ways) requires multiple memory tiles.\n"
            if (self.soc.TECH == "virtexu" and tot_mem >=
                    2 and (self.noc.rows < 3 or self.noc.cols < 3)):
                string += "A 3x3 NoC or larger is recommended for multiple memory tiles for virtexu (profpga-xcvu440).\n"
            if (tot_acc > NACC_MAX):
                string += "There must no more than " + \
                    str(NACC_MAX) + " (can be relaxed).\n"
            if (tot_tiles > NTILE_MAX):
                string += "Maximum number of supported tiles is " + \
                    str(NTILE_MAX) + ".\n"
            if (tot_full_coherent > NFULL_COHERENT_MAX):
                string += "Maximum number of supported fully-coherent devices is " + \
                    str(NFULL_COHERENT_MAX) + ".\n"
            if (tot_llc_coherent > NLLC_COHERENT_MAX):
                string += "Maximum number of supported LLC-coherent devices is " + \
                    str(NLLC_COHERENT_MAX) + ".\n"
            if (self.soc.cache_spandex.get() != 0 and self.soc.CPU_ARCH.get()
                    != "ariane" and self.soc.cache_en.get() == 1):
                string += "Spandex currently supports only RISC-V Ariane processor core.\n"
            if (tot_clkbuf > 9):
                string += "The FPGA board supports no more than 9 CLKBUF's.\n"
            string += pll_string
            if (clk_region_skip > 0):
                string += "Clock-region IDs must be consecutive; skipping region " + \
                    str(clk_region_skip) + " intead.\n"
            if (self.soc.cache_en.get() == 1 and self.soc.cache_line_size.get()
                    < self.noc.coh_noc_width.get()):
                string += "Cache line size must be greater than or equal to coherence NoC bitwidth.\n"
            if (self.soc.cache_en.get() == 1 and self.soc.cache_line_size.get()
                    < self.noc.dma_noc_width.get()):
                string += "Cache line size must be greater than or equal to DMA NoC bitwidth.\n"
            if (self.soc.TECH == "asic" and self.soc.cache_line_size.get()
                    < self.soc.mem_link_width.get()):
                string += "Cache line size must be greater than or equal to mem link bitwidth.\n"
            if (self.soc.TECH == "asic" and self.noc.coh_noc_width.get()
                    < self.soc.mem_link_width.get()):
                string += "Coherence NoC bitwdith must be greater than or equal to mem link bitwidth.\n"
            if (self.soc.TECH == "asic" and self.noc.dma_noc_width.get()
                    < self.soc.mem_link_width.get()):
                string += "DMA NoC bitwdith must be greater than or equal to mem link bitwidth.\n"
            if (self.soc.cache_en.get() != 1) and (
                    self.noc.coh_noc_width.get() > self.soc.ARCH_BITS):
                string += "Caches must be enabled to support a coherence NoC width larger than the CPU architecture size.\n"
            if (self.noc.coh_noc_width.get() < self.soc.ARCH_BITS):
                string += "Coherence NoC width must be greater than or equal to the CPU architecture size.\n"
            if (self.noc.dma_noc_width.get() < self.soc.ARCH_BITS):
                string += "DMA NoC width must be greater than or equal to the CPU architecture size.\n"
            if (not acc_impl_valid):
                string += "All accelerators must have a selected implementation.\n"
            if (self.soc.cache_line_size.get() > 128 and (
                    self.soc.cache_spandex.get() == 1 or self.soc.cache_rtl.get() == 0)):
                string += "Only ESP RTL caches support cache line size greater than 128 bits.\n"
            if (self.soc.jtag_en.get() == 1 and (
                    self.noc.dma_noc_width.get() != 64 or self.noc.coh_noc_width.get() != 64)):
                string += "JTAG is only supported for 64-bit coherence and DMA NoC planes.\n"
            if ((self.soc.TECH == "asic" or self.soc.TECH == "inferred" or self.soc.ESP_EMU_TECH !=
                    "none") and tot_mem >= 1 and self.soc.cache_en.get() == 0):
                string += "Caches must be enabled for ASIC design with memory tiles.\n"

        # Update message box
        self.message.insert(0.0, string)

    def set_message(self, message, cfg_frame, cpu_frame, done):
        self.message = message
        self.cfg_frame = cfg_frame
        self.cpu_frame = cpu_frame
        self.done = done

    def create_noc(self):
        self.pack(side=LEFT, fill=BOTH, expand=YES)
        if isInt(self.ROWS.get()) == False or isInt(self.COLS.get()) == False:
            return
        # destroy current topology
        if len(self.row_frames) > 0:
            for x in range(0, len(self.row_frames)):
                self.row_frames[x].destroy()
            self.noc_tiles = []
            self.row_frames = []
        # create new topology
        self.noc.create_topology(
            self.noc_frame, int(
                self.ROWS.get()), int(
                self.COLS.get()))
        for y in range(0, int(self.ROWS.get())):
            self.row_frames.append(
                Frame(
                    self.noc_frame,
                    borderwidth=2,
                    relief=RIDGE))
            self.row_frames[y].pack(side=TOP)
            self.noc_tiles.append([])
            for x in range(0, int(self.COLS.get())):
                self.noc_tiles[y].append(
                    Frame(
                        self.row_frames[y],
                        borderwidth=2,
                        relief=RIDGE))
                self.noc_tiles[y][x].pack(side=LEFT)
                Label(
                    self.noc_tiles[y][x],
                    text="(" + str(y) + "," + str(x) + ")").pack()
                self.create_tile(self.noc_tiles[y][x], self.noc.topology[y][x])
                if len(self.noc.topology[y][x].ip_type.get()) == 0:
                    self.noc.topology[y][x].ip_type.set(
                        "empty")  # default value
        # set call-backs and default value
        for y in range(0, int(self.ROWS.get())):
            for x in range(0, int(self.COLS.get())):
                tile = self.noc.topology[y][x]
                tile.ip_type.trace('w', self.changed)
                tile.clk_region.trace('w', self.changed)
        self.soc.IPs = Components(
            self.soc.TECH,
            self.noc.dma_noc_width.get(),
            self.soc.CPU_ARCH.get())
        self.soc.update_list_of_ips()
        self.changed()
