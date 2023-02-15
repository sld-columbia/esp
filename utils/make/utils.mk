# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

ifneq ($(UART_IP),)
ifeq ($(UART_PORT),)
$(error Please define both UART_IP and UART_PORT or neither)
endif

ttyV0:
	@socat pty,link=ttyV0,waitslave,mode=777 tcp:$(UART_IP):$(UART_PORT) &
	@sleep 1

uart: ttyV0
	@VIRTUAL_DEVICE=$$(readlink ttyV0); minicom -p $$VIRTUAL_DEVICE;

ifneq ($(DISPLAY),)
xuart: ttyV0
	@VIRTUAL_DEVICE=$$(readlink ttyV0); (xterm -e "minicom -p $$VIRTUAL_DEVICE" &);
else
xuart:
	$(MAKE) uart
endif

else
uart:
	@echo "*** UART_IP and UART_PORT are not defined. Open a serial console manually on the target UART device ***"
	@echo "*** If the FPGA board is connected to your computer, connect to the corresponding '/dev/ttyUSBx' device ***"

xuart: uart
endif


ifneq ($(SSH_IP),)

ifeq ($(SSH_PORT),)
SSH_PORT = 22
endif

ssh:
	@ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $(SSH_PORT) root@$(SSH_IP)

else

ssh:
	@echo "*** SSH_IP and SSH_PORT are not defined. Look for the IP addressed leased to the ESP instance at the end of the boot process ***"
	@echo "*** If you are on the same network as the FPGA boar, the default SSH_PORT is 22 ***"

endif

.PHONY: uart xuart ssh
