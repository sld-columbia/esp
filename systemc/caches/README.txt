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
