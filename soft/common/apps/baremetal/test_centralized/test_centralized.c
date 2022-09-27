#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define CRR

#ifdef CP
	#include "test_cp.h"
#endif

#ifdef CRR
	#include "test_crr.h"
#endif

int main(int argc, char * argv[])
{

	unsigned int sum_max = 0;
	unsigned int tot_activity = 0;
	unsigned int step=0;
	unsigned int finished_tiles = 0;
	unsigned int runstep=0;

	int i, tempval ;
	for (i=0; i<N_ACC; i++)
	{
		start_tile(i);
		tot_activity += activity[i];
	}

	//while (finished_tiles < N_ACC)
	//{
		tot_activity = 0;
		while((head_run != NULL) ||(head_idle != NULL) ||(head_wait != NULL) ) {
			finished_tiles = 0;
			check_tile(runstep);
			printf("Tiles completed: ");
			for (i=0; i<N_ACC; i++)
			{
				printf ("%d\t", tile_complete[i]);
				finished_tiles += tile_complete[i];
			}
			printf ("\n");
			runstep++;
			printf("Run step: %d, Finished tiles: %d\n", runstep, finished_tiles);
		}
		
	//}
	return 0;
}
