// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>

#include "esplink.h"
#include "edcl.h"

static char *exe;

static void print_usage() {
	printf("\n");

	printf("Usage:\n");
	printf("  %s <action> <options>\n", exe);
	printf("  %s -h | --help\n", exe);

	printf("\n");

	printf("Actions:\n");
	printf("  --load              Load binary `infile` to target system.\n");
	printf("  --dump              Dump memory from target system to `outfile`.\n");
	printf("  --brom              Load binary `infile` to system BOOTROM\n");
	printf("  --dram              Load binary `infile` to system DRAM\n");
	printf("  --regw              Write target register (4 Bytes)\n");
	printf("  --regr              Read target register (4 Bytes)\n");
	printf("  --reset             Send soft-reset to processor cores\n");

	printf("\n");

	printf("Options:\n");
	printf("  -h --help           Show this screen.\n");
	printf("  -i --infile         Input binary to be loaded.\n");
	printf("  -o --outfile        Output file.\n");
	printf("  -a --address        Base addres son target.\n");
	printf("  -s --size           Length transfer in Bytes.\n");
	printf("  -d --data           Single 32-bits word to be written to target register.");

	printf("\n\n");
}

static long int parse_int(char *str)
{

	char *endptr;
	long int val;
	errno = 0;

	if (str[1] == 'x' || str[1] == 'X')
		val = strtol(str, &endptr, 16);
	else
		val = strtol(str, &endptr, 10);

	if ((errno == ERANGE && (val == LONG_MAX || val == LONG_MIN)) || (errno != 0 && val == 0))
		die("strtol");

	if (endptr == str) {
		fprintf(stderr, "strtol: no digits were found\n");
		exit(EXIT_FAILURE);
	}

	return val;
}

static struct option long_options[] = {
        {"infile",  required_argument,  0,  'i'             },
        {"outfile", required_argument,  0,  'o'             },
        {"address", required_argument,  0,  'a'             },
        {"size",    required_argument,  0,  's'             },
        {"data",    required_argument,  0,  'd'             },
        {"help",    no_argument,        0,  'h'             },
	{"wrhex",   no_argument,        0,  DO_WRITE        },
	{"rdhex",   no_argument,        0,  DO_READ         },
        {"load",    no_argument,        0,  DO_WRITE_BIN    },
        {"dump",    no_argument,        0,  DO_READ_BIN     },
        {"brom",    no_argument,        0,  DO_LOAD_BOOTROM },
        {"dram",    no_argument,        0,  DO_LOAD_DRAM    },
        {"regw",    no_argument,        0,  DO_SET_WORD     },
        {"regr",    no_argument,        0,  DO_GET_WORD     },
        {"reset",   no_argument,        0,  DO_RESET        },
        {0,         0,                  0,  0               }
};

int main(int argc, char *argv[]) {
	int opt = 0;
	int long_index = 0;

	action_t action = DO_NONE;
	char *infile = NULL;
	char *outfile = NULL;
	u32 address = INT_MAX;
	u32 size = 0;
	u32 data = 0;

	exe = argv[0];

	if (argc < 2) {
		print_usage();
		exit(EXIT_FAILURE);
	}

	while ((opt = getopt_long(argc, argv, "i:o:a:s:d:h", long_options, &long_index)) != -1) {
		switch (opt) {
		case 'i' : infile = optarg; break;
		case 'o' : outfile = optarg; break;
		case 'a' : address = parse_int(optarg); break;
		case 's' : size = parse_int(optarg); break;
		case 'd' : data = parse_int(optarg); break;
		case 'h' : print_usage(); exit(EXIT_SUCCESS); break;
		case DO_WRITE :
		case DO_READ :
		case DO_WRITE_BIN :
		case DO_READ_BIN :
		case DO_LOAD_BOOTROM :
		case DO_LOAD_DRAM :
		case DO_RESET :
		case DO_SET_WORD :
		case DO_GET_WORD : action = opt; break;
		default : print_usage(); exit(EXIT_FAILURE);
		}
	}

	printf("ESPLink address ");
	if (ESPLINK_IP[0] == '\0') {
		printf("%s:%d\n", EDCL_IP, PORT);
		connect_edcl(EDCL_IP);
	} else {
		printf("%s:%d\n", ESPLINK_IP, PORT);
		connect_edcl(ESPLINK_IP);
	}

	atexit(disconnect_edcl);

	switch (action) {
	case DO_WRITE :
		if (infile == NULL)
			die("Invalid options for action --wrhex");
		load_memory(infile);
		break;

	case DO_READ :
		if ((address == INT_MAX) || (size == 0) || (outfile == NULL))
			die("Invalid options for action --rdhex");
		dump_memory(address, size, outfile);
		break;

	case DO_WRITE_BIN :
		if ((address == INT_MAX) || (infile == NULL))
			die("Invalid options for action --load");
		load_memory_bin(address, infile);
		break;

	case DO_READ_BIN :
		if ((address == INT_MAX) || (size == 0) || (outfile == NULL))
			die("Invalid options for action --dump");
		dump_memory_bin(address, size, outfile);
		break;

	case DO_LOAD_BOOTROM :
		if (infile == NULL)
			die("Invalid options for action --brom");
		load_memory_bin(BOOTROM_BASE_ADDR, infile);
		break;

	case DO_LOAD_DRAM :
		if (infile == NULL)
			die("Invalid options for action --dram");
		load_memory_bin(DRAM_BASE_ADDR, infile);
		break;

	case DO_RESET :
		reset(ESPLINK_BASE_ADDR);
		break;

	case DO_SET_WORD :
		if ((address == INT_MAX))
			die("Invalid options for action --regw");
		set_word(address, data);
		break;

	case DO_GET_WORD :
		if ((address == INT_MAX))
			die("Invalid options for action --regr");
		get_word(address);
		break;

	default :
		errno = EINVAL;
		die("Invalid action");
		break;
	}

	return 0;
}
