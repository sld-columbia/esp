/*
 * Copyright (c) 2011-2022 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#include <asm/byteorder.h>
#include <linux/io.h>
#include <asm/irq.h> 
#include <linux/of_irq.h>
#include <linux/list.h>
#include <linux/string.h>
#include <esp.h>
#include "dpr.h"
#include <linux/delay.h>
#include <linux/workqueue.h>
#include <linux/ktime.h>

#define DRV_NAME "(PRC)"

#define PRC_WRITE(base, offset, value) iowrite32(value, base.prc_base + offset)
#define PRC_READ(base, offset) ioread32(base.prc_base + offset)


DEFINE_MUTEX(prc_lock);

uint32_t rtile = 0;
struct pbs_struct *curr;
struct pbs_struct *next; 

struct esp_prc_device {
	struct device 	*dev;
	struct resource res;
	struct module 	*module;
	void __iomem 	*prc_base;
	int		irq;
} prc_dev;


//struct list_head pbs_list[5];


ktime_t start_time, stop_time, elapsed_time;


static int prc_start(void)
{
	uint32_t prc_status;
	uint32_t bit1 = 1;

	bit1 = cpu_to_le32(bit1);
	PRC_WRITE(prc_dev, 0x0, bit1);

	prc_status = PRC_READ(prc_dev, 0x0);
	prc_status = le32_to_cpu(prc_status);
	prc_status &= (1<<7);

	if (prc_status) {
		pr_info(DRV_NAME ": error starting controller \n");
		return 1;
	}

	return 0;

}

static int prc_stop(void)
{
	uint32_t prc_status;

	PRC_WRITE(prc_dev, 0x0, 0x0);

	prc_status = PRC_READ(prc_dev, 0x0);
	prc_status = le32_to_cpu(prc_status);
	prc_status &= (1<<7);

	if (!prc_status) {
		pr_info(DRV_NAME ": Error shutting controller \n");
		return 1;
	}
	return 0;
}

static int prc_set_trigger(void *pbs_addr, uint32_t pbs_size)
{
	uint32_t le_addr = cpu_to_le32((uint32_t)pbs_addr);
	uint32_t le_size = cpu_to_le32(pbs_size);
	if (!prc_stop()) {
		PRC_WRITE(prc_dev, TRIGGER_OFFSET + 0x0, 0x0);
		PRC_WRITE(prc_dev, TRIGGER_OFFSET + 0x4, le_addr);
		PRC_WRITE(prc_dev, TRIGGER_OFFSET + 0x8, le_size);
		pr_info(DRV_NAME ": Trigger set \n");
		return 0;
	} else {
		pr_info(DRV_NAME ": Error arming trigger \n");
		return 1;
	}
}


int prc_reconfigure(pbs_struct *pbs)
{
	//   int status = 0;
	rtile = pbs->tile_id;
	
	//wait_for_tile(pbs->tile_id);
	reinit_completion(&prc_completion);
	mutex_lock(&prc_lock);

	start_time = ktime_get();

	decouple(pbs->tile_id); //Signal to decouple Acc
	prc_set_trigger(pbs->phys_loc, pbs->size);//pbs_id);

	if(!(prc_start())) {
		pr_info(DRV_NAME ": Starting Reconfiguration \n");
		PRC_WRITE(prc_dev, 0x4, 0); //send reconfig trigger
	}

	else {
		pr_info(DRV_NAME ": Error reconfiguring FPGA \n");
		return 1;
	}

	pr_info(DRV_NAME ": Started Reconfiguration... waiting for completion... \n");
	//wait_for_completion_interruptible_timeout(&prc_completion, 12000);
	mutex_unlock(&prc_lock); // unlock when reconfiguration is actually done

	pr_info(DRV_NAME ": Finished Reconfiguration\n");
	return 0;
}
//EXPORT_SYMBOL_GPL(prc_reconfigure);

static struct miscdevice esp_prc_misc_device = {
	.minor 	= MISC_DYNAMIC_MINOR,
	.name 	= DRV_NAME,
	//.fops	= &esp_prc_fops,
};

static irqreturn_t prc_irq(int irq, void *dev)
{
	int status;
	uint32_t byte3= 0x3;
	byte3 = cpu_to_le32(byte3);

	status = PRC_READ(prc_dev, 0x0);

	PRC_WRITE(prc_dev, 0x0, byte3); //clear interrupt 

	if(status == 0x07000000){
		stop_time = ktime_get();
		elapsed_time= ktime_sub(stop_time, start_time);
		couple(rtile);
		pr_info(DRV_NAME ": Reconfigured Complete triggered\n");
		pr_info(DRV_NAME ": Elapsed time: %lldns\n",  ktime_to_ns(elapsed_time));
		schedule_work(&tiles[rtile].reg_drv_work);
		//complete(&prc_completion);
	}

	return IRQ_HANDLED;
}

int esp_prc_probe(struct platform_device *pdev)
{
	int ret;
	int rc;
	int irq_num;


	prc_loaded = true; 
	
	ret = misc_register(&esp_prc_misc_device);
	ret = of_address_to_resource(pdev->dev.of_node, 0, &prc_dev.res);
	if (ret) {
		ret = -ENOENT;
		goto deregister_res;
	}

	if (request_mem_region(prc_dev.res.start, resource_size(&prc_dev.res),
				DRV_NAME) == NULL)
	{
		ret = -EBUSY;
		goto deregister_res;
	}

	prc_dev.prc_base = of_iomap(pdev->dev.of_node, 0);
	if (prc_dev.prc_base == NULL) {
		ret = -ENOMEM;
		goto release_mem;
	}

	irq_num = of_irq_get(pdev->dev.of_node, 0);
	pr_info("PRC found IRQ of %d\n", irq_num);
	rc = request_irq(PRC_IRQ, prc_irq, IRQF_SHARED, DRV_NAME, pdev);
	if (rc) {
		pr_info(DRV_NAME ": cannot request IRQ \n");
		goto release_mem; 
	}

	return 0;

release_mem:
	release_mem_region(prc_dev.res.start, resource_size(&prc_dev.res));
deregister_res:
	misc_deregister(&esp_prc_misc_device);
	return ret;
}


int __exit esp_prc_remove(struct platform_device *pdev)
{
	iounmap(prc_dev.prc_base);
	release_mem_region(prc_dev.res.start, resource_size(&prc_dev.res));
	misc_deregister(&esp_prc_misc_device);
	return 0;
}

extern struct of_device_id esp_prc_device_ids[] = {
	{
		.name = "XILINX_PRC",
	},
	{
		.name = "ef_031",
	},
	{
		.compatible = "sld,prc",
	},
	{ },
};
struct platform_driver esp_prc_driver = {
		.driver		= {
			.name 		= DRV_NAME,
			.owner		= THIS_MODULE,
			.of_match_table	= of_match_ptr(esp_prc_device_ids),
		},
		.remove	= __exit_p(esp_prc_remove),
};

//
//static int __init esp_prc_init(void)
//{
//	pr_info(DRV_NAME ": init\n");
//	//tiles_setup();
//	return platform_driver_probe(&esp_prc_driver, esp_prc_probe);
//}
//
//static void __exit esp_prc_exit(void)
//{
//	platform_driver_unregister(&esp_prc_driver);
//}
//
//module_init(esp_prc_init);
//module_exit(esp_prc_exit);

MODULE_DEVICE_TABLE(of, esp_prc_device_ids);

//MODULE_LICENSE("GPL");
//MODULE_AUTHOR("Bryce Natter <brycenatter@pm.me");
//MODULE_DESCRIPTION("esp PRC driver");
