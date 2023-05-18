// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <stdio.h>
#include <stdlib.h>

void load_model(float* test_1,float* w_conv0,float* w_conv1,float* w_skip1,float*w_conv3,float* w_skip3, float*w_conv5,float* w_skip5,float*linear)
{

	FILE* inFile0=fopen("convnet_model1/test_1.bin","rb");

	if (inFile0!=NULL)
	{
		fread(test_1,sizeof(float),3072,inFile0);
		fclose(inFile0);
	}
	else {
		printf("Can't find input file test_1");
	}

	FILE* inFile1 =fopen("convnet_model1/w_conv0.bin","rb");

        if (inFile1!=NULL)
        {
		fread(w_conv0,sizeof(float),432,inFile1);
		fclose(inFile1);
                /* inFile.close(); // CLose input file */
        }
        else { //Error message
		printf("Can't find input file conv0 ");
        }

	FILE* inFile2 =fopen("convnet_model1/w_conv1.bin","rb");
        
        if (inFile2!=NULL)
        {
		fread(w_conv1,sizeof(float),4608,inFile2);
		fclose(inFile2);
        }
        else { //Error message
		printf("Can't find input file conv1 ");
        }

	FILE* inFile3 =fopen("convnet_model1/w_conv3.bin","rb");
        
        if (inFile3!=NULL)
        {
		fread(w_conv3,sizeof(float),18432,inFile3);
		fclose(inFile3);
        }
        else { //Error message
		printf("Can't find input file conv3 ");
        }

	FILE* inFile4 =fopen("convnet_model1/w_conv5.bin","rb");
        
        if (inFile4!=NULL)
        {
		fread(w_conv5,sizeof(float),73728,inFile4);
		fclose(inFile4);
        }
        else { //Error message
		printf("Can't find input file conv5 ");
        }


	FILE* inFile5 =fopen("convnet_model1/w_skip1.bin","rb");
        
        if (inFile5!=NULL)
        {
        	fread(w_skip1,sizeof(float),512,inFile5);
		fclose(inFile5);
        }
        else { //Error message
		printf("Can't find input file skip1 ");
        }

	FILE* inFile6 =fopen("convnet_model1/w_skip3.bin","rb");
        
        if (inFile6!=NULL)
        {
        	fread(w_skip3,sizeof(float),2048,inFile6);
		fclose(inFile6);
        }
        else { //Error message
		printf("Can't find input file skip3 ");
        }

	FILE* inFile7 =fopen("convnet_model1/w_skip5.bin","rb");
        
        if (inFile7!=NULL)
        {
        	fread(w_skip5,sizeof(float),8192,inFile7);
		fclose(inFile7);
        }
        else { //Error message
		printf("Can't find input file skip5 ");
        }

	FILE* inFile8 =fopen("convnet_model1/linear.bin","rb");
        
        if (inFile8!=NULL)
        {
		fread(linear,sizeof(float),256,inFile8);
		fclose(inFile8);
        }
        else { //Error message
		printf("Can't find input file linear ");
        }

}

