all : grpci2test.c grpci2api.c grpci2extra.c
	sparc-elf-gcc -DRAMSTART=0x00000000 -O2 -g  grpci2test.c grpci2api.c grpci2extra.c -Wl,-msparcleon0 -qambapp -o grpci2test.exe
