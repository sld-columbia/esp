### Env setup ###
source /opt/cad/scripts/tools_env.sh
# make fft_stratus-hls

# setup in 707
ESP_ROOT=$(realpath ../../../)
cd "$ESP_ROOT/socs/xilinx-vc707-xc7vx485t"

### SoC config creation ###
# esp config
make esp-xconfig

### fft workflow ###
make linux-distclean
make linux
make examples
make linux

## Run software ##
# check make linux success
if [ -s "./soft-build/ariane/linux.bin" ]; then
    echo ""
    echo "MAKE LINUX SUCCESS"

    # open minicom session
    echo ""
    echo "TRY TO OPEN MINICOM..."
    socat pty,link=ttyV0,waitslave,mode=777 tcp:espdev.cs.columbia.edu:4322 &
    socat_pid=$!
    sleep 2
    VIRTUAL_DEVICE=$(readlink ttyV0)

    # make fpga-run-linux in background
    echo ""
    echo -e "${BOLD}BOOTING LINUX...${NC}"
    cd "$ESP_ROOT/socs/xilinx-vc707-xc7vx485t"
    $fpga_run_linux > "$run_linux" 2>&1 &

    # call helper to monitor linux boot progress. 
    # TODO: do not kill minicom if boot success. the linux will be used later.
    $monitor > "$boot_linux" 2>&1 &
    monitor_pid=$!

    # open minicom in foreground
    minicom="$logs/minicom/minicom_linux.log"
    minicom -p "$VIRTUAL_DEVICE" -C "$minicom" 2>&1

    # print monitor status
    wait $monitor_pid
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
    echo "Monitor script detected successful boot"
    else
    echo "Monitor script detected boot failure or was terminated"
    fi

    # TODO: if linux boot success, run ssh login and fft script

    # clean up
    kill -9 "$socat_pid"

else
    echo ""
    echo "MAKE LINUX FAILED"
fi