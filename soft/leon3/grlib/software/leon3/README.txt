========================
CUSTOM CACHE TESTS:
========================

------------------------------------------------------------------------------------------------------------
Naming convention for tests: 

*_sp -> single processor test
*_mp -> multi processor test
*_flush -> contains flush statements at random places

All tests support any cache configuration for L2 and LLC
All multiprocessor tests support upto 16 cpus
------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------
Test_file_name and function descriptions:

defines.h 			: Contains all the necessary parameters which form the basis of
					  all tests. The parameters are self explanatory

rand_rw.c 			: Contains 2 functions (_sp & _mp) which perform reads and writes 
					  for 100 random cacheable locations. Address locations do not overlap
			          for different processors in multi processor test
			
false_sharing.c		: (Only for multi processor scenario) Different CPUs modify different
					  locations in the same cache line causing invalidations. The test
					  does false sharing checks on all sets and ways of L2 cache.
					  
Cache_evictions.c   : l2_fill_evict_single_set,-> modifies all ways in a given set, evicts
					  llc_fill_evict_single_set	  data from cache and checks if data is properly
												  stored in memory. Does not modify all the 
												  locations in a cache line
												  
					  l2_fill_evict,		   -> Modifies all ways in all the sets, evicts
					  llc_fill_evict			  data from cache and checks if data is properly
												  stored in memory. Fills all ways in a set and 
												  then moves to the next set.
												  
					  evict                    -> Function used to evict a pointer from all the 
												  caches. Works for any cache replacement policy.
					  
					  The file contains different scenarios of the above mentioned tests
					  (Total number of functions in file = 16)

L2_cache.c 			: L2_cache_fill,		   -> The sets are filled first and then the ways are
					  LLC_cache_fill			  modified. Modifies and checks each and every
												  cache location.
												
Comprehensive_test.c: databus_test,			   -> Checks if all the bits of the address and data bus
					  addressbus_test			  can be set and reset. Avoids address location overlap
												  and corrupt data. Although the correctness of the 
												  bus is a given, it is a good test to have.
					  
					  cache_test               -> Checks if each bit in every cacheable location can 
												  be set and reset. Captures most corner case bugs in
												  single CPU scenarios.
					  
					  MESI_protocol test       -> Tests all transitions in MESI protocol FSM for 
												  all cacheable locations and for all CPUs. Should
												  capture most corner case bugs.

Combined_test.c 	: Contains a test which calls all the above mentioned tests stressing the caches
					  as much as possible. Prints out the results of every test once they are executed.

------------------------------------------------------------------------------------------------------------
												

