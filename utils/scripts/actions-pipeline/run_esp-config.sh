#!/bin/bash

# Output styles
NC='\033[0m' 
BOLD='\033[1m'
EMOJI_CHECK="\xE2\x9C\x94"

# Source HLS accelerators
source "get_hls_accelerators.sh"

# Define SoC configuration source + target
defconfig="$HOME/esp/socs/defconfig/esp_xilinx-vc707-xc7vx485t_defconfig"
esp_config="$HOME/esp/socs/xilinx-vc707-xc7vx485t/socgen/esp/.esp_config"

# FPGA run
fpga_run="$HOME/esp/utils/scripts/actions-pipeline/./run_fpga_program.sh"

for accelerator in "${!dma[@]}"; do
    accelerator_upper=$(echo "$accelerator" | tr '[:lower:]' '[:upper:]')

	# Logging
	logs="$HOME/esp/utils/scripts/actions-pipeline/logs/"
	esp_config="$logs/config/$accelerator.log"
	fpga_program="$logs/program/$accelerator.log"
	vivado_syn="$logs/hls/$accelerator.log"
	minicom="$logs/run/minicom_$accelerator.log"
	run="$logs/run/run_$accelerator.log"

	# Swap in the appropriate accelerator
    cp "$defconfig" "$esp_config"
    sed -i "s/CONFIG_DSU_IP = C0A80107/CONGIG_DSU_IP = C0A8011C/" "$esp_config"
    sed -i "s/CONFIG_DSU_ETH = A6A7A0F8043D/CONGIG_DSU_ETH = A6A7A0F80445/" "$esp_config"
    sed -i "s/TILE_1_0 = 2 empty empty 0 0 0/TILE_1_0 = 2 acc $accelerator_upper 0 0 0 ${dma[$accelerator]} 0 sld/" "$esp_config"
    sed -i "s/POWER_1_0 = empty 0 0 0 0 0 0 0 0 0 0 0 0/POWER_1_0 = $accelerator_upper 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0/" "$esp_config"
	
	# Clean the vivado directories and bistream shortcut
	echo ""
	echo -e "${BOLD}CLEANING VIVADO DIRECTORIES...${NC}"
	cd "$HOME/esp/socs/xilinx-vc707-xc7vx485t"
	rm top.bit
	rm -rf vivado
	make clean >/dev/null 2>&1
	echo ""

	# Make esp config
	echo ""
	echo -e "${BOLD}CREATING SoC CONFIG W/ ACCELERATOR...${NC}"
	echo -e "  ${EMOJI_CHECK} $accelerator"
	make esp-config > "$esp_config" 2>&1

	# Run SoC HLS and generate bitstream 
	echo ""
	echo -e "${BOLD}STARTING SoC HLS W/ ACCELERATOR...${NC}"
	echo -e "  ${EMOJI_CHECK} $accelerator"
	make vivado-syn > "$vivado_syn" 2>&1

	# Run FPGA-program if bitstream gen suceeds
	if [ -s "top.bit" ]; then
		make fpga-program > "$fpga_program" 2>&1
		if grep -q ERROR "$fpga_program"; then
			echo ""
        	echo -e "${BOLD}FPGA-PROGRAM FAILED...${NC}"
			echo -e "  - $accelerator"
			echo ""
		else
			echo ""
			echo -e "${BOLD}FPGA-PROGRAM SUCCEEDED...${NC}"
			echo -e "  ${EMOJI_CHECK} $accelerator"
			echo ""
		fi

		# Open Minicom in the foreground
		echo -e "${BOLD}OPENING MINICOM...${NC}"
		echo ""
		socat pty,link=ttyV0,waitslave,mode=777 tcp:goliah.cs.columbia.edu:4332 &
		socat_pid=$!
		sleep 2
		VIRTUAL_DEVICE=$(readlink ttyV0)

		# Run fpga program in the background
		echo -e "${BOLD}WRITING RESULTS TO MINICOM...${NC}"
		echo ""
		$fpga_run > "$run" 2>&1 &
		minicom -p "$VIRTUAL_DEVICE" -C "$minicom" 2>&1
		kill -9 "$socat_pid"
	else
		echo -e "${BOLD}BITSTREAM GENERATION FAILED...${NC}"
		echo -e "  - $accelerator"
	fi
done