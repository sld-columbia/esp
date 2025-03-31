/*
 * Copyright (c) 2011-2022 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * Tile Manager
 * Used to manage registering and unregistering of device drivers per tile. 
 * Keeps a list of "boilerplate" esp drivers 
 * Takes in a esp_driver, clones relevant information to respective tile driver
 * This allows for tile-unique drivers.
 *
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

#include <esp_accelerator.h>
#define DRV_NAME "esp_dpr"

//EXPORT_SYMBOL_GPL(tiles);

struct list_head pbs_list[5] = {};
struct dpr_tile tiles[5] = {}; 

//static struct dpr_tile * to_dpr_tile(struct platform_device *pdev)
//{
//	struct device_driver *driver = pdev->dev.driver;
//	struct platform_driver *plat_drv = to_platform_driver(driver);
//	struct esp_driver *esp_drv = container_of(plat_drv, struct esp_driver, plat);
//	struct dpr_tile *tile = container_of(esp_drv, struct dpr_tile, esp_drv);
//	return dpr_tile;
//
//}
//
//


//struct pbs_struct * get_pbs(int tile, char *name)
//{
//	pbs_struct *pbs_entry;
//	list_for_each_entry(pbs_entry, &pbs_list[user_pbs.pbs_tile_id], list){
//		if(pbs_entry->tile_id == tile && !strcmp(pbs_entry->name, name)){
//			pr_info("\nFound match!\n");
//			return pbs_entry;
//		}
//	}
//
//	return NULL;
//
//}
//
//int add_pbs(int tile, struct pbs_struct *pbs)
//{
//	int ret; 
//	struct pbs_struct pbs_entry = get_pbs(pbs->tile_id, pbs->name);
//
//	if(pbs_entry)
//		return -1;
//
//	list_add(&pbs->list, &tiles[tile].pbs_list);
//	return 0;
//
//}

int __decoupler(int tile, int status)
{
	unsigned long decoupler_phys;
	void *decoupler;
	int ret;

	status = __cpu_to_le32(status);
	iowrite32(status, tiles[tile].decoupler);
	ret = ioread32(tiles[tile].decoupler);
	return ret;
}


int decouple(int tile_loc)
{
	pr_info("Accelerator %i decoupled\n", tile_loc);
	return __decoupler(tile_loc, 1);
}
EXPORT_SYMBOL_GPL(decouple);

int couple(int tile_loc)
{
	pr_info("Accelerator %i coupled\n", tile_loc);
	return __decoupler(tile_loc, 0);
}
EXPORT_SYMBOL_GPL(couple);

static int tile_probe(struct platform_device *pdev)
{
	int rc; 
	struct device_driver *driver = pdev->dev.driver;
	struct platform_driver *plat_drv = to_platform_driver(driver);
	struct esp_driver *esp_drv = container_of(plat_drv, struct esp_driver, plat);
	struct dpr_tile *tile = container_of(esp_drv, struct dpr_tile, esp_drv);
	struct esp_device *esp = &(tile->esp_dev);

	pr_info(DRV_NAME": probe\n");
	pr_info(DRV_NAME": MAYBE THIS? [%s]\n", pdev->dev.driver->name);

	esp->module = THIS_MODULE;
	esp->number = 0;
	esp->driver = esp_drv;

	rc = esp_device_register(esp, pdev);

	return 0;
}

static int __exit tile_remove(struct platform_device *pdev)
{
	int rc; 
	struct esp_device *esp = platform_get_drvdata(pdev);

	esp_device_unregister(esp);
	return 0;
}

void unload_driver(int tile_num)
{
	//mutex_lock(&(tiles[tile_num].esp_dev.lock));
	//pr_info("UNLOAD LOCK RET: %d\n", rc);
	esp_driver_unregister(&(tiles[tile_num].esp_drv));

}
EXPORT_SYMBOL_GPL(unload_driver);


void load_driver(struct esp_driver *esp, int tile_num)
{
	int ret;

	pr_info(DRV_NAME ": loading driver [%s] for tile [%d] :)\n",
			esp->plat.driver.name, tile_num);
	strcpy(tiles[tile_num].esp_drv.plat.driver.name, esp->plat.driver.name);
	strcat(tiles[tile_num].esp_drv.plat.driver.name, "_");
	strcat(tiles[tile_num].esp_drv.plat.driver.name, tiles[tile_num].tile_id);


	strcpy(tiles[tile_num].esp_drv.plat.driver.of_match_table[0].name, esp->plat.driver.name);
	strcpy(tiles[tile_num].esp_drv.plat.driver.of_match_table[1].name, tiles[tile_num].tile_id);
	pr_info("Copied [%s], now holds: [%s]\n", tiles[tile_num].tile_id,  tiles[tile_num].esp_drv.plat.driver.of_match_table[1].name);
	

	tiles[tile_num].esp_drv.plat.probe	= tile_probe;
	tiles[tile_num].esp_drv.plat.remove	= tile_remove;
	tiles[tile_num].esp_drv.xfer_input_ok	= esp->xfer_input_ok;
	tiles[tile_num].esp_drv.prep_xfer	= esp->prep_xfer;
	tiles[tile_num].esp_drv.ioctl_cm	= esp->ioctl_cm;
	tiles[tile_num].esp_drv.arg_size	= esp->arg_size;
	tiles[tile_num].esp_drv.dpr			= false;
	//tiles[tile_num].esp_drv.esp		= &test_esp_device;

	ret = esp_driver_register(&(tiles[tile_num].esp_drv));
	pr_info(DRV_NAME ": esp_drv_reg returned: %d\n", ret);
}
EXPORT_SYMBOL_GPL(load_driver);


void wait_for_tile(int tile)
{
	u32 status, run;
	pr_info("Waiting for tile: %d\n", tile);

	if(!tiles[tile].esp_dev.iomem)
		pr_info("IOMEM NOT MAPPED...");
	pr_info("IOMEM: 0x%08x\n", tiles[tile].esp_dev.iomem);


	status = ioread32be(tiles[tile].esp_dev.iomem + STATUS_REG);
	run = status & STATUS_MASK_RUN;
	pr_info("STATUS: 0x%08x\n", status);

	if (run) {
		pr_info("ACC ALREADYING RUNNING, WAIT!\n");
		wait_for_completion_interruptible(&(tiles[tile].esp_dev.completion));
	}
}
EXPORT_SYMBOL_GPL(wait_for_tile);

void register_tile_driver(struct work_struct * work)
{
	struct dpr_tile *tile = container_of(work, struct dpr_tile, reg_drv_work);
	tile->curr = tile->next;
	pr_info(DRV_NAME ": Current now equals -  %s\n", tile->curr->driver);
	load_driver(tile->next->esp_drv, tile->tile_num);
	pr_info(DRV_NAME ": Completed Reconfiguration Cycle\n");
	complete(&prc_completion);
}

void tiles_setup(void)
{
	int i;
	unsigned long dphys; 

	for(i = 0; i < 5; i++)
	{
		INIT_LIST_HEAD(&pbs_list[i]);
		INIT_LIST_HEAD(&tiles[i].pbs_list);
		INIT_WORK(&tiles[i].reg_drv_work, register_tile_driver); 
		tiles[i].tile_num = i;
		dphys= (unsigned long) (APB_BASE_ADDR + (MONITOR_BASE_ADDR + i * 0x200));
		tiles[i].decoupler = ioremap(dphys, 1); 
		tiles[i].esp_drv.plat.probe = tile_probe;
		tiles[i].esp_drv.plat.driver.name = "empty-oops";
		tiles[i].esp_drv.plat.driver.owner = THIS_MODULE;

		strcpy(tiles[i].device_ids[2].compatible , "sld");
		tiles[i].esp_drv.plat.driver.of_match_table = tiles[i].device_ids;

		mutex_init(&tiles[i].esp_dev.dpr_lock);
		init_completion(&tiles[i].prc_completion);
	}

	strcpy(tiles[2].tile_id, "eb_122");
	strcpy(tiles[4].tile_id, "eb_056");
}

struct completion prc_completion;
EXPORT_SYMBOL_GPL(prc_completion);


static long esp_dpr_ioctl(struct file *f, unsigned int cmd, unsigned long arg)
{
	int i = 0;

	pbs_arg user_pbs;
	decouple_arg d;
	pbs_struct *pbs_entry;
	struct esp_device *esp;
	struct esp_driver *drv;
	struct list_head *ele;

	/**
	 * TODO:
	 *	- Add remove pbs entry
	 *	- Add return pbs_entry list
	 *	- move cmds to seperate functions
	 */
	switch (cmd) {
		case PRC_LOAD_BS:
			if (copy_from_user(&user_pbs, (pbs_arg *) arg, sizeof(pbs_arg))) {
				pr_info("Failed to copy pbs_arg\n");
				return -EACCES;
			}

			pr_info("pbs_size is 0x%08x\n", user_pbs.pbs_size);
			if (!user_pbs.pbs_size)
				return -EACCES;


			list_for_each_entry(pbs_entry, &pbs_list[user_pbs.pbs_tile_id], list){
				if(pbs_entry->tile_id == user_pbs.pbs_tile_id && !strcmp(pbs_entry->name, user_pbs.name)) {
					pr_info("\nAlready Loaded: %s - %s...\n", pbs_entry->name, user_pbs.name);
					return 0;
					//load_driver(pbs_entry->esp_drv, pbs_entry->tile_id);
					//return -EACCES;
				}
			}

			pbs_entry = kmalloc(sizeof(pbs_struct), GFP_KERNEL);
			pbs_entry->file = kmalloc(user_pbs.pbs_size, GFP_DMA | GFP_KERNEL);
			if (!pbs_entry->file)
				return -ENOMEM;

			pr_info("Looking for %s...\n", user_pbs.driver);
			spin_lock(&esp_drivers_lock);
			list_for_each(ele, &esp_drivers) { drv = list_entry(ele, struct esp_driver, list);
				//pr_info("Comparing [%s] with [%s]\n", drv->plat.driver.name, user_pbs.driver);
				if (!strcmp(drv->plat.driver.name, user_pbs.driver)) {
					pr_info("Found %s driver in driver list\n", user_pbs.driver);
					pbs_entry->esp_drv = drv;
				}
			}

			if (!pbs_entry->esp_drv)
				return -ENODEV;

			spin_unlock(&esp_drivers_lock);

			if (copy_from_user(pbs_entry->file, user_pbs.pbs_mmap, user_pbs.pbs_size)) {
				kfree(pbs_entry->file);
				return -EACCES;
			}

			//Fill in rest of the pbs_struct fields
			pbs_entry->size		= user_pbs.pbs_size;
			pbs_entry->tile_id	= user_pbs.pbs_tile_id;
			pbs_entry->phys_loc	= (void *)(virt_to_phys(pbs_entry->file));
			memcpy(pbs_entry->name, user_pbs.name, LEN_DEVNAME_MAX);
			memcpy(pbs_entry->driver, user_pbs.driver, LEN_DRVNAME_MAX);
			INIT_LIST_HEAD(&pbs_entry->list);
			pr_info(DRV_NAME " filled in pbs_entry...\n");

			//If first pbs in list, reconfigure device to use it...
			if (list_empty(&pbs_list[pbs_entry->tile_id])) {
				pr_info(DRV_NAME " tile list is empty, reconfigure device to use this one...\n");

				tiles[pbs_entry->tile_id].next = pbs_entry; 

				mutex_lock(&tiles[user_pbs.pbs_tile_id].esp_dev.dpr_lock);
				//prc_reconfigure(pbs_entry);
				load_driver(pbs_entry->esp_drv, 2);
				mutex_unlock(&tiles[user_pbs.pbs_tile_id].esp_dev.dpr_lock);
			}

			//Add to list:
			list_add(&pbs_entry->list, &pbs_list[user_pbs.pbs_tile_id]);

			pr_info(DRV_NAME ": Successfully Read Arguments...\n");
			break;

		case PRC_RECONFIGURE:
			pr_info("RECONFIGURATION REQUESTED");
			if (copy_from_user(&user_pbs, (pbs_arg *) arg, sizeof(pbs_arg))) {
				pr_info("Failed to copy pbs_arg\n");
				return -EACCES;
			}
			list_for_each_entry(pbs_entry, &pbs_list[user_pbs.pbs_tile_id], list){
				if(pbs_entry->tile_id == user_pbs.pbs_tile_id && !strcmp(pbs_entry->name, user_pbs.name)){
					pr_info("\nFound match!\n");
					if (!strcmp(tiles[user_pbs.pbs_tile_id].curr->name, pbs_entry->name)) {
						pr_info("Tile already currently using this pbs...\n");
						return 0;
					}

					tiles[user_pbs.pbs_tile_id].next = pbs_entry;
					pr_info(DRV_NAME ": unregistering %s\n", tiles[user_pbs.pbs_tile_id].curr->driver);
					wait_for_tile(user_pbs.pbs_tile_id);
					mutex_lock(&tiles[user_pbs.pbs_tile_id].esp_dev.dpr_lock);
					unload_driver(user_pbs.pbs_tile_id);

					//esp_driver_unregister(tiles[user_pbs.pbs_tile_id].curr->esp_drv);

					prc_reconfigure(pbs_entry);
					//pr_info("Please register %s\n", pbs_entry->esp_drv->plat.driver.name);
					mutex_unlock(&tiles[user_pbs.pbs_tile_id].esp_dev.dpr_lock);
					return 0;
				}
			}

			pr_info("\nBitstream not loaded..\n");
			break;
		default:
			return -EINVAL;
	}
	return 0;
}

static const struct file_operations esp_dpr_fops = {
	.owner 		= THIS_MODULE,
	.unlocked_ioctl = esp_dpr_ioctl,
};

static struct miscdevice esp_dpr_misc_device = {
	.minor 	= MISC_DYNAMIC_MINOR,
	.name 	= DRV_NAME,
	.fops	= &esp_dpr_fops,
};



static int __init tile_manager_init(void)
{
	int ret;
	pr_info(DRV_NAME ": init\n");
	init_completion(&prc_completion);
	tiles_setup();

	ret = misc_register(&esp_dpr_misc_device);
	if (ret) {
		misc_deregister(&esp_dpr_misc_device);
		return -ENOENT;
	}

	ret = platform_driver_probe(&esp_prc_driver, esp_prc_probe);
	pr_info(DRV_NAME ": registered PRC driver...");
//	return 0;
	//return platform_driver_probe(&esp_dpr_driver);;
}

static void __exit tile_manager_exit(void)
{
	misc_deregister(&esp_dpr_misc_device);
	platform_driver_unregister(&esp_prc_driver);
//	platform_driver_unregister(&tile_manager_driver);
}

static int __exit tile_manager_remove(struct platform_device *pdev)
{
	return 0;
}



//TODO: 
//Move userspace calls to this
//Finish userspace calls 
//Add /proc/ devices to expose information

module_init(tile_manager_init);
module_exit(tile_manager_exit);


MODULE_LICENSE("GPL");
MODULE_AUTHOR("Bryce Natter <brycenatter@pm.me");
MODULE_DESCRIPTION("esp dpr manager driver");
