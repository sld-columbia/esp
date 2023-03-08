
/*
 * Copyright (c) 2011-2022 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef __PRCLIB_H__
#define __PRCLIB_H__
#include <assert.h>
#include <fcntl.h>
#include <math.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "my_stringify.h"
#include "fixed_point.h"
#include "test/time.h"
#include "test/test.h"

#include <dpr.h>


int prc_load_pbs(char *filepath, int tile_num, char *drv_name);
int prc_request_dpr(int tile_num, char *pbs_name);
pthread_t *prc_request_dpr_pthread(int tile_num, char *pbs);



#endif

