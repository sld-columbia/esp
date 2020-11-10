# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

xilinx_lib-clean:
	$(QUIET_CLEAN)$(RM) \
		.cxl.mti_se.version \
		.cxl.modelsim.version \
		.cxl.ies.version \
		*.log \
		*.bak \
		*.jou \
		*backup* \

xilinx_lib-distclean: xilinx_lib-clean
	$(QUIET_CLEAN)$(RM) \
		$(ESP_ROOT)/.cache/modelsim/ 	\
		$(ESP_ROOT)/.cache/xcelium/ 	\
		$(ESP_ROOT)/.cache/incisive/

.PHONY: xilinx_lib-clean xilinx_lib-distclean
