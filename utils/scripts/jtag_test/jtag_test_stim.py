#!/usr/bin/python3

import sys

tile = int(sys.argv[1])

addr = [ "100000", \
         "010000", \
         "001000", \
         "000100", \
         "000010", \
         "000001"]

fp = open("tiles_gen_" + str(tile) + ".lst")

# Skip table header (5 lines)
line = fp.readline()
for i in range(5):
  if not line:
    print("Error: early termination of trace file")
    sys.exit(1)
  line = fp.readline()

of = []
for i in range(0,6):
  of.append(open("stim" + str(i + 1) + ".txt", 'w'))

i =0
while line:
  # i = i + 1
  # if i == 5:
  #   break
  # print(line)

  line.strip()
  tok = line.split()
  for noc in range(0, 6):
    offset = 1 + 6 * noc

    if tok[offset + 1] == "0" and tok[offset + 2] == "0":
      # Valid input port with no stop -> Read and check operation (tile to NoC)
      of[noc].write(tok[offset] + "0\n")
    if tok[offset + 4] == "0" and tok[offset + 5] == "0":
      # Valid output port with no stop -> Write operation (NoC to tile)
      of[noc].write(tok[offset + 3] + "1\n")

  line = fp.readline()


fp.close()

for i in range(0,6):
  of[i].close()
