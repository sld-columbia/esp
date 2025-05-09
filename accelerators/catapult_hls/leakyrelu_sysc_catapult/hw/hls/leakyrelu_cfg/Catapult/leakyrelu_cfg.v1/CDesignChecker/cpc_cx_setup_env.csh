#! /bin/csh -f
setenv SYSTEMC_HOME /opt/Catapult_2025/Mgc_home/shared
setenv SYSTEMC_LIB_DIR /opt/Catapult_2025/Mgc_home/shared/lib
setenv CXX_FLAGS "-g -DCALYPTO_SKIP_SYSTEMC_VERSION_CHECK"
setenv LD_FLAGS "-lpthread"
setenv OSSIM ddd
setenv PATH /opt/Catapult_2025/Mgc_home/bin:$PATH
