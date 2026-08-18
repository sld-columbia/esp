# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

# Regenerate grlib_config.h without starting Tk.  main.tk contains both the
# generated configuration model and GUI procedures; the latter are harmless
# as long as their two top-level entry points are replaced with no-ops.

if {$argc != 1} {
	puts stderr "usage: tclsh regen_config.tcl main.tk"
	exit 1
}

set grlib_tkconfig_headless 1
set tkconfig_dir [file dirname [file normalize [info script]]]
source [file join $tkconfig_dir header.tk]

proc mainmenu_name {text} {}
proc menu_option {w menu_num text} {}

source [lindex $argv 0]

# read_config calls this after loading the selected values.  Updating GUI
# widgets is neither necessary nor possible in a headless interpreter.
proc update_mainmenu {} {}

if {![file readable .grlib_config]} {
	puts stderr "error: .grlib_config is not readable"
	exit 1
}

read_config .grlib_config
catch {file copy -force .grlib_config .grlib_config.old}
writeconfig .grlib_config grlib_config.h
exit 2
