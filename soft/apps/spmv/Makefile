KERN=spmv
ALG=crs

CFLAGS?=-O3 -Wall -Wno-unused-label

SRCS=$(KERN).c local_support.c support.c
FILES=$(SRCS) $(KERN).h support.h

$(KERN): $(FILES) harness.c
	$(CC) $(CFLAGS) -o $(KERN) $(SRCS) harness.c

run: $(KERN)
	./$(KERN) 1 315 128 128; \
	./$(KERN) 2 4701 1024 1024; \
	./$(KERN) 3 138848 16384 16384; \
	./$(KERN) 4 1077480 65536 65536

generate:
	python3.6 generate.py

clean:
	rm -f $(KERN) inputs/* outputs/*
