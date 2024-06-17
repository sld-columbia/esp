#echo "Restarting simulation with SDF annotation for DCO and delay line"
set sdf ""
set TECHLIB $::env(TECHLIB)
set ESP_ROOT $::env(ESP_ROOT)
set VSIMOPT $::env(VSIMOPT)
#foreach inst [find instances -nodu -bydu DCO] {
#    append sdf "-sdfmax "
#    append sdf [string map {( [} [string map {) ]} $inst]]
#    append sdf "=${ESP_ROOT}/rtl/techmap/${TECHLIB}/dco_wrappers/DCO_tt.sdf "
#}
#append sdf "-suppress 3438"
eval vsim $sdf $VSIMOPT
