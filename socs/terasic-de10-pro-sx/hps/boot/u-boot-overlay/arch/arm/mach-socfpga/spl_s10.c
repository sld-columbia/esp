// SPDX-License-Identifier: GPL-2.0
/*
 * Copyright (C) 2016-2018 Intel Corporation <www.intel.com>
 *
 */

#include <hang.h>
#include <init.h>
#include <log.h>
#include <asm/io.h>
#include <asm/u-boot.h>
#include <asm/utils.h>
#include <common.h>
#include <debug_uart.h>
#include <dm.h>
#include <dm/ofnode.h>
#include <image.h>
#include <spl.h>
#include <asm/arch/clock_manager.h>
#include <asm/arch/firewall.h>
#include <asm/arch/mailbox_s10.h>
#include <asm/arch/misc.h>
#include <asm/arch/reset_manager.h>
#include <asm/arch/smmu_s10.h>
#include <asm/arch/system_manager.h>
#include <wdt.h>
#include <dm/uclass.h>

DECLARE_GLOBAL_DATA_PTR;

u32 spl_boot_device_ram(void);

#define DE10_PRO_SX_USED_BRIDGES \
	(RSTMGR_BRGMODRST_SOC2FPGA_MASK | \
	 RSTMGR_BRGMODRST_LWSOC2FPGA_MASK | \
	 RSTMGR_BRGMODRST_FPGA2SOC_MASK | \
	 RSTMGR_BRGMODRST_F2SDRAM0_MASK)

#define DE10_PRO_SX_UNUSED_F2SDRAM_RESETS \
	(RSTMGR_BRGMODRST_F2SDRAM1_MASK | \
	 RSTMGR_BRGMODRST_F2SDRAM2_MASK)

static bool de10_pro_sx_fpga_ready(void)
{
	u32 fpga_config = readl(socfpga_get_sysmgr_addr() +
				SYSMGR_SOC64_FPGA_CONFIG);

	return (fpga_config & SYSMGR_FPGACONFIG_READY_MASK) ==
	       SYSMGR_FPGACONFIG_READY_MASK;
}

static void de10_pro_sx_enable_fpga_bridges(void)
{
	if (!de10_pro_sx_fpga_ready())
		return;

	/*
	 * ESP uses HPS-to-FPGA for loader writes and F2SDRAM0 for ESP DRAM
	 * traffic. The old working SPL left all bridge reset bits deasserted,
	 * while F2SDRAM sideband status showed only F2SDRAM0 enabled.
	 */
	socfpga_bridges_reset(1, DE10_PRO_SX_USED_BRIDGES);
	clrbits_le32(socfpga_get_rstmgr_addr() + RSTMGR_SOC64_BRGMODRST,
		     DE10_PRO_SX_UNUSED_F2SDRAM_RESETS);
}

void board_init_f(ulong dummy)
{
	/* Ensure 'spl_boot_device_ram' symbol used by debugger is exported */
	int ret = spl_boot_device_ram();
	const struct cm_config *cm_default_cfg = cm_get_default_config();

	ret = spl_early_init();
	if (ret)
		hang();

	socfpga_get_managers_addr();

	/* Ensure watchdog is paused when debugging is happening */
	writel(SYSMGR_WDDBG_PAUSE_ALL_CPU,
	       socfpga_get_sysmgr_addr() + SYSMGR_SOC64_WDDBG);

	/*
	 * Enable watchdog as early as possible before initializing other
	 * component.
	 */
	if (CONFIG_IS_ENABLED(WDT))
		initr_watchdog();

	/* ensure all processors are not released prior Linux boot */
	writeq(0, CPU_RELEASE_ADDR);

	socfpga_per_reset(SOCFPGA_RESET(OSC1TIMER0), 0);
	timer_init();

	sysmgr_pinmux_init();

	/* configuring the HPS clocks */
	cm_basic_init(cm_default_cfg);

#ifdef CONFIG_DEBUG_UART
	socfpga_per_reset(SOCFPGA_RESET(UART0), 0);
	debug_uart_init();
#endif

	preloader_console_init();
	print_reset_info();
	cm_print_clock_quick_summary();

	firewall_setup();

	/* disable ocram security at CCU for non secure access */
	clrbits_le32(CCU_REG_ADDR(CCU_CPU0_MPRT_ADMASK_MEM_RAM0),
		     CCU_ADMASK_P_MASK | CCU_ADMASK_NS_MASK);
	clrbits_le32(CCU_REG_ADDR(CCU_IOM_MPRT_ADMASK_MEM_RAM0),
		     CCU_ADMASK_P_MASK | CCU_ADMASK_NS_MASK);

#if CONFIG_IS_ENABLED(ALTERA_SDRAM)
		struct udevice *dev;

		ret = uclass_get_device(UCLASS_RAM, 0, &dev);
		if (ret) {
			debug("DRAM init failed: %d\n", ret);
			hang();
		}
#endif

	mbox_init();
	de10_pro_sx_enable_fpga_bridges();

#ifdef CONFIG_CADENCE_QSPI
	mbox_qspi_open();
#endif
}
