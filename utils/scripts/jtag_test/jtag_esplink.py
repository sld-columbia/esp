#!/usr/bin/python3
# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

import sys
import os
import time

if len(sys.argv) == 1:
    f = "modelsim/jtag/stim.txt"
else:
    f = sys.argv[1]

fp = open(f)

line = fp.readline()

flag=1
i=0
err=0
ex=0
op=1

of=open("test_mismatches.txt",'w')
i=0
while line:

  line.strip()

  i=i+1
  #convert to binary to split into 3 wr requests
  end_length = (len(line)-1) * 4

  hex_as_int = int(line, 16)
  hex_as_binary = bin(hex_as_int)
  flit = hex_as_binary[2:].zfill(end_length)

  if flit[-4:]=='0001':
    source="100000"
    plane=1
    addr1="0xC0010000"
    addr2="0xC0010004"
    addr3="0xC0010008"
    addrr1="0xC0010100"
    addrr2="0xC0010104"
    addrr3="0xC0010108"

  elif flit[-4:]=='0010':
    source="010000"
    plane=2
    addr1="0xC0010010"
    addr2="0xC0010014"
    addr3="0xC0010018"
    addrr1="0xC0010110"
    addrr2="0xC0010114"
    addrr3="0xC0010118"

  elif flit[-4:]=='0011':
    source="001000"
    plane=3
    addr1="0xC0010020"
    addr2="0xC0010024"
    addr3="0xC0010028"
    addrr1="0xC0010120"
    addrr2="0xC0010124"
    addrr3="0xC0010128"

  elif flit[-4:]=='0100':
    source="000100"
    plane=4
    addr1="0xC0010030"
    addr2="0xC0010034"
    addr3="0xC0010038"
    addrr1="0xC0010130"
    addrr2="0xC0010134"
    addrr3="0xC0010138"

  elif flit[-4:]=='0101':
    source="000010"
    plane=5
    addr1="0xC0010040"
    addr2="0xC0010044"
    addr3="0xC0010048"
    addrr1="0xC0010140"
    addrr2="0xC0010144"
    addrr3="0xC0010148"

  elif flit[-4:]=='0110':
    source="000001"
    plane=6
    addr1="0xC0010050"
    addr2="0xC0010054"
    addr3="0xC0010058"
    addrr1="0xC0010150"
    addrr2="0xC0010154"
    addrr3="0xC0010158"


  zeros=""
  testin1=zeros.zfill(21)+flit[2:13]
  testin2=flit[13:45]
  testin3=flit[45:68] + source + "0" + flit[71] + "1"

  expected=flit[:-8]+"0"+source

  #convert back to hexadecimal
  dec1 = int(testin1, 2)
  flit1 = hex(dec1)

  dec2 = int(testin2, 2)
  flit2 = hex(dec2)

  dec3 = int(testin3, 2)
  flit3 = hex(dec3)

  exp= hex(int(expected,2))

  # write to apb2jtag registers
  os.system('./socgen/esp/esplink-fpga-proxy --regw -a %s -d %s' % (addr1,flit1))
  os.system('./socgen/esp/esplink-fpga-proxy --regw -a %s -d %s' % (addr2,flit2))
  os.system('./socgen/esp/esplink-fpga-proxy --regw -a %s -d %s' % (addr3,flit3))

  # print('./socgen/esp/esplink-fpga-proxy --regw -a '+addr1+' -d '+flit1)
  # print('./socgen/esp/esplink-fpga-proxy --regw -a '+addr2+' -d '+flit2)
  # print('./socgen/esp/esplink-fpga-proxy --regw -a '+addr3+' -d '+flit3)

  rsp="000000000000000000000000"

  # #read from jtag2apb registers
  if (flit[71]=='0') :
    ex=ex+1

    a=os.popen('./socgen/esp/esplink-fpga-proxy --regr -a %s' %(addrr1)).read()
    print(a)
    a.strip()
    atok= a.split()
    b=os.popen('./socgen/esp/esplink-fpga-proxy --regr -a %s' %(addrr2)).read()
    b.strip()
    btok= b.split()
    print(b)
    c=os.popen('./socgen/esp/esplink-fpga-proxy --regr -a %s' %(addrr3)).read()
    c.strip()
    ctok= c.split()
    print(c)
    rsp=ctok[4]+btok[4]+atok[4]

    # if done==1:
    #   print(" Exiting at flit "+str(i))
    #   break

    exp_rsp=exp[2:].zfill(24)

    print("\n Expected response: "+exp_rsp+"\n")
    print(" Obtained response: "+rsp+"\n")
    if rsp!=exp_rsp :
      print(" *** MISMATCH ***")

    exp_rsp1=(str(hex(int(flit[:-8],2)))[2:]).zfill(17)
    rsp1=(bin(int(rsp,16))[2:]).zfill(1)
    if rsp1!="0" :
      rsp1=rsp1[:-7]

    rsp1=hex(int(rsp1,2))
    rsp1=str(rsp1)[2:].zfill(17)

    if rsp1!=exp_rsp1 :
      err = err+1
      of.write(str(i)+" :Mismatch plane:"+ str(plane)+" \n")
      of.write("Expected response: "+exp_rsp1+"\n")
      of.write("Obtained response: "+rsp1+"\n\n\n")
      print("***MISMATCH***")
      flag=0

  line = fp.readline()
  # time.sleep(1)

if flag==1:
  print("TEST PASSED !")
else:
  print("TEST FAILED with "+ str(err) +"mismatches out of "+ str(i))

fp.close()

