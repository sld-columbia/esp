#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <sof>" >&2
    exit 2
fi

sof=$1

if [ ! -r "$sof" ]; then
    echo "ERROR: SOF not found: $sof" >&2
    exit 1
fi

script_dir=$(cd "$(dirname "$0")" && pwd)
reset_script="$script_dir/issp_reset.tcl"

if [ ! -r "$reset_script" ]; then
    echo "ERROR: ISSP reset script not found: $reset_script" >&2
    exit 1
fi

for tool in jtagconfig quartus_pgm system-console; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "ERROR: $tool not found in PATH" >&2
        exit 1
    fi
done

select_first_cable() {
    jtagconfig | awk '
        /^[[:space:]]*[0-9]+\)/ {
            sub(/^[[:space:]]*[0-9]+\)[[:space:]]*/, "")
            print
            exit
        }'
}

select_matching_cables() {
    local match=$1

    jtagconfig | awk -v match="$match" '
        /^[[:space:]]*[0-9]+\)/ && index($0, match) {
            sub(/^[[:space:]]*[0-9]+\)[[:space:]]*/, "")
            print
        }'
}

cable=${BOARD_CABLE:-}
cable_match=${BOARD_CABLE_MATCH:-}
device_index=${BOARD_DEVICE_INDEX:-1}

if [ -z "$cable" ] && [ -n "$cable_match" ]; then
    matching_cables=$(select_matching_cables "$cable_match")
    match_count=$(printf "%s\n" "$matching_cables" | awk 'NF { count++ } END { print count + 0 }')

    if [ "$match_count" -eq 0 ]; then
        echo "ERROR: no JTAG cable matched BOARD_CABLE_MATCH='$cable_match'" >&2
        jtagconfig >&2
        exit 1
    elif [ "$match_count" -gt 1 ]; then
        echo "ERROR: multiple JTAG cables matched BOARD_CABLE_MATCH='$cable_match'" >&2
        printf "%s\n" "$matching_cables" >&2
        exit 1
    fi

    cable=$matching_cables
fi

if [ -z "$cable" ]; then
    cable=$(select_first_cable)
fi

if [ -z "$cable" ]; then
    echo "ERROR: no JTAG cable found" >&2
    jtagconfig >&2
    exit 1
fi

echo "INFO: using JTAG cable: $cable"
export BOARD_CABLE="$cable"
export BOARD_CABLE_MATCH="$cable_match"
export BOARD_DEVICE_INDEX="$device_index"

pgm_args=(--mode=jtag)
if [ -n "$cable" ]; then
    pgm_args+=(--cable="$cable")
fi

operation="p;$sof"
if [ -n "$device_index" ]; then
    operation="${operation}@${device_index}"
fi

jtagconfig
quartus_pgm "${pgm_args[@]}" --operation="$operation"

jtag_args=()
if [ -n "$cable" ]; then
    jtag_args=(-c "$cable")
fi

jtagconfig "${jtag_args[@]}" -n
system-console --script="$reset_script"
