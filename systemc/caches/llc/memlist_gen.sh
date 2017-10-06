#!/bin/bash

echo ""
echo GENERATE memlist.txt
echo ""


### Extract information from the constants header file ###
echo "[INFO] Extract information from header files."

CACHE_LIB=../../common/lib
CACHE_CONSTS=$CACHE_LIB/cache_consts.hpp

N_CPU_LINE="$(grep "#define N_CPU " $CACHE_CONSTS)"
SET_BITS_LINE="$(grep "#define SET_BITS" $CACHE_CONSTS)"
L2_WAY_BITS_LINE="$(grep "#define L2_WAY_BITS" $CACHE_CONSTS)"
ADDR_BITS_LINE="$(grep "#define ADDR_BITS" $CACHE_CONSTS)"
BYTE_BITS_LINE="$(grep "#define BYTE_BITS" $CACHE_CONSTS)"
WORD_BITS_LINE="$(grep "#define WORD_BITS" $CACHE_CONSTS)"
STATE_BITS_LINE="$(grep "#define LLC_STATE_BITS" $CACHE_CONSTS)"

echo $N_CPU_LINE
echo $SET_BITS_LINE
echo $L2_WAY_BITS_LINE
echo $ADDR_BITS_LINE
echo $BYTE_BITS_LINE
echo $WORD_BITS_LINE
echo $STATE_BITS_LINE

N_CPU="$(cut -d' ' -f3 <<<$N_CPU_LINE)"
SET_BITS="$(cut -d' ' -f3 <<<$SET_BITS_LINE)"
L2_WAY_BITS="$(cut -d' ' -f3 <<<$L2_WAY_BITS_LINE)"
ADDR_BITS="$(cut -d' ' -f3 <<<$ADDR_BITS_LINE)"
BYTE_BITS="$(cut -d' ' -f3 <<<$BYTE_BITS_LINE)"
WORD_BITS="$(cut -d' ' -f3 <<<$WORD_BITS_LINE)"
STATE_BITS="$(cut -d' ' -f3 <<<$STATE_BITS_LINE)"

# echo $N_CPU
# echo $SET_BITS
# echo $L2_WAY_BITS
# echo $ADDR_BITS
# echo $BYTE_BITS
# echo $WORD_BITS
# echo $STATE_BITS

### Evaluate parameters ###

WAYS=$(($N_CPU*$((2**$L2_WAY_BITS))))
SETS=$((2**$SET_BITS))
LINES=$(($WAYS*$SETS))

TAG_BITS=$(($ADDR_BITS-$SET_BITS-$WORD_BITS-$BYTE_BITS))
HPROT_BITS=4
LINE_BITS=$(($ADDR_BITS*$((2**$WORD_BITS))))
SHARERS_BITS=$N_CPU

if [ "$N_CPU" = "1" ]; then
    N_CPU_BITS=1
    EVICT_WAY_BITS=$(($L2_WAY_BITS))    
elif [ "$N_CPU" = "2" ]; then
    N_CPU_BITS=1
    EVICT_WAY_BITS=$(($L2_WAY_BITS+$N_CPU_BITS))
else
    N_CPU_BITS=1 # N_CPU max is 4
    EVICT_WAY_BITS=$(($L2_WAY_BITS+$N_CPU_BITS))
fi

OWNER_BITS=$N_CPU_BITS

### Write output file ### 

echo ""
echo "[INFO] Write to memlist.txt."

rm -rf ../memlist.txt
touch ../memlist.txt

echo "llc_tags $LINES $TAG_BITS 1w:0r 0w:${WAYS}r" > ../memlist.txt
echo "llc_states $LINES $STATE_BITS 1w:0r 0w:${WAYS}r" >> ../memlist.txt
echo "llc_hprots $LINES $HPROT_BITS 1w:0r 0w:${WAYS}r" >> ../memlist.txt
echo "llc_lines $LINES $LINE_BITS 1w:0r 0w:${WAYS}r" >> ../memlist.txt
echo "llc_sharers $LINES $SHARERS_BITS 1w:0r 0w:${WAYS}r" >> ../memlist.txt
echo "llc_owners $LINES $OWNER_BITS 1w:0r 0w:${WAYS}r" >> ../memlist.txt
echo "llc_evict_ways $SETS $EVICT_WAY_BITS 1w:0r 0w:1r" >> ../memlist.txt

echo "llc_tags $LINES $TAG_BITS 1w:0r 0w:${WAYS}r"
echo "llc_states $LINES $STATE_BITS 1w:0r 0w:${WAYS}r"
echo "llc_hprots $LINES $HPROT_BITS 1w:0r 0w:${WAYS}r"
echo "llc_lines $LINES $LINE_BITS 1w:0r 0w:${WAYS}r"
echo "llc_sharers $LINES $SHARERS_BITS 1w:0r 0w:${WAYS}r"
echo "llc_owners $LINES $OWNER_BITS 1w:0r 0w:${WAYS}r"
echo "llc_evict_ways $SETS $EVICT_WAY_BITS 1w:0r 0w:1r"

