/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#define _GNU_SOURCE /* asprintf */

#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <time.h>
#include <sched.h>
#include <unistd.h>

#include <test/test.h>
#include <test/time.h>

#define KNRM  "\x1B[0m"
#define KRED  "\x1B[31m"
#define KGRN  "\x1B[32m"
#define KYEL  "\x1B[33m"
#define KBLU  "\x1B[34m"
#define KMAG  "\x1B[35m"
#define KCYN  "\x1B[36m"
#define KWHT  "\x1B[37m"

#define SET_RED(_fp) fprintf(_fp, "%s", KRED)
#define SET_GRN(_fp) fprintf(_fp, "%s", KGRN)
#define SET_YEL(_fp) fprintf(_fp, "%s", KYEL)
#define SET_BLU(_fp) fprintf(_fp, "%s", KBLU)
#define SET_MAG(_fp) fprintf(_fp, "%s", KMAG)
#define SET_CYN(_fp) fprintf(_fp, "%s", KCYN)
#define SET_WHT(_fp) fprintf(_fp, "%s", KWHT)
#define SET_NRM(_fp) fprintf(_fp, "%s", KNRM)

static void dev_open(struct test_info *info)
{
	info->fd = open(info->devname, O_RDWR, 0);
	if (info->fd < 0) {
		perror(__func__);
		exit(1);
	}
}

static void __dev_init(struct test_info *info, bool pr)
{
	if (!info->fd) {
		if (pr) {
			printf("Opening %s... \n", info->devname);
			fflush(NULL);
		}
		dev_open(info);
	}

	if (pr) {
		printf("Allocating buffers... \n");
		fflush(NULL);
	}
	info->alloc_buf(info);

	if (pr) {
		printf("Allocating hardware buffer... \n");
		fflush(NULL);
	}
	info->alloc_contig(info);

	if (pr) {
		printf("Initializing buffers... \n");
		fflush(NULL);
	}
	info->init_bufs(info);

	if (info->to_sc_fixed) {
		if (pr) {
			printf("Converting to fixed point... \n");
			fflush(NULL);
		}
		info->to_sc_fixed(info);
	}

	/* Disable P2P by default: user can override configuraion later */
	info->esp->p2p_store = 0;
	info->esp->p2p_nsrcs = 0;

	if (info->set_access)
		info->set_access(info);
	info->esp->contig = contig_to_khandle(info->contig);
	info->esp->run = true;

}

static void dev_init(struct test_info *info)
{
	__dev_init(info, false);
}

static void pr_file(const char *filename, const char *pfx, const char *description, const struct timespec *ts)
{
	FILE *fp;

	fp = fopen(filename, "w+");
	if (fp == NULL) {
		perror(__func__);
		exit(1);
	}
	fprintf(fp, "%s: %llu (%s)\n", pfx, getformattedtime(ts), description);
	if (fclose(fp)) {
		perror(__func__);
		exit(1);
	}
}

static char *str_to_upper(const char *str)
{
	char *new;
	char *p;

	new = strdup(str);
	if (new == NULL) {
		perror(__func__);
		exit(1);
	}
	p = new;
	while (*p)
		*p++ = toupper(*p);
	return new;
}

static int cmd_test(struct test_info *info)
{
	struct timespec ts_start, ts_end;
	struct timespec th_start, th_end;
	unsigned long long sw_ns;
	unsigned long long hw_ns;
	int rc;

	__dev_init(info, true);

	if (info->comp) {
		printf("Running software\n");
		gettime(&ts_start);
		info->comp(info);
		gettime(&ts_end);
		printf("Software done!\n\n");
	}

	printf("Running hardware\n");
	gettime(&th_start);
	rc = ioctl(info->fd, info->cm, info->esp);
	gettime(&th_end);
	if (rc < 0)
		die_errno("IOCTL on %s failed", info->devname);
	printf("HW done");
	if (info->to_float) {
		printf("... Converting to float\n");
		fflush(NULL);
		info->to_float(info);
	}
	printf("\n");
	printf("\n--------------------------------\n");
	hw_ns = ts_subtract(&th_start, &th_end);
	sw_ns = ts_subtract(&ts_start, &ts_end);
	printf("  hw exec time: %llu ms\n", hw_ns/1000000);
	printf("  sw exec time: %llu ms\n", sw_ns/1000000);
	unsigned int speedup = sw_ns / hw_ns;
	SET_GRN(stdout);
	printf("\n  HW SPEEDUP: %ux\n", speedup);

	if (!info->diff_ok(info))
		return 1;
	else
		printf("\n  SOFTWARE AND HARDWARE MATCH!\n");

	SET_NRM(stdout);

	        printf("--------------------------------\n");

	return 0;
}

static int cmd_hw(struct test_info *info)
{
	struct timespec ts_start, ts_end;
	struct timespec th_start, th_end;
	char *uppername;
	int rc;

	gettime(&ts_start);
	dev_init(info);
	gettime(&th_start);
	rc = ioctl(info->fd, info->cm, info->esp);
	gettime(&th_end);
	if (rc < 0)
		die_errno("IOCTL on %s failed", info->devname);
	gettime(&ts_end);

	uppername = str_to_upper(info->name);
	printf("   hw-init: %llu ns\n", getformattedtime(&th_start) - getformattedtime(&ts_start));
	printf("   hw-exec: %llu ns\n", getformattedtime(&th_end) - getformattedtime(&th_start));
	free(uppername);
	return 0;
}

static int cmd_run(struct test_info *info)
{
	struct timespec th_start;
	char *filename;
	char *uppername;
	int rc;

	dev_open(info);

	gettime(&th_start);
	rc = ioctl(info->fd, ESP_IOC_RUN);
	if (rc < 0)
		die_errno("ESP_IOC_RUN on %s failed", info->devname);
	if (asprintf(&filename, "%s-start.txt", info->name) < 0) {
		perror("asprintf");
		exit(1);
	}
	uppername = str_to_upper(info->name);
	pr_file(filename, uppername, "hardware-start", &th_start);
	free(uppername);
	free(filename);
	return 0;
}

static int cmd_flush(struct test_info *info)
{
	int rc;

	dev_open(info);

	rc = ioctl(info->fd, ESP_IOC_FLUSH);
	if (rc < 0)
		die_errno("ESP_IOC_FLUSH on %s failed", info->devname);

	return 0;
}

static int cmd_config(struct test_info *info)
{
	struct timespec th_end;
	char *filename;
	char *uppername;
	int rc;

	dev_init(info);
	info->esp->run = false;
	rc = ioctl(info->fd, info->cm, info->esp);
	gettime(&th_end);
	if (rc < 0)
		die_errno("IOCTL on %s failed", info->devname);
	if (asprintf(&filename, "%s-end.txt", info->name) < 0) {
		perror("asprintf");
		exit(1);
	}
	uppername = str_to_upper(info->name);
	pr_file(filename, uppername, "hardware-end", &th_end);
	free(uppername);
	free(filename);
	return 0;
}

static int sched_setaffinity_syscl(pid_t pid, size_t cpusetsize, const cpu_set_t *cpuset)
{
	errno = syscall(__NR_sched_setaffinity, pid, cpusetsize, cpuset);
	return errno;
}

int test_main(struct test_info *info, const char *coh, const char *cmd)
{
	cpu_set_t set;
	enum accelerator_coherence coherence;

	CPU_ZERO(&set);
	CPU_SET(0, &set);

	if (sched_setaffinity_syscl(getpid(), sizeof(set), &set)) {
		perror("sched_setaffinity: %d");
		exit(EXIT_FAILURE);
	}


	if (!strcmp(coh, "coh"))
		coherence = ACC_COH_FULL;
	else if (!strcmp(coh, "llc-coh-dma"))
		coherence = ACC_COH_LLC;
	else if (!strcmp(coh, "coh-dma"))
		coherence = ACC_COH_RECALL;
	else
		coherence = ACC_COH_NONE;

	info->cmd = cmd;
	info->esp->coherence = coherence;

	if (!strcmp(cmd, "config"))
		return cmd_config(info);
	else if (!strcmp(cmd, "test"))
		return cmd_test(info);
	else if (!strcmp(cmd, "run"))
		return cmd_run(info);
	else if (!strcmp(cmd, "hw"))
		return cmd_hw(info);
	else if (!strcmp(cmd, "flush"))
		return cmd_flush(info);
	fprintf(stderr, "unknown cmd '%s'\n", cmd);
	return 1;
}

static int err_vfmt(const char *prefix, const char *fmt, va_list ap)
{
        char err[2048];

        vsnprintf(err, sizeof(err), fmt, ap);
        return fprintf(stderr, "%s%s\n", prefix, err);
}

static void NORETURN die_vfmt(const char *fmt, va_list ap)
{
        err_vfmt("fatal: ", fmt, ap);
        exit(EXIT_FAILURE);
}

void NORETURN die(const char *fmt, ...)
{
        va_list ap;

        va_start(ap, fmt);
        die_vfmt(fmt, ap);
        va_end(ap);
}

static void NORETURN errno_vfmt(const char *fmt, va_list ap)
{
        char err[1024];

        snprintf(err, sizeof(err), "%s: %s", fmt, strerror(errno));
        die_vfmt(err, ap);
}

void NORETURN die_errno(const char *fmt, ...)
{
        va_list ap;

        va_start(ap, fmt);
        errno_vfmt(fmt, ap);
        va_end(ap);
}
