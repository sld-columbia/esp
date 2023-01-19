onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib acl_fmadd_opt

do {wave.do}

view wave
view structure
view signals

do {acl_fmadd.udo}

run -all

quit -force
