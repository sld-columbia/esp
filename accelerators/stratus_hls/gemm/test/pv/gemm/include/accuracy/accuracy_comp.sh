#!/bin/bash

declare -a IMAGES=("bird" "frog" "cat" "airplane" "automobile"
    "deer" "dog" "horse" "ship" "truck")

LAYER=$(cat team.tcl | grep "TARGET_LAYER" | cut -d "_" -f 4 | cut -d "\"" -f 1)

echo -n "LAYER IS $LAYER"

let accuracy=0

rm -rf accuracy_comp.log

make clean

for i in `seq 0 9`; do

    img=${IMAGES[$i]}
    class=${IMAGES[$i]}

    echo "Processing the image of a ${img}"

    dst=${PWD}
    src=../hls/syn/

    cd $src
    make sim_BEHAV_${1}_TARGET_LAYER_${LAYER}_${img} > $dst/accuracy_comp.log
    cd $dst

    grep " tb_system: #1:" accuracy_comp.log | grep -i -q $class
    r=$?
    if [ $r -eq 0 ]; then
	echo "Correct classification"
	let accuracy=accuracy+10
    else
	echo "Wrong classification"
    fi

done

echo "The layer ${LAYER} accuracy is ${accuracy}%."
if [ ${accuracy} -ge 50 ] ; then
    echo "Accuracy test PASSED"
else
    echo "Accuracy test FAILED"
fi

echo "The layer ${LAYER} accuracy is ${accuracy}%." > accuracy_comp_res.log
if [ ${accuracy} -ge 50 ] ; then
    echo "Layer accuracy test PASSED" >> accuracy_comp_res.log
else
    echo "Layer accuracy test FAILED" >> accuracy_comp_res.log
fi 

