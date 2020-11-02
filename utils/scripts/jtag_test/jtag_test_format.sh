#!/bin/bash

for list in tiles_gen*.lst; do
    # Replace multiple spaces with single space
    sed -i 's/\s\+/ /g' $list
    # Remove white spaces at the beginning
    sed -i "s/^\s\+//g" $list
    # Remove trailing white spaces
    sed -i "s/\s\+$//g" $list
    # remove RTL Hex format indicators: we know how data is encoded
    sed -i "s/66'h//g" $list
    sed -i "s/34'h//g" $list
done
