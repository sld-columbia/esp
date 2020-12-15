#!/bin/bash

hexdump -v -e '"%08_ax: "' -e ' 4/4 "%08x " " |"' -e '16/1 "%_p" "|\n"' $1
