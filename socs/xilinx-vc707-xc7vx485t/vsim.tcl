# Bounded baremetal validation; UART verdict is captured in the transcript.
onerror {quit -code 1 -f}
onbreak {quit -f}
run 100 ms
quit -f
