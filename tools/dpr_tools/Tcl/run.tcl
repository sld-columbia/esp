###############################################################
###   Main flow - Do Not Edit
###############################################################
#TODO: For now define the script version here... find a better home like the README or design.tcl?
set scriptVer "2019.2"
set vivado [exec which vivado]
if {[llength $vivado]} {
   set vivadoVer [version -short]
   puts "INFO: Found Vivado version $vivadoVer"
   #Bypass version check if script version is not specified
   if {[info exists scriptVer]} {
      if {![string match ${scriptVer}* $vivadoVer]} {
#         set errMsg "ERROR: Specified script version $scriptVer does not match Vivado version $vivadoVer.\n"
         set errMsg "Critical Warning: Specified script version $scriptVer does not match Vivado version $vivadoVer.\n"
         append errMsg "Either change the version of scripts being used or run with the correct version of Vivado."
#         error $errMsg
         puts "$errMsg"
      }
   }
} else {
   errMsg "Error: No version of Vivado found"
   error $errMsg
}

list_runs

#### Run Synthesis on any modules requiring synthesis
foreach module [get_modules] {
   if {[get_attribute module $module synth]} {
    synthesize $module
   }
}

#### Run Top-Down implementation before OOC
foreach impl [get_implementations td.impl] {
   if {[get_attribute impl $impl impl] && [get_attribute impl $impl td.impl]} {
      #Override directives if directive file is specified
      if {[info exists useDirectives]} {
         puts "#HD: Overriding directives for implementation $impl"
         set_directives impl $impl
      }
      implement $impl
   }
}

#### Run OOC Implementations
if {[llength $ooc_implementations] > 0} {
   foreach ooc_impl $ooc_implementations {
      if {[get_attribute ooc $ooc_impl impl]} {
         #Override directives if directive file is specified
         if {[info exists useDirectives]} {
            puts "#HD: Overriding directives for implementation $ooc_impl"
            set_directives ooc $ooc_impl
         }
         ooc_impl $ooc_impl
      }
   }
}

#### Run PR configurations
set configurations [sort_configurations [get_configurations]]
foreach config $configurations {
   if {[get_attribute impl $config impl]} {
      #Override directives if directive file is specified
      if {[info exists useDirectives]} {
         puts "#HD: Overriding directives for configuration $config"
         set_directives config $config
      }
      implement $config
   }
}

#### Run Assembly and Flat implementations
foreach impl [get_implementations "!td.impl !pr.impl"]  {
   if {[get_attribute impl $impl impl] && ![get_attribute impl $impl td.impl]} {
      #Override directives if directive file is specified
      if {[info exists useDirectives]} {
         puts "#HD: Overriding directives for implementation $impl"
         set_directives impl $impl
      }
      implement $impl
   }
}

#### Run PR verify 
if {[llength $configurations] > 1} {
   verify_configs $configurations
}

#### Genearte PR bitstreams 
if {[llength $configurations] > 0} {
   #generate_pr_bitstreams $configurations
   #generate_pr_binfiles $configurations 
}

close $RFH
close $CFH
close $WFH
