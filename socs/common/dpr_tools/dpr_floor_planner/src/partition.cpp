#include "partition.h"
#include <iostream>

using namespace std;

void Taskset::print()
{
    for(unsigned int i=0; i < HW_Tasks.size(); i++)
    {
        cout << "HW-Task " << i << endl;
        cout << "\t\t WCET = \t" << HW_Tasks[i].WCET << endl;
        cout << "\t\t RES_DEMAND:" << endl;
        for(unsigned int x=0; x < HW_Tasks[i].resDemand.size(); x++)
            cout << "\t\t\t #" << x << " = " << HW_Tasks[i].resDemand[x] << endl;
    }
}
