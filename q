[33mcommit d7786fd7ba5592740f52cba67bf2745017f7ff5f[m
Author: Aparna Muraleekrishnan <am5964@columbia.edu>
Date:   Fri Apr 28 08:22:11 2023 -0400

    - dma_read_ctrl changes to accelerator, socket and dma controller
    - userspace functions defined for writing dma index table
    - changes to userspace app for testing
    
    Signed-off-by: Aparna Muraleekrishnan <am5964@columbia.edu>

[33mcommit cdcc8bf7dc2f7d905dea3055d282840755f428a1[m
Author: Aparna Muraleekrishnan <am5964@columbia.edu>
Date:   Fri Mar 31 11:34:56 2023 -0400

    Phase1: DMA mode toggle after every transaction : done
    
    Signed-off-by: Aparna Muraleekrishnan <am5964@columbia.edu>

[33mcommit 25874ebea596a9bb3c7be8af18b37d2c63d6cd57[m
Author: Aparna Muraleekrishnan <am5964@columbia.edu>
Date:   Fri Mar 31 04:31:02 2023 -0400

    changes to dma engine
    
    Signed-off-by: Aparna Muraleekrishnan <am5964@columbia.edu>

[33mcommit b146f61d6b7b3cb14a9537e48167a7ca5c7ad7e8[m
Author: Aparna Muraleekrishnan <am5964@columbia.edu>
Date:   Fri Mar 31 04:28:09 2023 -0400

    toggle
    
    Signed-off-by: Aparna Muraleekrishnan <am5964@columbia.edu>

[33mcommit 793393e30283bf0245f4d0fe9abba8186806fd22[m
Merge: 8b85c53 8dcc9f0
Author: apm98 <113757960+apm98@users.noreply.github.com>
Date:   Fri Mar 31 04:24:45 2023 -0400

    Merge branch 'sld-columbia:master' into dma-reconfig-phase1

[33mcommit 8b85c535559916a7a3f8a6d8c3efe005215aab3b[m
Author: Aparna Muraleekrishnan <am5964@columbia.edu>
Date:   Fri Mar 31 04:11:14 2023 -0400

    toggle app
    
    Signed-off-by: Aparna Muraleekrishnan <am5964@columbia.edu>

[33mcommit 8dcc9f07ac85558538986f5084745146358cb3a4[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Wed Feb 8 17:24:22 2023 -0500

    :bug: fix in apb2jtag to get Leon3 sim to compile

[33mcommit bac014463de655998f502bc276615ac898714380[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Thu Feb 16 15:54:49 2023 -0500

    add fft2_minimal and synth_p2p example apps

[33mcommit 3b5a35912c0be290a32f2e30673543cc2b5f41f4[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Wed Feb 8 17:24:22 2023 -0500

    :bug: fix in apb2jtag to get Leon3 sim to compile

[33mcommit fedf52c3f344c6d09d5036c4f6342f9f7b035246[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Fri Feb 3 15:41:37 2023 -0500

    Update release notes for 2023.1.0 (#186)

[33mcommit 2deb8316db73906f4c94e875526d08232317e50f[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Fri Feb 3 10:33:16 2023 -0500

    add empty inferred/verilog folder to remove warnings

[33mcommit d0e52ff2bf4d52a0120bbdfeacb75ae845311f98[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Fri Feb 3 10:23:57 2023 -0500

    minor cleanup of asic soc design folders
    
    -epochs0-gf12: fix defconfig
    -esp_asic_generic: uncomment vsim.tcl to fix JTAG simulation
    -esp_asic_generrric: fix whitespace in fpga_proxy_top.vhd

[33mcommit db033954b60430446a278abe7c0811e6fd15e902[m
Author: Kuan-Lin Chiu <chiu@cs.columbia.edu>
Date:   Wed Feb 1 01:59:25 2023 -0500

    Update Copyright year to 2023

[33mcommit 6c9514aadbb1ae1179ece24d33804e68b0333e6f[m
Author: Kuan-Lin Chiu <chiu@cs.columbia.edu>
Date:   Wed Feb 1 01:24:25 2023 -0500

    Update toolchain scripts:
    - change the default target folder
    - temporary change the git config

[33mcommit 7f4be8bb9918f0c4f0be0b076488ddad66406538[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Mon Jan 30 16:53:21 2023 -0500

    :sparkles: new Sinkhorn (Stratus HLS) and SVD (Vivado HLS) accelerators  (#185)
    
    -from Eichler, ICCD 2021 https://sld.cs.columbia.edu/pubs/eichler_iccd21.pdf
    -for questions, contact guyeichler@cs.columbia.edu
    
    ---------
    
    Co-authored-by: GuyEichler <guyeichler@cs.columbia.edu>

[33mcommit b54312e1ad7d79c36bfc5e37641e9f26029afabe[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Tue Jan 24 18:33:28 2023 -0500

    :bug: fix ariane cacheable length for accelerator and ethernet functionality with and without cache hierarchy enabled

[33mcommit b2c40950a5cafe8e3e7c38c12353ffc79b82ffff[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Thu Jan 19 12:47:10 2023 -0500

    :bug: fix erroneous edit to noc2ahbmst

[33mcommit 705fa6353b1a6b505fa4ce56f3f94507d255c65b[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Thu Jan 19 12:45:20 2023 -0500

    allow coexistence of ethernet and IO link for ASIC designs (#183)
    
    -changes to I/O tile to allow both iolink and Ethernet
    -add new ahbslv2iolink proxy to drive iolink from Ethernet master
    -new dual-FPGA setup for esp_asic_generic that supports iolink control and memory access from an FPGA proxy
    
    Co-authored-by: biruk <forbiruk@gmail.com>

[33mcommit 18742636a80047910fef21c58566b54e0b187db7[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Sep 1 08:59:34 2021 -0400

    :sparkles: new custom I/O Link for ASIC designs
    
    Co-authored-by: Joseph Zuckerman <jzuck@cs.columbia.edu>

[33mcommit 2b9e5e6e36e29c8194b329e422fb121602fe1b95[m
Author: gabriele tombesi <gt2448@columbia.edu>
Date:   Wed Oct 19 16:53:29 2022 -0400

    Updated ASIC Testing infratructure (#177)
    
    - Enable FPGA deployment of ASIC testing proxy with constraints and synthesis targets
    - Add FPGA emulation option for ASIC designs with dual-FPGA testing setup
    - Improvements to JTAG-based debug unit and accompanying testing flow
    
    Co-authored-by: Joseph Zuckerman <jzuck@cs.columbia.edu>

[33mcommit 6c107a4a6c73b42617fd0f992d6370f8b4fb2099[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Sat Oct 15 20:30:48 2022 -0400

    :bug: fix CONFIG_JTAG_EN in defconfig files

[33mcommit 6f784cf55357c1df7f1e05c53370c687a0ccb4d8[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Sat Oct 15 20:28:37 2022 -0400

    :bug: fix defines in epochs0-gf12 Makefile

[33mcommit cbc8d6876514a9555e8b16c8337ca23f21959484[m
Author: Gabriele Tombesi <gt2448@columbia.edu>
Date:   Mon Oct 10 17:56:37 2022 -0400

    Add matchlib_toolkit submodule and clean-up Catapult SystemC flow

[33mcommit adc561376dd444e8dee52125db4c32d4648b6589[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Fri Sep 30 16:22:48 2022 -0400

    add minimal technology-independent ASIC design folder

[33mcommit 3ebe6d0e383f930b576df17c90dd92c91918cd7c[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Sep 28 00:47:26 2021 -0400

    NVDLA: different verilog flist for ASIC and FPGA
    
    Co-authored-by: Joseph Zuckerman <jzuck@cs.columbia.edu>

[33mcommit 9405f858a79d8ecd7470cd1c631e2fcd4bb62930[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Thu Sep 29 14:32:07 2022 -0400

    :bug: fix xcelium support
    
    -fix ASIC issue by disabling timing checks

[33mcommit b0921a51b71a121bffa397f781aae6b6dc5cd3b2[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Nov 9 19:46:56 2021 -0500

    :bug: fix AHB-related comb loops in CPU tile

[33mcommit c157a090c2fde299cf944f3bcc8a89dd76d76a26[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Nov 4 03:37:08 2021 -0400

    ahbslv2noc: keep into account HTRANS_BUSY for sending data to ahbs_remote queues

[33mcommit 564af5de8e720fe6a76b6432be941052bce3777f[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Nov 1 05:03:10 2021 -0400

    fix genus warnings
    
    Co-authored-by: Joseph Zuckerman <jzuck@cs.columbia.edu>

[33mcommit 4487d97219f5f39240719d8bdf78911f81fc103a[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Sep 23 14:37:42 2021 -0400

    add HAS_SYNC generic to asic_tile_* to enable NoC synchronizers
    
    Co-authored-by: Joseph Zuckerman <jzuck@cs.columbia.edu>

[33mcommit 16e9b4f0dc8d3c1e9322c63b330f3a845dc642dc[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Sun Jun 12 01:17:10 2022 -0400

    Improve flexibility of ASIC clocking strategy
    
    -enable 1 global DCO
    -enable only using external clock
    -modify reset hierarchy to accomodate all strategies
    
    Co-authored-by: Davide Giri <davide_giri@cs.columbia.edu>

[33mcommit ab1f42ec7c332962dc2a5dd9a65284d7ab525b6d[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Thu Sep 1 14:47:16 2022 -0400

    make JTAG test unit optional and for ASIC only
    
    Co-authored-by: Davide Giri <davide_giri@cs.columbia.edu>

[33mcommit 6cb511b30880006a158d18072b1db29da60d1155[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Jun 8 21:23:03 2021 -0400

    fix Genus compilation error in esp_init.vhd

[33mcommit 67ae3ee54d5aac45e6e9675617068f06351e5c26[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Thu Sep 1 12:53:37 2022 -0400

    Expand ESP SoC config options and reduce GRLIB config options
    
    -Ethernet IP and MAC now configurable from GUI
    
    Co-authored-by: Davide Giri <davide_giri@cs.columbia.edu>

[33mcommit dfff283a785c3cfcec304a5fcc3d6956290a82e2[m
Author: Vignesh Suresh <77220542+vsuresh95@users.noreply.github.com>
Date:   Wed Aug 10 11:38:34 2022 -0500

    Spandex integration fixes and performance updates (#163)

[33mcommit 7620693db0978ffa2cfe8999b409395552884357[m
Author: gabriele tombesi <gt2448@columbia.edu>
Date:   Mon Aug 1 17:42:58 2022 -0400

    :sparkles: New accelerator design flow with SystemC and Catapult HLS (#165)

[33mcommit f316410a6e0421482101f63158c7cf2dc1e1bf2e[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Tue Jul 19 11:38:06 2022 -0400

    Fixes to SLM+DDR tile  (#169)
    
    -use correct clocks in asic_tile_slm_ddr
    -add configurable delay cells on dco outputs in tile_slm
    -fix ahb2bsg_dmc to support accelerator execution to slm_ddr tile
    -modify delay cell configuration from CSRs

[33mcommit 58a3c20bae0ee5a4203fca705fc5758c44efb7cc[m
Author: Kuan-Lin Chiu <chiu@cs.columbia.edu>
Date:   Tue Apr 12 16:09:30 2022 -0400

    Add a comment and copyright

[33mcommit b57413b751211f84abe9859bb7d8930e183631c0[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Sat Sep 10 18:44:25 2022 -0400

    :bug: override URLs for broken git submodules

[33mcommit a8863f80518e6c86ee922445d22c194b827eaf02[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Mon Mar 7 23:23:57 2022 -0500

    Update CHANGELOG.md and README.md for 2022.1.0 (#154)

[33mcommit 3034e55fc3ef434d350a61f5277179137e2a8e5a[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Mon Mar 7 19:22:51 2022 -0500

    libesp: don't spawn pthreads for single accelerator invocations

[33mcommit 092e73d5752ef98712f4ef90598997cc99345cb2[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Mon Mar 7 19:20:59 2022 -0500

    :bug: fix FFT applications to pass validation

[33mcommit ae9955e8b9929a0b3c57383cbd48769e915c47a1[m
Author: Kuan-Lin Chiu <52798470+klchiu@users.noreply.github.com>
Date:   Wed Feb 23 07:39:58 2022 +0800

    Improve nightvision accelerator (#130)
    
    * Improve nightvision accelerator
    
    - Change image size to 120x160 as the default
    - The hardware can support up to 480x640 image size
    - Fix baremetal application
    - Fix linux application
    - Codes are reformatted by using clang-format-12

[33mcommit 7228d7784ecf5487414307679bd2d41ebd21a4a9[m
Author: Kuan-Lin Chiu <chiu@cs.columbia.edu>
Date:   Sun Feb 20 15:54:35 2022 -0500

    Update Copyright for submodules

[33mcommit 79f6058a922f512ca2246922085784815576f0e8[m
Author: Kuan-Lin Chiu <chiu@cs.columbia.edu>
Date:   Sun Feb 20 00:53:34 2022 -0500

    Update Copyright year to 2022

[33mcommit cef5edbf224ce97dec52543e39864bf9a152114a[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Sat Feb 19 12:18:44 2022 -0500

    toolchain: don't require sudo for local tmp directory

[33mcommit cdaba8a0a327f12281101c3477699366ebb656f6[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Sat Feb 19 12:16:41 2022 -0500

    tie fpga-link signals to 0 for designs with ddr controller

[33mcommit 31dc2fccc442b1f060f61267f2ef1f8d207dcbdf[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Mon Feb 14 16:50:01 2022 -0500

    software updates for Ariane SMP
    
    -pass correct FPGA frequency to openSBI
    -enable SMP execution through bootloader only when SMP mode is defined

[33mcommit 97a63f3d580e6ccbc22cf4df6e8f96bc96b3c58c[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Fri Aug 6 14:26:07 2021 -0400

    switch from riscv-pk to opensbi 0.6

[33mcommit ceb52b7e9231c3e9e790a330464f9d31c6f14afd[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Wed Jul 28 19:03:36 2021 -0400

    ariane/linux: change config files to mitigate RCU stall

[33mcommit 7f60305ff561159468e8150bf64e6bf184333be6[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Mon Jun 28 11:35:53 2021 -0400

    add riscv amos component for clint

[33mcommit 70844360ebb71ec6f882037b55193e8b0df5fbaa[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri May 28 18:07:09 2021 -0400

    extend ariane cacheable region

[33mcommit 56e88b1b2f9a93554b6c155918db328d1bfff2b3[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Fri May 28 17:22:03 2021 -0400

    :sparkles: HW support for SMP with risc-v Ariane
    
    - invalidate L1 caches with AXI-ACE snoop address channel
    - flush L1 of Ariane when L2 is flushed
    - caches: move PUTACK to RSP plane from FWD
    - hold invalidation in adapter if pending read request
    - serve forwards from L2 between LR/SC

[33mcommit 0ab9c57eea11b8e22dfa3a439bb991538b4a866f[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Mon Feb 14 12:22:20 2022 -0500

    :bug: fix updated asic_tile_slm_ddr for xcelium

[33mcommit 6a11d9ba38373079f27e33a030b97717022bd3ca[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Oct 16 03:11:42 2021 -0400

    :bug: fix ext2ahbm send_data state in FPGA proxy

[33mcommit 024be3701d44ec38405296ad67af0f3b6d5f6204[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Oct 15 07:12:22 2021 -0400

    :bug: fix send_data state of mem2ext proxy

[33mcommit ddd09458330c750727bdf60bfe3338f576fdd4dd[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Sat Jan 29 21:54:24 2022 -0500

    :bug: fix bug in fft2_stratus app

[33mcommit 96ae4452cffeaf9898e0187c65a333dbc349d808[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Fri Jan 28 18:00:12 2022 -0500

    add SLM tile baremetal test with CPU R/W

[33mcommit bddeadf1347011e58401e26f51e617ec650dc333[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Fri Jan 28 17:42:52 2022 -0500

    esp_acc_dma: insert register between DMA FSM and acc rst
    
    -fixes bug where a glitch through states causes an erroneous reset
    
    Co-authored-by: Davide Giri <davide_giri@cs.columbia.edu>

[33mcommit 0eece1237797324aa365c26fd5e7a2980c94b457[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Fri Jan 28 16:10:44 2022 -0500

    :bug: distinguish CPU_DMA for SLM tile w/o overwriting reserved bits

[33mcommit 9dcea184d9afc60ba7bb2e44f2d9edfca18fe8a4[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Oct 13 05:13:34 2021 -0400

    remove inferred latch in tile_cpu

[33mcommit 28e14f360225a20f6566864dc3c738bf86428b71[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Oct 5 01:58:49 2021 -0400

    l2 wrapper: fix incomplete sensitivity list

[33mcommit fd44bfe8be35e436317d3d6d0edae9d614301de2[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Sep 29 16:55:35 2021 -0400

    socketgen: list accelerators in alphabetical order

[33mcommit 4b5808b966812980b084de23e41ae5bbeac63575[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Fri Jan 28 15:53:47 2022 -0500

    comment out extra code in inferred async fifo
    
    Co-authored-by: maico <mcassel@cs.columbia.edu>

[33mcommit 4b829531eae598dbe5e5bc57fcc4cfd68d2849ad[m
Author: J-D Wellman <jdwellman@yahoo.com>
Date:   Thu Apr 15 09:20:34 2021 -0400

    :sparkles: add fft2_stratus accelerator

[33mcommit 5bcb740aeafe80470930f76e32e139188a0b2cbe[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Thu Jan 27 11:13:48 2022 -0500

    :bug: fix overflow for max transaction length in axislv2noc
    
    Co-authored-by: biruk <forbiruk@gmail.com>

[33mcommit da4a66a1eb9cdff7a58e5f9b6d17a8d22ceb0a7e[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Wed Jan 26 23:59:43 2022 -0500

    enable coherence mode selection for third-party accelerators
    
    -supports the non-coherent-DMA, LLC-coherent DMA, and coherent-DMA modes
    -fixes bug with third party accelerators on systems with FPGA link for memory access
    -add NVDLA baremetal application with coherence mode selection
    
    Co-authored-by: Davide Giri <davide_giri@cs.columbia.edu>

[33mcommit 1961715c85135d72f669901147de13dba15c1733[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Mon Jan 24 23:34:30 2022 -0500

    fft_stratus acc: add batching and ping-pong buffering

[33mcommit 4b4babd6a19d65de4ecfb1686e7cbd488663763d[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Sun Jan 23 19:49:19 2022 -0500

    monitors API: make accelerator monitors consistent with others

[33mcommit da761fd2b96a32d44fee4e6d47c4fcd28c500d75[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Wed Jun 23 18:21:43 2021 -0400

    :sparkles: new monitors API for performance evaluation
    
    -new hardware implementation of "free-running" monitors
    -software API (baremetal and Linux) for reading hardware monitors
    -sample applications with API for baremetal and Linux
    -generation of software include files that provide SoC layout info
    -new example baremetal application folder

[33mcommit 6cba4687b2f0568bbc421ffe2d6cff5396c12b06[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Sep 22 17:55:07 2021 -0400

    :bug: fix of extension of acc regs from 14 to 48

[33mcommit b49e7030fe11efb3dbcf52a2b750f60701c8ba77[m
Author: Kuan-Lin Chiu <52798470+klchiu@users.noreply.github.com>
Date:   Wed Aug 18 10:51:02 2021 -0400

    Add gitignore for files generated by enabling python (#125)

[33mcommit e5c39ec5462102049218f92496151dd053e10c66[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Aug 16 10:17:58 2021 -0400

    extend custom config regs for accelerators from 14 to 48

[33mcommit 14717876d061d45197e5ca4e4eefa67b61dc091c[m
Author: Kuan-Lin Chiu <52798470+klchiu@users.noreply.github.com>
Date:   Wed Aug 4 08:32:08 2021 -0400

    Add support of python3 (#124)
    
    - for RISC-V 64 bit only
    - add buildroot config file for python
    - add busybox config file for python
    - use GCC9
    - update build_riscv_toolchain.sh script

[33mcommit 244ff73f4860582ec6ae609dad46ec98bc0ec1fd[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 4 08:06:17 2021 -0400

    rtl/caches/llc_wrapper.vhd: fix comment

[33mcommit 11cea4c999b8ce6ea8c34a1916a7bcd6f52fd244[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Jul 23 11:46:37 2021 -0400

    :bug: fix multifft app so it passes validation

[33mcommit a23bd5d3ccef8dd21390ed990028350033b98ef6[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Thu Jul 22 18:25:24 2021 -0400

    :bug: fix multifft P2P mode by making all non-coherent

[33mcommit 3abb43a57b75b3f355e2ec556fd7bf0d1d0d75af[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Thu Jul 22 18:24:20 2021 -0400

    ESP GUI: make LLC SETS refer to a partition for all implementations

[33mcommit 69fd3ee03a4954ca9aaea49846da9c8901401aa5[m
Author: maico <mcassel@cs.columbia.edu>
Date:   Wed Jul 14 10:16:52 2021 -0400

    add reset synchronous to the reading clock into async_fifo

[33mcommit 71398cc0e108c55f61ff95443b786fb594f07c27[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Jul 14 13:40:07 2021 +0200

    :sparkles: add basic RTL accelerator design flow (#123)

[33mcommit 1e307b4ed47b267c837af89c09c7e1890cb9bf99[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Tue Jun 29 16:36:36 2021 -0400

    :bug: remove erroneous arguments from cholesky cfg

[33mcommit 72a57868d995f9fc22ae4991cf7e718020a5a723[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Jun 29 15:45:26 2021 -0400

    :bug: update accgen baremetal app templates with new probe args

[33mcommit adcd7270efacbeb94839ff9d500ab54c62f4e466[m
Author: maico <mcassel@cs.columbia.edu>
Date:   Fri Jun 4 10:32:39 2021 -0400

    Modify tile hierarchy: move NoC and JTAG to the tile top

[33mcommit 8cf45b4c45d354c692ef2e94ec79d211de9dc31a[m
Author: Luca Piccolboni <piccolboni@cs.columbia.edu>
Date:   Tue Jun 8 09:47:27 2021 -0400

    remove duplicated flag in common.tcl (Vivado HLS)

[33mcommit fb4e94149d805ae11ce093b549c1e92e9541867d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Jun 7 19:43:27 2021 -0400

    minor patch to fix Xcelium compilation

[33mcommit f61756bff68462d70c5ba45642b2efdb0294d34c[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Jun 1 17:10:29 2021 -0400

    Bump riscv-pk submodule and update bare-metal probe library

[33mcommit 878b2e899ca4e07004ba5a698a14ccdcfa1476ac[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon May 31 12:05:05 2021 -0400

    :bug: mem_id range for tile_mem should account for # of SLM tiles

[33mcommit c6933b523721c09f76a2373c4c84b2349eed338e[m
Author: Giuseppe Di Guglielmo <giuseppe@cs.columbia.edu>
Date:   Wed May 26 14:16:04 2021 -0400

    use local path for temporary directory of toolchains installation scripts
    
    - This solves issue #110

[33mcommit 33e9b2302284256b1c19842924a6faccdf33d7e7[m
Author: Kuan-Lin Chiu <chiu@cs.columbia.edu>
Date:   Wed Apr 21 18:24:24 2021 -0400

    :bug: fix typos in riscv_busybox.config

[33mcommit 4459a0c7cff9bb9a66b0a5458054494b3ce33819[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 19 14:13:24 2021 -0400

    :bug: set src_/dst_offset in conv2d_stratus accelerator Linux driver

[33mcommit bf468baa8055f71fb88197168524900922081f50[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 19 12:36:41 2021 -0400

    :bug: set src_/dst_offset in gemm_stratus accelerator Linux driver

[33mcommit a9effc5bcde86bb3c04bf4798b775fc14ab919c0[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Mon Feb 14 12:05:01 2022 -0500

    :bug: fix asic_tile_slm_ddr for xcelium compilation

[33mcommit 0bb638f5402104b91fde786dda30cd587e591c79[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed May 12 11:48:29 2021 -0400

    Update CHANGELOG (#116)

[33mcommit dffff05d4e958276e79651cd2d418593279f59eb[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu May 13 00:23:42 2021 -0400

    :bug: fix install target of Makefile for hls4ml flow

[33mcommit 5b541ee278c61e8ab314d2ff1f9b5a3f0f7eea67[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 12 23:31:12 2021 -0400

    :bug: fix multifft app

[33mcommit 1bfde714d7685d80dd10e7763179236b46e092c7[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue May 11 21:55:56 2021 -0400

    add GeMM accelerator designed with the Stratus HLS flow

[33mcommit f210658847e0b6a22c41037e958e5efd2edd3e1c[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue May 11 21:54:48 2021 -0400

    add 2D Convolution accelerator designed with the Stratus HLS flow

[33mcommit 3e88cdba8821662ce74471936e18a5f1a1ac914a[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue May 11 21:51:50 2021 -0400

    accelerators/stratus_hls/common: add utilities

[33mcommit 984397e55f477177de5a6d7c4a596a8c0c4782c1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 13 00:03:07 2021 -0400

    update copyright info

[33mcommit c358b4754b514a66e386435eb0597b4b8fe4a935[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 6 14:15:24 2021 -0400

    ESP core drivers: enable L2 and LLC flush on RISC-V

[33mcommit b8d71471f3e7d1eae3eec915deb9bc027c42e280[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon May 10 12:23:06 2021 -0400

    add beta warning for Spandex support to ESP GUI

[33mcommit b26a03008abf03da38c6ae71529658c9f7efeda4[m
Author: Vignesh Suresh <vv15@illinois.edu>
Date:   Fri Apr 23 14:23:03 2021 -0500

    fence implementation for spandex l2

[33mcommit c35556d0bbe881505ef36f38fd75d6217394501a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 21 18:36:36 2021 -0400

    Use Xcelium as default simulator for Stratus HLS accelerators

[33mcommit e3f691f71c09ac075746926f55838bd801b2da7b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 20 14:46:20 2021 -0400

    :bug: fix AXI BRESP on store conditional

[33mcommit 1c1df9fdeff2f1335765e71c660fd6088602d563[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 20 13:47:24 2021 -0400

    use larger RESERVED_WIDTH to allow more than 16 distinct interrupt lines

[33mcommit 77fb076e1986642763ef66694dcda026760a2853[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 23 16:15:21 2021 -0400

    Update software to detect when Spandex caches are present

[33mcommit c08a2be5f5cc9bcaddc18a2aa5535a9754e43c92[m
Author: Zeran Zhu <zzhu35@illinois.edu>
Date:   Wed Mar 31 21:17:31 2021 -0500

    Add Spandex caches

[33mcommit d69947542487987f3fe7f7184b0b1934093ab8a0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 6 11:56:43 2021 -0400

    asic_tile_slm_lpddr: break record for hierarchical synthesis flow

[33mcommit ddef20119722898a063ea40ec456de203f3b1937[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 26 16:03:33 2021 -0400

    bsg_dmc: fix compilation error for unsupported 32 bit bus

[33mcommit 6126028399d45b9553a4fb5296c974ca5f25f173[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 22 11:14:32 2021 -0500

    Add bsg_dmc source files for Genus synthesis

[33mcommit a8460d7e0783fbd02881242f5786a48d36e18869[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 10 10:54:10 2021 -0500

    fix default DCO clock frequency for acc tiles; slow down test DCO clock div for all tiles

[33mcommit c689c4dc9a3302c2d476dbcf8cf53a5efac7d829[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun Jan 31 15:51:55 2021 -0500

    ahbram: use large banks for SLM tiles and small banks for bootrom to preserve existing floorplan of I/O tile

[33mcommit 957c3710185e35269e1a6904073ce7a463ef8d18[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Tue Feb 9 18:07:38 2021 -0500

    add support for RISCV atomic instructions
    
     - Ariane axi_risv_atomics module sets the lock on the axi bus for both LR/SC and amos
     - L2 must process instructions in between the read and write atomics
     - Must allow a second request to the same set if the first is a pending atomic and the second is an instruction
     - L2 must reply with a failure code (OKAY instead of EXOKAY) if it receives a write atomic and there is not currently an ongoing atomic, this means we terminated the atomic because of a load/store
     - The above required another channel on the interface of the L2
     - Modify L2 wrapper to wait for the cache’s response in the case of a write atomic
     - Ariane axi_riscv_atomics module forwards write response from L2 to the core

[33mcommit 58aa24bf05ca3e56bf122c93a0530a26fdfce674[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 14 18:10:03 2021 -0500

    add support for bsg_dmc using SLM tile with LPDDR I/O

[33mcommit 3c519e100a9fa9379ab91e5d7cb43adb48528211[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 13 14:42:06 2021 -0500

    add SLM tile support for GF12

[33mcommit 5cb4de31904f72a9990f3e2f4abc954e545774d9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jan 11 15:10:37 2021 -0500

    genus.mk: fix vlog compilation flages

[33mcommit fca4ac673668728db7f935c7ecb60fa29789bb36[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jan 11 15:06:20 2021 -0500

    update GF12 componenets esp-caches and DCO

[33mcommit 68e3923531461e8eb762e45b4d916a562a3ae72a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 6 10:44:53 2021 -0500

    make SDF backannotation more flexible using design-specific Modelsim script

[33mcommit 0ea074068addf9417a38c9fa55782d7404b9943b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 6 10:43:39 2021 -0500

    :bug: fix jtag trace generation script

[33mcommit c4688d18c3bb81cccc3a9880950667659b4fb744[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Dec 16 14:34:51 2020 -0500

    Add example design for ASIC flow
    
      ** This design example requires access to GF12 standard cells library and SRAM generator **
      - add ESP tile wrappers for ASIC flow w/ DCO and per-tile reset generator
      - add epochs0-gf12 SoC design

[33mcommit 74188d37efdc05207f051896fa9e9ec9b236e03a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Nov 13 16:07:37 2020 -0500

    Add scripts to generate PAD location configuration package for ASIC flow

[33mcommit 2bbbe2467ccc469c49d736b19f0231e0b8a7037d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Dec 16 14:10:22 2020 -0500

    add basejump submodule to import the LPDDR controller with simulation model

[33mcommit 158f901a8b7f3399b97180db6514cea862243a40[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Fri May 7 21:03:33 2021 -0400

    add cholesky accelerator for Stratus HLS flow (#113)
    
    Co-authored-by: Pratyush Agrawal <pa2562@columbia.edu>

[33mcommit ead1e8a158aa14ff46d9a9fbb707a59cfeae6db0[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon May 10 17:27:43 2021 -0400

    add/update license for mriq_stratus accelerator

[33mcommit d994018194c36c4ad70ec406e57c9b3267bc959d[m
Author: Pei Liu <pl2748@columbia.edu>
Date:   Thu Jan 28 09:39:37 2021 -0500

    add MRI-Q accelerator designed with the Stratus HLS flow (#112)

[33mcommit a2f785a0052582e30286a59cdc73c733c25eec41[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri May 7 10:58:42 2021 -0400

    fix Xcelium elaboration target (#106)

[33mcommit 8d113c5b18da555680395b1ee5432a836a97859c[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu May 6 12:44:42 2021 +0100

    README.md: add Zenodo DOI badge

[33mcommit 200e92ed3316f7a5ecf4d8cb1fdbbd9042e2ba14[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 13 22:25:24 2021 -0400

    Update CHANGELOG.md

[33mcommit 1aa7cdac7560ac25d7c82f4a8dd89a27d53f3607[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Mar 23 22:03:32 2021 -0400

    issue #92: fix SystemC caches endian assignment and implementation

[33mcommit 45fdb2ce843773593381b932d5bfa7ce5453165d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Mar 23 22:01:29 2021 -0400

    sc_caches.mk: save caches HLS logs into dedicated folder

[33mcommit 046ae60542879be58826d90f324ed6f25835cab1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Mar 23 21:54:05 2021 -0400

    issue #93: update links to prom and ram images when switching CPU core selection

[33mcommit 7a35d86c6750cbee0ca2990dc15769c12498c0a8[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Mar 22 23:40:09 2021 -0400

    use Xilinx primitives from Ibex when targeting FPGA

[33mcommit 84ed311bffeb33c0bd86eac14b311d643cfe253d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Mar 22 23:34:50 2021 -0400

    issue #92: disable l2 invalidate AHB interface as Ibex has no L1. Fix timing loop

[33mcommit 6492697912bb86ae779024841cb185429402da6a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Mar 16 15:50:39 2021 -0400

    issue #92: fix endianness for SystemVerilog caches with Ibex

[33mcommit 0e0ab3be8a24b9b7674a607901d9c2df578be876[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Mon Mar 22 15:58:20 2021 -0400

    fix profpga-xcvu440 floorplanning scripts after restructuring (issue #94)

[33mcommit 57804de0988834c5ff325b1b2c0698819a16ebb3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Mar 25 09:59:30 2021 -0400

    issue #96: update URL of prebuilt files to use https in toolchain scripts

[33mcommit 607b249f06fb257c50e6f4e2e9d8a447f92eb1ee[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Jan 22 19:10:20 2021 -0500

    minor edits to CHANGELOG.md and CREDITS.md

[33mcommit 6eb0f4ba1b16bdb3825ea837234b9f7cfaaa497d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Jan 22 13:01:46 2021 -0500

    add CHANGELOG.md

[33mcommit 1cc05492fa46c50e4769a21bc38d8a374f39e001[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jan 18 11:28:30 2021 -0500

    update credits content and format

[33mcommit 1cb3575e653ded446a833198cbe6086d6691bc32[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jan 11 10:48:22 2021 -0500

    :bug: fix examples/multifft include flags

[33mcommit 716ab155f4957d0d09d7e3ebb05cdd9fe81a1676[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 7 16:08:34 2021 -0500

    :bug: reomve copyright from XML files to be parsed by Python

[33mcommit 81475052f4d930a41c98ee1ec91f312a4ac34f1f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 6 16:54:49 2021 -0500

    :bug: fix install target for SystemC caches implementation

[33mcommit 7d31649f44cc8e49a677842869b4f74840971347[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Wed Jan 6 13:43:39 2021 -0500

    :bug: move license information after interpreter declararation

[33mcommit b9694e0809863f7b7c4a8789f9168967aec09bb3[m
Merge: 62a3cb4 2dbb8f1
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Jan 5 17:01:49 2021 +0100

    Merge pull request #87 from sld-columbia/restructuring
    
    Consolidating and cleaning up RTL, automation tools and software (part 3)

[33mcommit 2dbb8f157c867c53e084fed7b463d8f065a908e0[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Jan 5 09:07:20 2021 -0500

    :bug: fix broken device tree generation make target

[33mcommit 6b3b18db301d38681a2aa424543c3663491784cb[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Jan 5 06:11:25 2021 -0500

    :bug: fix broken esp-defconfig target

[33mcommit 796521fb6e983fa41e7290cb3057d341b82ddcf7[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Dec 21 16:20:15 2020 -0500

    update socs/.gitignore

[33mcommit e895f80af455decf40154a973d0510759e61659e[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Dec 21 16:19:30 2020 -0500

    :bug: fix MEMTECH_PATH in common script of Catapult flow

[33mcommit 69d62fed92a7db9c4ab72c81ae5c91171e9c6484[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Dec 19 17:27:09 2020 -0500

    add READMEs to 1st level of folders and describe them in main README

[33mcommit 8585bb86a3f0330fc2a4429241898dbece7c87f9[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Sat Dec 19 11:44:09 2020 -0500

    add license to files missing it

[33mcommit 4931c2dba631cb417bd54a83924c3f06ff25cae0[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Thu Dec 17 19:21:44 2020 -0500

    update license for 2021

[33mcommit 62a3cb473a00ce7b27757e2aa75b2b8e7bb457eb[m
Merge: b568841 08625b2
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Dec 17 22:16:58 2020 +0100

    Merge pull request #86 from sld-columbia/restructuring
    
    Consolidating and cleaning up RTL, automation tools and software (part 2)

[33mcommit 08625b2ad97efa50846d43e9f695e7c730d90883[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Dec 17 15:58:55 2020 -0500

    organize in folders the spare files generated in the working folder
    
    - logs/hls and log/vivado contain log from HLS and vivado
    - socgen/esp mostly contains files generated by the tools/socgen tool
    - socgen/grlib contains files generated by the utils/grlib_tkconfig tool
    - socgen/flits contains RTL file lists generated by utils/make/rtl.mk
    - espmon contains files generated by the tools/espmon tool

[33mcommit 13856d0eb2fd20ccfaefa33bcf17657ad6b2540a[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Dec 17 15:54:31 2020 -0500

    avoid naming conflict for device drivers of homonyn accelerators
    
    - avoid conflict for homonym accelerators from different design
      flows by renaming the device driver source file and some global
      structures and constants

[33mcommit b5688418931e1a026b81772baa760ddb1188f29c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Dec 16 18:30:23 2020 -0500

    vitdodec_stratus: add clock period for Virtex Ultrascale technology

[33mcommit 2d45772ea8051bd683472750b8a7bd4fc25ccbd3[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Dec 16 13:16:53 2020 -0500

    improve compilation of app examples and generate outputs in soft-build
    
    - the apps in soft/common/apps/examples are now compiled with the
      soft/common/drivers/linux/common.mk makefile
    - the generated files go to soft-build/<cpu>/apps/examples
    - the generated files are automatically copied into the linux sysroot

[33mcommit 2a55d021300d396fcae876070b0e0103ebaf347c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Dec 16 12:25:57 2020 -0500

    Update Stratus HLS Make and TCL include and link paths

[33mcommit 466cccfb27f94b3f17dab25fd5d1349011169632[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Dec 16 11:43:56 2020 -0500

    ibex wrapper: fix Genus elaboration

[33mcommit 8973a081daa5b2cc2932f81c8232ddaeea8a7471[m
Merge: 215f794 76a2bf2
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Dec 16 10:21:08 2020 -0500

    Merge pull request #85 from sld-columbia/restructuring
    
    Consolidating and cleaning up RTL, automation tools and software

[33mcommit 76a2bf2759c9a0b8c9c566c71c56ae7114beca3a[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Dec 16 09:14:20 2020 -0500

    enhance common makefiles for baremetal and linux apps
    
    - add support for multiple source and header files in common makefiles
    - apply patch to all local makefiles for baremetal and linux apps
    - apply patch also to the AccGen tool templates

[33mcommit f2b77a087fa89a6ac2a1926f32932bbc0fda2526[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Dec 15 16:01:57 2020 -0500

    add soft-build/leon3/grlib and soft-build-leon3/mkprom subfolders

[33mcommit 112bd094c7c3e82692c2b20c43cd00ba35f80f71[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Dec 15 14:31:37 2020 -0500

    socketgen: fix null range for Genus synthesis

[33mcommit 0cf69dc22aa579ccd9663e65d10fcb1cfac1fd36[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Dec 15 14:09:11 2020 -0500

    add support for Questasim

[33mcommit 74da1df76faf1ddcca8be2399f31a7d07bf221ff[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Dec 15 13:04:36 2020 -0500

    Restructure the soft/drivers and soft/examples folders
    
    - Change their paths to soft/common/drivers soft/common/apps/examples
    - Divide drivers software in baremetal, linux and common
    - Add some utils folders for the drivers. These will host files
      previously placed in test/, like fft_test.c
    - Adjust all makefiles and FFT accelerator apps accordingly
    - Adjust examples/multifft to adhere to the new software structure

[33mcommit b9760ab5310c31ad19e30330cbadd4fa14703f02[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Dec 15 05:47:23 2020 -0500

    Move ESP automation tools from utils/ to tools/ and improve their names
    
    - Move both init_accelerator.sh script and the related templates

[33mcommit bda075e4cfe4da56867a3f53bede613ae2484791[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Dec 14 17:14:36 2020 -0500

    modlesim.mk: suppress warning on empty VHD files

[33mcommit e2245e91635c66c7b8a5a94e3fb2a55b61e8a1c8[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Dec 14 11:40:20 2020 -0500

    Restructure accelerator folders: new acc names, add sw, modify hw
    
    - Move the software of each accelerator inside the respective folder
      in accelerators.
    - Restructure the accelerator folders into hw and sw.
    - Rename all syn folders to hls.
    - Rename all accelerators according to a new scheme: <acc-name>_<flow>
    - Replace esp-chisel-accelerators submodule. Poi to a fork where
      the accelerators have new names
    - Adjust various scripts and makefiles according to the changes
      listed above

[33mcommit 467359b37354ad9a5a861089727eead660e71274[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Dec 14 17:03:34 2020 -0500

    use https URL for zynq submodule

[33mcommit 27674fb70c45231ddcab09d1b9a95151fc6dca10[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Dec 14 13:47:28 2020 -0500

    move grlib software to soft/leon3

[33mcommit 6296e2238008b16bd74cf6be1240bebcfb0408bb[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Dec 13 17:51:39 2020 -0500

    Move drivers folder one level up and make it common to all CPUs
    
    - Move soft/leon3/drivers --> soft/drivers
      Remove soft/ariane/drivers and soft/ibex/drivers
    - Modify some files and makefiles to make them common to all CPUs

[33mcommit f6475778d524a12687742e084e997bb597207613[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Dec 11 08:33:08 2020 -0500

    Generate drivers compilation output in the design folder
    
    - All files generated by the compilation of bare-metal apps,
      Linux device drivers and Linux user-space apps go directly
      to the soft-build/drivers folder in the design folder

[33mcommit 3ef4039179fcd2341134048030a516366403f0ea[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Dec 10 23:34:30 2020 -0500

    move non generated SRAM wrappers from build folder tech to rtl/techmap

[33mcommit 6ed893784adfc5c59de1dabafb7edd5194937d13[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Dec 10 23:02:05 2020 -0500

    improve ESP socket components name

[33mcommit e5ff930dc2f8b1834ed78754537d770a06d8d86c[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Dec 8 18:08:44 2020 -0500

    Restructure LibESP to remove accelerator-specific code
    
    - When generating new ESP accelerators LibESP does not get
      edited anymore
    - The cfg.h of the accelerator apps using LibESP have been
      modified accordingly. TODO: the synth accelerator app still
      needs to be modified

[33mcommit db6b17dd4a524d9363cdc8a0557eea305d41de39[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Dec 8 17:20:29 2020 -0500

    Fix indentation of accelerator C apps and LibESP

[33mcommit d0540ab279e57fc232a81548c85f4539f65f9409[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Dec 10 22:24:23 2020 -0500

    embed SystemC implementation of ESP caches into caches submodule

[33mcommit b849e6892ee7833fe42f7012cf942bde6746670d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Dec 7 10:29:54 2020 -0500

    cleanup and restructure RTL folder:
    
      - Remove unused files from GRLIB
      - Combine packages and source files
      - create file list in place of source autodiscovery
      - organize RTL sources by component type
      - cleanup full RTL source generation in Makefile
      - filter out RTL files based on selected processor core
      - simplify flags and include directory lists
      - Temporarily disabled Vivado, Genus, Incisive and Xcelium targets

[33mcommit f1e37aab45d7e30045c728298f86883806bc8f56[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Dec 4 12:19:30 2020 -0500

    Move third-party/accelerators to accelerators/third-party
    
    - Remove subfolders dma64 and dma32. Now each accelerator folder
      contains the list of supported processors in <acc-name>.hosts.
      Makefiles and ESP SoCGen have been updated accordingly.
    - The two NVDLA submodules have been moved to
      accelerators/third-party/NV_NVDLA

[33mcommit 402a0050232fc66d4034ca663b086bca3fc2dfbd[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Dec 4 06:19:00 2020 -0500

    ESP SoCGen: use lower case for hex numbers in the device tree

[33mcommit 7e4d539d4c402e6208b2ea933ca1ed06d8ece665[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Dec 4 05:50:45 2020 -0500

    cleanup RISC-V and SPARC toolchain scripts:
    
      - Do not checkout twice buildroot and riscv repos submodule
      - Use /tmp as temporary build folder but do not automatically delete them (the first reboot will clear /tmp)
      - Kill script on error

[33mcommit 017038df26273561043770cbbd73ecec110eb4e9[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Dec 3 17:24:36 2020 -0500

    Make folder naming consistent across different accelerator design flows
    
    - stratus_hls: stratus becomes syn, submodule syn-templates becomes inc
    - catapult_hls: move header files from common to common/inc
    - adjust accordingly accel makefile and accel generation script

[33mcommit b410ea627bc20368d27f1f00b5d57eea0c15d489[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Dec 3 12:19:42 2020 -0500

    Rename visionchip accelerator as nightvision
    
    - Rename folders, files and their content in accelerators/stratus_hls/,
      soft/leon3/drivers, soft/ariane/drivers, soft/ibex/drivers

[33mcommit 19fb2dcee610341604d2d9503530980dc2194825[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Dec 3 10:49:38 2020 -0500

    Move `chisel` submodule to the `accelerators` folder
    
    - `chisel` --> `accelerators/chisel/hw`
    - update `CHISEL_PATH` in `accelerators.mk`

[33mcommit 5d3237037ff299a788abb84c445c04abae4ae9dc[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Dec 3 09:21:06 2020 -0500

    Remove from socs/common outdated duplicate of mmi64.c
    
    - The duplicate and up-to-date file is utils/mmi64/mmi64.c

[33mcommit 215f794fad29e632f46b21ffd019dd6bf6ed2478[m
Merge: d3d4338 6c79301
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Dec 4 12:38:25 2020 -0500

    Merge pull request #84 from sld-columbia/zynq
    
    Preliminary support for ZYNQ MP SoC boards ZCU102 and ZCU106

[33mcommit 6c793016fc38f32e24e623baf03ec962bc0ba14b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Dec 3 22:39:45 2020 -0500

    update zynq submodule: use rootfs from Petalinux 2017.4

[33mcommit 6cbb7b66e0c71a3b86f99b1376b52e234516f956[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Nov 20 23:27:21 2020 -0500

    Integrate ZYNQ MP SoC boot flow

[33mcommit 8bfcf90304be43eca58a31f9084a577a5f1a1fe5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Dec 2 12:32:52 2020 -0500

    add template design for ZCU106 using PS-side DDR

[33mcommit 2fa12b1a31fb02f45d1b4fa873c60c7f95356ef5[m
Author: Juan Escobedo <juan.escobedo@pnnl.gov>
Date:   Mon Nov 2 16:08:59 2020 -0500

    add template design for ZCU102 using PS-side DDR

[33mcommit d3d43388d8af21de63ff12ec1c80d9f358edb72c[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Dec 1 20:45:35 2020 +0100

    Delete outdated README for Vivado HLS accelerator flow

[33mcommit c49f60bfa883871af00e58409a39f562c18006a5[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Nov 17 08:52:45 2020 -0500

    :bug: Fix APB to AXI-Lite adapter
    
    - Solve issue #83
    - Remove latches in main process
    - Remove custom behavior for reads/writes for address 0

[33mcommit 3ecbe3618a989c47bde5b50788e2adbde2f7c837[m
Merge: 116c39d 703585d
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Nov 12 21:17:36 2020 -0500

    Merge pull request #81 from sld-columbia/ibex
    
    Add option to use SLM tiles instead of memory tiles for ibex

[33mcommit 703585dcaac187647b02101768ddfa107ebdd059[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Nov 12 12:10:09 2020 -0500

    Fix vitdodec Linux app compilation

[33mcommit bd0ff0a9115f5f6e1fa917e53fc7dab0fa0193ae[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 11 23:31:53 2020 -0500

    Add option to use SLM tiles instead of memory tiles for ibex

[33mcommit fd8a0f1c1e2cdb0de21062712e9044d2a12485b7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 11 23:27:20 2020 -0500

    implement SLM tile with ahbram and new unisim_syncram_be to enable more size options

[33mcommit a3b939569633e13320480ddb82ae61a289ec1a01[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 11 23:17:18 2020 -0500

    memory_unisim: reimplement syncram with byte enable; support for up to 20 address bits

[33mcommit 116c39d41084d075b73f97151f9aeda8f7b6b5a0[m
Merge: 2198c52 f80f7eb
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Nov 10 18:09:53 2020 -0500

    Merge pull request #80 from sld-columbia/ibex
    
    Add lowRISC ibex processor core to ESP

[33mcommit f80f7ebf30ee1da3b1ed30f1fdd21da44392bbdc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Nov 9 22:57:20 2020 -0500

    Add IBEX core option to ESP

[33mcommit d02dbdbbce87bce68e40452532ea41e10e0ba837[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Nov 9 22:54:21 2020 -0500

    fix vitdodec bare metal driver compilation

[33mcommit 40a46995afa499811abf059e34752c2bc0ab4933[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Nov 9 22:53:11 2020 -0500

    Makefile: move barec-all target to soft_common.mk

[33mcommit dd5e6ae98a3881ba5f23f3f0c9845221de66de3d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Nov 9 21:40:17 2020 -0500

    add wrappers for Lowrisc Ibex core

[33mcommit 101d51990da136b6f1609bdc7fd67f3a4e997628[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Nov 9 21:37:11 2020 -0500

    Split Makefile

[33mcommit 697ca2e332cfd06fbda0bfb210daa17e31818335[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Nov 9 21:33:47 2020 -0500

    add RISC-V rv32imc toolchain script

[33mcommit 51f299950a38b4a8a39f9562bf464b8e4e9707e1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Nov 3 15:29:14 2020 -0500

    add submodule Ibex

[33mcommit 2198c5217a3fe8dc1a05c815bc090ebc63e6f6ac[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Oct 28 18:28:27 2020 -0400

    Makefile: move vhdl compilation flag -93 to common Makefile

[33mcommit 50f606d29ae5bfefe27d284830a8c7789646329d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Oct 28 18:26:04 2020 -0400

    Makefile: do not define Vivado's target when TECHLIB is not for Xilinx

[33mcommit 850df648762eedb86ccba73d5d43104be9201d07[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Oct 28 17:46:31 2020 -0400

    Refactor target technology selection:
     - use single VHDL constant defined by socmap.vhd only
     - local design Makefile sets TECHLIB

[33mcommit 48a63a6e838627a2b67469178f55c93760614f12[m
Author: Gabriele Tombesi <gabriele.tombesi@studenti.polito.it>
Date:   Wed Sep 23 16:03:05 2020 -0400

    Add JTAG-based unit for single tile testing

[33mcommit 3b6ac137fb0b1108d8f2e20dd33ce7c6eee4006f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 24 16:55:38 2020 -0400

    Add support for GF12 technology
    
      ** note: technology library, models and scripts cannot be publicly shared **
      - generate RTL elaboration script for Genus
      - minor RTL patches to fix elaboration with Genus
      - add support for single-port SRAM memories to the ESP memory wrapper generator
      - add GF12 mapping for pads
      - add GF12 mapping for syncram and syncram_2p
      - add Stratus HLS pragmas to generate accelerators for GF12
      - add wrapper for DCO to generate tiles and NoC clocks
      - add per-tile reset generator synchronous with the DCO clock
      - keep S and E ports active for non-FPGA flows to have fewer different instances of the routers

[33mcommit 3ab3310bde833cbf625f2a8b06dfffcdf7a48677[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Sep 18 14:46:07 2020 -0400

    Add FPGA-based memory link as alternative to the integrated DDR controller

[33mcommit d5c720c959a303f9798f42b37c52ad803677bb09[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 24 16:46:46 2020 -0400

    Enhance ESP tiles interface for hierarchical ASIC flow w/ multiple Ariane CPU tiles
    
      - move UART pads to ESP top
      - enable synchronizers by default with HAS_SYNC parameter in tile declarations
      - refactor clocks interface to use a DCO when external tile reference clock is not available
      - enable run-time reconfiguration of the Ethernet MDC scaler to account for clock frequency uncenrtainty
      - add the following ESP CSRs:
        > output PADs configuration
        > DCO and NoC DCO configuration
        > Ethernet MDC scaler
        > Ariane's HART ID override
        > CPU routing table override to fix CPU tiles coordinates after overriding the HART ID
      - add support for multiple Ariane CPU tiles (SMP not supported yet)
      - generate RISC-V PLIC register map based on the number of CPUs specified in the ESP configuration file
      - add SMP and non-SMP Linux defconfig for Ariane

[33mcommit c08f5c2978889753e5959718285aeb3d894705a8[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jul 9 04:21:35 2020 -0400

    Ariane submodule points to internal fork: apply minor patches to fix the ASIC synthesis flow

[33mcommit 0c34769c14bef380fb5d6d555a9b7ae332ce4acc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 24 18:58:16 2020 -0400

    enable custom defconfigs

[33mcommit ea0e65420175a247b56b24b163fc437d5f688163[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jul 30 18:04:51 2020 -0400

    visionchip: improve PLM memory list

[33mcommit 34e7f01cdc3e249237a6d648774a5489f3f3a68e[m
Author: J-D Wellman <jdwellman@yahoo.com>
Date:   Tue Mar 10 01:05:14 2020 -0400

    add vitdodec: Viterbi Decoder Accelerator

[33mcommit 5beb186800adef9985932557930674887cebcf97[m
Author: J-D Wellman <jdwellman@yahoo.com>
Date:   Tue Mar 10 00:40:29 2020 -0400

    strarus_hls/fft: tune 32-bit fixed-point data type

[33mcommit 1b0e52b5badf865a988c50adb1c5c740bd520793[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 18 11:08:39 2020 -0500

    Enable ESP cache hierarchy w/ single-core Ariane
    
      - add 64 bit AXI slave interface to l2 cache
      - add L2 and LLC caches to Ariane device tree
      - add support for little endian architecture to LLC wrapper
      - add support for 32-bit coherent DMA (Ethernet) on 64-bit archiectures to LLC wrapper
      - fix Linux Ethernet driver for RISC-V to work w/ coherent DMA
      - separate list of common RTL source files for Ariane from FPGA-specific SRAM wrapper

[33mcommit 6f4e7e7730781c8af54d1fa79c263e584e6bd34c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Oct 1 13:14:20 2020 -0400

    l2_wrapper: remove initial signal assignment

[33mcommit f02a59f914a158da10ca35b87e50e6001be867fb[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Tue Feb 18 15:38:21 2020 -0500

    Add doubleword write support for SystemC caches

[33mcommit 44092912fb3674d9b058e7d3486d580d7fb68831[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Oct 1 13:13:39 2020 -0400

    remove unused verilog file from Ariane's source files

[33mcommit 9c7741260e7827ee4682267f9ce01b4b6ebb7bdd[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 25 18:38:45 2020 -0400

    Makefile: fix RTL file search in linked tech folder

[33mcommit f582763b821cc4c11413dbc070935207f3625923[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Sep 23 18:15:15 2020 -0400

    move sync_noc_set component declaration to nocpackage

[33mcommit c06d3bf3bda5e3aada9bb4cedafff14155160434[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 6 08:30:24 2020 -0400

    rtl: remove gaisler can

[33mcommit 52412078c8cd92be9c3947e61f2f112b6fc04395[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 19 16:20:34 2020 -0500

    update mark_debug attributes

[33mcommit ab792f800d5301674d2343e3123a00447a317092[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Tue Feb 18 13:58:12 2020 -0500

    Fix RISC-V toolchain script to clone from https URL

[33mcommit 5221887565c5af665e940f75ff2fcd73625d1273[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Oct 14 18:28:56 2020 -0400

    fft and generated bare-metal apps: improve printouts and test all coherences

[33mcommit 7fffd8073807e8c2f70c881061e71de10fb89cf6[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Oct 14 10:35:58 2020 -0400

    :bug: make FFT bare-metal app compile out of the box

[33mcommit 278f1a29f8231fc0c461f60e22b46b3ba7f98ef7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Sep 24 16:40:57 2020 -0400

    define XILINX_FPGA for RTL simulation w/ updated ESP caches

[33mcommit 82be6d19ea69909e1cb9edb216713557be4824a4[m
Merge: 593c4ed 0c2f5f0
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Sep 24 21:36:41 2020 +0200

    Merge pull request #63 from sld-columbia/vivado-hls
    
    Add support for Vivado HLS generated IPs and float interfaces

[33mcommit 0c2f5f034f3c24eff1f4f0dc7744512b5af86147[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Sep 24 15:14:05 2020 -0400

    change HLS config string to indicate a float accelerator interface

[33mcommit dde8b86557e40fa0420dc5dc58fbc932f5211f01[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Sep 24 13:07:07 2020 -0400

    :sparkles: add support for Vivado HLS accelerators with float interfaces
    
    - inc/espacc.h,espacc_config.h: add float datatype option
    - syn/custom.tcl,common.tcl: optionally add float string to hls config
    - sld_generate.py: interface signal names based on hls config
    - update bare-metal test apps

[33mcommit 90c8e91c7fbd80e2e58f0cbcf4be08703671af00[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Sep 24 12:58:23 2020 -0400

    :sparkles: add automatic integration of IPs generated by Vivado HLS
    
    - solve issue #44
    - utils/Makefile:
      - add to Vivado project .xci files generated by Vivado HLS
      - compile all IPs in Vivado simulation libraries
    - accelerators/vivado_hls/common/syn/Makefile:
      - fix to copy of files from Vivado HLS project to tech folder

[33mcommit 593c4edf041646a3a76b958e2944148ce96ff6bf[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Wed Sep 23 22:37:22 2020 -0400

    update cache submodule
    
    -various optimizations for L2 and LLC FSMs
    -fix warnings produced by Genus for ASIC flow
    -add GF12 SRAMs for ASIC flow
    -use of XILINX_FPGA define to enable BRAMs for ASIC flow

[33mcommit 58a2d0748b6e942a1d7d4de1946b832205fc2d98[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Sep 21 13:06:22 2020 -0400

    :bug: fix additions for RedHat support made to accelerator generation script
    
    - Fix issue #62
    - On CentOS the script was executing also some `rename` operations meant for
      RedHat

[33mcommit ed3e453c4b286a7f4a3298ed92bba453d5fa642a[m
Merge: 032a765 2e1572f
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Sep 18 18:20:30 2020 +0200

    Merge pull request #58 from sld-columbia/monitors
    
    Enhanced scalability and flexibility of the ESP architecture

[33mcommit 2e1572f000c034c6bbafb10431b6763458fbb9bb[m
Merge: e24d700 032a765
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Sep 18 18:16:30 2020 +0200

    Merge branch 'master' into monitors

[33mcommit e24d70001ff64b8beb938e8d63af1164fce2acbe[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Fri Sep 18 12:09:26 2020 -0400

    synth app: enable up to 16 accelerators

[33mcommit 53a30b51ab17aa1f06b76cee0d0ce07985248cfd[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Sep 17 19:15:04 2020 -0400

    replace blackbox unread from Ariane's repo to prevent DRC error on Vivado 2019.2

[33mcommit 48adb6880d1f8e3c8cdf7ddf3a6edca32567264a[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Mon Aug 17 02:34:50 2020 -0400

    keeps for tile_acc.vhd

[33mcommit 1c48a4f0ba500622115c645eb2445ee5fd1bf1b6[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Sun Aug 16 18:12:57 2020 -0400

    add keeps to all NoC planes, update burst monitor in acc_dma2noc to count all communication cycles
    
    Conflicts:
    	socs/common/tile_io.vhd

[33mcommit 032a7656a26dceb868c8b6bf122ca413a06117a0[m
Merge: 2e5e8ff 8ea4833
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Sep 11 00:46:18 2020 +0200

    Merge pull request #59 from sld-columbia/catapult-hls-pr
    
    Added support of Mentor Catapult HLS (C++ flow)

[33mcommit 8ea4833b3d65d8b4230f23141168398113b794c1[m
Author: Giuseppe Di Guglielmo <giuseppe@cs.columbia.edu>
Date:   Thu Sep 10 18:35:47 2020 -0400

    [top.vhd] restore mem size

[33mcommit 9c4d71bda4882fa7592d7ae8d454382b2d6d289a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Sep 10 18:10:57 2020 -0400

    tile_cpu: remove mark_debug attributes; these trigger a don't touch on a dummy module in ariane, which becomes black box after synthesis

[33mcommit 8613b8df9318f45e1ec6c8ed9ee37beacd84a52e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Sep 10 12:52:30 2020 -0400

    :bug: relax esp_init time to ensure tile_id is configured before forwarding any NoC packet

[33mcommit 2e5e8ff3b67748298d98cd25f29ab861d06ea389[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Sep 5 11:20:10 2020 +0200

    update README.md with new overview paper and other minor changes

[33mcommit 1283c56de1f0c269634fb5795ca64a6216618f2d[m
Author: Giuseppe Di Guglielmo <giuseppe@cs.columbia.edu>
Date:   Fri Sep 4 13:51:52 2020 -0400

    Added support of Mentor Catapult HLS (C++ flow)

[33mcommit 77b0760207eb47767d721a59d6615f3a0b0eba41[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Sep 2 11:51:27 2020 -0400

    ESPLink soft reset forwarded through the NoC

[33mcommit 839a3cbd232daba39b4e44e6c1d892cf79338f60[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Sep 2 09:01:17 2020 -0400

    tile_io: fix interrupt assignment for multicore Ariane

[33mcommit 25983926425a5474b57b7a85cd9bef7898d29062[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Aug 26 11:56:59 2020 -0400

    RISC-V PLIC and CLINT interrupt lines forwarded through the NoC

[33mcommit c08f49868a345f36517af481d146a5faa6720173[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Aug 26 05:56:13 2020 -0400

    cleanup most mark_debug attributes

[33mcommit 1741da922c8ca4179a50ea87ac69109651c1644d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Aug 10 05:15:46 2020 -0400

    esp_tile_csr: fix CSR address decoding for Genus synthesis

[33mcommit 96ad2cdd27ec8c26710e3d18c6333fafc11d8dc2[m
Merge: 456df7c b1fb1b8
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Aug 1 19:02:47 2020 -0400

    Merge branch 'master' into monitors
    
    Conflicts:
    	soft/leon3/drivers/synth/app/synth.c

[33mcommit 456df7c351db735d460f3ba504398a3bc5db977f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 15 05:42:40 2020 -0400

    Configure tile ID to improve physical design scalability; add self configuration sequence at reset.

[33mcommit b1fb1b84bd3df48db3fec6b1a4c4403a4bd03a70[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Jul 20 05:34:42 2020 -0400

    Bump third-party/accelerators/dma64/NV_NVDLA/ip submodule
    
    Merged the master branch of the original NVDLA hw repository:
    - vmod: 2 cleanup commits
    - a few other commits in cmod/ and verif/ which are not used by ESP

[33mcommit 7389957fad34c01bd3e09c29317cf0e1567eacd7[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Jul 19 12:55:03 2020 -0400

    User app for synth accelerator: remove compilation warning

[33mcommit 97d7703fccbd366f5e3fc2f1fcfe85a1f587617a[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Jul 19 12:40:00 2020 -0400

    :bug: fix modifications to LibESP when generating a new accelerator

[33mcommit 4d86f68878aeab9480b632ad8c6fae70b0571767[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 15 05:24:42 2020 -0400

    techmap: create SLM bank technology mapping

[33mcommit 26d46580c2e6933a706b1e3a2c98261d4f088732[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 6 08:33:54 2020 -0400

    rtl: move unisim SLM bansk to unisim techmap

[33mcommit 65d3bd88e4439fc498df4b5edee8d4f6be0e2edb[m
Merge: d8011c8 ecc8d1e
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 13 05:51:40 2020 -0400

    Merge branch 'master' into monitors

[33mcommit ecc8d1e9eaa25dbd9bf9ccc5af5c5c4bb0b28a0a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 13 05:49:20 2020 -0400

    NV_NVDLA: update sample workload to match online tutorial

[33mcommit d8011c81f37ff0355f8d107e6393461a79b6b9df[m
Merge: d8fa10b 3142f8a
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 13 04:04:53 2020 -0400

    Merge branch 'master' into monitors

[33mcommit 3142f8a3272f097485fa7d0f94358521a59bfe6a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 13 04:03:10 2020 -0400

    :bug: fix unused AXI slave ports for thirdparty accelerators

[33mcommit d8fa10b70bc001e934d711dbceea856ac18abdbf[m
Merge: 2814523 ec9b3af
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Jul 10 09:42:06 2020 -0400

    Merge branch 'master' into monitors

[33mcommit ec9b3af769bef1101b8ab89de1eccad8b2097503[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Jul 9 20:38:01 2020 -0400

    :bug: accelerator generation: fix app skeleton and edits to libesp.c

[33mcommit 28145234253234a121bc7f4757ac0c4aadebbafb[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jul 7 06:42:32 2020 -0400

    bump ariane submodule

[33mcommit 80952f23665caf14b348b2e7b9dca3590e2b4d7a[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Sun Jul 5 14:51:01 2020 -0400

    fix synth barec to read correct status reg

[33mcommit 735aa4c2d3ea5fca3715b2dd219031679ca647a6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 1 00:33:31 2020 -0400

    :bug: fix accelerator tile NoC wiring

[33mcommit 400891f8916f9f5a5a0a078428608aaf59d02707[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 29 17:17:42 2020 -0400

    llc_wrapper: fix simulation artifact due to glitch on FIFO empty flag

[33mcommit d343fbf8dde1ae3de40b1e99dba0c8f5a1f5a2a4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 29 17:17:05 2020 -0400

    socs: use clkgen for clock generation in simulation as well

[33mcommit 2015f375151d9654f020e22bb3852a3c3fa49056[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 29 17:12:57 2020 -0400

    rtl/src/techmap/unisim/clkgen_unisim: update Virtex7 PLL

[33mcommit 03c0284ed3ea69b00977a0d3ddaad00c13c15672[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Fri Jun 26 15:53:56 2020 -0400

    esp_tile_csr: make user reset terminate current window

[33mcommit 5734b2fae6dbe7a3e35d25be7a143296a4cbd211[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 24 23:43:13 2020 -0400

    :bug: fix NoC2 stop wire assignment

[33mcommit 4b545e495dc7137a85ff887152218bad9aff1a09[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 24 23:24:44 2020 -0400

    :bug: fix NoC2 stop signal assignemnt

[33mcommit d490968ea416d058e98492645ccb80cb54b83506[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 23 14:47:24 2020 -0400

    add empty NV_NVDLA.bc

[33mcommit 00f9d9ccf285465336387da7d83b16a9de6f6ce0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 23 14:25:43 2020 -0400

    utils/accekerators.mk: enable bare-metal Make targets for thirdparty accelerator

[33mcommit db8339eb5db2c72fc9db9ce49001ebba3aa33235[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 23 14:21:55 2020 -0400

    profpga-xc7v2000t: increase simulation memory size

[33mcommit f19f70b30b5f0417cc36a0f8731c3b0d9b6ac511[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 22 15:58:12 2020 -0400

    add APB to AXI-L adapter

[33mcommit d53554035cbe053046ebd7021598774a747f64dc[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Tue Jun 23 11:54:34 2020 -0400

    fix mon_ddr assignment at top level for profpga-xcvu440

[33mcommit e7f4c629dcdfd12d50dfaaee200fce5d45521bc0[m
Merge: 3fdbb19 a3b62bf
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Tue Jun 23 11:49:04 2020 -0400

    Merge branch 'monitors' of https://github.com/sld-columbia/esp into monitors

[33mcommit 3fdbb1904a6ed6b4b56f923e2f90a48ba5b48ece[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Tue Jun 23 11:46:40 2020 -0400

    fix window_reset on window size change

[33mcommit a3b62bf15ede1702b3ed33daf4c1af7c1d6be7b6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 23 11:44:07 2020 -0400

    sldgen/templates/noc2axi_interface: connect output pindex

[33mcommit 362c933520b50604a041cba7cdf42330c51be92e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 3 19:14:05 2020 -0400

    Enable printf on RISC-V bare metal test programs
    
    Conflicts:
    	soft/leon3/drivers/synth/barec/synth.c

[33mcommit 6e8b44793caba428029d8654eb33cd18a5d311a6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 22 12:43:16 2020 -0400

    sldgen: pready is always active when CSRs are selected

[33mcommit 7cf722cbf18af47d460d06935b700c6370631ef2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 22 12:07:11 2020 -0400

    Makefile: fix boot loader dependency on socmpa

[33mcommit 27117a77cc6892fdb81a6eff32f40eae23db7f5e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 22 12:06:36 2020 -0400

    socs/common: add APB to empty tile for CSRs

[33mcommit f40d60d7aca89df8834edbbe93617029d049975c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 22 12:05:43 2020 -0400

    socmap: add APB pindex to tile ID match for CSRs

[33mcommit 9f78acd44e939f8f45c7a6643df4e5585be3f87e[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Sat Jun 20 18:17:53 2020 -0400

    create monitor-apb interface in esp_tile_csr.vhd. connect csr in each tile type. simulation compiles and runs, but new features untested

[33mcommit 4c3b28bb750ba13f6baabf2418e9d755c0d89e14[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jun 19 18:45:18 2020 -0400

    socmap: generate CSR addres map and routing table

[33mcommit 4e52df91ecaaedb0a9a3fdbf9c59b077bcc966e7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jun 19 16:39:23 2020 -0400

    SLM tile: add APB proxy and queues

[33mcommit 7a4d7b8e13ece3de17a91dd221483db9fc9ea0e4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 18 18:31:47 2020 -0400

    soft/leon3/drivers: bare metal probe can discover up to 128 APB slaves including up to 44 ESP accelerators

[33mcommit c28a757348b124e4121e1cd7788eda603db6bf97[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 18 17:50:30 2020 -0400

    tile_acc: move APB proxy to tile top to connect local monitors

[33mcommit 0ad0536e11500eddf1e5dab5881f4adadc8bf935[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 18 15:52:13 2020 -0400

    :bug: fix router ports enable after hierarchy reshape

[33mcommit 939134c33f1be3407167370e8d89031c44715b6d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 17 18:49:32 2020 -0400

    synthetic accelerator app: fix printf for size_t

[33mcommit 896f1e5152c01d02bbbf009a3b8d1f47313a7337[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 17 18:44:59 2020 -0400

    utils/Makefile: distclean removes log files

[33mcommit 6bdcaef22ca508e7675fd6edee4aafae4bda92b4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 17 18:44:42 2020 -0400

    utils/ariane_verilog: remove deprecated generic_fifo conflicting w/ GRLIB generic_fifo

[33mcommit a1f49e5d6798b1e9932369e94072df76d349c2b3[m
Author: Maico Cassel <mcassel@cs.columbia.edu>
Date:   Wed Jun 17 18:40:14 2020 -0400

    NoC hierarchy: routers are now part of tile modules

[33mcommit 56e719ddc4d36e2c874aec5893eabae4ff71cfc9[m
Merge: b383c49 452692a
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 17 16:03:53 2020 -0400

    Merge branch 'master' into monitors

[33mcommit 452692a779378d15a4cdb80fc61e4f6a915c8f00[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Mon Jun 15 22:07:38 2020 -0400

    move S64esp generation to socmap_gen, automatically add contig_alloc and thirdparty regions to ariane.dts

[33mcommit 188926364e955b7e15a56351285fb13e983fb272[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Jun 11 03:06:21 2020 -0400

    :bug: update NVDLA submodule: declare different mem regions for each NVDLA device

[33mcommit b383c493e9b783f7e14c0044b9f40e70a194217b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 10 17:48:33 2020 -0400

    Support up to 128 APB slaves

[33mcommit 79ae3ca3cd18bed11a1f4ddb4b309a27d313da39[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 10 17:47:31 2020 -0400

    rtl/src/grlib/amba: remove unused GRLIB APB controller

[33mcommit 3def4dfa3ca4b52b3de299c90b4581d9a0304f5d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 10 17:46:19 2020 -0400

    socmap: fix checks on number of coherent devices

[33mcommit ed69227f5e84e29afcdca53135d7059464fdc68e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 10 12:02:50 2020 -0400

    enable LLC-coherent DMA for up to 64 LLC-coherent devices

[33mcommit dd5928b2f20cfa9d69445302e81857177cdfa4b5[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Jun 10 00:14:29 2020 -0400

    :bug: fix S64esp script generation after changes to socmap_gen.py

[33mcommit 70862768b3c9bc1a01677dfd621e4f9c045a9874[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Tue Jun 9 14:08:25 2020 -0400

    systemc/l2: update testbench for L1 invalidation from SMA(D)

[33mcommit b74ef5d14ef5572875b0c1324eecb094be45a082[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Jun 9 03:05:52 2020 -0400

    :bug: naming change in socmap_gen.py to avoid conflict

[33mcommit 28149dbd9bb8b920feda747dc5343cda1e90e305[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Jun 9 02:53:57 2020 -0400

    :bug: fix generation of S64esp script that registers the contig_alloc driver

[33mcommit b181d53d30359fc481642ef65b4384ed50a07b15[m
Merge: 770d3b5 81d26a8
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Jun 8 14:03:48 2020 -0400

    Merge pull request #49 from sld-columbia/synth-app-dev
    
    Improve synthetic app and accelerator, improve libesp, various cache fixes

[33mcommit 81d26a8ab81a0e19ff140b7120df83208d333921[m
Merge: 514ba9d 770d3b5
Author: jzuckerman <jzuck@cs.columbia.edu>
Date:   Mon Jun 8 14:02:29 2020 -0400

    Merge branch 'master' into synth-app-dev

[33mcommit 514ba9d7d1bb3d45eaf0c9fc15816ba0701b54eb[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Thu Apr 2 17:37:16 2020 -0400

    improve synthetic application, accelerator, and libesp API
    
    - synth app reads configuration from a file
    - add python script to generate configuration
    - fix reuse factor in synth accelerator
    - add read and write data as accelerator parameter, with read validation
    - remove invalid configurations of synth accelerator
    - add p2p as an option for synthetic application
    - enable multiple allocations in libesp API, with lookup from buffer pointer
    - support multiple threads of p2p and non-p2p accelerators in libesp API
    - rename esp_cleanup esp_free
    - new runtime coherence algorithm, and tracking statistics for all invocations
    - change existing applications for new API usage

[33mcommit 20788a8eeb3f7ca6c16960cb029d523f9f751202[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Wed May 20 16:35:29 2020 -0400

    enable >2 memory tiles in contig_alloc, pass correct ddr addrs and cache sizes to kernel modules

[33mcommit c7c4442af5860b7c157b0db9c489ae655b964079[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Sun May 17 23:12:44 2020 -0400

    update mem floorplanning constraints for 2MB LLC

[33mcommit cea39e394da793cad45c70eb6e3882f6e8a3859a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed May 6 15:50:49 2020 -0400

    :bug: systemc/llc: fix recalls on S and SD state

[33mcommit 765a1dd20c78018d24a9234db1e8b77ddf931254[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Thu May 28 12:42:03 2020 -0400

    pipeline monitor signals from memory tile in profpga-xcvu440 to resolve timing issues

[33mcommit 2ad394820a183f5cfaefd9a8108853a0181874bc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 5 19:07:19 2020 -0400

    :bug: accelerator L2 wrapper holds flush until last request is accepted
    
    This solves a potential race condition: if the last line is written to
    the accelerator's cache after the flush, a processor, or another
    accelerator may request that line from the LLC before the accelerator's
    GetM reaches the LLC.
    Accesses are not protected by locks, because we always assume
    accelerators execute in mutual exclusion on their dedicated memory
    region. As long as flush is triggered after the last write has occured,
    any further request to the LLC will be handled properly and may incur a
    recall.

[33mcommit 770d3b53cb294ddc41c8d78b2e3994e3b4fd49a2[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Fri Jun 5 20:50:35 2020 -0400

    bump cache submodule
    
    -fix recall from Shared state
    -fix data width issue in L2 that manifested with >= 1024 sets
    -fix inferred caches in localmemory

[33mcommit 8eae9f08fc632d9e60cd65f439daa8280231e7dd[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jun 5 17:26:34 2020 -0400

    socs/common/tile_io: fix interrupt acknowledge

[33mcommit 6e746d499bd5720e4d77876aa535315ebc007db2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 3 23:21:20 2020 -0400

    socmap: update APB addressing for accelerators w/o extended address

[33mcommit 802c4d4dbb8822bdb26c4ddc0d412e715864ed45[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Jun 2 22:16:05 2020 -0400

    profpga-xc7v2000t: Linux SMP disabled by default

[33mcommit d342336ce4196a3abd9885a92841f6dc83c9da6e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 2 18:23:47 2020 -0400

    :bug: fix APB extended address decoding; resolves conflict between PLIC and SGMII

[33mcommit 2597b60864d0c95d0e8232d2da174b024d977ffd[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 2 08:11:30 2020 -0400

    constraints/xilinx-vc707-xc7vx485t: fix VC707 board part number for Vivado 2019.2

[33mcommit 40e317a09373f6824f9b162fab610654deda6f1f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed May 27 19:02:52 2020 -0400

    rtl/include/sld/sldcommon: add SLM number to memory count for  monitor component declariation

[33mcommit 52fb98468def3d05fbf5cea7ff35fe56dc3e9427[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed May 27 19:01:40 2020 -0400

    sldgen/templates/noc2axi_interface.vhd: remove frame buffer from memory count

[33mcommit dccd388e816fad3675a48b7871385fdc5eeb5339[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed May 27 13:28:12 2020 -0400

    vcu128: fix size of memory model for simulation

[33mcommit 96260cd764243f18d992a86b853b9778417b998f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed May 27 13:26:31 2020 -0400

    :sparkles: add shared-local memory tile

[33mcommit a0fd0bbf4cebd61b68ed73975afe7fe6471d2ed4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed May 27 13:16:20 2020 -0400

    add shared-local memory device with AHB interface; configurable 1 to 4 MB

[33mcommit 5f7e7e750094e0b6cb9bba2db19cfaf68b329763[m
Merge: 3ae2606 fdd1044
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 27 14:29:48 2020 -0400

    Merge pull request #46 from sld-columbia/nvdla
    
    Complete NVDLA integration. Improvement of third-party accelerator integration flow.

[33mcommit fdd1044d872bc4e32d7382aef57efe67b392e889[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 27 14:00:46 2020 -0400

    update nvdla sw submodule: remove unneeded error message

[33mcommit 34ae6db3d1456793cfb611c7d85a2225219c8707[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 27 05:18:00 2020 -0400

    nvdla sw: improve debug prints and revert DMA address range

[33mcommit 7f3100090cf0c1b04f97152000eac45560c18cf0[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 27 05:13:12 2020 -0400

    socs: add to gitignore the constraint file generated for profpga-xcvu440 FPGA

[33mcommit 2c0846469858a982dbbd00525e55437f11bfe8f2[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 27 05:09:27 2020 -0400

    utils/socmap: restructure the third-party accelerator constants
    
    - move user-defined constants to a new file: thirdparty.py
    - the remaining constants are now fixed for all thirdparty accelerators

[33mcommit 563f38c43570f2fbcd84a0e74217154e1cefeddb[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 27 04:26:11 2020 -0400

    nvdla sw: add support for multiple NVDLA instances

[33mcommit 3ae26065bcdea8d1c6bf09db0f5de7f6ec97ea0b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon May 25 08:18:08 2020 -0400

    change voptflow in modelsim.ini; fix Ariane simulation in Modelsim 2019.2

[33mcommit b1cdfec3d7529e7126039f67ff5febccca67cc07[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun May 24 08:41:24 2020 -0400

    pads_unisim: use vcomponents for synthesis

[33mcommit 36717e487b981295b1c4777f5b6df090b666471a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun May 24 07:47:43 2020 -0400

    pads_unisim: fix simulation issue on Modelsim 2019.2

[33mcommit 36854ba31f08c9f09e6d7dfcf6b30d59ab52c2b5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun May 24 07:45:59 2020 -0400

    fix distclean

[33mcommit eaf1b0a03a9c403469b87489f0bdee96b682e668[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 21 18:43:27 2020 -0400

    Makefile: fix vsim.mk target

[33mcommit 9485f25c64a56e5ca9b08473269bea93d286c802[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 21 10:49:28 2020 -0400

    socs/common/tile_io: fix comment

[33mcommit 5b2c56001d1de029ecdebfb7ca7901c48ebcbc21[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 19 18:01:20 2020 -0400

    :sparkles: add support for Xilinx VCU128

[33mcommit 8d37bd186a5d63014cc1dec9cf0a9bb2d39ae198[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon May 18 14:39:24 2020 -0400

    add gitignore to shared cache folder

[33mcommit c610199a6f616912e3b5d14662f3afbce9b6fce6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon May 18 14:38:54 2020 -0400

    Vivado tcl open_hw is deprecated; replaced with open_hw_manager

[33mcommit f8ec81a86b137dcb82f06cb83ebe6e01917d9b5a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon May 18 14:38:07 2020 -0400

    RTL simulation uses shared cache for Xilinx libraries

[33mcommit 44b1753f5fe8db81d836062c57ca8eb049a01965[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon May 18 14:36:55 2020 -0400

    Bump Vivado and Modelsim to v. 2019.2

[33mcommit 1d73a81a375955d1f7fbdd17c783d78aff523000[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon May 18 12:03:57 2020 -0400

    :bug: fix fixed-point datatype in the Vivado HLS accelerator templates

[33mcommit 2e75608fa81f7aff23ded6fc33d01e3ac9e7725c[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon May 18 12:02:44 2020 -0400

    compile also VHDL files present in the  folder

[33mcommit 0287cdfe1e7ca393510d32c0a6bc2b36347a0076[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed May 13 17:00:50 2020 -0400

    :bug: templates/drivers_hls4ml/app: fix input and golden output read from file

[33mcommit 8434708a5fdacb6a2b744cda341937157e710715[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed May 13 11:37:06 2020 -0400

    :bug: fix hls4ml includes order for older gcc

[33mcommit 07aa7064abd11c0c05be19090bffb4c98df1c1d9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed May 13 11:05:35 2020 -0400

    :bug: update hls4ml flow according to commit 15ded1357b1913c6dfbce21f5252d10982b2691b on Vivado HLS flow; close issue #23

[33mcommit bae9b118090d34f321e2b9bc03509fa6d94a45a9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 12 15:43:18 2020 -0400

    :bug: src/sld/tile/mem_noc2ahbm: fix DMA busy state to prevent loosing the bus before last address

[33mcommit 06ae7e4c0c5dece00a4cc26fe134371e68429d36[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 12 15:42:11 2020 -0400

    src/sld/caches/l2_acc_wrapper.vhd: declare constant signal as const

[33mcommit 39993ffdc6d2bb48f6712efc912c015b4844e0cc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 12 15:41:05 2020 -0400

    drivers: fix adder device name

[33mcommit 12e9eaea6355a69daa92054d1411c1ae9b82f8a1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 12 15:40:10 2020 -0400

    ignore memory floorplan XDC

[33mcommit 15ded1357b1913c6dfbce21f5252d10982b2691b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 12 15:37:29 2020 -0400

    :bug: fix and improve Vivado HLS accelerator interface; issue #23

[33mcommit efa2e78faaa9959c56ff3485779401e1061d8195[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon May 11 17:12:49 2020 -0400

    utils/accelerators.mk: fix hls working folder init

[33mcommit 7ff94f785192af237613cafd753b10b4aed4f480[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri May 8 15:53:48 2020 -0400

    src/techmap/unisim/pads_unisim.vhd: add optional component defaults to fix profpga simulation on Xcelium

[33mcommit 45add86c3bebcd3decb17553037333b5a23af9ac[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri May 8 15:52:47 2020 -0400

    Makefile: fix Xcelium flags

[33mcommit 9c2f8d399066ffe8ca77380a3bb837a918f67fd8[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 7 09:11:23 2020 -0400

    rtl/src/sld/noc: fix issue #42 on single-flit routing

[33mcommit a1a97a9bb0bd8b29efa75e7e61389ebe18622c80[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 7 16:31:41 2020 -0400

    Makefile: improve dependencies for simulation; fix issue #43

[33mcommit bac0488e5da959a0284182b0911b01c3268afe61[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 7 09:11:23 2020 -0400

    rtl/src/sld/noc: fix issue #42 on single-flit routing

[33mcommit b1a0fe45791b5dbc864a17bd68da56b985970a17[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed May 6 17:07:02 2020 -0400

    Revert "Modify lenght of accelerator interrupt NoC packets from 1 to 2"
    
    This reverts commit 0d9f242b55a7e932077008aa3a14a7da3cc10048.

[33mcommit 1c5e5e93cc854bf6584db0aa88c15b7e51233442[m
Merge: c5e63d2 c1eca1c
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed May 6 17:05:23 2020 -0400

    Merge branch 'nvdla' of github.com:sld-columbia/esp into nvdla

[33mcommit d616c38fd2db64f67093bec00d0806ae46faf27b[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon May 4 16:28:12 2020 -0400

    automatic accelerator generation: force lowercase device ID
    
    - Fix issue #36
    - Accelerator device driver for Leon3 requires lowercase device ID

[33mcommit c5e63d236328ac7d808d62eb705e5391cdf25fc6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 30 15:23:20 2020 -0400

    rotuer: delete trailing white spaces

[33mcommit c1eca1cf7cd779768c5460714882a5eda55a5a39[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Apr 29 03:26:38 2020 -0400

    update nvdla-sw submodule: adjust execution time measurement scaling

[33mcommit 1c7e454df418d18795cb1f8cf8babc55294bc4d5[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Apr 29 03:25:36 2020 -0400

    update nvdla-hw submodule: modify AXI burst length from 1 to 4

[33mcommit 0d9f242b55a7e932077008aa3a14a7da3cc10048[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Apr 29 03:22:10 2020 -0400

    Modify lenght of accelerator interrupt NoC packets from 1 to 2
    
    - This is a temporary workaround

[33mcommit 2d5675a796c03f17181c1760bfa0086e59842bcf[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Apr 29 03:19:48 2020 -0400

    Add support for accelerators with level-sensitive interrupts

[33mcommit 0e8694649d2e5f7763153a2a904b3d1c75a062d3[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Apr 29 02:53:19 2020 -0400

    Fix typo in decription field of NV_NVDLA.xml

[33mcommit de006f23094a953dd68bd21bbac00597223ca801[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 24 12:08:29 2020 -0400

    socs/xilinx-vcu118-xcvu9p/top: expand memory model to prevent simulation errors

[33mcommit e130ec63b4f018911a2c243a7e8453eb6b975da0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 24 11:56:22 2020 -0400

    socmap: fix ariane.dts for native ESP accelrators

[33mcommit c1b7f4b952094bb12d1f7652a6e0d1dea87b5f52[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 24 11:55:58 2020 -0400

    socs/commomn: fix pconfig extened for sgmii

[33mcommit cd8b86f3c5035d40ad05040cf45115124b3b352f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 24 10:15:26 2020 -0400

    Extend APB address space w/ second pair of addr/mask for decoding

[33mcommit ff94cf8723b12d276cb53a3967f70f97e970f8b8[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 23 17:40:32 2020 -0400

    socmap: enable multiple instances of a third-party accelerator

[33mcommit cb44ad1d19585192e70dbc56db375e7927e97067[m
Merge: 900cf27 6f097cb
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 23 15:30:58 2020 -0400

    Merge branch 'master' into nvdla

[33mcommit 900cf27367171e29a340de087bb5fd1e63ae7ec7[m
Merge: ae1b2cb 87524b6
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Apr 23 12:31:01 2020 -0400

    Merge branch 'master' into nvdla

[33mcommit 6f097cb4fd19af7ecddc0ff17c429f4262776d47[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 22 17:28:41 2020 -0400

    socs/common/tile_cpu: detect exit and stop simulation for RISC-V automatically

[33mcommit 90978ed673e1988ee68c77802bed469228446ce6[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Tue Apr 21 11:34:31 2020 -0400

    caches: fix l2 reset

[33mcommit 87524b664c4d2889075d961b36ed12cc58fa0ab5[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Fri Apr 10 16:05:50 2020 -0400

    modify NoCConfiguration.py
    
    -enforce 3x3 NoC for multiple memory controllers only on profgpa-xcvu440
    -remove requirement of distributing 1MB LLC over multiple memory tiles

[33mcommit 0b78d8a310f38ef4cf6bd70e56736a8ee7ed3cbd[m
Author: Guy Eichler <geichler@tlv.cs.columbia.edu>
Date:   Thu Apr 9 17:13:01 2020 -0400

    Added mm64_rt64.v to profpga_verilog

[33mcommit eb8dbadde3952890f755653d7385c7da7ae84cc1[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Apr 8 23:22:28 2020 -0400

    :bug: Add L1 invalidation in L2 caches in state SMA(D)
    
    - Fix issue #31
    - Fix both SystemVerilog and SystemC caches

[33mcommit ae1b2cb0a5abaf82d3463b620f6f025faa1aa752[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Apr 8 19:16:07 2020 -0400

    bump NVDLA sw submodule to most recent commits
    
    - update submodule
    - update a few Makefiles and scripts to match the new NVDLA sw

[33mcommit 10f6218caa9e3c4cf8115f941560d4f8de583247[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Tue Apr 7 15:55:48 2020 -0400

    caches: update consts file for BRAM reduction

[33mcommit 7d35c920b3437d2c6392ff5f8d7e433d85b492d2[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Fri Apr 3 13:31:08 2020 -0400

    Caches: switch from 512x32 BRAM to reduce utilization

[33mcommit f41a17b652c374aed561e7254fb1e1aab5c1921b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 1 17:16:27 2020 -0400

    Makefile: always check that Xilinx Vivado environment is setup properly

[33mcommit 6d6f518d01029d793b50ad33bc8b05cb4b7d17f5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 1 17:15:24 2020 -0400

    Makefile: do not compile ProFPGA RTL if not targeting ProFPGA boards

[33mcommit 3049e47eb5be2b6020fc1cd33c1bd09212d33449[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 1 17:09:28 2020 -0400

    Makefile: Xcelium and Incisive ignore intovf.
    Some VHDL conversions may overlow when the output of the conversion is not used
    (e.g. we use integer conversion when receiving the length of a transaction, but
     the same NoC FIFO may carry address values. The integer conversion of an address
    can oftentimes exceed the maximum lenght of a transaction).

[33mcommit bb927a3381cad558faf0d57b70c3b2d39bcd05ac[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 1 16:56:43 2020 -0400

    soft: add bare metal unit test for dummy accelerator

[33mcommit f12aa6d929c37ef70341b501502f935d1270f680[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 1 16:54:54 2020 -0400

    Makefile: esp-config-distclean deletes cache_cfg.h

[33mcommit b68f0215b6a0f8e469d2b95194bc5194cee7bd33[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Mar 31 11:27:12 2020 -0400

    bump syn-templates submodule

[33mcommit 969bb84c71063d33576f5bfe17bd250a585944a8[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Mar 31 10:38:20 2020 -0400

    add missing verilog include dirs to Xcelium and Incisive targets

[33mcommit dfe43eb131d9baadacc4d211f6f1cf50134fc417[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Mar 28 23:43:56 2020 -0400

    build_riscv_toolchain.sh: swap SSH Git clones with HTTPS

[33mcommit 76f109c08bd8d9c9683106dbcd21c53ece7a547d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 26 11:54:42 2020 -0400

    :bug: remove false positive error in `dummy` accelerator simulation
    
    - the simulation wrongly reported an unsupported DMA width

[33mcommit 9ddb1d9ac55f1fda11ca41b6f56ca03fcefa1a39[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Sun Mar 22 18:37:03 2020 -0400

    fix cache testbenches to support varying number of ways
    
    -L2 testbench supports 4 and 8 ways
    -LLC testbench supports 4, 8, and 16 ways
    -use 2 encoder split (instead of 4) in LLC lookup to support 4 ways
    -fix simulation warnings in L2 and LLC RTL that arose during fixes

[33mcommit 7e29a87a624d75ce0e057347cb857cd36e6ae60f[m
Merge: 5f0f335 efd6c9c
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 19 23:24:43 2020 -0400

    Merge branch 'hls4ml'

[33mcommit efd6c9c07b34578cb37eee236c5f7ca009aa67aa[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 19 23:19:57 2020 -0400

    :sparkles: add hls4ml accelerator design flow: accelerator generation
    
    - add hls4ml flow to interactive script for accelerator generation. It
      generates ESP accelerators that encapsulate hls4ml accelerators,
      C++ accelerator testbench, Linux device driver and unit-test
      application, bare-metal unit-test application.
    - add templates used by the interactive script for the hls4ml flow

[33mcommit 94245553eda4c83a0b90cdd5a0298f0aa87a2002[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 19 23:13:35 2020 -0400

    :sparkles: add hls4ml accelerator design flow: accelerator integration
    
    - hls4ml converts ML models in Keras/Pytorch/ONNX into accelerators
    - add hls4ml accelerators folder
    - add Makefile targes for the hls4ml design flow
    - add automatic generation of accelerator tile socket for hls4ml accelerators

[33mcommit 2c202db7bfba44577da12cae5c5dd67e4df29cea[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 19 23:04:32 2020 -0400

    automatically add .dat files to RTL simulation
    
    - The RTL of accelerators may include .dat files. Now the ESP design
      flow automatically adds them to the RTL simulation.
    - The RTL of hls4ml accelerators includes .dat files.

[33mcommit 5f0f33564146858bb561b82b7091d5605a49650b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Mar 19 22:51:02 2020 -0400

    soft/examples: add multifft

[33mcommit 7480771bdd90962eb74de4fbdd0a9cece1bd9355[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Mar 19 22:50:32 2020 -0400

    add targets for example applications

[33mcommit c73c30ec156d6e70d611858c4154cdd5f65b6937[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Mar 19 22:23:18 2020 -0400

    :bug: remove automatic fixed-point flag selection for FFT
    Compilation would fail with more than one FFT in the SoC;
    Users are responsible to adjust the fixed-point configuration in software;
    TODO: read HLS config from accelerator registers to determine fixed-point type

[33mcommit 76175320dc82314d181de8daf501d00e265c966b[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Wed Mar 18 22:08:09 2020 -0400

    caches: enable use of RTL cache_cfg in SystemC testbench; re-implement misalign timing fix

[33mcommit b2791926f387023331dbc853a9b21bd8a4c3aaa3[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Sun Mar 15 13:19:15 2020 -0400

    caches: cleanup changes from timinng fixes

[33mcommit 99b759d73f1fc13ffcccea7dd27b940d2ba7d511[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Sun Mar 15 11:39:09 2020 -0400

    :bug: fix singlecore ethernet issues with RTL caches by reverting misalign timing fix

[33mcommit d9595be388d314234db685c01ec36af427f21e6c[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Fri Mar 13 15:13:20 2020 -0400

    :sparkles: add support for multiple memory controllers on proFPGA-xcvu440
    
    - automatically generate floorplanning constraints from SoC config
    - partition LLC among multiple memory tiles for SystemVerilog caches
    - fix critical timing paths in LLC
    - set SystemC testbench to have same default parameters as RTL

[33mcommit e558c1970f62ad394cb35bc55c7dbd157b7a6f49[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 12 13:59:53 2020 -0400

    Improve printouts of SPMV accelerator bare-metal test

[33mcommit fcb873ea61b059ec70b14f93cac883bb25d46f12[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 12 02:55:31 2020 -0400

    Fix bare-metal app for 'adder' accelerator
    
    - Minor fixes: accelerator ID and restore the for loop iterating
      over all the instances of the 'adder' accelerator in the SoC.

[33mcommit c86d57e6b25194f141140d0931e50056c9304f03[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 12 02:53:30 2020 -0400

    Add placeholder bare-metal test for 'dummy' and 'vitbfly2' accelerators
    
    - These tests have not been implemented yet. The application compiles
      and runs, informing the user of being a placeholder.

[33mcommit c47d282a0d0a9a01a17688381bacdd83aab6a7f4[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Mar 11 22:05:42 2020 -0400

    :bug: Add scrollbars to ESP GUI so it doesn't get cut on small screens.
    
    Fixing issue #28.

[33mcommit 62154c583a9c179ebec2671b516152e57dce6332[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Wed Mar 11 17:51:15 2020 -0400

    added endianness to cache_cfg.svh, fix dma_addr with new cache timing

[33mcommit c71f5dbad54f3dc9510dbb061fb2358380273345[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Mar 11 17:28:59 2020 -0400

    Improve ESP GUI with better 'cache config' section and more checks and error messages
    
    - More intuitive selection options for caches
    - Add checks and error messages regarding enabling caches, caches size, number
      of CPUs, number of memory tiles, number of columns and rows (fix issue #26).

[33mcommit 9a1dd91a91e41c98338bdf47e5b25f831b95ddd1[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Mar 8 03:07:11 2020 -0400

    utils/grlib: revive bare-metal tests for Leon3 multicore

[33mcommit ca0eb5143d265ab49b3949f599b7c32f3f99fbb8[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Tue Mar 3 11:12:17 2020 -0500

    caches: fixes for input port warnings, timing improvements for 4 memory controllers setup

[33mcommit c7d878d3d83176584086a7d304c2bedeca3f4a49[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 27 12:42:31 2020 -0500

    accelerators.mk: fix hls-work folder generation for Vivado HLS

[33mcommit 794a0a99b9601a31a25e5bcb472d209b225bf497[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 18 14:08:39 2020 -0500

    utils: remove paths not relative to ESP_ROOT

[33mcommit a6d3b5a92d6036137b1a4332c8fa18ead363490c[m
Author: Joseph Zuckerman <jzuck@cs.columbia.edu>
Date:   Mon Feb 17 01:12:15 2020 -0500

    caches: cleaned up verilog files

[33mcommit 036d628776d60bde4245b33e3de32f767c86914c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 12 15:48:50 2020 -0500

    fix sldgen dependencies to pass correct parameters to RTL caches

[33mcommit 485f84a2a46a854ff7b21522f5dd117328b2ae8e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 12 15:25:31 2020 -0500

    RTL cache instance takes global system parameters

[33mcommit 973e398a36a40fb6ceffdab29bfd7f886fdfde3c[m
Merge: 875632a 7465422
Author: joseph <jzuck@cs.columbia.edu>
Date:   Tue Feb 11 18:05:38 2020 -0500

    Merge branch 'dev-ariane-smp' of https://github.com/sld-columbia/esp into dev-ariane-smp

[33mcommit 875632abc0cead9d6857aaf72f3b1598c7b1c2da[m
Author: joseph <jzuck@cs.columbia.edu>
Date:   Tue Feb 11 18:05:16 2020 -0500

    caches: merged changes for recalls to support non-inclusive LLC

[33mcommit 746542280e9a95601ba15951e48938162d8f4af9[m
Merge: 1d6e101 908198c
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 11 15:50:59 2020 -0500

    Merge branch 'master' into dev-ariane-smp

[33mcommit 908198c944ef4ecd076902a88085ed148c6dd5b1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 11 15:36:59 2020 -0500

    Update support for Incisive and Xcelium; WARN: Ariane needs patching for Cadence simuators and is not supported on Incisive

[33mcommit ee0d27ade9081408fb2f61aa4c69d6af632b581e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 11 11:04:06 2020 -0500

    :bug: fix label for accelerators instance by adding prefix

[33mcommit 1d6e101db940eeae69db1826ebafb5f4945cc7d1[m
Merge: 2d4923c f2c875e
Author: joseph <jzuck@cs.columbia.edu>
Date:   Mon Feb 10 20:36:06 2020 -0500

    Merge branch 'dev-ariane-smp' of https://github.com/sld-columbia/esp into dev-ariane-smp

[33mcommit 2d4923cca9077c97d6682a1b2ec7fa544e0d1c1f[m
Author: joseph <jzuck@cs.columbia.edu>
Date:   Mon Feb 10 20:35:17 2020 -0500

    caches: backpressure fixes for 4 core support, optimizations for forwards in L2

[33mcommit f2c875e61746855d8e30263858df8faa8fce219f[m
Merge: 34e060d 790792e
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 10 16:46:12 2020 -0500

    Merge branch 'master' into dev-ariane-smp

[33mcommit 790792ecb87b9c9bfa2c48fc2ec722520d4a90c2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 10 16:45:50 2020 -0500

    Add placeholder driver and applications for Chisel AdderAccelerator

[33mcommit 34e060d0b134973276c08fe7dc10d6482d5207aa[m
Merge: 6baf1c2 e099fcc
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 10 15:06:59 2020 -0500

    Merge branch 'master' into dev-ariane-smp

[33mcommit e099fcc9a0b8c9c575c1cde2e66307ada63fe1af[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 10 15:04:11 2020 -0500

    Bump chisel submodule to update FFTAccelerator

[33mcommit 75fe0dedfd4e307aaf2dcfbd8f592c577ca67ac4[m
Merge: fd6670c d1c4292
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 10 14:57:45 2020 -0500

    Merge pull request #21 from sld-columbia/fft-chisel
    
    Bump chisel submodule for FFTAccelerator

[33mcommit fd6670c97b5ec1f4ac8c6a3e71ca8767dfebebc6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 10 14:55:24 2020 -0500

    change visionchip ID to fix conflict with Chisel

[33mcommit 6baf1c23b91e9eb585b3c60bcb1c8bf4ae48a766[m
Merge: 1e9de46 c462c99
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 7 17:17:03 2020 -0500

    Merge branch 'master' into dev-ariane-smp

[33mcommit c462c99bd005e07a1d94bb4f485980d8c463576f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 7 17:16:26 2020 -0500

    local Makefile does not define LINUX_MAC; ESP GUI will take randomly generated value

[33mcommit 1e9de46735d0e5e801a42e0785eb2d513eb1d323[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 7 17:13:42 2020 -0500

    :bug: sldgen generates RTL l2 and llc instances even when no HLS-based caches exist

[33mcommit b69b851f002753c12931c2de41ad0a9f9218c762[m
Merge: 4595b58 5ece756
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 4 18:03:10 2020 -0500

    Merge branch 'master' into dev-ariane-smp

[33mcommit 5ece756b9e5c29dd982d8b243a3d232087903563[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 4 18:02:32 2020 -0500

    Makefile: add vivado-update target

[33mcommit 4595b5832d1f41a055198ea8dd02a8010b966d41[m
Merge: 888e172 b73f2d2
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 4 12:55:02 2020 -0500

    Merge branch 'master' into dev-ariane-smp

[33mcommit b73f2d2d7b4b2a5cd1fc728dc8d6da60b5b96d4b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 4 12:53:24 2020 -0500

    defconfig: use consecutive MAC/IP pairs for debug link

[33mcommit 888e172b29da497f61f6eeb400005855117f7f29[m
Merge: 94de47e f0b3a7d
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 4 11:06:40 2020 -0500

    Merge branch 'master' into dev-ariane-smp

[33mcommit f0b3a7d881407fdb21c73805ee041426477bef86[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 4 11:05:40 2020 -0500

    socs: add optional network configuration to local Makefile for shared FPGA boards

[33mcommit f2ee6f29ebe5e3bbf3c730358414bb076a9d93fa[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 4 11:02:59 2020 -0500

    Makefile: force esplink target to run in case the IP address or the service PORT changed

[33mcommit 5991fc4165eb4b669ca8e5fc84b1f6cd26f979a2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 4 11:01:59 2020 -0500

    Makefile: add uart, xuart and ssh targets when FPGAs are shared remotely

[33mcommit 4ab879e614c01ef2dbeb1e4d83f2c49c5df2baec[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 4 11:00:16 2020 -0500

    design.mk: accept override value for Linux network interface MAC

[33mcommit 7be128df6cffb3837fb29779c727fc34bde1bd8c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 4 10:59:33 2020 -0500

    esplink: accept overwrite value for ESPLink IP

[33mcommit 5b9672afa0fd8251e808ca5159777d75766e02c1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 3 12:34:49 2020 -0500

    change proFPGA configuration TCP port to custom value. This is configuration dependent

[33mcommit 94de47ec095e3c75ecef299ca0c2c1539fc8c736[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 29 15:47:45 2020 -0500

    :sparkles: Add RTL caches to the ESP configuration

[33mcommit e22fdca47d2a01095ba75f63a8f4d6e7e8a1aa60[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 29 15:35:23 2020 -0500

    esp-caches: update submodule

[33mcommit 0733ef4aba94487e25fb760af7df0c4b345d7a39[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 29 12:33:51 2020 -0500

    add RTL caches

[33mcommit e3e8d7691d35ca15b26885d281cf0e37873f4913[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 29 23:01:31 2020 -0500

    utils/scripts/templates/stratus_hls: improve timing of accelerator template

[33mcommit de914c40951629a1c8751bb4452fa2ed3dbc4acc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 29 12:26:01 2020 -0500

    :bug: disable p2p for soft/leon3/drivers/synth/app/synth.c

[33mcommit e7580436795f7462e058f0c03da781005c7a6053[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 29 12:25:07 2020 -0500

    :bug: fix adder and synth accelerators conflicting ID

[33mcommit c79ef6ee3fe687aba4e464b72d2c6ed8049515c6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jan 27 10:41:27 2020 -0500

    Update timing settings for profpga-xcvu440 with DDR4:
      This is a workaround to achieve stable operation of all DDR4 cards
      - Change memory freqeuncy to 1400 ps
      - Change input frequency to 11200 ps
      - Enable all 72 bits of data, even if using 64 on the app interface
      - Si5338 generates a 45MHz reference clock (workaround)

[33mcommit 3f2a07e4b4643ef35a00c865375229abb7769007[m
Merge: 08a58d1 126a1b5
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 22 15:26:35 2020 -0500

    Merge branch 'master' into dev-ariane-smp
    
    Conflicts:
    	socs/defconfig/grlib_profpga-xc7v2000t_defconfig
    	utils/socmap/esp_creator.py
    	utils/socmap/esp_creator_batch.py

[33mcommit 126a1b5d6347c1f312a79ba53886257288129a53[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 22 13:19:51 2020 -0500

    update gitignore

[33mcommit cb353381fbdf62e0c6d386e7b4df5015bb20e323[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 22 13:18:56 2020 -0500

    ariane.dts: use randomly generated MAC address

[33mcommit 694e1ef3d2ac79fb5616f420b3a753b7017bbc35[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 22 13:04:19 2020 -0500

    riscv_buildroot_defconfig: configure networking, password, hostname and welcome message

[33mcommit 452a105e1e5d81db873729230bf367ff252b3cde[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 22 12:54:23 2020 -0500

    soft/ariane/sysroot: remove S40fixup from overlay

[33mcommit aeab55fe723cc44272ea81cd739909d34906e9eb[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 22 11:39:37 2020 -0500

    leon3_busybox.config: revert passwd algorithm to des

[33mcommit e27308eaeb8231461c5997986be653733973545c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 22 10:08:37 2020 -0500

    :bug: fix Leon3 toolchain flow on Centos 7 by using buildroot
     - Upgrade compiler to gcc v5.5
     - Upgrade root file system to default from buildroot
     - Automatimcally set hostname, welcome text and root password
     - Get DHCP IP address upon boot
     Fixes issue #24

[33mcommit 26bce17d01957a1786c6815032a4696e347e3dc7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 22 10:05:13 2020 -0500

    Makefile: Linux image on Leon3 takes random MAC address

[33mcommit affe2225b9933b9632c4b064500d62a026eb48c5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 22 10:03:54 2020 -0500

    Makefile: fpga-program target waits 5 s for DDR calibration

[33mcommit c3070b92cf113ee83e478ff37e0340c4cd764a2c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 22 10:03:05 2020 -0500

    update Leon3 cross compile prefix to default sparc-linux-

[33mcommit 7ad16e1251fead96ff0c18fcaf17a3da97267050[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 22 09:52:05 2020 -0500

    socs/defconfig: change default IP for EDCL to avoid conflicts w/ DHCP assigned IP addresses

[33mcommit 2fdc419d610a1aa64085a0c14a7f40d0afdd3f1f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 21 11:29:19 2020 -0500

    soft/leon3/sysroot: save only sysroot overlay for buildroot

[33mcommit 08a58d188edb6deea487055508b44e4f200ea5bc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jan 17 17:23:04 2020 -0500

    profpga-xcvu440: decouple DDR clock from main ESP clock

[33mcommit be4ad62a0ae4e4ba173e9a4843ec9f2e16f91c8b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jan 17 17:19:44 2020 -0500

    profpga-xc7v2000t: update profpga IP

[33mcommit be2fc38e1a31a229f3001d5dac1d23217063618e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jan 17 17:19:10 2020 -0500

    rtl/src/techmap/unisim/clkgen_unisim: fix Virtex Ultrascale clkgen

[33mcommit bf1072af1846d582f599e462a6cc2cc4e4d22d5f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 16 00:09:05 2020 -0500

    socs: add profpga-xcvu440 design

[33mcommit 051041b9a9e1bfb516c3521bff8385d594344f36[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 16 00:06:18 2020 -0500

    Makefile: add support for TCL script to generate MIG for DDR

[33mcommit 13dd291980d46e03052f1785988a8d62e53018d8[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 16 00:04:52 2020 -0500

    tile_io.vhd: update comment about frame buffer address

[33mcommit 076d4636ccc8df99837efdc2caa196981389dfa7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 16 00:03:37 2020 -0500

    add support for Virtex Ultrascale to HLS flows

[33mcommit b2b0c39a515ef11016a733425f9fbf4927e0048d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 16 00:00:46 2020 -0500

    support profpga monitors for Virtex Ultrascale

[33mcommit 388981e5775965dfe95d02594b7000a1532de795[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 15 23:55:13 2020 -0500

    rtl: add support to grlib components for Virtex Ultrascale technology

[33mcommit d168e13d2ddcb8f706540cd2f969691cff62eb0c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 15 23:49:19 2020 -0500

    soft/leon3/linux: update submodule

[33mcommit 71d05381978851eab2ac1c605bd31aead371cd9e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 15 23:47:04 2020 -0500

    update design configuration for profpga-xc7v2000t

[33mcommit b41fc190eb711891758bc0519cfce2217d9e834c[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Jan 13 15:14:03 2020 -0500

    :bug: Fix sporadic bug at the interface of Vivado HLS accelerators
    Fixes issue #23
    Fix done in utils/sldgen/

[33mcommit 4f7ad08a79023eba28b0a16509d1b082c5808177[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 9 16:21:55 2020 -0500

    :sparkles: enhance FFT accelerator:
      - Select fixed-point length 32 or 64 bits from HLS config
      - Enable/disable bit-reverse computation at runtime
      - Reserve register to enable peak computation for mini-era application (not implemented)
      - Remove unused ping-pong buffers

[33mcommit 8ffbafcfcf8d36dd16c58a27717e1bde19369890[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 9 16:12:18 2020 -0500

    soft: enable EXTRA_CFLAGS

[33mcommit fe7aedcde0904db879e84f349e8c4337d7251bf4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 9 16:08:13 2020 -0500

    :sparkles: accelerator socket supports big endian 64-bits data tokens on 32-bits NoC

[33mcommit db834e8c6fe7e7cd3f8b90be38ff1bdedf87dbf8[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Dec 17 12:12:50 2019 -0500

    sldgen: add default TLB entries and HLS tool for partially specified accelerators

[33mcommit 1b351fb6d1b06ec07c9e64225b49b7d6072882e3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Dec 17 12:12:12 2019 -0500

    utils/esplink/dumphex.sh: do not redirect dump to file

[33mcommit 57e23cf42ee8af61b57fd580cd199dbf3508c933[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Dec 17 12:11:33 2019 -0500

    utils/grlib/leon3_sw.mk: enable program selection for baremetal simulation and emulation on Leon3

[33mcommit b722b540a0e622f90ffe0b72716834d3e6d9aaa6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Dec 17 12:10:54 2019 -0500

    utils/accelerators.mk: fix Chisel accelerator install

[33mcommit f49b4b79273c2dbff52b9616a078aa54f2bf0eb3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Dec 17 12:10:17 2019 -0500

    soft/ariane/bootrom/startup.S: move stack pointer to boot Linux w/ large root file system

[33mcommit 6d10a0c7069eb96475c28631590a424ea586248f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Dec 17 12:09:18 2019 -0500

    Add device driver for FFTAccelerator

[33mcommit 8c6cef2750995f8e1ddca0067e2a6ebc2355c536[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Dec 12 13:37:22 2019 -0500

    riscv_buildroot_defconfig: disable OPENSSH
      - We use dropbear instead, that allows ssh into the ESP system
      - This removes the rcu stall that was occuring at times at the end of the boot process

[33mcommit e8278a09eb4f780af0ae76a208ee5a8a80364aea[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Dec 19 00:39:27 2019 -0500

    :bug: Fix timing closure problem of the last-level cache on the VCU118 board
    
    Fixes issue https://github.com/sld-columbia/esp/issues/22
    Feature added in systemc/llc/stratus/project.tcl

[33mcommit d1c42922d36ba5a0e2fbea8424de4ac570be3cc9[m
Author: Schuyler Eldridge <schuyler.eldridge@ibm.com>
Date:   Wed Dec 11 00:58:44 2019 -0500

    Bump chisel submodule for FFTAccelerator
    
    This updates the esp-chisel-accelerators submodule to pull in a
    direct/SDF FFT accelerator generator. This supports fixed point data
    types <= 32 bits in width and point sizes less than 512.
    
    Signed-off-by: Schuyler Eldridge <schuyler.eldridge@ibm.com>

[33mcommit ddaca94a7a7a4deab860d322d61dadb0305dab3b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Dec 4 15:31:12 2019 -0500

    Add FFT accelerator for Stratus HLS

[33mcommit 574a664b8a63833091a739ea22da54e3a24583d2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Dec 4 15:20:42 2019 -0500

    accelerators/stratus_hls/common/systemc.mk: allow local Make to add flags

[33mcommit 0d0e9a6a17236f993a3cc50c959f9f638a79ab2c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Dec 3 14:45:08 2019 -0500

    :bug: Do not share interrupt lines on RISC-V
    
    Resolves issue https://github.com/sld-columbia/esp/issues/20

[33mcommit efdb6bfcf1f3958693b0dfc98f17d346dbb6ad90[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Dec 3 14:43:26 2019 -0500

    vitbfly2: fix baremetal app to run; validation will still report errors

[33mcommit bd466d253ff4ef3eca53f4c8279c1b2decd5d5b7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Dec 3 14:43:01 2019 -0500

    vitbfly2: fix descriptor configuration in user-space app

[33mcommit 59859261afb22437374b1a4e9ac0c0e2aaf7897b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Dec 3 14:42:13 2019 -0500

    Fix profpga constraints when mmi64 is enabled

[33mcommit e1800e01c7de658146de6ae58c12ac39cd47fc5c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Dec 2 16:50:49 2019 -0500

    update NV_NVDLA sw submodule to fix typo

[33mcommit 3a5bd27e7c9f6989d864a7ab9317c8c68b826756[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Dec 2 16:38:19 2019 -0500

    README: fix typo

[33mcommit 6a37d5f46d9b815a00b2ec1952c9d6fa1f14c039[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Dec 2 16:35:39 2019 -0500

    third-party/accelerators/dma64/NV_NVDLA/vendor: fix typo

[33mcommit 090f3670863b0f5d29344dfbcc5cc1c98d133620[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Dec 2 16:33:16 2019 -0500

    esplink: fix overflow on load percentage for large Linux images

[33mcommit 2c60795f03972e12c25d67ace3dced89fd7b406c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Nov 22 14:25:41 2019 -0500

    accelerators/stratus_hls/sort/stratus/project.tcl: add dma64 to HLS configurations

[33mcommit e3821fc2b770378701ed44d2a59ded06817c54f4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Nov 22 14:22:47 2019 -0500

    Makefile: update dependencies
    
    baremetal binary and loadable for RAM model get always updated when TEST_PROGRAM is set
    fpga-run depends on the baremetal program and on the bootrom binary
    fpga-run-linux depends on the bootrom binary and fpga-program
    TODO: propagate soft-reset to all components to remove the need for fpga-program on reboot

[33mcommit afd7aebf2e1eb0b059ba0fc8e1559dbf87ce012d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Nov 22 14:19:51 2019 -0500

    Update and cleanup example applications to reflect contig_alloc updates

[33mcommit f54f8c3c9204f94d2b62d9f45e4a0c7bf773f6d6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Nov 22 14:17:34 2019 -0500

    :sparkles: ESP Library API update to avoid copies of data:
      - esp_alloc returns a single virtual address, like malloc
      - contig_alloc is hidden from the user and makes a single call to mmap
      - remove esp_dump, which is no longer necessar
      - remove contig_alloc pages user-space test, as there are no more pages in user space
      - update libesp, contig_alloc-libtest
      - update accelerator initialization script to reflect these changes

[33mcommit a025806927a1147df3c9989266c423c3ef308db4[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Nov 22 03:18:41 2019 -0500

    :sparkles: Replace polling with interrupt in RISC-V device driver
    
    Resolves issue https://github.com/sld-columbia/esp/issues/17
    Feature added in soft/leon3/drivers/esp/esp.c

[33mcommit dc0b67bee7f4f2ed244d6421b6671eab6e82a3ae[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 20 14:52:24 2019 -0500

    :bug: Interrupt controller unreachable for Leon3-based SoC
    Bug introduced by commits for centralized RISC-V PLIC.
    Bug fixed in socs/common/tile_io.vhd

[33mcommit ec07fdc2bb12b791fc17849a1d3dbf5a8cf21fea[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 20 14:51:15 2019 -0500

    :bug: define RISC-V CLINT constants even for Leon3 to fix compilation error

[33mcommit 14bc4c45e49b9a007947e288dfa7526984af87e2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 20 14:50:59 2019 -0500

    :bug: drive unused RISC-V irq signals when selecting Leon3

[33mcommit 7f24cd37385d6dc7e6bb10bebffbf961fc15d01f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 20 14:49:51 2019 -0500

    :bug: fix wiring on 32-bits system for mem_noc2ahbm

[33mcommit 06977f9f2cc4cd87c7cfab98c7f91b8edfb330b5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Nov 19 21:15:49 2019 -0500

    sldgen: add SiFive CLINT entry to device list

[33mcommit 3a8736a6dfefc3ac9a0abdad00544225af1cfaf2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Nov 19 17:59:52 2019 -0500

    move RISC-V CLINT to miscellaneous I/O tile

[33mcommit 129c543669535ecf4c6b9d25f7e231cccc04ae48[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Nov 19 17:57:07 2019 -0500

    rtl: enable 64-bit AXI to 64-bit AHB transaction with narrow 32-bits NoC between cpu_axi2noc and mem_noc2ahbm2

[33mcommit 7e38ab128199ce00e951d0583dcf3a33c5dab563[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Nov 19 17:52:56 2019 -0500

    rtl/src/gaisler/axi: add ahb2axi_l from rlib-gpl-2018.3-b4226

[33mcommit 6d79c143da9c402bca78b29fd0c7c2c712e869f0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Nov 19 17:48:56 2019 -0500

    sysroot: add dropbear

[33mcommit 9532527d36663d144bd048a89f6c84a659dacd8f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Nov 19 17:31:49 2019 -0500

    ariane/sysroot: set root password

[33mcommit 7133087c3896615324deb0c636356e17cf148a40[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Nov 19 17:17:33 2019 -0500

    update submodule soft/ariane/linux

[33mcommit d70f9c92dd1b8b3e87aeb57c5155f858dbe3ceef[m
Merge: 19b7f08 f64be30
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Nov 19 17:15:19 2019 -0500

    Merge branch 'master' of github.com:sld-columbia/esp into dev-ariane-smp

[33mcommit f64be3008fddc6ecede74b34a074241700eb1401[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Nov 19 12:24:26 2019 -0500

    :bug: Incorrect accelerator nodes in Ariane's device tree
    
    Fixes issue #16: https://github.com/sld-columbia/esp/issues/16
    Fixed in utils/socmap/socmap.py.

[33mcommit 179f980a560c531f2ea29796b93813e5678810aa[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Nov 15 02:59:39 2019 -0500

    Fix README.md
    
    Correct link to the ESP website

[33mcommit 1f2638c2fe29cff7b03e3169359248a9d3f34128[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Nov 15 02:58:27 2019 -0500

    Update README.md to highlight the ESP website
    
    Push up in the description the links to the ESP website

[33mcommit 7f6d9582bca82d46481c46f476d1b0847c23c23b[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Nov 15 02:51:15 2019 -0500

    Create CONTRIBUTING.md

[33mcommit 19b7f0891e6f51fc1fde77d92a24e64d9d092cc5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Nov 14 13:53:24 2019 -0500

    utils/Makefile: cleanup clean target for device drivers

[33mcommit 6b86c75e55657f70d76a5f76082a54861b4d4a30[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 13 17:45:25 2019 -0500

    README: add paragraph about NVDLA

[33mcommit 3998c6c0f7bfe4aa6fc488c93212bfb3c944debd[m
Merge: aa0893a 74d65ea
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 13 17:37:21 2019 -0500

    Merge branch 'master' of dev.sld.cs.columbia.edu:esp/esp

[33mcommit aa0893a3b655ce6c9bb8dc4e7ebb524fbbccf47e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 13 16:52:12 2019 -0500

    src/sld/tile/cpu_axi2noc: buf fix on DMA message types

[33mcommit 2dfa3eefff341345cd45d50b7e5e721636f8e6db[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 13 16:51:10 2019 -0500

    soft/ariane/sysroot: change memory mapping of reserved regions to enable NV_NVDLA to run next to ESP accelerators

[33mcommit 1aba789d1bdf085e9ae915aa4b240c6dc17f11d2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 13 16:49:43 2019 -0500

    NV_NVDLA: fix socmap and device tree generation

[33mcommit 6a78b76c1ce171f3fa4169974802fc00769c60ca[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 13 16:49:06 2019 -0500

    sldgen: bug fix on third-party accelerators:
      - Add APB plug&play information
      - Mask APB address MSB
      - fix empty flag of unused NoC queue
      - drive to zero unused DVFS transient flag

[33mcommit 29bd94cd7d4b099da9a1153ffb0428798943e2cc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 13 16:46:31 2019 -0500

    utils/accelerators.mk: always recompile third-party accelerator software

[33mcommit bb83ec8e1c8cc3b190a368bd4ef0827735fd5b89[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 13 16:46:04 2019 -0500

    utils/Makefile: minor improvements to Linux and FPGA targets

[33mcommit deab814d47c63eb261e45ffb56ecd5281021f0d5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 13 16:45:03 2019 -0500

    NV_NVDLA: bug fix on APB clock and reset

[33mcommit 725c5259582610213f4cedfc2c238bbe23df45ce[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 13 16:44:44 2019 -0500

    NV_NVDLA: decouple sw and hw make targets

[33mcommit 253581c609c06bcfea59520c3681ab9743f4236e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 13 16:43:56 2019 -0500

    update NV_NVDLA software

[33mcommit 74d65eacd5c3368514e08dcb21033648decbbfba[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Nov 13 14:57:37 2019 -0500

    :bug: Fix ESP config GUI stuck in self-updating infinite loop

[33mcommit b25300549f13a1071a6ef12ecf32e462f7d234d1[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Nov 13 01:52:05 2019 -0500

    Update issue templates

[33mcommit 38539f0b839fb13b72d7ca834218548cf6a297c4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Nov 7 11:51:05 2019 -0500

    NV_NVDLA config: use default python3 instead of python 36

[33mcommit e3ec76cfadc97ead7d2a4d17bfa393aba4478e45[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Nov 5 17:41:37 2019 -0500

    profpga-xc7v2000t: update clocking to ease time closure w/ Ariane

[33mcommit 74f4178326cf3fa73c2a1504ed2039a50e41302f[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Nov 5 21:45:47 2019 -0500

    utils/grlib/mkprom2: support Ubuntu by increasing a char array size

[33mcommit 88d6b6706df9514db9458d42cbdef9878830fdf5[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Nov 5 19:37:16 2019 -0500

    utils/scripts/init_accelerator.sh: support Ubuntu, it has a different version of rename

[33mcommit 2a3b6569cfc6a02534d425c6e05ec86c6d388eb7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Nov 5 13:30:13 2019 -0500

    Move RISC-V PLIC to miscellaneous tile

[33mcommit c653606a4758395169ef0d388b3d9c3664fa7ef0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Nov 5 13:28:46 2019 -0500

    Enhance APB: extended-address mode and pready

[33mcommit f05236d2a1d4d334dc02abc37a39ec6cf2de9710[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Nov 4 12:26:18 2019 -0500

    utils/scripts/build_leon3_toolchain.sh: add compile flags to compile binutils on Ubuntu

[33mcommit c7cbb0b1fa2d2eb474fc3fc62f1b7ab68933b90e[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Nov 4 12:24:19 2019 -0500

    utils/scripts/build_leon3_toolchain.sh: BUGFIX remove some softlinks before creating them

[33mcommit 507a32e6bdc2a5dca385beed0cff0d7dc82fc0d5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Nov 1 14:41:41 2019 -0400

    update soft/ariane/linux: enable GRETH driver

[33mcommit eea72cc0e80363d5b06a4f1ccd806451c910ca42[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Nov 1 13:13:47 2019 -0400

    Add 1MB Reserved area for Ethernet to device tree

[33mcommit 7388e47c0cd9392a7f8b902fc0f3abb4e83034ac[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Nov 1 12:10:50 2019 -0400

    socs/xilinx-vc707-xc7vx485t$: do not simulate ETH by default

[33mcommit cf1fd7320ae92c78329c4d49e24bda07cc261d93[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Nov 1 11:41:03 2019 -0400

    soft/ariane/sysroot/etc/init.d/S40fixup: send DHCP request after boot

[33mcommit 84df4b182d89777736f085b14eef09b498c2fcb4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Nov 1 11:39:08 2019 -0400

    socpma adds Ethernet entry to Ariane device tree

[33mcommit 91897d8a68074dd0abc098a4bf25ffc428728f4d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Nov 1 11:37:35 2019 -0400

    update submodule soft/ariane/linux: GRETH support for RISCV

[33mcommit 1ea2c383a91c835192bb67d5a61528dfaffe2051[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Oct 30 17:36:24 2019 -0400

    xilinx-vc707-xc7vx485t: enable Ethernet MAC TX simulation

[33mcommit 4680f649eff3d959b53e76d8618c755e3906a634[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Oct 30 17:35:59 2019 -0400

    rtl/src/sld/tile/cpu_ahbs2noc.vhd: add commented mark_debug attributes

[33mcommit 4e17d37f5595bcb656810d51f35a2d767772c597[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Oct 30 17:35:31 2019 -0400

    WIP Ethernet: enable non-coherent DMA for Ethernet when ESP caches are not present

[33mcommit 972a469f5e04ad48cf9b20bdc200c4662e812426[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Oct 17 14:52:51 2019 -0400

    bump profpga version to 2019A-SP4

[33mcommit e5e869de8b2288b2da025f7cd725da0424e4c064[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Oct 17 14:48:11 2019 -0400

    profpga monitor: fix interface for corner cases of no accelerator or no caches

[33mcommit 29b218398783f0f512e09081473d84402b430aa9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Oct 17 14:41:44 2019 -0400

    Makefile: remove esp_global.vhd on clean

[33mcommit 23aff6967bb3827521520514796daf40df09047d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Oct 16 12:05:38 2019 -0400

    update gitmodules: use https instead of git SSH URL

[33mcommit 93bf147a396aa0277eef562b1e91fe31aa35cba6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Oct 16 11:24:16 2019 -0400

    ESP Generator GUI: bug fix on processor type selection.
      - Update Info about FPU
      - Update list of available accelerators and HLS implementations
      - Update DMA_WIDTH variable

[33mcommit fd11dee735d0a267b481dd2e67f6468aee9e11ed[m
Merge: 43e01e7 9a044ea
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Oct 14 16:38:27 2019 -0400

    Merge pull request #7 from sld-columbia/devel
    
    Devel

[33mcommit 9a044ea0ee709465843593c0b8841013b181991d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Oct 14 16:26:27 2019 -0400

    utils/scripts/init_accelerator: add print statements and minor bug fixes:
      - SystemC tb uses correct data_width for in, out and gold
      - device driver ID replace string corrected for Leon3
      - app prints accelerator configuration
      - pass output offset to esp_dump

[33mcommit 88a5bf0c5bf0c4a836c19b68b0827b1f2133b90c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Oct 14 15:51:53 2019 -0400

    libesp: fix esp_dump to take offset from user app

[33mcommit 6c39400b18236e1c0ac6617d389ba15811d5a531[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Oct 14 15:47:39 2019 -0400

    Makefile: user can specify TEST_PROGRAM for simulation and baremetal execution

[33mcommit e505aa2290c57e258316e977cc96bf32469873f4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Oct 14 15:45:25 2019 -0400

    utils/sldgen: mv l2 and llc component declaration to RTL include

[33mcommit 6a999e8a7df772792bb94db707d65cde48ddd054[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Oct 8 14:59:53 2019 -0400

    utils/scripts/init_accelerator.sh: generate Vivado HLS skeleton

[33mcommit 5daa883861214bf31c192e4cc047b1cba867dff7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Oct 8 10:29:34 2019 -0400

    vitbfly2/app: fix Makefile

[33mcommit 56fc64a11b17f592bdcc7f4deeeff587b2dea83a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Oct 7 16:25:36 2019 -0400

    utils/scripts/init_accelerator.sh: force transfers w/ base address aligned to DMA_WIDTH

[33mcommit 1a9c277e34e22ef0e2433ed4c3b36ec39c52c566[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Oct 3 14:47:32 2019 -0400

    utils/scripts/init_accelerator.sh: add device driver generation

[33mcommit 9c3cd8058f11da5ab6b038a2da10c41c3025d43a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Oct 3 14:12:39 2019 -0400

    soft: add comments to libesp to insert new accelerator info

[33mcommit 01044be39dcb36122862d06bafb84acc05ba1043[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Oct 3 14:11:55 2019 -0400

    soft: esp_accelerator.h defines round_up macro for user apps

[33mcommit 5a36d92c3c459a05fdf6419282f1a0a1d3a0f1e3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Oct 3 14:11:09 2019 -0400

    user apps link libesp

[33mcommit afc82172994e76bc09cfced6d1eeaa17a7ebdea5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Oct 2 11:26:07 2019 -0400

    utils/scripts/init_accelerator: interactive accelerator skeleton generation for Stratus HLS

[33mcommit cc4b60bf5a7a7f846f06b15535bd32533ab62e4a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Sep 27 15:18:35 2019 -0400

    socmap GUI: update colors of tiles

[33mcommit f23853e912223d7584972013975e68e8a186d28d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Sep 27 14:24:47 2019 -0400

    utils/socmap/socmap_gen.py: BUGFIX set correct timebase-frequency in Ariane's device tree

[33mcommit 931ceb6f3388f58e773f6361308bc5f04d0c13b6[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Sep 27 14:22:28 2019 -0400

    utils/scripts/init_accelerator.sh: add support for Vivado HLS flow and update path for Stratus HLS flow

[33mcommit db7913fd435bcc46bb26eb14ed4d50ac5f2bfdc7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Sep 27 14:19:01 2019 -0400

    accelerators/stratus_hls/dummy: fix dma32

[33mcommit 0bdae9dfab9d2e1ce78aa25bcc471b9de27f0d22[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Sep 27 13:16:00 2019 -0400

    update visionchip:
      - add dwt enable, src/dest registers to descriptor
      - accept 8-bits input pixels
      - fix maximum image size
      - add datasets for baremetal test

[33mcommit 968c14116aea085b901d29ad385f2de72a13a51b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Sep 27 13:13:15 2019 -0400

    systemc/common: update path stratus HLS base scripts and Makefile

[33mcommit eb98a322aea48c994f20208551dd7a817f2a5479[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Sep 27 13:11:19 2019 -0400

    add Vivado HLS flow for accelerator design w/ example

[33mcommit b5b14038e95d00d4f2529c3aa3d7243eb0ab16f0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Sep 6 16:43:41 2019 -0400

    Makefile: fix list of RTL sources for third-party accelerators

[33mcommit d18377c828105f80430438a2dc1d0af244ed5410[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Sep 6 16:43:17 2019 -0400

    design.mk: suppress verbose notes from vopt

[33mcommit 4b2e2973ab4ae42a99680a1a9310541a553367ae[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Sep 6 16:42:53 2019 -0400

    accelerators.mk: third-party accelerator wrapper is not compiled if IP is not generated or VOPT throws an error

[33mcommit c0703c6d3a9749f732e49ceeb2cdba56a9d8bbdd[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Sep 5 23:21:44 2019 -0400

    Update Ariane submodule

[33mcommit 794b4bbf99b81805639209fa386fe028dd7fd4b0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Sep 4 14:59:05 2019 -0400

    soft: libesp cleanup takes no arguments

[33mcommit ea9192312ef16bca5cd45efad9e1217091b0308b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Sep 3 17:25:32 2019 -0400

    soft: add simple version of multi-threaded runtime for ESP accelerators

[33mcommit a5d6ee692b2424bbf7f8ed38b9b7fabe5c632248[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Sep 3 16:35:05 2019 -0400

    soft/ariane/linux: update submodule; enable preemption

[33mcommit d5940bfba8a70d2a524f925be7f63f59ba530a09[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Sep 3 16:34:14 2019 -0400

    soft: fix test library Make

[33mcommit f15d35464e0c8bf44ab1e2b04be048f9fecc246a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Sep 3 16:31:13 2019 -0400

    soft: move driver header files to include folder

[33mcommit 761b537707a97ede3a0dacedc78e0bb197a64f1f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Sep 27 12:27:39 2019 -0400

    mv Stratus HLS accelerators to accelerators/stratus_hls

[33mcommit 3e185119a0fd61eeb004fef2f2288530f2ccdc7e[m
Merge: 862abbf b95c51e
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Sep 27 11:16:21 2019 -0400

    Add point-to-point or P2P communication
    Merge commit 'b95c51e7d48b5722d7e466d1b1dff31789aeda7c'

[33mcommit 862abbf7983ff448dfbac59fa39e93ce3bffede8[m
Merge: 3939479 5da095f
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Sep 27 11:13:47 2019 -0400

    WIP NVDLA: add submodule and integration targets
    Merge commit '5da095f3e99985304c9e6feebf83f61d48d30baa'

[33mcommit 3939479f5c44461098a7611178fe3af9ff6324f6[m
Merge: 532e3c3 120e2df
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Sep 27 11:12:55 2019 -0400

    utils/script: update stratus accelerator template
    Merge commit '120e2df003dfa5e4bec1297bcb3f8a104660650e'

[33mcommit 532e3c3d8faebbee0705e964c3b05975ac069f78[m
Merge: 43e01e7 bd74068
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Sep 27 11:11:21 2019 -0400

    visionchip: dwt enabled from software
    Merge commit 'bd74068c86736f11bc69b6b06f6ffb32aa2819ac'

[33mcommit b95c51e7d48b5722d7e466d1b1dff31789aeda7c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Aug 30 21:38:03 2019 -0400

    rtl/src/sld/sldcommon/acc_tlb: fix sensitivity list

[33mcommit f1dcc98165ffb9591dd7e1e6f312de5d709133a2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Aug 28 21:49:00 2019 -0400

    soft: ESP Linux driver supports P2P; add P2P test w/ dummy accelerator

[33mcommit 116c2043197b94f1d02535e78c832df70d8e19b4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Aug 28 21:46:08 2019 -0400

    dummy: bare-metal driver tests more complex P2P behavior

[33mcommit 59707a537654488b2866818c9dbb71b1fce5cc78[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Aug 28 21:41:52 2019 -0400

    soft: bare-metal esp driver resets p2p register by default

[33mcommit 65be863a2a48e59032efcc0aa5b41143625af6f8[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Aug 27 16:49:52 2019 -0400

    RISCV ariane: enable rmmod

[33mcommit 8f68517928150a143f4cf4c54e4e72efe2c542ec[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Aug 27 12:50:13 2019 -0400

    soft: improve dummy test application

[33mcommit 12b04f113385a1a8844e429a1d54e3c4d43aa043[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Aug 27 12:49:32 2019 -0400

    soft: dummy device driver overrides srt/dst offsets from user input

[33mcommit bfb2bc5e767c0c3e1667bd029e399b353806fa05[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Aug 26 22:47:19 2019 -0400

    soft: add basic Linux driver and test application for dummy device

[33mcommit f2983903bedd38b2df30b4c4198dd999d7243e60[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Aug 26 22:45:21 2019 -0400

    soft: add contig_read64/write64 to libcontig API

[33mcommit c79958d79a9712c72209032894479bc79d9f8eb8[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Aug 26 22:44:03 2019 -0400

    soft: esp driver runs accelerator-specific xfer prep after esp_transfer; user can override dst/src offsets

[33mcommit b8ce1873eb2b4ff1d77e8055ac0ee705e5df906e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Aug 26 22:43:00 2019 -0400

    soft: add pthread to LDFLAGS for user applications

[33mcommit 7bfaece31b61ac43ca389273ac2f4677725db2a7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Aug 24 23:13:24 2019 -0400

    soft: add bare-metal driver for dummy w/ p2p test

[33mcommit 6feb87805605525d1c3f47e90e0fc681b9aeab41[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Aug 24 23:12:24 2019 -0400

    rtl: add p2p communicaition for ESP accelerators

[33mcommit ecb9fe6cc97b7c01bdbbbb3d0acf11020b9970a5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Aug 24 23:10:56 2019 -0400

    soft: update bare-metal code to configure p2p communication

[33mcommit 3d2fbca9d10b356e9eaaa9616527c5fe46b5946b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Aug 24 23:08:44 2019 -0400

    accelerators: add dummy device to test point-to-point communication

[33mcommit 5da095f3e99985304c9e6feebf83f61d48d30baa[m
Merge: 120e2df abaeb1b
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Aug 22 16:37:00 2019 -0400

    Merge commit 'abaeb1b0df658234f81dfb9a5268fbc62e34a3ae' into ml-merge

[33mcommit 120e2df003dfa5e4bec1297bcb3f8a104660650e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Aug 22 16:32:59 2019 -0400

    utils/script: update accelerator templates

[33mcommit a00a7570197f239dbbb718b5d3e535a387533b6c[m
Merge: bd74068 43e01e7
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Aug 22 12:09:18 2019 -0400

    Merge branch 'master' into ml

[33mcommit 43e01e7e0a01ebbc02868da30ca2ba4195e73d75[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Aug 22 12:08:01 2019 -0400

    rtl/src/gaisler: add little_end generic to greth and grethm interfaces; unused for now

[33mcommit bd74068c86736f11bc69b6b06f6ffb32aa2819ac[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 21 16:04:43 2019 -0400

    visionchip accel: improve configurability

[33mcommit abaeb1b0df658234f81dfb9a5268fbc62e34a3ae[m
Merge: df5ac45 5ab371c
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Aug 16 10:26:17 2019 -0400

    Merge latest updates from master

[33mcommit 5ab371cf5a11fa3165bd7d59032a382081a782aa[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Aug 15 16:53:02 2019 -0400

    utils/script/init_accelerator.sh: add CADENCE guards for SystemC simulation target

[33mcommit 983e5c632dfc451a630d9571b36937fafcea71bf[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Aug 15 16:28:34 2019 -0400

    utils/script/init_accelerator.sh: add SystemC simulation folder

[33mcommit 9a8cff7e5b074cf3d8bf30639129b1ab702a5f50[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Aug 15 16:10:21 2019 -0400

    add gitignore for <accelerator>-exe simulations

[33mcommit 8501d135996f2bbdcf2821cda970b3b9e64a5d7d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Aug 15 16:07:48 2019 -0400

    accelerators/synth/tb: fix configuration parameters

[33mcommit e40c46bcfffcdd6967ba1c8ce7e8b1a6fe76fa7c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Aug 15 16:01:04 2019 -0400

    accelerators/syhth: enable SystemC simulation

[33mcommit f3bff62844035ff099f8c6c253231e90d20d3372[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Aug 15 15:40:09 2019 -0400

    accelerators/spmv: enable SystemC simulation

[33mcommit ddbecf1d0f7559ae8f253453a9a02197a781ded3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Aug 15 15:38:32 2019 -0400

    accelerators/sort: enable SystemC simulation

[33mcommit a71cbc69fbe202b775ca4a6c461e2f58db660b8d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Aug 15 15:34:00 2019 -0400

    accelerators/vitbfly2/sim: change Makefile style

[33mcommit 096e2c2da496e0f4424c71b364e70a39b38dfb3b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Aug 15 15:32:40 2019 -0400

    accelerators/visionchip: enable SystemC simulation

[33mcommit dccbf93f76444b8b4ada14dcf6256e1dbe2cff56[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Aug 15 13:10:10 2019 -0400

    add plain SystemC simulation target for accelerators

[33mcommit b754d37fbf8e0d1e4544adbd56032cc919516958[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Aug 15 13:05:41 2019 -0400

    vitbfly2: add plain SystemC simulation folder

[33mcommit c90c2c5c48b522ee585c9cfecb3052bbc520788f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Aug 15 13:04:59 2019 -0400

    vitbfly2: remove CADENCE guards where not needed

[33mcommit e8f0971b2c689899578a4b682d8a4dac32d0b78f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Aug 15 13:04:26 2019 -0400

    vitbfly2: use only hpp for includes

[33mcommit 0fc59e29fd6dc6b6485937371f60d93a4cb4dddc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Aug 14 17:14:19 2019 -0400

    accelerators/vitbfly2: guard stratus-specific expression to sypport Accelera SystemC simulation

[33mcommit 6b3427e5328539e8c23da418dd48898d0fc0223e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Aug 14 17:12:44 2019 -0400

    update syn-templates submodule

[33mcommit df5ac45bcda4268832a698b18f8fe8addb280736[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Aug 13 16:20:29 2019 -0400

    tile_cpu: extend DDR address-space to get 512 MB reserved for NV_NVDLA.
    NB: requires at least 1.5GB DDR module on board

[33mcommit f3146e8bbf7ef6c4a83fb17b55ebd4e32cf1fc24[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Aug 13 16:17:11 2019 -0400

    soft/ariane/linux: update submodule; enable DRM

[33mcommit 51f858f05a03d8cf952c5dd84d45917e00e27611[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Aug 13 15:53:50 2019 -0400

    utils/design.mk: suppress verilog overwrite warning

[33mcommit fd15946ccacdb0a2a39c799a95679c67b1d5681d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Aug 13 15:53:28 2019 -0400

    utils/accelerator.mk: pass ARCH, CROSS_COMPILE and KSRC to third-party custom Makefile

[33mcommit 9adc9bdf7a6d377ed337c08412251755cd6c0dc3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Aug 13 15:52:19 2019 -0400

    NV_NVDLA: Makefile compiles user application and device driver

[33mcommit 04928866f562703b5ce116a1040f273ee8b6776d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Aug 13 15:51:24 2019 -0400

    add NV_NVDLA sw as submodule

[33mcommit 8dbbe65797d4f7d38ea5e4689c7c55729b57db04[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Aug 12 15:44:14 2019 -0400

    soft/ariane/sysroot/etc/init.d: add drivers autoload

[33mcommit bade6c1c8e9d528ced6a6ad21ee73c8097baf411[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Aug 12 10:16:26 2019 -0400

    add third-party accelerators' files to simulationa and synthesis

[33mcommit 677d41515d87419b23ac2f5c5e4c116c9f9bd866[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Aug 12 10:15:57 2019 -0400

    utils/accelerators.mk: add third-party accelerators targets

[33mcommit f58230e8b84b8bf426eac714e90a8ec8406f059f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Aug 12 10:14:41 2019 -0400

    utils/design.mk: suppress NV_NVDLA warnings during vopt

[33mcommit a139a084f92bc77e1cd3ea015426cca2b8fd420f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Aug 12 10:14:10 2019 -0400

    sldgen: fix wrapper generation for third-party IPs

[33mcommit dcd61e883708b6ebc62bb27bc9fcff2d5b362f54[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Aug 12 10:13:34 2019 -0400

    socmap: add custom vendor and memory-map info for third-party IPs

[33mcommit 34a31ce4a3e224ce524ffa2f4e9fc962cf7d3fe2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Aug 12 10:11:09 2019 -0400

    NV_NVDLA: add helper files for integration

[33mcommit 15ca17e9dbbe50a9c56aa654c58e61f36e0bb0b3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Aug 12 10:10:41 2019 -0400

    NV_NVDLA: fix wrapper

[33mcommit bfbb513861e4e9dfd245aadb3efdf5c2262c0581[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Aug 12 10:08:41 2019 -0400

    add NV_NVDLA ip as submodule

[33mcommit 8dbfcde648d770d11f6f84ba198d362c15def6bf[m
Author: Davide Giri <43386475+davide-giri@users.noreply.github.com>
Date:   Fri Jul 19 20:55:15 2019 -0400

    README: fix links

[33mcommit a3f23d3384b81b8fa357bae410a7f483a2d1e55c[m
Author: Davide Giri <43386475+davide-giri@users.noreply.github.com>
Date:   Fri Jul 19 20:53:59 2019 -0400

    README: temporary change links from open-esp.org to esp.cs.columbia.edu

[33mcommit eb44616be11876fadd38ac6623cb7302517e68d3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jul 16 03:33:18 2019 -0400

    update README with links

[33mcommit aa17e62a2eba9c5e4f24da4e129f925ca34f2908[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jul 16 03:29:23 2019 -0400

    add logo small

[33mcommit 36ae48c6ef204e5696c98073e9b812d83f6424b5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jul 16 03:27:01 2019 -0400

    add logo

[33mcommit e6d2d4567e952cddb63f8fd2fdaf9fe91d806177[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jul 16 03:25:18 2019 -0400

    Add main README.md

[33mcommit f31d03538a9315d38168c879c104a4277c0c4db3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jul 16 01:48:06 2019 -0400

    fix IP and MAC addresses for debug link

[33mcommit 24bda505bfd506832ca3164f8223322d28b48cac[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jul 16 01:38:55 2019 -0400

    remove all netlists

[33mcommit bd2270cd12b2a87e81bca31f662fa4736f2b756c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jul 16 01:34:06 2019 -0400

    Fix license

[33mcommit adcadefb7a70f6fc741a28ea8480f1bebf628463[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 15 17:19:47 2019 -0400

    socmap: generate device-tree entry for accelerators

[33mcommit ce5a532624e3764d9b1a0f75469cd429027c9775[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 15 16:31:39 2019 -0400

    accelerators: add vitbfly2

[33mcommit 46c77bedca30919c2b52d5ac56ccef0837a5ca80[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 15 16:30:26 2019 -0400

    fix HLS working folder generation

[33mcommit 31a79ad581aaab614d207631f9c872f4c34cc253[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 15 16:30:01 2019 -0400

    soft: improve Linux app CFLAGS

[33mcommit 318c9b153cb99bd140028ee9dfc3e5387b2ca8e0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 15 16:28:20 2019 -0400

    WIP NVDLA: fix sldgen for AXI-based accelerators w/ ESP interface

[33mcommit 196b2b5bb6fb7c3cc35af3ca5a8587115784106b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun Jul 14 01:39:28 2019 -0400

    ESP drivers on RISC-V: use polling until PLIC is properly connected; fix ioread and iowrite endian

[33mcommit c28293bb659511731bd060e185f30987b7dfba92[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun Jul 14 01:29:33 2019 -0400

    drivers/visionchip/app: print buffer size in B

[33mcommit d86f5480afe1622c7bfff6c83fbac73657f9fb87[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun Jul 14 01:25:28 2019 -0400

    contig_alloc: DMA API failed on RISC-V; replacing with virt_to_phys for now

[33mcommit 36ea2e75be6727bf60c4bd99afa37e3b0a4eb6ba[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun Jul 14 01:23:09 2019 -0400

    soft/ariane/drivers/common.mk: add test library as dependence

[33mcommit 521c1a9e7e552bdd31da7d837659d403cce87952[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Jul 13 02:18:30 2019 -0400

    WIP NVDLA

[33mcommit 32765884f2e441040a27c0105a5b0fb5d476f8ce[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 10 14:32:44 2019 -0400

    utils/accelerators.mk: fix bare metal env

[33mcommit f64237cf513f22660ff3580b5c087fe094d57b04[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 10 14:32:26 2019 -0400

    espmon: relax no activity flag

[33mcommit 8858347743017211ddff353a5de0d0735d9f490d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 10 14:31:45 2019 -0400

    utils/Makefile: reprogram FPGA on fpga-run targets

[33mcommit 18536b817a7fe494f89d573556fcdb970479102d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 10 14:09:35 2019 -0400

    soft/ariane/drivers: fix bare-metal include dirs

[33mcommit 1277d73f388b10c209683661b0812a522ec24c80[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 10 14:07:42 2019 -0400

    accelerators: change ID number of synth

[33mcommit dd4b37eb0a98fc5f6ed06381da3a3dbe378566d4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jul 9 16:07:54 2019 -0400

    sldgen: fix accelerator wrapper; number of memory nodes for L2 was wrong when frame buffer was disabled

[33mcommit 39ca2a43a2b22e828b72c0dd08aff28758f2e6f7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jul 9 16:06:46 2019 -0400

    socmap: fix check on maximum number of accelerators

[33mcommit e9f2c92fc492c254c8c466f9817942efab51373e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 8 18:27:08 2019 -0400

    utils/Makefile: add fpga-run and fpga-run-linux targets

[33mcommit ec4862278b9495f046b1ebac10372fff49511e01[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 8 18:26:51 2019 -0400

    build_leon3_toolchain: remove GRMON

[33mcommit 30254705c0bad6155d0440b0cd6c28cbb0794b1f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 8 18:26:33 2019 -0400

    esplink: add reset command

[33mcommit 14fc7041cf7de6e74c8c3810a56d7b3a4e0e864e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 8 18:25:31 2019 -0400

    socs/profpga: fix CPU_FREQ constant

[33mcommit 34e96648b6d3d12b6a27c74bfe7191af8b471620[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 8 17:03:49 2019 -0400

    utils/design.mk: fix proFPGA top source files list

[33mcommit 88b992bc9f3044ca9f6cbc5bfa32379efb94aa1a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 8 17:02:47 2019 -0400

    soft/ariane/bootrom: initialize UART w/o GRMON

[33mcommit 5096fb2b2fdc3fe021386f382f84aea0b7732c24[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 8 16:57:30 2019 -0400

    Use ESPLink:
      - remove Leon3 DSU
      - drop dependency on GRMON

[33mcommit 29fde9e877c52495d817343f7dff841f74854efc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 8 14:26:05 2019 -0400

    utils: add esplink utility

[33mcommit 80aced5daaca0d9042857fcfca837c0201673e5e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 8 14:25:03 2019 -0400

    utils/Makefile: fix PROFPGA verilog include dirs

[33mcommit 9e22ee0abab57b6931077e706b162923e3e4c4ec[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 8 11:38:17 2019 -0400

    utils/Makefile: compile bootloader and application binaries for Leon3

[33mcommit 7253f05f01badc24c2f992f6e30c3bb181d50580[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 8 11:36:45 2019 -0400

    mkprom2: do not compile mflat option, which is not supported by sparc-elf-gcc

[33mcommit 1b890fb8ad81ec27e46b96b6c161a6bdd3aafe80[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 8 01:08:46 2019 -0400

    utils/grlib/mkprom2: clear compilation warnings

[33mcommit 02a971d9001b5e3b48d991f318e371f068583ff6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 8 01:08:22 2019 -0400

    utils/grlib/mkprom2/Makefile: hide embedded script trace

[33mcommit ed16247b9e3d287828eab29cdc6be019fc3d013c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 8 01:07:28 2019 -0400

    update .gitignore

[33mcommit 20c88d7324ed9df2632dfc906f5289cc15be400f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 8 00:15:15 2019 -0400

    utils/grlib: add patched version of mkprom2; the patch skips copying program to memory

[33mcommit cf07a1a9d86db7107939384917925d02f20ad903[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jul 5 18:40:05 2019 -0400

    rtl/src/sld/tile: fix compilation warning w/ Leon3

[33mcommit 8a1cfc00723463d9f16ed275b423261efde92271[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jul 5 18:39:01 2019 -0400

    socs/common/sgmii_vc707: keep clock signal name

[33mcommit a40fb3f3d541895b646034e19fb885a801a83420[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jul 5 11:38:11 2019 -0400

    create soft/leon3/bootrom

[33mcommit 2d7e7703a4e94514daf0458d56703150d9f23b92[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 3 23:17:32 2019 -0400

    constraints/xilinx-vc707-xc7vx485t: improve Ethernet constraint to solve false timing violation

[33mcommit ad6c4eed23a0b24e8c9cb2072dd22d6272cc9959[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 3 17:10:51 2019 -0400

    soft: fix aligned_free

[33mcommit 38cd0e44f51ae1d880f9c6fd4d367da721493288[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 3 16:07:11 2019 -0400

    Update ESP accelerator interface: add data tokens size to DMA control signals to support different endianness

[33mcommit 351d47d485ef092794d401a3d8f3264386c6e46f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 3 15:56:55 2019 -0400

    visionchip: use larger test case

[33mcommit 85973df1a9e12f571bdf0f99693b155d5da855a2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 3 15:55:03 2019 -0400

    Always enable synchronizers to decouple memory tiles clock from the rest of the system. Helps timing; Update top; removing memctrl

[33mcommit ba169fce437bf5d20d8b5478199424e6a3dcd296[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 3 15:45:39 2019 -0400

    socmap: always enable synchronizers to allow design clock to be independent from memory controller

[33mcommit 482253a3898aeea0013199c9e0f38580201d7abd[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 3 15:43:35 2019 -0400

    utils/scripts: update riscv_busybox to enable insmod

[33mcommit ac3f0af7e3af16d9ca064935a29275184dce43ac[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 3 15:42:57 2019 -0400

    utils: add RISC-V software targets and fix simulation and synthesis flow for Ariane

[33mcommit 7580fd66487a139773ba08b8da4efe70b2811f6c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 3 15:40:54 2019 -0400

    Ignoring binary bin files from RISC-V compilation flow

[33mcommit a925314fc3cfad939f163f159712b7c9716414cb[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 3 15:39:45 2019 -0400

    Add RISC-V device driver support for Ariane

[33mcommit 4ee45117079c125bca13c2b07484465df3a3ec82[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jul 3 14:17:41 2019 -0400

    ariane: reserve non-cacheable DRAM addresses

[33mcommit d7386fff3d7ecddff73331d21c8039e5d8ca6889[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jul 2 12:37:09 2019 -0400

    Revert "accelerators/visionchip: fix endianness"
      - That fix works for big-endian processors only; We are going
        to keep little-endian as default and add information at the
        accelerator's interface to inform the ESP socket about the
        actual size of the data tokens (e.g. half-word, byte, etc.).
        The socket will take care of swapping data tokens accordingly
        when running on a big-endian system.
    
    This reverts commit 6f0321e785f7bb13a49398198d145842adecc794.

[33mcommit 358283a5fa3902652a75fa2d4d33b26a91a7620d[m
Merge: 304431b 88c4cce
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jun 28 12:29:00 2019 -0400

    merge master into ariane devel branch

[33mcommit 304431b9d5cafab195b5b917cb136f02a63beb84[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 27 15:28:47 2019 -0400

    soft/leon3: restructure Makefiles

[33mcommit 88c4cce4e8acc11aa63283811ecbf2386787b69c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 26 16:40:54 2019 -0400

    build_leon3_toolchain.sh: fix busybox and uclibc config files

[33mcommit 834ca57d45a304804b7dc90f1f6ee109aa98276f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 26 11:57:41 2019 -0400

    accelerators/visionchip: set HLS clock period for Ultrascale+ to 10 ns

[33mcommit c814d944c50851fd73a7d0c117fb623dbbf56689[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 26 11:56:57 2019 -0400

    utils/accelerators.mk: HLS working folder copies over input/output files

[33mcommit 377d059827b9301643f42258f7831f91aec09a54[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 25 14:26:40 2019 -0400

    utils/scripts/templates: remove blank line from memlist.txt

[33mcommit bc04c3a065c0b00a15c8bbd5dd5d7c5c0f57b036[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 25 14:25:24 2019 -0400

    drivers: complete visionchip baremetal driver w/ embedded input data

[33mcommit a20af15b8c9a89638348522544809204b4f0f4da[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 25 14:24:49 2019 -0400

    drivers: update visionchip application to optimize DMA transfers

[33mcommit 6f0321e785f7bb13a49398198d145842adecc794[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 25 14:23:29 2019 -0400

    accelerators/visionchip: fix endianness

[33mcommit 2aee0e3a4a987f1cdd01e3174661888002f70c57[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 24 15:41:45 2019 -0400

    accelerators/visionchip: add BASIC and FAST implementation points

[33mcommit 3924843e9757522bd1e05f7e0f5f2e2241feb155[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 24 15:27:53 2019 -0400

    accelerators/visionchip: optimize DMA; add 64 bits support

[33mcommit a9fbd49c53379e1461fd804c10fc20226d90f687[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 24 13:43:29 2019 -0400

    accelerators/visionchip: cleanup HLS directives

[33mcommit a7d5273bf54dd626e669e782ab6fc8cb59c851bd[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 24 13:19:07 2019 -0400

    accelerators/visionchip: histogram equalization optimization:
      - only consider relevant range of bins
      - use unsigned integer when appropriate
      - overlap buffer PLM initialization and load data

[33mcommit faa801a8c143ea3a2f5a828f6706dae9595f3f5a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 24 10:25:29 2019 -0400

    accelerators/visionchip: optimize DWT w/ pipeline

[33mcommit d27fdc8c70fb0b301b96bf142ea754a32bb509b5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 24 10:25:06 2019 -0400

    accelerators/visionchip/tb: test one image only to speedupt RTL sim

[33mcommit 7908f58a0613529424bcefb5e474549c5ce18967[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 24 10:24:30 2019 -0400

    memgen: use crossbar when distributing data; area-expensive workaround for Stratus implicit memories

[33mcommit d20309ef597e2c8d000250d6151beecf657d6f9e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Jun 22 23:00:24 2019 -0400

    visionchip: add baremetal driver placeholder

[33mcommit 4ae92271c031e2ae19ad5807bdce3439b3500b03[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jun 21 13:28:12 2019 -0400

    accelerators/visionchip: optimize loop w/ division through pipeline

[33mcommit 4b9fdd199319b88824d616eace05e6669bdab14d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 20 23:55:21 2019 -0400

    accelerators/visionchip: cleanup project.tcl

[33mcommit c702e66428c1561e080479782effb5de4469374f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 20 23:54:30 2019 -0400

    accelerators/visionchip: replace explicit memories w/ implicit memories

[33mcommit cbf0677faae43af58672a5167274d5a458d9a743[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 20 22:52:22 2019 -0400

    accelerators/visionchip/tb: cleanup

[33mcommit 25d6db5aebb95e99503cef09f3cb703cc0e4da87[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 20 22:51:59 2019 -0400

    accelerators/visionchip: fix input and golden output

[33mcommit 6e203d4db9e9e32a3e90943284aceb0b6170db82[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 20 14:36:29 2019 -0400

    utils/scripts/templates/project.tcl: add default Virtex US+ clock period setting

[33mcommit 0d9b936531617318907bafe57252eed1be4d5bb6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 20 14:35:32 2019 -0400

    accelerators/visionchip: beautify

[33mcommit 25e5f44b91e75cf22c952cd9f6f5ab1510f8fc8c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 20 14:00:05 2019 -0400

    update CREDITS

[33mcommit e6b775cbf9b3cff57b83f3bef6edb37c5ac05f3a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 19 16:04:37 2019 -0400

    accelerators/common/syn-templates: submodule points GitHub repository

[33mcommit 73a19d86fad1ffbd0d8e4a043b08867aa84ad416[m
Merge: cb63f0d 0c53395
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Jun 19 12:04:50 2019 -0400

    Merge branch 'visionchip'

[33mcommit cb63f0df39e7d379b1af462d290532e5b15c6374[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri May 3 02:05:24 2019 -0400

    soft: improve prints of user apps

[33mcommit 6294a040504dd09255c21e81a5b809fd5090d2cb[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 29 13:00:32 2019 -0400

    BUGFIX of sim clock in project.tcl of ESP accelerator template

[33mcommit 24d8be723a5b9612f2354a50c5b90ad67a96e790[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 12 12:09:03 2019 -0400

    xilinx-vcu118-xcvu9p: set refclk to 78 MHz to guarantee timing closure

[33mcommit 4cc6600ec6bd8d44eb744b4d293435ececaf5e46[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 12 11:15:27 2019 -0400

    utils/Makefie: vivado batch mode requires update_compile_order -fileset

[33mcommit 1b2a8429a4e8e0751ba0d1d280d3a20d6af00ecd[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 12 11:13:31 2019 -0400

    WIP socs/common: ariane integration w IRQ on processor tile

[33mcommit 8c3cd4f47ac23c8af3af8d1138190064542debda[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 12 11:12:41 2019 -0400

    socs/common/tilem_mem: fix proxy endiannes

[33mcommit d14359b6cbd5052fd565be51b6ab5fb8b89b0062[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 12 11:11:35 2019 -0400

    src/techmap/unisim/clkgen_unisim: fix Ultrascale PLL using MMCME4_BASE

[33mcommit 2c74dbecdf727e461788424971bcc60fa922950e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 12 11:10:55 2019 -0400

    xilinx-vcu118-xcvu9p: attempt setting system clock to 125MHz

[33mcommit 59034c7c4855417e1bb4bd1251ae5575c0b4beb5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 11 18:08:31 2019 -0400

    constraints/xilinx-vcu118-xcvu9p/mig: additional clock added to MIG IP

[33mcommit 9f13002bb64adbee43a1e0d6501fde9202de54de[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 11 18:07:58 2019 -0400

    socmap: vcu118 requires synchronizers always

[33mcommit a7832133b3023d7a88b4f470c92c3a09ffc3a78d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 11 17:02:39 2019 -0400

    socs/xilinx-vcu118-xcvu9p: update top and testbench: use bootram and slower additional user clock from MIG

[33mcommit 1691f80a91a54c1208f1256ca39c81773494f50e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 11 17:02:08 2019 -0400

    constraints/xilinx-vcu118-xcvu9p: additional user clock from MIG

[33mcommit f9940e31fb2e147f41fe9c63360bf41a90e68073[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 11 11:32:28 2019 -0400

    socs/common/sgmii_vcu118: add keep attribute on 125 MHz clock

[33mcommit 6661b7f08e648c45f844ca4b0afd0598548ea682[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 10 17:20:11 2019 -0400

    socs: update hello world for RISCV bare metal

[33mcommit 65461042181ea88cb6fba602dd62cd8efd84cfae[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 10 17:19:04 2019 -0400

    socs: update Makefile to allow for CPU ARCH choice

[33mcommit 213e740a70748b63e09030cc220d34239eb2e52d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 10 16:50:57 2019 -0400

    update defconfig

[33mcommit 6487b69e1d3e981a7b3e6bf331f38ceee7401671[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 10 16:50:21 2019 -0400

    socs: update .gitignore

[33mcommit 33e1225a9e6e15b49f176bd4446a3d176f092af3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 10 16:49:18 2019 -0400

    utils: update ariane RTL and software targets

[33mcommit 0bcc484b62ba5025a83bd747eb7ffaa96f2a406e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 10 16:48:18 2019 -0400

    socmap: fix SoC configuraion with no cache hierarchy

[33mcommit c62e597e8421beda3b3a61cd68d0d7348d6eaba7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 10 16:47:34 2019 -0400

    utils/scripts: update RISCV buildroot flow

[33mcommit df7f225514ebe3b92f28a3b8f1626d26d84bcdc9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 10 16:33:03 2019 -0400

    soft/ariane/sysroot: disable nfs

[33mcommit 34d0772bfc6ef8ea393bcc38f3506c680c6def5a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 10 16:10:31 2019 -0400

    soft/ariane: update linux submodule

[33mcommit 90a43bf7b1882fbcf14bfc4909c1e41a40ea0869[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 10 15:59:46 2019 -0400

    update ariane submodule

[33mcommit 581f526425fb696dc85f606b6e1788f7f4dae44d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 3 13:09:10 2019 -0400

    cleanup PROM and bare memtal systest build for Ariane

[33mcommit cd1cc5923afd0478ebedbf5ca927e46d83989844[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 3 11:30:56 2019 -0400

    add submodule soft/ariane/riscv-tests

[33mcommit b1b8b8ad86ea147956bc489de37984b99cef291e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 3 11:26:43 2019 -0400

    utils/script: add RISCV toolchain build script

[33mcommit b16542dafe4bd43c080b78b78400f3fea02b633e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 3 10:35:41 2019 -0400

    soft/ariane/sysroot: add ariane's default sysroot overlay from ariane-sdk

[33mcommit d80e016d5d41af2b824f05325782fd24233e91b9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri May 31 17:59:11 2019 -0400

    add soft/ariane/riscv-pk submodule

[33mcommit 40c14432442a65a2d9dfcbd8956468f6aa840b89[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri May 31 15:16:06 2019 -0400

    WIP utils/socmap: generate ariane device tree

[33mcommit c4b110654bd5171bad708fa12ab79b0242ee3a28[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri May 31 13:09:48 2019 -0400

    WIP utils/socmap: support for Ariane-bases SoC map generation

[33mcommit 669d27a2ba583f8d5487745666c1e750981ff866[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 30 18:32:32 2019 -0400

    utils/design.mk: set different simulation opt. for ariane

[33mcommit c92c1b58fb9137eace51c2995a6b581f499a689d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 30 18:31:31 2019 -0400

    constraints/xilinx-vc707-xc7vx485t reduce frequency to 81MHz

[33mcommit 8c6ea67a1f466873713f44d79e814433a30be394[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 30 18:22:02 2019 -0400

    sim/src/gaisler/sim: fix ahbram_sim model

[33mcommit a0e888d9bdbbfe7ad9921c9cf3331986e09b7132[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 30 18:20:41 2019 -0400

    add  third-party/ariane submodule

[33mcommit 4446ae819bfdf8f8d20fe00a8dba17b9cf42a3bf[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 30 18:14:51 2019 -0400

    remove ariane and ariane-sdk submodules

[33mcommit a15dcfcd3f6e87c6f29bc34403dd2704724a7e22[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 30 17:56:04 2019 -0400

    rtl/src: fix ariane wrapper

[33mcommit b0c8912b102cb531c392f0c5d8b4c42499a2cf82[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 30 17:55:17 2019 -0400

    rtl/src/sld/tile: fix NoC proxies for 64-bit NoC

[33mcommit 5c2c754fe1f71f9b1d09f0732d3af075a388181a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 30 17:53:26 2019 -0400

    rtl/src/gaisler/misc: updage ahbram for bug fix

[33mcommit 4cea0e4e32e8cbf1b8202efdded991d87d771551[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 30 17:52:07 2019 -0400

    add submodule arch/ariane/linux

[33mcommit 0c53395d95d5fe13654984fa05853b4443acfe0f[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri May 3 02:06:11 2019 -0400

    change arguments of visionchip user app. change outfile path.

[33mcommit 7496771ffaba68caec8f91c0dfcdddaa011c1515[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri May 3 02:05:24 2019 -0400

    soft: improve prints of user apps

[33mcommit b5c1588afa7e5a78d7e68aea6e188de53d315378[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu May 2 02:38:55 2019 -0400

    visionchip linux app: bugfix, tested on FPGA

[33mcommit fe26d76d8b16086a11e82fe5443c181144798672[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu May 2 02:38:00 2019 -0400

    visionchip accel: change protocol regions to have success hls on vc707

[33mcommit efa5a562eace7fb8f87a518342ecc78b04509301[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 1 05:17:33 2019 -0400

    visionchip driver: remove programmer's view files not needed anymore

[33mcommit aa9f3d33978466c4f78da612cb2a391ebfd06622[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 1 05:08:15 2019 -0400

    visionchip accel: testbench. Support for multiple input images and multiple accelerator invocations

[33mcommit c0f6573f23707767f64c4656e26f5e78e7eb6364[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 1 05:06:08 2019 -0400

    visionchip accelerator: systemc sources, big upgrade
    - support multiple input images
    - support multiple accelerator invocations
    - go back to large PLMs and support input images smaller than PLMs
    - bugfix: reset PLM values when needed to be ready for the next invocation

[33mcommit f7f20829603574819b39cb666d855b8e47577495[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 1 05:05:22 2019 -0400

    visionchip accel, project.tcl: add virtexup option and go back to large PLMs

[33mcommit e2901294004712e8151017abc68c47576848498a[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 1 05:04:21 2019 -0400

    revert memlist of visionchip accelerator to large PLMs

[33mcommit 30bbd8fe65a203f6b01d36784f868e691f3910d5[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 1 05:03:59 2019 -0400

    add nimages config reg to visionchip accelerator

[33mcommit 2df7bd7d961f1336404a910779889966c1dc673d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 1 05:01:12 2019 -0400

    visionchip user app: big upgrade that compiles but is untested

[33mcommit d2c4df49c7e2378c399619ef6497320436e76fe4[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 1 05:00:40 2019 -0400

    visionchip driver header: add nimages config register and max bound for cmd line args of user app

[33mcommit 4b06b2e1187d06dbfcd197aee15a3123b353cdd0[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 1 04:59:52 2019 -0400

    visionchip driver: add nimages config register

[33mcommit 8c936482651d7a9040d37c245ef983b8342039a7[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Apr 30 15:44:48 2019 -0400

    visionchip accelerator driver: add source files for software execution

[33mcommit 4a366f5a75556b13ebb7b777452f80200403ad75[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 29 14:19:13 2019 -0400

    add Linux app and driver for visionchip accelerator: COMPILES but not tested

[33mcommit b202d9c8002c5314fd8c248815d4dbd6fdf1dd74[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 29 13:02:43 2019 -0400

    add visionchip accelerator. Behav and RTL sim PASSED

[33mcommit c452d2fe68f87ac71279536c80be3d31b94f738d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 29 13:00:32 2019 -0400

    BUGFIX of sim clock in project.tcl of ESP accelerator template

[33mcommit 9ca161d831554eaefddc333da79e78562104d246[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 26 09:59:33 2019 -0400

    ahbram_sim: do not print memory content

[33mcommit 48a952c65d05ededc96234db4e5a85806e109a43[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 25 17:52:43 2019 -0400

    WIP: socs/common: replace mctrl w/ bootrom and set AXI transaction and little endian generics to proxies

[33mcommit 54cc8860a8555bb2ba0e594c1923f7fd96bd1bdf[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 25 17:49:14 2019 -0400

    WIP: set AXI tran from socmap; this is assumed little endian

[33mcommit d9c564b3a2159bb515e268e8c5e742c5feff7963[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 25 17:43:09 2019 -0400

    WIP: add ahbrom.vhd to source files; should convert to rw RAM

[33mcommit c26b5eeba692fb98b1cc3aec263f2e00849fe798[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 25 17:42:02 2019 -0400

    WIP: bug fix for AXI and little endian transactions

[33mcommit 408ccb9c9c4dbe3c0ad5c6dc9fbebc2d80d5235c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 25 17:41:21 2019 -0400

    WIP: fix ariane_wrap bus and addressing

[33mcommit 45272b31cc56596131ad8a0f1e987bbc1b331884[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 25 17:39:22 2019 -0400

    WIP: add original software for ariane baremental; socmap patched manually for now

[33mcommit d37ebaedfd8a12217f1155593199150d643837be[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 23 11:34:29 2019 -0400

    WIP: initial instantiation of ariane into tile_cpu; further refining needed

[33mcommit 7a59554abc80509cb304d706aee9bac123df2596[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 23 11:32:56 2019 -0400

    WIP: add AXI2noc draft. Need testing

[33mcommit 3a54cdd5e3e22589760658c67621887aa0541e48[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 23 11:31:48 2019 -0400

    WIP: rename entity fifo to fifo0 to avoid clash with ariane's source code

[33mcommit c8848a0c4e6bca377943c278b4efcd66a2758209[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 23 11:29:40 2019 -0400

    WIP: rtl/include/grlib/amba: add AXI constants

[33mcommit 789531767ba21121170a37a8b00f170dc810f391[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 19 15:17:13 2019 -0400

    WIP: add ariane submodule and update modelsim compile script

[33mcommit 8e66697d75310094e510e9d47b43562a15b30026[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 19 15:03:33 2019 -0400

    WIP: additional AXI fields

[33mcommit 5cac2333c4c793a703f2bb85a4f2f679d3c5779d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 19 15:03:18 2019 -0400

    WIP: fix simulation warning with no accelerators

[33mcommit 543255001f44228f746e606626aadafd17f237b1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 19 14:59:24 2019 -0400

    WIP: rename or delete conflicting module names

[33mcommit 20986d7a9aa7f2c15deec8e41b1d8af8218a0763[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 19 12:46:13 2019 -0400

    update CREDITS

[33mcommit c50ecb292076ebcabb84e722db8ed127e3c9a475[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 19 12:11:41 2019 -0400

    WIP: fix type mismatch when setting 64-bit architecture; note that some GRIPs won't take advantage of 64-bits bus architecture

[33mcommit ec8b9ed81262949fb7c89184aa761f38f2cf7ade[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 19 12:10:14 2019 -0400

    rtl/include/grlib/amba: add AXI constants

[33mcommit 7cf101c4fa8955040572ff86aa847aee0e22f7f1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 19 12:09:27 2019 -0400

    WIP: rename mmu to l3_mmu to prevent conflict with ariane mmu module

[33mcommit 3c7cac06562419f1bbfcea6f8f8ea2425131aa6c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 19 12:07:01 2019 -0400

    WIP: remove conflicting but unused files

[33mcommit 867d64d2427238760ac9089e10901bc8ca599846[m
Merge: 18b4ea0 f3a78c1
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 12 15:54:16 2019 -0400

    Merge branch 'ariane' of dev.sld.cs.columbia.edu:esp/esp into ariane

[33mcommit f3a78c150f974a86617145af0836cfa38fc2f864[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Apr 12 01:13:05 2019 -0400

    Support caches with 64-bit data word and 2 words per cache line:
    fix caches, adapt testbench.

[33mcommit fb9a029410f25705e2aad243c7dbe02b350463d9[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Apr 12 01:12:39 2019 -0400

    select cache implementation also based on word width and # words per line

[33mcommit 18b4ea00c9fbdce96ff3a5473a22abcc44ee0d5a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 11 18:19:02 2019 -0400

    heterogeneous NoC planes to support 64-bits cores and accelerators

[33mcommit ef7360a7977c4f20f8a0912245c3256d58850ff9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 11 14:37:29 2019 -0400

    rtl/src/sld/tile/: dix noc5_in_void on stop

[33mcommit 75efa176c2c94de57cffeac9ee70c0097c8b08b3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 11 11:52:47 2019 -0400

    update soft/leon3/linux module: enable video output on Leon3 defconfig

[33mcommit 18f92f9173d5c99feba0c43da57a2167fbbbde61[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 11 11:29:17 2019 -0400

    update soft/leon3/linux module: fix video output

[33mcommit 94af1e7f31cb5264abda4e7c22ef28e47729e2ef[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 11 11:27:22 2019 -0400

    tile_io: decople local-remote APB request queues from remote ones

[33mcommit b4b3418475529b6e0f939a60200741dc3906bc94[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 11 11:20:36 2019 -0400

    rtl/src/sld/tile/acc_dma2noc.vhd: comment mark_debug

[33mcommit 18c94f0753618e84d0cdfc8388fc74ffb3b316ad[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 11 11:19:39 2019 -0400

    rtl/src/gaisler/leon3v3/iu3.vhd: remove keep attribute

[33mcommit fe85c18295d7e7dc4970c2b311f9a8fe3658785f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 9 11:50:30 2019 -0400

    Fix multi memory controller clock domains

[33mcommit a5db5dd1ffab3a507ce5f8d785f350f54d805d43[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 5 12:01:34 2019 -0400

    rename cpu_mem2noc to cpu_ahbs2noc, matching entity name

[33mcommit 315a8f1eff18ecddcc39158fae0cfdd067705035[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 5 12:00:32 2019 -0400

    rtl/src/sld/tile/cpu_ahbs2mem: add comment specifying that we only handle up to 32-bits transactions from AHB masters

[33mcommit 3cb150ecfb51dc8daca650796e338918f8198ba4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 4 11:19:23 2019 -0400

    update CREDITS

[33mcommit 33b43dc322ad7924b4b95af5136ca1e98124a671[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 4 00:07:21 2019 -0400

    Add CREDITS

[33mcommit f2f22fa34a274a86ed07d895b357bd36d470d4b4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 3 23:22:09 2019 -0400

    remove wami-related device driver from repo for release

[33mcommit 7eea59fdfee9d12e6899906b332bf558c442bcb0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 3 23:11:20 2019 -0400

    systemc/llc/stratus: fix license header

[33mcommit b1c3e483fbb37f3b5d870083efac11e8348031fd[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 3 23:09:51 2019 -0400

    update submodule syn-templates

[33mcommit 9c052246b29c8b9086e1c445c8339b0844e69c7a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 3 23:09:32 2019 -0400

    Add copy of each license file and list of licenses

[33mcommit 6f204cfa9975137fd2bbaa2f44b513f296e174a9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 3 16:28:34 2019 -0400

    Add MIT License and copyright information

[33mcommit 8f935b8dec7785ab40b99dba25cd38168a6e752d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 3 14:07:26 2019 -0400

    update syn-templates submodule

[33mcommit af8b12794d26ce35d4d13a89ff03e2bc8709b96b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 3 12:46:00 2019 -0400

    update Linux submodule; points to github.com/sld-columbia/linux/tree/leon3

[33mcommit ee505e0f7a4907fb28d3dd79047d8c8a075c8baf[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 2 10:28:26 2019 -0400

    CLEANUP: esp device driver takes cache parameters when the module is loaded

[33mcommit 3125cb11d75f3ddb6711de8f23c6a3fe4cc4f484[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 2 10:27:54 2019 -0400

    CLEANUP: baremetal probe uses SLD_LLC instead of SLD_L3 constants

[33mcommit 7e23571af0b6f3c697d168b0d610a7b3967f7340[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 2 10:21:03 2019 -0400

    CLEANUP: update espmon colors for tiles

[33mcommit 220ba45390f1dc0f2e4da00b770cf00a57b9db36[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 2 10:04:31 2019 -0400

    CLEANUP: update espmon-clean and gitignore

[33mcommit cf4f8666ab32afa9db30d7409efe95546f71fb20[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 2 09:54:25 2019 -0400

    CLEANUP: top module of profpga example SoC enables separate AHB interface for EDCL

[33mcommit 6fb8300f058717b98086437e5cbc3c44f8b33069[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 1 17:32:33 2019 -0400

    CLEANUP: fix chisel accelerator installation target

[33mcommit a96ac8c3d42d5851ddba0ffda5134c549c7f976c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 1 17:32:10 2019 -0400

    CLEANUP: remove irqoverflow port from profpga constraints

[33mcommit 11feed0a09bc1a11f1c55e10f659f8962cb8654c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 1 17:31:39 2019 -0400

    CLEANUP: run VC707 example design at 100MHz. Tight, but better for Ethernet

[33mcommit cd6e9d8736d662c2bb9c764c4705fb0e05260ae0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 1 17:28:51 2019 -0400

    CLEANUP: rename top module instance for profpga example SoC

[33mcommit abb5a67e06b1c83c90760ddfbd1e902337dfe799[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 1 17:28:25 2019 -0400

    CLEANUP: sgmii for VC707 and VCU118 enables separate AHB interface for EDCL

[33mcommit 53100a23d80c0ff2f1a9726b0e2eb1cb14f7edf9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 1 17:26:49 2019 -0400

    CLEANUP: fix cache wrapper message routing

[33mcommit ba8a2126b2cc4e5100875fc2b2d7ea7600331ca5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 29 10:06:55 2019 -0400

    CLEANUP: constraints/xilinx-vc707-xc7vx485t/mig.prj round clock to 200 MHz

[33mcommit a37e4d6e8d6430e3713ba331708e4c506b60bf72[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Mar 28 18:21:47 2019 -0400

    CLEANUP: refactor socmap and move all centralized components to misc tile; mem_dbg removed mem_lite renamed to mem

[33mcommit 20bb349d929b6405c0698cb5bc8d776e24ca32d2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Mar 28 18:14:11 2019 -0400

    CLEANUP: update proxies and tile queues:
     - memory queues only handle memory accesses
     - any master in the system can access any slave
     - miscellaneous tile has all proxies to host Ethernet and Debug access interfaces

[33mcommit d2ad025703647f75bc37afb2b7030039aca16200[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Mar 28 18:11:45 2019 -0400

    CLEANUP: fix bit order for patient AHB2APB bridge

[33mcommit 7f5e519e3bda39ca3c3b43b1bec9e57459928eda[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Mar 28 18:10:55 2019 -0400

    CLEANUP: accelerator's wrapper accepts tlbentries=0 in case no memory is required

[33mcommit d21d5154dea6dbb2d3891365f3fc8399c96b3200[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Mar 28 18:06:35 2019 -0400

    CLEANUP: nocpackage defines max counts for components and corresponding data types; add RSP_AHB_RD message type

[33mcommit 3d8cd1bfe6311715d72c4dac2d0ee512b98ae872[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Mar 28 18:04:33 2019 -0400

    CLEANUP: cache wrappers use static info to compute yx coordinates of target tiles

[33mcommit ec46b54db749b559dd29718dd8df6bcaeb28dc4c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Mar 28 18:03:16 2019 -0400

    CLEANUP: fix bit order for plug&play info on AMBA

[33mcommit d61a46a35fba97f54adf4bb0fb66c7b4424b9962[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Mar 28 18:00:44 2019 -0400

    CLEANUP: grethm selects separate AHB master interface for EDCL

[33mcommit bb5d0fc510c190e2bdc25915af7b79cacd468b0e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Mar 28 17:58:07 2019 -0400

    update chisel submodule

[33mcommit f5ab276fc8a909f0ec908ec2716a1b27f426adb1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 22 15:21:04 2019 -0500

    change l2 and llc default cache size

[33mcommit d20a4d828a0b00b8db4fbd0a29636e5083fc6968[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 22 15:20:48 2019 -0500

    add bare-metal stub for synthetic accelerator

[33mcommit ef2b400ff0f3b12e65aeb11365645a3470028daa[m
Merge: 8d84c62 0783119
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 22 12:24:28 2019 -0500

    Merge branch 'aspdac'
    
      -- add a synthetic accelerator and its work-in-progress user application
      -- initial version of automatic coherence model selection for accelerators
      -- split DMA coherent and DMA non coherent requests on different NoC planes
         to resolve a deadlock scenario in case of heterogeneous coherence models
         selected for concurrent accellerators.
      -- fix L2 cache bank sizes

[33mcommit 8d84c62b8cf2a5b7a7de5b89fb0894701d079e55[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 22 10:23:01 2019 -0500

    socs/common/sgmii_vcu118: add author and update information

[33mcommit fee34f0d04d98e967e01df4d72bbac1372fdc65e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 22 10:22:21 2019 -0500

    sort: HLS builds only DMA32 version. TODO: re-enable 64-bit version later

[33mcommit bf3fa7ee206ece2aabe2da938c6d7a6026b99113[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 20 18:17:55 2019 -0500

    socs: Add example design for Xilinx VCU118 board

[33mcommit 4e11a11bea7171407518bcddd0824e3a678c9417[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 20 18:17:00 2019 -0500

    socs/common: add SGMII wrapper for Xilinx VCU118 board

[33mcommit 976374860a9b797d597a6fa1203727e08c4008c3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 20 18:16:28 2019 -0500

    Add support for Virtex UltraScale+ target technology

[33mcommit 1fe9d30efc304468a06a6911373ec2c3b1c376c1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 20 18:10:37 2019 -0500

    constraints: add VCU118 constraints and IP source files

[33mcommit fff4d09f8d9879ae588e950602402347b9bf0080[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 20 18:09:54 2019 -0500

    constraints/esp-common: get clock name from elaborated design

[33mcommit c1b0f57e9d5035562236901a25382dd2babb778b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 20 18:08:39 2019 -0500

    netlist: fix naming convention for netlist source files to match TECHLIB variable

[33mcommit fabafae53f4fd3c4762cdc9f8dcaea91f260f1e3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 20 18:06:38 2019 -0500

    memgen: fix physical ports assignment when pattern is unknown for all parallel operations

[33mcommit 2e639e237719ecf766110a6f16e950e96c9e0c51[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 20 18:05:45 2019 -0500

    llc: add explicit wait to fix Synthesis with Stratus HLS 18.20p100

[33mcommit e68cfb1103bdf26ed5bf4c1d3096ebd7e3d7d523[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 20 18:04:14 2019 -0500

    sim: upgrade Ethernet PHY simulation model from grlib-gpl-2018.3-b4226

[33mcommit b170e65e541b2edf9f3338e0d4b3494be41c76f2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 20 18:03:04 2019 -0500

    rtl: add required tech-dependent components for Virtex UltraScale+ target technology

[33mcommit 3e33b07192cd80e63cb91617bf41352956e4b720[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 20 18:00:24 2019 -0500

    rtl/src/eth/core/grethc.vhd: Add support for TI DP83867ISRGZ Ethernet PHY on VCU118

[33mcommit 21756c963ea8cafd39f88d9006319f8706894352[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 20 17:55:43 2019 -0500

    Cleanup testbench, top module and simulation targets to speedup compilation and simulation

[33mcommit 61ef0650b467cb404b7309ebdb4cefa19e35ae7e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 20 17:47:09 2019 -0500

    defconfig: update VC707 default IP

[33mcommit 4a1a0b5d5eefa2c98f765be4d1fc9d21916fdf94[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 4 15:22:09 2019 -0500

    barec/CounterAccelerator.c: remove meaningless test condition

[33mcommit 7c71ee617b992a402dcba58a5c77139f9984f529[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 4 13:55:30 2019 -0500

    chisel: merge PR-12 that fixes the ESP accelerator wrapper interface

[33mcommit 73a47bdb96728c3295e67a6cae9c21970b6100b4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 4 13:54:49 2019 -0500

    utils/Makefile: add Chisel targets to quick help

[33mcommit 0d3fff412ac5e4467db78e186570f103bf45a667[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun Feb 3 23:48:29 2019 -0500

    utils/accelerators.mk: add build targets for Chisel3 accelerators

[33mcommit a2a8520b7adbf5afee093325c10de8511ca80591[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun Feb 3 23:47:23 2019 -0500

    Add device driver for Chisel3 example CounterAccelerator

[33mcommit cfe6370b02752ee6ebc2b9fa1b910db1192a9d6e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun Feb 3 22:39:50 2019 -0500

    Add github.com:IBM/esp-chisel-accelerators.git submodule

[33mcommit b0d3bc56fbd18a58c986a3b4e1ce2c395d5e7d43[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun Feb 3 22:35:12 2019 -0500

    socs: ignore xcelium and incisive build folders

[33mcommit 896ab76bc07609a65d36c6ffcb0b1efb7b886d4a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun Feb 3 22:34:54 2019 -0500

    Support ESP device that does not access memory w/ 0 TLB entries

[33mcommit 08c04e72cece406ed1da89d45e90b0c0d6af5b8f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 1 14:16:50 2019 -0500

    Workaround for type mismatch between VHDL generics and Verilog parameters in Xilinx unisim library

[33mcommit caea4d31443898f71240d94b8eeb968711753b68[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 1 14:14:29 2019 -0500

    rtl/src/sld/caches/llc_wrapper.vhd: fix syntax warning from Incisive

[33mcommit 62797e4920765dc282eb38c586332a862f5ef5b1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Jan 26 21:50:17 2019 -0500

    scripts/leon3_toolchain: do not export SYSROOT variable

[33mcommit 0122538e6aeb5e3e4dada011e75ae0de2caf453a[m
Merge: 525f86c 961cfe9
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Jan 26 21:28:36 2019 -0500

    Merge branch 'master' of dev.sld.cs.columbia.edu:esp/esp

[33mcommit 525f86c4ecd41ec23c688a8f8fc87f565f329225[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Jan 26 21:28:21 2019 -0500

    socmap: remove undefined tap_tck_gated(CFG_FABTECH)

[33mcommit 961cfe97a3a03442e036ea9fc744b492458b1ac0[m
Merge: 1c4c295 01ededc
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 24 17:04:56 2019 -0500

    Merge branch 'python3-portability' of schuyler/esp into master

[33mcommit 1c4c295e3adc58a64d5e25c5b2f9e8e188a0bf02[m
Merge: c001194 05334c7
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 24 17:04:12 2019 -0500

    Merge branch 'realpath' of schuyler/esp into master

[33mcommit c001194421e35804ece9620c1b78656d906d741c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Dec 19 18:09:06 2018 -0500

    Add Incisive and Xcelium clean targets to clean and distclean

[33mcommit acf3233bf10116a14aa508815046ad19f8bafadf[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Dec 13 15:31:22 2018 -0500

    Add simulation targets for Cadence Incisive

[33mcommit bc03c67f552455d675e1e86d60a14ba01b7f2b12[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Dec 13 14:39:23 2018 -0500

    Fix library components and simulation flags for Cadence Xcelium

[33mcommit 01ededc338dbef332baffca9a9f6195f0f9d4bd3[m
Author: Schuyler Eldridge <schuyler.eldridge@ibm.com>
Date:   Tue Dec 11 17:10:28 2018 -0500

    Make python3 shebangs portable
    
    This changes the explicit shebang for utils Python3 scripts to be
    `/usr/bin/env python3` as opposed to `/usr/bin/python3`. This uses the
    Python3 install that env finds as opposed to hardcoding a path (which may
    not exist).
    
    Signed-off-by: Schuyler Eldridge <schuyler.eldridge@ibm.com>

[33mcommit 05334c7a08589d4a36e6f11eb955b1d71f81ad4c[m
Author: Schuyler Eldridge <schuyler.eldridge@ibm.com>
Date:   Thu Dec 6 17:38:59 2018 -0500

    Use realpath Makefile file name function
    
    This uses the `realpath` that Make provides as opposed to relying on the
    system's `realpath`. These *should* be the same, but the former allows for
    systems which don't have `realpath` installed to still build (I ran into
    this on a VLSI machine...).
    
    Signed-off-by: Schuyler Eldridge <schuyler.eldridge@ibm.com>

[33mcommit 019da329d51119f7fbc47b489cb08174784014e1[m
Merge: caa8fad 67470ca
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Dec 5 15:50:40 2018 -0500

    Merge branch 'issue-1' of schuyler/esp into master

[33mcommit 67470ca18129d864d9b9d2d240ea52645a613d54[m
Author: Schuyler Eldridge <schuyler.eldridge@ibm.com>
Date:   Wed Dec 5 14:56:08 2018 -0500

    Make llc_wrapper literal explicit for Vivado
    
    The use of '1' in a port map is apparently ambiguous to Vivado for unknown
    reasons. This changes a port map literal to use a qualified expression and
    satisfy Vivado. This is one of the two solutions suggested by Xilinx:
      - https://www.xilinx.com/support/answers/57549.html
    
    Tracking issue: #1
    
    Signed-off-by: Schuyler Eldridge <schuyler.eldridge@ibm.com>

[33mcommit 0783119f858f8e92e5fa56b0dd3f9f7c95e4e3bb[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Nov 10 03:34:37 2018 -0500

    tune app parameters

[33mcommit 9e7b830e3e224833fc7fbc629d592ea8c3db535d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Nov 10 02:04:07 2018 -0500

    improve application parameters

[33mcommit c7de178efe776a466305a4b96071f7c841da1982[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Nov 3 23:40:38 2018 -0400

    soft/leon3/drivers: working synth app and fix number of max full accelerators

[33mcommit 4fa14a192fb7b98a912b78e7f6275997ae3ccc5b[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Nov 3 20:59:33 2018 -0400

    soft/leon3/drivers: comment out some prints and print total exec time

[33mcommit f602e0d5a2fa14e6d513d79adc5d85f2ab15ef02[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Nov 3 17:41:37 2018 -0400

    mem_tile_q: use all directions for coherent and non coherent DMA

[33mcommit 26d625fe6b461d5e0e254bcd214bed774042fe69[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Nov 3 16:30:23 2018 -0400

    mem_tile_q: use all directions for coherent and non coherent DMA

[33mcommit 3a9cf11b50e57d3f79375c9f137edd9692be157b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Nov 3 01:42:23 2018 -0400

    colors for mmi

[33mcommit 0cbcc744091b08155fefc829c27519e5f38615ca[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Nov 2 16:01:00 2018 -0400

    update synth

[33mcommit 46f18b90c8ff44c9f70fae40699c15a60846de06[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Nov 2 15:54:56 2018 -0400

    change mmi64 address

[33mcommit 106210d7ad034f7bcf897e6b86aed857eac2936d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Nov 2 14:09:35 2018 -0400

    synth/app/synth.c

[33mcommit c140fb0f5c819fb9fe6b3d1ca39f068b0e81d5ab[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Nov 2 12:06:34 2018 -0400

    accelerators/synth: new input in testbench to expose bug

[33mcommit ffbd3c0d6bd3549906c4e1946488387c26ec0c58[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Nov 2 12:05:41 2018 -0400

    soft/leon/drivers: full application for synth accelerators

[33mcommit 6cbf7eb6939ca59fbe83187adc9fc19c68d414b4[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Nov 2 12:03:34 2018 -0400

    soft/leon3/driver: comment out prints in kernel

[33mcommit 93db19313a9b8ed6c3fb7a0b1a04513530d9eae8[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Nov 2 02:27:32 2018 -0400

    soft/leon3/drivers: change configuration of the 12 accelerators of synth app

[33mcommit 4b31b4ce146096311d7873fb8174e1a50d2cb495[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Nov 2 02:11:20 2018 -0400

    soft/leon3/drivers: enable from command line the use of the alloc policies

[33mcommit 823fa526d7d58010c86ae74626045e21ee1f60ef[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Nov 2 01:07:31 2018 -0400

    soft/leon3/drivers: modify prints and improve prep phase of the synth app

[33mcommit ce455d5d02a90603420497cf7d9ba138e0f11b4b[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Nov 1 04:42:47 2018 -0400

    improve adaptive algorithm for cache coherence choice in the driver

[33mcommit c47dbd51f937c9511fd52cbd35e542dfcb3ec4a7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Oct 30 00:07:25 2018 -0400

    soft/leon3/drivers/synth: app selects contig_alloc policy based on nthreads and memsz

[33mcommit dc72354153a8c5aa7748cfe78a7e5f140c4c4236[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Oct 30 00:06:53 2018 -0400

    soft/leon3/drivers: contig_alloc returns most_allocated ddr node

[33mcommit 3f0e215e708f7cf2ea55f26c8bdfbc0265cde3eb[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Oct 29 22:54:02 2018 -0400

    soft: improve coherence mechanisms in the accelerator's drivers

[33mcommit 045409ec6f26c6eca2cbc920c5e0d23889aac0d2[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Oct 29 15:32:19 2018 -0400

    accelerators: fix install when no rtl_parts are generated

[33mcommit caa8fad8b0fbe3e673cf1b06cbbcfed5f46e7a55[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Oct 29 11:55:56 2018 -0400

    update version of Vivado in printounts of make --help

[33mcommit 868ad986b10b9626ffbfa4bdd7e7013fb349065d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Oct 28 23:37:38 2018 -0400

    synth accelerator: put DMA get and put inside a protocol region

[33mcommit 7c28827a29a4c3f382f99867fde7a4025e9e0c5e[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Oct 28 22:29:35 2018 -0400

    add to esp driver codebase the runtime algorithm for cache coherence choice

[33mcommit 501fd6446582eb616198c1fe2728a7ca9cce1493[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Oct 27 04:55:22 2018 -0400

    completed synth accelerator, passed SystemC simulation with light testbench

[33mcommit 415f5b8fdc7d8ecbf8713a010ba6d7d3bb856578[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Oct 27 02:12:34 2018 -0400

    fixing aspdac algorithm, in_size is in words, not bytes

[33mcommit fd0b11fe07f7d84dcfe1a94601fe6b0e3985e477[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Oct 27 01:37:45 2018 -0400

    soft/leon3/drivers/synth: moc driver and app with no algorithm

[33mcommit e0a3836ddbecefdc0d24195f34c85c21def4cc0e[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Oct 27 01:31:39 2018 -0400

    add temporary data structure and algorithm for aspdac paper

[33mcommit f870c5f7f33c3d4589df9e78f1ceecae0efc5aa7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Oct 25 23:38:11 2018 -0400

    systemc/l2: increase L2 and LLC size to 64K and 1M per partition

[33mcommit e353272000a2365747eb530eb3159e8a27f8ec0f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Oct 25 23:33:50 2018 -0400

    systemc/l2: fix size of memories in memlist

[33mcommit 59403c4fdf79820cbb0b332c2de4ad87f7077f65[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Oct 25 22:59:58 2018 -0400

    accelerators/synth: swap register address; change devid

[33mcommit 6db4aa3f047bc82001a0b6112180466f124b882e[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Oct 25 17:31:18 2018 -0400

    add 'offset' config register to synth accelerator

[33mcommit 2ff43d53dafad70fff8e98fe74fd92fdea97cb38[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Oct 25 16:53:53 2018 -0400

    add draft of synth accelerator (to be completed)

[33mcommit f48c5f5cc39a2d35d0489d1324e79d996ee48042[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Oct 25 16:05:47 2018 -0400

    Update submodules URL

[33mcommit deb9d18d0a5a0d279465f7ef581d997eb5aa38a5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Oct 1 08:39:18 2018 -0400

    soft/leon3/drivers: esp_private_cache flush all; replace spinlock with mutex

[33mcommit d5e8b741a922bff582ac2c48d7e8cd1430b9b65e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Oct 1 08:38:45 2018 -0400

    soft/leon3/drivers: define coherence model labels

[33mcommit 8ff083e317a91305d0bc62e9652b320a781644aa[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Oct 1 08:33:21 2018 -0400

    socs/profpga-xc7v2000t/profpga.cfg: upgrade interface board to R5

[33mcommit 9a455c04beb460ec1ae01a2eeab01e9e1255f83e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Oct 1 08:32:33 2018 -0400

    Rewriting LLC to fix deadlock on coherent DMA with recalls. Hit latency is now 8 cycles though

[33mcommit 648cb27846ca0ee52689e07f8b636e8f10f23ff5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Sep 28 11:43:44 2018 -0400

    utils/components.mk: fix distclean

[33mcommit f70713c5f618b10bb1c71c33ead860d58adfa1b8[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Sep 28 11:11:40 2018 -0400

    tech/virtex7/mem: add memory delay info

[33mcommit 6bd178f031427935f5a9a2c29f7d2462c332f033[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Sep 28 11:11:12 2018 -0400

    tech/virtex7: remove obsolete caches folder

[33mcommit 07ded72e2ccfe9cea362659b2ac63449b1244dad[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Sep 28 11:10:07 2018 -0400

    memgen.py: improve simulation labels and synthesis translate on/off pragmas

[33mcommit c565e7cc62a2a0362cc488776168a0fd3735c299[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Sep 28 11:09:24 2018 -0400

    memgen.py: read delay from lib

[33mcommit f25c8c1018f6310f95f21c1974c5605ee8e8fbf4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Sep 17 10:12:53 2018 -0400

    accelerators/common/stratus/Makefile: do not buffer stdout in simulation

[33mcommit 3fff8854e1a89991b4b8ffd7bd16233ec6da8c5e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 23 12:52:16 2018 -0400

    src/sld/caches: remove IRQ logic.
    Check for cache status must be done using polling;
    driver cannot sleep while holding the lock on the
    cache list, which is necessary with Linux SMP.

[33mcommit 6930a26cfa564202b4e019926ede758b056662a4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 23 12:29:14 2018 -0400

    rtl/src/sld/caches/l2_wrapper: flush_all / not flush_data_only with CMD_REG(2)

[33mcommit e5e56bd051339f5e36aade2545e40c18a106895a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 16 16:35:08 2018 -0400

    soft/leon3/dirvers/esp_cache: fix Leon3 L1 flush asm

[33mcommit ec44e79d4c9b25b9405c9efd18971a8172b4df4a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jul 13 18:08:29 2018 -0400

    update .gitignore

[33mcommit aa5c7650ae5722f1ba35381d7bff4edbc86576ff[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jul 13 18:06:26 2018 -0400

    soft/leon3/drivers: update esp drivers for Linux 4.9

[33mcommit 90b4ec8ac61cd917932f18dad52df67ae1da9317[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jul 13 18:05:34 2018 -0400

    utils/script: add Leon3 tool chain build script; sysroot binaries are not precompiled any more

[33mcommit a9100e142542c3703fc0fbe5cafad6751e7abc06[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jul 13 12:21:05 2018 -0400

    soft/leon3: add Linux 4.9.112 stable submodule w\ Leon3 patches

[33mcommit 7e549cc9140ce578a62f811486b484ae0f6b1b9c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jul 12 23:46:46 2018 -0400

    soft/leon3: delete linux 3.8 submodule

[33mcommit e25249c8b2d0c7b969d583e8d244335fdc83a63d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jul 12 23:42:03 2018 -0400

    soft/leon3/sysroot: update toolchain for Linux 4.9

[33mcommit e958f49e04fe3b011517664e90407b1efee9c7a5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jul 10 16:36:39 2018 -0400

    removing binary inherited from grlib

[33mcommit d1b10129aa174b42974df046f0829ab49ce4d473[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jul 10 15:02:04 2018 -0400

    bump Vivado to version 2018.2

[33mcommit 4a01bcfccc482d5fd4d3a9c3b354a961bb5208e9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 20 17:24:15 2018 -0400

    soft/leon3/drivers: update accelerator-specific drivers and app for new coherence model

[33mcommit 45b40fb6a6cba193711757e5464cd7971f619937[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 20 17:23:32 2018 -0400

    sort: cosmetic fix to barec driver

[33mcommit c9a5438bac7bf3231c28678fa463e0822588a69d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 20 17:22:32 2018 -0400

    soft/leon3/drivers/esp_cache: do not issue LLC flush if pending

[33mcommit 2dbbb804cb2ac09b362bfe7700706ca03caac6e2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 20 17:21:57 2018 -0400

    soft/leon3/drivers: add support for flush_ioctl and coherent DMA aka ACC_COH_RECALL

[33mcommit fda279fd680d4222113767f1a1d769eecf1e902a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 20 17:19:32 2018 -0400

    add support for ACC_COH_RECALL settings in hardware; behaves as ACC_COH_LLC

[33mcommit 413f08dfb5d61d1ac589528ebaf146e93fffe5dd[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 19 17:40:20 2018 -0400

    add Xcelium compilation targets

[33mcommit 7ef18b9fc599d748487247fd34014a97e275c277[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 19 17:37:47 2018 -0400

    utils/accelerators.mk: folder sldgen must be deleted before refresh

[33mcommit 22077116487c6d2403928806f12f1aa4d4130263[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 19 17:21:38 2018 -0400

    systemc/llc: add support for LLC-coherent accelerators using recalls instead of flush

[33mcommit bfc03c5116a79e808347a60b36efd94724cde063[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 19 17:20:46 2018 -0400

    soft/leon3/linux: cherry-pick 1ffbc51a0d00e52983c70aa7c8dbc7b621d6287d; fix timer bug on SMP

[33mcommit 4326b1222efb20934ad023529fef485357fc8d8d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 19 17:19:58 2018 -0400

    soft/leon3/drivers/sort/barec/sort.c: random init

[33mcommit 3359f647ec657c773699581bac90308fac6207b2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 19 17:15:42 2018 -0400

    socs: fix mig_7series interface for Vivado 2018

[33mcommit 30c376beff5cf0b6237cb88b4ecbdc53c7385c84[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 19 17:14:17 2018 -0400

    rtl/src/gaisler/leon3v3/iu3.vhd: add PSR to debug probes

[33mcommit 930ee551548273cd164eb94f1bbd122b42b32dc6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 19 17:12:58 2018 -0400

    rtl/src/techmap/unisim: remove redundant components; using original source files from Vivado instead

[33mcommit 6cd98b412dc690d004552f84f8e2a9b79bc8ca07[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 19 17:12:01 2018 -0400

    rtl/src/sld/noc/fifo2.vhd: remove obsolete port

[33mcommit a2ec2c6a79277340ba6eafb3efcfa88fce41d682[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jun 19 17:11:26 2018 -0400

    rtl/src/gaisler/ddr: fix mig_7series interface for Vivado 2018

[33mcommit 478306337be30b94b7198722159b212253424efc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 29 18:10:57 2018 -0400

    socs/xilinx-vc707-xc7vx485t/systest.c: set hello world as default programg

[33mcommit 258b482c78dcee327dd9f4cae351070d18c83298[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 29 17:57:32 2018 -0400

    fix cache wrappers: signal initialization may lead to synthesis errors

[33mcommit 7bcf38cef13969270e4ff3b8bc014e3394192725[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 29 17:56:53 2018 -0400

    fix IRQ over noc for SMP

[33mcommit 423ff050756e12d313e8811ffc4449ee8b4175f6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri May 25 17:10:56 2018 -0400

    utils/Makefile: modelsim.ini suppress warning related to novopt

[33mcommit ea13d66d716030c3d8b7719fab9d0a5264e6ddd0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri May 25 15:14:10 2018 -0400

    update to Vivado 2018.1, Modelsim 10.7a

[33mcommit b40e179c1a2d06ced165d8dba5e290f9c176e6ca[m
Merge: 3c1b57c 66739e6
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 24 18:13:56 2018 -0400

    Merge master into caches

[33mcommit 3c1b57ca72aecae3ce7e014e638ef2a3303fc182[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 24 13:15:00 2018 -0400

    soft/leon3/drivers: smarter flush for private cache

[33mcommit 9620175915b8340531378d473ccd944ac257bbf5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri May 11 22:29:08 2018 -0400

    esp driver sets transfer before flush

[33mcommit cf53fcde22a1ed510472b2aae1239cc9a059c33c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri May 11 11:35:03 2018 -0400

    socmap allows to remove the L2 cache from accelerators at design time

[33mcommit 796e2bb8ceb4c8010574168fabf30a242d098675[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 10 13:34:04 2018 -0400

    soft/leon3: add fft1d and fft2d device driver and apps

[33mcommit 6f4b89abe66dda720f31d714dfec5b6d33619eb9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 10 13:32:47 2018 -0400

    add support for split LLC and memory service monitors

[33mcommit 89502021bb0d0a862cefd2465b119b16565bc58d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 10 13:29:34 2018 -0400

    allow up to 16 distict cache IDs

[33mcommit 69de9d97728746857cc2eb8ba691995ca5cdde6a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 10 13:26:04 2018 -0400

    utils/Makefile: fix netlist path

[33mcommit 3c013a86eb1afb1b07346d06f37c1ce50e2ad6dd[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 8 17:58:17 2018 -0400

    add support for split LLC

[33mcommit dd517198c25bd8d39baccba6fc59cbe40a29f133[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 8 17:57:40 2018 -0400

    utils/socmap/NoCConfiguration.py: fix error message print

[33mcommit cfa40a1a37eec8c31598750290256a5782b4845f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon May 7 13:49:05 2018 -0400

    add mmi64 appl to gather raw values from ESP probes

[33mcommit a34a15eaff253acac48e178be87ea9b2908fe5fb[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon May 7 13:48:33 2018 -0400

    utils/scripts: update accelerator initialization script

[33mcommit ad235c2d39d4b1a20c09880b8cbf58697e23f3d6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon May 7 13:47:40 2018 -0400

    drivers/spmv/linux: fixe check on mtx_max

[33mcommit 5c8019b74efc61479ed0e4652fcd613e93dd0661[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon May 7 13:47:04 2018 -0400

    update default caches configuration

[33mcommit 628ead831db8ef6532c058cf3ddbc08f1686d83e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon May 7 13:08:25 2018 -0400

    spmv: uncrease number of TLB entries and fix comments

[33mcommit ddd629c250e78cefeff10c124af7d79806087289[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon May 7 13:07:22 2018 -0400

    socs/.gitignore: ignore mmi64 targets and outputs

[33mcommit efa1349fd1956fe5a96655981c2a23bbc3fe70ea[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon May 7 13:03:58 2018 -0400

    soft: add spmv baremetal driver

[33mcommit 3191e0c2bb27d456ef8a236cda9faf60e1f4fbf4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 3 13:20:56 2018 -0400

    apps: cleaning printouts for experiments

[33mcommit 97bfe144635b6af72a36e7b94449e9d52405d6ce[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 3 13:15:05 2018 -0400

    common test: add new lines in printf statements

[33mcommit 6fb14cf60b6e76942cdaa0ec1c0a8fff0e9d3e14[m
Merge: db02745 9fda823
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 3 12:41:59 2018 -0400

    Merge branch 'caches' of dev.sld.cs.columbia.edu:esp into caches

[33mcommit db0274524ed9a74b1c0df3232e99c5eabc5bfe35[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 3 12:41:07 2018 -0400

    spmv/app: add software compute

[33mcommit 9fda82374c42e261661d8eda38c95c4dc4b91989[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu May 3 08:46:19 2018 -0400

    For SPMV app change generation of some matrices. max-nonnull should be a power of 2.

[33mcommit b18a6929a2eab5aa034c352fb863688d65d83a10[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed May 2 23:43:27 2018 -0400

    WIP spmv: linux app

[33mcommit 3cfb009d3b5737976251842b4e4cbcab4250be62[m
Merge: 7ccfc1c dd5f6c2
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 2 17:15:24 2018 -0400

    Merge branch 'caches' of dev.sld.cs.columbia.edu:esp into caches

[33mcommit 7ccfc1cecc6630b767b2f37c6753f727aaf32246[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed May 2 17:13:43 2018 -0400

    New dataset sizes for SPMV: 25k, 133k, 650k, 9M.

[33mcommit dd5f6c2e51d846699976148cd8119413629e7b58[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed May 2 17:03:50 2018 -0400

    spmv: add Linux device driver

[33mcommit 0659fb93ee510f4182f0c8cb6de318a669ce0b35[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed May 2 17:00:02 2018 -0400

    spmv: add input matrix generator

[33mcommit 35230e599846d856e295116914238a2eeb56b5ef[m
Merge: 4bc4444 34a7511
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue May 1 23:55:18 2018 -0400

    Merge branch 'caches' of dev.sld.cs.columbia.edu:esp into caches

[33mcommit 4bc44448095b2c2ed36dbf9aa4b7decc89de67ab[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue May 1 23:53:33 2018 -0400

    In L2 cache work around a Stratus bug by avoiding a sc_uint<1> for the l2_ways_t
    datatype. So that the 2 ways cache can synthesize correctly. Small fix also in the
    testbench to make it work up to T6 also for 2ways and 4 ways. From T7 it only works
    for 8 ways.

[33mcommit 34a7511cca8bd0f5baed7b758bb40f560b251e8b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 1 23:49:03 2018 -0400

    change_detection: fix app usage string

[33mcommit dd2b99ed85b542962d2b9ecabb7da29a170c2dc4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 1 23:30:54 2018 -0400

    soft/leon3/driver: add debayer and change detection drivers and apps

[33mcommit 27bbe6eb9ea521495592a88f9c236ff341bf0abd[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 1 22:24:49 2018 -0400

    socmap: add LLC info to apb-to-tile

[33mcommit d7c5e1ddd18f122d4da088ee964cb3c6e35f0c84[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 1 18:04:49 2018 -0400

    sldgen: fix cahce hls_config parse

[33mcommit a04dfb19f29f616ef1a1f917452ef9eed1f138bc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 1 12:46:54 2018 -0400

    sldgen/templates/noc_interface: fix queues read/write request

[33mcommit b5a8dab871c708c6ce1f832fac8cb2b04097ed48[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 1 12:46:25 2018 -0400

    sldgen: add new llc I/O to handle llc-coherent misaligned DMA transactions

[33mcommit b6ae25ca43c6df16b8b1088410fb465a0ab93d55[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue May 1 12:45:42 2018 -0400

    sort bare-metal driver runs on smaller dataset for simulation

[33mcommit 0db06ecffb1115e555832e37eb3422def4bdbfef[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 30 22:43:20 2018 -0400

    Revert "Make L2 cache in-order with respect to read requests. TODO REVERT this"
    
    This reverts commit 73ca0cb4862f0258a2dabb271200795e0f00267b.

[33mcommit 63a6116e2e7dd3634ea2a42919b7d8bcf453dfdf[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 30 22:11:23 2018 -0400

    Adapt LLC SystemC testbench to misaligned bursts (length and offset).

[33mcommit dda63f0e126a4eba981a947c9c0d55fd638c4f11[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 30 18:58:47 2018 -0400

    WIP llc_wrapper: fix misaligned address/length

[33mcommit 96a7d16cbe323bd87a51fdf8a0e4b17fd12e5bc3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 30 16:32:59 2018 -0400

    llc; fix dma read/write with address and or length not aligned with cache line size

[33mcommit f0e08bd193101d7321a77a9d03402f10afb1884c[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 30 15:21:11 2018 -0400

    Add some mark_debug to signals for debug in VHDL source code.

[33mcommit 73ca0cb4862f0258a2dabb271200795e0f00267b[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 30 15:16:57 2018 -0400

    Make L2 cache in-order with respect to read requests. TODO REVERT this
    when the cache is meant to be out of order.

[33mcommit fd7416192bdd666a7bee4d99c850ff20fe2e04bf[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Apr 29 21:06:43 2018 -0400

    BUGFIX: LLC fwd out message type (coh_msg) was at most 2 bits instead of 3.

[33mcommit 8f78f071a8ca04e5fcdbf7f299fb4d2bd7141307[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 27 16:00:09 2018 -0400

    soft/leon3/drivers/test: set affinity to CPU0 to reduce test variability

[33mcommit b06889971dc299e593a075df93fafbe232e3753b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 27 15:05:26 2018 -0400

    utils/Makefile: make sure sysroot is updated with newly compiled drivers

[33mcommit 7b05d9c4432db29360800240df43c43bd5ffdc2a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 27 15:04:46 2018 -0400

    soft/leon3/drivers: add esp_private_cache_flush_smp

[33mcommit b12e9f40687e3130c5de271d1943c71f423906a6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 27 11:13:47 2018 -0400

    soft: remove apps/spmv from wrong place

[33mcommit 81de46b09dc35ea4f5e53dd80ebec204ece6e0a9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 27 11:13:12 2018 -0400

    soft/leon3/drivers: fix esp cache flush for accelerators

[33mcommit 129312e9fb0875385f8a38135c83ce47dba8d1b4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 26 16:59:45 2018 -0400

    compile and add to sysroot esp_cache and esp_private_cache modules

[33mcommit 50e231d77e4983020f4e30e8f683ffac3546c65f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 26 16:58:42 2018 -0400

    WIP: update esp drivers for cache flush (to be fixed on Linux as IRQ is not connected in hardware)

[33mcommit 422665ed2aaabed538efde955d929fb027add130[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 26 12:59:53 2018 -0400

    socmap: fix esp_config file read/write

[33mcommit 46ea51b009a472bee49024092610f783fba6741b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 26 12:59:30 2018 -0400

    socs/defconfig: update defconfig files

[33mcommit 6a6b8d67b4167f72cfa0fe2ebf2c9ce37e0739d4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 26 12:43:14 2018 -0400

    add counters and mmi64 interface for cache hit/miss

[33mcommit 240ae797a05b838a656523bf862c17f1f7d0fcbb[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 25 15:49:18 2018 -0400

    each CPU can see and set a flush due on every l2 cache:
      - add full APB interface to tile_cpu with local feedback capability
      - fix bare metal device-drivers to test new flush mechanism

[33mcommit 7680d5fb972e49029cbc741d2f55e9be288e25a4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 25 15:38:29 2018 -0400

    src/sld/caches/l2_wrapper.vhd: save cpuid into status register range 31-28

[33mcommit 96e627f463f8c4952d68c1349b781f2656d74f76[m
Merge: b53253a 873743e
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 24 19:19:03 2018 -0400

    Merge branch 'caches' of dev.sld.cs.columbia.edu:esp into caches

[33mcommit b53253a5dd7b7f0511f5809af1279db6cf4f18bd[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 24 19:19:01 2018 -0400

    accelerator coherence model selected at runtime

[33mcommit 873743ea301f637d2e5d9412a404e0a18dd377e0[m
Merge: c5d1e1d 88d9bc7
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Apr 24 19:18:28 2018 -0400

    Merge branch 'caches' of dev.sld.cs.columbia.edu:esp into caches

[33mcommit c5d1e1df7ec5802f3dd94d08b2a3e612913bca9f[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Apr 24 19:17:55 2018 -0400

    Add configuration of PLM size.

[33mcommit c549ca9a62e057e17f4e1c79a41e04a50da3916a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 24 15:36:22 2018 -0400

    acc_dma2noc: fix flush default value; do not flush

[33mcommit fddd4fe461608dfce3ee99d01e81337d1f3a46ea[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 24 15:23:30 2018 -0400

    socmap: accelerator coherence model cannot be set at design time

[33mcommit 2ad66e1afabd204007133bb33cc79e839111c10c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 24 15:04:09 2018 -0400

    rtl: fully-coherent accelerators flush private cache after last word has been sent to cache

[33mcommit b87c3137b5cb519e356ecbf55e02bc12c327133c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 24 14:50:17 2018 -0400

    rtl/sld: fix fully-coherent accelerator

[33mcommit 88d9bc77a2ee26d08dec7d79b42e4ba02f240c40[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 23 14:03:46 2018 -0400

    spmv: set accelerator ID different from sort

[33mcommit d9be527d9e4673461d8ae268523533c2ac9b5b8c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 23 14:03:16 2018 -0400

    sldgen: fix l2 stats port ma;p

[33mcommit 2dda1586829082aaa8c0aeb48f6d3d56a05e380c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 23 14:03:03 2018 -0400

    l2 cache flush is set by device driver and triggered by l1 flush

[33mcommit 937651a625abf37cb6742d2a1cdad26468b2b612[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 23 03:07:31 2018 -0400

    Additional fix to validation in SystemC testbench of SPMV accelerator.

[33mcommit ec0ac6a00979df3cfb06c249960d63d57ab8d5f1[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 23 02:53:03 2018 -0400

    Fix validation in SystemC testbench of SPMV accelerator.

[33mcommit 576799ed0795d6e28a72f79941ab2b2537848880[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 23 02:27:35 2018 -0400

    Add some new input matrices for SPMV accelerator's testbench.

[33mcommit 20a8f1df0041250c46bcdc8e2c2078c04a79a64b[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 23 02:26:32 2018 -0400

    Add script to lanch behavioral and RTL simulations on several inputs.

[33mcommit ea18375a90b5633abcdc7dfad29c89bfa86d9508[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 23 01:05:06 2018 -0400

    Generate also diagonal and triangular matrices for SPMV application.

[33mcommit 9b37cf6751e0f62b352ca50b33f27da3d434c54e[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Apr 22 22:52:43 2018 -0400

    In caches wrappers add stats cache output containing hit and miss info.

[33mcommit cf9d3800ed4e4c7e445f30cfb8782cec76efc8a7[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Apr 22 22:24:22 2018 -0400

    In L2 add llc_stats output containing hit and miss info.

[33mcommit 6fdfe63e5078e7d2929e9b238c70833094a91b7c[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Apr 22 22:23:55 2018 -0400

    In LLC add llc_stats output containing hit and miss info.

[33mcommit f0ebb76477afd53d13f451f91d11d0c3a68bf2c6[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Apr 22 19:17:22 2018 -0400

    In L2 wrapper do not send flush to L2 when L1 data cache is flushed.

[33mcommit ccea7ae047790b93823d64145cd90a4472459d5f[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Apr 22 19:16:09 2018 -0400

    In L2 wrapper fix an hprot assignment by setting bit 1 to '0'.

[33mcommit 356fee51a5083ae9528c3a27ff0ccd5574a22d57[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Apr 22 19:13:20 2018 -0400

    In LLC fix bug of debug mode, a debug signal was assigned an undefined variable.

[33mcommit 37a7cf22e09e63ed1f501937ea5d9fc3428ba83a[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Apr 22 02:16:22 2018 -0400

    Add accelerator for sparse matrix-vector multiplication (SPMV)

[33mcommit 03f8d2bffc1ca132cea1b260e345bb996f46afa3[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Apr 22 02:07:41 2018 -0400

    Slight change on SPMV application. Change generated matrices.

[33mcommit 453024fed9f8c1a251b62f9d0578061daa261dad[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Apr 21 17:03:20 2018 -0400

    llc_tb: remove test case evict SD for DMA

[33mcommit fbe97f09f3ac079a8395b1f8626a75bca07c3958[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 20 17:20:33 2018 -0400

    l2: try to remove warning on async write to states CE0 and WE0 .. maybe not solved yet

[33mcommit 989f395dbdd9f21881027eeff68140c926adadf7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 20 17:15:32 2018 -0400

    accelerators/common/stratus/project.tcl: update stratus project.tcl

[33mcommit a607b782e8086e7ac43ffa4c8c96f266cdd6f8a2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 20 17:14:53 2018 -0400

    llc, llc_wrapper, acc_dma2noc: fix non-coherent and llc-coherent

[33mcommit 6638c69d9466d9e39979b2952e30442e5e4a0f89[m
Merge: 66b9b3a a810e29
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 20 17:04:09 2018 -0400

    Merge branch 'caches' of dev.sld.cs.columbia.edu:esp into caches

[33mcommit 66b9b3a933e9571beefd0f0defde616845cc8fd3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 20 16:39:18 2018 -0400

    l2: WIP restructuring protocol regions

[33mcommit a810e295f8518ea23d3a1e237fe2ffd80faa82d8[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Apr 20 11:04:45 2018 -0400

    In LLC add directive to preserve signals and add a protocol region to fix bug on send_mem_req.

[33mcommit c7739b38af591a1633a8fdd257834126808a5487[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Apr 20 11:03:33 2018 -0400

    Fix in L2 to make it schedule for both cmos and fpga.

[33mcommit 1ac8b41f29e328888cefafc0234b18beb323f1f6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 20 10:43:04 2018 -0400

    soft/leon3/drivers/sort: handle coherence

[33mcommit 21b30ae87bf9166e8b606109d807f790f0e944dc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 20 10:42:48 2018 -0400

    soft/leon3/drivers/probe: add esp_flush to bare-metal probe

[33mcommit edd3bbee3427541b99ee54871f1536e66dc19120[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 20 10:27:14 2018 -0400

    add soft/leon3/drivers/esp_cache: interrupt handler clears IRQ

[33mcommit 09b5ee234fc5407e163273c3aaed0fc072495595[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Apr 19 14:54:09 2018 -0400

    In L2 add a protocol region to make sure the flush loop is not unrolled
    causing a combinational loop.

[33mcommit 6004a1af1eee22f5bd07cb4c768bb5438242639d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Apr 19 01:54:03 2018 -0400

    Add debug signals to LLC cache with HLS_PRESERVE_SIGNAL. Debug mode can
    be enabled in "cache_consts.hpp" by decommenting "#define LLC_DEBUG".

[33mcommit f53e899e884f89637afdeada6169b3a6b2bdd37d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Apr 18 23:30:58 2018 -0400

    Add debug signals to L2 cache with HLS_PRESERVE_SIGNAL. Debug mode can
    be enabled in "cache_consts.hpp" by decommenting "#define L2_DEBUG".

[33mcommit a17d8117876a62677481bff6ab36731573a0979e[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Apr 18 14:51:10 2018 -0400

    In LLC remove parts to handle DMA_READ and DMA_WRITE requests.

[33mcommit 9125a59f7c20e4c58f0e387c4f0b7ff857963377[m
Merge: 154f061 2263898
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 18 13:20:36 2018 -0400

    Merge branch 'caches' of dev.sld.cs.columbia.edu:esp into caches

[33mcommit 154f061d4ee68a9548f1d094e311ec460f0844f4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 18 13:19:57 2018 -0400

    systemc/caches/llc/src/llc.cpp: add wait() in reset to avoid async write to mem

[33mcommit 2263898493ee8a2b76656cf695414acf1d0f6417[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Apr 17 23:13:33 2018 -0400

    In the LLC send FWD_GETM_LLC and FWD_INV_LLC in case of recalls.

[33mcommit 7f3059ae89ab27606b8cfc5d807d5dd9530300ce[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Apr 17 18:38:14 2018 -0400

    Add README to spmv C application. Description of make targets.

[33mcommit b4e484e678cf620ae08224922f7c61166c45f565[m
Merge: c93bbd1 414f02b
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 17 17:02:58 2018 -0400

    Merge branch 'caches' of dev.sld.cs.columbia.edu:esp into caches

[33mcommit c93bbd1bca2344a9ceedecbdee005c72242fccad[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 17 17:02:52 2018 -0400

    rtl/src/sld/caches/l2_wrapper.vhd: fix cpu hindex check

[33mcommit 414f02b7053a9b380cf9b8d9a575d3a703431c6a[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Apr 17 16:42:22 2018 -0400

    BUGFIX: L2 FWD_IN should be get also when flush is pending.

[33mcommit 09372831a9c533e728f54cb0dd2cc43483b7fff6[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Apr 17 03:15:02 2018 -0400

    Add gitignore to newly added spmv C application.

[33mcommit 1554db9add78735980505f5095aeefc27dcd297e[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Apr 17 03:11:40 2018 -0400

    Add spmv (sparse matrix vector multiplication) C application.

[33mcommit 88f4883bce7e63f9c771e692ab893d47338d3241[m
Merge: 09b85c7 ff68ba6
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 16 18:49:37 2018 -0400

    Merge branch 'caches' of dev.sld.cs.columbia.edu:esp into caches

[33mcommit 09b85c78431662b4738f5b4a5f61e701fff03c01[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 16 18:49:32 2018 -0400

    fix profpga top when no monitor is enabled

[33mcommit ff68ba69577e77c02f88c16e97d24d31d6ad68b6[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 16 18:34:44 2018 -0400

    Now in LLC FWD_PUTACK message contains destination cache_id in both req_id and dest_id fields.

[33mcommit b6b89f9683ad717ebea0127e3ecebfe7def1be82[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 16 17:06:53 2018 -0400

    caches: use gnerated component declaration

[33mcommit 6f2fa32139e18f17d63640e97b9c1c743b2e0ba7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 16 17:06:06 2018 -0400

    tech/virtex7/mem: add fake delay for simulation on Modelsim

[33mcommit d14fa32204be6c3c568c78b83369f36236a328d7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 16 15:39:14 2018 -0400

    top: fix ethernet pads with no ethernet; remove debug_led

[33mcommit 5e153c5be8de4c2d96aa91e0500a2d3c7897c07a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 16 15:37:50 2018 -0400

    l2/llc caches have no debug_led; fix tile_mem_lite

[33mcommit b07e305f88a6558ec200995dbf03805fbae02dd5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 16 15:37:05 2018 -0400

    utils/sldgen: fix errors for accelerator tiles with coherence

[33mcommit c699b11f00c11ce95a1736e47058d98a5401b484[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 16 14:22:05 2018 -0400

    rtl: add APB interface to llc_wrapper for flush

[33mcommit 75b239c6ddaa79ac93b8f4bcd6bb0042fe257514[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 16 14:21:40 2018 -0400

    ssoft/leon3/drivers/esp_cache: interrupt handler clears IRQ

[33mcommit 8ff21dc55e7133d08b958eafcfcff3e3eca9c63d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 16 12:54:39 2018 -0400

    In tile_cpu.vhd partial fix cpu_id and hindex of CPUs.

[33mcommit 9933e79670afdb9d8d6f282e378a6774c04254e4[m
Merge: 314d862 b51ddff
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 16 12:06:29 2018 -0400

    Merge branch 'caches' of dev.sld.cs.columbia.edu:esp into caches

[33mcommit 314d86206eae9e0b0404fee2f3e0b47c624da632[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 16 12:06:23 2018 -0400

    Fix generation of CFG_NL2 in socmap.vhd. Now it also counts CPUs.

[33mcommit b51ddff003350c8f4eeecf4aff19f0bcb11faf3f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun Apr 15 15:52:59 2018 -0400

    utils/socmap: set LLC apb as remote for cpu tile

[33mcommit 2bf16d5d62f289f509c56009240596b8817bdf13[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun Apr 15 15:44:36 2018 -0400

    accelerators/sort: update to current syn-templates

[33mcommit da30f3d25dc1d26f2f1ab17c3f7d6fa2edd6e81e[m
Merge: 0a2a9c5 5625d1d
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Apr 14 00:35:57 2018 -0400

    Merge branch 'caches' of dev.sld.cs.columbia.edu:esp into caches

[33mcommit 0a2a9c5247a9e6d0262487addfc8ad2a0ebc9281[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Apr 14 00:35:34 2018 -0400

    soft/leon3/sysroot: load esp_cache module after boot

[33mcommit 667ac7f6b47e7256e32200abbf17a931011a8469[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Apr 14 00:33:56 2018 -0400

    utils/Makefile: compile esp_cache linux module

[33mcommit 40186e73297dd0216e6e7bfab189d931e8e12559[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Apr 14 00:33:19 2018 -0400

    soft/leon3/drivers: add support for llc and fully coherent accelerators

[33mcommit 5625d1d0e19df596aa60fdea61476df141503331[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Apr 13 23:26:26 2018 -0400

    Compile cachepackage before tile package

[33mcommit 08534b52001d7ca3153cce1847745f736feda605[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Apr 13 23:26:04 2018 -0400

    Add read_word function and a few other fixes.

[33mcommit 5cb1b044f8fcf07adb561135fb30e2d56351bca5[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Apr 13 23:24:54 2018 -0400

    Various fixes to proxies after modifying them to support caches variable
    in size and accelerators with different memory models.

[33mcommit 40201f42d1acb71ada6db59a8f06c4ef21b1aff5[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Apr 13 23:23:28 2018 -0400

    Various fixes on cache wrappers after modifying them to support caches variable
    in size and accelerators with different memory models.

[33mcommit 9ae2ad9187c19831c99fc4ebc822a2f8097f34c9[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Apr 13 23:22:38 2018 -0400

    Various fixes in tiles after adapting for new memory models of accelerators and variable size caches

[33mcommit 1e7cb92b27c679b334410241da3e56fe4f991bf5[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Apr 13 23:21:41 2018 -0400

    Fix hindex in top entity

[33mcommit b1b57da89a5da2e5acd79cdb82039241e967e2d8[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Apr 13 23:20:55 2018 -0400

    L2 cache configurable with 256, 512 sets and 4, 8 ways.

[33mcommit a4d9172936910bdeb7f8d1cb2c68ab90307607e4[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Apr 13 23:19:57 2018 -0400

    LLC cache configurable with 256, 512 sets and 16, 32 ways.

[33mcommit e103b90d89f056dc1fbfa997b65c073a758ee7fc[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Apr 13 23:19:14 2018 -0400

    Add addr_breakdown_llc for LLC cache, as it was using the one for L2 cache.

[33mcommit 524590a62d672135707649188e17949c533e61d3[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Apr 13 23:17:35 2018 -0400

    Fix tipe of dma_tile_id in socmap_gen.py

[33mcommit 5c73b9461220051b1bc5fa6c7f7fab0d00ff9a84[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Apr 13 23:17:01 2018 -0400

    Fix cache components generation in sld_generate.py

[33mcommit 536c6f1799fda37394013d0147d9e2631e5fcce6[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Apr 13 23:16:26 2018 -0400

    In memgen.py do not create testbench.

[33mcommit 2ae57092d2956b950bf225e367211a5eba4476f6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 9 15:06:44 2018 -0500

    accelerators/common: upgrade to latest syn-templates

[33mcommit 2e37775590813dd153cb0523133b74d779137360[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 13 14:54:38 2018 -0400

    rtl/src/sld/tile/acc_dma2noc.vhd: use REQ_DMA_READ/WRITE for llc-coherent transactions

[33mcommit cadc25459ec128d74646f1afa62cac7bed8022f6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 13 14:46:42 2018 -0400

    utils/socmap: set L3_CACHE_IRQ

[33mcommit 3219f1304513bfcf07629d61d60db615ba768b55[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 13 12:04:10 2018 -0400

    accelerator wrapper supports llc/fully-coherent DMA transactions

[33mcommit 388a94955bb41f0863c0a9fd3a2e85ac0c277b64[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Apr 13 10:06:38 2018 -0400

    utils/socmap: add apb index and pconfig for LLC

[33mcommit 4e11e91827bc4de5ab4241a894fd70efc74cff01[m
Merge: ce35ce4 7150064
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 12 18:46:18 2018 -0400

    Merge branch 'caches' of dev.sld.cs.columbia.edu:esp into caches

[33mcommit ce35ce4b7f987cd13bf040e7014c078985734e22[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 12 18:46:15 2018 -0400

    utils/design.mk: add cache-related source files from sldgen

[33mcommit 71500648191ae9364b66ade981fb945fcdb7f52b[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Apr 12 18:44:05 2018 -0400

    Enable more sets and ways configurations for caches

[33mcommit 9ec9e81982ab32eb9f166f0fae52f5cab59da023[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 12 18:43:02 2018 -0400

    utils/sldgen: generate cache entities and components based on hls_config

[33mcommit e77b97345bb5dfb840c37bc612686bc0e6c5658d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 12 18:42:29 2018 -0400

    l2 and llc don't need tech generic

[33mcommit f1b2032b2dad9b7f2bf07f20ab3a4145350e42c8[m
Merge: 19334e5 e95bee3
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Apr 12 16:21:56 2018 -0400

    Merge branch 'caches' of dev.sld.cs.columbia.edu:esp into caches

[33mcommit 19334e596f31ec425c421f0a107824396abf5ae5[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Apr 12 16:21:48 2018 -0400

    Add testbench for DMA bursts in LLC. Small bugfix in LLC.

[33mcommit e95bee3f390464c79671e606b34c050674755a58[m
Merge: 45943ea 8a0a57f
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 12 15:58:26 2018 -0400

    Merge branch 'caches' of dev.sld.cs.columbia.edu:esp into caches

[33mcommit 45943ea1b6e635c9ab3962f7df1f587fba2dee78[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 12 15:58:23 2018 -0400

    WIP: adding support for LLC-coherent accelerators

[33mcommit 12e65e5784ef12f733b14ec73186a20e41b2b68d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Apr 12 15:57:40 2018 -0400

    utils/socmap: generate accelerator coherence type

[33mcommit 8a0a57fc33bcbcd8afa39059c4cbb9041aa86da9[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Apr 12 14:31:22 2018 -0400

    In L2 cache for accelerator tiles add TAIL to dma response messages.

[33mcommit 84ad0cb6dbf5ab40ce81ab97f1d0e46c1a1d9359[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Apr 12 12:34:39 2018 -0400

    Send CPU's soft reset to LLC cache and its wrapper.

[33mcommit 3ad8eae5a5461da5eb2a398faf7450c77388be52[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Apr 12 12:34:06 2018 -0400

    In LLC SystemC cache add support for DMA coherent messages.

[33mcommit db1fe71ae425d3ca79716af8c30c77a323cde89d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Apr 12 12:33:15 2018 -0400

    Add wrapper for L2 cache on accelerator tiles.

[33mcommit 0a197b8365a90b2b44a533499a6a5e5cef5abd86[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Apr 12 12:32:44 2018 -0400

    Extended llc_wrapper to support DMA coherent messages and their effects

[33mcommit 18f41612d0c508cd2008ab9b275c72c573472471[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Apr 12 12:31:38 2018 -0400

    Add DMA coherent requests message codes in nocpackage

[33mcommit 09eaa2e5866d4d6d221a530b7d8e31eebd3ba3a0[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Apr 12 12:30:59 2018 -0400

    Add BYTES_PER_LINE constant in cachepackage

[33mcommit 944ba614ae55f95e2e37f66012324b5514056921[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Apr 11 19:02:10 2018 -0400

    Fix l2_acc_wrapper dma interface

[33mcommit 9de24e8b9cd91476958cf7a01ef8cd516046a791[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 11 18:47:50 2018 -0400

    socs: minor fix to usage of socmap-related constants

[33mcommit d9fa3b5f6e64c46c6e93de5fea512e9fc5a5ad00[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 11 18:46:38 2018 -0400

    rtl/src/sld/tile: add hconfig to ahbm proxy

[33mcommit 1c6fd596c4965a7c83566620029fa6c8d1185a87[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 11 18:45:45 2018 -0400

    grlib-config: do not set constants that might conflict with esp-config

[33mcommit 79c450290ae21f9ec103d346385e1a5a480003fb[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 11 18:44:37 2018 -0400

    delete socs/common/socmap_types.vhd: constants are set in nocpackage and cachepackage

[33mcommit 9e68970af351f3b918639a094e785d3da98b511e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 11 18:44:01 2018 -0400

    WIP: updating socmap to support accelerator coherence

[33mcommit 680bfa05911fa1aba23c41ae578bd67d86508d90[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 11 18:43:39 2018 -0400

    WIP: restructuring L2/LLC wrappers to support accelerator coherence

[33mcommit ed41458e415d6c4c6fc371e703a48d268428551b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 2 22:30:34 2018 -0500

    utils/Makefile: fix RTL source enumeration

[33mcommit dc2630f4ff44c516066b26b10f7aa06585bdbc9d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 2 16:15:38 2018 -0500

    utils/Makefile: do not compile Xilinx Macro IPs for non FPGA target technology

[33mcommit a0c9e6ca2818a2e6a0912e5c60496b0593c93ecf[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 2 16:29:09 2018 -0500

    socs/common/tile_mem.vhd: fix typo to remove sgmii when ethernet is disabled

[33mcommit e496f68332737255570f43f315f0a3c41520ebbc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Apr 11 18:28:48 2018 -0400

    socs/common/tle_mem.vhd: fix use of socmap constants

[33mcommit 67d057a61f93984a33fad80842bac79f8f6ab243[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 10 00:05:51 2018 -0400

    socs/defconfig: fix both profpga and vc707 defconfig for cache params

[33mcommit 153ea08cf2e20fdc3dfc59e01c3a9098dfa8a645[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 9 23:54:59 2018 -0400

    socs/defconfig: update profpga defconfig for cache configuration params

[33mcommit f8a450b6d6cb581465845d52d49a7aedf735545e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 9 23:45:23 2018 -0400

    utils/socmap: add cache configuration

[33mcommit 179155fc794180d7e322137543c96ad3be68ed20[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 9 23:45:06 2018 -0400

    utils/accelerators.mk: fix installed.log

[33mcommit ca6a1dd11186a00cd5bc7584412f0dbbce7bcd12[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 9 23:44:39 2018 -0400

    accelerators: improved sort

[33mcommit 1c027175b45eb35539b9e62282407c824eade961[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Apr 9 23:44:13 2018 -0400

    accelerators/common/stratus/project.tcl: disable dsp

[33mcommit 9ed1f3ef1cb087cb1148db8be1a98f95d6262de8[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 9 01:09:41 2018 -0400

    In LLC cache move wait() from the beginning of the main loop to the bottom.

[33mcommit 652aba6178c00d64ef735d65d6af1deab71428b3[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 9 01:08:19 2018 -0400

    Adapt RTL cache wrappers to the new caches. Update some constants in cachepackage and nocpackage.

[33mcommit 7c45f605b4439aca33a0eb0c0d371b4e15eb3f2e[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Apr 9 00:57:22 2018 -0400

    Optimize LLC after latest modifications. Now 4 clock cycles latency from request arrival to response.

[33mcommit 46d902a32436192a305118c3cb1badfd46746422[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Apr 8 00:40:20 2018 -0400

    Bugfix for HLS of new LLC with support for accelerators snooping
    in LLC and accelerators bypassing LLC. A lot of protocol regions added
    to avoid supposed Stratus bug, which execute some writes to memory
    even when unnecessary.

[33mcommit 1584cdfbbfb70fd9f27af2117badeca6a470130c[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Apr 5 15:28:46 2018 -0400

    Bugfix for HLS of new L2 with support for accelerators snooping
    in LLC and accelerators bypassing LLC.

[33mcommit d89943416a1fdbe566366875e115184fba06147b[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Apr 4 17:48:18 2018 -0400

    New L2 and LLC caches and their SystemC testbenches.
    Added support to accelerators snooping in LLC and accelerators bypassing LLC.

[33mcommit 512267c5e46767bb9aa883f79107b2ebb7a9e355[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Mar 26 18:22:16 2018 -0400

    Reorganize the caches. Now from the project tcl l2 and llc independently
    receive sets and ways. Memories are mapped with some new macros in
    cache_utils.hpp. New states have been added to cache_consts.hpp to later
    extend the llc to support dma read and dma write requests.

[33mcommit 09819a014fdf348e2048b1fa0e73362e688ee541[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Mar 26 17:48:11 2018 -0400

    Update memlist.txt for l2 and llc. Now each memory is identified by
    number of sets and ways. Most of them are left commented so not to
    slow down memgen.py and Stratus.

[33mcommit 5e9b67755830255cfcaff1f369a82a7288d5c11d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Mar 26 17:47:14 2018 -0400

    Remove memlist_gen.sh from l2 and llc folders. It's not needed anymore.

[33mcommit 4c1c1b132afef4c346e9d620459c00950de11f0d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 22 21:18:29 2018 -0400

    In LLC cache do not go to Exclusive state is the cache line contains
    instructions, go straight to Shared instead. Set hprot to only have
    data cache lines in the testbench, otherwise it won't work. TODO: Add
    testing of this new feature later on.

[33mcommit 3c6ae9a5eb5ac8ecb9caab12851f49dbd4821130[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 22 15:37:23 2018 -0400

    Change clock to 12.5ns for Stratus HLS of caches.

[33mcommit c1952ce7e341fef77896d7d30499b9a8416e39f7[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 22 15:36:49 2018 -0400

    L2 cache: add constraint latency whenever possible and add back 2 protocol regions that are needed.

[33mcommit 06928f53a0af36990df67056ac3fc34b12b7e4ec[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Mar 21 18:37:40 2018 -0400

    Revert "Optimizing L2 caches: reorganizing to apply HLS_CONSTRAIN_LATENCY to"
    
    This reverts commit e95d265f75aea5393a1d85191f058cf599382c26.

[33mcommit e95d265f75aea5393a1d85191f058cf599382c26[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Mar 19 15:08:50 2018 -0400

    Optimizing L2 caches: reorganizing to apply HLS_CONSTRAIN_LATENCY to
    the proper regions.

[33mcommit 0b8ef12449360f5f59d5beab6c194f3927b3524f[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Mar 19 00:52:55 2018 -0400

    Optimize L2 cache: remove all protocol regions, merge initial selection part
    with the rest.

[33mcommit 03ae8ecb7a1715de319b5e1bd012071b82f6932d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Mar 17 21:30:23 2018 -0400

    For L2 and LLC caches: remove some loop carried dependencies, remove protocol region
    from L2 flush, fix bit-width of sharers and owners memories, make tag_lookup have
    latency of 1 clock cycle.

[33mcommit 8d6cddabd347125f3ac88d52bad3b5f17a2e0a2b[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Mar 17 04:59:58 2018 -0400

    Add systemc constant for caches for lenght of addresses without the cache line offset.

[33mcommit ab6feb6968afad6a3e62c55953c37af4a7174e81[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Mar 17 04:55:44 2018 -0400

    In L2 cache and LLC wrappers cut unused parts of address signals, as done for the caches.

[33mcommit 5d5852c3f82a754156b0dfb4a12c25f4d4a10536[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Mar 17 04:54:06 2018 -0400

    In L2 and LLC caches cut unused parts of address signals.

[33mcommit c35cd295608527702722b8fc4e5ee3b70910b6f3[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Mar 16 23:41:38 2018 -0400

    BUGFIX of ESP: some signals were not set in top.vhd when frame buffer disabled.

[33mcommit a53ffce777ee698dd17bd1fd15ee3413fc5ac6f8[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Mar 16 23:39:39 2018 -0400

    Adapt RTL cache wrappers to the latest changes in the caches: remove all
    debug signals coming from the caches, hprot is now only 1 bit.

[33mcommit fdbf9ce191c158ed36b6b4dda5d07f6e1998323f[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Mar 16 23:36:41 2018 -0400

    All LLC debug signals are excluded from the design when the LLC_DEBUG constant
    is not set. Fix LLC testbench for PUT messages, it had not been properly updated
    when PUT messages were moved to the FWD plane.

[33mcommit dea1d3be24a24fa8646125165c6080f65a8903d1[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Mar 16 18:04:11 2018 -0400

    Modify addr_breakdown type for caches by removing some unused fields.

[33mcommit 7d5ac1584fbf8e1fae2b38b2143699f291ee2df6[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Mar 16 17:39:24 2018 -0400

    All logic for L2 debug only active when L2_DEBUG is defined.
    Define it in cache_consts.hpp if needed"

[33mcommit 79beacc9c40b457e88252ed298b233f444a2239d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 15 23:37:31 2018 -0400

    Small fix in tile_io. There were still some coherence_* signals with the old names.

[33mcommit 7dd6c3bae3c773c264ee1fccf94f83bf4e402651[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 15 23:35:33 2018 -0400

    In caches makefile esplicitly specify l2 and llc to avoid trying to install sys in tech/

[33mcommit 8bffe99efddfe1fcd260244d86c7e54ca3e14a86[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Mar 5 22:09:52 2018 -0500

    socs/common/tile_io.vhd: remove frame buffer when SVGA is disabled

[33mcommit f946d2a5877fd35ce46d41179c775f3eb216ee8a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 27 10:53:16 2018 -0500

    rtl/src/sld/noc/router.vhd: fix single-flit pakcets routing

[33mcommit 66739e668e193e5af6aaa4f9b5dc9d13f1836de7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 2 23:26:15 2018 -0500

    socs/profpga-xc7v2000t/top.vhd: fix error and warnings when MMI64 and Ethernet are disabled

[33mcommit 85bcb95af1ab49a56a02bb5ad3b804d2d0870ea9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 2 16:28:46 2018 -0500

    socs/common/tile_io.vhd: remove frame buffer when SVGA is disabled

[33mcommit 1a34635df917fe7229a08b495ee00f88df892bef[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 2 16:29:09 2018 -0500

    socs/common/tile_mem.vhd: fix typo to remove sgmii when ethernet is disabled

[33mcommit a618eab0a33d900eeeb2591dc5a5ab2030e0190c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 2 16:15:38 2018 -0500

    utils/Makefile: do not compile Xilinx Macro IPs for non FPGA target technology

[33mcommit 60393dbff04ed529008d0849e0f5ec5ba1fb3fc3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 2 22:30:34 2018 -0500

    utils/Makefile: fix RTL source enumeration

[33mcommit b9c8522bd7041c492a244219b254923562090737[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Mar 2 02:08:16 2018 -0500

    Fix small bug introduced in the last commit. Wrong ports of VHDL component in cachepackage.vhd

[33mcommit 50585333244508f00b610f9442d822c48aeb82d5[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 1 19:31:59 2018 -0500

    Enable use of caches in an SoC with 1 CPU.
    This was not possible anymore after enabling SoCs with either 2 or 4 CPUs.

[33mcommit 040adb3f5c1b1a2bb80793c36efa7a7ccdbfa866[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 1 01:44:03 2018 -0500

    Fix bug in L2 cache. After a stall for a set conflict for a request coming from the CPU
    the pending request would be processes even if all the request buffers were full,
    then overwriting on ongoing transaction.

[33mcommit fcf9407ff2e2c11440f560c21658ff6ac7d83222[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 1 01:42:42 2018 -0500

    Minor fix: remove some latches that were not creating problems but are incorrect.

[33mcommit 8a054ca9979e9183d48c69ffeaaea690ebf5607b[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 1 01:41:44 2018 -0500

    Fix bug on AHBM master for invalidations in L2 cache wrapper,
    in which also remove some latches and
    add missing signal in sensitivity list.

[33mcommit 14cd9876bc5b8cb84c2b9d4995200afbba2ce68d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 28 16:52:26 2018 -0500

    Fix interrupt over NoC

[33mcommit 0ed6ca88833c9ae838a639fae67643ff7c6bf869[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 27 10:55:50 2018 -0500

    Delivering interrupt request/acknowledge through NoC (fails with Ethernet)

[33mcommit 1f6ce7ab5e438a7dfd8bbad3629b18843d289978[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 27 10:53:16 2018 -0500

    rtl/src/sld/noc/router.vhd: fix single-flit pakcets routing

[33mcommit 46cf01eae2105b8163643725f94e387197579aab[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 27 10:52:31 2018 -0500

    rtl: add ESP proxies for interrupt level over NoC

[33mcommit f9ed972b3f42c84aa4c65e227c5c18f03a4654aa[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Feb 26 14:58:01 2018 -0500

    Add test of casa instructions. casa is used to implement a spinlock.

[33mcommit 2cfaad24357a0bde9b3dea4c832fcbd639ac64c0[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Feb 26 01:55:39 2018 -0500

    Extend bare-metal tests by running cache_fill also for less-than-word size transactions

[33mcommit aac382da8507e42f675602ca499d1ff4623fec2d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Feb 25 20:01:18 2018 -0500

    Fix bug in LLC when exiting stall states.

[33mcommit 71d1965aba102adc2c2caf7718f0ade2a5464e44[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Feb 24 17:36:54 2018 -0500

    Change bare-metal test to execute its core 100 times.

[33mcommit 483b59029cf3112f88b63e88cd4752608e874be7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Feb 24 14:06:59 2018 -0500

    utils/Makefile: create sgmii library for simulation even if sgmii IP is not used

[33mcommit f75b74e19c971d5815b9eae2c0832c509e101d45[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Feb 23 18:00:12 2018 -0500

    Add the systest that runs all the test suite for the caches.

[33mcommit 64c183cafedd3ee260bd60bd537436949fcf759c[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Feb 23 17:59:27 2018 -0500

    Change signals marked for debug with ILAs (mark_debug)

[33mcommit 09c831b52d5d00283759d6860aa32baf76988c49[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Feb 23 17:58:40 2018 -0500

    Add some datatypes for memory tiles location

[33mcommit 90b3c6f408a818ade450d559949bc95ccf3d4d60[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Feb 22 20:35:46 2018 -0500

    Fix bug about end of forward stall in L2 cache when invack arrive after data.

[33mcommit 85a6dd6a38227677625375c888c0d90f66531fea[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Feb 21 13:52:12 2018 -0500

    Export to output some LLC signals for debug. Fix bug about & and != precedence. Fix bug of value of IIA, SIA and MIA constants.

[33mcommit 5a1b36d56d8046a6c4a9a85c91b23bd7d6713fdc[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Feb 21 13:50:39 2018 -0500

    Add to RTL the 2 LLC modules for 2 CPUs and 4 CPUs.

[33mcommit fb3bee558f7aa3053d01b2c2f6934ddd0ec1f4b0[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Feb 20 17:43:58 2018 -0500

    Modify SystemC of caches to be able to synthesize 2 different versions for each cache: 2 CPUs and 4 CPUs.

[33mcommit e1afb6b11b6b4c65c53b2df2fe179f08df7b33ed[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Feb 20 17:41:20 2018 -0500

    Add support for caches for 2 or 4 CPUs in their wrappers. Fix bug on AHB invalidation for L1 cache.

[33mcommit b0a7cdc015077ba22346e79236804b548d4838fa[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Feb 19 21:50:45 2018 -0500

    Add bare-metal tests for Leon3 multi-core.

[33mcommit a8044d30ebb7737c476985f400da13ca60c9a3c3[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Feb 19 21:48:44 2018 -0500

    Compile leon3 software with -O2

[33mcommit d142bc4ffd938fc309edae360e4c9bb54a197a7d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Feb 16 16:44:15 2018 -0500

    Fix a couple of bugs in L2 and export to the interface some debug signals

[33mcommit 30a32fe23caf93f2a6865c639124ece1abcc0e4b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 14 15:51:35 2018 -0500

    constraints/profpga-xc7v2000t/profpga-xc7v2000t-eth-pins.xdc: use ETH2 on faulty daughter card

[33mcommit c05088c16a6d3145f9ca794d731bee795264a0c1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 9 18:00:47 2018 -0500

    utils/socmap: fix hls config naming convention

[33mcommit 5560c95aacd4af2c3ab4b8e8cf49eccbbf72125d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 9 18:00:29 2018 -0500

    update IPs to Vivado 2017.4

[33mcommit 0296d953ffc4c8c01930ff659e67e4ff485f7576[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 9 15:55:28 2018 -0500

    utils/accelerators.mk: check if list of installed accelerators exists before editing

[33mcommit 7fb4ff8cf869a1909df7b4f7e508f20fec4a94cc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 9 15:06:44 2018 -0500

    accelerators/common: upgrade to latest syn-templates

[33mcommit b9594ea6d6a371f6714b94ad5d23a5192873ee60[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 9 15:04:35 2018 -0500

    accelerators: fix stratus Make and project

[33mcommit 0fa12bb288eeb8e76e98d1c2c297da329a2e0f5b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 9 15:02:44 2018 -0500

    accelerators/sort: improved sort with implicit memories

[33mcommit 9a045a6ea6d976dc865018a75aaa1475f2637857[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Feb 3 01:49:11 2018 -0500

    Add multiple CPU features to L2 and LLC wrappers, which are now complete.

[33mcommit a87871d33f0291a937872007859ad01f3939dedc[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Feb 1 03:59:53 2018 -0500

    Completed and tested testbench of L2 cache for multiprocessor case.

[33mcommit 2c7baaef5aad051af189dea61d1f6ec36fa5beeb[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Feb 1 02:43:59 2018 -0500

    WIP: Switch to explicit memory and add some protocol regions for memory access.

[33mcommit 0fa08592416cedcfce8eb2893dbeb5abc45dea73[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Feb 1 00:41:35 2018 -0500

    WIP: Bugfix on testbench of L2 cache.

[33mcommit 8ceda0b8bd52f272503e6d2257089d4a60c835ee[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Jan 31 04:00:45 2018 -0500

    WIP: Extend testbench of L2 cache to multiprocessor case.

[33mcommit 81c1297e17f33a232125d549001262971f3b97eb[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Jan 29 01:25:40 2018 -0500

    Setup L2 private cache testbench to cover the whole coherence protocol.

[33mcommit fe0629f2bdbad6367288d2a1f70cef52b3c74904[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Jan 28 18:52:52 2018 -0500

    L2 private cache: define/correct macros, polish code and make it compile.

[33mcommit 018aa15d19a459d94cfb80e31f1db04b366d3664[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Jan 24 01:34:05 2018 -0500

    Complete forwards management of L2 private cache.

[33mcommit 510b9a2eeb616580c3f306193f1de1a156fe9022[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Jan 23 15:31:29 2018 -0500

    Complete requests management of L2 private cache.

[33mcommit e0dea89b086093d229a78c94865863332aa69c94[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Jan 16 18:52:18 2018 -0500

    Complete responses management of L2 private cache.

[33mcommit 873c717bf53e456ba98061cba261f35984c4e882[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Nov 1 17:04:08 2017 -0400

    Add debug_led to tile_mem to avoid assert signals to be optimized by the synthesis.

[33mcommit aa0324953af2f101856c37efc38655ee1bf0c44f[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Oct 6 00:11:58 2017 -0400

    Fix memlist_gen.sh printout small bug. Evaluate N_CPU_BITS inside the script because that has changed in caches_consts.hpp.

[33mcommit 3ff1b6714d578fe2c6d6d3c10c286f8edecb37ed[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Sep 26 17:46:53 2017 -0400

    systemc/caches/sys/tb: add missing name declaration to sys_tb constructor

[33mcommit 521c9af72e55e1900c812e599c84219c6121176f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Sep 26 17:22:54 2017 -0400

    systemc/caches: add structure for system testbench

[33mcommit 719949e57cbf676d24c1716f0084cf049298c313[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Sep 26 11:36:41 2017 -0400

    systemc/caches: add L2_ and LLC_ prefix to some define pragmas

[33mcommit 6d58bf86ef28a9c52255874fc811ab79576ad77d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Sep 26 11:35:42 2017 -0400

    systemc/caches/common/lib: use ilog2 for constants

[33mcommit 1627596fbcba1c68c221402f930cd0593ddbd0cf[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Sep 26 13:59:51 2017 -0400

    systemc/caches/*/memlist_gen.sh: BUGFIX remove space in strings to grep.

[33mcommit 5ee4da4aaf7965fa48bc6bc72c20347481c76a63[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Sep 26 13:12:50 2017 -0400

    rtl/include/sld/caches/cachepackage.vhd, rtl/src/sld/caches/*: Add rst_tb for llc cache.

[33mcommit b2210fa51c568535e9a54b61a0b144456e37a1a4[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Sep 25 13:38:40 2017 -0400

    systemc/caches/README.txt: Update info on memlist.txt update and minimum size of the caches.

[33mcommit cc213ae7e9f1a03e357235bdde5cde0ec15c6c90[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Sep 25 13:31:14 2017 -0400

    systemc/caches/llc: Adapt llc to function with any number of sets and ways (>1 sets, >1 ways, >1 cpu).

[33mcommit 7caa8cfd10e3ccace29420143bc7246d8e885849[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Sep 25 13:30:39 2017 -0400

    systemc/caches/l2: Adapt l2 to function with any number of sets and ways (>1 sets, >1 ways).

[33mcommit baed47caf737f36c3e7c1804d5aed991d17bd5f9[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Sep 25 13:29:38 2017 -0400

    esp-caches/systemc/caches: memlist_gen.sh. Script to update memlist.txt based on caches/common/lib/cache_consts.hpp.

[33mcommit 084c7f28e5bde09748c272e477606ea550a55205[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Sep 21 19:48:08 2017 -0400

    systemc/caches/llc/tb: Execute tests for multiprocessor only if N_CPU > 1.

[33mcommit 6fe1068cc9323f78d9bd993a42eeeb9bb9f48eb5[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Sep 21 19:33:31 2017 -0400

    systemc/caches/llc: add LLC tests for multiprocessor. To be continued.

[33mcommit daf5b5264b76c2b745a912dc6fcd8b4cfcd6a69a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Sep 21 18:46:21 2017 -0400

    systemc/caches/llc: use implicit memories

[33mcommit c237de9cc2c957420b2334344e3612385b222175[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Sep 21 17:24:07 2017 -0400

    systemc/caches/l2/tb: Fix byte and halfword expected results in the testbench. Instead, the cache had already been fixed before.

[33mcommit f649192d16d3e6515754cbc21acdaa6f72fb404a[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Sep 7 14:42:14 2017 -0400

    cache_consts.hpp: Assign constants to the coherence planes.

[33mcommit 04fca37202a24c1b21282a0b0812e5e16027636e[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Sep 7 14:41:05 2017 -0400

    l2_wrapper.vhd, llc_wrapper.vhd, tile_cpu.vhd, tile_mem.vhd: Change/add debug probes.

[33mcommit 184170c54d11bd30f26ecbd62d2197166dc318e0[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Sep 1 00:20:52 2017 -0400

    llc.cpp: Add invack_cnt.

[33mcommit 08f6ba0e516f88480b03009525fa44c47a8ea20c[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Aug 31 17:40:57 2017 -0400

    llc.cpp: Add full management of REQ_PUTS and REQ_PUTM. Move some local variables inside the infinite main loop.

[33mcommit e8e3c4682e5e3bceaf06bc116aeb259e97aadd84[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Aug 31 16:48:49 2017 -0400

    llc_wrapper.vhd, cachepackage.vhd: Adjust LLC_BOOKMARK_WIDTH. Remove llc_rsp_in_data_coh_msg as it was removed from the LLC interface.

[33mcommit 93ab267f904342e0497fc50ca19c904d6e11028e[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Aug 31 13:24:44 2017 -0400

    systemc/caches/common/lib/cache_types.hpp, llc/src/: Complete the management of Req_GetS and Req_GetM. Add the management for incoming Rsp_Data.

[33mcommit de2b9288e02a4c89def61ad4c14f78b1e81c2d7f[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Aug 31 11:50:55 2017 -0400

    systemc/caches/common/lib/cache_types.hpp: Remove coh_msg field from llc_rsp_in_t as there is only one kind of possible incoming response (RSP_DATA).

[33mcommit 70bba29f33f442b8d090e28b5de04fc4086c60d9[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Aug 31 11:49:25 2017 -0400

    systemc/caches/llc/src: Add sharers and owners memories.

[33mcommit ecc05843c9b705f5fa7120855323c08d30d8ea2a[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Aug 31 00:50:04 2017 -0400

    Resize LLC to support 2 L2 caches.

[33mcommit a9905d3dd5a2394ef6477711e497b6780e18f39a[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 30 12:07:35 2017 -0400

    systemc/caches/llc/src/llc.cpp: Change eviction management. Now using a protocol region to make it comply to what the testbench expect. Protocol region is to be removed.

[33mcommit 09879be73825cb2902ce81512269a093cb8b2181[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 30 12:06:32 2017 -0400

    systemc/caches/llc/src/llc.hpp: Add debug signals to map internal behavior of LLC.

[33mcommit f40688c719ce2dbf80839ef1fb1a96e8e26595bf[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 30 11:54:51 2017 -0400

    systemc/caches/llc/tb/llc_tb.hpp, system.hpp: Add debug signals that map internal behavior of LLC.

[33mcommit 8ff59d53045bc044efbb8c90664e2487b41ac2dd[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 30 11:53:32 2017 -0400

    systemc/caches/llc/src/llc_directives.hpp: Add generic assert. Flatten hprot_buf.

[33mcommit 1890b29330d6309b13113055f105615aaffe499e[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 30 11:52:26 2017 -0400

    systemc/caches/common/lib/cache_consts.hpp: Add generic assert for LLC.

[33mcommit b444b8e0d6990337e314ac193c67e1dc717a64f0[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Aug 28 01:17:04 2017 -0400

    socs/common/socmap_types.vhd: Go back to 4 MAX CPUs as it does not work with 1 MAX CPU.

[33mcommit 1d4d5628c8a5dc14bf350f0d65d5441ab5773ea5[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Aug 28 01:16:18 2017 -0400

    rtl/*/sld/caches/llc_wrapper.vhd, cachepackage.vhd: Add rsp_out management, responses from LLC to L2 caches.

[33mcommit 6d5dd00661ab122aa0baff01cb90b72b69010b96[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Aug 27 15:26:22 2017 -0400

    rtl/src/sld/caches/llc_wrapper.vhd: Add ahbm fsm between LLC and AHB.

[33mcommit b813e63b8a7cf2515667feb60c3c84dd03df57b1[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Aug 27 13:18:22 2017 -0400

    socs/common/socmap_types.vhd: Add constants to be used by the VHDL LLC wrapper.

[33mcommit 48eddef8ef5e7e509bf5ead3fed9f50a1649441a[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Aug 27 13:17:14 2017 -0400

    change l3 wrapper name to llc wrapper

[33mcommit 7ace28e643464df6ebe4ae7b0c6feb2bcf2f6e00[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Aug 27 00:20:41 2017 -0400

    systemc/caches/llc/src/llc.cpp, tb/llc_tb.cpp: Improve execution time by moving around wait() statements.

[33mcommit 0cbc1b31e51007de6aa9834eafdfff7eb1fcafe7[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Aug 26 19:04:11 2017 -0400

    systemc/caches/llc/src: BUGFIX Add hprot, fix address of evicted lines, add a lot of wait() to make it work (to be removed later).

[33mcommit 029b9ae38ab7a5702dabe64ffabb0b521c0c08d0[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Aug 26 19:03:16 2017 -0400

    Add some bookmarks for the LLC.

[33mcommit f400688a012db10571def9f4bea3e1a2c53159a6[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sat Aug 26 19:02:31 2017 -0400

     systemc/caches/llc/tb: Add tesbench for the single CPU LLC.

[33mcommit 49f4090765c0e8a4bce36033494f694bcab7255c[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Aug 25 22:21:24 2017 -0400

    systemc/caches/common/lib/cache_consts.hpp: BUGFIX Correct typos in two constants' names.

[33mcommit 9d577a6b9a5a697218d966f0cfa8fb311d3670cc[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Aug 25 22:11:43 2017 -0400

    systemc/caches/l2/tb/l2_tb.*: remove function make_line_of_addr and place it in cache_utils.hpp

[33mcommit 8289630854f3231d3f4d0a0acdbc4da5bed0ea95[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Aug 25 18:31:20 2017 -0400

    systemc/caches/common/lib/cache_consts.hpp: Set constants to have system with 1 CPU

[33mcommit ee611736d689c40cdb2afc2daae11598cb57aed3[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Aug 25 18:22:01 2017 -0400

    systemc/caches/l2/src/l2.hpp: BUGFIX Missing second parameter or HLS_MAP_TO_MEMORY.

[33mcommit f50757139a9888aa4d531843f5510d9641463f9d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Aug 25 18:19:01 2017 -0400

    /systemc/caches/common/lib/cache_utils.hpp: Move here debug function make_line_of_addr.

[33mcommit 3476e698430e521224523a4e9e9cccc5b21c3423[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Aug 25 18:17:05 2017 -0400

    systemc/caches/llc/hls-work-virtex7/src: BUGFIX Missing protocol regions and wait().

[33mcommit 2604e82277435eb3b172f61f15c3e3c3cc2621f9[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 23 16:52:37 2017 -0400

    systemc/caches: Move rand functions to common/lib/cache_utils.hpp to be used also by the LLC.

[33mcommit 36b3703f7acd842f818d064d90dbe8ab51472a0d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 23 16:22:09 2017 -0400

    systemc/caches/llc: Add LLC FSM. This first FSM only supports 1 CPU.

[33mcommit 0cc7402c81909519f2bd1b49a527bb0a4199ea0d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Aug 22 00:39:17 2017 -0400

    Finish reverting to a system with request buffer of depth 4.

[33mcommit c42ddbbadcc5e0e4aea43b4f3eaebce3da575606[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Aug 21 23:12:16 2017 -0400

    systemc/caches/llc: Add the files for the Last Level Cache (llc). The structure is there but the FSMs of the directory controller and of the testbench are empty.

[33mcommit 4244bde58f59846187cdce2cd3fe1903101c6612[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Aug 20 21:17:10 2017 -0400

    systemc/caches/l2: remove debug outputs that were mapping internal signals.

[33mcommit 8cfa68d815b38f6612d23af4e1b252c9213f2461[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Aug 20 21:13:34 2017 -0400

    socs/xilinx-vc707-xc7vx485t/top.vhd: add debug probes for the ethernet ahb master eth_ahbm.

[33mcommit 02eab590b292a7ae089e4392392d35c389c0e6d9[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Aug 20 21:12:52 2017 -0400

    rtl/src/sld/caches/l2_wrapper.vhd, rtl/include/sld/caches/cachepackage.vhd: Remove internal signals coming from the l2 cache

[33mcommit 658d52dc5fd2f6a2c7e030c5be3a6b6a2f05d1d0[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Aug 20 21:12:04 2017 -0400

    rtl/src/sld/tile/mem_noc2ahbm.vhd: BUGFIX error in the send_header state.

[33mcommit 1d855fd059fbc38c57b5df99f2eb8f644cf9ff64[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Aug 20 20:59:39 2017 -0400

    Revert "UNDO commit to simplify l2 to find a bug."
    
    This reverts commit 4c136ae0ea14fdd65f488deeebec45112ca62821.

[33mcommit 4c136ae0ea14fdd65f488deeebec45112ca62821[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Aug 17 15:09:57 2017 -0400

    l2.cpp: remove support for N_REQS > 1, which includes the set_conflict management.

[33mcommit ad428bf40ef6f27d6e534a944477c0f4a6464238[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Aug 17 14:46:07 2017 -0400

    rtl/src/sld/tile/mem_noc2ahbm.vhd: When L2 present answer with RSP_EDATA to GETS requests and not with RSP_DATA

[33mcommit f049f896475dd457adcc5a42a3c209efd5e64b92[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Aug 17 14:45:11 2017 -0400

    caches systemc and rtl: add asserts for debug, reduce the number of concurrent requests handled by the l2 cache to 1 (N_REQS = 1)

[33mcommit dbc1de009319db6056cee3cf15181c7ab21c2fbe[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Aug 17 14:43:00 2017 -0400

    utils/grlib/software/leon3/, socs/xilinx-vc707-xc7vx485t/systest.c: Expand bare-metal texting by adding some of gaisler tests.

[33mcommit 2f97900c4481a7ff9f9c863ecb5c502e7ae1d595[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Aug 15 21:05:34 2017 -0400

    rtl/src/sld/caches/l2_wrapper.vhd: for now never send atomic requests to l2 cache.

[33mcommit 64fc613548216504b593e55625fe38b163872d76[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Aug 15 10:18:41 2017 -0400

    Export internal signals from l2 cache to help system debug. Also add signals for ILA debug.

[33mcommit 8a4b290da79a2f0639f037248b995fb557c573ae[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Aug 15 10:17:42 2017 -0400

    rtl/src/sld/caches/l2_wrapper.vhd, rtl/include/sld/caches/cachepackage.vhd: Add internal signals from l2 cache. Fix bug: invalidation writes were not ignored by the l2 wrapper.

[33mcommit aee56b112fbd484f8a145081e334ccef781bb825[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Aug 15 10:15:14 2017 -0400

    rtl/src/gaisler/ddr: fix ahb2mig: sensitivity list and address msb

[33mcommit 8c49b6c9736e4dfd5ab1461ea8d0693ec69a4dc3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Aug 11 14:57:04 2017 -0400

    rtl/src/gaisler/ddr: fix ahb2mig: sensitivity list and address msb

[33mcommit bcdb1ad0bdf75d05c7ff5cc5c48aab13f0d80e4e[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Aug 10 11:02:51 2017 -0400

    rtl/src/sld/caches/l2_wrapper.vhd: Fix bug, now load_alloc_reg is used properly.

[33mcommit 344b2200e7af85a87c5f1a7fbafeef3629b881e1[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 9 18:34:12 2017 -0400

    systemc/caches/common/lib/cache_utils.hpp: Fix bug on halfword and byte writes.

[33mcommit e03e9bc4efe979cdee140e2690b626413df30254[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 9 18:33:44 2017 -0400

    systemc/caches/: Export to the output of the cache a lot of internal signals to ease RTL debug after integration into ESP. This feature will be removed or only enabled in debug mode.

[33mcommit a7f17b6022f83a93320e390cb82feacbe8d0f55e[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 9 18:30:14 2017 -0400

    socs/xilinx-vc707-xc7vx485t/systest.c: Systest now included a custom l2 cache test and the usual "Hello ESP!".
    utils/grlib/software/leon3/l2_cache_test.c, report_device.c, testmod.h: Expand and improve the l2 cache test.

[33mcommit 18a6234284c685456eb10e3112e1d58a3c35a46c[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 9 18:28:49 2017 -0400

    rtl/src/sld/tile/mem_noc2ahbm.vhd: Fix bug introduced while adapting this component
    for the case of L2 present, LLC not present. An increment on the address had been mistakenly removed.

[33mcommit b756ac40feb17a2e4427602f56baff06ea073c92[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 9 18:25:48 2017 -0400

    rtl/include/sld/caches/cachepackage.vhd, rtl/src/sld/caches/l2_wrapper.vhd:
    Fix bugs: 1) read_alloc is now a proper register. 2) Reads always read a full word
              from the cache line output of the l2 cache, regardless of hsize.
    Debug: Add a log of signals coming from the l2 cache for debug purposes, they will be
           later deleted or only used in debug mode.

[33mcommit 0645cf765bf90d9e165a2e43095f26aa3a2545c5[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Aug 7 17:34:37 2017 -0400

    systemc/caches/l2/src/l2.cpp, l2_directives.hpp, systemc/caches/common/lib/cache_consts.hpp: Add 3 assertions to the l2 cache controller.

[33mcommit 470917d7c0648e778d146208efd489f1107fa90d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Aug 7 16:05:17 2017 -0400

    utils/caches.mk: Fix typo, -wdir3 is now -wdir as -sim argument.

[33mcommit e641ca47a004d1c9db217b13e5b3abedc837187b[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Aug 7 16:04:02 2017 -0400

    Fix flush management and add a flush_done output. Fix set conflict stall management.

[33mcommit 72ed2764c88c2a8df95368510a61486abba36887[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Aug 7 16:01:49 2017 -0400

    utils/grlib/leon3_sw.mk, utils/grlib/software/leon3/l2_cache_test.c: Add bare-metal test for the l2 cache (for leon3).

[33mcommit a5403adf3977053d1367d6c382d55e04b86ef2a8[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Aug 7 16:00:54 2017 -0400

    utils/grlib/software/leon3/testmod.h, report_device.c: Add read_report function.

[33mcommit 46383922e5529f97fea6cd3dbf9f73159c5d062e[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Mon Aug 7 15:59:34 2017 -0400

    caches/l2_wrapper.vhd, caches/cachepackage.vhd: Add custom_dbg signal. Fix flush management to match l2 cache behavior.

[33mcommit 8fccd942a9974eec1ee3feb64f86299b896ef9c1[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 2 17:49:19 2017 -0400

    rtl/src/sld/tile/mem_noc2ahbm.vhd, rtl/src/sld/caches/l2_wrapper.vhd, rtl/include/sld/caches/cachepackage.vhd: Fix some bugs found in simulation.

[33mcommit 58ae6c2b919c5e8634c067e2a192ad4d03589912[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 2 17:48:42 2017 -0400

    systemc/caches/l2: Fix eviction stall, implement set conflict stall, implement full reqs buffer stall. Add a new debug signal called custom_dbg.

[33mcommit a6fd638df787c155423a72a7066c08839649fd19[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 2 17:46:41 2017 -0400

    socs/.gitignore: Ignore .lst files.

[33mcommit ef428e5ea4b58841d8e3ec86ad8958c1889ce155[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Aug 2 17:44:11 2017 -0400

    utils/memgen/memgen.py: This was kept local until now. This version of memgen works for explicit memories, that as of now are used by the caches.

[33mcommit 1b049ea90202b2985a7e9ba5063a153e760e18dd[m
Author: Luca Piccolboni <piccolboni@cs.columbia.edu>
Date:   Wed Jul 26 12:08:44 2017 -0400

    utils/Makefile: fixed path grlib netlists

[33mcommit 6e66456de1f11127913f53afdd0b033c190f9624[m
Author: Luca Piccolboni <piccolboni@cs.columbia.edu>
Date:   Wed Jul 19 21:15:06 2017 -0400

    utils/Makefile: fixed typos in target names

[33mcommit 210a37d2aac2cc49ec07146f53ecc92e78441931[m
Author: Luca Piccolboni <piccolboni@cs.columbia.edu>
Date:   Mon Jul 10 15:36:43 2017 -0400

    utils/sldgen: fix implementation point name

[33mcommit 3dc6dcf1a767f580ef93d23ee44d77872219b34c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jul 10 14:03:14 2017 -0400

    utils/sldgen: fix implementation point search

[33mcommit c571b4bb0fe43d0b75ff3bbec35166c3d7f43f53[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jul 7 16:53:23 2017 -0400

    stratus make install: copy necessary v_rtl parts

[33mcommit fe2267269e5305e8014d633b3760db35138e9594[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Jul 5 16:40:42 2017 -0400

    Fix bugs of the first version of cachepackage.vhd and l2_wrapper.vhd. Move fifo_custom.vhd from include/ to src/.

[33mcommit 677afe00d10259a06a11fd05f6dd323c2ac0e16b[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Jul 5 16:38:56 2017 -0400

    Add debug_led to top entities and tile_cpu. The LED serves to stop Vivado from erasing debug signals in the cache wrappers.

[33mcommit e172685a35630cef41f9c461720e9631dfa7f2bf[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Jul 5 16:37:25 2017 -0400

    systemc/caches/ : Remove wr_rsp (write response) channel.

[33mcommit 43291cf1df5191c842f7ebf57f36c372b6c13397[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Tue Jul 4 22:29:56 2017 -0400

    rtl/*/sld/caches/cachepackage.vhd, l2_wrapper.vhd: WIP. First design of the l2_wrapper for the l2 cache. Cachepackage contains the required constants, components, types and functions.

[33mcommit d5173f9978cd45b6f5852f56035493481894324c[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Jul 2 23:32:56 2017 -0400

    tech/virtex7/caches/.gitignore: Ignore Verilog of caches generated by HLS.

[33mcommit b14748210ea2dbafc413768c233af7326ee17c68[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Jul 2 23:31:22 2017 -0400

    Adapt ESP to accept the new caches. The main change is the name of the queues for coherence response messages.

[33mcommit 2d13c7f44551209f541c3dd57ab609129fed2fcb[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Jul 2 23:29:15 2017 -0400

    rtl/include/sld/caches/ rtl/src/sld/caches/ : Add caches wrappers.

[33mcommit 0e719d0aeeeca32a9b22082d63fcb98096601fc4[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Jul 2 23:27:44 2017 -0400

    systemc/caches/l2/ : Change from l2_cache to l2 folder name and files.

[33mcommit d1f39517a609afce3664b8c62fb564ebf07ae2d4[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Jul 2 23:23:48 2017 -0400

    accelerators/common/stratus/Makefile, utils/Makefile, utils/caches.mk: Add caches generation to Makefiles chain. Use $ make caches to generate all caches. RTL of caches will be placed in tech/

[33mcommit a90c0c0703426eb28c73949da1e09cee9f91436d[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Mar 2 00:33:11 2017 -0500

    socs/common/: add support for multi processor. debug unit moved to tile_mem, update with CFG_NCPU_TILE where needed, update coherence signal names, instantiate cache wrappers.

[33mcommit 278075c8394033df862debad5de31fa91ef3c291[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Wed Mar 1 18:01:51 2017 -0500

    rtl/include/sld/tile/tile.vhd: modify component definition for cpu_ahbs2noc and mem_noc2ahbm adding cache enable generics and the updated names for coherence signals.

[33mcommit cfd94586bd45d546c921a69662adc414e4d00678[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Feb 24 19:15:36 2017 -0500

    rtl/src/sld/tile: add support for L2/L3 caches

[33mcommit 3ffd09193f2f51b4ac8c74612368c8e5069ed772[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Feb 24 18:58:56 2017 -0500

    TO BE IMPROVED: define some common types necessary for L2/L3 cache wrappers
    
    Conflicts:
    	rtl/src/sld/caches/l2_wrapper.vhd
    	rtl/src/sld/caches/l3_wrapper.vhd

[33mcommit 6f008a265aaac5ef23f888cee4d1dbd1e26b8577[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Feb 24 18:38:41 2017 -0500

    utils/socmap: define constants and types for L2/L3 caches

[33mcommit 1244c093d333a567f5caa1da5b8079623da1b97c[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Feb 24 18:04:17 2017 -0500

    sldgen/templates/sld_devices: add L2 and L3 devid

[33mcommit a7bd068b60f39a9d74468859a91568da027c8264[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Feb 24 17:57:56 2017 -0500

    gaisler/leon3v3: export flush signals

[33mcommit b025302102c2ad636ff4dcccf7e85fcaaaf08861[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Feb 24 17:40:07 2017 -0500

    utils/grlib/tkconfig/in/leon3.in: fix line size config

[33mcommit fa1a9dca03da78b11db44a5d20e7f52e568759fb[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Sun Jul 2 12:24:43 2017 -0400

    STABLE. Add eviction in L2 and the related tests. Improve testbench by adding op and op_flush functions to make it more modular and concise (less-than-word testing removed temporarily).

[33mcommit de80bc94110eee6221d875de0f425394ef4055bc[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Jun 30 19:43:47 2017 -0400

    STABLE. Add less-than-word management to L2 cache. Add related tests.

[33mcommit 1611fdd0de50157949e696accaa204427c3aa686[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Fri Jun 30 17:30:57 2017 -0400

    cache_consts.hpp, l2/tb/l2_tb.cpp: add a general report constant (RTP = RPT_OFF or RPT_ON) to enable/disable all reporting of the testbench.

[33mcommit 86ff75755b111a4d7df7e176fe2a38f8402782a1[m
Author: Davide Giri <davide_giri@cs.columbia.edu>
Date:   Thu Jun 29 15:37:01 2017 -0400

    systemc: add caches

[33mcommit 08393a8e69abe9909ce86150a9bffac324954fd4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 29 15:35:13 2017 -0400

    accelerators/common/stratus/Makefile: fix memlib with multiple bdm

[33mcommit 48979231cedfb7932a2630cc44ca79100a57aa2a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 29 14:25:35 2017 -0400

    add systemc/common/stratus

[33mcommit 0ca7394b406aa5863a756eb8222115782294ad5f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 29 14:23:52 2017 -0400

    accelerators/common: update Stratus project.tcl and Makefile to work with sc_components

[33mcommit 91f5e8ec980bae571c6ef6936f6a5f8017e5d731[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 29 14:22:38 2017 -0400

    memgen: accept empty memory list

[33mcommit fb3bb476e4299c896a17e71d0dcfbbaf4467bbea[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 29 14:21:42 2017 -0400

    tech/virtex7: add sc_components folder

[33mcommit eac696b8ceacd2fdf9e2a2cb73debc6313b5ad08[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 29 14:20:57 2017 -0400

    tech/virtex7: update .gitignore

[33mcommit 9a52f26c59779045c4ab00901f4ed3ca96b4a4e2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 26 17:46:39 2017 -0400

    utils/memgen: fix mem write for non power-of-two bit-width

[33mcommit baece0f3b0d81488efc12685ade84ae21d88256e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jun 26 17:38:15 2017 -0400

    utils/memgen: fix mem write for non power-of-two bit-width

[33mcommit 020e1ee08ac77c3c70cdf24b4ab3e49a17bd0a49[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Jun 24 13:49:32 2017 -0400

    utils: update sgmii behavioral model version for simulation

[33mcommit 1a884047890635ffe10af624bcbd6c38d2027dc7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jun 23 18:04:34 2017 -0400

    constraints: update mig and sgmii to Vivado 2017.2

[33mcommit 13a3436008eec0a116990b965b1e0eaf47329cc0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 21 10:06:47 2017 -0400

    utils/memgen: bdm generation with reversed port ordering

[33mcommit 0d6759aa0a63fecedc629f4c7aea746f51ac61f0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 8 18:52:40 2017 -0400

    socs/profpga-xc7v2000t/Makefile: update XIL_HW_SERVER_PORT and FPGA_HOST

[33mcommit aaadb0785175cba08f190d5c4c9061d17e63f371[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 8 18:51:13 2017 -0400

    gig_ethernet_pcs_pma_v16_0_0 -> gig_ethernet_pcs_pma_v16_0_2 as per Vivado 2017.1

[33mcommit e87ac203c8aa3ce0bfff6ad4b9291a617c1e4cd0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 8 18:40:39 2017 -0400

    xc7v2000t: update to Vivado 2017.1

[33mcommit ed26bf27e47988ed02bf6bc7f9345bf3eac93505[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 8 18:29:44 2017 -0400

    VC707: update to Vivado 2017.1

[33mcommit 091f270335bc87c428b29afbc45b57822e9139bc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jun 7 11:23:06 2017 -0400

    soft/leon3/sysroot/applications: add empty folders to sysroot template

[33mcommit 77bf816792e67b2bc1df2508ee3655162089df1f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 1 17:58:04 2017 -0400

    utils/socmap/NoCConfiguration.py: fix synchronizers flag

[33mcommit d3f5a0431caebe490f72353ec0ff2831903216bd[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 1 16:16:33 2017 -0400

    update some environment variables name and assignments

[33mcommit 7e12d220c210b87d03cca5044804e87bd435db58[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 1 14:33:50 2017 -0400

    utils/Makefile: add sim-gui to help

[33mcommit 43b048bc10b5c68f638f0fe33cf6d584bb1b73c0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 1 14:08:15 2017 -0400

    utils/Makefile: fix typo

[33mcommit 7f2d3811e0948c5f130e5968870ce5d2019189d5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 1 14:07:25 2017 -0400

    utils/Makefile: fix clean and distclean when has not been built

[33mcommit d665d90a1913503bf19937605863c1929f9abbfc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 1 14:06:03 2017 -0400

    utils/socmap: replace gree with darkgreen

[33mcommit 797f7e66c2164064bb29cdea9fbfdf4c98057e1b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 1 14:05:31 2017 -0400

    utils/socmap/power.xml: remove FFT, add place holder numbers for SORT

[33mcommit ae00a4de9239462319d4f59ec0b8d4c0e4f51ead[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 1 14:03:19 2017 -0400

    constraints/xilinx-vc707-xc7vx485t: remove unused files

[33mcommit 2533dbb712ee478690d164368133b44d521b5375[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jun 1 14:02:38 2017 -0400

    socs/defconfig: remove FFT

[33mcommit 95649280b4f7f3ba9ceb14eaf274c443bb815be8[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu May 11 16:59:52 2017 -0400

    utils/scripts: add accelerator initialization script

[33mcommit fb184987cfb310deb4630e9a593d424be7d1c269[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 25 14:56:20 2017 -0400

    utils/design.mk and socs/xilinx-vc707-xc7vx485t/Makefile: .grlib_config must be included before checking if VSIMOPT needs sgmii library

[33mcommit 3fcbb9a6bb5e11f1bc9ff65b83940d937b05cd1e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Apr 25 14:51:54 2017 -0400

    utils/design.mk and socs/xilinx-vc707-xc7vx485t/Makefile: .grlib_config must be included before checking if VSIMOPT needs sgmii library

[33mcommit b37088b5252089eada5535f0a82f5b027bf79fdf[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 31 16:04:25 2017 -0400

    utils/Makefile: update help

[33mcommit 356f98268d680254f5a8611fb8445648c213c698[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 31 15:31:23 2017 -0400

    socs: update .gitignore

[33mcommit 42c7f95d4b053cb40dd5646686b49c5837d30c14[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 31 15:30:30 2017 -0400

    utils/sldgen/templates/noc_interface.vhd: set PT_NCHUNKS_MAX to 0 if scatter-gather DMA is disabled

[33mcommit cd6b9b0aae6b4a1efc1a099b2e8ef36b14aa16a1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 31 15:29:53 2017 -0400

    utils/design.mk: fix source list for top module RTL files

[33mcommit ce82fdd2bce97d96254964e7d0a883dda82b172c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 31 15:05:48 2017 -0400

    utile/Makefile: add leon3 device drivers and test application targets

[33mcommit 5e9786a477bd2a90d7b4df92ab119312040d7e2f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 31 15:04:54 2017 -0400

    utils/accelerators.mk: add targets for drivers

[33mcommit b3e1df0c8c1898119f101cb3143379b2e74cd52b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 31 15:01:08 2017 -0400

    soft/leon3/sysroot/etc/rc.d/init.d: update drivers init script

[33mcommit 00912a9cb7b8818cf4ec440b5d7f3b5d8a57f10d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 31 15:00:20 2017 -0400

    soft/leon3/linux: update .gitignore

[33mcommit 4bee7becf5d42a691723197374b0cd3e9f989ffe[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 31 15:00:00 2017 -0400

    soft/leon3/linux: add sort baremetal and linux drivers with test application

[33mcommit ec4d3dbd3248432e5d0078ecdbdb4ea48a731251[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 31 14:57:33 2017 -0400

    soft/leon3/drivers: add libtest

[33mcommit 0bdbc00c15d6d8950bc98e3d9ca46d1b4487951a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 31 14:56:57 2017 -0400

    soft/leon3/drivers: add baremetal probe equivalent function

[33mcommit f5482d0b72594968c8a32de6ea11d9eac6c1c435[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 31 14:56:02 2017 -0400

    soft/leon3/drivers: add inlucde headers

[33mcommit 8d6a5da99b53ec3d34f6fe1dec62e6144998e8f9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 31 14:54:55 2017 -0400

    soft/leon3/drivers: add dvi baremetal and linux drivers

[33mcommit 90826e0b4903d6a0d087c5da23c1432f1faf3c55[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 31 14:43:23 2017 -0400

    soft/leon3/drivers: add driver.mk and .gitignore

[33mcommit 7384876b3a10d10c313d1546c31ac9a4f2b5ac5b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 31 14:42:59 2017 -0400

    soft/leon3/drivers: add esp

[33mcommit 99c478d61e39f5a109d1b87fcd8b63e0a404c6b2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Mar 31 14:42:32 2017 -0400

    soft/leon3/drivers: add contig_alloc

[33mcommit a960a3ff7c68ff72c7f5bfd1586f1e0453ef2385[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Mar 30 14:10:32 2017 -0400

    soft/leon3: add sysroot template

[33mcommit 35d9926443eb7627b7fcfa46f7b271cc5a50d55c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Mar 30 12:58:52 2017 -0400

    utilx/Makefile: add Leon3-Linux targets

[33mcommit a52bd31bb920bcef0188ab66c67861c008a45008[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Mar 30 12:55:10 2017 -0400

    update soft/leon3/linux: leon3 defconfig

[33mcommit 58148b855bb9407e68208493da5e6e39f64fc916[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Mar 30 12:54:25 2017 -0400

    add submodule soft/leon3/linux

[33mcommit aa6018dae728afbf8e0858723aa5d35ea13e790a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Mar 29 22:54:23 2017 -0400

    utils/Makefile: prepend leon3- to software targets for leon3

[33mcommit 2cb6944823b756fa49fba0bbdb6dcf3987961f53[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Mar 29 15:28:44 2017 -0400

    utils/socmap/NoCConfiguration: fix spin_box clock region range

[33mcommit 8bd702895104a4fdcbb07e95b7d9b7677693af18[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun Mar 19 14:26:36 2017 -0400

    utils/sldgen: handle config parameters smaller than 32 bits

[33mcommit 4d323ec222004ea9c4f5c9618e20cd14a6cb7f44[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun Mar 19 13:51:45 2017 -0400

    utils/socmap: fix GUI accelerator descovery (indentation)

[33mcommit dca78941aa1525899deaf5978a9ef3b979193514[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Mar 6 10:58:31 2017 -0500

    utils/Makefile: proFPGA can be seen with faster JTAG clock

[33mcommit 8c7f84a9620e8c77cc1be9cb8b3998fd886c6dfc[m
Author: Davide Giri <dg2937@columbia@edu>
Date:   Thu Mar 2 17:21:42 2017 -0500

    utils/accelerators.mk: add installed.log target to create file if new repo

[33mcommit a9b62d5e0bd709de1a47ae5a3dcc0a2dfbb1c2f7[m
Author: Davide Giri <dg2937@columbia@edu>
Date:   Thu Mar 2 17:17:00 2017 -0500

    socs/defconfig: no accelerators should be instantiated by default as HLS hasn't run yet

[33mcommit a5067ca34423eaa1b1b377d31a2589ae8be985a8[m
Author: Davide Giri <dg2937@columbia@edu>
Date:   Thu Mar 2 17:06:29 2017 -0500

    utils/grlib/leon3_sw.mk: fix older bash compatibility issue

[33mcommit 5ac53a480f43ec93d829001c06110521cc89cb02[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun Feb 26 15:23:02 2017 -0500

    utils/Makefile: improve espmon and profpga clean targets

[33mcommit 07f845d168ffbb5605fa268662baad43ff33a254[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun Feb 26 15:22:35 2017 -0500

    socs: proFPGA boards folder links to proFPGA installation path

[33mcommit dcd4dfc7facf33b0898e86d64263a8c66896897d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sun Feb 26 15:02:06 2017 -0500

    utils/Makefile: fix typo

[33mcommit 414537785353b853d34f7e63c440487049025ccb[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Feb 25 23:01:47 2017 -0500

    utils: add esmon

[33mcommit f93177f21e5b98bcda5106871250ebafa2b89871[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Feb 25 22:58:41 2017 -0500

    Use proFPGA verilog source instead of VHDL

[33mcommit 29b9ee58f76bc09ca39e7a863aec2603d545c028[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Feb 25 22:51:15 2017 -0500

    constraints/profpga-xc7v2000t: use profpga clk4 as c0_sys_clk

[33mcommit 0770dca8c42838eb3d0fbd1e8b0249a80c848b76[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 24 17:26:25 2017 -0500

    utils/Makefile: fix typo in help

[33mcommit 7be3c8c0fc1a43b86aab45fd0a7ec5def37ca14e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 24 00:33:23 2017 -0500

    utils/Makefile: fix help spacing

[33mcommit 54504e3a22b229f473f09b888b4b0f73043cf640[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 24 00:23:53 2017 -0500

    make alone prints make help

[33mcommit 9634d98faffae16d4d109264d8361a42b14252a1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Feb 24 00:19:54 2017 -0500

    utils/Makefile: write target description with make help

[33mcommit 31e5b5216c0ae02dc316d6c32435108720f51b11[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 23 23:11:19 2017 -0500

    socs/profpga-xc7v2000t/profpga.cfg: update board configuration

[33mcommit 9e80ef64e9a13dbfafd69aeb2eb482510588c505[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 23 23:08:53 2017 -0500

    socs/defconfig/esp_xilinx-vc707-xc7vx485t_defconfig: add default HLS configuration for SORT

[33mcommit b8dfd39fd347c7f31e5c8025d583b42f7b62fda6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 23 23:08:12 2017 -0500

    utils/socmap: save and restore HLS configuration to .esp_config

[33mcommit a7864790bb2fc2f298a150e64c30e6157e1efba9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 23 23:02:08 2017 -0500

    utils/accelerators.mk: fix list of installed accelerators when rescheduling

[33mcommit 7817b8172d513044023d221e7b08e065aace0fac[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 23 18:37:39 2017 -0500

    utils/Makefile: add support for sldgen

[33mcommit 116a05ba1bb6f0cf872d1718f7f5d3708da6191b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 23 18:36:53 2017 -0500

    utils/socmap: Update system map generation to account for sldgen

[33mcommit 02adc0b3aebfbfe04c8ba5eac92499af247c08aa[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 23 18:34:43 2017 -0500

    utils/accelerators.mk: add sldgen targets and dependencies

[33mcommit d9f70ab2b2a69718816ae45c6ae8b89fbdefef6a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 23 18:32:56 2017 -0500

    utils/design.mk: add files generated with sldgen to list of source files

[33mcommit ee7e818654d72266ca3821b516c8cd8f0cb1fae1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 23 18:32:03 2017 -0500

    utils/sldgen: fix wrappers generation for compilation and synthesis

[33mcommit d12b0e5a31077cbcc35ac8090bcdd66883afec54[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 23 18:31:12 2017 -0500

    socs/common: pass hls configuration to accelerator-tile instance

[33mcommit 6f855c7dabf260bf814635adb45003f07d4a7dee[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 23 18:30:33 2017 -0500

    socs: local Makefiles define NOC_WIDTH, but we still only support 32 bits on this release

[33mcommit 88c9b33e506d53e2d64d8c287f80c2706acf2f4e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 23 18:28:38 2017 -0500

    socs/.gitignore: ignore sldgen output

[33mcommit 63f7a18cdb8fde2e3a731048ec8090d9527751ad[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 23 01:01:35 2017 -0500

    utils/accelerators.mk: clean and distclean delete accelerators log files

[33mcommit 927c8ddb177c2c6d42826392c4bf5a788a2008c5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 23 01:00:37 2017 -0500

    socs/common: remove tile_acc.vhd, to be generated

[33mcommit cbaf51d089e4b8d2125a14b37ab744620e518f2d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 23 00:59:26 2017 -0500

    utils: add sldgen to create accelerators wrappers

[33mcommit b83ef6e5b0b7b5d697330d22c45bee93beac36c9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 22 23:58:58 2017 -0500

    rtl, socs: remove physical-only pins vdd_ivr and vref signals

[33mcommit 273eb232e39009b62f83bb8dd4a487e966c836db[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 22 23:55:04 2017 -0500

    rtl/include: remove accelerator wrapper from package lists

[33mcommit d04cfe2d33b76aaed173a8a3073090851e64b036[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 22 23:53:40 2017 -0500

    rtl: remove unused IVRCMD.v

[33mcommit 4d1ecd34015ffa82a480a3b709b1cfa4c44a00d1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 22 23:53:16 2017 -0500

    rtl: remove accelerators wrapper to be generated

[33mcommit b0b578884be1f7e4994eeb4d0109657e2e3460f3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 18:28:44 2017 -0500

    accelerators/sort: add device_id to xml definition

[33mcommit 88678a2c9309be7a78912e5631d0347d8eaf381d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 17:39:53 2017 -0500

    utils/accelerators.mk: fix automatic variables

[33mcommit eacb00b5523c4938bf6556b003865dacb205e67a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 16:50:52 2017 -0500

    accelerators/common/stratus/Makefile: copy xml description to install folder

[33mcommit 3372ad36bc19b053dff08d7fddcef9942d5a9e45[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 16:48:37 2017 -0500

    utils/accelerators.mk: fix dependency of hls working directory

[33mcommit 09a1e8707b05234af08fe558404a1cf461e58b60[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 14:57:38 2017 -0500

    accelerators/sort/sort.xml: add register description for sldgen

[33mcommit 42901c0c2e10b9bf2bc10a869b73ad0f6b046271[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 12:33:48 2017 -0500

    rtl/include/techmap/gencomp/gencomp: accelerators need no tech_ability definition

[33mcommit c651d977db24927959d314ee304017ef1239f32a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 12:13:47 2017 -0500

    utils/accelerators.mk: define PHONY targets calling all accelerators targets

[33mcommit 8ed42ea1387e97e26cab05b2cc40c12164702a5a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 12:11:54 2017 -0500

    remove dependency from grlib/amba/devices: sld_devices.vhd will be generated based on available accelerators

[33mcommit f2aa5488e6e1b74851d1a6d7330db71ef1c24ff0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 10:48:45 2017 -0500

    rtl/include/grlib/amba/devices.vhd: remove SLD descriptors; to be generated in soc folder

[33mcommit 333e4d8824aae371afe8a491e0413650f95c7086[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 09:38:33 2017 -0500

    accelerators/common/stratus: cosmetic fix to plot

[33mcommit b534e5b609ea01c594d58692c73e2a855e63a0f1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 09:26:01 2017 -0500

    accelerators/common: remove common.mk

[33mcommit f03adce78f5f4ae1ebff5d37bbbc1cbe8f64f6d4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 00:57:44 2017 -0500

    socs: local Makefiles include accelerators.mk

[33mcommit c9bae106764390c20b87c6d72a72d930dc60763a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 00:53:52 2017 -0500

    utils: add accelerators.mk

[33mcommit af42bd5bff18b890f7ca2b74e9ee7a80bc1288d8[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 00:53:02 2017 -0500

    utils/memgen: remove unused area.log

[33mcommit 94bf8c67a22f9a8fef243a1821d40e1f5f80a8a4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 00:51:19 2017 -0500

    accelerators/common/stratus: add nimbus to plot hls results

[33mcommit c1c212de885f0b72105d62381ecb96f284e25a48[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 00:10:08 2017 -0500

    accelerators/common/stratus/Makefile: add install to PHONY

[33mcommit 1d87e966cc5305a72551cca540a48964afa7849a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 00:07:24 2017 -0500

    accelerators: mv sort/stratus/Makefile to common/stratus/Makefile

[33mcommit e932380fbdafa049ac380e3486ab4f5e2b876486[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 21 00:04:58 2017 -0500

    accelerators/sort/stratus/Makefile: add install target

[33mcommit d43a5d5aff6d23bc02be29dba602edcd0909468a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 20 23:03:14 2017 -0500

    accelerators/common/stratus/project.tcl: disable area-oriented optimizations to speedup scheduling

[33mcommit 30ec5197d36affe965935b9b16d92f06255f3635[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 20 23:02:00 2017 -0500

    accelerators/sort: place all HLS directives in sort_directives.hpp

[33mcommit a71a60d149712d457a674568cd4d80e9d8f14021[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 20 00:06:35 2017 -0500

    accelerators/sort: support DMA_WIDTH 32 and 64

[33mcommit 8c1d9c75885b4bbf147f1d5ed1e8961db20f74b2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Sat Feb 18 00:07:11 2017 -0500

    accelerators/sort: use io_config to pass matching DMA_WIDTH to tb and accelerator

[33mcommit d360ce5ba28fb747fa8f9914394f164af5cfb7c9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 16 19:11:54 2017 -0500

    esp/accelerators: add glbl as top module for RTL_V simulations

[33mcommit c38ea94971b8b73da43830095996eda7cfefda82[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 16 16:01:39 2017 -0500

    tech/virtex7: add memgen folder with gitignore

[33mcommit 563e68317e9652ad7c48901c2c8fc3c966dbb391[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 16 15:59:37 2017 -0500

    tech/virtex7: add acc folder with gitignore

[33mcommit 482b97500ae77d55526df4b321b3cea29f5ac35a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 15 13:49:28 2017 -0500

    accelerators: update .gitignore

[33mcommit 429e937c76189196f026080a1a1faaa48f29cf63[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 15 13:41:09 2017 -0500

    update submodule accelerators/common/syn-templates

[33mcommit 49c4afc6a1a616afb7c3af5f8924a889e2146976[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 15 13:39:19 2017 -0500

    accelerators/sort/src: allow maximum throughput on DMA write with latency constraint

[33mcommit ca3c35e97fc0b5646e15e2663b1973190d6b47b3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 15 13:38:19 2017 -0500

    accelerators/sort: mv syn to stratus; syn folder will be generated based on technology

[33mcommit 12ead5de96fc18750acda3a5c786a06d86aafcb3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 15 13:33:01 2017 -0500

    accelerators/sort/syn/project.tcl: remove FPGA syn-config as prototyping for asic synthesis

[33mcommit 1468a7be26f4f20343b6335c626e03f014ff6570[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 15 13:32:20 2017 -0500

    accelerators/sort/syn: fix Makefile distclean target

[33mcommit 7054a1d96b4307b6954ead5589fe1daf6c2fde34[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 15 13:18:55 2017 -0500

    utils/memgen: Improve memory description for Stratus (bdm) to allow maximum throughput

[33mcommit 0773f4ed108210c676775abea7de462590ea48dc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 14 16:20:47 2017 -0500

    update submodule accelerators/common/syn-templates

[33mcommit 7226a96549c86eef3a5fc5b582bde1b3df2d375e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 14 16:16:03 2017 -0500

    accelerators/common/stratus/project.tcl: fix cmos32soi library settings

[33mcommit a70a5a9e28551fe71269590312f2554c5d50fb1b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Feb 14 16:15:25 2017 -0500

    accelerators/sort/syn/Makefile: invoke memgen

[33mcommit 68b3b94f8d8ac307cbd3bc9ef71b7935725cb0b2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 13 17:58:58 2017 -0500

    accelerators: add initial sort implementation and Stratus configuration

[33mcommit bd06b89e4b203e0ae500f7c6b891c539edcf965a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 13 17:57:48 2017 -0500

    accelerators: add .gitignore

[33mcommit c50487d1adb807a783f62a1c005a853d66b359ba[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 13 17:29:30 2017 -0500

    tech: restructure folders

[33mcommit 382880d2e717fa24463788740cf237e99f798274[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 13 17:24:34 2017 -0500

    remove obsolete test file for memgen

[33mcommit a72d3b8d254fbe4311ddaa9960ae34ca7aeafd56[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 13 17:23:33 2017 -0500

    utils/memgen: integrate Stratus memgen flow

[33mcommit b1bcf92005cca9d54c6c4c53c66bc8c086e81712[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 13 17:22:06 2017 -0500

    accelerators/common: add stratus common project tcl file

[33mcommit 6d0776f2911a37de878f1eb259bf5ee999df46cb[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 13 17:21:42 2017 -0500

    accelerators/common: add .gitignore and common.mk

[33mcommit 1a5dfa341cb7529efa0f0a4552f123c75b9344f0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Feb 13 17:19:12 2017 -0500

    accelerators/common: update submodule syn-templates

[33mcommit f33bba75e8140714d1a9ec8d18d47e08c8b93e01[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 9 14:52:03 2017 -0500

    add submodule accelerators/common/syn-templates

[33mcommit 56fdc6f353147bb762dc512afe00ba159c0e8c86[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Feb 2 11:31:45 2017 -0500

    utils/memgen: member variables not shared across objects must be defined within __init__

[33mcommit 8bcc62ac5c869e177c7a0620e4f6445554947aa6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 1 19:03:51 2017 -0500

    rtl/include/techmap: removed dead code

[33mcommit a951170be795fc0441a3b61e9194866d7dbc62e7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 1 19:03:03 2017 -0500

    moving tech dependent files and memgen script

[33mcommit a4f212f649bd26685fc8846e46a31a2200a21de6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 1 18:51:21 2017 -0500

    .gitignore: ignore __pycache__

[33mcommit 0c56fa534a0eb44ddc6c38feabf94f519b1aeadc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 1 18:50:53 2017 -0500

    removed obsolete .gitignore

[33mcommit ecd00193f2b4c026915811eb8352fdb06120eae0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 1 18:45:26 2017 -0500

    memgen: WIP. Take tech and out path; print area.log

[33mcommit 68dbf3887d76a8a191915671f3cb045eef6fb542[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 1 18:20:30 2017 -0500

    memgen: WIP. Fix duplicated set selection

[33mcommit 4905ca0ad10bed29ac106d802f84fd3804327258[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 1 16:13:13 2017 -0500

    memgen: WIP. Removed constraint on first op being a write

[33mcommit 014c56a003feedb5cb65451e9ec8ad40ba429b0a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 1 15:47:20 2017 -0500

    memgen: WIP. Fix print of tb op list

[33mcommit 7cc0175845d636d599cbd7eaa49d1294b09a6c50[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 1 12:14:46 2017 -0500

    memgen: WIP. Fix duplication factor computation. WARNING: opens another bug

[33mcommit 19ae946156d8907f69c8588d972eadceab140edc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 1 12:01:07 2017 -0500

    memgen: WIP. change I/O naming convention: removed prefix

[33mcommit b119856498344e7edadc4973a30d0e37350d70ef[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Feb 1 11:29:55 2017 -0500

    memgen: WIP. Tetbench generation merges and handles all supported accesses

[33mcommit f6bf38c2486589e5768c648949e56d53a840dd0b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 31 19:06:09 2017 -0500

    memgen: WIP. Fix port assignment for 1 or 2 interfaces

[33mcommit 900f2e101ab1a9ebffe07d7a58068cae3610054f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 31 18:55:20 2017 -0500

    memgen: WIP. Centralize port selection for banks to fix output Q assignment

[33mcommit 9db835ed16417abbec0547bee7eb2f3af1782df4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 31 18:53:51 2017 -0500

    memgen: WIP. tb merges ops to handle non parallel r/w test cases

[33mcommit ba30496f2cdb78cf05ed578bf54767cebde533d4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 31 18:51:40 2017 -0500

    memgen: WIP. Fix input check: first op should include at least one write

[33mcommit b29a0d575a8f93f28db80e5277622214eb38cd41[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 31 16:46:06 2017 -0500

    memgen: WIP. Allow longer format for memory wrapper name

[33mcommit 944f0546b5a3a5eac8ff7a4ddf13890ac35db4a6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 31 16:43:07 2017 -0500

    memgen: WIP. Reset memory cells to zero between two op tests

[33mcommit f453c9c705d24fc5af653dec0f99897dae0261b0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 31 16:23:03 2017 -0500

    memgen: WIP. Add input check: first op should include at least one write

[33mcommit 2476d49ad1ecf3e076fe14baf2868c99e29aec73[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 31 15:42:00 2017 -0500

    memgen: WIP. add tb generation for parallel r/w with modulo access pattern

[33mcommit b0ca015c91515c4d76bf12828fbdfb8118c5c962[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 31 15:40:32 2017 -0500

    memgen: WIP. additional input check on number of ports larger than word count

[33mcommit 0be6e54fdf16d317aa15cbd8707951eb687a120d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 31 15:38:54 2017 -0500

    memgen: WIP. fix output Q assignment on non-power-of-2 bit-width

[33mcommit b1c8ff42d19a3ce2ba9a9882a98bf8e131774dcb[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 31 15:36:47 2017 -0500

    memgen: WIP. add timescale

[33mcommit 119bc8da836756475e6bc2808727803c9b776fa8[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 31 15:35:48 2017 -0500

    memgen: WIP. s/clash/conflict/g

[33mcommit 6bf652932c2c570d262ddf44c0e821d060008d9a[m
Author: Giuseppe Di Guglielmo <giuseppe.diguglielmo@columbia.edu>
Date:   Tue Jan 31 12:43:16 2017 -0500

    Fix compatibility python 3.4 vs 3.5 (inf)
    
    Signed-off-by: Giuseppe Di Guglielmo <giuseppe.diguglielmo@columbia.edu>

[33mcommit 2aaa1227a6c588aee210d992e9f736d5c252d820[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jan 30 10:22:30 2017 -0500

    memgen: WIP. Generate more readable access check usign task

[33mcommit 25c7286563a64309a5d2506b0ed306be5134a1b8[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jan 30 09:54:15 2017 -0500

    memgen: WIP. Enable assertions

[33mcommit 7eb7d6785eb98781df6478b34aec2d1e76edd5f7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Fri Jan 27 20:01:21 2017 -0500

    memgem: WIP. All parallel operations handled. Need testing

[33mcommit 3834a3ba4bc96fad4a56dd6f83a409f443dbd379[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Mon Jan 23 12:09:53 2017 -0500

    xilinx-vc707-xc7vx485t: update MIG and ref clock to run at ~80 MHz

[33mcommit 87d442ba678d01be33f1a14d2a0f9c5959ca00a3[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 19 17:49:13 2017 -0500

    Cleaning constraints and renaming top module ports

[33mcommit cc3de9d933a780b979c00fbb3e2d7bbe7931d952[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 19 17:43:57 2017 -0500

    utils/Makefile: do not compile sldcommon/monitor.vhd if not proFPGA board

[33mcommit 5081dfc005fdf5639cc20da98cb2c2056649967e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 19 17:43:13 2017 -0500

    socs/defconfig/esp_xilinx-vc707-xc7vx485t_defconfig: dvfs disabled by default

[33mcommit a7f371e6f7d6c3ae1459b5e674db7191eda278ad[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 19 15:07:06 2017 -0500

    utils/Makefile: fix check for proFPGA board

[33mcommit 1680eba873d899fe2243c2f414c220cd2db1972e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 19 13:16:55 2017 -0500

    socs/profpga-xc7v2000t: update mi64.cfg

[33mcommit a657d58d798daa4ef51838ee3d5a8ae491119009[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 19 13:15:36 2017 -0500

    rtl/src/sld/sldcommon/monitor: update MMI64 interface to release 2016B

[33mcommit a2b33951a049744073beec425b0420a551b1d630[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 19 13:15:06 2017 -0500

    utils/Makefile: compile proFPGA libraries from installation folder

[33mcommit dac4e7b2e1ec17ec228d2f070eb577ba5410b880[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 19 13:13:05 2017 -0500

    utils/design.mk: XIL_HW_SERVER_PORT can be changed from env

[33mcommit de6384df653d3d72868ffbdaf28f9ec14bde3df9[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 19 13:12:30 2017 -0500

    rtl: remove proFPGA imported library; it will be linked from proFPGA installation

[33mcommit 24ace188ac4cc4f27a043f76862fbee70765f051[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 19 13:10:04 2017 -0500

    socs/defconfig: remove config files for XC7VX690T

[33mcommit 4b46b5d130e18dc7e0b8f7f475a74e9fd9c20d62[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 19 11:46:43 2017 -0500

    Update profpga motherboard configuration and pin assignments

[33mcommit d95ff5ca970c56e4a7731f9fd70cc8cc2b34e352[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 18 17:11:50 2017 -0500

    utils/design.mk: MIG constraints must be read before MMI64

[33mcommit ac0cf28cdbd34d211c4f8603c326c1310c4a6280[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 18 17:10:11 2017 -0500

    socs/.gitignore: ignore bit files

[33mcommit c0b505d817aa8ee0759d6601c383b9f04ed49467[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Jan 18 17:07:52 2017 -0500

    constraints: remove profpga-xc7vx690t due to damaged FPGA module

[33mcommit 5397501572dbd0534aed705a90daf0a825a0772f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Jan 5 09:48:16 2017 -0500

    rtl: remove patched profpga; using $PROFPGA/hdl sources directly

[33mcommit ffd2c12b75d68c1c7a544fda774431729f4f9e7e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 3 05:46:19 2017 -0500

    constraints: add draft of constraints for profpga-xc7vx690t placed in MB1_TA3

[33mcommit d68a8561a9595212d43bbb4dbd07225664992ae0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 3 05:44:59 2017 -0500

    utils/socmap/soc.py: fix .esp_config flag has_dvfs

[33mcommit 1fd81c1f05fa2f86f6bc69ba244e069fb011611c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 3 05:44:09 2017 -0500

    utilis/design.mk: makefile checks for profpga version

[33mcommit b48cbf1eb87a5264bef341e25fe4195ddb741c36[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 3 05:43:44 2017 -0500

    socs/defconfig: update profpga defconfig

[33mcommit 0e1f0d195db25f4c0539fb85d1294a0fded05ebb[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 3 05:43:02 2017 -0500

    socs/common/tile_cpu: fix number of slaves for ahb proxy

[33mcommit 925382931f192959617e8396a8c4277d03bf6b4b[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Jan 3 05:42:26 2017 -0500

    socs/.gitignore: ignore vivado

[33mcommit 39a0ca57671f046936650f6c449527b908015d79[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Dec 22 10:46:57 2016 -0500

    utils/Makefile: hide shell command to link bitstream

[33mcommit 873accb62b15df9e2dc891e439177ecba0be3549[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Dec 22 06:53:34 2016 -0500

    utils/design.mk: include .esp_config

[33mcommit 3a66f5a7dab1450c5628bc0363503c1871930abc[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Dec 22 06:53:06 2016 -0500

    socs/xilinx-vc707-xc7vx485t: commeng disas flag for simulation

[33mcommit b5fe32846bc506d2d42b38a00bed9ef558c2d41c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Dec 22 06:52:46 2016 -0500

    socs/.gitignore: ignore exe and srec files

[33mcommit 1b713a7a75de4e1ee092a32a405fef3f63702447[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Dec 22 06:38:00 2016 -0500

    utils/socmap: .esp_config can be included in Makefile

[33mcommit 66704ddd7873c5d2b667b53546ef5f14461d5da7[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 2 17:29:25 2016 -0400

    utils/socmap: drop bus support

[33mcommit 655f84b37e48a307547a3e3df0817cb8bb4399ec[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 2 17:28:58 2016 -0400

    utils/Makefile: esp-config depends on grlib_config

[33mcommit eb5786657009c5ab8e67b5d0324653f50150a3f2[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 2 16:47:09 2016 -0400

    utils: add main Makefile

[33mcommit 76fb63843dae6b03d22eaf452eca10f21955b872[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 2 16:46:46 2016 -0400

    add xilinx-vc707-xc7vx485t design stub

[33mcommit e59b415eb54a03adfe1c86ffdb4b39ce5a594106[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 2 16:46:11 2016 -0400

    add profpga-xc7v2000t design stub

[33mcommit cb6b498cb249d7e31e046dfd519848e1efa48197[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 2 16:45:51 2016 -0400

    socs: add .gitignore

[33mcommit dcc03cc686fbd9b80277cd51093484ca6408d22a[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 2 16:37:52 2016 -0400

    socs/defconfig: add default configuration files

[33mcommit cec5a742a2caa898db0cfffd218926326d409a4d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 2 16:34:24 2016 -0400

    socs/common: add common RTL files for SoC integration

[33mcommit 38100ee4c569767b3903c6431eae7e773fc5a5f6[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 2 16:33:28 2016 -0400

    utils/socmap: add python-based socmap generator

[33mcommit c9369129e15ff2107f5533333b93af9a304a7da5[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 2 16:31:55 2016 -0400

    utils/grlib: add Leon3 software utilities from grlib

[33mcommit 87c8b6797cde1d344ca4b9483810d3bf3e6b1ea4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 2 16:29:44 2016 -0400

    ../../utils/grlib/netlists: add GRFPU netlist for virtex7

[33mcommit 4a4ed7a454f1a55454d9e7ba0e8ac75bd3545a78[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 2 16:29:02 2016 -0400

    rtl/src/grlib/amba/patient_apbctrl: add LI version of APB bus

[33mcommit 537f5f2afe77c34c7389c5b03beb55a70eff7c6c[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 2 16:28:39 2016 -0400

    rtl/src/gaisler/ddr/ahb2mig_7series_profpga: add support for multiple MIG

[33mcommit ecead01e92638aef875d40551a900023a704f534[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 2 16:27:59 2016 -0400

    Add initial constraints. May be improved

[33mcommit bf6721b9a9c95c8c6acb22c35486c6b664117d99[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 2 16:27:23 2016 -0400

    rtl/src/techmap/unisim/clkgen_unisim: add Virtex7 PLL support

[33mcommit 695149fc4f8141db1d0d1b459dbcb305ec299994[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Wed Nov 2 16:26:58 2016 -0400

    rtl/src/gaisler/ddr/ahb2mig_7series: remove unused apb interface

[33mcommit 101a1499e9e7c2d3340a4da646d0958497c1dd8e[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Nov 1 10:46:30 2016 -0400

    rtl/src/techmap/unisim/memory_unisim: support up to 20 address bits

[33mcommit 34910d6b0a9e557bf6cd5f94086fd3713aa9e3d0[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Oct 13 14:18:42 2016 -0400

    utils/grlib/tkconfig/in/uart1: add configuration for UART interrupt line

[33mcommit d4ef6b059bd6cc95b2cfe1e9e3d9a40e19402917[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Oct 13 14:18:12 2016 -0400

    utils/grlib/tkconfig/in/ps2vga: add configuration for hardware frame buffer

[33mcommit c0695392451213b80f39e437a15fe35cbacb1c4d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Oct 13 14:17:25 2016 -0400

    utils/grlib/tkconfig/config.vhd: GRLIB configuration package name changed to grlib_config

[33mcommit ccd4607b1146b53d536d0a5195c2d730f6e8a02d[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Thu Oct 13 14:16:49 2016 -0400

    rtl/include/grlib/stdlib/stdlib.vhd: add function to_std_logic

[33mcommit 678b019756282001d6c2844371d9acc0bfa1651f[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Oct 11 18:42:07 2016 -0400

    rtl/sim: remove some unused source files from GRLIB

[33mcommit 6ed3317749d9755358b3d57dae758c9a6d8bcbb4[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Oct 11 16:38:39 2016 -0400

    utils/grlib: add tkconfig for configuration of GRLIB

[33mcommit fa0a8a3c2a5cade1970c2aef91a73dbf0ef94e15[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Oct 11 16:34:49 2016 -0400

    rtl: fix naming clash for clkgen across grlib and profpga

[33mcommit a7485034d9ebbb668e4cf81077becfcfea01c8f1[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Oct 4 15:52:38 2016 -0400

    Add initial set of synthesis and simulation RTL source files

[33mcommit 60bdf5e2b1f2c18a907b1059aa5ab9ecddebc463[m
Author: Paolo Mantovani <paolo@cs.columbia.edu>
Date:   Tue Sep 20 12:08:04 2016 -0400

    Initial commit: create .gitignore
