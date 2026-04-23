#echo "Restarting simulation with SDF annotation for DCO and delay line"
set sdf ""
set TECHLIB $::env(TECHLIB)
set ESP_ROOT $::env(ESP_ROOT)
set VSIMOPT $::env(VSIMOPT)

#####################################################################
# Uncomment this block of code for RTL simulation using DCO clocking#
#####################################################################
#foreach inst [find instances -nodu -bydu DCO] {
#    append sdf "-sdfmax "
#    append sdf [string map {( [} [string map {) ]} $inst]]
#    append sdf "=${ESP_ROOT}/rtl/techmap/asic/dco/DCO_tt.sdf "
#}
#append sdf "-suppress 3438"
#####################################################################
# End block of code                                                 #
#####################################################################

eval vsim $sdf $VSIMOPT
