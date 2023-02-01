#!/bin/bash
# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

set -e

noyes () {
    while true; do
	read -p "$1 [y|n]? n: " yn
	yn=${yn:-n}
	case $yn in
            [Yy]* ) echo "y"; break;;
            [Nn]* ) echo "n"; break;;
            * ) ;;
	esac
    done
}

echo "*** WARNING  : This script will reset the Git repository at path ${PWD} and all its submodules ***"
echo "*** WARNING  : All changes not committed will be lost and this action cannot be undone!        ***"
if [ $(noyes "*** QUESTION : Do you REALLY wish to continue") == "n" ]; then
    exit
fi

git reset --hard
git submodule foreach --recursive git reset --hard
git submodule update --init --recursive
