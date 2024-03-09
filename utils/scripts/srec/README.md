# modify\_srec.py
This Python utility was created to preload simulation data in the main memory
model of an SoC. This removes the need to initialize potentially large
quantities of data from software in slow RTL simulations of full SoCs.
Ordinarily, the main memory model is initialized with the cross-compiled binary
of the target C application from the file `soft-build/<cpu>/ram.srec`. This utility
is automatically invoked when one of the simulation make targets are called with
the additional environment variables `SIM_DATA_FILES` and `START_ADDRS` specified,
as shown below.
```SIM_DATA_FILES="data_file1.bin data_file2.text" START_ADDRS="0xA0100000 0xA0200000" make sim```


The utility takes as arguments 1) the target SREC file to be modified, 2) the
data files that should be loaded in the memory model, and 3) the desired start
address for each data file.
```python3 modify_srec.py infile.srec data_file1 [data_file2] ... start_address1 [start_address2] ...```

## Data File Formats
The data files can take two formats: 1) a binary file or 2) a text file with one
32-bit hex word per line, as shown below.
```
0x11111111
0x22222222
0x33333333
...
```
For correct operation, the data files must be prepared with endianness that
matches that of the system, i.e. little-endian for Ariane and Ibex or
big-endian for Leon3.

## Start Addresses
The start addresses must be chosen to be in the main memory space, i.e.
`0x80000000`-`0xBFFFFFFF` for Ariane and Ibex or `0x40000000` - `0x7FFFFFFF`
for Leon3.  There are a few important factors to keep in mind. First, the
target C program's executable will be placed at the start of the main memory
space, so data files should be placed after the end of the program. It is also
important to note that the simulation memory model is by default 2MB large. This
means that some of the MSBs of the address are not used. If the addresses are
not chosen carefully, the additional data could overwrite the existing C
program and break the program's execution. Setting bits in the address that are
beyond the program's size, but not in the MSBs (as shown in the `START_ADDRS`
above), is a good way to handle this.
