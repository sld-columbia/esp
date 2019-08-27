#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <pthread.h>

#include <my_stringify.h>
#include <test/test.h>
#include <test/time.h>
#include <dummy.h>

#define TOKENS 512
#define BATCH 2
#define SIZE (2 * BATCH * TOKENS)

struct accelerator_thread_info {
	int fd;
	struct dummy_access desc;
	unsigned long long hw_ns;
};

typedef struct accelerator_thread_info accelerator_thread_info_t;

void *accelerator_thread( void *ptr )
{
	accelerator_thread_info_t *info = (accelerator_thread_info_t *) ptr;
	struct timespec th_start;
	struct timespec th_end;
	int rc;

	gettime(&th_start);
	rc = ioctl(info->fd, DUMMY_IOC_ACCESS, info->desc);
	gettime(&th_end);
	if(rc < 0) {
		perror("ioctl");
		exit(1);
	}
	info->hw_ns = ts_subtract(&th_start, &th_end);

	return NULL;
}

static void prepare_dummy(int *fd, contig_handle_t *mem, accelerator_thread_info_t *info, struct dummy_access *desc, const char *device_name, unsigned id)
{
		*fd = open(device_name, O_RDWR, 0);
		if (*fd < 0) {
			perror("open");
			exit(1);
		}

		desc->esp.contig = contig_to_khandle(*mem);
		desc->esp.run = true;
		desc->esp.coherence = ACC_COH_NONE;
		desc->tokens = TOKENS;
		if (id != 2)
			desc->batch = 1;
		else
			desc->batch = BATCH;
		info->fd = *fd;
		info->desc = *desc;
}

int main(int argc, char *argv[])
{
	int i;
	int rc = 0;
	int err;
	int fd[3];
	contig_handle_t hwbuf;
	char device_name[60];


	struct timespec th_start;
	struct timespec th_end;
	unsigned long long hw_ns = 0;

	pthread_t thread[3];
	accelerator_thread_info_t info[3];
	struct dummy_access desc[3];

	printf("=== Point-to-point test w/ dummy accelerator ===\n");

	printf("  - Config: {tokens = %d, batch = %d}\n", TOKENS, BATCH);

	printf("  - Allocate %lu B\n", SIZE * sizeof(uint64_t));
	contig_alloc(SIZE * sizeof(uint64_t), &hwbuf);

	printf("  - Initialize %d double words at offset 0\n", BATCH * TOKENS);
	for (i = 0; i < BATCH * TOKENS; i++)
		contig_write64(0xFEED0BACL | (uint64_t) i, hwbuf, i * sizeof(uint64_t));

	printf("  - Configure devices\n");
	for (i = 0; i < 3; i++) {
		sprintf(device_name, "/dev/dummy.%d", i);
		prepare_dummy(&fd[i], &hwbuf, &info[i], &desc[i], device_name, i);
	}

	printf("  --> Start simple DMA test\n");
	printf("      MEM ==> ACC.0 ==> MEM\n");
	printf("      MEM ==> ACC.1 ==> MEM\n");
	printf("      MEM ==> ACC.2 ==> MEM\n");

	gettime(&th_start);
	for (i = 0; i < 3; i++) {
		rc = pthread_create(&thread[i], NULL, accelerator_thread, (void*) &info[i]);
		if(rc != 0) {
			perror("pthread_create");
			goto free_and_exit;
		}
		rc = pthread_join(thread[i], NULL);
		if(rc != 0) {
			perror("pthread_join");
			goto free_and_exit;
		}
	}
	gettime(&th_end);

	err = 0;
	for (i = 0; i < BATCH * TOKENS; i++) {
		uint64_t token = contig_read64(hwbuf, (BATCH * TOKENS + i) * sizeof(uint64_t));
		if (token != (0xFEED0BACL | (uint64_t) i))
			err++;
	}

	if (!err)
		printf("      + Test PASSED\n");
	else
		printf("      + Test FAILED\n");


	for (i = 0; i < 3; i++)
		printf("      * ACC.%d time: %llu ns\n", i, info[i].hw_ns);
	hw_ns = ts_subtract(&th_start, &th_end);
	printf("      Test time: %llu ns\n", hw_ns);

free_and_exit:
	contig_free(hwbuf);
	return rc;

}


