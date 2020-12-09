set modules             [list ]
set ooc_implementations [list ]
set implementations     [list ]

set opt_directives   [list Explore                \
                           ExploreArea            \
                           AddRemap               \
                           ExploreSequentialArea  \
                           RuntimeOptimized       \
                     ]
set place_directives [list Explore                \
                           WLDrivenBlockPlacement \
                           LateBlockPlacement     \
                           ExtraNetDelay_high     \
                           ExtraNetDelay_medium   \
                           ExtraNetDelay_low      \
                           SpreadLogic_high       \
                           SpreadLogic_medium     \
                           SpreadLogic_low        \
                           ExtraPostPlacementOpt  \
                           SSI_ExtraTimingOpt     \
                           SSI_SpreadSLLs         \
                           SSI_BalanceSLLs        \
                           SSI_BalanceSLRs        \
                           SSI_HighSLRs           \
                           RuntimeOptimized       \
                           Quick                  \
                           Default                \
                     ]
set phys_directives  [list Explore                \
                           ExploreWithHoldFix     \
                           AggressiveExplore      \
                           AlternateReplication   \
                           AggressiveFanoutOpt    \
                           AlternateDelayModeling \
                           AddRetime              \
                           Default                \
                     ]
set route_directives [list Explore                \
                           NoTimingRelaxation     \
                           MoreGlobalIterations   \
                           HigherDelayCost        \
                           AdvancedSkewModeling   \
                           RuntimeOptimized       \
                           Quick                  \
                           Default                \
                      ]


array set module_attributes [list "moduleName"           [list string   null]  \
                                  "top_level"            [list boolean {0 1}]  \
                                  "prj"                  [list string   null]  \
                                  "includes"             [list string   null]  \
                                  "generics"             [list string   null]  \
                                  "vlog_headers"         [list string   null]  \
                                  "vlog_defines"         [list string   null]  \
                                  "sysvlog"              [list string   null]  \
                                  "vlog"                 [list string   null]  \
                                  "vhdl"                 [list string   null]  \
                                  "ip"                   [list string   null]  \
                                  "ipRepo"               [list string   null]  \
                                  "bd"                   [list string   null]  \
                                  "cores"                [list string   null]  \
                                  "xdc"                  [list string   null]  \
                                  "synthXDC"             [list string   null]  \
                                  "implXDC"              [list string   null]  \
                                  "synth"                [list boolean {0 1}]  \
                                  "synth_options"        [list string   null]  \
                                  "synthCheckpoint"      [list string   null]  \
                            ]

array set impl_attributes   [list "top"                  [list string   null]  \
                                  "implXDC"              [list string   null]  \
                                  "linkXDC"              [list string   null]  \
                                  "cores"                [list string   null]  \
                                  "ip"                   [list string   null]  \
                                  "ipRepo"               [list string   null]  \
                                  "impl"                 [list boolean {0 1}]  \
                                  "hd.impl"              [list boolean {0 1}]  \
                                  "td.impl"              [list boolean {0 1}]  \
                                  "pr.impl"              [list boolean {0 1}]  \
                                  "ic.impl"              [list boolean {0 1}]  \
                                  "partitions"           [list string  null  \
                                                               string  null  \
                                                               enum   {implement import greybox}  \
                                                               enum   {logical placement routing} \
                                                               string  null  \
                                                         ] \
                                  "link"                 [list boolean {0 1}]  \
                                  "opt"                  [list boolean {0 1}]  \
                                  "opt.pre"              [list string   null]  \
                                  "opt_options"          [list string   null]  \
                                  "opt_directive"        [list enum     $opt_directives]   \
                                  "place"                [list boolean {0 1}]  \
                                  "place.pre"            [list string   null]  \
                                  "place_options"        [list string   null]  \
                                  "place_directive"      [list enum     $place_directives] \
                                  "phys"                 [list boolean {0 1}]  \
                                  "phys.pre"             [list string   null]  \
                                  "phys_options"         [list string   null]  \
                                  "phys_directive"       [list enum     $phys_directives]  \
                                  "route"                [list boolean {0 1}]  \
                                  "route.pre"            [list string   null]  \
                                  "route_options"        [list string   null]  \
                                  "route_directive"      [list enum     $route_directives] \
                                  "verify"               [list boolean {0 1}]  \
                                  "bitstream"            [list boolean {0 1}]  \
                                  "bitstream.pre"        [list string   null]  \
                                  "bitstream_options"    [list string   null]  \
                                  "bitstream_settings"   [list string   null]  \
                                  "cfgmem.icap"          [list boolean {0 1}]  \
                                  "cfgmem.pcap"          [list boolean {0 1}]  \
                                  "cfgmem.offset"        [list string   null]  \
                                  "cfgmem.size"          [list enum    {1 2 4 8 16 32 64 128 256 512}] \
                                  "cfgmem.interface"     [list enum    {SMAPx8 SMAPx16 SMAPx32}] \
                                  "drc.quiet"            [list boolean {0 1}]  \
                            ]

array set ooc_attributes    [list "module"               [list string   null]  \
                                  "inst"                 [list string   null]  \
                                  "hierInst"             [list string   null]  \
                                  "implXDC"              [list string   null]  \
                                  "cores"                [list string   null]  \
                                  "impl"                 [list boolean {0 1}]  \
                                  "hd.isolated"          [list boolean {0 1}]  \
                                  "budget.create"        [list boolean {0 1}]  \
                                  "budget.percent"       [list integer  null]  \
                                  "link"                 [list boolean {0 1}]  \
                                  "opt"                  [list boolean {0 1}]  \
                                  "opt.pre"              [list string   null]  \
                                  "opt_options"          [list string   null]  \
                                  "opt_directive"        [list enum     $opt_directives]   \
                                  "place"                [list boolean {0 1}]  \
                                  "place.pre"            [list string   null]  \
                                  "place_options"        [list string   null]  \
                                  "place_directive"      [list enum     $place_directives] \
                                  "phys"                 [list boolean {0 1}]  \
                                  "phys.pre"             [list string   null]  \
                                  "phys_options"         [list string   null]  \
                                  "phys_directive"       [list enum     $phys_directives]  \
                                  "route"                [list boolean {0 1}]  \
                                  "route.pre"            [list string   null]  \
                                  "route_options"        [list string   null]  \
                                  "route_directive"      [list enum     $route_directives] \
                                  "bitstream"            [list boolean {0 1}]  \
                                  "bitstream.pre"        [list string   null]  \
                                  "bitstream_options"    [list string   null]  \
                                  "bitstream_settings"   [list string   null]  \
                                  "implCheckpoint"       [list string   null]  \
                                  "preservation"         [list enum    {logical placement routing}] \
                                  "drc.quiet"            [list boolean {0 1}]  \
                             ]
   

###############################################################
### Define a top-level implementation
###############################################################
proc add_implementation { name } {
   global implementations
   set procname [lindex [info level 0] 0]
   
   if {[lsearch -exact $implementations $name] >= 0} {
      set errMsg "\nERROR: Implementation $name is already defined"
      error $errMsg
   }

   lappend implementations $name
   set_attribute impl $name "top"                 ""
   set_attribute impl $name "implXDC"             "" 
   set_attribute impl $name "linkXDC"             "" 
   set_attribute impl $name "cores"               ""
   set_attribute impl $name "ip"                  ""
   set_attribute impl $name "ipRepo"              ""
   set_attribute impl $name "impl"                0
   set_attribute impl $name "hd.impl"             0
   set_attribute impl $name "td.impl"             0
   set_attribute impl $name "pr.impl"             0
   set_attribute impl $name "ic.impl"             0
   set_attribute impl $name "partitions"          [list ]
   set_attribute impl $name "link"                1
   set_attribute impl $name "opt"                 1
   set_attribute impl $name "opt.pre"             ""
   set_attribute impl $name "opt_options"         ""
   set_attribute impl $name "opt_directive"       ""
   set_attribute impl $name "place"               1
   set_attribute impl $name "place.pre"           ""
   set_attribute impl $name "place_options"       ""
   set_attribute impl $name "place_directive"     ""
   set_attribute impl $name "phys"                1
   set_attribute impl $name "phys.pre"            ""
   set_attribute impl $name "phys_options"        ""
   set_attribute impl $name "phys_directive"      ""
   set_attribute impl $name "route"               1
   set_attribute impl $name "route.pre"           ""
   set_attribute impl $name "route_options"       ""
   set_attribute impl $name "route_directive"     ""
   set_attribute impl $name "verify"              0
   set_attribute impl $name "bitstream"           0
   set_attribute impl $name "bitstream.pre"       ""
   set_attribute impl $name "bitstream_options"   ""
   set_attribute impl $name "bitstream_settings"  ""
   set_attribute impl $name "cfgmem.icap"         0
   set_attribute impl $name "cfgmem.pcap"         0
   set_attribute impl $name "cfgmem.offset"       "up 0x0"
   set_attribute impl $name "cfgmem.size"         "1"
   set_attribute impl $name "cfgmem.interface"    "SMAPx32"
   set_attribute impl $name "drc.quiet"           0
}

###############################################################
### Define an OOC implementation
###############################################################
proc add_ooc_implementation { name } {
   global ooc_implementations
   global dcpDir

   set procname [lindex [info level 0] 0]
   
   if {[lsearch -exact $ooc_implementations $name] >= 0} {
      set errMsg "\nERROR: OOC implementation $name is already defined"
      error $errMsg
   }

   lappend ooc_implementations $name
   set_attribute ooc $name "module"              ""
   set_attribute ooc $name "inst"                "$name"
   set_attribute ooc $name "hierInst"            ""
   set_attribute ooc $name "implXDC"             "" 
   set_attribute ooc $name "cores"               ""
   set_attribute ooc $name "impl"                0
   set_attribute ooc $name "hd.isolated"         0
   set_attribute ooc $name "budget.create"       0
   set_attribute ooc $name "budget.percent"      50
   set_attribute ooc $name "link"                1
   set_attribute ooc $name "opt"                 1
   set_attribute ooc $name "opt.pre"             ""
   set_attribute ooc $name "opt_options"         ""
   set_attribute ooc $name "opt_directive"       ""
   set_attribute ooc $name "place"               1
   set_attribute ooc $name "place.pre"           ""
   set_attribute ooc $name "place_options"       ""
   set_attribute ooc $name "place_directive"     ""
   set_attribute ooc $name "phys"                1
   set_attribute ooc $name "phys.pre"            ""
   set_attribute ooc $name "phys_options"        ""
   set_attribute ooc $name "phys_directive"      ""
   set_attribute ooc $name "route"               1
   set_attribute ooc $name "route.pre"           ""
   set_attribute ooc $name "route_options"       ""
   set_attribute ooc $name "route_directive"     ""
   set_attribute ooc $name "bitstream"           0
   set_attribute ooc $name "bitstream.pre"       ""
   set_attribute ooc $name "bitstream_options"   ""
   set_attribute ooc $name "bitstream_settings"  ""
   set_attribute ooc $name "implCheckpoint"      "$dcpDir/${name}_route_design.dcp"
   set_attribute ooc $name "preservation"        "routing"
   set_attribute ooc $name "drc.quiet"           0
}
   
###############################################################
### Add a module
###############################################################
proc add_module { name } {
   global modules synthDir

   if {[lsearch -exact $modules $name] >= 0} {
      set errMsg "\nERROR: Module $name is already defined"
      error $errMsg
   }

   lappend modules $name
   set_attribute module $name "moduleName"       $name
   set_attribute module $name "top_level"        0
   set_attribute module $name "prj"              ""
   set_attribute module $name "includes"         ""
   set_attribute module $name "generics"         ""
   set_attribute module $name "vlog_headers"     [list ]
   set_attribute module $name "vlog_defines"     ""
   set_attribute module $name "sysvlog"          [list ]
   set_attribute module $name "vlog"             [list ]
   set_attribute module $name "vhdl"             [list ]
   set_attribute module $name "ip"               [list ]
   set_attribute module $name "ipRepo"           [list ]
   set_attribute module $name "bd"               [list ]
   set_attribute module $name "cores"            [list ]
   set_attribute module $name "xdc"              [list ]
   set_attribute module $name "synthXDC"         [list ]
   set_attribute module $name "implXDC"          [list ]
   set_attribute module $name "synth"            0 
   set_attribute module $name "synth_options"    "-flatten_hierarchy rebuilt" 
   set_attribute module $name "synthCheckpoint"  ""
}

###############################################################
### Set an attribute
##############################################################
proc set_attribute { type name attribute {values null} } {
   global ${type}Attribute
   set procname [lindex [info level 0] 0]

   switch -exact -- $type {
      module  {set list_type "modules"}
      ooc     {set list_type "ooc_implementations"}
      impl    {set list_type "implementations"}
      default {error "\nERROR: Invalid type \'$type\' specified"}
   }

   check_list $list_type $name $procname
   check_attribute $type $attribute $procname
   if {![string match $values "null"]} {
      foreach value $values {
         check_attribute_value $type $attribute $value
      }
      set ${type}Attribute(${name}.$attribute) $values
   } else {
      puts "Critical Warning: Attribute $attribute for $type $name is set to $values. The value will not be modified."
   }
   return $values
}

###############################################################
### Get an attribute
###############################################################
proc get_attribute { type name attribute } {
   global ${type}Attribute
   set procname [lindex [info level 0] 0]

   switch -exact -- $type {
      module  {set list_type "modules"}
      ooc     {set list_type "ooc_implementations"}
      impl    {set list_type "implementations"}
      default {error "\nERROR: Invalid type \'$type\' specified"}
   }

   check_list $list_type $name $procname
   check_attribute $type $attribute $procname
   return [subst -nobackslash \$${type}Attribute(${name}.$attribute)]
}

###############################################################
### Check if attribute exists
###############################################################
proc check_attribute { type attribute procname } {
   global ${type}_attributes
   set attributes [array names ${type}_attributes]
   if {[lsearch -exact $attributes $attribute] < 0} {
      set errMsg "\nERROR: Invalid $type attribute \'$attribute\' specified in $procname"
      error $errMsg
   }
}


###############################################################
### Check if attribute value matches type
###############################################################
proc check_attribute_value { type attribute values } {
   global ${type}_attributes 
   if {[info exists ${type}_attributes($attribute)]} {
      set attribute_checks [subst -nobackslashes \$${type}_attributes($attribute)]
      set index 0
      foreach {attr_type attr_values} $attribute_checks {
         set value [lindex $values $index]
         if {![string match $attr_values "null"] && [llength $value]} {
            set pass 0
            foreach attr_value $attr_values {
               if {$attr_value==$value} {
                  set pass 1
               }
            }
            if {$pass==0} {
               set errMsg "\nERROR: Value \'$value\' of $type attribute $attribute of type $attr_type is not valid.\n"
               append errMsg "Supported values are: $attr_values"
               error $errMsg
            }
         }
         incr index
      }
   } else {
      set errMsg "\nERROR: Could not find attribute $attribute in array ${type}_attributes."
      error $errMsg
   }
}

###############################################################
### Check if object exists
###############################################################
proc check_list { list_type name procname } {
   global [subst $list_type]
   if {[lsearch -exact [subst -nobackslash \$$list_type] $name] < 0} {
      set errMsg "\nERROR: Invalid $list_type \'$name\' specified in $procname"
      error $errMsg 
   }
}

###############################################################
### Override directives with global values
###############################################################
proc set_directives {$type $name} {
   global Directives
     
   set_attribute $type $name opt_directive   $Directives(opt)
   set_attribute $type $name place_directive $Directives(place)
   set_attribute $type $name phys_directive  $Directives(phys)
   set_attribute $type $name route_directive $Directives(route)
}

proc list_runs { } {
   #### Print list of Modules
   if {[llength [get_modules synth]]} {
      set table "-title {#HD: List of modules to be synthesized}"
      append table " -row {Module \"Module Name\" \"Top Level\" Options}"
      foreach module [get_modules synth] {
         set moduleName [get_attribute module $module moduleName] 
         set top [get_attribute module $module top_level]
         set synth_options [get_attribute module $module synth_options]
         append table " -row {$module $moduleName $top \"$synth_options\"}"
      }
      print_table $table 
   } else {
      puts "#HD: No modules set to be synthesized"
   }
   if {[llength [get_modules !synth]]} {
      puts "#HD: Defined modules not being synthesized:"
      set count 1
      foreach module [get_modules !synth] {
         puts "\t$count. $module ([get_attribute module $module moduleName])"
         incr count
      }
   }

   #### Print list of Configurations
   if {[llength [get_implementations "pr.impl impl" &&]]} {
      set configs [sort_configurations [get_implementations "pr.impl impl" &&]]
      set table "-title {#HD: List of Configurations to be implemented}"
      append table " -row {Configuration \"Reconfig Modules\" \"Static State\" pr_verify write_bistream}"
      #Sort list of configurations. Insert "initial" config at beginning of list.
      foreach configuration $configs { 
         set partitions [get_attribute impl $configuration partitions]
         set top        [get_attribute impl $configuration top]
         set verify     [get_attribute impl $configuration verify]
         set bitstream  [get_attribute impl $configuration bitstream]
         set RMs ""
         set staticState ""
         foreach partition $partitions {
            lassign $partition name cell state level dcp
            if {![string match $cell $top]} {
               lappend RMs "$name\($state\) "
            } else {
               set staticState $state
            }
         }
         set rmCount [llength $RMs]
         for {set i 0} {$i < $rmCount} {incr i} {
            if {$i==0} {
               append table " -row {$configuration [lindex $RMs $i] $staticState $verify $bitstream}"
            } else {
               append table " -row {\"\" [lindex $RMs $i] \"\" \"\" \"\"}"
            } 
         }
      }
      print_table $table 
   } else {
      puts "#HD: No Configurations set to be implemented"
   }
   if {[llength [get_implementations "pr.impl !impl" &&]]} {
      puts "#HD: Defined Configurations not being implemented:"
      set count 1
      foreach config [get_implementations "pr.impl !impl" &&] {
         puts "\t$count. $config"
         incr count
      }
   }

   #### Print list of Implementations
   if {[llength [get_implementations "!pr.impl impl" &&]]} {
      set table "-title {#HD: List of Implementations to be implemented}"
      append table " -row {Implementation Top Partitions Assembly TopDown In-Context write_bistream}"
      foreach impl [get_implementations "!pr.impl impl" &&] {
         set partitions [get_attribute impl $impl partitions]
         set top        [get_attribute impl $impl top]
         set hd         [get_attribute impl $impl hd.impl]
         set td         [get_attribute impl $impl td.impl]
         set ic         [get_attribute impl $impl ic.impl]
         set bitstream  [get_attribute impl $impl bitstream]
         set hdCells ""
         foreach partition $partitions {
            lassign $partition name cell state level dcp
            if {![string match $cell $top]} {
               lappend hdCells "$name\($state\)"
            } else {
               set topState $state
            }
         }
         set hdCount [llength $hdCells]
         for {set i 0} {$i < $hdCount} {incr i} {
            if {$i==0} {
               append table " -row {$impl $top\($state\) [lindex $hdCells $i] $hd $td $ic $bitstream}"
            } else {
               append table " -row {\"\" \"\"  [lindex $hdCells $i] \"\" \"\" \"\" \"\"}"
            } 
         }
      }
      print_table $table 
   }
   if {[llength [get_implementations "!pr.impl !impl" &&]]} {
      puts "#HD: Defined Implementations not being implemented:"
      set count 1
      foreach impl [get_implementations "!pr.impl !impl" &&] {
         puts "\t$count. $impl"
         incr count
      }
   }
}
###############################################################
### Sorts the list of configurations to put any configuration
### that implements Static at the beginning of the list. This
### prevents having to worry about what order the configurations
### are defined in design.tcl, or allows them to easily be changed.
###############################################################
proc sort_configurations { configurations } {
   set configs "" 
   #Sort list of configurations. Insert "initial" config at beginning of list.
   foreach configuration $configurations {
      set partitions [get_attribute impl $configuration partitions]
      set top        [get_attribute impl $configuration top]
      foreach partition $partitions {
         lassign $partition name cell state level dcp
         if {[string match $cell $top]} {
            if {[string match -nocase $state "implement"]} {
               set configs [linsert $configs 0 $configuration]
            } else {
               lappend configs $configuration
            }
         }
      }
   }

   #Make sure no configurations get lost in the sort
   if {[llength $configs] == [llength $configurations]} {
      return $configs
   } else {
      set errMsg "\nERROR: Number of configurations changed during sorting process." 
      error $errMsg
   }
}

###############################################################
### Set specified parameters
###############################################################
proc set_parameters {params} {
   command "puts \"\t#HD: Setting Tcl Params:\""
   foreach {name value} $params   {
      puts "\t$name == $value"
      command "set_param $name $value"
   }
   puts "\n"
}

###############################################################
### Report all attributes
###############################################################
proc report_attributes { type name } {
   global ${type}Attribute
   global ${type}_attributes
   set procname [lindex [info level 0] 0]
   set widthCol1 18
   set widthCol2 90

   switch -exact -- $type {
      module  {set list_type "modules"}
      ooc     {set list_type "ooc_implementations"}
      impl    {set list_type "implementations"}
      default {error "\nERROR: Invalid type \'$type\' specified"}
   }

   check_list $list_type $name $procname
   puts "Report $type properties for $name:"
   puts "| [string repeat - $widthCol1] | [string repeat - $widthCol2] |"
   puts [format "| %-*s | %-*s |" $widthCol1 "Attribute" $widthCol2 "Value"]
   puts "| [string repeat - $widthCol1] | [string repeat - $widthCol2] |"
   foreach {attribute } [lsort [array names ${type}_attributes]] {
      set value [subst -nobackslash \$${type}Attribute(${name}.$attribute)]
      puts [format "| %-*s | %-*s |" $widthCol1 $attribute $widthCol2 $value]
   }
   puts "| [string repeat - $widthCol1] | [string repeat - $widthCol2] |"
}

###############################################################
### Get a list of all implementations that have pr.impl set to 1 
###############################################################
proc get_configurations { } {
   set configurations [get_implementations pr.impl]
   return $configurations
}

###############################################################
### Get a list of all modules 
###############################################################
proc get_modules { {filters ""} {function &&} } {
   upvar #0 modules modules

   if {[llength $filters]} {
      set filtered_modules ""
      foreach module $modules {
         foreach filter $filters {
            #Check if value is "not", and remove ! from name
            if {[regexp {!(.*)} $filter old filter]} {
               set value 0
            } else {
               set value 1
            }
            if {[get_attribute module $module $filter] == $value} {
               set match 1
               if {[string match $function "||"]} {
                  #Add matching filter results if not already added
                  if {[lsearch -exact $filtered_modules $module] < 0} {
                     lappend filtered_modules $module
                     break
                  }
               }
            } else {
               set match 0
               if {[string match $function "&&"]} {
                  break
               }
            }
         }
         if {$match && [string match $function "&&"]} {
            #Add matching filter results if not already added
            if {[lsearch -exact $filtered_modules $module] < 0} {
               lappend filtered_modules $module
            }
         }
      }
      return $filtered_modules
   } else {
      return $modules
   }
}

###############################################################
### Get a list of all implementations
### Filter on boolean attributes, using ! for not
###############################################################
proc get_implementations { {filters ""} {function &&} } {
   upvar #0 implementations implementations

   if {[llength $filters]} {
      set filtered_implementations ""
      foreach implementation $implementations {
         foreach filter $filters {
            #Check if value is "not", and remove ! from name
            if {[regexp {!(.*)} $filter old filter]} {
               set value 0
            } else {
               set value 1
            }
            if {[get_attribute impl $implementation $filter] == $value} {
               set match 1
               if {[string match $function "||"]} {
                  #Add matching filter results if not already added
                  if {[lsearch -exact $filtered_implementations $implementation] < 0} {
                     lappend filtered_implementations $implementation
                     break
                  }
               }
            } else {
               set match 0
               if {[string match $function "&&"]} {
                  break
               }
            }
         }
         if {$match && [string match $function "&&"]} {
            #Add matching filter results if not already added
            if {[lsearch -exact $filtered_implementations $implementation] < 0} {
               lappend filtered_implementations $implementation
            }
         }
      }
      return $filtered_implementations
   } else {
      return $implementations
   }
}

###############################################################
### Check Specified Part 
###############################################################
proc check_part {part} {
   set device [lindex [split $part -] 0]
   if {![llength [get_parts $part]]} {
      puts "ERROR: No valid part found matching specifiec part:\n\t$part"
      if {[llength [get_parts ${device}*]]} {
         puts "Valid part combinations for $device:"
         puts "\t[join [get_parts ${device}*] \n\t]"
      }
      error "ERROR: Check value of specified part."
   } else {
      puts "INFO: Found part matching $part"
   }
}

###############################################################

