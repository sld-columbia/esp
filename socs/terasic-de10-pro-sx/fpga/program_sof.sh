#!/usr/bin/env bash
# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

usage() {
    echo "Usage: $0 <sof>" >&2
}

die() {
    echo "ERROR: $*" >&2
    exit 1
}

require_tool() {
    command -v "$1" >/dev/null 2>&1 || die "$1 not found in PATH"
}

if [ "$#" -ne 1 ]; then
    usage
    exit 2
fi

sof=$1
[ -r "$sof" ] || die "SOF not found: $sof"

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
reset_script=${QUARTUS_ISSP_RESET_SCRIPT:-"$script_dir/issp_reset.tcl"}
[ -r "$reset_script" ] || die "ISSP reset script not found: $reset_script"

require_tool jtagconfig
require_tool quartus_pgm
require_tool system-console

list_cables() {
    jtagconfig | awk '
        /^[[:space:]]*[0-9]+\)/ {
            sub(/^[[:space:]]*[0-9]+\)[[:space:]]*/, "")
            print
        }'
}

select_cable() {
    local exact=${BOARD_CABLE:-}
    local match=${BOARD_CABLE_MATCH:-}

    if [ -n "$exact" ]; then
        printf '%s\n' "$exact"
        return
    fi

    if [ -n "$match" ]; then
        local matches
        local count

        matches=$(list_cables | awk -v match="$match" 'index($0, match)')
        count=$(printf '%s\n' "$matches" | awk 'NF { count++ } END { print count + 0 }')

        case "$count" in
            0)
                echo "Available JTAG cables:" >&2
                jtagconfig >&2
                die "no JTAG cable matched BOARD_CABLE_MATCH='$match'"
                ;;
            1)
                printf '%s\n' "$matches"
                return
                ;;
            *)
                echo "Matching JTAG cables:" >&2
                printf '%s\n' "$matches" >&2
                die "multiple JTAG cables matched BOARD_CABLE_MATCH='$match'"
                ;;
        esac
    fi

    list_cables | awk 'NF { print; exit }'
}

cable=$(select_cable)
[ -n "$cable" ] || {
    echo "Available JTAG cables:" >&2
    jtagconfig >&2
    die "no JTAG cable found"
}

device_index=${BOARD_DEVICE_INDEX:-1}
operation="p;$sof"
if [ -n "$device_index" ]; then
    operation="${operation}@${device_index}"
fi

echo "INFO: using JTAG cable: $cable"
jtagconfig
quartus_pgm --mode=jtag --cable="$cable" --operation="$operation"

jtagconfig -c "$cable" -n
BOARD_CABLE="$cable" \
BOARD_DEVICE_INDEX="$device_index" \
INTEL_ISSP_SERVICE_MATCH="${INTEL_ISSP_SERVICE_MATCH:-}" \
system-console --script="$reset_script"
