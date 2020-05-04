#ifndef __UTILS_H__
#define __UTILS_H__

int read_image_from_file(float **data, unsigned
    *num_rows, unsigned *num_cols, const char *name)
{
    unsigned tmp;
    unsigned i, j;

    FILE *fp = fopen(name, "r");

    if (!name || !fp)
    {
        fprintf(stderr, "File not found: %s\n", name);
        return -1;
    }

    fscanf(fp, "%u", &tmp);
    *num_rows = tmp;

    fscanf(fp, "%u", &tmp);
    *num_cols = tmp;

    *data = (float *) malloc(((*num_rows) *
          (*num_cols)) * sizeof(float));

    for (i = 0; i < *num_rows; i++)
    {
        for (j = 0; j < *num_cols; j++)
        {
            float ftmp = 0.0;
            uint32_t utmp = 0;
            fscanf(fp, "%x", &utmp);
            ftmp = (float) *((float*) &utmp);
            (*data)[(i * (*num_cols)) + j] = ftmp;
            /* assert (ftmp >= 0 && ftmp <= 256.0); */
        }
    }

    fclose(fp);

    return 0;
}

int write_image_to_file(float *data, unsigned
    num_rows, unsigned num_cols, const char *name)
{
    unsigned i, j;

    FILE *fp = fopen(name, "w");

    if (!name || !fp)
    {
        fprintf(stderr, "File not found: %s\n", name);
        return -1;
    }

    fprintf(fp, "%u %u\n", num_rows, num_cols);

    for (i = 0; i < num_rows; i++)
    {
        for (j = 0; j < num_cols; j++)
        {
            float ftmp = data[(i * num_cols) + j];
            assert (ftmp >= 0 && ftmp <= 256.0);
            fprintf(fp, " %f", ftmp);
        }

        fprintf(fp, "\n");
    }

    fclose(fp);

    return 0;
}

#endif // __UTILS_H__
