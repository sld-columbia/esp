#!/usr/bin/python3

# This script taks the formatted list of pads' location (see utils/scripts/asic/reformat.sh)
# and generates a VHDL package containing constant bit vectors to be passed to the pad wrappers instances.

import os.path
import glob
import sys
import collections

filepath = 'pads_loc.txt'
pads = dict()

with open(filepath) as fp:
    line = fp.readline()
    while line:
        line.strip()
        items = line.split()
        name = items[0]
        index = int(items[1])
        loc = items[2]

        if name in pads:
            pads[name][index] = loc
        else:
            pads[name] = dict()
            pads[name][index] = loc

        line = fp.readline()

fp = open('pads_loc.vhd', 'w+')

fp.write("library ieee;\n")
fp.write("use ieee.std_logic_1164.all;\n\n")

fp.write("package pads_loc is\n\n")

for p in pads:
    if len(pads[p]) == 1:
        fp.write("  constant " + p + "_pad_loc : std_logic := '" + str(pads[p][0]) + "';\n")
    else:
        s = "  constant " + p + "_pad_loc : std_logic_vector(" + str(len(pads[p]) - 1) + " downto 0) := \""
        pd = collections.OrderedDict(sorted(pads[p].items(), reverse=True))
        for k in pd:
            s += str(pd[k])
        s += "\";"
        fp.write(s + "\n")

fp.write("\n")
fp.write("end package pads_loc;\n")
