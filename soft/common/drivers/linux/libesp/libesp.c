/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#include "libesp.h"

buf2handle_node *head = NULL;

void insert_buf(void *buf, contig_handle_t *handle, enum contig_alloc_policy policy)
{
	buf2handle_node *new = malloc(sizeof(buf2handle_node));
	new->buf = buf;
	new->handle = handle;
	new->policy = policy;

	new->next = head;
	head = new;
}

contig_handle_t* lookup_handle(void *buf, enum contig_alloc_policy *policy)
{
	buf2handle_node *cur = head;
	while (cur != NULL) {
		if (cur->buf == buf) {
			if (policy != NULL)
				*policy = cur->policy;
			return cur->handle;
		}
		cur = cur->next;
	}
	die("buf not in active allocations\n");
}

void remove_buf(void *buf)
{
	buf2handle_node *cur = head;
	if (cur->buf == buf) {
		head = cur->next;
		contig_free(*(cur->handle));
		free(cur);
		return;
	}

	buf2handle_node *prev;
	while (cur != NULL && cur->buf != buf) {
		prev = cur;
		cur = cur->next;
	}

	if (cur == NULL)
		die("buf not in active allocations\n");

	prev->next = cur->next;
	contig_free(*(cur->handle));
	free(cur->handle);
	free(cur);
}

bool thread_is_p2p(esp_thread_info_t *thread)
{
	return ((thread->esp_desc)->p2p_store || (thread->esp_desc)->p2p_nsrcs);
}

unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
	return (sizeof(void *) / _st);
}

void *accelerator_thread( void *ptr )
{
	esp_thread_info_t *info = (esp_thread_info_t *) ptr;
	struct timespec th_start;
	struct timespec th_end;
	int rc = 0;

	gettime(&th_start);
	rc = ioctl(info->fd, info->ioctl_req, info->esp_desc);
	gettime(&th_end);
	if (rc < 0) {
		perror("ioctl");
	}

	info->hw_ns = ts_subtract(&th_start, &th_end);

	return NULL;
}

void *accelerator_thread_p2p(void *ptr)
{
	struct thread_args *args = (struct thread_args*) ptr;
	esp_thread_info_t *thread = args->info;
	unsigned nacc = args->nacc;
	int rc = 0;
	int i;

	pthread_t *threads = malloc(nacc * sizeof(pthread_t));

	for (i = 0; i < nacc; i++) {
		esp_thread_info_t *info = thread + i;
		if (!info->run)
			continue;
		rc = pthread_create(&threads[i], NULL, accelerator_thread, (void*) info);
		if (rc != 0)
			perror("pthread_create");
	}

	for (i = 0; i < nacc; i++) {
		esp_thread_info_t *info = thread + i;
		if (!info->run)
			continue;
		rc = pthread_join(threads[i], NULL);
		if (rc != 0)
			perror("pthread_join");
		close(info->fd);
	}
	free(threads);
	free(ptr);
	return NULL;
}

void *accelerator_thread_serial(void *ptr)
{
	struct thread_args *args = (struct thread_args*) ptr;
	esp_thread_info_t *thread = args->info;
	unsigned nacc = args->nacc;
	int i;
	for (i = 0; i < nacc; i++) {

		struct timespec th_start;
		struct timespec th_end;
		int rc = 0;
		esp_thread_info_t *info = thread + i;

		if (!info->run)
			continue;

		gettime(&th_start);
		rc = ioctl(info->fd, info->ioctl_req, info->esp_desc);
		gettime(&th_end);
		if (rc < 0) {
			perror("ioctl");
		}

		info->hw_ns = ts_subtract(&th_start, &th_end);
		close(info->fd);
	}
	free(ptr);
	return NULL;
}

void *esp_alloc_policy(struct contig_alloc_params params, size_t size)
{
	contig_handle_t *handle = malloc(sizeof(contig_handle_t));
	void* contig_ptr = contig_alloc_policy(params, size, handle);
	insert_buf(contig_ptr, handle, params.policy);
	return contig_ptr;
}

void *esp_alloc(size_t size)
{
	contig_handle_t *handle = malloc(sizeof(contig_handle_t));
	void* contig_ptr = contig_alloc(size, handle);
	insert_buf(contig_ptr, handle, CONTIG_ALLOC_PREFERRED);
	return contig_ptr;
}

static void esp_config(esp_thread_info_t* cfg[], unsigned nthreads, unsigned *nacc)
{
	int i, j;
	for (i = 0; i < nthreads; i++) {
		unsigned len = nacc[i];
		for(j = 0; j < len; j++) {
			esp_thread_info_t *info = cfg[i] + j;
			if (!info->run)
				continue;

			enum contig_alloc_policy policy;
			contig_handle_t *handle = lookup_handle(info->hw_buf, &policy);

			(info->esp_desc)->contig = contig_to_khandle(*handle);
			(info->esp_desc)->ddr_node = contig_to_most_allocated(*handle);
			(info->esp_desc)->alloc_policy = policy;
			(info->esp_desc)->run = true;
		}
	}
}

static void print_time_info(esp_thread_info_t *info[], unsigned long long hw_ns, int nthreads, unsigned* nacc)
{
	int i, j;

	printf("  > Test time: %llu ns\n", hw_ns);
	for (i = 0; i < nthreads; i++) {
		unsigned len = nacc[i];
		for (j = 0; j < len; j++) {
			esp_thread_info_t* cur = info[i] + j;
			if (cur->run)
				printf("	- %s time: %llu ns\n", cur->devname, cur->hw_ns);
		}
	}
}

void esp_run(esp_thread_info_t cfg[], unsigned nacc)
{
	int i;

	if (thread_is_p2p(&cfg[0])) {
		esp_thread_info_t *cfg_ptrs[1];
		cfg_ptrs[0] = cfg;

		esp_run_parallel(cfg_ptrs, 1, &nacc);
	} else{
		esp_thread_info_t **cfg_ptrs = malloc(sizeof(esp_thread_info_t*) * nacc);
		unsigned *nacc_arr = malloc(sizeof(unsigned) * nacc);

		for (i = 0; i < nacc; i++) {
			nacc_arr[i] = 1;
			cfg_ptrs[i] = &cfg[i];
		}
		esp_run_parallel(cfg_ptrs, nacc, nacc_arr);
		free(nacc_arr);
		free(cfg_ptrs);
	}
}

void esp_run_parallel(esp_thread_info_t* cfg[], unsigned nthreads, unsigned* nacc)
{
	int i, j;
	struct timespec th_start;
	struct timespec th_end;
	pthread_t *thread = malloc(nthreads * sizeof(pthread_t));
	int rc = 0;
	esp_config(cfg, nthreads, nacc);
	for (i = 0; i < nthreads; i++) {
		unsigned len = nacc[i];
		for (j = 0; j < len; j++) {
			esp_thread_info_t *info = cfg[i] + j;
			const char *prefix = "/dev/";
			char path[70];

			if (strlen(info->devname) > 64) {
				contig_handle_t *handle = lookup_handle(info->hw_buf, NULL);
				contig_free(*handle);
				die("Error: device name %s exceeds maximum length of 64 characters\n",
					info->devname);
			}

			sprintf(path, "%s%s", prefix, info->devname);

			info->fd = open(path, O_RDWR, 0);
			if (info->fd < 0) {
				contig_handle_t *handle = lookup_handle(info->hw_buf, NULL);
				contig_free(*handle);
				die_errno("fopen failed\n");
			}
		}
	}

	gettime(&th_start);
	for (i = 0; i < nthreads; i++) {
		struct thread_args *args = malloc(sizeof(struct thread_args));;
		args->info = cfg[i];
		args->nacc = nacc[i];

		if (thread_is_p2p(cfg[i])) {
			if (nthreads == 1)
				accelerator_thread_p2p( (void*) args);
			else
				rc = pthread_create(&thread[i], NULL, accelerator_thread_p2p, (void*) args);
		} else {
			if (nthreads == 1)
				accelerator_thread_serial( (void*) args);
			else
				rc = pthread_create(&thread[i], NULL, accelerator_thread_serial, (void*) args);
		}

		if(rc != 0) {
			perror("pthread_create");
		}
	}
	for (i = 0; i < nthreads; i++) {
		if (nthreads > 1)
			rc = pthread_join(thread[i], NULL);

		if(rc != 0) {
			perror("pthread_join");
		}
	}

	gettime(&th_end);
	print_time_info(cfg, ts_subtract(&th_start, &th_end), nthreads, nacc);

	free(thread);
}

void esp_free(void *buf)
{
	remove_buf(buf);
}
