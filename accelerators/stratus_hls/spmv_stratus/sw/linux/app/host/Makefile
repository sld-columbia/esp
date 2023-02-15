# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
KERN=spmv
ALG=crs

CFLAGS?=-O3 -Wall -Wno-unused-label

SRCS=$(KERN).c local_support.c support.c
FILES=$(SRCS) $(KERN).h support.h

# 1 = uniform, 2 = diagonal, 3 = triangular
MTX_TYPE=1

$(KERN): $(FILES) harness.c
	$(CC) $(CFLAGS) -o $(KERN) $(SRCS) harness.c

run: $(KERN)
	./$(KERN) 1 315 128 128; \
	./$(KERN) 2 4701 1024 1024; \
	./$(KERN) 3 138848 16384 16384; \
	./$(KERN) 4 1077480 65536 65536; \
	./$(KERN) _d1 287 128 128; \
	./$(KERN) _d2 4534 1024 1024; \
	./$(KERN) _d3 138110 16384 16384; \
	./$(KERN) _d4 1079515 65536 65536; \
	./$(KERN) _t1 314 128 128; \
	./$(KERN) _t2 4594 1024 1024; \
	./$(KERN) _t3 139166 16384 16384; \
	./$(KERN) _t4 1078703 65536 65536

generate:
	python3 generate.py

clean:
	rm -f $(KERN) inputs/* outputs/*
