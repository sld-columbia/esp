#include "../dprc/bitstream.h"

dpr_test(unsigned int control_reg)
{

unsigned int *control_pointer=(unsigned int *)control_reg;
unsigned int *address_pointer=(unsigned int*)(control_reg+0x00000004);
unsigned int *status_pointer=(unsigned int*)(control_reg+0x00000008);
unsigned int *timer_pointer=(unsigned int*)(control_reg+0x0000000C);
unsigned int *reset_pointer=(unsigned int*)(control_reg+0x00000010);

//First reconfiguration
*address_pointer=(unsigned int)&bitstream0;
*reset_pointer=1;
*control_pointer=sizeof(bitstream0)/sizeof(int);

while( (((*status_pointer)&0x0F)!=15) && (((*status_pointer)&0x0F)!=1) && (((*status_pointer)&0x0F)!=8) && (((*status_pointer)&0x0F)!=4) && (((*status_pointer)&0x0F)!=2)){}

//Second reconfiguration
*address_pointer=(unsigned int)&bitstream1;
*control_pointer=sizeof(bitstream1)/sizeof(int);

while( (((*status_pointer)&0x0F)!=15) && (((*status_pointer)&0x0F)!=1) && (((*status_pointer)&0x0F)!=8) && (((*status_pointer)&0x0F)!=4) && (((*status_pointer)&0x0F)!=2)){}

}
