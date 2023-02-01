#!/bin/bash
# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

set -e

vlog="$(strings $1) $(find . -name "*.svh")"

for v in $vlog; do
    if grep -q "translate_off" $v; then
	echo "Patching $v"
	sed -i '/translate_off/a \/\/cadence translate_off' $v
	sed -i '/translate_on/a \/\/cadence translate_on' $v
    fi
done
