# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

all: genData wrt_bmData convert2be

genData: genData.c ../../common/helper.h 
	gcc -o genData -pedantic -std=gnu99 -Wall genData.c ../../common/helper.h  -lm

wrt_bmData: wrt_bmData.c ../../common/helper.h 
	gcc -o wrt_bmData -pedantic -std=gnu99 -Wall wrt_bmData.c ../../common/helper.h  -lm

convert2be: convert2be.c
	gcc -o convert2be -pedantic -std=gnu99 -Wall convert2be.c

clean:
	rm genData wrt_bmData convert2be
