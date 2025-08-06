
# Check timing for one clock
proc check_timing { report_name clk cells } {
  report_timing -from $clk -delay_type min_max -max_paths 10 -sort_by group -input_pins -routable_nets -cells $cells -name timing_2 -warn_on_violation > ./Reports/${report_name}.txt

  # parse timing report
  set viable 1
  set fh_in [open ./Reports/${report_name}.txt]
  while {true} {
      set l [gets $fh_in]
      if {[string match {CRITICAL WARNING: \[Timing 38-282\]*} "$l"]} {
          set viable 0
          puts "Failed timing for clock $clk"
          break
      }
      if {"$l" == ""} { break }
  }
  close $fh_in
  return $viable
}

# Loop through clocks from an object
proc do_report_viability_clocks { name clk_obj filters cells } {
  file mkdir "./Reports/dfs_viability"
  set fh [open "./Reports/dfs_viability/${name}" "w"]

  # loop through clocks in the list
  set clk_idx 0
  foreach filter $filters {
    set clk [get_clocks -of_objects $clk_obj -filter "$filter"]

    set viable [check_timing "timing-${name}-${clk_idx}" $clk $cells]
    puts $fh "$viable"
    set clk_idx [expr $clk_idx+1]
  }

  close $fh
}

# Report whether the accelerator can run at various clock periods
proc do_report_viability_periods { name clk_periods clk_obj cells } {
  set fh [open "./Reports/dfs_viability/${name}" "w"]

  # loop through clock periods
  foreach period $clk_periods {
    # get numerical period
    set period [format "%.3f" $period]
    set pos [string first "." "$period"]
    set period_str [string replace "$period" $pos $pos "_"]

    # create (overwrite) clock object
    set clk [create_clock -name clk -period $period -waveform [list 0 [expr $period / 2]] $clk_obj]

    set viable [check_timing "timing-${name}-${period_str}" $clk $cells]
    puts $fh "$viable"
  }

  close $fh
}

# Report power for clock periods
proc do_report_power { name clk_periods clk_obj } {

  foreach period $clk_periods {
    # get numerical period
    set period [format "%.3f" $period]
    set pos [string first "." "$period"]
    set period_str [string replace "$period" $pos $pos "_"]

    # create (overwrite) clock object
    set clk [create_clock -name clk -period $period -waveform [list 0 [expr $period / 2]] $clk_obj]

    # report power
    report_power -file "./Reports/power-${name}-${period_str}.txt" -rpx "./Reports/power-${name}-${period_str}.rpx" -name "power-${name}-${period_str}"
  }

}
