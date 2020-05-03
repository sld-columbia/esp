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

    fscanf(fp, "\n");

    *data = (float *) malloc(((*num_rows) *
          (*num_cols)) * sizeof(float));

    for (i = 0; i < *num_rows; i++)
    {
        for (j = 0; j < *num_cols; j++)
        {
            float _tmp;
            fscanf(fp, "%f", &_tmp);
            (*data)[(i * (*num_cols)) + j] = _tmp;
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
            fprintf(fp, " %f", data[(i * num_cols) + j]);
        }

        fprintf(fp, "\n");
    }

    fclose(fp);

    return 0;
}

#endif // __UTILS_H__
