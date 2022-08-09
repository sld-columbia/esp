#!/bin/bash

# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

#variables related to srcs of accelerators
#tile_acc="$1/socs/$2/socketgen/tile_acc.vhd"
tile_acc="$1/socs/$2/socketgen/acc_top.vhd"
dpr_srcs="$1/socs/$2/socketgen/dpr_srcs"
dpr_bbox="$dpr_srcs/acc_top_bbox.vhd"
original_src="$1/socs/$2/vivado/srcs.tcl"
temp_srcs="/tmp/temp_srcs.tcl"
esp_config="$1/socs/$2/socgen/esp/.esp_config"
esp_config_old="$1/socs/$2/vivado_dpr/.esp_config"
tcl_dir="$1/socs/common/dpr_tools/Tcl"

#variables related to accelerator tiles
num_acc_tiles=0
num_old_acc_tiles=0
num_modified_acc_tiles=0
regenerate_fplan=0;

DEVICE=$3
device=$(echo ${DEVICE} | awk '{print tolower($0)}')
acc_id_match="hls_conf       : hlscfg_t"
declare -A new_accelerators old_accelerators modified_accelerators
declare -A res_consumption
declare -A bitstream_descr

PBS_DDR_OFFSET=0x3000;

#function to extract the number and types of accelerator tiles from current esp_config
function extract_acc() {
while read line
do
    for word in $line
    do
        if [[ $word == *"TILE_"* ]]; then
            _line=( $line )
            tile_token=${_line[0]}
            tile_index=${_line[2]}
            tile_type=${_line[3]}
            acc_name=${_line[4]}
            acc_name+="_$tile_index"
            if [[ $tile_type == "acc" ]]; then
                new_accelerators["$num_acc_tiles,0"]=$tile_index;
                new_accelerators["$num_acc_tiles,1"]=$(echo ${acc_name} | awk '{print tolower($0)}');
                ((num_acc_tiles++));
            fi
#            echo "$tile_token $tile_index $tile_type $acc_name $1 $2 $3 ";
        fi
    done
done < $esp_config

#for ((i=0; i<num_acc_tiles; i++)) 
#do
#echo " new accelerator $i is ${new_accelerators[${i},0]}  ${new_accelerators[${i},1]};"
#done

}

#function to extract the number and types of accelerator tiles from the old esp_config in vivado_dpr dir
function extract_acc_old() {
while read line
do
    for word in $line
    do
        if [[ $word == *"TILE"* ]]; then
            _line=( $line )
            tile_token=${_line[0]}
            tile_index=${_line[2]}
            tile_type=${_line[3]}
            acc_name=${_line[4]}
            acc_name+="_$tile_index"
            if [[ $tile_type == "acc" ]]; then
                old_accelerators["$num_old_acc_tiles,0"]=$tile_index;
                old_accelerators["$num_old_acc_tiles,1"]=$(echo ${acc_name} | awk '{print tolower($0)}');
                ((num_old_acc_tiles++));
            fi
 #           echo $tile_token $tile_index $tile_type $acc_name $1 $2 $3;
        fi
    done
done < $esp_config_old
}

#function to figure out which acc_tile is changed in the new .esp_config
#TODO: this func relies on name change of acc_tiles to mark change, this is 
#obvioulsy insufficient when the same acc_tile is modified without a name change
function diff_accelerators() {
for ((i=0; i<$num_acc_tiles; i++))
do
    if [ "${new_accelerators[$i,1]}" != "${old_accelerators[$i,1]}" ]; then
        modified_accelerators[$num_modified_acc_tiles,0]=${new_accelerators[$i,0]};
        modified_accelerators[$num_modified_acc_tiles,1]=${new_accelerators[$i,1]};
        ((num_modified_acc_tiles++));
    fi
       
done 

    echo -e "\t DPR: number of modified tiles is equal to $num_modified_acc_tiles "
}

#This function initializes the specific accelerator tiles from the template acc_dpr.vhd
#initialization refers to replacing the default parameters of the template acc with 
#acc specific parameters
function initialize_acc_tiles() {
for ((i=0; i<$num_acc_tiles; i++))
do
    skip_params=0;
    acc_dir="$dpr_srcs/acc_${new_accelerators[$i,0]}_top";
    mkdir -p $acc_dir;
    echo " " > $acc_dir/acc_$i.vhd;

    while read acc_src
    do
        if [[ $acc_src == *"$acc_id_match"*  ]]; then
            echo "  hls_conf           : hlscfg_t := tile_design_point(${new_accelerators[$i,0]});" >> $acc_dir/acc_$i.vhd;
            echo "  this_device        : devid_t  := tile_device(${new_accelerators[$i,0]});" >> $acc_dir/acc_$i.vhd;
            echo "  tech               : integer  := CFG_FABTECH;">> $acc_dir/acc_$i.vhd;
            echo "  mem_num            : integer  := CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_SVGA_ENABLE;">> $acc_dir/acc_$i.vhd;
            echo "  cacheable_mem_num  : integer  := CFG_NMEM_TILE;">> $acc_dir/acc_$i.vhd;
            echo "  mem_info           : tile_mem_info_vector(0 to CFG_NMEM_TILE + CFG_NSLM_TILE) := tile_acc_mem_list;">> $acc_dir/acc_$i.vhd;
            echo "  io_y               : local_yx := tile_y(io_tile_id);">> $acc_dir/acc_$i.vhd;
            echo "  io_x               : local_yx := tile_x(io_tile_id);">> $acc_dir/acc_$i.vhd;
            echo "  pindex             : integer  := 1;">> $acc_dir/acc_$i.vhd;
            echo "  irq_type           : integer  := tile_irq_type(${new_accelerators[$i,0]});">> $acc_dir/acc_$i.vhd; 
            echo "  scatter_gather     : integer range 0 to 1  := CFG_SCATTER_GATHER;">> $acc_dir/acc_$i.vhd;
            echo "  sets               : integer  := CFG_ACC_L2_SETS;">> $acc_dir/acc_$i.vhd;
            echo "  ways               : integer  := CFG_ACC_L2_WAYS;">> $acc_dir/acc_$i.vhd;
            echo "  little_end     : integer range 0 to 1 := 0;">> $acc_dir/acc_$i.vhd;
            echo "  cache_tile_id      : cache_attribute_array := cache_tile_id;">> $acc_dir/acc_$i.vhd;
            echo "  cache_y            : yx_vec(0 to 2**NL2_MAX_LOG2 - 1) := cache_y;">> $acc_dir/acc_$i.vhd;
            echo "  cache_x            : yx_vec(0 to 2**NL2_MAX_LOG2 - 1) := cache_x;">> $acc_dir/acc_$i.vhd;
            echo "  has_l2             : integer range 0 to 1 := tile_has_l2(${new_accelerators[$i,0]});">> $acc_dir/acc_$i.vhd;
            echo "  has_dvfs           : integer range 0 to 1 := tile_has_dvfs(${new_accelerators[$i,0]});">> $acc_dir/acc_$i.vhd; 
            echo "  has_pll            : integer range 0 to 1 := tile_has_pll(${new_accelerators[$i,0]});">> $acc_dir/acc_$i.vhd; 
            echo "  extra_clk_buf      : integer range 0 to 1 := extra_clk_buf(${new_accelerators[$i,0]}));">> $acc_dir/acc_$i.vhd; 
            skip_params=20;
        elif [[ $skip_params -ne 0 ]]; then
            skip_params=$((skip_params-1));
        else
            echo "  $acc_src" >> $acc_dir/acc_$i.vhd;
        fi
    done <$tile_acc
done
}

function patch_acc_devid() {
for ((i=0; i<$num_modified_acc_tiles; i++))
do
    #extract the names of the newly modified accs and parse them to name and type of acc
    acc_name=$(echo ${modified_accelerators[$i,1]} | awk -F'[_]' '{print($1)}');
    acc_type=$(echo ${modified_accelerators[$i,1]} | awk -F'[_]' '{print($2)}');
    acc_def=$(echo "sld_"$acc_name | awk '{print toupper($0)}');

    #extract the id of the tile where the accelerators were modified
    for ((k=0; k<$num_acc_tiles; k++)) do
        if [[ "$old_accelerators[$k,0]" == "$modified_accelerators[$i,0]" ]]; then
            parent_tile=$k;
            break;
        fi
    done
    
    #extract the name of old tiles and do the same parsing (name and type)
    modified_tile=$(echo ${modified_accelerators[$i,0]} | awk -F'[_]' '{print($2)}');
    old_acc_name=$(echo ${old_accelerators[$parent_tile,1]} | awk -F'[_]' '{print($1)}');
    old_acc_type=$(echo ${old_accelerators[$parent_tile,1]} | awk -F'[_]' '{print($2)}');
    old_acc_def=$(echo "sld_"$old_acc_name | awk '{print toupper($0)}');
    
    #extract the tile id from old acc tile and assign them to new acc
    if [[ $old_acc_type == "stratus" ]]; then
        sw_src="$1/accelerators/stratus_hls/$old_acc_name"_"$old_acc_type/sw/baremetal/$old_acc_name".c"";
    elif [[ $old_acc_type == "vivado" ]]; then
        sw_src="$1/accelerators/vivado_hls/$old_acc_name"_"$old_acc_type/sw/baremetal/$old_acc_name".c"";
    elif [[ $old_acc_type == "catapult" ]]; then
        sw_src="$1/accelerators/catapult_hls/$old_acc_name"_"$old_acc_type/sw/baremetal/$old_acc_name".c"";
    elif [[ $old_acc_type == "hls4ml" ]]; then
        sw_src="$1/accelerators/hls4ml/$old_acc_name"_"$old_acc_type/sw/baremetal/$old_acc_name".c"";
    else
        echo "unknown type of accelerator";
    fi
    

    if [[ $acc_type == "stratus" ]]; then
        temp_sw_dest="$1/accelerators/stratus_hls/$acc_name"_"$acc_type/sw/baremetal/$acc_name"_dpr.c""; 
        sw_dest="$1/accelerators/stratus_hls/$acc_name"_"$acc_type/sw/baremetal/$acc_name".c""; 
    elif [[ $acc_type == "vivado" ]]; then
        temp_sw_dest="$1/accelerators/vivado_hls/$acc_name"_"$acc_type/sw/baremetal/$acc_name"_dpr.c"";
        sw_dest="$1/accelerators/vivado_hls/$acc_name"_"$acc_type/sw/baremetal/$acc_name".c"";
    elif [[ $acc_type == "catapult" ]]; then
        temp_sw_dest="$1/accelerators/catapult_hls/$acc_name"_"$acc_type/sw/baremetal/$acc_name"_dpr.c"";
        sw_dest="$1/accelerators/catapult_hls/$acc_name"_"$acc_type/sw/baremetal/$acc_name".c"";
    elif [[ $acc_type == "hls4ml" ]]; then
        temp_sw_dest="$1/accelerators/hls4ml/$acc_name"_"$acc_type/sw/baremetal/$acc_name"_dpr.c"";
        sw_dest="$1/accelerators/hls4ml/$acc_name"_"$acc_type/sw/baremetal/$acc_name".c"";
    else
        echo "unknown type of accelerator";
    fi
    
    echo " " > $temp_sw_dest;
    
    while IFS= read -r line; do
        if [[ $line  == "#define $old_acc_def"* ]]; then
            new_acc_id=$(echo $line | awk '{print($3)}');
            new_line="#define $acc_def  $new_acc_id";
            #echo "new acc id $new_line";
            break;
        fi
    done < $sw_src
    
    while IFS= read -r line; do
        if [[ "$line"  == "/* DPR patch:"* ||  "$line"  == "For non-DPR"* || "$line" == "//#define $acc_def"* ]]; then
            continue;
        elif [[ "$line"  == "#define $acc_def"* ]]; then
            printf "/* DPR patch: line commented to make DPR work. \n"  >> $temp_sw_dest;
            printf  "For non-DPR acceleration, swap the commented defs */\n" >> $temp_sw_dest;
            printf "//%s\n" "$line" >> $temp_sw_dest;
            printf "%s\n" "$new_line" >> $temp_sw_dest;
        else
            printf "%s\n" "$line" >> $temp_sw_dest;
    
        fi
    done < $sw_dest
    
    cp $temp_sw_dest $sw_dest;
    rm $temp_sw_dest;
done
}

#initialize bbox tiles
function initialize_bbox_tiles() {
mkdir -p $dpr_srcs
echo " " > $dpr_bbox;
echo " " > $temp_srcs;

while read line
do
    if [[ $line == "begin" ]]; then
        echo "  attribute black_box : string;" >> $dpr_bbox;
        echo "  attribute black_box of rtl : architecture is \"true\";" >> $dpr_bbox;
    fi
    echo "  $line" >> $dpr_bbox;
done < $tile_acc


while read src_list
do
    if [[ $src_list == *"acc_top.vhd" ]]; then
        echo "read_vhdl $dpr_srcs/acc_top_bbox.vhd" >> $temp_srcs;
    else
        echo "$src_list" >> $temp_srcs;
    fi
done < $original_src

mv $temp_srcs $original_src;
}

#add acc source to prj file
function add_acc_prj_file() {
for ((i=0; i<$num_acc_tiles; i++))
do
    prj_source="$1/socs/$2/vivado/srcs.tcl"
    acc_dir="$dpr_srcs/acc_${new_accelerators[$i,0]}_top";
    output="$acc_dir/src.prj"

echo " " > $output
while read -r type ext addr
do
    if [[ "$ext" == *"acc_top.vhd"* ]] || [[ "$ext" == *"acc_top_bbox.vhd"* ]]; then
        echo "vhdl xil_defaultlib $acc_dir/acc_$i.vhd" >> $output;
    elif [ "$type" == "read_verilog" ] && [ "$ext" == "-sv" ] && [[ "$addr" != *"nbdcache"* ]] && [[ "$addr" != *"miss_handler"* ]]  && [[ "$addr" != *"llc_rtl_top"* ]]; then
        echo "system xil_defaultlib $addr" >> $output
    elif [ "$type" == "read_vhdl" ]; then
        echo "vhdl xil_defaultlib $ext" >> $output
    elif [ "$type" == "read_verilog" ] && [ "$ext" != "-sv" ]; then
        echo "verilog  xil_defaultlib $ext" >> $output
    fi;
done < $prj_source
done
}

#generate the tcl script to synthesise and implement the design
function gen_synth_script() {

syn_include_file="$1/socs/$2/vivado/setup.tcl";
syn_include="$tcl_dir/synth_include.tcl";
rm -rf $syn_include;

while read line 
do
    for word in $line
    do
        if [[ "$word" == "include_dirs" ]]; then
            echo "$line" >> $syn_include;
            break;
        fi;
    done
done < $syn_include_file;

#generate the synth script
dpr_syn_tcl="vivado_dpr/ooc_syn.tcl"
echo "set tclParams [list hd.visual 1]" > $dpr_syn_tcl;
echo "set tclHome \"$tcl_dir\" " >> $dpr_syn_tcl; #\"$1/socs/common/Tcl\" " >> $dpr_syn_tcl;
echo "set tclDir \$tclHome " >> $dpr_syn_tcl;
echo "set projDir \"$1/socs/$2/vivado_dpr\" " >> $dpr_syn_tcl;
echo "source \$tclDir/design_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/log_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/synth_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/impl_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/pr_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/log_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/hd_floorplan_utils.tcl" >> $dpr_syn_tcl;

echo " " >> $dpr_syn_tcl;

echo "####### FPGA type #######" >> $dpr_syn_tcl;
echo "set part $device" >> $dpr_syn_tcl;
echo "check_part \$part" >> $dpr_syn_tcl;

echo "set run.topSynth  0" >> $dpr_syn_tcl;
echo "set run.rmSynth   1" >> $dpr_syn_tcl;
echo "set run.prImpl    1" >> $dpr_syn_tcl;
echo "set run.prVerify  1" >> $dpr_syn_tcl;
echo "set run.writeBitstream 1" >> $dpr_syn_tcl;

echo "####Report and DCP controls - values: 0-required min; 1-few extra; 2-all" >> $dpr_syn_tcl;
echo "set verbose      1" >> $dpr_syn_tcl;
echo "set dcpLevel     1" >> $dpr_syn_tcl;

echo " " >> $dpr_syn_tcl;

echo "####Output Directories" >> $dpr_syn_tcl;
echo "set synthDir  \$projDir/Synth" >> $dpr_syn_tcl;
echo "set implDir   \$projDir/Implement" >> $dpr_syn_tcl;
echo "set dcpDir    \$projDir/Checkpoint" >> $dpr_syn_tcl;
echo "set bitDir    \$projDir/Bitstreams" >> $dpr_syn_tcl;

echo " " >> $dpr_syn_tcl;

echo "####Input Directories " >> $dpr_syn_tcl;
echo "set srcDir     \$projDir/Sources" >> $dpr_syn_tcl;
echo "set rtlDir     \$srcDir/hdl" >> $dpr_syn_tcl;
echo "set prjDir     \$srcDir/project" >> $dpr_syn_tcl;
echo "set xdcDir     \$srcDir/xdc" >> $dpr_syn_tcl;
echo "set coreDir    \$srcDir/cores" >> $dpr_syn_tcl;
echo "set netlistDir \$srcDir/netlist" >> $dpr_syn_tcl;

echo " " >> $dpr_syn_tcl;

echo "#################################################################### " >> $dpr_syn_tcl;
echo "### Top Module Definitions" >> $dpr_syn_tcl;
echo "#################################################################### " >> $dpr_syn_tcl;
echo "set top \"top\" " >> $dpr_syn_tcl;
echo "set static \"Static\" " >> $dpr_syn_tcl;
echo "add_module \$static " >> $dpr_syn_tcl;
echo "set_attribute module \$static moduleName    \$top" >> $dpr_syn_tcl;
echo "set_attribute module \$static top_level     1 " >> $dpr_syn_tcl;
echo "#set_attribute module \$static synthCheckpoint \$synthDir/\$static/top_synth.dcp " >> $dpr_syn_tcl;
echo "#set_attribute module \$static synth         \${run.topSynth} " >> $dpr_syn_tcl;


echo "####################################################################" >> $dpr_syn_tcl;
echo "### RP Module Definitions " >> $dpr_syn_tcl;
echo "#################################################################### " >> $dpr_syn_tcl;

echo -e "\t DPR: number of acc tiles inside dpr gen is $num_acc_tiles ";
if [[ "$4" == "DPR" ]]; then
    for ((i=0; i<num_acc_tiles; i++))
    do
        acc_dir="$dpr_srcs/acc_${new_accelerators[$i,0]}_top";
        prj_src="$acc_dir/src.prj"
        echo "add_module ${new_accelerators[$i,1]} " >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} moduleName acc_top" >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} prj $prj_src" >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} synth  \${run.rmSynth}" >> $dpr_syn_tcl;
    done
elif [[ "$4" == "ACC" ]] && [[ "$num_modified_acc_tiles" != "0" ]]; then
    for ((i=0, j=0; i<$num_acc_tiles; i++))
    do
        acc_dir="$dpr_srcs/acc_${new_accelerators[$i,0]}_top";
        prj_src="$acc_dir/src.prj"
        echo "add_module ${new_accelerators[$i,1]} " >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} moduleName acc_top" >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} prj $prj_src" >> $dpr_syn_tcl;
        if [[ ${modified_accelerators[$j,0]} == ${new_accelerators[$i,0]} ]]; then
            echo "set_attribute module ${new_accelerators[$i,1]} synth  \${run.rmSynth}" >> $dpr_syn_tcl;
            ((j++));
        fi;
    done
fi;

echo "source \$tclDir/run.tcl" >> $dpr_syn_tcl;
echo "exit" >> $dpr_syn_tcl;
}


#generate the tcl script to synthesise and implement the design
function gen_impl_script() {
syn_include_file="$1/socs/$2/vivado/setup.tcl";
syn_include="$tcl_dir/synth_include.tcl";
rm -rf $syn_include;

while read line 
do
    for word in $line
    do
        if [[ "$word" == "include_dirs" ]]; then
            echo "$line" >> $syn_include;
            break;
        fi;
    done
done < $syn_include_file;

#generate the imlementation script
dpr_syn_tcl="vivado_dpr/impl.tcl"
echo "set tclParams [list hd.visual 1]" > $dpr_syn_tcl;
echo "set tclHome \"$tcl_dir\" ">> $dpr_syn_tcl; # \"$1/socs/common/Tcl\" " >> $dpr_syn_tcl;
echo "set tclDir \$tclHome " >> $dpr_syn_tcl;
echo "set projDir \"$1/socs/$2/vivado_dpr\" " >> $dpr_syn_tcl;
echo "source \$tclDir/design_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/log_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/synth_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/impl_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/pr_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/log_utils.tcl" >> $dpr_syn_tcl;
echo "source \$tclDir/hd_floorplan_utils.tcl" >> $dpr_syn_tcl;

echo " " >> $dpr_syn_tcl;

echo "####### FPGA type #######" >> $dpr_syn_tcl;
echo "set part $device" >> $dpr_syn_tcl;
echo "check_part \$part" >> $dpr_syn_tcl;

echo "set run.topSynth  0" >> $dpr_syn_tcl;
echo "set run.rmSynth   0" >> $dpr_syn_tcl;
echo "set run.prImpl    1" >> $dpr_syn_tcl;
echo "set run.prVerify  1" >> $dpr_syn_tcl;
echo "set run.writeBitstream 1" >> $dpr_syn_tcl;

echo "####Report and DCP controls - values: 0-required min; 1-few extra; 2-all" >> $dpr_syn_tcl;
echo "set verbose      1" >> $dpr_syn_tcl;
echo "set dcpLevel     1" >> $dpr_syn_tcl;

echo " " >> $dpr_syn_tcl;

echo "####Output Directories" >> $dpr_syn_tcl;
echo "set synthDir  \$projDir/Synth" >> $dpr_syn_tcl;
echo "set implDir   \$projDir/Implement" >> $dpr_syn_tcl;
echo "set dcpDir    \$projDir/Checkpoint" >> $dpr_syn_tcl;
echo "set bitDir    \$projDir/Bitstreams" >> $dpr_syn_tcl;

echo " " >> $dpr_syn_tcl;

echo "####Input Directories " >> $dpr_syn_tcl;
echo "set srcDir     \$projDir/Sources" >> $dpr_syn_tcl;
echo "set rtlDir     \$srcDir/hdl" >> $dpr_syn_tcl;
echo "set prjDir     \$srcDir/project" >> $dpr_syn_tcl;
echo "set xdcDir     \$srcDir/xdc" >> $dpr_syn_tcl;
echo "set coreDir    \$srcDir/cores" >> $dpr_syn_tcl;
echo "set netlistDir \$srcDir/netlist" >> $dpr_syn_tcl;

echo " " >> $dpr_syn_tcl;

echo "#################################################################### " >> $dpr_syn_tcl;
echo "### Top Module Definitions" >> $dpr_syn_tcl;
echo "#################################################################### " >> $dpr_syn_tcl;
echo "set top \"top\" " >> $dpr_syn_tcl;
echo "set static \"Static\" " >> $dpr_syn_tcl;
echo "add_module \$static " >> $dpr_syn_tcl;
echo "set_attribute module \$static moduleName    \$top" >> $dpr_syn_tcl;
echo "set_attribute module \$static top_level     1 " >> $dpr_syn_tcl;
echo "#set_attribute module \$static synthCheckpoint \$synthDir/\$static/top_synth.dcp " >> $dpr_syn_tcl;
#echo "set_attribute module \$static synth         \${run.topSynth} " >> $dpr_syn_tcl;


echo "####################################################################" >> $dpr_syn_tcl;
echo "### RP Module Definitions " >> $dpr_syn_tcl;
echo "#################################################################### " >> $dpr_syn_tcl;

echo -e "\t DPR: number of acc tiles inside dpr gen is $num_acc_tiles ";
#if [[ "$4" == "IMPL_DPR" ]]; then
    for ((i=0; i<num_acc_tiles; i++))
    do
        acc_dir="$dpr_srcs/acc_${new_accelerators[$i,0]}_top";
        #acc_dir="$dpr_srcs/accelerator_$i";
        prj_src="$acc_dir/src.prj"
        echo "add_module ${new_accelerators[$i,1]} " >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} moduleName acc_top" >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} prj $prj_src" >> $dpr_syn_tcl;
        #echo "set_attribute module ${new_accelerators[$i,1]} synth  \${run.rmSynth}" >> $dpr_syn_tcl;
    done
#elif [[ "$4" == "ACC" ]] && [[ "$num_modified_acc_tiles" != "0" ]]; then
#    for ((i=0; i<$num_acc_tiles; i++))
#    do
#        acc_dir="$dpr_srcs/tile_${new_accelerators[$i,0]}_acc";
        #acc_dir="$dpr_srcs/accelerator_$i";
#        prj_src="$acc_dir/src.prj"
#        echo "add_module ${new_accelerators[$i,1]} " >> $dpr_syn_tcl;
#        echo "set_attribute module ${new_accelerators[$i,1]} moduleName tile_acc" >> $dpr_syn_tcl;
#        echo "set_attribute module ${new_accelerators[$i,1]} prj $prj_src" >> $dpr_syn_tcl;
#        if [[ ${modified_accelerators[$i,0]} == ${new_accelerators[$i,0]} ]]; then
#            echo "set_attribute module ${new_accelerators[$i,1]} synth  \${run.rmSynth}" >> $dpr_syn_tcl;
#        fi;
#    done
#fi;

echo "####################################################################" >> $dpr_syn_tcl;
echo "### Implementation " >> $dpr_syn_tcl;
echo "#################################################################### " >> $dpr_syn_tcl;

echo "add_implementation top_dpr " >> $dpr_syn_tcl;
echo "set_attribute impl top_dpr top        \$top" >> $dpr_syn_tcl;
echo "set_attribute impl top_dpr pr.impl      1" >> $dpr_syn_tcl;
if [[ "$2" == "xilinx-vcu118-xcvu9p" ]]; then
    echo "set_attribute impl top_dpr implXDC     [list [ list $1/constraints/$2/pblocks.xdc $1/constraints/$2/$2.xdc $1/constraints/$2/$2-eth-constraints.xdc $1/constraints/$2/$2-eth-pins.xdc  $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/mig/par/mig.xdc $1/constraints/$2/$2-mig-pins.xdc $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/sgmii/synth/sgmii.xdc ] ]" >> $dpr_syn_tcl;
elif [[ $2 == "xilinx-vcu128-xcvu37p" ]]; then
echo "set_attribute impl top_dpr implXDC     [list [ list $1/constraints/$2/pblocks.xdc $1/constraints/$2/$2.xdc $1/constraints/$2/$2-eth-constraints.xdc $1/constraints/$2/$2-eth-pins.xdc  $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/mig_clamshell/par/mig_clamshell.xdc $1/constraints/$2/$2-mig-pins.xdc $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/sgmii_vcu128/synth/sgmii_vcu128.xdc ] ]" >> $dpr_syn_tcl;
else    
    echo "set_attribute impl top_dpr implXDC     [list [ list $1/constraints/$2/pblocks.xdc $1/constraints/$2/$2.xdc $1/constraints/$2/$2-eth-constraints.xdc $1/constraints/$2/$2-eth-pins.xdc  $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/mig/mig/user_design/constraints/mig.xdc ]]" >> $dpr_syn_tcl;
fi;

#if [[ "$2" == "xilinx-vcu118-xcvu9p" ]]; then
#   echo "set_attribute impl top_dpr implXDC     [list [ list $1/constraints/$2/pblocks.xdc $1/constraints/$2/$2.xdc $1/constraints/$2/$2-eth-constraints.xdc $1/constraints/$2/$2-eth-pins.xdc  $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/mig/par/mig.xdc $1/constraints/$2/$2-mig-pins.xdc $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/sgmii/synth/sgmii.xdc ] ]" >> $dpr_syn_tcl;
#elif [[ $2 == "xilinx-vcu128-xcvu37p" ]]; then
#echo "set_attribute impl top_dpr implXDC     [list [ list $1/constraints/$2/pblocks.xdc $1/constraints/$2/$2.xdc $1/constraints/$2/$2-eth-constraints.xdc $1/constraints/$2/$2-eth-pins.xdc  $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/mig_clamshell/par/mig_clamshell.xdc $1/constraints/$2/$2-mig-pins.xdc $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/sgmii_vcu128/synth/sgmii_vcu128.xdc ] ]" >> $dpr_syn_tcl;
#else    
#    echo "set_attribute impl top_dpr implXDC     [list [ list $1/constraints/$2/pblocks.xdc $1/constraints/$2/$2.xdc $1/constraints/$2/$2-eth-constraints.xdc $1/constraints/$2/$2-eth-pins.xdc  $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/mig/mig/user_design/constraints/mig.xdc $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/sgmii/synth/sgmii.xdc ] ]" >> $dpr_syn_tcl;
#fi;
#echo "set_property SEVERITY {Warning} [get_drc_checks HDPR-41]" >> $dpr_syn_tcl;

if [[ "$4" == "IMPL_DPR" ]]; then
    echo "set_attribute impl top_dpr partitions  [list [list \$static \$top  implement ] \\" >> $dpr_syn_tcl;
    for ((i=0; i<$num_acc_tiles; i++))
    do
        echo "[list ${new_accelerators[$i,1]}  esp_1/tiles_gen[${new_accelerators[$i,0]}].accelerator_tile.tile_acc_i/tile_acc_1/acc_top_inst implement ] \\" >>  $dpr_syn_tcl;
    done
    echo "]"  >> $dpr_syn_tcl;
elif [[ "$4" == "IMPL_ACC" ]] && [[ "$num_modified_acc_tiles" != "0" ]]; then
    if  [[ $regenerate_fplan == 1 ]]; then
        echo "set_attribute impl top_dpr partitions  [list [list \$static \$top  implement ] \\" >> $dpr_syn_tcl; 
    else
        echo "set_attribute impl top_dpr partitions  [list [list \$static \$top  import ] \\" >> $dpr_syn_tcl; 
    fi

    for ((i=0, j=0; j<$num_acc_tiles; j++))
    do
        if  [[ $regenerate_fplan == 1 ]]; then
            echo "[list ${new_accelerators[$j,1]}  esp_1/tiles_gen[${new_accelerators[$j,0]}].accelerator_tile.tile_acc_i/tile_acc_1/acc_top_inst implement ] \\" >>  $dpr_syn_tcl;

        elif [[ ${modified_accelerators[$i,0]} == ${new_accelerators[$j,0]} ]]; then
            echo "[list ${modified_accelerators[$i,1]}  esp_1/tiles_gen[${modified_accelerators[$i,0]}].accelerator_tile.tile_acc_i/tile_acc_1/acc_top_inst implement ] \\" >>  $dpr_syn_tcl;
            ((i++));
        else
            echo "[list ${new_accelerators[$j,1]}  esp_1/tiles_gen[${new_accelerators[$j,0]}].accelerator_tile.tile_acc_i/tile_acc_1/acc_top_inst import ] \\" >>  $dpr_syn_tcl;
        fi
    done
    echo "]"  >> $dpr_syn_tcl;
else

echo -e "\t DPR: No accelerator tile was modified ";
    exit;
fi;
echo "set_attribute impl top_dpr impl       \${run.prImpl}" >> $dpr_syn_tcl;
echo "set_attribute impl top_dpr verify     \${run.prVerify}" >> $dpr_syn_tcl;
echo "set_attribute impl top_dpr bitstream  \${run.writeBitstream}" >> $dpr_syn_tcl;
echo "set_attribute impl top_dpr cfgmem.icap     1 " >> $dpr_syn_tcl;

echo "source \$tclDir/run.tcl" >> $dpr_syn_tcl;
echo "exit" >> $dpr_syn_tcl;
}

function gen_bs_script() {
bs_gen_script=$1/socs/$2/vivado_dpr/bs.tcl;

    echo " " > $bs_gen_script;
    
    echo "open_checkpoint Implement/top_dpr/top_route_design.dcp" >> $bs_gen_script;
    echo "write_bitstream -force -bin_file Bitstreams/acc_bs" >> $bs_gen_script;
    echo "source [get_property REPOSITORY [get_ipdefs *prc:1.3]]/xilinx/prc_v1_3/tcl/api.tcl" >> $bs_gen_script;
    
    for((i=0; i<$num_acc_tiles; i++)) do
        echo "prc_v1_3::format_bin_for_icap -i Bitstreams/acc_bs_pblock_slot_"$i"_partial.bin -o Bitstreams/${new_accelerators[$i,1]}.bin" >> $bs_gen_script;
    done
}

function gen_bs_descriptor() {
pbs_map=$1/socs/$2/socgen/esp/pbs_map.h;
pbs_path=$1/socs/$2/partial_bitstreams;

    for((i=0; i<$num_acc_tiles; i++)) do
        cp $1/socs/$2/vivado_dpr/Bitstreams/${new_accelerators[$i,1]}.bin $1/socs/$2/partial_bitstreams; 
    done
    

num_pbs=$(cd $1/socs/$2/partial_bitstreams && (ls | wc -l));
pbs_addr=0;
array=$(ls -ls $1/socs/$2/partial_bitstreams)
    
    echo " " > $pbs_map;
    echo "pbs_map bs_descriptor [$num_pbs] = { " >> $pbs_map;
    
    for FILE in $pbs_path/*; do
        pbs_name=$(basename $FILE | awk -F'[.]' '{print($1)}');
        pbs_size=$(echo `ls -ls $FILE` | awk '{print($6)}'); 
        pbs_tile_id=$(echo $pbs_name | awk -F'[_]' '{print($3)}');
        echo "{\"$pbs_name\", $pbs_size, $pbs_addr, $pbs_tile_id}, " >> $pbs_map;
        pbs_addr=$(($pbs_addr + $pbs_size + $PBS_DDR_OFFSET));
        echo "file is $pbs_size $pbs_tile_id $pbs_name";
    done
    echo "};" >>$pbs_map;
    
}

function load_bs() {
#get cpu arch
while read line
do
    for word in $line
    do
        if [[ $word == "CPU_ARCH"* ]]; then
            _line=( $line )
            arch=${_line[2]}
            echo "$arch"
            if [[ $arch == "leon3" ]]; then
               pbs_base_addr=0x50000000;
            else
               pbs_base_addr=0xA0000000; 
            fi
        fi
    done
done < $esp_config

num_pbs=$(cd $1/socs/$2/partial_bitstreams && (ls | wc -l));
pbs_addr=$pbs_base_addr;
pbs_path=$1/socs/$2/partial_bitstreams;
        
    for FILE in $pbs_path/*; do
        pbs_name=$(basename $FILE);
        pbs_size=$(echo `ls -ls $FILE` | awk '{print($6)}'); 
        $1/socs/$2/socgen/esp/esplink --load -a $pbs_addr  -i $1/socs/$2/partial_bitstreams/$pbs_name;
        pbs_base_addr=$pbs_addr;
        pbs_addr=$(($pbs_base_addr + $pbs_size + $PBS_DDR_OFFSET));
    done
}

#This function parses the synthesis reports of accelerators to extract their resource requirements
function parse_synth_report() {
synth_report_base=$1/socs/$2/vivado_dpr/Synth;
flora_input=$1/socs/$2/flora_input.csv;

lut_keyword=LUTs*;
bram_keyword=Block;
dsp_keyword=""DSPs;

LUT_TOLERANCE=700;
BRAM_TOLERANCE=20;
DSP_TOLERANCE=20;

echo -e "\t DPR: Parsing synthesis report";
for ((i=0; i<$num_acc_tiles; i++))
do
    while read line
    do
    lut_match=$(echo ${line} | awk '{print($3)}'); 
    dsp_match=$(echo ${line} | awk '{print($2)}'); 
    bram_match=$(echo ${line} | awk '{print($2)}');

    if [[ "$lut_match" == "$lut_keyword" ]]; then
        lut=$(echo ${line} | awk '{print($5)}');
        clb=$((($lut / 8) + LUT_TOLERANCE));
        res_consumption["$i,0"]=$clb;
        #echo "found one $lut $clb";
    fi;
   
    #TODO this should be for DSP matching for VCU118 and VCu128
    #if [[ "$dsp_aux_match" == "$dsp_keyword" ]] && [[ $dsp_match == "DSP48E2" ]]; then
    #    dsp=$(echo ${dsp_line} | awk '{print($4)}');
    #    dsp=$((dsp + DSP_TOLERANCE ));
    #    res_consumption["$i,2"]=$dsp;
    #    #echo "found one $dsp";
    #fi;
    
    if [[ "$dsp_match" == "$dsp_keyword" ]]; then
        dsp=$(echo ${line} | awk '{print($4)}');
        dsp=$((dsp + DSP_TOLERANCE ));
        res_consumption["$i,2"]=$dsp;
        #echo "found one $dsp";
    fi;
    
    if [[ "$bram_aux_match" == "$bram_keyword" ]] && [[ $bram_match == "RAMB36/FIFO*" ]]; then
        bram=$(echo ${bram_line} | awk '{print($6)}');
        #bram=$(bram%.*);
        bram=$(echo $bram $BRAM_TOLERANCE | awk '{print $1 + $2}');
        res_consumption["$i,1"]=$bram;
        #echo "found one $bram";
    fi; 
    
    dsp_aux_match=$dsp_match;
    dsp_line=$line;
    bram_aux_match=$bram_match;
    bram_line=$line;
    done < $synth_report_base/${new_accelerators[$i,1]}/acc_top_utilization_synth.rpt;
done

for ((i=0; i<$num_acc_tiles; i++))
do
    if [[ "$i" == "0" ]]; then
        echo ${res_consumption["$i,0"]}, ${res_consumption["$i,1"]}, ${res_consumption["$i,2"]}, esp_1/tiles_gen[${new_accelerators[$i,0]}].accelerator_tile.tile_acc_i/tile_acc_1/acc_top_inst, ${new_accelerators[$i,0]} > $flora_input;
    else
        echo ${res_consumption["$i,0"]}, ${res_consumption["$i,1"]}, ${res_consumption["$i,2"]}, esp_1/tiles_gen[${new_accelerators[$i,0]}].accelerator_tile.tile_acc_i/tile_acc_1/acc_top_inst, ${new_accelerators[$i,0]} >> $flora_input;
    fi;
done
}

function gen_floorplan() {
    src_dir=$1/socs/$2;
    fplan_dir=$1/socs/common/dpr_tools/dpr_floor_planner;

    #TODO:type of FPGA must be a variable of $2
    cd $fplan_dir;
    make flora FPGA=VC707;
    ./bin/flora $num_acc_tiles  $1/socs/$2/flora_input.csv $1/socs/$2/res_reqs.csv;
    cp pblocks.xdc $1/constraints/$2/;
    cd $src_dir;
}

function acc_fplan() {
res_req_new=$1/socs/$2/res_reqs.csv;
res_req_old=$1/socs/$2/vivado_dpr/res_reqs.csv;
regenerate_fplan=0;

    for((i=0; i<$num_modified_acc_tiles; i++))
    do
        while read line
        do
            lut_new=$(echo ${line} | awk -F'[, ]' '{print($1)}');
            bram_new=$(echo ${line} | awk -F'[, ]' '{print($3)}');
            dsp_new=$(echo ${line} | awk -F'[, ]' '{print($5)}');
            tile_id_new=$(echo ${line} | awk -F'[, ]' '{print($9)}');
            while read line2
            do
                lut_old=$(echo ${line2} | awk -F'[, ]' '{print($1)}');
                bram_old=$(echo ${line2} | awk -F'[, ]' '{print($3)}');
                dsp_old=$(echo ${line2} | awk -F'[, ]' '{print($5)}');
                tile_id_old=$(echo ${line2} | awk -F'[, ]' '{print($9)}');
                if [[ "$tile_id_new" == "$tile_id_old" ]]; then
                    if [[ "${lut_new%%.*}" -gt "${lut_old%%.*}" ]] || [[ "${bram_new%%.*}" -gt "${bram_old%%.*}" ]] || [[ "${dsp_new%%.*}" -gt "${dsp_old%%.*}" ]]; then
                        regenerate_fplan=1;
                        break;    
                    fi;
                fi;
            done < $res_req_old;
        done < $res_req_new;
    done 

}

if [ "$4" == "BBOX" ]; then
    extract_acc $1 $2 $3 
    initialize_acc_tiles $1 $2 $3
    initialize_bbox_tiles $1 $2 $3

elif [ "$4" == "DPR" ]; then 
    extract_acc $1 $2 $3
    initialize_acc_tiles $1 $2 $3
    add_acc_prj_file $1 $2 $3
    gen_synth_script $1 $2 $3 $4

elif [ "$4" == "IMPL_DPR" ]; then 
    extract_acc $1 $2 $3
    initialize_acc_tiles $1 $2 $3
    add_acc_prj_file $1 $2 $3
    parse_synth_report $1 $2 $3 $4
    gen_floorplan $1 $2 $3 $4
    gen_impl_script $1 $2 $3 $4

    #gen_dpr $1 $2 $3 $4
elif [ "$4" == "ACC" ]; then
    extract_acc $1 $2 $3; 
    extract_acc_old $1 $2 $3; 
    diff_accelerators $1 $2 $3; 
    initialize_acc_tiles $1 $2 $3
    add_acc_prj_file $1 $2 $3
    gen_synth_script $1 $2 $3 $4

    #gen_fplan $1 $2 $3
    #gen_dpr $1 $2 $3 $4;

elif [ "$4" == "IMPL_ACC" ]; then
    extract_acc $1 $2 $3; 
    extract_acc_old $1 $2 $3; 
    diff_accelerators $1 $2 $3; 
    initialize_acc_tiles $1 $2 $3;
    patch_acc_devid $1 $2 $3 $4;
    add_acc_prj_file $1 $2 $3;
    parse_synth_report $1 $2 $3 $4;
    acc_fplan $1 $2 $3 $4;
    if [ "$regenerate_fplan" == "1" ]; then
        gen_floorplan $1 $2 $3 $4;      
    fi;
    gen_impl_script $1 $2 $3 $4;
   
elif [ "$4" == "GEN_BS" ]; then
    extract_acc $1 $2 $3; 
    extract_acc_old $1 $2 $3; 
    diff_accelerators $1 $2 $3; 
    gen_bs_script $1 $2 $3 $4;

elif [ "$4" == "GEN_HDR" ]; then
    extract_acc $1 $2 $3
    gen_bs_descriptor $1 $2 $3 $4
     
elif [ "$4" == "LOAD_BS" ]; then
    load_bs $1 $2 $3 $4

elif [ $4 == "test" ]; then
    extract_acc $1 $2 $3
    #extract_acc_old $1 $2 $3
    #diff_accelerators $1 $2 $3 
    #patch_acc_devid $1 $2 $3 $4
    #gen_bs_script $1 $2 $3 $4 
    #gen_bs_descriptor $1 $2 $3 $4
    #load_bs $1 $2 $3 $4
    initialize_acc_tiles $1 $2 $3
    #add_acc_prj_file $1 $2 $3
    #gen_synth_script $1 $2 $3 $4
    #gen_fplan $1 $2 $3;
    #echo " regenarate before parse is $regenerate_fplan";
    parse_synth_report $1 $2 $3 $4
    gen_floorplan $1 $2 $3 $4;
    #acc_fplan $1 $2 $3 $4;
    #echo " regenarate after parse is $regenerate_fplan";
    #gen_floorplan $1 $2 $3 $4
fi;
