#!/usr/bin/python

import string
import sys

if len(sys.argv) != 2:
    print("usage: python3 bin2txt.py cpu_arch")

cpu_arch = sys.argv[1]

arch_bits = 32

binfile = [
    "soft-build/" +
    cpu_arch +
    "/prom.bin",
    "soft-build/" +
    cpu_arch +
    "/systest.bin"]
txtfile = [
    "soft-build/" +
    cpu_arch +
    "/prom.txt",
    "soft-build/" +
    cpu_arch +
    "/systest.txt"]

for i in range(len(binfile)):

    hexlist = []

    print("Read binary file " + binfile[i])
    with open(binfile[i], "rb") as f:
        hexword = f.read(int(arch_bits / 8)).hex()
        while hexword:
            hexlist.append(hexword)
            hexword = f.read(int(arch_bits / 8)).hex()

    print("Write text file " + txtfile[i])
    with open(txtfile[i], "w") as f:
        f.write(str(format(len(hexlist), 'x')).zfill(
            int(arch_bits / 4)) + '\n')
        for word in hexlist:
            f.write(word.zfill(int(arch_bits / 4)) + '\n')
