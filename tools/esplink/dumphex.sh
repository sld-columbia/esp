#!/bin/bash
# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

hexdump -v -e '"%08_ax: "' -e ' 4/4 "%08x " " |"' -e '16/1 "%_p" "|\n"' $1
