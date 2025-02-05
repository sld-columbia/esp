#!/bin/bash

# Output styles
NC='\033[0m' 
BOLD='\033[1m'
EMOJI_CHECK="\xE2\x9C\x94"

# Discover all child processes and their descendants
list_descendants() {
  local children=$(ps -o pid= --ppid "$1")
  for pid in $children; do
    list_descendants "$pid"
  done
  echo "$children"
}

# Kill all child process and their descendants
cleanup() {
  echo ""
  echo ""
  echo -e "${BOLD}TERMINATING...${NC}"
  echo -e "  ${EMOJI_CHECK} Killing child processes"
  local descendants=$(list_descendants $$)
  for pid in $descendants; do
    if kill -0 "$pid" &>/dev/null; then
      kill "$pid"
    fi
  done
   echo ""
  echo -e "${BOLD}DONE.${NC}"
  exit
}

trap cleanup SIGINT

# Clean hls output directories
echo -e "${BOLD}CLEANING HLS DIRECTORIES...${NC}"
acc_dir="$HOME/esp/tech/virtex7/acc"
echo -e "${EMOJI_CHECK} Clearing tech/virtex/acc${NC}"
rm -rf "$acc_dir"
mkdir -p "$acc_dir"
echo -e "*" > "$acc_dir/.gitignore"
echo -e ".gitignore" >> "$acc_dir/.gitignore"

# Get modified accelerators
echo ""
echo -e "${BOLD}GETTING MODIFIED ACCs...${NC}"
source get_modified_accelerators.sh
echo ""

# Source the HLS tools
echo ""
echo -e "${BOLD}EXPORTING HLS TOOLS...${NC}"
source /opt/cad/scripts/tools_env.sh
echo ""

CORES=$(nproc)
child_processes=()
declare -A core_jobs
declare -A job_names
for ((i=0; i<CORES; i++)); do
    core_jobs[$i]=0
done

min_core=0
min_jobs=100
echo -e "${BOLD}HLS STARTED FOR...${NC}"
for accelerator_name in "${modified_accelerators[@]}"; do

	# Get the core with the minimum number of HLS jobs
    for ((i=0; i<CORES; i++)); do
        if (( core_jobs[$i] < min_jobs )); then
            min_core=$i
            break
        fi
    done

	# Start HLS on core with mininum number of jobs
    hls=$(jq --arg name "$accelerator_name" '.accelerators[] | select(.name == $name)' "$ACCELERATORS" | jq -r '.hls')
	echo -e "  ${EMOJI_CHECK} [CORE $min_core] $accelerator_name..."

	# Keep track of parent job and its children
    (cd ~/esp/socs/xilinx-vc707-xc7vx485t && taskset -c "$min_core" setsid make "$hls" >/dev/null 2>&1) &
    child_processes+=("$!")
    job_names[$!]="$accelerator_name" 

    ((core_jobs[$min_core]++))
    min_jobs=${core_jobs[$min_core]}
done

# Wait for each hls job to finish and update results as each process completes
echo ""
echo -e "${BOLD}WAITING FOR HLS JOBS TO FINISH...${NC}"

for pid in "${child_processes[@]}"; do
    wait "$pid"

    # Print the latest job result with accelerator name
	echo -e "  ${EMOJI_CHECK} ${job_names[$pid]}"
done