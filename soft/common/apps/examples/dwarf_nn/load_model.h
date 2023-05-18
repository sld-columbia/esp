// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <stdio.h>
#include <stdlib.h>

void load_model(float* test_1,float** w_conv,float** bias_conv,float** w_fc,float** bias_fc)
{

	FILE* inFile0=fopen("data/dwarf_model1/ship.bin","rb");

	if (inFile0!=NULL)
	{
		fread(test_1,sizeof(float),3072,inFile0);
		fclose(inFile0);
	}
	else {
		printf("Can't find input image");
	}

	FILE* inFile1 =fopen("data/dwarf_model1/conv1.bin","rb");

        if (inFile1!=NULL)
        {
		fread(w_conv[0],sizeof(float),864,inFile1);
		fclose(inFile1);
                /* inFile.close(); // CLose input file */
        }
        else { //Error message
		printf("Can't find input file conv1 ");
        }

	FILE* inFile2 =fopen("data/dwarf_model1/conv2.bin","rb");
        
        if (inFile2!=NULL)
        {
		fread(w_conv[1],sizeof(float),9216,inFile2);
		fclose(inFile2);
        }
        else { //Error message
		printf("Can't find input file conv2 ");
        }

	FILE* inFile3 =fopen("data/dwarf_model1/conv3.bin","rb");
        
        if (inFile3!=NULL)
        {
		fread(w_conv[2],sizeof(float),18432,inFile3);
		fclose(inFile3);
        }
        else { //Error message
		printf("Can't find input file conv3 ");
        }

	FILE* inFile4 =fopen("data/dwarf_model1/conv4.bin","rb");
        
        if (inFile4!=NULL)
        {
		fread(w_conv[3],sizeof(float),73728,inFile4);
		fclose(inFile4);
        }
        else { //Error message
		printf("Can't find input file conv4 ");
        }

	FILE* inFile5 =fopen("data/dwarf_model1/bias1.bin","rb");
        
        if (inFile5!=NULL)
        {
		fread(bias_conv[0],sizeof(float),32,inFile5);
		fclose(inFile5);
        }
        else { //Error message
		printf("Can't find input file bias1 ");
        }
	FILE* inFile6 =fopen("data/dwarf_model1/bias2.bin","rb");
        
        if (inFile6!=NULL)
        {
		fread(bias_conv[1],sizeof(float),32,inFile6);
		fclose(inFile6);
        }
        else { //Error message
		printf("Can't find input file bias2 ");
        }

	FILE* inFile7 =fopen("data/dwarf_model1/bias3.bin","rb");
        
        if (inFile7!=NULL)
        {
		fread(bias_conv[2],sizeof(float),64,inFile7);
		fclose(inFile7);
        }
        else { //Error message
		printf("Can't find input file bias3 ");
        }

	FILE* inFile_7 =fopen("data/dwarf_model1/bias4.bin","rb");
        
        if (inFile_7!=NULL)
        {
		fread(bias_conv[3],sizeof(float),128,inFile_7);
		fclose(inFile_7);
        }
        else { //Error message
		printf("Can't find input file bias4 ");
        }

	FILE* inFile_8 =fopen("data/dwarf_model1/bias5.bin","rb");
        
        if (inFile_8!=NULL)
        {
		fread(bias_fc[0],sizeof(float),64,inFile_8);
		fclose(inFile_8);
        }
        else { //Error message
		printf("Can't find input file bias5 ");
        }
	FILE* inFile_9 =fopen("data/dwarf_model1/bias6.bin","rb");
        
        if (inFile_9!=NULL)
        {
		fread(bias_fc[1],sizeof(float),10,inFile_9);
		fclose(inFile_9);
        }
        else { //Error message
		printf("Can't find input file bias6c ");
        }

	FILE* inFile8 =fopen("data/dwarf_model1/fc1.bin","rb");
        
        if (inFile8!=NULL)
        {
		fread(w_fc[0],sizeof(float),131072,inFile8);
		fclose(inFile8);
        }
        else { //Error message
		printf("Can't find input file fc1 ");
        }

	FILE* inFile9 =fopen("data/dwarf_model1/fc2.bin","rb");
        
        if (inFile8!=NULL)
        {
		fread(w_fc[1],sizeof(float),640,inFile9);
		fclose(inFile8);
        }
        else { //Error message
		printf("Can't find input file fc2 ");
        }

}

