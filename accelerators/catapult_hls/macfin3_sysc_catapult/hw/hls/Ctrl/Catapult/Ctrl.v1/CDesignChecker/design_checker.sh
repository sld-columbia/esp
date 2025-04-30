#!/bin/sh -f

SOLUTION_DIR='..'

if test -z $MGC_HOME; then
   echo "Error: MGC_HOME environment variable setting not found."
   exit -1
fi

if test -z $SLEC_CPC_HOME; then
   echo "Error: SLEC_CPC_HOME environment variable setting not found."
   exit -1
fi

$SLEC_CPC_HOME/bin/cat2slec -workdir $SOLUTION_DIR -cpc $@
