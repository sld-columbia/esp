#!/usr/bin/env python3
# coding=utf-8

#with open('../../data/lena-480x640.txt', 'r') as fileA:
with open('../../data/lena-120x160.txt', 'r') as fileA:
    lines = fileA.readlines()

fileA.close()

i = 0
for l in lines:
    # print("line: {count}: {l}")
    print("mem[%d]" % (i), end='')
    print(" = %s" % (l.rstrip('\n')), end='')
    print(";")
    i += 1

print("")

#with open('gold-480x640.txt', 'r') as fileG:
with open('gold-120x160.txt', 'r') as fileG:
    lines = fileG.readlines()

fileG.close()

i = 0
for l in lines:
    # print("line: {count}: {l}")
    print("gold[%d]" % (i), end='')
    print(" = %s" % (l.rstrip('\n')), end='')
    print(";")
    i += 1

