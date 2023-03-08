
/*
 * Copyright (c) 2011-2022 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#include "libdpr.h"

#include <sys/mman.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <libgen.h>

static const char prc_drv[] = "/dev/esp_dpr";
int prc_driver;

int prc_load_pbs(char *filepath, int tile_num, char *drv_name)
{
	pbs_arg pbs;
	int pbs_fd;
	struct stat sb; 

	if ((prc_driver = open(prc_drv, O_RDWR)) == -1) {
		fprintf(stderr, "Unable to open device %s\n", prc_drv );
		return -1;
	}

	if ((pbs_fd = open(filepath, O_RDONLY)) == -1) {
		fprintf(stderr, "Unable to open %s\n", filepath);
		return -1;
	}
	fstat(pbs_fd, &sb);

	pbs.pbs_tile_id = tile_num; 
	pbs.pbs_size = sb.st_size;
	strncpy(pbs.name, filepath, LEN_DEVNAME_MAX);
	strncpy(pbs.driver, drv_name, LEN_DRVNAME_MAX);

	pbs.pbs_mmap = mmap(NULL, sb.st_size, PROT_READ, MAP_PRIVATE, pbs_fd, 0);
	if (pbs.pbs_mmap == MAP_FAILED) {
		fprintf(stderr, "Unable to mmap %s\n", filepath);
		return -1;
	}

	if(ioctl(prc_driver, PRC_LOAD_BS, pbs)) {
		perror("Failed to write bitsream to driver");
		return -1;
	}

	close(pbs_fd);
	return 0;
}

int prc_request_dpr(int tile_num, char *pbs_name)
{
	pbs_arg pbs;

	strncpy(pbs.name, pbs_name, LEN_DEVNAME_MAX);
	pbs.pbs_tile_id = tile_num; 

	if(ioctl(prc_driver, PRC_RECONFIGURE, pbs)) {
		perror("Failed to write bitsream to driver");
		return -1;
	}
	return 0;

}

void *prc_request_thread(void *ptr)
{
	pbs_arg *pbs = (pbs_arg *) ptr;

	if(ioctl(prc_driver, PRC_RECONFIGURE, pbs)) {
		perror("Failed to write bitsream to driver");
	}

	return NULL; 
	
}


pthread_t *prc_request_dpr_pthread(int tile_num, char *pbs_name)
{
	int rc = 0;
	pbs_arg *pbs =  malloc(sizeof(pbs_arg));
	pthread_t *thread = malloc(sizeof(pthread_t));
	

	strncpy(pbs->name, pbs_name, LEN_DEVNAME_MAX);
	pbs->pbs_tile_id = tile_num; 

	rc = pthread_create(thread, NULL, prc_request_thread, (void*)pbs);
	if (rc)
		perror("pthread_create");

	return thread;
}

