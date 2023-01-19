#!/usr/bin/python

import string

binfile = ["soft-build/ariane/prom.bin", "soft-build/ariane/systest.bin"]
txtfile = ["soft-build/ariane/prom.txt", "soft-build/ariane/systest.txt"]
arch_bits = 32

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
        f.write(str(format(len(hexlist), 'x')).zfill(int(arch_bits / 4)) + '\n')
        for word in hexlist:
            f.write(word.zfill(int(arch_bits / 4)) + '\n')
