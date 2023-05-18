#include <iostream>
#include <string>
#include <cstring>
#include <sstream>
#include <fstream>

void load_model(float* test_1,float* w_conv0,float* w_conv1,float* w_skip1,float*w_conv3,float* w_skip3, float*w_conv5,float* w_skip5,float*linear)
{

	std::ifstream inFile ("../tb/convnet_tb/model/convnet_model/input.bin", std::ifstream::binary);
        if (inFile.is_open())
        {
            assert(inFile.read((char *) test_1, 3072 * sizeof(float)));
            inFile.close();
        }
        else {
		std::cout << "Can't find input file input.bin " << std::endl;
        }

        inFile.open("../tb/convnet_tb/model/convnet_model/w_conv0.bin", std::ifstream::binary);
        if (inFile.is_open())
        {
            assert(inFile.read((char *) w_conv0, 432 * sizeof(float)));
            inFile.close();
        }
        else {
		std::cout << "Can't find input file conv0" << std::endl;
        }

        inFile.open("../tb/convnet_tb/model/convnet_model/w_conv1.bin", std::ifstream::binary);
        if (inFile.is_open())
        {
            assert(inFile.read((char *) w_conv1, 4608 * sizeof(float)));
            inFile.close();
        }
        else {
		std::cout << "Can't find input file conv1" << std::endl;
        }

        inFile.open("../tb/convnet_tb/model/convnet_model/w_conv3.bin", std::ifstream::binary);
        if (inFile.is_open())
        {
            assert(inFile.read((char *) w_conv3, 18432 * sizeof(float)));
            inFile.close();
        }
        else {
		std::cout << "Can't find input file conv3 " << std::endl;
        }

        inFile.open("../tb/convnet_tb/model/convnet_model/w_conv5.bin", std::ifstream::binary);
        if (inFile.is_open())
        {
            assert(inFile.read((char *) w_conv5, 73728 * sizeof(float)));
            inFile.close();
        }
        else {
		std::cout << "Can't find input file conv5" << std::endl;
        }

        inFile.open("../tb/convnet_tb/model/convnet_model/w_skip1.bin", std::ifstream::binary);
        if (inFile.is_open())
        {
            assert(inFile.read((char *) w_skip1, 512 * sizeof(float)));
            inFile.close();
        }
        else {
		std::cout << "Can't find input file skip1" << std::endl;
        }

        inFile.open("../tb/convnet_tb/model/convnet_model/w_skip3.bin", std::ifstream::binary);
        if (inFile.is_open())
        {
            assert(inFile.read((char *) w_skip3, 2048 * sizeof(float)));
            inFile.close();
        }
        else {
		std::cout << "Can't find input file skip3" << std::endl;
        }

        inFile.open("../tb/convnet_tb/model/convnet_model/w_skip5.bin", std::ifstream::binary);
        if (inFile.is_open())
        {

            assert(inFile.read((char *) w_skip5, 8192 * sizeof(float)));
            inFile.close();
        }
        else {
		std::cout << "Can't find input file skip5" << std::endl;
        }

        inFile.open("../tb/convnet_tb/model/convnet_model/linear.bin", std::ifstream::binary);
        if (inFile.is_open())
        {
            assert(inFile.read((char *) linear, 256 * sizeof(float)));
            inFile.close();
        }
        else {
		std::cout << "Can't find input file linear" << std::endl;
        }





	// std::ifstream inFile ("../tb/convnet_tb/model/convnet_model/input.txt");
        // if (inFile.is_open())
        // {
        //         for (int i = 0; i < 3072; i++)
        //         {
        //                 inFile >> test_1[i];
        //         }

        //         inFile.close();
        // }
        // else {
	// 	std::cout << "Can't find input file input.txt " << std::endl;
        // }

        // inFile.open("../tb/convnet_tb/model/convnet_model/conv0.txt");
        // if (inFile.is_open())
        // {
        //         for (int i = 0; i < 432; i++)
        //         {
        //                 inFile >> w_conv0[i];
        //         }

        //         inFile.close();
        // }
        // else {
	// 	std::cout << "Can't find input file conv0" << std::endl;
        // }

        // inFile.open("../tb/convnet_tb/model/convnet_model/conv1.txt");
        // if (inFile.is_open())
        // {
        //         for (int i = 0; i < 4608; i++)
        //         {
        //                 inFile >> w_conv1[i];
	// 	}

        //         inFile.close();
        // }
        // else {
	// 	std::cout << "Can't find input file conv1" << std::endl;
        // }

        // inFile.open("../tb/convnet_tb/model/convnet_model/conv3.txt");
        // if (inFile.is_open())
        // {
        //         for (int i = 0; i < 18432; i++)
        //         {
        //                 inFile >> w_conv3[i];
        //         }

        //         inFile.close();
        // }
        // else { 
	// 	std::cout << "Can't find input file conv3 " << std::endl;
        // }

        // inFile.open("../tb/convnet_tb/model/convnet_model/conv5.txt");
        // if (inFile.is_open())
        // {
        //         for (int i = 0; i < 73728; i++)
        //         {
        //                 inFile >> w_conv5[i];
        //         }

        //         inFile.close();
        // }
        // else {
	// 	std::cout << "Can't find input file conv5" << std::endl;
        // }

        // inFile.open("../tb/convnet_tb/model/convnet_model/skip1.txt");
        // if (inFile.is_open())
        // {
        //         for (int i = 0; i < 512; i++)
        //         {
        //                 inFile >> w_skip1[i];
        //         }

        //         inFile.close();
        // }
        // else { 
	// 	std::cout << "Can't find input file skip1" << std::endl;
        // }

        // inFile.open("../tb/convnet_tb/model/convnet_model/skip3.txt");
        // if (inFile.is_open())
        // {
        //         for (int i = 0; i < 2048; i++)
        //         {
        //                 inFile >> w_skip3[i];
	// 	}

        //         inFile.close();
        // }
        // else { 
	// 	std::cout << "Can't find input file skip3" << std::endl;
        // }

        // inFile.open("../tb/convnet_tb/model/convnet_model/skip5.txt");
        // if (inFile.is_open())
        // {
        //         for (int i = 0; i < 8192; i++)
        //         {
        //                 inFile >> w_skip5[i];
        //         }
        //         inFile.close();
        // }
        // else { 
	// 	std::cout << "Can't find input file skip5" << std::endl;
        // }

        // inFile.open("../tb/convnet_tb/model/convnet_model/linear.txt");
        // if (inFile.is_open())
        // {
        //         for (int i = 0; i < 256; i++)
        //         {
        //                 inFile >> linear[i];
        //         }
        //         inFile.close(); 
        // }
        // else { 
	// 	std::cout << "Can't find input file linear" << std::endl;
        // }


}

