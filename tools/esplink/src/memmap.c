/*
 * memmap.c
 *
 *  Created on: Dec 23, 2020
 *      Author: esco063
 */


#include "memmap_zcu.h"
#include "le_zcu.h"


void *  MMU_Remap(unsigned long int PhysAddr, unsigned long int MappedRange_Bytes){
        // ---------------------------------------
        // ------ OPEN SYSTEM MEMORY FOR RW -----
        int FileId = open("/dev/mem", O_RDWR|O_SYNC);
        if(FileId == -1){
                printf("Error Accessing dev/mem!\n");
                exit(EXIT_FAILURE);
        }
        // -------------------------------
        // ------- MAP THE ADDRESS -------
        void *Mapped_Addr = mmap(NULL, MappedRange_Bytes, PROT_READ|PROT_WRITE, MAP_SHARED|MAP_SYNC, FileId, PhysAddr);
        if(Mapped_Addr == MAP_FAILED){
                printf("Error mapping memory!\n");
                exit(EXIT_FAILURE);
        }
        return Mapped_Addr;
}

unsigned* uiomap()
{
	 return (void*) MMU_Remap(0x400000000, 0x100000000);
}

uint64_t * udmabufmap()
{
	int fd_udma0 =-1;
	if ((fd_udma0 = open("/dev/udmabuf_esp0", O_RDWR|O_SYNC)) != -1)                                                                //      {
	{
		return (uint64_t*) mmap((void*)0x40000000, 0x3fffffff, PROT_READ| PROT_WRITE, MAP_SHARED|MAP_SYNC, fd_udma0,0);
	}
	return NULL;
}

// Helper functions
//static void print_progress(u64 progress, u64 total, const char *prefix)
//{
//	const u32 symbols = 40;
//	int i;
//
//	u64 percent = progress * 100 / total;
//
//	u64 fraction = progress * symbols / total;
//
//	printf("%s: [", prefix);
//
//	for (i = 0; i < symbols; ++i) {
//		char c = i < fraction ? '#' : ' ';
//		printf("%c", c);
//	}
//
//	printf("] %lld%%", percent);
//	if (progress == total)
//		printf("\n");
//	else
//		printf("\r");
//	fflush(stdout);
//}
//
//static void set_offset(u8 *_m, u32 _x)
//{
//	_m[0] = (u8) (_x >> 8);
//	_m[1] = (u8) (_x >> 0);
//}
//
//static u32 get_offset(u8 *_m)
//{
//	u32 _x;
//	_x  = ((u32) _m[0]) << 8;
//	_x |= ((u32) _m[1]) << 0;
//	return _x;
//}

void set_sequence(u8 *_m, u32 _x)
{
	_m[2] = _m[2] | (u8) (0xff & ((_x << 2) >> 8));
	_m[3] = _m[3] | (u8) (0xff & ((_x << 2) >> 0));
}

u32 get_sequence(u8 *_m)
{
	u32 _x;
	_x  = (((u32) _m[2]) << 8) >> 2;
	_x |= (((u32) _m[3]) << 0) >> 2;
	return _x;
}

void set_write(u8 *_m, u32 _x)
{
	_m[3] = _m[3] | (u8) (_x << 1);
}

u32 get_nack(u8 *_m)
{
	u32 _x;
	_x = 0x1 & (((u32) _m[3]) >> 1);
	return _x;
}

void set_length(u8 *_m, u32 _x)
{
	_m[3] = _m[3] | (u8) (0xff & (_x >> 9));
	_m[4] = _m[4] | (u8) (0xff & (_x >> 1));
	_m[5] = _m[5] | (u8) (0xff & (_x << 7));
}
u32 get_length(u8 *_m)
{
	u32 _x;
	_x  = (0x1 & (u32) _m[3]) << 9;
	_x |=       ((u32) _m[4]) << 1;
	_x |=       ((u32) _m[5]) >> 7;
	return _x;
}

void set_address(u8 *_m, u32 _x)
{
	_m[6] = (u8) (0xff & (_x >> 24));
	_m[7] = (u8) (0xff & (_x >> 16));
	_m[8] = (u8) (0xff & (_x >> 8));
	_m[9] = (u8) (0xff & (_x >> 0));
}

u32 get_address(u8 *_m)
{
	u32 _x;
	_x  = ((u32) _m[6]) << 24;
	_x |= ((u32) _m[7]) << 16;
	_x |= ((u32) _m[8]) << 8;
	_x |= ((u32) _m[9]) << 0;
	return _x;
}

void set_data(u8 *_m, u32 *_x, u32 _n)
{
	u32 i;
	for (i = 0; i < _n; i++) {
		u32 index = i * 4 + 10;
		_m[index + 0] = (u8) (0xff & (_x[i] >> 24));
		_m[index + 1] = (u8) (0xff & (_x[i] >> 16));
		_m[index + 2] = (u8) (0xff & (_x[i] >> 8));
		_m[index + 3] = (u8) (0xff & (_x[i] >> 0));
	}
}

void get_data(u8 *_m, u32 *_x, u32 _n)
{
	u32 i;
	for (i = 0; i < _n; i++) {
		u32 index = i * 4 + 10;
		_x[i]  = ((u32) _m[index + 0]) << 24;
		_x[i] |= ((u32) _m[index + 1]) << 16;
		_x[i] |= ((u32) _m[index + 2]) << 8;
		_x[i] |= ((u32) _m[index + 3]) << 0;
	}
}


// memmap API Functions
void die(char *s)
{
	perror(s);
	exit(EXIT_FAILURE);
}

void load_memory(void* ptr, char *fname)
{
	u32 i;
	int r;
	u32 addr;
	u32 data;
	FILE *fp = fopen(fname, "r");
	if (!fp)
		die("fopen");
	for (i = 0; i < NWORD_MAX_SND; i++) {
		r = fscanf(fp, "%08x %08x\n", &addr, &data);
		memcpy(ptr+(addr>>2),&data,sizeof(u32));
		if (r == EOF)
			break;
		if (r != 2)
			die("fscanf");
	}

	fclose(fp);
}

void dump_memory_uio(unsigned* ptr, u32 address, u32 size, char *fname)
{
	FILE *fp = fopen(fname, "w+");
	if (!fp)
		die("fopen");
	fwrite(ptr+(address>>2), sizeof(u32), size/ sizeof(u32), fp);
	fclose(fp);

}

void load_memory_bin_uio(unsigned* ptr, u32 base_addr, char *fname)
{

	FILE *fp = fopen(fname, "rb");
	if (!fp)
		die("fopen");
	size_t sz;
	size_t rem;
	// Get binary size
	fseek(fp, 0L, SEEK_END);
	sz = ftell(fp);
	rewind(fp);
	rem = sz;
	//printf("Starting pointer: %p\n",ptr+(base_addr>>2));
	lefread_uio(ptr+(base_addr>>2), sizeof(u32), rem / sizeof(u32), fp);
	fclose(fp);
	/* clear_rcv_memmap(); */
	printf("Loaded %zu Bytes at %08x\n", sz, base_addr);
}

void dump_memory_bin_uio(unsigned* ptr, u32 address, u32 size, char *fname)
{


	FILE *fp = fopen(fname, "wb+");
	if (!fp)
		die("fopen");
	fwrite(ptr+(address>>2), sizeof(u32), size/ sizeof(u32), fp);
	fclose(fp);
	printf("Dumped %u Bytes starting at %08x\n", size, address);
}



void set_word_uio(unsigned* ptr, u32 addr, u32 data)
{
	u32 Data = data;
	memcpy(ptr+(addr>>2),&Data,sizeof(u32));
	printf("Write %08x at %08x\n", data, addr);
}

void get_word_uio(unsigned* ptr, u32 addr)
{
	printf("Read %08x at %08x\n", *(ptr+(addr>>2)), addr);

}

void dump_memory_udma(uint64_t* ptr, u32 address, u32 size, char *fname)
{
	FILE *fp = fopen(fname, "w+");
	if (!fp)
		die("fopen");
	fwrite(ptr+(address>>2), sizeof(u64), size/ sizeof(u64), fp);
	fclose(fp);

}

void load_memory_bin_udma(uint64_t* ptr, u32 base_addr, char *fname)
{

	FILE *fp = fopen(fname, "rb");
	if (!fp)
		die("fopen");
	size_t sz;
	size_t rem;
	// Get binary size
	fseek(fp, 0L, SEEK_END);
	sz = ftell(fp);
	rewind(fp);
	rem = sz;
	//printf("Starting pointer: %p\n",ptr+(base_addr>>2));
	lefread_udma(ptr+(base_addr>>3), sizeof(u64), rem / sizeof(u64), fp);
	fclose(fp);
	/* clear_rcv_memmap(); */
	printf("Loaded %zu Bytes at %08x\n", sz, base_addr);
}

void dump_memory_bin_udma(uint64_t* ptr, u32 address, u32 size, char *fname)
{


	FILE *fp = fopen(fname, "wb+");
	if (!fp)
		die("fopen");
	fwrite(ptr+(address>>3), sizeof(u64), size/ sizeof(u64), fp);
	fclose(fp);
	printf("Dumped %u Bytes starting at %08x\n", size, address);
}


void set_word_udma(uint64_t* ptr, u32 addr, u64 data)
{
	u32 Data = data;
	memcpy(ptr+(addr>>3),&Data,sizeof(u64));
	printf("Write %08x at %08x\n", data, addr);
}

void get_word_udma(uint64_t* ptr, u32 addr)
{
	printf("Read %08x at %08x\n", *(ptr+(addr>>3)), addr);

}


void reset(unsigned* ptr, u32 addr)
{
	u32 Reset = 1;
	// Reset must be sent twice
	memcpy(ptr+(addr>>2),&Reset,sizeof(u32));
	usleep(500000);
	memcpy(ptr+(addr>>2),&Reset,sizeof(u32));
	usleep(500000);
	printf("Reset ESP processor cores\n");
}
