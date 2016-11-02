#ifndef GRLIB_REPORTDEV_CUSTOM

#ifndef GRLIB_REPORTDEV_WIDTH
/* Use 32 for AHBREP or GRTESTMOD with 32-bit width */
#define GRLIB_REPORTDEV_WIDTH 32
#endif

#if GRLIB_REPORTDEV_WIDTH == 32
#define REPORTDEV_OFFSET 1
typedef int testmod_type;
#elif GRLIB_REPORTDEV_WIDTH == 64
#define REPORTDEV_OFFSET 1
typedef long long testmod_type;
#else
#define REPORTDEV_OFFSET 2
typedef short testmod_type;
#endif

#ifndef GRLIB_REPORTDEV_BASE
#define GRLIB_REPORTDEV_BASE 0x20000000
#endif


volatile testmod_type *grtestmod = (volatile testmod_type *) GRLIB_REPORTDEV_BASE;
static void grtestmod_write(r,v)
{
	grtestmod[r*REPORTDEV_OFFSET] = v;
}

#endif /* ifndef GRLIB_REPORTDEV_CUSTOM */

report_start()
{
	if (!get_pid()) grtestmod_write(4,1);
	return(0);
}

report_end()
{
	grtestmod_write(5,1);
	return(0);
}

report_device(int dev)
{

#if GRLIB_REPORTDEV_WIDTH < 32
	grtestmod_write(0, dev >> (32 - GRLIB_REPORTDEV_WIDTH));
	grtestmod_write(3, dev);
#else
	grtestmod_write(0, dev);
#endif
	return(0);
}

report_subtest(int dev)
{
	grtestmod_write(2,dev);
	return(0);
}

fail(int dev)
{
	grtestmod_write(1,dev);
	return(0);
}

void chkp(int n)
{
	grtestmod_write(6,n);
}

void report_mem_test(void)
{
	grtestmod_write(7,1);
}

