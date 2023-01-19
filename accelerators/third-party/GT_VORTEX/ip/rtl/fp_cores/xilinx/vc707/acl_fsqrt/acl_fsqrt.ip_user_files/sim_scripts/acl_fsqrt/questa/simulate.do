onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib acl_fsqrt_opt

do {wave.do}

view wave
view structure
view signals

do {acl_fsqrt.udo}

run -all

quit -force
