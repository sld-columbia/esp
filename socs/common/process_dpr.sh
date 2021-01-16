#!/bin/bash

# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

#variables related to srcs of accelerators
tile_acc="$1/socs/$2/sldgen/tile_acc.vhd"
dpr_srcs="$1/socs/$2/sldgen/dpr_srcs"
dpr_bbox="$dpr_srcs/tile_acc_bbox.vhd"
original_src="$1/socs/$2/vivado/srcs.tcl"
temp_srcs="/tmp/temp_srcs.tcl"
esp_config="$1/socs/$2/./socgen/esp/.esp_config"
esp_config_old="$1/socs/$2/vivado_dpr/.esp_config"
tcl_dir="$1/socs/common/dpr_tools/Tcl"

#variables related to accelerator tiles
num_acc_tiles=0
num_old_acc_tiles=0
num_modified_acc_tiles=0
regenerate_fplan=0;

DEVICE=$3
device=$(echo ${DEVICE} | awk '{print tolower($0)}')
acc_id_match="this_hls_conf      : hlscfg_t"
declare -A new_accelerators old_accelerators modified_accelerators
declare -A res_consumption

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
            #echo "$tile_token $tile_index $tile_type $acc_name $1 $2 $3 ";
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
#            echo $tile_token $tile_index $tile_type $acc_name $1 $2 $3;
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
    if [ ${new_accelerators[$i,1]} != ${old_accelerators[$i,1]} ]; then
        modified_accelerators[$num_modified_acc_tiles,0]=${new_accelerators[$i,0]};
        modified_accelerators[$num_modified_acc_tiles,1]=${new_accelerators[$i,1]};
        ((num_modified_acc_tiles++));
    fi
       
done 

    echo -e "\t DPR: number modified tiles is equal to $num_modified_acc_tiles "
}

#This function initializes the specific accelerator tiles from the template tile_acc.vhd
#initialization refers to replacing the default parameters of the template acc with 
#acc specific parameters
function initialize_acc_tiles() {
for ((i=0; i<$num_acc_tiles; i++))
do
    skip_params=0;
    acc_dir="$dpr_srcs/tile_${new_accelerators[$i,0]}_acc";
    mkdir -p $acc_dir;
    echo " " > $acc_dir/tile_acc_$i.vhd;

    while read acc_src
    do
        if [[ $acc_src == *"$acc_id_match"*  ]]; then
            #echo "  tile_id : integer range 0 to CFG_TILES_NUM - 1 := ${new_accelerators[$i,0]});" >> $acc_dir/tile_acc_$i.vhd;
            echo "  this_hls_conf      : hlscfg_t             := tile_design_point(${new_accelerators[$i,0]});" >> $acc_dir/tile_acc_$i.vhd;
            echo "  this_device        : devid_t  := tile_device(${new_accelerators[$i,0]});" >> $acc_dir/tile_acc_$i.vhd;
            echo "  this_irq_type      : integer  := tile_irq_type(${new_accelerators[$i,0]});">> $acc_dir/tile_acc_$i.vhd;             
            echo "  this_has_l2        : integer range 0 to 1 := tile_has_l2(${new_accelerators[$i,0]});">> $acc_dir/tile_acc_$i.vhd;             
            echo "  this_has_dvfs      : integer range 0 to 1 := tile_has_dvfs(${new_accelerators[$i,0]});">> $acc_dir/tile_acc_$i.vhd;             
            echo "  this_has_pll       : integer range 0 to 1 := tile_has_pll(${new_accelerators[$i,0]});">> $acc_dir/tile_acc_$i.vhd;             
            echo "  this_has_dco       : integer range 0 to 1 := 0;">> $acc_dir/tile_acc_$i.vhd;
            echo "  this_extra_clk_buf : integer range 0 to 1 := extra_clk_buf(${new_accelerators[$i,0]});">> $acc_dir/tile_acc_$i.vhd;             
            echo "  test_if_en         : integer range 0 to 1 := 0;">> $acc_dir/tile_acc_$i.vhd;
            echo "  ROUTER_PORTS       : ports_vec            := set_router_ports(CFG_FABTECH, CFG_XLEN, CFG_YLEN, tile_x(${new_accelerators[$i,0]}),tile_y(${new_accelerators[$i,0]}));">> $acc_dir/tile_acc_$i.vhd;             
            echo "  HAS_SYNC           : integer range 0 to 1 := CFG_HAS_SYNC);">> $acc_dir/tile_acc_$i.vhd;             
            skip_params=10;
        elif [[ $skip_params -ne 0 ]]; then
            skip_params=$((skip_params-1));
        else
            echo "  $acc_src" >> $acc_dir/tile_acc_$i.vhd;
        fi
    done <$tile_acc
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
    if [[ $src_list == *"tile_acc.vhd" ]]; then
        echo "read_vhdl $1/socs/$2/sldgen/dpr_srcs/tile_acc_bbox.vhd" >> $temp_srcs;
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
    acc_dir="$dpr_srcs/tile_${new_accelerators[$i,0]}_acc";
    #acc_dir="$dpr_srcs/accelerator_$i";
    output="$acc_dir/src.prj"

echo " " > $output
while read -r type ext addr
do
    if [[ "$ext" == *"tile_acc.vhd"* ]] || [[ "$ext" == *"tile_acc_bbox.vhd"* ]]; then
        echo "vhdl xil_defaultlib $acc_dir/tile_acc_$i.vhd" >> $output;
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

#generate flooplan
#This is a simplistic floorplanner. It simply stacks 1 clock region wide pblocks
#on top of eachother. For few number of acc tiles, this should not cause any violation, 
#except errors related to lack of enough resources in the pblock. Eventually this simple 
#floorplanner needs to be replaced with a more agressive floorplanner customized for each
#FPGA.
function gen_fplan() {
fplan_pblock="$1/constraints/$2/pblocks_dpr.xdc";

slice_start_y_default=0;
bram36_start_y_default=0;
bram18_start_y_default=0;
dsp_start_y_default=0;

slice_start_x=10;
slice_start_y=0;
slice_width=119;
slice_height=100;
bram36_start_x=1;
bram36_start_y=0;
bram36_width=8;
bram36_height=20;
bram18_start_x=1;
bram18_start_y=0;
bram18_height=40;
bram18_width=8;
dsp_start_x=1;
dsp_start_y=0;
dsp_width=8;
dsp_height=40;
threshold=400;

slice_start_y_vc707=0;
slice_height_vc707=50;
bram36_start_y_vc707=0;
bram36_height_vc707=10;
bram18_start_y_vc707=0;
bram18_height_vc707=20;
dsp_start_y_vc707=0;
dsp_height_vc707=20;
threshold_vc707=350;

slice_start_y_vc118=0;
slice_height_vc118=60;
bram36_start_y_vc118=0;
bram36_height_vc118=12;
bram18_start_y_vc118=0;
bram18_height_vc118=24;
dsp_start_y_vc118=0;
dsp_height_vc118=24;
threshold_vc118=480;

slice_start_y_vc128=60;
slice_height_vc128=60;
bram36_start_y_vc128=12;
bram36_height_vc128=12;
bram18_start_y_vc128=24;
bram18_height_vc128=24;
dsp_start_y_vc128=18;
dsp_height_vc128=24;
threshold_vc128=540;

echo " " > $fplan_pblock;

if [ "$2" == "xilinx-vcu128-xcvu37p" ]; then
    slice_start_y=$slice_start_y_vc128;
    slice_start_y_default=$slice_start_y_vc128;
    slice_height=$slice_height_vc128;
    bram36_start_y=$bram36_start_y_vc128;
    bram36_start_y_default=$bram36_start_y_vc128;
    bram36_height=$bram36_height_vc128;
    bram18_start_y=$bram18_start_y_vc128;
    bram18_start_y_default=$bram18_start_y_vc128;
    bram18_height=$bram18_height_vc128;
    dsp_start_y=$dsp_start_y_vc128;
    dsp_start_y_default=$dsp_start_y_vc128;
    dsp_height=$dsp_height_vc128;
    threshold=$threshold_vc128;

elif [ "$2" == "xilinx-vcu118-xcvu9p" ]; then
    slice_start_y=$slice_start_y_vc118;
    slice_start_y_default=$slice_start_y_vc118;
    slice_height=$slice_height_vc118;
    bram36_start_y=$bram36_start_y_vc118;
    bram36_start_y_default=$bram36_start_y_vc118;
    bram36_height=$bram36_height_vc118;
    bram18_start_y=$bram18_start_y_vc118;
    bram18_start_y_default=$bram18_start_y_vc118;
    bram18_height=$bram18_height_vc118;
    dsp_start_y=$dsp_start_y_vc118;
    dsp_start_y_default=$dsp_start_y_vc118;
    dsp_height=$dsp_height_vc118;
    threshold=$threshold_vc128;

elif [ "$2" == "xilinx-vc707-xc7vx485t" ]; then
    slice_start_y=$slice_start_y_vc707;
    slice_start_y_default=$slice_start_y_vc707;
    slice_height=$slice_height_vc707;
    bram36_start_y=$bram36_start_y_vc707;
    bram36_start_y_default=$bram36_start_y_vc707;
    bram36_height=$bram36_height_vc707;
    bram18_start_y=$bram18_start_y_vc707;
    bram18_start_y_default=$bram18_start_y_vc707;
    bram18_height=$bram18_height_vc707;
    dsp_start_y=$dsp_start_y_vc707;
    dsp_start_y_default=$dsp_start_y_vc707;
    dsp_height=$dsp_height_vc707;
    threshold=$threshold_vc707;

fi;

for ((i=0; i<$num_acc_tiles; i++))
do
    echo "set_property HD.RECONFIGURABLE true [get_cells esp_1/tiles_gen[${new_accelerators["$i,0"]}].accelerator_tile.tile_acc_i]" >> $fplan_pblock;
    echo "create_pblock pblock_$i" >> $fplan_pblock;
    echo "add_cells_to_pblock [get_pblocks pblock_$i] [get_cells -quiet [list esp_1/tiles_gen[${new_accelerators["$i,0"]}].accelerator_tile.tile_acc_i]]" >> $fplan_pblock;
    echo "resize_pblock [get_pblocks pblock_$i] -add {SLICE_X"$slice_start_x"Y"$slice_start_y":SLICE_X"$(($slice_start_x+$slice_width))"Y"$((slice_start_y+$slice_height-1))"}" >> $fplan_pblock;
    echo "resize_pblock [get_pblocks pblock_$i] -add {RAMB18_X"$bram18_start_x"Y"$bram18_start_y":RAMB18_X"$(($bram18_start_x+$bram18_width))"Y"$(($bram18_start_y+$bram18_height-1))"}" >> $fplan_pblock;
    echo "resize_pblock [get_pblocks pblock_$i] -add {RAMB36_X"$bram36_start_x"Y"$bram36_start_y":RAMB36_X"$(($bram36_start_x+$bram36_width))"Y"$(($bram36_start_y+$bram36_height-1))"}" >> $fplan_pblock;
    if [ "$2" == "xilinx-vcu118-xcvu9p" ] || [ "$2" == "xilinx-vcu128-xcvu37p" ]; then 
    echo "resize_pblock [get_pblocks pblock_$i] -add {DSP48E2_X"$dsp_start_x"Y"$dsp_start_y":DSP48E2_X"$(($dsp_start_x+$dsp_width))"Y"$(($dsp_start_y+$dsp_height-1))"}" >> $fplan_pblock;
    else 
    echo "resize_pblock [get_pblocks pblock_$i] -add {DSP48_X"$dsp_start_x"Y"$dsp_start_y":DSP48_X"$(($dsp_start_x+$dsp_width))"Y"$(($dsp_start_y+$dsp_height-1))"}" >> $fplan_pblock;
    fi;
    echo "set_property RESET_AFTER_RECONFIG true [get_pblocks pblock_$i]" >> $fplan_pblock;
    echo "set_property SNAPPING_MODE ON [get_pblocks pblock_$i]" >> $fplan_pblock;
    echo "set_property SEVERITY {Warning} [get_drc_checks NSTD-1]" >> $fplan_pblock;
    echo "set_property SEVERITY {Warning} [get_drc_checks UCIO-1]" >> $fplan_pblock;

    if [ $slice_start_y -ge $(($threshold-$slice_height-1)) ]; then 
        slice_start_y=$slice_start_y_default;
        slice_start_x=$(($slice_start_x+$slice_width+1));
        bram18_start_y=$bram18_start_y_default;
        bram18_start_x=$(($bram18_start_x+$bram18_width+1));\
        bram36_start_y=$bram36_start_y_default;\
        bram36_start_x=$(($bram36_start_x+$bram36_width+1));\
        dsp_start_y=$dsp_start_y_default;\
        dsp_start_x=$(($dsp_start_x+$dsp_width+1)); \
    else
        slice_start_y=$(($slice_start_y+$slice_height));
        #bram18_start_x=$(($bram18_start_x+$bram18_width));
        bram18_start_y=$(($bram18_start_y+$bram18_height));
        #bram36_start_x=$(($bram36_start_x+$bram36_width));
        bram36_start_y=$(($bram36_start_y+$bram36_height));
        #dsp_start_x=$(($dsp_start_x+$dsp_width));
        dsp_start_y=$(($dsp_start_y+$dsp_height));
    fi;
   # echo "slice y  $slice_start_y ";
done
}


#generate the tcl script to synthesise and implement the design
function gen_synth_script() {

syn_include="$tcl_dir/synth_include.tcl";
rm -rf $syn_include;
echo "set_property include_dirs {" >> $syn_include;
echo "$1/socs/$2 " >> $syn_include;
echo "$1/rtl/src/sld/caches/esp-caches/common/defs" >> $syn_include;
echo "$1/third-party/accelerators/dma64/NV_NVDLA/vlog_incdir" >> $syn_include;
echo "$1/third-party/ariane/src/common_cells/include" >> $syn_include;
echo "$1/third-party/ibex/vendor/lowrisc_ip/prim/rtl" >> $syn_include;
echo "} [current_fileset]" >> $syn_include;

#generate the imlementation script
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
echo "set_attribute module \$static synth         \${run.topSynth} " >> $dpr_syn_tcl;


echo "####################################################################" >> $dpr_syn_tcl;
echo "### RP Module Definitions " >> $dpr_syn_tcl;
echo "#################################################################### " >> $dpr_syn_tcl;

echo -e "\t DPR: number of acc tiles inside dpr gen is $num_acc_tiles ";
if [[ "$4" == "DPR" ]]; then
    for ((i=0; i<num_acc_tiles; i++))
    do
        acc_dir="$dpr_srcs/tile_${new_accelerators[$i,0]}_acc";
        #acc_dir="$dpr_srcs/accelerator_$i";
        prj_src="$acc_dir/src.prj"
        echo "add_module ${new_accelerators[$i,1]} " >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} moduleName tile_acc" >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} prj $prj_src" >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} synth  \${run.rmSynth}" >> $dpr_syn_tcl;
    done
elif [[ "$4" == "ACC" ]] && [[ "$num_modified_acc_tiles" != "0" ]]; then
    for ((i=0; i<$num_acc_tiles; i++))
    do
        acc_dir="$dpr_srcs/tile_${new_accelerators[$i,0]}_acc";
        #acc_dir="$dpr_srcs/accelerator_$i";
        prj_src="$acc_dir/src.prj"
        echo "add_module ${new_accelerators[$i,1]} " >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} moduleName tile_acc" >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} prj $prj_src" >> $dpr_syn_tcl;
        if [[ ${modified_accelerators[$i,0]} == ${new_accelerators[$i,0]} ]]; then
            echo "set_attribute module ${new_accelerators[$i,1]} synth  \${run.rmSynth}" >> $dpr_syn_tcl;
        fi;
    done
fi;

echo "source \$tclDir/run.tcl" >> $dpr_syn_tcl;
echo "exit" >> $dpr_syn_tcl;
}


#generate the tcl script to synthesise and implement the design
function gen_impl_script() {
syn_include="$tcl_dir/synth_include.tcl"; #"$1/socs/common/Tcl/synth_include.tcl";
rm -r $syn_include;
echo "set_property include_dirs {" >> $syn_include;
echo "$1/socs/$2 " >> $syn_include;
echo "$1/rtl/src/sld/caches/esp-caches/common/defs" >> $syn_include;
echo "$1/third-party/accelerators/dma64/NV_NVDLA/vlog_incdir" >> $syn_include;
echo "$1/third-party/ariane/src/common_cells/include" >> $syn_include;
echo "$1/third-party/ibex/vendor/lowrisc_ip/prim/rtl" >> $syn_include;
echo "} [current_fileset]" >> $syn_include;

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
        acc_dir="$dpr_srcs/tile_${new_accelerators[$i,0]}_acc";
        #acc_dir="$dpr_srcs/accelerator_$i";
        prj_src="$acc_dir/src.prj"
        echo "add_module ${new_accelerators[$i,1]} " >> $dpr_syn_tcl;
        echo "set_attribute module ${new_accelerators[$i,1]} moduleName tile_acc" >> $dpr_syn_tcl;
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
    echo "set_attribute impl top_dpr implXDC     [list [ list $1/constraints/$2/pblocks_dpr.xdc $1/constraints/$2/$2.xdc $1/constraints/$2/$2-eth-constraints.xdc $1/constraints/$2/$2-eth-pins.xdc  $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/mig/par/mig.xdc $1/constraints/$2/$2-mig-pins.xdc $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/sgmii/synth/sgmii.xdc ] ]" >> $dpr_syn_tcl;
elif [[ $2 == "xilinx-vcu128-xcvu37p" ]]; then
echo "set_attribute impl top_dpr implXDC     [list [ list $1/constraints/$2/pblocks_dpr.xdc $1/constraints/$2/$2.xdc $1/constraints/$2/$2-eth-constraints.xdc $1/constraints/$2/$2-eth-pins.xdc  $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/mig_clamshell/par/mig_clamshell.xdc $1/constraints/$2/$2-mig-pins.xdc $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/sgmii_vcu128/synth/sgmii_vcu128.xdc ] ]" >> $dpr_syn_tcl;
else    
    echo "set_attribute impl top_dpr implXDC     [list [ list $1/constraints/$2/pblocks_dpr.xdc $1/constraints/$2/$2.xdc $1/constraints/$2/$2-eth-constraints.xdc $1/constraints/$2/$2-eth-pins.xdc  $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/mig/mig/user_design/constraints/mig.xdc $1/socs/$2/vivado/esp-$2.srcs/sources_1/ip/sgmii/synth/sgmii.xdc ] ]" >> $dpr_syn_tcl;
fi;
echo "set_property SEVERITY {Warning} [get_drc_checks HDPR-41]" >> $dpr_syn_tcl;

if [[ "$4" == "IMPL_DPR" ]]; then
    echo "set_attribute impl top_dpr partitions  [list [list \$static \$top  implement ] \\" >> $dpr_syn_tcl;
    for ((i=0; i<$num_acc_tiles; i++))
    do
        echo "[list ${new_accelerators[$i,1]}  esp_1/tiles_gen[${new_accelerators[$i,0]}].accelerator_tile.tile_acc_i implement ] \\" >>  $dpr_syn_tcl;
    done
    echo "]"  >> $dpr_syn_tcl;
elif [[ "$4" == "IMPL_ACC" ]] && [[ "$num_modified_acc_tiles" != "0" ]]; then
    echo "set_attribute impl top_dpr partitions  [list [list \$static \$top  import ] \\" >> $dpr_syn_tcl; 
    
    for ((i=0, j=0; j<$num_acc_tiles; j++))
    do
        if  [[ $regenerate_fplan == 1 ]]; then
            echo "[list ${new_accelerators[$i,1]}  esp_1/tiles_gen[${new_accelerators[$i,0]}].accelerator_tile.tile_acc_i implement ] \\" >>  $dpr_syn_tcl;

        elif [[ ${modified_accelerators[$i,0]} == ${new_accelerators[$i,0]} ]]; then
            echo "[list ${modified_accelerators[$i,1]}  esp_1/tiles_gen[${modified_accelerators[$i,0]}].accelerator_tile.tile_acc_i implement ] \\" >>  $dpr_syn_tcl;
            ((i++));
        else
            echo "[list ${new_accelerators[$j,1]}  esp_1/tiles_gen[${new_accelerators[$j,0]}].accelerator_tile.tile_acc_i import ] \\" >>  $dpr_syn_tcl;
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

echo "source \$tclDir/run.tcl" >> $dpr_syn_tcl;
echo "exit" >> $dpr_syn_tcl;
}

function parse_synth_report() {
synth_report_base=$1/socs/$2/vivado_dpr/Synth;
flora_input=$1/socs/$2/res_reqs.csv;

lut_keyword=LUTs*;
bram_keyword=Block;
dsp_keyword=""DSPs;

LUT_TOLERANCE=250;
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
    
    if [[ "$dsp_aux_match" == "$dsp_keyword" ]] && [[ $dsp_match == "DSP48E2" ]]; then
        dsp=$(echo ${dsp_line} | awk '{print($4)}');
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
    done < $synth_report_base/${new_accelerators[$i,1]}/tile_acc_utilization_synth.rpt;
done

for ((i=0; i<$num_acc_tiles; i++))
do
    if [[ "$i" == "0" ]]; then
        echo ${res_consumption["$i,0"]} , ${res_consumption["$i,1"]} , ${res_consumption["$i,2"]} , ${new_accelerators[$i,1]} , ${new_accelerators[$i,0]} > $flora_input;
    else
        echo ${res_consumption["$i,0"]} , ${res_consumption["$i,1"]} , ${res_consumption["$i,2"]} , ${new_accelerators[$i,1]} , ${new_accelerators[$i,0]} >> $flora_input;
    fi;
done
}

function gen_floorplan() {
    src_dir=$1/socs/$2;
    fplan_dir=$1/socs/common/dpr_tools/dpr_floor_planner;

    #TODO:type of FPGA must be a variable of $2
    cd $fplan_dir;
    make flora FPGA=VC707;
    ./bin/flora $num_acc_tiles $1/socs/$2/res_reqs.csv;
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
            lut_new=$(echo ${line} | awk '{print($1)}');
            bram_new=$(echo ${line} | awk '{print($3)}');
            dsp_new=$(echo ${line} | awk '{print($5)}');
            tile_id_new=$(echo ${line} | awk '{print($9)}');

            while read line2
            do
                lut_old=$(echo ${line2} | awk '{print($1)}');
                bram_old=$(echo ${line2} | awk '{print($3)}');
                dsp_old=$(echo ${line2} | awk '{print($5)}');
                tile_id_old=$(echo ${line2} | awk '{print($9)}');
                if [[ "$tile_id_new" == "$tile_id_old" ]]; then
                    if [[ "$lut_new" -gt "$lut_old" ]] || [[ "$bram_new" -gt "$bram_old" ]] || [[ "$dsp_new" -gt "$dsp_old" ]]; then
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
elif [ $4 == "ACC" ]; then
    extract_acc $1 $2 $3; 
    extract_acc_old $1 $2 $3; 
    diff_accelerators $1 $2 $3; 
    initialize_acc_tiles $1 $2 $3
    add_acc_prj_file $1 $2 $3
    gen_synth_script $1 $2 $3 $4

    #gen_fplan $1 $2 $3
    #gen_dpr $1 $2 $3 $4;

elif [ $4 == "IMPL_ACC" ]; then
    extract_acc $1 $2 $3; 
    extract_acc_old $1 $2 $3; 
    diff_accelerators $1 $2 $3; 
    initialize_acc_tiles $1 $2 $3;
    add_acc_prj_file $1 $2 $3;
    parse_synth_report $1 $2 $3 $4;
    acc_fplan $1 $2 $3 $4;
    if [ "$regenerate_fplan" == "1" ]; then
        gen_floorplan $1 $2 $3 $4;      
    fi;
    gen_impl_script $1 $2 $3 $4;
   

elif [ $4 == "test" ]; then
    extract_acc $1 $2 $3
    extract_acc_old $1 $2 $3
    diff_accelerators $1 $2 $3 
    initialize_acc_tiles $1 $2 $3
    #gen_fplan $1 $2 $3;
    echo " regenarate before parse is $regenerate_fplan";
    parse_synth_report $1 $2 $3 $4
    acc_fplan $1 $2 $3 $4;
    echo " regenarate after parse is $regenerate_fplan";
    #gen_floorplan $1 $2 $3 $4

fi;
