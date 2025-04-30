# This Catapult LB script has been generated to expand the characterization range(es)
# of components of the Catapult base library(ies) to fit the current design
# 
# Running this script is optional but using the updated library should result in improved correlation.
# 
# Run this script in Catapult LB with the base library loaded or uncomment the "library load" command(s)

proc setup_workdir { libname } {
  set workdir [library get /LIBS/${libname}/WORKING_DIR]
  if {![file writable ${workdir}]} {
    set char_dir [file join [pwd] "${libname}.char"]
    catch {file mkdir $char_dir}
    library set /LIBS/${libname} -- -WORKING_DIR $char_dir
    if {  [file writable $char_dir]} {
      puts "Note: Characterization directory (WORKING_DIR) set to:  $char_dir"
    } else {
      puts "Error: Characterization directory (WORKING_DIR) for library ${libname} is not writable!"
    }
  }
}

#library load /opt/Catapult_2024.2/Mgc_home/pkgs/ccs_xilinx/mgc_Xilinx-VIRTEX-7-2_beh.lib
setup_workdir mgc_Xilinx-VIRTEX-7-2_beh

library set /LIBS/mgc_Xilinx-VIRTEX-7-2_beh/MODS/mgc_mux1hot/PARAMETERS/width -- -CHAR_RANGE {4 to 32, 96}
library set /LIBS/mgc_Xilinx-VIRTEX-7-2_beh/MODS/mgc_mux1hot/PARAMETERS/ctrlw -- -CHAR_RANGE {1, 4 to 32}
library set /LIBS/mgc_Xilinx-VIRTEX-7-2_beh/MODS/mgc_mux1hot/PARAMETERS/width -- -CHAR_RANGE {1, 4 to 32}
# The "library characterize" command below requires that: 
#   1. characterization working directory is set (default: pwd);
#   2. library exists and is write accessible;
#   3. paths to technology libraries are set to correct locations;
#   4. the downstream tool used to characterize the library is available;
library characterize
