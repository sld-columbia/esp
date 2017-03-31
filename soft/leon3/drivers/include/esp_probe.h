#ifndef __ESP_PROBE_H__
#define __ESP_PROBE_H__

#define VENDOR_SLD 0xEB
#define APB_BASE_ADDR 0x80000000
#define APB_PLUGNPLAY (APB_BASE_ADDR + 0xff000)
#define NAPBSLV 32

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

#endif /* __ESP_PROBE_H__ */
