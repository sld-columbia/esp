#include "prc.h"
#include <stdio.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <libgen.h>



int prc_driver;

void load_bs(pbs_arg *pbs)
{
	if(ioctl(prc_driver, PRC_LOAD_BS, pbs)) {
		perror("Failed to write bitsream to driver");
		return;
	}

}

void reconfigure_fpga(pbs_arg *pbs)
{
	if(ioctl(prc_driver, PRC_RECONFIGURE, pbs)) {
		perror("Failed to write bitsream to driver");
		return;
	}

}

void decouple(decouple_arg *da)
{
	int ret;
	if((ret = ioctl(prc_driver, DECOUPLE, da)) != 0) {
		perror("Failed to write da to driver");
		return ret;;
	}

}

int main(int argc, char **argv)
{
	static const char filename[] = "/dev/prc";
	pbs_arg pbs;
	decouple_arg da = {};

	int tile_id = 0;
	int pbs_fd = {0};
	struct stat sb;



	if ((prc_driver = open(filename, O_RDWR)) == -1) {
		fprintf(stderr, "Unable to open device %s\n", filename);
		return -1;
	}

	if(strcmp(argv[1], "load") && strcmp(argv[1], "unload") && 
	   strcmp(argv[1], "couple") && strcmp(argv[1], "decouple") &&
	   strcmp(argv[1], "reconf")) 
	{
		fprintf(stderr, "Invalid command: %s\n", argv[1]);
		return -1;
	}

	if(argv[2][0] >= '0' && argv[2][0] <= '9') {
		tile_id = atoi(argv[2]);
	} else {
		fprintf(stderr, "Invalid tile id");
		return -1;
	}

	if(!strcmp(argv[1], "decouple")) {
		da.tile_id = tile_id;
		da.status = 1;
		decouple(&da);
		return 0;
	}

	if(!strcmp(argv[1], "couple")) {
		da.tile_id = tile_id;
		da.status = 0x0;
		decouple(&da);
		return 0;
	}

	strcpy(pbs.name, argv[3]);
	strcpy(pbs.driver, argv[4]);

	pbs.pbs_tile_id = atoi(argv[2]);

	if(!strcmp(argv[1], "load")) {
		if ((pbs_fd = open(argv[3], O_RDONLY)) == -1) {
			fprintf(stderr, "Unable to open %s\n", argv[2]);
			return -1;
		}
		fstat(pbs_fd, &sb);
		pbs.pbs_size = sb.st_size;

		pbs.pbs_mmap = mmap(NULL, sb.st_size, PROT_READ, MAP_PRIVATE, pbs_fd, 0);
		if (pbs.pbs_mmap == MAP_FAILED) {
			fprintf(stderr, "Unable to mmap %s\n", argv[2]);
			return -1;
		}
		load_bs(&pbs);

		return 0;
	}

	if(!strcmp(argv[1], "reconf")) {
		reconfigure_fpga(&pbs);
		return 0;
	}

	if(!strcmp(argv[1], "unload")) {
		return 0;
	}
}
