#!/bin/bash
# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

INPUTS='../tb/inputs/in'
OUTPUTS='../tb/outputs/chk'
EXT='.data'

IN='../tb/inputs/in.data'
CHK='../tb/outputs/chk.data'

cd hls-work-virtex7

rm -rf test.log

for name in '2' '_d2' '_t2'; do

    source=$INPUTS
    source+=$name
    source+=$EXT

    check=$OUTPUTS
    check+=$name
    check+=$EXT

    echo "Input: $source. Output: $check"
    echo "\n\nTEST. Input: $source. Output: $check\n\n" >> test.log

    cp $source $IN
    cp $check $CHK

    make sim_BEHAV_DMA32 >> test.log
    make sim_BASIC_DMA32_V >> test.log
done

cd ..
