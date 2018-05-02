#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "change_detection.h"

#define DRV_NAME	"change_detection"

#define CHDET_REG_NUM_ROW	0x40
#define CHDET_REG_NUM_COL	0x44

#define CHDET_MAX_ROW 2048
#define CHDET_MAX_COL 2048
#define CHDET_MODELS  5
#define CHDET_FRAMES  5

#define CHDET_TRAINING_SIZE(__row, __col) ((__row) * (__col) * 12 * CHDET_MODELS)
#define CHDET_INPUT_SIZE(__row, __col) ((__row) * (__col) * 2 * CHDET_FRAMES)
#define CHDET_OUTPUT_SIZE(__row, __col) ((__row) * (__col) * CHDET_FRAMES)

#define CHDET_BUF_SIZE(__row, __col)			\
	(CHDET_TRAINING_SIZE(__row, __col) +		\
		CHDET_INPUT_SIZE(__row, __col) +	\
		CHDET_OUTPUT_SIZE(__row, __col))

#define CHDET_MAX_BUF_SIZE CHDET_BUF_SIZE(CHDET_MAX_ROW, CHDET_MAX_COL)


//    Frames  = 5
//    Rows    = 16
//    Columns = 16
//    Models  = 5
// Training: 
//    mu, sigma, tau = 3 x Rows x Columns x Models = 3840 (32 bits)
// Input: 
//    frame = Rows x Columns x Frames = 1280 (16 bits)
// Output: 
//    golden foreground = Rows x Columns x Frames = 1280 (8 bits)
// Total 32bit words: 
//    input = 4480
//    output = 320
//    total = 4800
// Memory allocated = 5120

struct chdet_device {
	struct esp_device esp;
	size_t max_size;
};

static struct esp_driver chdet_driver;

static struct of_device_id change_detection_device_ids[] = {
	{
		.name = "SLD_CHANGE_DETECTION",
	},
	{
		.name = "eb_00e",
	},
	{ },
};

static int chdet_devs;

static inline struct chdet_device *to_chdet(struct esp_device *esp)
{
	return container_of(esp, struct chdet_device, esp);
}

static void chdet_prep_xfer(struct esp_device *esp, void *arg)
{
	struct change_detection_access *access = arg;

	esp->coherence = access->esp.coherence;
	iowrite32be(access->rows, esp->iomem + CHDET_REG_NUM_ROW);
	iowrite32be(access->cols, esp->iomem + CHDET_REG_NUM_COL);
}

static bool chdet_xfer_input_ok(struct esp_device *esp, void *arg)
{
	struct change_detection_access *access = arg;

	if (access->rows > CHDET_MAX_ROW ||
		access->cols > CHDET_MAX_COL ||
		access->rows != access->cols)
		return false;
	return true;
}

static int chdet_probe(struct platform_device *pdev)
{
	struct chdet_device *chdet;
	struct esp_device *esp;
	int rc;

	chdet = kzalloc(sizeof(*chdet), GFP_KERNEL);
	if (chdet == NULL)
		return -ENOMEM;
	esp = &chdet->esp;
	esp->module = THIS_MODULE;
	esp->number = chdet_devs;
	esp->driver = &chdet_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	chdet->max_size = round_up(CHDET_MAX_BUF_SIZE, PAGE_SIZE);
	chdet_devs++;
	return 0;
 err:
	kfree(chdet);
	return rc;
}

static int __exit chdet_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct chdet_device *chdet = to_chdet(esp);

	esp_device_unregister(esp);
	kfree(chdet);
	return 0;
}

static struct esp_driver chdet_driver = {
	.plat	= {
		.probe	= chdet_probe,
		.remove	= chdet_remove,
		.driver	= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = change_detection_device_ids,
		},
	},
	.xfer_input_ok	= chdet_xfer_input_ok,
	.prep_xfer	= chdet_prep_xfer,
	.ioctl_cm	= CHANGE_DETECTION_IOC_ACCESS,
	.arg_size	= sizeof(struct change_detection_access),
};

static int __init chdet_init(void)
{
	return esp_driver_register(&chdet_driver);
}

static void __exit chdet_exit(void)
{
	esp_driver_unregister(&chdet_driver);
}

module_init(chdet_init)
module_exit(chdet_exit)

MODULE_DEVICE_TABLE(of, change_detection_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("change_detection driver");
