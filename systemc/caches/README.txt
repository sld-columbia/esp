=========================================================
 ESP CACHES
---------------------------------------------------------
 Author: Davide Giri
---------------------------------------------------------
 Description: L2 private cache and LLC with directory
   implementing the MESI directory protocol. They are 
   written in SystemC and HLS is performed with Stratus.
=========================================================

--------------
Repo Structure
--------------

- accelerators/ tech/ utils/
  The content these 3 folders is taken as is from ESP. These are all the files in ESP that the caches framework needs. The folders structure is also the same as in ESP, so that this work can be added directly into ESP without modifications.

- caches/ 
  This is the folder containing the caches, their testbench and the whole framework to perform HLS and simulation. This is what will be added to ESP.
    
    - common/
    - l2/
        - stratus/
	- src/
	- tb/
	- memlist.txt

-----------
memlist.txt
-----------

There is a default memlist.txt pushed for both l2 and llc caches. It accounts for 2 CPUs, 256 sets and 8 ways in the l2 cache. If any of these parameters are changes in caches/common/lib/cache_consts.hpp memlist.txt must be updated. N_CPU (together with N_CPU_BITS and N_CPU_LOG2), SET_BITS and L2_WAYS_BITS are the only parameters to be modified. BEWARE: the minimum is N_CPU=2, SET_BITS=1 and L2_WAYS_BITS=1. After cache_consts.hpp has been modified memlist.txt can be updated by running 2 scripts: caches/l2/memlist_gen.sh, caches/llc/memlist_gen.sh.
