#!/usr/bin/python3
import sys

from tkinter import *
from tkinter import messagebox
from soc import *
from socmap_gen import *
from mmi64_gen import *
from power_gen import *

root = Tk()
soc = SoC_Config()
soc.noc = NoC()
x = soc.read_config(False)
if x == -1:
  print("Configuration is not available")
  sys.exit(-1)

esp_config = soc_config(soc)
create_socmap(esp_config, soc)
create_power(soc)
create_mmi64_regs(soc)

