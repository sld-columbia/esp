import sys
from pathlib import Path
from math import ceil

if len(sys.argv) < 4 or len(sys.argv) % 2 == 1:
    print(
        "usage: python3 modify_srec.py infile.srec data_file1 [data_file2] ... start_address1 [start_address2] ...")
    exit()

srec_path = sys.argv[1]
srec_file = open(srec_path, "a")


def calc_checksum(count, address, data):
    total = 0
    total += count
    for _ in range(4):
        total += address & 0xFF
        address >>= 8
    for i in range(16):
        total += int(data[i * 2:i * 2 + 2], 16)
    return total & 0xFF


for k in range(int((len(sys.argv) - 2) / 2)):
    data_path = sys.argv[k + 2]
    start_addr = int(sys.argv[2 + int((len(sys.argv) - 2) / 2) + k], 0)

    if data_path[-3:] == "txt":
        data_file = open(data_path, "r")
        lines = data_file.readlines()
        i = 0
        string = ""
        addr = start_addr

        for line in lines:
            word = line.strip()
            if word[0:2] == "0x":
                word = word[2:]

            string += word
            if i == 3:
                srec_file.write("S315")
                srec_file.write(hex(addr)[2:].upper())
                srec_file.write(string.upper())
                checksum = calc_checksum(0x15, addr, string)
                srec_file.write("{:02x}".format(checksum).upper())
                srec_file.write("\n")

                addr += 0x10
                string = ""

            i = (i + 1) % 4

        data_file.close()
    else:
        data = Path(data_path).read_bytes()
        i = 0
        addr = start_addr
        string = ""
        for k in range(ceil(len(data) / 16.0) * 4):
            if k >= len(data) / 4:
                word = "0"
            else:
                word = str(
                    hex(int.from_bytes(data[k * 4:k * 4 + 4], byteorder='big', signed=False))[2:])
            string += word.zfill(8)

            if i == 3:
                srec_file.write("S315")
                srec_file.write(hex(addr)[2:].upper())
                srec_file.write(string.upper())
                checksum = calc_checksum(0x15, addr, string)
                srec_file.write("{:02x}".format(checksum).upper())
                srec_file.write("\n")

                addr += 0x10
                string = ""

            i = (i + 1) % 4

srec_file.close()
