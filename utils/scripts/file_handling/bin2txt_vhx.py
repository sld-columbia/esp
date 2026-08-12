#!/usr/bin/python

#This script converts the executable binary into a vhx file format and appends 0's to fill the 2MB memory. 
import sys
import os

if len(sys.argv) != 3:
    print("usage: python3 bin2txt.py <cpu_arch_data_width> <source_binary_file>")
    sys.exit(1)

cpu_arch_data_width = int(sys.argv[1])
cpu_type = sys.argv[2]

binfile_path = os.path.join("soft-build", cpu_type, "systest.bin")
txtfile_path = os.path.join("soft-build", cpu_type, "ram.vhx")

# --- Calculations for 2MB memory ---
MEMORY_SIZE_BYTES = 2 * 1024 * 1024 # 2 MB
BYTES_PER_WORD = cpu_arch_data_width // 8
HEX_CHARS_PER_WORD = cpu_arch_data_width // 4

if BYTES_PER_WORD == 0:
    print(f"Error: cpu_arch_data_width ({cpu_arch_data_width}) is too small for byte-aligned words.")
    sys.exit(1)

TOTAL_WORDS_IN_MEMORY = MEMORY_SIZE_BYTES // BYTES_PER_WORD

hexlist = []

print(f"Read binary file {binfile_path}")
try:
    with open(binfile_path, "rb") as f:
        while True:
            chunk = f.read(BYTES_PER_WORD)
            if not chunk: # End of file
                break
            # Pad chunk with zeros if it's shorter than BYTES_PER_WORD (e.g., endof file)
            # This ensures we always get a full word's worth of hex
            if len(chunk) < BYTES_PER_WORD:
                chunk = chunk.ljust(BYTES_PER_WORD, b'\x00')
            hexword = chunk.hex()
            hexlist.append(hexword)
except FileNotFoundError:
    print(f"Error: Binary file not found at {binfile_path}")
    sys.exit(1)

print(f"Write text file {txtfile_path}")
with open(txtfile_path, "w") as f:
    words_written = 0
    for word in hexlist:
        # Write each word, zero-filled to the correct hex character width, followed by a newline
        f.write(word.zfill(HEX_CHARS_PER_WORD) + '\n')
        words_written += 1

    # Pad with zeros if the binary file is smaller than the total memory size
    zero_word_hex = '0' * HEX_CHARS_PER_WORD
    zero_words_needed = TOTAL_WORDS_IN_MEMORY - words_written

    if zero_words_needed < 0:
        print(f"Warning: Binary file content ({words_written} words) exceeds target memory size.")
        # No padding needed if the binary already fills or overfills the memory
    else:
        #pad zeros
        for _ in range(zero_words_needed):
            f.write(zero_word_hex + '\n')

print(f"VHX file generated.")
