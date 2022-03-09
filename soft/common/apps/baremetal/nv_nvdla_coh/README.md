# NVDLA Baremetal Application with Coherence

This baremetal application serves two purposes. First, it allows for testing
the NVDLA in ESP without booting an operating system or using the NVDLA
software stack. This is particularly convenient for testing NVDLA in full
system simulation. The input data and configuration of NVDLA's registers were
obtained by recording transactions at the interrface of NVDLA running on FPGA
with its software stack.

Second, this application shows how to configure the coherence mode of a
third-party accelerator designed independently of ESP. Currently, the
third-party socket supports the non-coherent-DMA, the LLC-coherent-DMA, and the
coherent-DMA modes; the fully-coherent mode with a private L2 cache is not yet
supported. The coherence register for these accelerators sits in the control
and status registers (CSRs) of the tile.  The support for configuring the
coherence modes of third-party accelerators is currently not completely
transparent, as it is for ESP accelerators (this is planned for future
releases). So, this application shows how to write to this configuration
register. The application is configured to work with the SoC configuration
provided in this folder. For different SoCs, the `nvdla_tile_numbers` array
should be modified to include the tile number for each NVDLA instance in the
SoC. A similar approach can be used to write to the coherence register of
third-party accelerators from Linux appliations, although this requires the
memory region of the CSRs to be mapped with `mmap` first. An equivalent code
snippet for a Linux application is shown below.

```
void *monitor_base_ptr;
int fd = open("/dev/mem", O_RDWR);
csr_base_ptr = mmap(NULL, SOC_ROWS * SOC_COLS * MONITOR_TILE_SIZE
                            , PROT_READ | PROT_WRITE, MAP_SHARED, fd, CSR_BASE_ADDR);
close(fd);

tile_offset = (CSR_TILE_SIZE / sizeof(unsigned int)) * nvdla_tile_numbers[n];
coh_reg_addr = ((unsigned int*) csr_base_addr) + tile_offset + COH_REG_INDEX;
*coh_reg_addr = ACC_COH_NONE;
```
