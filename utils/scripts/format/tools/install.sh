#!/bin/bash

#Install bats for testing
sudo apt-get install bats

# Install vsg
echo "Installing vhdl-style-guide (vsg)..."
pip3 install vsg --user
sudo mv "$HOME"/.local/bin/vsg /usr/local/bin/vsg
echo "vsg installed."

# Install clang-format-10
echo ""
echo "Installing clang-format-10 for C/C++ formatting..."
sudo apt-get update
sudo apt-get install -y clang-format-10
echo "clang-format-10 installed."

# Install autopep8
echo ""
echo "Installing autopep8 for Python formatting..."
pip3 install autopep8 --user
echo "autopep8 installed."

# Install verible
echo ""
echo "Installing Verible for Verilog/SystemVerilog formatting..."
wget https://github.com/chipsalliance/verible/releases/download/v0.0-3545-ge4028f19/verible-v0.0-3545-ge4028f19-linux-static-x86_64.tar.gz
tar -xvf verible-v0.0-3545-ge4028f19-linux-static-x86_64.tar.gz
rm verible-v0.0-3545-ge4028f19-linux-static-x86_64.tar.gz
sudo mv verible-v0.0-3545-ge4028f19/bin/* /usr/local/bin/
rm -r verible-v0.0-3545-ge4028f19
echo "Verible installed and configured."

echo ""
echo "All formatter tools installed successfully!"