#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>

#include <my_stringify.h>
#include <test/test.h>
#include <test/time.h>
#include <visionchip.h>

#define DEVNAME "/dev/visionchip.0"
#define NAME "visionchip"

static const char usage_str[] = "usage: visionchip coherence cmd [-v]\n"
	"  coherence: none|llc|recall|full\n"
	"  cmd: config|test|run|hw|flush\n"
	"\n"
	"Optional arguments: none.\n"
	"\n"
	"The remaining option is only optional for 'test':\n"
	"  -v: enable verbose output for output-to-gold comparison\n";

struct visionchip_test {
	struct test_info info;
	struct visionchip_access desc;
	unsigned rows;
	unsigned cols;
	int *hbuf;
	int *sbuf;
	bool verbose;
};

static inline struct visionchip_test *to_visionchip(struct test_info *info)
{
	return container_of(info, struct visionchip_test, info);
}

static int check_gold (int *gold, int *array, int len, bool verbose)
{
	int i;
	int rtn = 0;
	for (i = 0; i < len; i++) {
		if (array[i] != gold[i]) {
			if (verbose)
				printf("A[%d]: array=%d; gold=%d\n", i, array[i], gold[i]);
			rtn++;
		}
	}
	return rtn;
}

static void init_buf (int *buf, unsigned visionchip_rows, unsigned visionchip_cols)
{
        //  ========================  ^
        //  |  in/out image (int)  |  | img_size (in bytes)
        //  ========================  v

        // -- Read image
        printf("read image start\n");

        int i = 0;
        int val = 0;
        FILE *fd = NULL;

        if((fd = fopen("./lena.txt", "r")) == (FILE*)NULL)
        {
                printf("[Err] could not open ./lena.txt\n");
                fclose(fd);
        }

        fscanf(fd, "%d", &val);
        while(!feof(fd))
        {
                buf[i++] = val;
                fscanf(fd, "%d", &val);
        }

        fclose(fd);

	printf("read image finish\n");

        printf("load memory completed\n");
}

static inline size_t visionchip_size(struct visionchip_test *t)
{
	return t->rows * t->cols * sizeof(int);
}

static void visionchip_alloc_buf(struct test_info *info)
{
	struct visionchip_test *t = to_visionchip(info);

	t->hbuf = malloc0_check(visionchip_size(t));
	if (!strcmp(info->cmd, "test"))
		t->sbuf = malloc0_check(visionchip_size(t));
}

static void visionchip_alloc_contig(struct test_info *info)
{
	struct visionchip_test *t = to_visionchip(info);

	printf("HW buf size: %zu\n", visionchip_size(t));
	if (contig_alloc(visionchip_size(t), &info->contig))
		die_errno(__func__);
}

static void visionchip_init_bufs(struct test_info *info)
{
	struct visionchip_test *t = to_visionchip(info);

	init_buf(t->hbuf, t->rows, t->cols);
	contig_copy_to(info->contig, 0, t->hbuf, visionchip_size(t));

	if (!strcmp(info->cmd, "test"))
		memcpy(t->sbuf, t->hbuf, visionchip_size(t));
}

static void visionchip_set_access(struct test_info *info)
{
	struct visionchip_test *t = to_visionchip(info);

	t->desc.rows = t->rows;
	t->desc.cols = t->cols;
}

static void visionchip_comp(struct test_info *info)
{
	struct visionchip_test *t = to_visionchip(info);

	// TODO call pv

        // -- Read gold output
        printf("read gold output start\n");

        int i = 0;
        int val = 0;
        FILE *fd = NULL;

        if((fd = fopen("./gold_output.txt", "r")) == (FILE*)NULL)
        {
                printf("[Err] could not open ./gold_output.txt\n");
                fclose(fd);
        }

        fscanf(fd, "%d", &val);
        while(!feof(fd))
        {
                t->sbuf[i++] = val;
                fscanf(fd, "%d", &val);
        }

        fclose(fd);

	printf("read gold output finish\n");
}

static bool visionchip_diff_ok(struct test_info *info)
{
	struct visionchip_test *t = to_visionchip(info);
	int total_err = 0;
	int i;

	contig_copy_from(t->hbuf, info->contig, 0, visionchip_size(t));

	int err;

	err = check_gold(t->sbuf, t->hbuf, t->rows * t->cols, t->verbose);
	if (err)
		printf("%d mismatches\n", err);

	total_err += err;

	if (t->verbose) {
		for (i = 0; i < t->rows * t->cols; i++) {
			printf("      \t%d : %d\n", i, t->hbuf[i]);
		}
		printf("\n");
	}
	if (total_err)
		printf("%d mismatches in total\n", total_err);
	return !total_err;
}

static struct visionchip_test visionchip_test = {
	.info = {
		.name		= NAME,
		.devname	= DEVNAME,
		.alloc_buf	= visionchip_alloc_buf,
		.alloc_contig	= visionchip_alloc_contig,
		.init_bufs	= visionchip_init_bufs,
		.set_access	= visionchip_set_access,
		.comp		= visionchip_comp,
		.diff_ok	= visionchip_diff_ok,
		.esp		= &visionchip_test.desc.esp,
		.cm		= VISIONCHIP_IOC_ACCESS,
	},
};

static void NORETURN usage(void)
{
	fprintf(stderr, "%s", usage_str);
	exit(1);
}

int main(int argc, char *argv[])
{
	if (argc < 3)
		usage();

	if (argc == 4) {
		if (strcmp(argv[3], "-v"))
			usage();
		visionchip_test.verbose = true;
	}

	visionchip_test.rows = 16;
	visionchip_test.cols = 16;

	return test_main(&visionchip_test.info, argv[1], argv[2]);
}


