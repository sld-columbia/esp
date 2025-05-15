
# Report power for clock periods
proc do_report_power { name clk_periods } {

  #open_checkpoint ${checkpoint}

  set clk_port [get_port clk]

  foreach period $clk_periods {
    # get numerical period
    set period [format "%.3f" $period]
    set pos [string first "." "$period"]
    set period_str [string replace "$period" $pos $pos "_"]

    # create (overwrite) clock object
    set clk [create_clock -name clk -period $period -waveform [list 0 [expr $period / 2]] $clk_port]

    # ensure proper timing
    report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -routable_nets -name timing-${name}-${period_str} -warn_on_violation > ./Reports/timing-${name}-${period_str}.txt

    # report power
    report_power -file "./Reports/power-${name}-${period_str}.txt" -rpx "./Reports/power-${name}-${period_str}.rpx" -name "power-${name}-${period_str}"
  }

  #close_design

}
