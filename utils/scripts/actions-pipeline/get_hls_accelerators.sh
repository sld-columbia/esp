#!/bin/bash

# Output styles
NC='\033[0m' 
BOLD='\033[1m'
EMOJI_CHECK="\xE2\x9C\x94"

# Navigate to the acc HLS directory
cd "$HOME/esp/tech/virtex7/"
directory="acc"

accelerators=()

# All sub-directories in virtex7/acc represent accelerators post-HLS
# Iterate over them
for dir in "$directory"/*/; do
    if [ -d "$dir" ]; then  # Check if the directory exists
        accelerator_name=$(basename "$dir")
        accelerators+=("$accelerator_name")
    fi
done

# Create a dictionary to map accelerator to its dma size
declare -A dma

# Iterate over available dma sizes
# Pick the greatest one
for accelerator in "${accelerators[@]}"; do
    sizes=()
    for size_dir in "$directory/$accelerator"/*/; do
        size=$(basename "$size_dir")
        sizes+=("$size")
    done
    
    sorted_sizes=($(printf "%s\n" "${sizes[@]}" | sort))
    dma["$accelerator"]="${sorted_sizes[-1]#*_*_}"
done

echo -e "${BOLD}HLS SUCCEEDED FOR...${NC}"
if [ ${#dma[@]} -eq 0 ]; then
    echo "0 accelerators"
else
    for accelerator in "${!dma[@]}"; do
        echo -e "  ${EMOJI_CHECK} [${dma[$accelerator]}] $accelerator"
    done
fi