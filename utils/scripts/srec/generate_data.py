def generate_hex_file(filename):
    with open(filename, 'w') as file:
        for i in range(32768):  # 0 to 32767
            file.write("0x00000000\n")
            file.write(f"0x{i:08X}\n")

# Usage
generate_hex_file("hex_data.txt")

print("File 'hex_data.txt' has been generated successfully.")
