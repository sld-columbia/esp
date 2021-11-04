#!/usr/bin/python

import string

binfile = ["soft-build/ibex/prom.bin", "soft-build/ibex/systest.bin", "soft-build/ibex/baremetal/ad03_cxx_catapult.bin"]
txtfile = ["soft-build/ibex/prom.txt", "soft-build/ibex/systest.txt", "soft-build/ibex/baremetal/ad03_cxx_catapult.txt"]

for i in range(len(binfile)):

    hexlist = []

    print("Read binary file " + binfile[i])
    with open(binfile[i], "rb") as f:
        hexword = f.read(4).hex()
        while hexword:
            hexlist.append(hexword)
            hexword = f.read(4).hex()
        
    print("Write text file " + txtfile[i])
    with open(txtfile[i], "w") as f:
        f.write(str(format(len(hexlist), 'x').zfill(8)) + '\n')
        for word in hexlist:
            f.write(word.zfill(8) + '\n')
