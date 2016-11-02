setPreference -pref UserLevel:NOVICE
setPreference -pref MessageLevel:DETAILED
setPreference -pref ConcurrentMode:FALSE
setPreference -pref UseHighz:FALSE
setPreference -pref ConfigOnFailure:STOP
setPreference -pref StartupCLock:AUTO_CORRECTION
setPreference -pref AutoSignature:FALSE
setPreference -pref KeepSVF:FALSE
setPreference -pref svfUseTime:FALSE
setPreference -pref UserLevel:NOVICE
setPreference -pref MessageLevel:DETAILED
setPreference -pref ConcurrentMode:FALSE
setPreference -pref UseHighz:FALSE
setPreference -pref ConfigOnFailure:STOP
setPreference -pref StartupCLock:AUTO_CORRECTION
setPreference -pref AutoSignature:FALSE
setPreference -pref KeepSVF:FALSE
setPreference -pref svfUseTime:FALSE
setMode -bs
setCable -port auto
Identify
attachflash -position 1 -bpi "28F00AG18F"
assignfiletoattachedflash -position 1 -file "xilinx-vc707-xc7vx485t.mcs"
Program -p 1 -dataWidth 16 -rs1 25 -rs0 24 -bpionly -e -loadfpga
setMode -pff
setMode -sm
setMode -bs
deleteDevice -position 1
setMode -bs
setMode -sm
setMode -dtconfig
setMode -cf
setMode -mpm
setMode -pff
setMode -bs
setMode -bs
quit