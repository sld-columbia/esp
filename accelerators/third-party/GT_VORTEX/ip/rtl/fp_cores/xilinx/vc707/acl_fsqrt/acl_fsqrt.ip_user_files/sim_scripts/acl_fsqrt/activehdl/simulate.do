onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+acl_fsqrt -L xbip_utils_v3_0_10 -L axi_utils_v2_0_6 -L xbip_pipe_v3_0_6 -L xbip_dsp48_wrapper_v3_0_4 -L xbip_dsp48_addsub_v3_0_6 -L xbip_dsp48_multadd_v3_0_6 -L xbip_bram18k_v3_0_6 -L mult_gen_v12_0_16 -L floating_point_v7_1_9 -L xil_defaultlib -L secureip -O5 xil_defaultlib.acl_fsqrt

do {wave.do}

view wave
view structure

do {acl_fsqrt.udo}

run -all

endsim

quit -force
