CC=sparc-gaisler-elf-gcc
CFLAGS  =
CFLAGS += -Wall
CFLAGS += -Wextra
CFLAGS += -pedantic

init_reg32.S: init_reg32.c
	$(CC) -Os $(CFLAGS) -S $< -o $@

clean:
	$(RM) init_reg32.S

