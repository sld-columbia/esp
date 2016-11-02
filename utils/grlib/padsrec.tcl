#! /usr/bin/tclsh
#
# Utility to pad SREC to multiple of 16 bytes
# Copyright 2010, Aeroflex Gaisler AB.
#
# Usage: tclsh padsrec.tcl <in.srec >out.srec
#
# Limitations:
# - Each line except the last of the SREC must contain a multiple of 8 bytes of data
# - Records other than S1-3 are passed on unchanged
# - SREC checksums are not correct
#
# Revision history:
#   2011-08-12, MH, First version (based on ftddrcb.tcl)
#



# -------------------------------------------------------------
# SREC processing

set valtable {  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F }
for { set i 0 } { $i < 16 } { incr i } {
    set symval([lindex $valtable $i]) $i
}

proc hex2int { h } {
    global symval
    set l [string length $h]
    set r 0
    for {set i 0} {$i < $l} {incr i} {
	set r [expr {($r << 4) + $symval([string index $h $i])}]
    }
    return $r;
}

proc int2hex { i l } {
    global valtable
    set r ""
    set ol 0
    while { $i > 0 || $ol < $l || $ol < 1 } { 
	set r [ format "%s%s" [lindex $valtable [ expr { $i & 15 } ] ] $r ]
	set i [ expr { $i >> 4 } ]
	incr ol
    }
    return $r
}

set lineno 0
while { ! [eof stdin] } {
    set l [gets stdin]
    incr lineno
    set llen [string length $l]
    if { $llen == 0 } then continue
    set rt [string index $l 1 ]
    if { $rt > 0 && $rt < 4 } then {
	# Byte count and data position
	set bc [expr { [hex2int [string range $l 2 3]] - 2 - $rt } ]
	set dp [expr {6 + $rt*2}]

	if { [expr {$bc & 7}] != 0 } then {
	    # puts stderr "Warning: Padding line $lineno to even multiple of 8 bytes"
	    while { [expr {$bc & 7}] != 0 } {
		set l0 [ string range $l 4 [expr {$llen-3}] ]
		set l1 [ string range $l [expr {$llen-2}] $llen ]
		incr bc
		set l [format "S%s%s%s%s%s" $rt [int2hex [expr {$bc+2+$rt}] 2] $l0 "00" $l1]
		incr llen
		incr llen
	    }
	    # puts stderr "Became: $l"
	}
    }
    puts $l
}


