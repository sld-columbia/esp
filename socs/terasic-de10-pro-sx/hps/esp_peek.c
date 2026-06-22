// esp_peek.c - read a single 32-bit word from a physical address via /dev/mem
// Usage: sudo ./esp_peek 0x2000000000

#include <errno.h>
#include <fcntl.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/mman.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <physical_address>\n", argv[0]);
        return 1;
    }

    // Parse address (hex like 0x2000000000 or decimal)
    errno = 0;
    uint64_t phys_addr = strtoull(argv[1], NULL, 0);
    if (errno != 0) {
        perror("strtoull");
        return 1;
    }

    // Get page size and compute page-aligned base
    long page_size = sysconf(_SC_PAGESIZE);
    if (page_size <= 0) {
        perror("sysconf(_SC_PAGESIZE)");
        return 1;
    }

    uint64_t page_mask = (uint64_t)page_size - 1;
    uint64_t page_base = phys_addr & ~page_mask;
    uint64_t page_offset = phys_addr - page_base;

    // Open /dev/mem
    int fd = open("/dev/mem", O_RDONLY | O_SYNC);
    if (fd < 0) {
        perror("open(/dev/mem)");
        return 1;
    }

    // Map exactly one page containing the address
    void *map = mmap(NULL,
                     page_size,
                     PROT_READ,
                     MAP_SHARED,
                     fd,
                     (off_t)page_base);
    if (map == MAP_FAILED) {
        perror("mmap");
        close(fd);
        return 1;
    }

    volatile uint32_t *ptr = (volatile uint32_t *)((uint8_t *)map + page_offset);
    uint32_t value = *ptr;

    printf("Read 32-bit value at 0x%016" PRIx64 " = 0x%08" PRIx32 "\n",
           phys_addr, value);

    munmap(map, page_size);
    close(fd);
    return 0;
}