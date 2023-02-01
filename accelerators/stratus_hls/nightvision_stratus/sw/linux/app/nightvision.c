// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <fcntl.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <my_stringify.h>
#include <nightvision_stratus.h>
#include <test/test.h>
#include <test/time.h>

#include <assert.h>
#include <errno.h>
#include <limits.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <byteswap.h>
#include <unistd.h>
#define _byteswap_ushort(p16) bswap_16(p16)
#define _byteswap_ulong(p32)  bswap_32(p32)
#define _byteswap_uint64(p64) bswap_64(p64)
#define MAX_PATH              (1024)
#define __int64 long long
#define _getcwd(a, b) getcwd(a, b)
#define _chdir(a)     chdir(a)

#define DEVNAME "/dev/nightvision_stratus.0"
#define NAME    "nightvision_stratus"

// Default command line arguments
#define DEFAULT_NIMAGES       1
#define DEFAULT_NROWS         120
#define DEFAULT_NCOLS         160
#define DEFAULT_NBYTESPP      2
#define DEFAULT_SWAPBYTES     0
#define DEFAULT_DO_DWT        1
#define DEFAULT_INFILE_IS_RAW 0
#define DEFAULT_NBPP_IN       16
#define DEFAULT_NBPP_OUT      10
typedef short pixel_t;

#define IMAGE_SRC_DIR "."
#define IMAGE_DST_DIR "."
#define MEDIAN_NELEM  (3 * 3)
#define USE_SHIFT

typedef float          fltPixel_t;
typedef unsigned short senPixel_t;
typedef int            algPixel_t;

#define ODD(A)    ((A)&0x01)
#define EVEN(A)   (!ODD(A))
#define ABS(X)    ((X) < 0 ? (-(X)) : (X))
#define MAX(A, B) ((A) > (B) ? (A) : (B))
#define MIN(A, B) ((A) < (B) ? (A) : (B))

#define DBGMSG(MSG)                                         \
    {                                                       \
        printf("%s, line %d: %s", __FILE__, __LINE__, MSG); \
    }

#define CLIP_INRANGE(LOW, VAL, HIGH) ((VAL) < (LOW) ? (LOW) : ((VAL) > (HIGH) ? (HIGH) : (VAL)))

int dwt53_row_transpose(algPixel_t *data, algPixel_t *data2, int nrows, int ncols)
{
    int i, j, cur;

    for (i = 0; i < nrows; i++) {
        // Predict the odd pixels using linear interpolation of the even pixels
        for (j = 1; j < ncols - 1; j += 2) {
            cur = i * ncols + j;
#ifdef USE_SHIFT
            data[cur] -= (data[cur - 1] + data[cur + 1]) >> 1;
#else
            data[cur] -= (algPixel_t)(0.5 * (data[cur - 1] + data[cur + 1]));
#endif
        }
        // The last odd pixel only has its left neighboring even pixel
        cur = i * ncols + ncols - 1;
        data[cur] -= data[cur - 1];

        // Update the even pixels using the odd pixels
        // to preserve the mean value of the pixels
        for (j = 2; j < ncols; j += 2) {
            cur = i * ncols + j;
#ifdef USE_SHIFT
            data[cur] += (data[cur - 1] + data[cur + 1]) >> 2;
#else
            data[cur] += (algPixel_t)(0.25 * (data[cur - 1] + data[cur + 1]));
#endif
        }
        // The first even pixel only has its right neighboring odd pixel
        cur = i * ncols + 0;
#ifdef USE_SHIFT
        data[cur] += data[cur + 1] >> 1;
#else
        data[cur] += (algPixel_t)(0.5 * data[cur + 1]);
#endif

        // Now rearrange the data putting the low
        // frequency components at the front and the
        // high frequency components at the back,
        // transposing the data at the same time

        for (j = 0; j < ncols / 2; j++) {
            data2[j * nrows + i]               = data[i * ncols + 2 * j];
            data2[(j + ncols / 2) * nrows + i] = data[i * ncols + 2 * j + 1];
        }
    }

    return 0;
}

int dwt53_row_transpose_inverse(algPixel_t *data, algPixel_t *data2, int nrows, int ncols)
{
    int i, j, cur;
    for (i = 0; i < nrows; i++) {
        // Rearrange the data putting the low frequency components at the front
        // and the high frequency components at the back, transposing the data
        // at the same time
        for (j = 0; j < ncols / 2; j++) {
            data2[i * ncols + 2 * j]     = data[j * nrows + i];
            data2[i * ncols + 2 * j + 1] = data[(j + ncols / 2) * nrows + i];
        }

        // Update the even pixels using the odd pixels
        // to preserve the mean value of the pixels
        for (j = 2; j < ncols; j += 2) {
            cur = i * ncols + j;
#ifdef USE_SHIFT
            data2[cur] -= ((data2[cur - 1] + data2[cur + 1]) >> 2);
#else
            data2[cur] -= (algPixel_t)(0.25 * (data2[cur - 1] + data2[cur + 1]));
#endif
        }
        // The first even pixel only has its right neighboring odd pixel
        cur = i * ncols + 0;
#ifdef USE_SHIFT
        data2[cur] -= (data2[cur + 1] >> 1);
#else
        data2[cur] -= (algPixel_t)(0.5 * data2[cur + 1]);
#endif

        // Predict the odd pixels using linear
        // interpolation of the even pixels
        for (j = 1; j < ncols - 1; j += 2) {
            cur = i * ncols + j;
#ifdef USE_SHIFT
            data2[cur] += ((data2[cur - 1] + data2[cur + 1]) >> 1);
#else
            data2[cur] += (algPixel_t)(0.5 * (data2[cur - 1] + data2[cur + 1]));
#endif
        }
        // The last odd pixel only has its left neighboring even pixel
        cur = i * ncols + ncols - 1;
        data2[cur] += data2[cur - 1];
    }

    return 0;
}

int dwt53_inverse(algPixel_t *data, int nrows, int ncols)
{
    int         err   = 0;
    algPixel_t *data2 = (algPixel_t *)calloc(nrows * ncols, sizeof(algPixel_t));
    if (!data2) {
        perror("Could not allocate temp space for dwt53_inverse op");
        return -1;
    }

    err = dwt53_row_transpose_inverse(data, data2, ncols, nrows);
    err = dwt53_row_transpose_inverse(data2, data, nrows, ncols);

    free(data2);

    return err;
}

int dwt53(algPixel_t *data, int nrows, int ncols)
{
    int         err   = 0;
    algPixel_t *data2 = (algPixel_t *)calloc(nrows * ncols, sizeof(algPixel_t));
    if (!data2) {
        fprintf(stderr, "File %s, Line %d, Memory Allocation Error", __FILE__, __LINE__);
        return -1;
    }

    // First do all rows; This function will transpose the data
    // as it performs its final shuffling

    err = dwt53_row_transpose(data, data2, nrows, ncols);

    // We next do all the columns (they are now the rows)

    err = dwt53_row_transpose(data2, data, ncols, nrows);

    free(data2);

    return err;
}

int hist(algPixel_t *streamA, int *h, int nRows, int nCols, int nBpp)
{
    int nBins = 1 << nBpp;
    int nPxls = nRows * nCols;
    int i     = 0;

    if (h == (int *)NULL) {
        fprintf(stderr, "File %s, Line %d, Memory Allocation Error\n", __FILE__, __LINE__);
        return -1;
    }

    memset((void *)h, 0, nBins * sizeof(int));

    for (i = 0; i < nPxls; i++) {
        if (streamA[i] >= nBins) {
            fprintf(stderr, "File %s, Line %d, Range Error in hist() -- using max val ---", __FILE__, __LINE__);
            h[nBins - 1]++;
        } else {
            h[(int)streamA[i]]++;
        }
    }

    return 0;
}

int histEq(algPixel_t *streamA, algPixel_t *out, int *h, int nRows, int nCols, int nInpBpp, int nOutBpp)
{
    int  nOutBins = (1 << nOutBpp);
    int  nInpBins = (1 << nInpBpp);
    int *CDF      = (int *)calloc(nInpBins, sizeof(int));
    int *LUT      = (int *)calloc(nInpBins, sizeof(int));

    if (!(CDF && LUT)) { // Ok to call free() on potentially NULL pointer
        free(CDF);
        free(LUT);
        fprintf(stderr, "File %s, Line %d, Memory Allocation Error\n", __FILE__, __LINE__);
        return -1;
    }

    int CDFmin = INT_MAX;
    int sum    = 0;
    int nPxls  = nRows * nCols;
    int i      = 0;

    for (i = 0; i < nInpBins; i++) {
        sum += h[i];
        CDF[i] = sum;
    }

    for (i = 0; i < nInpBins; i++) {
        CDFmin = MIN(CDFmin, h[i]);
    }

    for (i = 0; i < nInpBins; i++) {
        LUT[i] = ((CDF[i] - CDFmin) * (nOutBins - 1)) / (nPxls - CDFmin);
    }

    for (i = 0; i < nPxls; i++) {
        out[i] = LUT[(int)streamA[i]];
    }

    free(CDF);
    free(LUT);

    return 0;
}

int comparePxls(const void *arg1, const void *arg2)
{
    algPixel_t *p1 = (algPixel_t *)arg1;
    algPixel_t *p2 = (algPixel_t *)arg2;

    if (*p1 < *p2)
        return -1;
    else if (*p1 == *p2)
        return 0;
    else
        return 1;
}

int slowMedian3x3(algPixel_t *src, algPixel_t *dst, int nRows, int nCols)
{
    int         i = 0, j = 0, k = 0;
    int         r = 0, c = 0;
    algPixel_t *pxlList = (algPixel_t *)calloc(MEDIAN_NELEM, sizeof(algPixel_t));

    if (!pxlList) {
        fprintf(stderr, "File %s, Line %d, Memory Allocation Error\n", __FILE__, __LINE__);
        return -1;
    }

    for (r = 1; r < nRows - 1; r++) {
        for (c = 1; c < nCols - 1; c++) {
            k = 0;
            for (i = -1; i <= 1; i++) {
                for (j = -1; j <= 1; j++) {
                    pxlList[k++] = src[(r + i) * nCols + c + j];
                }
            }
            qsort((void *)pxlList, MEDIAN_NELEM, sizeof(algPixel_t), comparePxls);
            // qsort() really not necessary for such a small array,
            // but it works and I don't care about speed right now.
            dst[r * nCols + c] = pxlList[4];
        }
    }
    free(pxlList);
    return 0;
}

int nf(algPixel_t *streamA, algPixel_t *out, int nRows, int nCols)
{
    int err = 0;
    err     = slowMedian3x3(streamA, out, nRows, nCols);

    return err;
}

int readFrame(FILE *fp, void *image, int nPxls, int nBytesPerPxl, bool bSwap)
{
    /* __int64 *p64 = (__int64 *)image; */
    unsigned long * p32       = (unsigned long *)image;
    unsigned short *p16       = (unsigned short *)image;
    int             nPxlsRead = 0;
    int             i         = 0;

    if (fp == (FILE *)NULL) {
        fprintf(stderr, "File %s, Line %d, NULL fp passed to readFrame()\n", __FILE__, __LINE__);
        return -1;
    }

    nPxlsRead = fread(image, nBytesPerPxl, nPxls, fp);

    if (bSwap) {
        for (i = 0; i < nPxlsRead; i++) {
            /* printf("[%d]: raw-noswap=%hu\n", */
            /*        i, *p16); */

            if (nBytesPerPxl == sizeof(unsigned short)) {
                *p16 = _byteswap_ushort(*p16);
                p16++;
            } else if (nBytesPerPxl == sizeof(unsigned long)) {
                *p32 = _byteswap_ulong(*p32);
                p32++;
            }
            /* else if (nBytesPerPxl == sizeof(unsigned __int64)) */
            /* { */
            /* 	*p64 = _byteswap_uint64(*p64); */
            /* 	p64++; */
            /* } */
        }
    }

    return nPxlsRead;
}

// Supply "." for srcDir if files reside in current working directory

int readImage(void *image, char *srcDir, char *fileName, int nRows, int nCols, int nFrames, int nBytesPerPxl,
              bool bSwap)
{
    char *          origDir   = NULL;
    __int64 *       p64       = (__int64 *)image;
    unsigned long * p32       = (unsigned long *)image;
    unsigned short *p16       = (unsigned short *)image;
    int             nPxlsRead = 0;
    int             i         = 0;

    origDir = _getcwd(NULL, MAX_PATH);
    if (_chdir(srcDir) == -1) {
        fprintf(stderr, "File %s, Line %d, Could not change to directory=%s\n", __FILE__, __LINE__, srcDir);
        return -1;
    }

    FILE *fp = fopen(fileName, "rb");
    if (fp == (FILE *)NULL) {
        fprintf(stderr, "File %s, Line %d, Could not open %s for reading\n", __FILE__, __LINE__, fileName);
        return -2;
    }
    nPxlsRead = fread(image, nBytesPerPxl, nRows * nCols * nFrames, fp);
    fclose(fp);

    if (bSwap) {
        for (i = 0; i < nPxlsRead; i++) {
            if (nBytesPerPxl == sizeof(unsigned short)) {
                *p16 = _byteswap_ushort(*p16);
                p16++;
            } else if (nBytesPerPxl == sizeof(unsigned long)) {
                *p32 = _byteswap_ulong(*p32);
                p32++;
            } else if (nBytesPerPxl == sizeof(unsigned __int64)) {
                *p64 = _byteswap_uint64(*p64);
                p64++;
            }
        }
    }

    _chdir(origDir);
    free(origDir);

    return nPxlsRead;
}

int saveFrame(void *image, char *dstDir, char *baseFileName, int nRows, int nCols, int frameNo, int nBytesPerPxl,
              bool bSwap)
{
    // char *origDir = NULL;
    __int64 *       p64 = (__int64 *)image;
    unsigned long * p32 = (unsigned long *)image;
    unsigned short *p16 = (unsigned short *)image;

    char fullFileName[MAX_PATH];
    int  nPxlsToWrite = nRows * nCols;
    // int err = 0;
    int i = 0;

    // origDir = _getcwd(NULL, MAX_PATH);

    if (_chdir(dstDir) == -1) {
        fprintf(stderr, "File %s, Line %d, Could not change to directory=%s\n", __FILE__, __LINE__, dstDir);
        return -1;
    }

    sprintf(fullFileName, "outputs/out_%dx%d.raw", nCols, nRows);
    if (bSwap) {
        for (i = 0; i < nPxlsToWrite; i++) {
            if (nBytesPerPxl == sizeof(unsigned short)) {
                *p16 = _byteswap_ushort(*p16);
                p16++;
            } else if (nBytesPerPxl == sizeof(unsigned long)) {
                *p32 = _byteswap_ulong(*p32);
                p32++;
            } else if (nBytesPerPxl == sizeof(unsigned __int64)) {
                *p64 = _byteswap_uint64(*p64);
                p64++;
            }
        }
    }
    FILE *fp = fopen(fullFileName, "wb");
    if (fp == (FILE *)NULL) {
        fprintf(stderr, "File %s, Line %d, Failed fopen() on file: %s\n", __FILE__, __LINE__, fullFileName);
        return -1;
    }
    if (fwrite((void *)image, nBytesPerPxl, nPxlsToWrite, fp) != (size_t)nPxlsToWrite) {
        fclose(fp);
        fprintf(stderr, "File %s, Line %d, Failed fwrite() on file: %s\n", __FILE__, __LINE__, fullFileName);
        return -1;
    }
    fclose(fp);
    // err = _chdir(origDir);
    return nPxlsToWrite * nBytesPerPxl;
}

int ensemble_1(algPixel_t *streamA, algPixel_t *out, int nRows, int nCols, int nInpBpp, int nOutBpp)
{
    // NF
    // H
    // HE
    // DWT

    int         err       = 0;
    int         i         = 0;
    int         nHistBins = 1 << nInpBpp;
    int *       h         = (int *)calloc(nHistBins, sizeof(int));
    algPixel_t *wrkBuf1   = (algPixel_t *)calloc(nRows * nCols, sizeof(algPixel_t));
    algPixel_t *wrkBuf2   = (algPixel_t *)calloc(nRows * nCols, sizeof(algPixel_t));

    if (!(h && wrkBuf1 && wrkBuf2)) {
        free(h);
        free(wrkBuf1);
        free(wrkBuf2);
        fprintf(stderr, "File %s, Line %d, Memory Allocation Error\n", __FILE__, __LINE__);
        return -1;
    }

    memcpy(wrkBuf1, streamA, nRows * nCols * sizeof(algPixel_t));
    // memcpy(wrkBuf2, streamA, nRows * nCols * sizeof(algPixel_t));
    memset(wrkBuf2, 0, nRows * nCols * sizeof(algPixel_t));

    FILE *fileInput = fopen("input.txt", "w");
    for (i = 0; i < nRows * nCols; i++) {
        fprintf(fileInput, "%d\n", wrkBuf1[i]);
    }
    fclose(fileInput);

    err          = nf(wrkBuf1, wrkBuf2, nRows, nCols);
    FILE *fileNF = fopen("AfterNF.txt", "w");
    for (i = 0; i < nRows * nCols; i++) {
        fprintf(fileNF, "%d\n", wrkBuf2[i]);
    }
    fclose(fileNF);

    err            = hist(wrkBuf2, h, nRows, nCols, nInpBpp);
    FILE *fileHist = fopen("AfterHist.txt", "w");
    for (i = 0; i < nHistBins; i++) {
        fprintf(fileHist, "%d\n", h[i]);
    }
    fclose(fileHist);

    err              = histEq(wrkBuf2, out, h, nRows, nCols, nInpBpp, nOutBpp);
    FILE *fileHistEq = fopen("AfterHistEq.txt", "w");
    for (i = 0; i < nRows * nCols; i++) {
        fprintf(fileHistEq, "%d\n", out[i]);
    }
    fclose(fileHistEq);

    if (DEFAULT_DO_DWT) {
        err = dwt53(out, nRows, nCols);
    }
    FILE *fileDWT = fopen("AfterDWT.txt", "w");
    for (i = 0; i < nRows * nCols; i++) {
        fprintf(fileDWT, "%d\n", out[i]);
    }
    fclose(fileDWT);

    // FOR TESTING, INVERT BACK TO GET DECENT IMAGE FOR COMPARISON...
    // dwt53_inverse(wrkBuf2, nRows, nCols);

    // memcpy(out, wrkBuf2, nRows * nCols * sizeof(algPixel_t));

    free(wrkBuf2);
    free(wrkBuf1);
    free(h);

    return err;
}

static const char usage_str[] = "usage: ./nightvision_stratus.exe coherence infile [nimages] [ncols] [nrows] [-v]\n"
                                "  coherence: none|llc-coh-dma|coh-dma|coh\n"
                                "  infile : input file name (includes the path)\n\n"
                                "Optional arguments:.\n"
                                "  nimages : number of images to be processed. Default: 1\n"
                                "  ncols: number of columns of input image. Default: 160\n"
                                "  nrows: number of rows of input image. Default: 120\n\n\n"
                                "The remaining option is only optional for 'test':\n"
                                "  -v: enable verbose output for output-to-gold comparison\n"
                                "Notice:\n"
                                "  The ordering of the argument is important. For now nimages, nrows\n"
                                "  and ncols should either be all present or not at all.\n";

struct nightvision_test {
    struct test_info                  info;
    struct nightvision_stratus_access desc;
    char *                            infile;
    bool                              infile_is_raw;
    unsigned                          nimages;
    unsigned                          rows;
    unsigned                          cols;
    unsigned                          nbytespp;
    unsigned                          swapbytes;
    unsigned                          do_dwt;
    unsigned                          nbpp_in;
    unsigned                          nbpp_out;
    pixel_t *                         hbuf;
    int *                             sbuf_in;
    int *                             sbuf_out;
    bool                              verbose;
};

static inline struct nightvision_test *to_nightvision(struct test_info *info)
{
    return container_of(info, struct nightvision_test, info);
}

static int check_gold(int *gold, pixel_t *array, unsigned len, bool verbose)
{
    int i;
    int rtn = 0;
    for (i = 0; i < len; i++) {
        if (((int)array[i]) != gold[i]) {
            if (verbose)
                printf("A[%d]: array=%d; gold=%d\n", i, (int)array[i], gold[i]);
            rtn++;
        }
    }

    return rtn;
}

static void init_buf(struct nightvision_test *t)
{
    // TODO load raw and repeat image in buffer as many times as nimages

    //  ========================  ^
    //  |  in/out image (int)  |  | img_size (in bytes)
    //  ========================  v

    printf("init buffers\n");

    int             i = 0, j = 0, hbuf_i = 0;
    unsigned        nPxls;
    FILE *          fd = NULL;
    unsigned short *rawBuf;

    // open input file
    if (t->infile_is_raw) {
        if ((fd = fopen(t->infile, "rb")) == (FILE *)NULL) {
            printf("[ERROR] Could not open %s\n", t->infile);
            exit(1);
        }
    } else {
        if ((fd = fopen(t->infile, "r")) == (FILE *)NULL) {
            printf("[ERROR] Could not open %s\n", t->infile);
            exit(1);
        }
    }

    // allocate buffers
    nPxls  = t->rows * t->cols;
    rawBuf = (unsigned short *)calloc(nPxls, sizeof(unsigned short));

    if (!rawBuf) {
        free(rawBuf);
        printf("[ERROR] Could not allocate buffer (in init_buf())\n");
        exit(1);
    }

    if (t->infile_is_raw) {
        // read raw image file
        if (readFrame(fd, rawBuf, nPxls, t->nbytespp, t->swapbytes) != nPxls) {
            printf("[ERROR] readFrame returns wrong number of pixels\n");
            exit(1);
        }
    } else {
        // read txt image file
        int      i   = 0;
        uint16_t val = 0;

        fscanf(fd, "%hu", &val);
        while (!feof(fd)) {
            rawBuf[i++] = val;
            fscanf(fd, "%hu", &val);
        }

        fclose(fd);
    }

    // store image in accelerator buffer
    // repeat image according to nimages parameter
    hbuf_i = 0;
    for (i = 0; i < t->nimages; i++) {
        for (j = 0; j < nPxls; j++) {
            t->hbuf[hbuf_i]    = (pixel_t)rawBuf[j];
            t->sbuf_in[hbuf_i] = (int)rawBuf[j];
            hbuf_i++;
        }
    }

    free(rawBuf);
    fclose(fd);
}

static inline size_t nightvision_size(struct nightvision_test *t)
{
    return t->rows * t->cols * t->nimages * sizeof(int);
}

static inline size_t nightvision_size_opt(struct nightvision_test *t)
{
    return t->rows * t->cols * t->nimages * sizeof(short);
}

static void nightvision_alloc_buf(struct test_info *info)
{
    struct nightvision_test *t = to_nightvision(info);

    t->hbuf = malloc0_check(nightvision_size_opt(t));
    if (!strcmp(info->cmd, "test")) {
        t->sbuf_in  = malloc0_check(nightvision_size(t));
        t->sbuf_out = malloc0_check(nightvision_size(t));
    }
}

static void nightvision_alloc_contig(struct test_info *info)
{
    struct nightvision_test *t = to_nightvision(info);

    printf("HW buf size: %zu B\n", nightvision_size(t));
    if (contig_alloc(nightvision_size(t), &info->contig) == NULL)
        die_errno(__func__);
}

static void nightvision_init_bufs(struct test_info *info)
{
    struct nightvision_test *t = to_nightvision(info);

    init_buf(t);
    contig_copy_to(info->contig, 0, t->hbuf, nightvision_size_opt(t));
}

static void nightvision_set_access(struct test_info *info)
{
    struct nightvision_test *t = to_nightvision(info);

    t->desc.nimages    = t->nimages;
    t->desc.rows       = t->rows;
    t->desc.cols       = t->cols;
    t->desc.do_dwt     = t->do_dwt;
    t->desc.src_offset = 0;
    t->desc.dst_offset = 0;
}

static void nightvision_comp(struct test_info *info)
{
    struct nightvision_test *t      = to_nightvision(info);
    int                      i      = 0;
    int                      algErr = 0, numOut = 0;

    int *buf_in  = NULL;
    int *buf_out = NULL;

    printf("nightvision_comp\n");

    for (i = 0; i < t->nimages; i++) {
        buf_in  = &(t->sbuf_in[i * t->cols * t->rows]);
        buf_out = &(t->sbuf_out[i * t->cols * t->rows]);
        algErr |= ensemble_1(buf_in, buf_out, t->rows, t->cols, t->nbpp_in, t->nbpp_out);
        assert(algErr == 0);
    }

    if (t->infile_is_raw) {
        // save raw output image
        numOut = saveFrame(buf_out, ".", "ensemble1", t->rows, t->cols, 0, sizeof(int), false);
        assert(numOut == t->rows * t->cols * sizeof(int));
    } else {
        // save txt output image

        FILE *fileOut = NULL;
        if ((fileOut = fopen("out.txt", "w")) == (FILE *)NULL) {
            printf("[ERROR] Could not open out.txt\n");
            fclose(fileOut);
        }

        // store output file
        int npixels = t->nimages * t->rows * t->cols;

        for (i = 0; i < npixels; i++) {
            fprintf(fileOut, "%d\n", (int)t->hbuf[i]);
        }

        fclose(fileOut);
    }

    // -- Read gold output
    /* printf("read gold output start\n"); */

    /* int i = 0; */
    /* int val = 0; */
    /* FILE *fd = NULL; */

    /* if((fd = fopen("./gold_output.txt", "r")) == (FILE*)NULL) */
    /* { */
    /*         printf("[Err] could not open ./gold_output.txt\n"); */
    /*         fclose(fd); */
    /* } */

    /* fscanf(fd, "%d", &val); */
    /* while(!feof(fd)) */
    /* { */
    /*         t->sbuf_in[i++] = val; */
    /*         fscanf(fd, "%d", &val); */
    /* } */

    /* fclose(fd); */

    /* printf("read gold output finish\n"); */
}

static bool nightvision_diff_ok(struct test_info *info)
{
    struct nightvision_test *t         = to_nightvision(info);
    int                      total_err = 0;
    int                      i;

    contig_copy_from(t->hbuf, info->contig, 0, nightvision_size_opt(t));

    int err;

    err = check_gold(t->sbuf_out, t->hbuf, t->rows * t->cols * t->nimages, t->verbose);

    FILE *fileSBUF = fopen("SBUF.txt", "w");
    for (i = 0; i < t->rows * t->cols; i++) {
        fprintf(fileSBUF, "%d\n", t->sbuf_out[i]);
    }
    fclose(fileSBUF);

    FILE *fileHBUF = fopen("HBUF.txt", "w");
    for (i = 0; i < t->rows * t->cols; i++) {
        fprintf(fileHBUF, "%d\n", t->hbuf[i]);
    }
    fclose(fileHBUF);

    if (err)
        printf("%d mismatches\n", err);

    total_err += err;

    /*
    if (t->verbose) {
        for (i = 0; i < t->rows * t->cols * t->nimages; i++) {
            printf("      \t%d : %d\n", i, t->hbuf[i]);
        }
        printf("\n");
    }
    */
    if (total_err)
        printf("%d mismatches in total\n", total_err);
    return !total_err;
}

static struct nightvision_test nightvision_test = {
    .info =
        {
            .name         = NAME,
            .devname      = DEVNAME,
            .alloc_buf    = nightvision_alloc_buf,
            .alloc_contig = nightvision_alloc_contig,
            .init_bufs    = nightvision_init_bufs,
            .set_access   = nightvision_set_access,
            .comp         = nightvision_comp,
            .diff_ok      = nightvision_diff_ok,
            .esp          = &nightvision_test.desc.esp,
            .cm           = NIGHTVISION_STRATUS_IOC_ACCESS,
        },
};

static void NORETURN usage(void)
{
    fprintf(stderr, "%s", usage_str);
    exit(1);
}

/*
 * The app currently has some hard-coded parameters, that should be made configurable.:
 * - do_dwt = false. DWT always disabled. This means that the output of the accelerator
 *   is expected to be unsigned.
 * - in/out images in TXT format only, although the RAW format is supported as well
 * - word bitwidth and related data type, it should be extracted from the HLS config of
 *   the accelerator. NBPP_IN and NBPP_OUT.
 */
int main(int argc, char *argv[])
{
    printf("=== Helloo from nightvision\n");
    if (argc < 3 || argc == 5 || argc > 7) {
        usage();

    } else {
        printf("\nCommand line arguments received:\n");
        printf("\tcoherence: %s\n", argv[1]);

        nightvision_test.infile = argv[2];
        printf("\tinfile: %s\n", nightvision_test.infile);

        if (argc == 6 || argc == 7) {
            nightvision_test.nimages = strtol(argv[3], NULL, 10);
            nightvision_test.cols    = strtol(argv[4], NULL, 10);
            nightvision_test.rows    = strtol(argv[5], NULL, 10);
            printf("\tnimages: %u\n", nightvision_test.nimages);
            printf("\tncols: %u\n", nightvision_test.cols);
            printf("\tnrows: %u\n", nightvision_test.rows);
        } else {
            nightvision_test.nimages = DEFAULT_NIMAGES;
            nightvision_test.rows    = DEFAULT_NROWS;
            nightvision_test.cols    = DEFAULT_NCOLS;
        }

        if (argc == 4 || argc == 7) {
            if ((strcmp(argv[3], "-v") && argc == 4) || (strcmp(argv[6], "-v") && argc == 7)) {
                usage();
            } else {
                nightvision_test.verbose = true;
                printf("\tverbose enabled\n");
            }
        }
        nightvision_test.nbytespp      = DEFAULT_NBYTESPP;
        nightvision_test.swapbytes     = DEFAULT_SWAPBYTES;
        nightvision_test.do_dwt        = DEFAULT_DO_DWT;
        nightvision_test.infile_is_raw = DEFAULT_INFILE_IS_RAW;
        nightvision_test.nbpp_in       = DEFAULT_NBPP_IN;
        nightvision_test.nbpp_out      = DEFAULT_NBPP_OUT;
        printf("\n");
    }

    return test_main(&nightvision_test.info, argv[1], "test");
}
