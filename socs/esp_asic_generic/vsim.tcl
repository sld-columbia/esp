set dco_model $::env(DCO_SIM_MODEL_RESOLVED)
set dco_sdf $::env(DCO_SDF)
set VSIMOPT $::env(VSIMOPT)
set sdf ""

puts "DCO simulation model: ${dco_model}"

if {$dco_model eq "structural"} {
   if {![file readable $dco_sdf]} {
      error "Structural DCO SDF is not readable: ${dco_sdf}"
   }

   set dco_instances [find instances -nodu -bydu DCO_ASIC]
   if {[llength $dco_instances] == 0} {
      error "Structural DCO simulation found no DCO_ASIC instances to annotate"
   }

   puts "Annotating [llength $dco_instances] DCO_ASIC instances with ${dco_sdf}"
   foreach inst $dco_instances {
      append sdf "-sdfmax "
      append sdf [string map {( [} [string map {) ]} $inst]]
      append sdf "=${dco_sdf} "
   }
   append sdf "-suppress 3438"
} elseif {$dco_model eq "behavioral"} {
   puts "SDF annotation disabled for the functional behavioral DCO"
} else {
   puts "ASIC DCO model selection bypassed by the FPGA technology override"
}

eval vsim $sdf $VSIMOPT
