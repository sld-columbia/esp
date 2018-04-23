#ifndef __ESP_PROBE_H__
#define __ESP_PROBE_H__

#include <esp_cache.h>
#include <esp_accelerator.h>

#define VENDOR_SLD 0xEB
#define APB_BASE_ADDR 0x80000000
#define APB_PLUGNPLAY (APB_BASE_ADDR + 0xff000)
#define NAPBSLV 32

#define SLD_L2_CACHE 0x020
#define SLD_L3_CACHE 0x021

struct esp_device {
	unsigned vendor;
	unsigned id;
	unsigned number;
	unsigned irq;
	unsigned addr;
};

int probe(struct esp_device **espdevs, unsigned devid, const char *name);
unsigned ioread32(struct esp_device *dev, unsigned offset);
void iowrite32(struct esp_device *dev, unsigned offset, unsigned payload);
void esp_flush(int coherence);

#endif /* __ESP_PROBE_H__ */
