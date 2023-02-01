/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * contig_alloc.c
 * Simple allocator for huge amounts of physically contiguous memory.
 * Allocation is done in chunks of configurable size (default 1MB).
 * Memory can come from either bigphysarea or memory that is not under
 * linux's control.
 * The module requires three flags when it is installed:
 * - start: Array with the physical addresses of the beginning of the
 *          memory regions assigned to the module for the different
 *          DDR devices. Ignored for bigphysarea.
 * - size: Array with the size in bytes of each memory region.
 * - chunk_log: log2 of the size of each memory chunk. Default: 20 (i.e. 1MB).
 */
//#include <linux/bigphysarea.h>
#include <linux/dma-mapping.h>
#include <linux/moduleparam.h>
#include <linux/compiler.h>
#include <linux/device.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/list.h>
#include <linux/slab.h>
#include <linux/stat.h>
#include <linux/err.h>
#include <linux/mm.h>

#include <linux/uaccess.h>

#include <contig_alloc.h>

struct contig_chunk {
	unsigned long paddr;
	int ddr_node;
	struct list_head node; /* head: inactive_chunks or desc->alloc_list */
};

struct contig_file {
	struct list_head desc_list;
};

#define PFX "contig_alloc: "

#define MAX_DDR_NODES 8

static unsigned long chunk_size;
unsigned long contig_chunk_size_log = 20;
EXPORT_SYMBOL_GPL(contig_chunk_size_log);
module_param_named(chunk_log, contig_chunk_size_log, ulong, S_IRUGO);
static unsigned int nddr;
module_param(nddr, uint, S_IRUGO);
static unsigned long mem_start[MAX_DDR_NODES];
module_param_array_named(start, mem_start, ulong, &nddr, S_IRUGO);
static unsigned long mem_size[MAX_DDR_NODES];
module_param_array_named(size, mem_size, ulong, &nddr, S_IRUGO);

static struct class *contig_class;
static DEFINE_MUTEX(contig_lock);
static LIST_HEAD(desc_list);
static struct list_head inactive_chunks[MAX_DDR_NODES];
static unsigned long mem_allocated[MAX_DDR_NODES];
static caddr_t bp_buf __maybe_unused;

static int contig_open(struct inode *, struct file *);
static int contig_release(struct inode *, struct file *);
static long contig_ioctl(struct file *, unsigned int, unsigned long);
static int contig_mmap(struct file *, struct vm_area_struct *);

static const struct file_operations contig_fops = {
	.owner		= THIS_MODULE,
	.open		= contig_open,
	.release	= contig_release,
	.unlocked_ioctl	= contig_ioctl,
	.mmap		= contig_mmap,
};

static struct contig_desc *contig_alloc_descriptor(unsigned int n_chunks)
{
	struct contig_desc *desc;

	desc = kmalloc(sizeof(*desc), GFP_KERNEL);
	if (unlikely(desc == NULL))
		return ERR_PTR(-ENOMEM);

	desc->arr = kmalloc_array(n_chunks, sizeof(unsigned long), GFP_KERNEL);
	if (unlikely(desc->arr == NULL))
		goto err_arr;

#ifndef __riscv
	desc->arr_dma_addr = dma_map_single(NULL, desc->arr, n_chunks * sizeof(dma_addr_t), DMA_TO_DEVICE);
#else
	desc->arr_dma_addr = virt_to_phys(desc->arr);
#endif
	if (unlikely(dma_mapping_error(NULL, desc->arr_dma_addr)))
		goto err_dma;

	desc->n = n_chunks;
	INIT_LIST_HEAD(&desc->alloc_list);
	return desc;

 err_dma:
	kfree(desc->arr);
 err_arr:
	kfree(desc);
	return ERR_PTR(-ENOMEM);
}

static void contig_free_descriptor(struct contig_desc *desc)
{
#ifndef __riscv
	dma_unmap_single(NULL, desc->arr_dma_addr, desc->n * sizeof(dma_addr_t), DMA_TO_DEVICE);
#endif
	kfree(desc->arr);
	kfree(desc);
}

static int get_next_ddr_node(int ddr_node, int first_ddr_node)
{
	BUG_ON(mem_allocated[ddr_node] > mem_size[ddr_node]);
	while (mem_allocated[ddr_node] == mem_size[ddr_node]) {
		ddr_node = (ddr_node + 1) % nddr;
		BUG_ON(ddr_node == first_ddr_node);
	}
	return ddr_node;
}

static void allocate_chunk(struct contig_desc **desc, int ddr_node, int chunk_index)
{
	struct contig_chunk *ch;

	BUG_ON(list_empty(&inactive_chunks[ddr_node]));
	ch = list_first_entry(&inactive_chunks[ddr_node], struct contig_chunk, node);
	/* pr_info("Allocating chunk %d @ address 0x%08lx\n", chunk_index, ch->paddr); */
	list_del(&ch->node);
	list_add(&ch->node, &(*desc)->alloc_list);
	(*desc)->arr[chunk_index] = ch->paddr;
	mem_allocated[ddr_node] += chunk_size;
}

static int contig_alloc_preferred(struct contig_desc *desc, const struct contig_alloc_params *params)
{
	unsigned long allocated = 0;
	int ddr_node;
	int i;

	unsigned int n_per_node_max;
	unsigned int n_per_node[MAX_DDR_NODES];
	for (i = 0; i < nddr; i++)
		n_per_node[i] = 0;

	ddr_node = params->pol.first.ddr_node;
	for (i = 0; i < desc->n; i++) {
		ddr_node = get_next_ddr_node(ddr_node, params->pol.first.ddr_node);
		allocate_chunk(&desc, ddr_node, i);
		allocated += chunk_size;
		n_per_node[ddr_node]++;
	}
	BUG_ON(allocated != desc->n * chunk_size);

	/* Compute which DDR holds most of the data */
	ddr_node = 0;
	n_per_node_max = n_per_node[0];

	for (i = 1; i < nddr; i++)
		if (n_per_node[i] > n_per_node_max) {
			ddr_node = i;
			n_per_node_max = n_per_node[i];
		}
	desc->most_allocated = ddr_node;

	return 0;
}

static bool least_loaded_alloc_ok(unsigned int n_chunks)
{
	int i;
	for (i = 0; i < nddr; i++)
		if (mem_size[i] - mem_allocated[i] >= n_chunks * chunk_size)
			return true;
	return false;
}

static int get_least_loaded_ddr_node(unsigned int n_chunks, unsigned int threshold)
{
	int i;
	unsigned long min_allocated = mem_size[1];
	int least_loaded = 0;
	unsigned long tba = n_chunks * chunk_size;
	unsigned long th = threshold * chunk_size;

	for (i = 1; i < nddr; i++)
		if (mem_allocated[i] <= min_allocated && mem_size[i] - mem_allocated[i] >= tba) {
			min_allocated = mem_allocated[i];
			least_loaded = i;
		}

	if (mem_allocated[0] + th < min_allocated && mem_size[0] - mem_allocated[0] >= tba)
		return 0;
	else
		return least_loaded;
}

static int contig_alloc_least_loaded(struct contig_desc *desc, const struct contig_alloc_params *params)
{
	unsigned long allocated = 0;
	int ddr_node;
	int i;

	if (unlikely(!least_loaded_alloc_ok(desc->n)))
		return -ENOMEM;

	ddr_node = get_least_loaded_ddr_node(desc->n, params->pol.lloaded.threshold);
	for (i = 0; i < desc->n; i++) {
		allocate_chunk(&desc, ddr_node, i);
		allocated += chunk_size;
	}
	BUG_ON(allocated != desc->n * chunk_size);

	desc->most_allocated = ddr_node;

	return 0;
}

static int contig_alloc_balanced(struct contig_desc *desc, const struct contig_alloc_params *params)
{
	unsigned long allocated = 0;
	int next_ddr_node;
	int cluster_chunk;
	int ddr_node;
	int i;

	unsigned int n_per_node_max;
	unsigned int n_per_node[MAX_DDR_NODES];
	for (i = 0; i < nddr; i++)
		n_per_node[i] = 0;

	ddr_node = get_least_loaded_ddr_node(1,	params->pol.balanced.threshold);

	cluster_chunk = 0;
	for (i = 0; i < desc->n; i++) {
		if (cluster_chunk == params->pol.balanced.cluster_size) {
			next_ddr_node = (ddr_node + 1) % nddr;
			next_ddr_node = get_next_ddr_node(next_ddr_node, next_ddr_node);
		} else {
			next_ddr_node = get_next_ddr_node(ddr_node, ddr_node);
		}

		if (ddr_node != next_ddr_node) {
			ddr_node = next_ddr_node;
			cluster_chunk = 1;
		} else {
			cluster_chunk++;
		}

		allocate_chunk(&desc, ddr_node, i);
		allocated += chunk_size;

		n_per_node[ddr_node]++;
	}
	BUG_ON(allocated != desc->n * chunk_size);

	/* Compute which DDR holds most of the data */
	ddr_node = 0;
	n_per_node_max = n_per_node[0];

	for (i = 1; i < nddr; i++)
		if (n_per_node[i] > n_per_node_max) {
			ddr_node = i;
			n_per_node_max = n_per_node[i];
		}
	desc->most_allocated = ddr_node;

	return 0;
}

static struct contig_desc *__contig_alloc_chunks(const struct contig_alloc_params *params, unsigned int n_chunks)
{
	struct contig_desc *desc;
	int rc;

	desc = contig_alloc_descriptor(n_chunks);
	if (unlikely(IS_ERR(desc)))
		return desc;

	switch (params->policy) {
	case CONTIG_ALLOC_PREFERRED:
		rc = contig_alloc_preferred(desc, params);
		break;
	case CONTIG_ALLOC_LEAST_LOADED:
		rc = contig_alloc_least_loaded(desc, params);
		break;
	case CONTIG_ALLOC_BALANCED:
		rc = contig_alloc_balanced(desc, params);
		break;
	default:
		BUG();
	}

	if (rc) {
		contig_free_descriptor(desc);
		return ERR_PTR(rc);
	}

	list_add(&desc->desc_node, &desc_list);
	return desc;
}

static struct contig_desc *__contig_alloc(const struct contig_alloc_params *params, unsigned long size)
{
	unsigned long mem_free = 0;
	unsigned int n_chunks;
	int i;

	for (i = 0; i < nddr; i++)
		mem_free += mem_size[i] - mem_allocated[i];

	if (size > mem_free)
		return ERR_PTR(-ENOMEM);

	n_chunks = DIV_ROUND_UP(size, chunk_size);
	BUG_ON(n_chunks > mem_free / chunk_size);
	return __contig_alloc_chunks(params, n_chunks);
}

struct contig_desc *contig_alloc(const struct contig_alloc_params *params, unsigned long size)
{
	struct contig_desc *ret;

	if (unlikely(size == 0))
		return ERR_PTR(-EINVAL);

	mutex_lock(&contig_lock);
	ret = __contig_alloc(params, size);
	mutex_unlock(&contig_lock);

	return ret;
}
EXPORT_SYMBOL_GPL(contig_alloc);

void __contig_free(struct contig_desc *desc)
{
	struct contig_chunk *ch, *nxt;
	unsigned int deallocated = 0;

	list_for_each_entry_safe(ch, nxt, &desc->alloc_list, node) {
		list_del(&ch->node);
		list_add(&ch->node, &inactive_chunks[ch->ddr_node]);
		deallocated += chunk_size;
		mem_allocated[ch->ddr_node] -= chunk_size;
	}
	BUG_ON(deallocated != desc->n * chunk_size);
	list_del(&desc->desc_node);
	contig_free_descriptor(desc);
}

void contig_free(struct contig_desc *desc)
{
	mutex_lock(&contig_lock);
	__contig_free(desc);
	mutex_unlock(&contig_lock);
}
EXPORT_SYMBOL_GPL(contig_free);

/*
 * Check that this is a valid desc. Ideally we'd also make sure that the calling
 * process owns the contig buffer. But for now this will do.
 */
struct contig_desc *contig_khandle_to_desc(contig_khandle_t khandle)
{
	struct contig_desc *handle = (struct contig_desc *)khandle;
	struct contig_desc *desc;

	mutex_lock(&contig_lock);
	list_for_each_entry(desc, &desc_list, desc_node) {
		if (desc == handle)
			break;
	}
	mutex_unlock(&contig_lock);

	return desc == handle ? desc : NULL;
}
EXPORT_SYMBOL_GPL(contig_khandle_to_desc);

static void __contig_chunks_remove(void)
{
	struct contig_chunk *ch, *nxt;
	int i;

	for (i = 0; i < nddr; i++)
		list_for_each_entry_safe(ch, nxt, &inactive_chunks[i], node) {
			list_del(&ch->node);
			kfree(ch);
		}
}

#ifdef CONFIG_BIGPHYS_AREA

static unsigned long __init contig_chunk_paddr(struct contig_chunk *ch, int n_chunk)
{
	return virt_to_phys(bp_buf) + chunk_size * n_chunk;
}

static int __init contig_phys_alloc(int n_chunks)
{
	bp_buf = bigphysarea_alloc(n_chunks * chunk_size);
	if (bp_buf == NULL)
		return -ENOMEM;
	return 0;
}

static void contig_phys_free(void)
{
	bigphysarea_free(bp_buf, mem_size);
}

#else

static unsigned long __init contig_chunk_paddr(int ddr_node, struct contig_chunk *ch, int n_chunk)
{
	return mem_start[ddr_node] + chunk_size * n_chunk;
}

static int __init contig_phys_alloc(int n_chunks)
{
	return 0;
}

static void contig_phys_free(void)
{ }

#endif /* CONFIG_BIGPHYS_AREA */

static int __init contig_chunks_create(int ddr_node, int n_chunks)
{
	int i;

	if (contig_phys_alloc(n_chunks))
		return -ENOMEM;

	for (i = 0; i < n_chunks; i++) {
		struct contig_chunk *ch;

		ch = kmalloc(sizeof(*ch), GFP_KERNEL);
		if (ch == NULL)
			goto err;

		ch->paddr = contig_chunk_paddr(ddr_node, ch, i);
		ch->ddr_node = ddr_node;
		list_add_tail(&ch->node, &inactive_chunks[ddr_node]);
	}
	return 0;
 err:
	__contig_chunks_remove();
	contig_phys_free();
	return -ENOMEM;
}

static int contig_open(struct inode *inode, struct file *file)
{
	struct contig_file *priv;

	priv = kmalloc(sizeof(*priv), GFP_KERNEL);
	if (priv == NULL)
		return -ENOMEM;
	INIT_LIST_HEAD(&priv->desc_list);
	file->private_data = priv;
	return 0;
}

static int contig_release(struct inode *inode, struct file *file)
{
	struct contig_file *priv = file->private_data;
	struct contig_desc *desc, *nxt;

	list_for_each_entry_safe(desc, nxt, &priv->desc_list, file_node) {
		list_del(&desc->file_node);
		contig_free(desc);
	}
	kfree(priv);
	return 0;
}

static bool contig_alloc_ok(const struct contig_alloc_params *params)
{
	switch (params->policy) {
	case CONTIG_ALLOC_PREFERRED:
		if (params->pol.first.ddr_node < 0 || params->pol.first.ddr_node > nddr)
			return false;
		break;
	case CONTIG_ALLOC_LEAST_LOADED:
		if (params->pol.lloaded.threshold < 0 || params->pol.lloaded.threshold > mem_size[0] / chunk_size)
			return false;
		break;
	case CONTIG_ALLOC_BALANCED:
		if (params->pol.balanced.threshold < 0 || params->pol.balanced.threshold > mem_size[0] / chunk_size)
			return false;
		if (params->pol.balanced.cluster_size < 1)
			return false;
		break;
	default:
		return false;
	}
	return true;
}

static long contig_alloc_ioctl(struct file *file, void __user *arg)
{
	struct contig_file *priv = file->private_data;
	struct contig_alloc_req req;
	struct contig_desc *desc;

	if (copy_from_user(&req, arg, sizeof(req)))
		return -EFAULT;
	if (req.arr == NULL)
		return -EFAULT;

	if (!contig_alloc_ok(&req.params))
		return -EINVAL;

	desc = contig_alloc(&req.params, req.size);
	if (IS_ERR(desc))
		return PTR_ERR(desc);

	if (desc->n > req.n_max) {
		contig_free(desc);
		return -EINVAL;
	}

	if (copy_to_user(req.arr, desc->arr, sizeof(*desc->arr) * desc->n)) {
		contig_free(desc);
		return -EFAULT;
	}
	req.n = desc->n;
	req.khandle = (contig_khandle_t)desc;
	req.most_allocated = desc->most_allocated;
	if (copy_to_user(arg, &req, sizeof(req))) {
		contig_free(desc);
		return -EFAULT;
	}
	list_add(&desc->file_node, &priv->desc_list);
	return 0;
}

static long contig_free_ioctl(struct file *file, contig_khandle_t __user *arg)
{
	struct contig_file *priv = file->private_data;
	struct contig_desc *del, *desc, *next;
	contig_khandle_t del_addr;
	bool found = false;

	if (get_user(del_addr, arg))
		return -EFAULT;
	del = (struct contig_desc *)del_addr;

	/* is it a valid descriptor for this file? */
	list_for_each_entry_safe(desc, next, &priv->desc_list, file_node) {
		if (desc == del) {
			list_del(&del->file_node);
			found = true;
			break;
		}
	}
	if (!found)
		return -EFAULT;
	contig_free(del);
	return 0;
}

static long contig_chunk_size_ioctl(struct file *file, void __user *arg)
{
	if (put_user(contig_chunk_size_log, (unsigned long __user *)arg))
		return -EFAULT;
	return 0;
}

static long contig_do_ioctl(struct file *file, unsigned int cm, void __user *arg)
{
	switch (cm) {
	case CONTIG_IOC_ALLOC:
		return contig_alloc_ioctl(file, arg);
	case CONTIG_IOC_FREE:
		return contig_free_ioctl(file, arg);
	case CONTIG_IOC_CHUNK_LOG:
		return contig_chunk_size_ioctl(file, arg);
	default:
		return -ENOTTY;
	}
}

static long contig_ioctl(struct file *file, unsigned int cm, unsigned long arg)
{
	return contig_do_ioctl(file, cm, (void __user *)arg);
}

static int contig_mmap(struct file *file, struct vm_area_struct *vma)
{
	int i, rc;
	struct contig_desc *desc, *itr;
	struct contig_file *priv = file->private_data;
	long unsigned paddr = PFN_PHYS(vma->vm_pgoff);
	bool found = false;

	mutex_lock(&contig_lock);
	list_for_each_entry(itr, &priv->desc_list, file_node) {
		if (itr->arr[0] == paddr) {
			found = true;
			desc = itr;
			break;
		}
	}
	mutex_unlock(&contig_lock);

	if (!found) {
		pr_info("contig_alloc: descriptor for addres %08lX not found", paddr);
		return -EFAULT;
	}


	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);

	for (i = 0; i < desc->n; i++) {
		/* pr_info("contig_mmap: paddr[%d] = %08lX\n", i, desc->arr[i]); */
		rc = remap_pfn_range(vma, vma->vm_start + i * chunk_size, PHYS_PFN(desc->arr[i]),
				chunk_size, vma->vm_page_prot);

		if (rc)
			return rc;
	}

	return 0;
}

static int __init contig_create_file(void)
{
	contig_class = class_create(THIS_MODULE, "contig_alloc");
	if (IS_ERR(contig_class))
		return PTR_ERR(contig_class);

	if (register_chrdev(CONTIG_MAJOR, "contig_alloc", &contig_fops))
		goto err_chrdev;

	if (IS_ERR(device_create(contig_class, NULL, MKDEV(CONTIG_MAJOR, CONTIG_MINOR), NULL, "contig_alloc")))
		goto err_device_create;

	return 0;

 err_device_create:
	unregister_chrdev(CONTIG_MAJOR, "contig_alloc");
 err_chrdev:
	class_destroy(contig_class);
	return -ENODEV;
}

static void contig_remove_file(void)
{
	device_destroy(contig_class, MKDEV(CONTIG_MAJOR, CONTIG_MINOR));
	unregister_chrdev(CONTIG_MAJOR, "contig_alloc");
	class_destroy(contig_class);
}

static int __init contig_init(void)
{
	int rc;
	int i;

	if (contig_chunk_size_log >= 32)
		return -EINVAL;
	chunk_size = BIT(contig_chunk_size_log);

#ifndef CONFIG_BIGPHYS_AREA
	if (!mem_start[0])
		return -EINVAL;
#endif
	if (chunk_size < PAGE_SIZE) {
		pr_err(PFX "chunk_size (0x%lx) < PAGE_SIZE (0x%lx)\n",
			chunk_size, PAGE_SIZE);
		return -EINVAL;
	}

	for (i = 0; i < nddr; i++) {
		INIT_LIST_HEAD(&inactive_chunks[i]);
		if (mem_size[i] % chunk_size) {
			pr_warn(PFX "chunk_size (0x%lx) does not divide evenly mem_size[%d] (0x%lx); discarding %ld bytes\n",
				chunk_size, i, mem_size[i], mem_size[i] % chunk_size);
			mem_size[i] -= mem_size[i] % chunk_size;
		}
		if (!mem_size[i] || !chunk_size)
			return -EINVAL;
		if (chunk_size > mem_size[i]) {
			pr_err(PFX "chunk_size (0x%lx) > mem_size[%d] (0x%lx)\n",
				chunk_size, i, mem_size[i]);
			return -EINVAL;
		}
	}

	rc = contig_create_file();
	if (rc)
		return rc;

	for (i = 0; i < nddr; i++) {
		rc = contig_chunks_create(i, mem_size[i] / chunk_size);
		if (rc)
			goto err_chunks;
	}

	return 0;

 err_chunks:
	contig_remove_file();
	return rc;
}

static void contig_exit(void)
{
	struct contig_desc *desc, *nxt;

	list_for_each_entry_safe(desc, nxt, &desc_list, desc_node) {
		__contig_free(desc);
	}
	__contig_chunks_remove();
	contig_phys_free();
	contig_remove_file();
}

module_init(contig_init)
module_exit(contig_exit)

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("allocator for memory beyond the system's physical memory");
