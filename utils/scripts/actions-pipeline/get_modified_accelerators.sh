#!/bin/bash

# Output styles
NC='\033[0m' 
BOLD='\033[1m'
EMOJI_CHECK="\xE2\x9C\x94"

# Configuration:
# Defines what accelerators to consider changes for.
ACCELERATORS="accelerators.json"
if [ ! -f "$ACCELERATORS" ]; then
    echo -e "${RED}Error:${NC} $ACCELERATORS file not found."
    exit 1
fi

# Get all the files that were modified compared to master branch.
modified_files=$(git diff master --name-only)

modified_accelerators=()

# Loop through each modified file
# Check whether it's an accelerator we should consider
# If it is, add it as a "modified accelerator"
for file in $modified_files; do
    while read -r accelerator; do
        path=$(jq -r '.path' <<< "$accelerator")
        if [[ "$file" == "$path"* ]]; then
            accelerator_name=$(jq -r '.name' <<< "$accelerator")
            if [[ ! " ${modified_accelerators[@]} " =~ " $accelerator_name " ]]; then
                modified_accelerators+=("$accelerator_name")
            fi
        fi
    done < <(jq -c '.accelerators[]' "$ACCELERATORS")
done

echo -e "${BOLD}MODIFIED ACCELERATORS:${NC}"
for acc in "${modified_accelerators[@]}"; do
    echo -e "  ${EMOJI_CHECK} $acc"
done