#!/usr/bin/env bash
# Run against exactly the RTL installed for the selected technology.
set -euo pipefail
test_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
esp_root=$(cd "$test_dir/../../../../.." && pwd)
rtl_dir=${1:-"$esp_root/tech/virtex7/acc/peek_dd"}
run_dir=${2:-$(mktemp -d /tmp/peek-dd-dma.XXXXXX)}
mkdir -p "$run_dir"
run_dir=$(cd "$run_dir" && pwd)
iverilog -g2012 -s peek_dd_dma_tb -o "$run_dir/sim" \
    "$test_dir/peek_dd_dma_tb.sv" \
    "$rtl_dir/peek_dd_basic_dma64/peek_dd_basic_dma64.v" \
    "$rtl_dir/peek_dd_core.v" "$rtl_dir/panda_libtech.v"
cp "$rtl_dir"/*.mem "$run_dir/"
cd "$run_dir"
for seed in 1 17 2026; do
    timeout 60 vvp ./sim +SEED="$seed"
done | tee simulation.log
test "$(grep -c '^ESP DMA RTL PASS' simulation.log)" -eq 3
echo "DMA validation artifacts: $run_dir"
