#!/bin/bash

INPUTS='../tb/inputs/in'
OUTPUTS='../tb/outputs/chk'
EXT='.data'

IN='../tb/inputs/in.data'
CHK='../tb/outputs/chk.data'

cd hls-work-virtex7

rm -rf test.log

for name in '1' '2' '3' '4' '_d1' '_d2' '_d3' '_d4' '_t1' '_t2' '_t3' '_t4'; do

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
