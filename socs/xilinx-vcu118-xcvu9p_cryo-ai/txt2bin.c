#include <stdio.h>
#include <stdlib.h>

	char *file_name = "ad03_cxx_catapult_in.txt";
	char *file_name_out = "ad03_cxx_catapult_in_bin.txt";
	//char *file_name = "ad03_cxx_catapult_out.txt";
	//char *file_name_out = "ad03_cxx_catapult_out_bin.txt";
	FILE *fptr, *fptr2;
	char line [8];
	char buff[4];

int main()
{
    int i = 0;
	int j = 0;
	int k;
	signed char value;
	signed char *out_buff;
	signed char *le_end_buff;
	int val;
	unsigned file_size;

	fptr = fopen(file_name, "r");
	if (fptr == NULL) {
		printf ("file nor found \n");
		return -1;
	}
	
	fptr2 = fopen(file_name_out, "wb");
	if (fptr2 == NULL) {
		printf ("file nor found \n");
		return -1;
	}

	file_size = 0;
	//while (EOF != (fscanf(fptr, "%*[^\n]"), fscanf(fptr,"%*c")))
    //    ++file_size;

	file_size = 132;
	//fseek(fptr, 0L, SEEK_SET);
/*
	fseek(fptr, 0L, SEEK_END);
	file_size = ftell(fptr);
	fseek(fptr, 0L, SEEK_SET);
*/

	out_buff = malloc(sizeof (signed char) * file_size);
	if (out_buff == NULL)
		fprintf(stderr, "Error allocating buffer \n");

	while (fgets(line, sizeof(line), fptr)) {
		if (i == file_size)
			break;
		else {
			out_buff[i] = (signed char) atoi(line);
			printf("%i %x \n", atoi(line), out_buff[i]);
			i++;
		}
    }

/*
	le_end_buff = malloc(sizeof (char) * file_size);
	if (le_end_buff == NULL)
		fprintf(stderr, "Error allocating buffer \n");

	for(i = 0; i < file_size; i=i+4){
		for(j = 3, k = 0; j >= 0; j--, k++){
			le_end_buff[i+k] = out_buff[j+i];
		}
	}

	for(i = 0; i < file_size; i++)
		printf("%x %x %i \n", le_end_buff[i], out_buff[i], file_size);
*/
	fwrite(out_buff, 1, file_size, fptr2);

	fclose(fptr);
	fclose(fptr2);
	return 0;
}
