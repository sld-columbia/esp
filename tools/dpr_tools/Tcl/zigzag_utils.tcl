proc getZigZag {args} {
   set args [join $args]

   set zigZag_left   "NA"
   set zigZag_right  "NA"
   set zigZag_top    "NA"
   set zigZag_bottom "NA"


   set pblock "null"
   set edges {left right top bottom}
   set xSearchRange 5
   set ySearchRange 5
   set xExtendRange 2
   set yExtendRange 2

   #Override defaults with command options
   set argLength [llength $args]
   set index 0
   set rowCount 0
   while {$index < $argLength} {
      set arg [lindex $args $index]
      set value [lindex $args [expr $index+1]]
      switch -exact -- $arg {
         {-pblock}   {set pblock [get_pblocks -quiet $value]}
         {-edges}    {set edges $value}
         {-xRange}   {set xSearchRange $value}
         {-yRange}   {set ySearchRange $value}
         {-help}     {set     helpMsg "Description:"
                      lappend helpMsg "Analyzes edges of specified Pblock to look for zig-zag paths.\n"
                      lappend helpMsg "Syntax:"
                      lappend helpMsg "getZigZag -pblock <pblock> \[-edges {right left top bottom}\]\n"
                      lappend helpMsg "Usage:"
                      lappend helpMsg "  Name                        Description"
                      lappend helpMsg "  -------------------------------------------------------------------------------"
                      lappend helpMsg "  \[-pblock]                   Required. Name of Pblock to be analyzed for zig-zag."
                      lappend helpMsg "  \[-edges]                    Optional, default is all edges. Suppoted values are"
                      lappend helpMsg "                              \'left\' \'right\' \'top\' and\/or \'bottom\'."
                      lappend helpMsg "  \[-xSearchRange]             Optional, default=3. Used to control how far to search."
                      lappend helpMsg "  \[-ySearchRange]             Optional, default=2. Used to control how far to search."
                      lappend helpMsg "  \[-help]                     Displays this message\n\n"
                      foreach line $helpMsg {
                         puts $FH $line
                      }
                      return
                     }
         default     {set errMsg "Error: Specified argument $arg is not supported.\n"
                      append errMsg "Supported arguments are -help, -title, -row, and -file.\n"
                      append errMsg "Use the -help option for more details"
                      error $errMsg 
                     }
      }
      set index [expr $index + 2]
   }

   if {[llength $pblock]} {
      puts "Processing Pblock $pblock"
   } else {
      if {[string match $pblock "null"]} {
         error "Error: No pblock specified. The -pblock switch must be provided."
      }
      error "Error: Pblock \'$pblock\' not found. Specify a valid Pblock."
   }

   foreach edge $edges {
      set FH [open "${pblock}_${edge}_edge.tcl" w]
      set zigZagCount 0
      set zigZagCells {}
      set zigZagNets {}
      set gridRanges [get_property DERIVED_RANGES $pblock]
      set sliceRanges [lsearch -regexp -inline -all $gridRanges ^SLICE_]
      foreach range $sliceRanges {
         #Define the four corners of each rectangle
         regexp {SLICE_(X.*Y.*):SLICE_(X.*Y.*)} $range match BLC TRC      
         set BRC "X[lindex [split $TRC XY] 1 ]Y[lindex [split $BLC XY] end]"
         set TLC "X[lindex [split $BLC XY] 1 ]Y[lindex [split $TRC XY] end]"
         #Define edges
         set leftEdge "$BLC:$TLC"
         set topEdge "$TLC:$TRC"
         set rightEdge "$BRC:$TRC"
         set bottomEdge "$BLC:$BRC"
         if {[string match $edge "left"]} {
            set currentEdge $leftEdge
            set color "orange"
            puts "\tProcessing Left Edge: $leftEdge"
         } elseif {[string match $edge "right"]} {
            set currentEdge $rightEdge
            set color "red"
            puts "\tProcessing Right Edge: $rightEdge"
         } elseif {[string match $edge "top"]} {
            set currentEdge $topEdge
            set color "cyan"
            puts "\tProcessing Top Edge: $topEdge"
         } elseif {[string match $edge "bottom"]} {
            set currentEdge $bottomEdge
            set color "magenta"
            puts "\tProcessing Bottom Edge: $bottomEdge"
         } else {
            error "Error: Edge value $edge is not supported. Supported values are \'left\' \'right\' \'top\' and \'bottom\'."
         }

         #Get X & Y values of current edge
         regexp {X(\d+)Y(\d+):X(\d+)Y(\d+)} $currentEdge match x1 y1 x2 y2
         set xValue $x1
         set yValue $y1
         set count 0
         set siteRange {}
         regexp {SLICE_X(\d+)Y(\d+)} [lindex [lsort -dict [get_sites SLICE_*]] end] match xMax yMax
         if {[string match $edge "left"]} {
            while {($xValue > 0) && ($count < $xSearchRange)} {
               set xValue [expr $xValue - 1]
               incr count
               set siteRange "SLICE_X${xValue}Y${y1}:SLICE_X[expr $x1-1]Y${y2}"
            }
         } elseif {[string match $edge "right"]} {
            while {($xValue < $xMax) && ($count < $xSearchRange)} {
               incr xValue
               incr count
               set siteRange "SLICE_X[expr $x1+1]Y${y1}:SLICE_X${xValue}Y${y2}"
            }
         } elseif {[string match $edge "top"]} {
#puts "DEBUG:yValue:$yValue yMax:$yMax $
            while {($yValue < $yMax) && ($count < $ySearchRange)} {
               incr yValue
               incr count
               set siteRange "SLICE_X${x1}Y[expr $y1+1]:SLICE_X${x2}Y${yValue}"
            }
         } elseif {[string match $edge "bottom"]} {
            while {($yValue > 0) && ($count < $ySearchRange)} {
               set yValue [expr $yValue - 1]
               incr count
               set siteRange "SLICE_X${x1}Y${yValue}:SLICE_X${x2}Y[expr ${y1}-1]"
            }
         }


         #If no siteRange defined, Pblock edge is probably edge aligned. Skip.
         if {![llength $siteRange]} {
            puts "\tInfo: No site ranges found to search for Pblock $pblock edge $currentEdge."
            continue
         }
         set searchSites {}
         #Get valid sites of each edge. Ignore sites that belong to the same Pblock
         foreach site [get_sites -range $siteRange] {
            if {![string match $pblock [get_pblocks -quiet -of $site]]} {
               lappend searchSites $site
            }
         } 
 
         #If no searchSites, Pblock edge is probably adjacent to itself.
         if {![llength $searchSites]} {
            puts "\tInfo: No sites to search search for Pblock $pblock edge $currentEdge."
            continue
         }
         puts $FH "highlight_objects -color $color \[get_tiles -of \[get_sites \{$searchSites\}\]\]"

         #Get cells of each edge
         set edgeCells [get_cells -of [get_sites $searchSites]] 
         puts "\tInfo: Found [llength $edgeCells] Cells in search area $siteRange"
         #Define X-Y checks values for the active egde
         set xCheck 0
         set yCheck 0
         set yLower 0
         set yUpper 0
         set xLeft  0
         set xRgith 0
         if {[string match $edge "left"]} {
            regexp {.*X(\d+)Y(\d+)} [get_tiles -of [get_sites SLICE_${BLC}]] match xCheck yLower
            regexp {.*X(\d+)Y(\d+)} [get_tiles -of [get_sites SLICE_${TLC}]] match xCheck yUpper
         } elseif {[string match $edge "right"]} {
            regexp {.*X(\d+)Y(\d+)} [get_tiles -of [get_sites SLICE_${BRC}]] match xCheck yLower
            regexp {.*X(\d+)Y(\d+)} [get_tiles -of [get_sites SLICE_${TRC}]] match xCheck yUpper
         } elseif {[string match $edge "top"]} {
            regexp {.*X(\d+)Y(\d+)} [get_tiles -of [get_sites SLICE_${TRC}]] match xRight yCheck
            regexp {.*X(\d+)Y(\d+)} [get_tiles -of [get_sites SLICE_${TLC}]] match xLeft yCheck
         } elseif {[string match $edge "bottom"]} {
            regexp {.*X(\d+)Y(\d+)} [get_tiles -of [get_sites SLICE_${BRC}]] match xRight yCheck
            regexp {.*X(\d+)Y(\d+)} [get_tiles -of [get_sites SLICE_${BLC}]] match xLeft yCheck
         }

         foreach cell $edgeCells {
            set zigZagLoads {}
            set loadCells [get_cells -quiet -of [get_pins -quiet -leaf -filter DIRECTION==IN -of [get_nets -quiet -of [get_pins -filter DIRECTION==OUT -of $cell]]]]
            foreach loadCell $loadCells {
               #ignore load cells that are assigned to the current Pblock
               if {[string match $pblock [get_pblocks -quiet -of $loadCell]]} {
                  continue
               }
               set loc [get_property LOC $loadCell]
               if {[llength $loc]} {
                  set tile [get_tiles -of $loc]
                  regexp {.*X(\d+)Y(\d+)} $tile match xLoad yLoad
                  if {[string match $edge "left"]} {
                     #Check if load crosses the left edge
                     if {$xLoad > $xCheck} {
                        #Check if zig-zag load in relatively same row (ie. yExtendRange)
                        if {($yLoad >= [expr $yLower - $yExtendRange]) && ($yLoad <= [expr $yUpper + $yExtendRange])} {
                           lappend zigZagLoads $loadCell
                        }
                     }
                  } elseif {[string match $edge "right"]} {
                     #Check if load crosses the right edge
                     if {$xLoad < $xCheck} {
                        #Check if zig-zag load in relatively same row (ie. yExtendRange)
                        if {($yLoad >= [expr $yLower - $yExtendRange]) && ($yLoad <= [expr $yUpper + $yExtendRange])} {
                           lappend zigZagLoads $loadCell
                        }
                     }
                  } elseif {[string match $edge "top"]} {
                     #Check if load crosses the top edge
                     if {$yLoad < $yCheck} {
                        #Check if zig-zag load in relatively same column (ie. xExtendRange)
                        if {($xLoad >= [expr $xLeft - $xExtendRange]) && ($xLoad <= [expr $xRight + $xExtendRange])} {
                           lappend zigZagLoads $loadCell
                        }
                     }
                  } elseif {[string match $edge "bottom"]} {
                     #Check if load crosses the top edge
                     if {$yLoad > $yCheck} {
                        #Check if zig-zag load in relatively same column (ie. xExtendRange)
                        if {($xLoad >= [expr $xLeft - $xExtendRange]) && ($xLoad <= [expr $xRight + $xExtendRange])} {
                           lappend zigZagLoads $loadCell
                        }
                     }
                  }
               } else {
                  puts "\tInfo: Load cell \'$loadCell\' of driver cell \'$cell\' is not placed. Skipping analysis"
               }
            }
            #Report on any zig-zag paths found between current cell and its loads
            if {[llength $zigZagLoads]} {
               incr zigZagCount
               lappend zigZagCells $cell
               lappend zigZagCells [join $zigZagLoads]
               lappend zigZagNets [get_nets -of [get_pins -filter DIRECTION==OUT -of $cell]]
            }
         }
         puts "\tInfo: Found $zigZagCount zig-zag paths for ${edge}-edge of Pblock $pblock"
         puts $FH "puts \"$zigZagCount zig-zag paths for ${edge}-edge of Pblock $pblock\""
      } ;#End foreach range
      set zigZag_$edge $zigZagCount
      puts $FH "mark_objects -color $color \[get_cells \{[join $zigZagCells]\}\]"
      puts $FH "highlight_objects -color $color \[get_nets \{[join $zigZagNets]\}\]"
      close $FH
      puts "\n"
   } ;#End foreach edge
   set table "-title \"ZigZag Analysis - \{$edges\}\""
   append table " -row {\"Pblock Name\" \"Left Edge\" \"Right Edge\" \"Top Edge\" \"Bottom Edge\"}"
   append table " -row {$pblock $zigZag_left $zigZag_right $zigZag_top $zigZag_bottom}"
   print_table $table
}


proc getExcludePblocks {} {
   set pblocks [get_pblocks -filter EXCLUDE_PLACEMENT]
   if {[llength $pblocks]} {
      puts "Found the following [llength $pblocks] Pblock(s) with Exclude Placement.\n\t[join $pblocks \t\n]"
      return $pblocks
   } else {
      puts "No Exclude Placement Pblocks found."
      return
   }
}
