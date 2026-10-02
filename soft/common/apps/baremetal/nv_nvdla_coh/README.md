# NVDLA Bare-Metal Coherence Test

This application replays a recorded NVDLA register sequence without requiring
Linux or the NVDLA software stack. It is useful for full-system simulation and
for validating NVDLA integration on FPGA.

The test also demonstrates how a third-party accelerator selects its ESP
coherence mode through the tile control and status registers. It uses
`ACC_COH_RECALL` when the generated SoC configuration enables the ESP
coherence hierarchy and `ACC_COH_NONE` for non-coherent systems.

## SoC Layout

The application includes tile-number tables for the provided 2x2 design and
the ESP third-party accelerator guide layout. Update
`nvdla_tile_numbers_2x2` or `nvdla_tile_numbers_guide` when using another SoC
layout. Interrupt numbers are discovered from the generated device tree.

ESP currently supports non-coherent DMA, LLC-coherent DMA, and coherent DMA
for third-party accelerators. A third-party accelerator with a private,
fully-coherent L2 cache is not supported.

## Linux Equivalent

A Linux application can configure the same coherence register after mapping
the tile CSR region through `/dev/mem`:

```c
int fd = open("/dev/mem", O_RDWR);
void *csr_base = mmap(NULL, SOC_ROWS * SOC_COLS * MONITOR_TILE_SIZE,
                      PROT_READ | PROT_WRITE, MAP_SHARED, fd, CSR_BASE_ADDR);
close(fd);

unsigned int tile_offset =
    (CSR_TILE_SIZE / sizeof(unsigned int)) * nvdla_tile_numbers[n];
volatile unsigned int *coh_reg =
    (volatile unsigned int *)csr_base + tile_offset + COH_REG_INDEX;

*coh_reg = ACC_COH_NONE;
```

Production code should check the return values from `open` and `mmap`, and
unmap the CSR region when it is no longer needed.
