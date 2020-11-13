#!/bin/bash

# PADs from technology libraries may require to instantiate different cells based on their location w.r.t the chip diagonals
#
# This script reformats data copied from a spreadsheet into a list
# The input file v.txt should contain all the pin names that map to vertical I/O cells (e.g. "clk  data_i[0] data_i[1] ...")
# Similarly, the input file h.txt should contain all the pin names that map to horizontal I/O cells (e.g. "  reset  data_i[2]  data_i[3]  ...")

# When copying from a spreadsheet, spacing between signals is irregular. This script removes all extra spaces and writes only one pin per line

# Example of expected output stored into pads_loc.txt
#
# pin_name | bit | Vertical(0)/Horizontal(1)
#   clk    |  0  |   0
#  reset   |  0  |   1
#  data_i  |  0  |   0
#  data_i  |  1  |   0
#  data_i  |  2  |   1
#  data_i  |  3  |   1
#   ...
#

#  Example of cells selection based on location:
#  _____________
# |\           /|
# | \   V(0)  / |
# |  \       /  |
# |   \     /   |
# |    \   /    |
# |     \ /     |
# | H(1) \ H(1) |
# |     / \     |
# |    /   \    |
# |   /     \   |
# |  /       \  |
# | /   V(0)  \ |
# |/___________\|
#

for f in $(strings v.txt); do echo $f; done | sed 's/\([^]]\)$/\1 0 0/g' | sed 's/\(.*\)\[\([0-9]\+\)\]/\1 \2 0/g' | sort >  pads_loc.txt
for f in $(strings h.txt); do echo $f; done | sed 's/\([^]]\)$/\1 0 1/g' | sed 's/\(.*\)\[\([0-9]\+\)\]/\1 \2 1/g' | sort >> pads_loc.txt
