set sdf ""
set TECHLIB $::env(TECHLIB)
set ESP_ROOT $::env(ESP_ROOT)
set VSIMOPT $::env(VSIMOPT)
if {$TECHLIB=="gf12"} {
    echo "Restarting simulation with SDF annotation for GF12 DCO and delay line"
    foreach inst [find instances -nodu -bydu DCO_GF12_C14] {
	append sdf "-sdfmax "
	append sdf [string map {( [} [string map {) ]} $inst]]
	append sdf "=${ESP_ROOT}/rtl/techmap/${TECHLIB}/wrappers/DCO_tt.sdf "
    }
    append sdf "-suppress 3438"
    eval vsim $sdf $VSIMOPT
}
