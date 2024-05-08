// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <linux/mm.h>
#include <linux/of_device.h>

#include <asm/io.h>

#include <esp.h>
#include <esp_accelerator.h>

#include "crypto_cxx_catapult.h"

#define DRV_NAME "crypto_cxx_catapult"

/* <<--regs-->> */
#define CRYPTO_CXX_CRYPTO_ALGO_REG 0x40
#define CRYPTO_CXX_ENCRYPTION_REG  0x44

#define CRYPTO_CXX_SHA1_IN_BYTES_REG 0x48

#define CRYPTO_CXX_SHA2_IN_BYTES_REG  0x4C
#define CRYPTO_CXX_SHA2_OUT_BYTES_REG 0x50

#define CRYPTO_CXX_AES_OPER_MODE_REG 0x54
//#define CRYPTO_CXX_AES_ENCRYPTION_REG 0x54
#define CRYPTO_CXX_AES_KEY_BYTES_REG   0x58
#define CRYPTO_CXX_AES_INPUT_BYTES_REG 0x5C
#define CRYPTO_CXX_AES_IV_BYTES_REG    0x60
#define CRYPTO_CXX_AES_AAD_BYTES_REG   0x64
#define CRYPTO_CXX_AES_TAG_BYTES_REG   0x68

struct crypto_cxx_catapult_device {
    struct esp_device esp;
};

static struct esp_driver crypto_driver;

static struct of_device_id crypto_device_ids[] = {
    {
        .name = "SLD_CRYPTO_CXX_CATAPULT",
    },
    {
        .name = "eb_091",
    },
    {
        .compatible = "sld,crypto_cxx_catapult",
    },
    {},
};

static int crypto_devs;

static inline struct crypto_cxx_catapult_device *to_crypto(struct esp_device *esp)
{
    return container_of(esp, struct crypto_cxx_catapult_device, esp);
}

static void crypto_prep_xfer(struct esp_device *esp, void *arg)
{
    struct crypto_cxx_catapult_access *a = arg;

    /* <<--regs-config-->> */
    iowrite32be(a->crypto_algo, esp->iomem + CRYPTO_CXX_CRYPTO_ALGO_REG);
    iowrite32be(a->encryption, esp->iomem + CRYPTO_CXX_ENCRYPTION_REG);
    iowrite32be(a->sha1_in_bytes, esp->iomem + CRYPTO_CXX_SHA1_IN_BYTES_REG);
    iowrite32be(a->sha2_in_bytes, esp->iomem + CRYPTO_CXX_SHA2_IN_BYTES_REG);
    iowrite32be(a->sha2_out_bytes, esp->iomem + CRYPTO_CXX_SHA2_OUT_BYTES_REG);
    iowrite32be(a->aes_oper_mode, esp->iomem + CRYPTO_CXX_AES_OPER_MODE_REG);
    iowrite32be(a->aes_key_bytes, esp->iomem + CRYPTO_CXX_AES_KEY_BYTES_REG);
    iowrite32be(a->aes_input_bytes, esp->iomem + CRYPTO_CXX_AES_INPUT_BYTES_REG);
    iowrite32be(a->aes_iv_bytes, esp->iomem + CRYPTO_CXX_AES_IV_BYTES_REG);
    iowrite32be(a->aes_aad_bytes, esp->iomem + CRYPTO_CXX_AES_AAD_BYTES_REG);
    iowrite32be(a->aes_tag_bytes, esp->iomem + CRYPTO_CXX_AES_TAG_BYTES_REG);
    iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
    iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);
}

static bool crypto_xfer_input_ok(struct esp_device *esp, void *arg)
{
    /* struct crypto_cxx_catapult_device *crypto = to_crypto(esp); */
    /* struct crypto_cxx_catapult_access *a = arg; */

    return true;
}

static int crypto_probe(struct platform_device *pdev)
{
    struct crypto_cxx_catapult_device *crypto;
    struct esp_device *esp;
    int rc;

    crypto = kzalloc(sizeof(*crypto), GFP_KERNEL);
    if (crypto == NULL) return -ENOMEM;
    esp         = &crypto->esp;
    esp->module = THIS_MODULE;
    esp->number = crypto_devs;
    esp->driver = &crypto_driver;
    rc          = esp_device_register(esp, pdev);
    if (rc) goto err;

    crypto_devs++;
    return 0;
err:
    kfree(crypto);
    return rc;
}

static int __exit crypto_remove(struct platform_device *pdev)
{
    struct esp_device *esp                    = platform_get_drvdata(pdev);
    struct crypto_cxx_catapult_device *crypto = to_crypto(esp);

    esp_device_unregister(esp);
    kfree(crypto);
    return 0;
}

static struct esp_driver crypto_driver = {
    .plat =
        {
            .probe  = crypto_probe,
            .remove = crypto_remove,
            .driver =
                {
                    .name           = DRV_NAME,
                    .owner          = THIS_MODULE,
                    .of_match_table = crypto_device_ids,
                },
        },
    .xfer_input_ok = crypto_xfer_input_ok,
    .prep_xfer     = crypto_prep_xfer,
    .ioctl_cm      = CRYPTO_CXX_CATAPULT_IOC_ACCESS,
    .arg_size      = sizeof(struct crypto_cxx_catapult_access),
};

static int __init crypto_init(void) { return esp_driver_register(&crypto_driver); }

static void __exit crypto_exit(void) { esp_driver_unregister(&crypto_driver); }

module_init(crypto_init) module_exit(crypto_exit)

    MODULE_DEVICE_TABLE(of, crypto_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("crypto_cxx_catapult driver");
