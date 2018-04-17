KERN=spmv
ALG=crs

CFLAGS?=-O3 -Wall -Wno-unused-label

SRCS=$(KERN).c local_support.c support.c
FILES=$(SRCS) $(KERN).h support.h

$(KERN): $(FILES) harness.c
	$(CC) $(CFLAGS) -o $(KERN) $(SRCS) harness.c

run: $(KERN)
	./$(KERN) 1 256 100 100; \
	./$(KERN) 2 4609 1000 1000; \
	./$(KERN) 3 84718 10000 10000; \
	./$(KERN) 4 1654146 100000 100000

generate:
	python3.6 generate.py

clean:
	rm -f $(KERN) inputs/* outputs/*
