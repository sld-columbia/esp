#ifndef ESP_CACHE_H
#define ESP_CACHE_H

#ifdef __KERNEL__
#include <linux/types.h>
#else
#include <stdint.h>
#endif /* __KERNEL__ */


#ifdef __KERNEL__

#include <linux/platform_device.h>
#include <linux/completion.h>
#include <linux/device.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/list.h>
#include <linux/spinlock.h>
#include <linux/interrupt.h>
#include <asm/io.h>
#include <asm/uaccess.h>

int esp_cache_flush(void);

#endif /* __KERNEL__ */

#endif /* ESP_CACHE_H */
