include $(DRIVERS)/driver.mk

Module.symvers:
	$(MAKE) -C $(ESP_CORE_PATH) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH)
	cp $(ESP_CORE_PATH)/$@ .
