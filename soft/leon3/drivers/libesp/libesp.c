/*
 * Copyright (c) 2011-2019 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#include "libesp.h"

unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
	return (sizeof(void *) / _st);
}

static contig_handle_t contig;
static pthread_t *thread;

void *accelerator_thread( void *ptr )
{
	esp_thread_info_t *info = (esp_thread_info_t *) ptr;
	struct timespec th_start;
	struct timespec th_end;
	int rc = 0;

	gettime(&th_start);
	switch (info->type) {
	// <<--esp-ioctl-->>
	case conv2d :
		rc = ioctl(info->fd, CONV2D_IOC_ACCESS, info->desc.conv2d_desc);
		break;
	case gemm :
		rc = ioctl(info->fd, GEMM_IOC_ACCESS, info->desc.gemm_desc);
		break;
	case fftaccelerator :
		rc = ioctl(info->fd, FFTACCELERATOR_IOC_ACCESS, info->desc.fftaccelerator_desc);
		break;
	case adderaccelerator :
		rc = ioctl(info->fd, ADDERACCELERATOR_IOC_ACCESS, info->desc.adderaccelerator_desc);
		break;
	case fft :
		rc = ioctl(info->fd, FFT_IOC_ACCESS, info->desc.fft_desc);
		break;
	case adder :
		rc = ioctl(info->fd, ADDER_IOC_ACCESS, info->desc.adder_desc);
		break;
	case CounterAccelerator :
		rc = ioctl(info->fd, COUNTERACCELERATOR_IOC_ACCESS, info->desc.CounterAccelerator_desc);
		break;
	case dummy :
		rc = ioctl(info->fd, DUMMY_IOC_ACCESS, info->desc.dummy_desc);
		break;
	case sort :
		rc = ioctl(info->fd, SORT_IOC_ACCESS, info->desc.sort_desc);
		break;
	case spmv :
		rc = ioctl(info->fd, SPMV_IOC_ACCESS, info->desc.spmv_desc);
		break;
	case synth :
		rc = ioctl(info->fd, SYNTH_IOC_ACCESS, info->desc.synth_desc);
		break;
	case visionchip :
		rc = ioctl(info->fd, VISIONCHIP_IOC_ACCESS, info->desc.visionchip_desc);
		break;
	case vitbfly2 :
		rc = ioctl(info->fd, VITBFLY2_IOC_ACCESS, info->desc.vitbfly2_desc);
		break;
	}
	gettime(&th_end);
	if (rc < 0) {
		perror("ioctl");
	}
	info->hw_ns = ts_subtract(&th_start, &th_end);

	return NULL;
}

void *esp_alloc(size_t size)
{
	return contig_alloc(size, &contig);
}

static void esp_prepare(struct esp_access *esp)
{
	esp->contig = contig_to_khandle(contig);
	esp->run = true;
}

static void esp_config(esp_thread_info_t cfg[], unsigned nacc)
{
	int i;
	for (i = 0; i < nacc; i++) {
		esp_thread_info_t *info = &cfg[i];

		if (!info->run)
			continue;

		switch (info->type) {
		// <<--esp-prepare-->>
		case conv2d :
			esp_prepare(&info->desc.conv2d_desc.esp);
			break;
		case gemm :
			esp_prepare(&info->desc.gemm_desc.esp);
			break;
		case fftaccelerator :
			esp_prepare(&info->desc.fftaccelerator_desc.esp);
			break;
		case adderaccelerator :
			esp_prepare(&info->desc.adderaccelerator_desc.esp);
			break;
		case fft :
			esp_prepare(&info->desc.fft_desc.esp);
			break;
		case adder:
			esp_prepare(&info->desc.adder_desc.esp);
			break;
		case CounterAccelerator:
			esp_prepare(&info->desc.CounterAccelerator_desc.esp);
			break;
		case dummy:
			esp_prepare(&info->desc.dummy_desc.esp);
			break;
		case sort:
			esp_prepare(&info->desc.sort_desc.esp);
			break;
		case spmv:
			esp_prepare(&info->desc.spmv_desc.esp);
			break;
		case synth:
			esp_prepare(&info->desc.synth_desc.esp);
			break;
		case visionchip:
			esp_prepare(&info->desc.visionchip_desc.esp);
			break;
		case vitbfly2:
			esp_prepare(&info->desc.vitbfly2_desc.esp);
			break;
		default :
			contig_free(contig);
			die("Error: accelerator type specified for accelerator %s not supported\n", info->devname);
			break;
		}
	}
}

static void print_time_info(esp_thread_info_t info[], unsigned long long hw_ns, int nthreads)
{
	int i;

	printf("  > Test time: %llu ns\n", hw_ns);

	for (i = 0; i < nthreads; i++)
		if (info->run)
			printf("    - %s time: %llu ns\n", info[i].devname, info[i].hw_ns);
}

void esp_run(esp_thread_info_t cfg[], unsigned nacc)
{
	int i;
	struct timespec th_start;
	struct timespec th_end;
	thread = malloc(nacc * sizeof(pthread_t));
	int rc = 0;

	esp_config(cfg, nacc);

	for (i = 0; i < nacc; i++) {
		esp_thread_info_t *info = &cfg[i];
		char path[70];
		const char *prefix = "/dev/";

		if (strlen(info->devname) > 64) {
			contig_free(contig);
			die("Error: device name %s exceeds maximum length of 64 characters\n", info->devname);
		}

		sprintf(path, "%s%s", prefix, info->devname);

		info->fd = open(path, O_RDWR, 0);
		if (info->fd < 0) {
			contig_free(contig);
			die_errno("fopen failed\n");
		}
	}

	gettime(&th_start);
	for (i = 0; i < nacc; i++) {
		esp_thread_info_t *info = &cfg[i];

		if (!info->run)
			continue;

		rc = pthread_create(&thread[i], NULL, accelerator_thread, (void*) info);
		if(rc != 0) {
			perror("pthread_create");
		}
	}
	for (i = 0; i < nacc; i++) {
		esp_thread_info_t *info = &cfg[i];

		if (!info->run)
			continue;

		rc = pthread_join(thread[i], NULL);
		if(rc != 0) {
			perror("pthread_join");
		}

		close(info->fd);
	}
	gettime(&th_end);
	print_time_info(cfg, ts_subtract(&th_start, &th_end), nacc);

	free(thread);
}


void esp_cleanup()
{
	contig_free(contig);
}
