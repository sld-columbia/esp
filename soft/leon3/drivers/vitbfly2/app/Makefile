
CFLAGS = -I../../include -std=c99 -DUSE_ESP_INTERFACE -DRUN_HW
LDFLAGS = -L../../contig_alloc -lcontig

SRC_S = $(wildcard *.c)
OBJ_S = $(SRC_S:.c=.o)

TARGET = vitbfly2.exe

compile: $(TARGET)


include ../../common.mk


%.o: %.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -c $< -o $@

vitbfly2.exe: $(OBJ_S)
	CROSS_COMPILE=$(CROSS_COMPILE) $(MAKE) -C ../../contig_alloc/ libcontig.a
	$(CROSS_COMPILE)$(CC) $^ -o $@ $(LDFLAGS)

.PHONY: compile
