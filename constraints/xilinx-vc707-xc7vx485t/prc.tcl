# Copyright (c) 2011-2021 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

set ip_name prc
create_ip -name prc -vendor xilinx.com -library ip -module_name $ip_name
            CONFIG.HAS_AXI_LITE_IF                      1 \
            CONFIG.RESET_ACTIVE_LEVEL                   0 \
            CONFIG.CP_FIFO_DEPTH                        32 \
            CONFIG.CP_FIFO_TYPE                         lutram \
            CONFIG.CP_ARBITRATION_PROTOCOL              0 \
            CONFIG.CP_COMPRESSION                       0 \
            CONFIG.CP_FAMILY                            7series \
            CONFIG.CDC_STAGES                           6 \
            CONFIG.VS.VS_0.START_IN_SHUTDOWN            0 \
            CONFIG.VS.VS_0.NUM_TRIGGERS_ALLOCATED       2 \
            CONFIG.VS.VS_0.NUM_RMS_ALLOCATED            2 \
            CONFIG.VS.VS_0.NUM_HW_TRIGGERS              0 \
            CONFIG.VS.VS_0.SHUTDOWN_ON_ERROR            1 \
            CONFIG.VS.VS_0.HAS_AXIS_STATUS              0 \
            CONFIG.VS.VS_0.HAS_AXIS_CONTROL             0 \
            CONFIG.VS.VS_0.HAS_POR_RM                   0 \
            CONFIG.VS.VS_0.SKIP_RM_STARTUP_AFTER_RESET  0 \
            CONFIG.VS.VS_0.TRIGGER0_TO_RM               RM_0 \
            CONFIG.VS.VS_0.TRIGGER1_TO_RM               RM_0 \
            CONFIG.VS.VS_0.RM.RM_0.SHUTDOWN_REQUIRED    no \
            CONFIG.VS.VS_0.RM.RM_0.STARTUP_REQUIRED     no \
            CONFIG.VS.VS_0.RM.RM_0.RESET_REQUIRED       no \
            CONFIG.VS.VS_0.RM.RM_0.RESET_DURATION       1 \
            CONFIG.VS.VS_0.RM.RM_0.BS.0.ADDRESS         0 \
            CONFIG.VS.VS_0.RM.RM_0.BS.0.SIZE            0 \
            CONFIG.VS.VS_0.RM.RM_0.BS.0.CLEAR           0 \
            CONFIG.VS.VS_0.RM.RM_0.BS.1.ADDRESS         0 \
            CONFIG.VS.VS_0.RM.RM_0.BS.1.SIZE            0 \
            CONFIG.VS.VS_0.RM.RM_0.BS.1.CLEAR           1 \
             ] [get_ips $ip_name]
