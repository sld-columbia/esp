#include <stdint.h>
struct grgpio_apb {
        uint32_t iodata;        ///< 0x00       I/O port data register
        uint32_t iooutput;      ///< 0x04       I/O port output register
        uint32_t iodir;         ///< 0x08       I/O port direction register
        uint32_t irqmask;       ///< 0x0C       Interrupt mask register
        uint32_t irqpol;        ///< 0x10       Interrupt polarity register
        uint32_t irqedge;       ///< 0x14       Interrupt edge register
        union {
                // GRGPIO v1
                struct {
                        uint32_t bypass;        ///< 0x18       Bypass register
                        uint32_t capability;    ///< 0x1C       Capability register
                        uint32_t irqmap[8];     ///< 0x20-0x3C  Interrupt map register(s)
                };
                // GRPULSE
                struct {
                        uint32_t pulse;        ///< 0x18       Pulse register
                        uint32_t counter;      ///< 0x1C       Pulse counter register

                };
        };
};
