/* Setup MMU 1:1 mapping */
/* Requires 2kbyte size 2kbyte aligned area for page and context tables */
/* Cached parameter has same format as leon3 generic */
void mmudmap(unsigned long *tbladdr, int cached)
{
	unsigned long *pt = tbladdr + 256;
	unsigned long *ctxt = tbladdr;
	int i;
	unsigned long pte;

	/* Create level 1 page table with 1:1 mapping */
	for (i=0; i<256; i++) {
		pte = (i << 20) | (3 << 2) | (2 << 0);
		/* Decide if cacheable, set C bit if so */
		if ( (cached & 1) != 0 )
			pte |= (1 << 7);
		pt[i] = pte;
		if ((i & 15) == 15) cached >>= 1;
	}

	/* Create context table with context 0 mapped to table above, other
	 * contexts marked as invalid */
	ctxt[0] = (((unsigned long)pt >> 4)) | (1 << 0);
	for (i=1; i<256; i++) ctxt[i]=0;

	/* Compiler barrier for completeness, make sure all table writes above
	 * have been performed before reg writes below */
	asm volatile ("" ::: "memory");

	/* Flush I/D/MMUTLB */
	asm volatile ("sta %g0, [%g0] 0x18");
	/* Point MMU context pointer register to context table */
	asm volatile ("sta %0, [%1] 0x19" : : "r"(((unsigned long)ctxt) >> 4),"r"(0x100));
	/* Set MMU context register to context 0 */
	asm volatile ("sta %%g0, [%0] 0x19" : : "r"(0x200));
	/* Enable MMU */
	asm volatile ("sta %0, [%%g0] 0x19" : : "r"(1));
}

/* Modify table set up by mmudmap for a 16 MiB virtual address area */
/* Does not flush TLB. */
void mmudmap_modify(unsigned long *tbladdr_phys, unsigned long vaddr,
	unsigned long physaddr, int cacheable, int acc)
{
	unsigned long pte,idx;

	/* Compute index in page table */
	idx = vaddr >> 24;
	/* Compute new PTE entry */
	pte = (((unsigned long)physaddr) >> 4) & (~0xff);
	if (cacheable) pte |= 0x80;
	pte |= (acc & 7) << 2;
        pte |= 2;

	/* Modify page table using MMU bypass insn just in case mapping for
	 * virtual page containing MMU page table has been changed earlier. */
	asm volatile ("sta %0, [%1] 0x1C" : : "r"(pte),"r"(tbladdr_phys+256+idx));

	/* Just for completeness, in case this code is inlined in the future */
	asm volatile ("" ::: "memory");
}

void mmudmap_flushtlb(void)
{
	/* Flush I/D/MMUTLB */
        asm volatile ("sta %%g0, [%%g0] 0x18" ::: "memory");
}

void mmudmap_block(void)
{
  unsigned long tmp;
  do {
    asm volatile ("lda [%%g0] 2, %0" : "=r"(tmp));
  } while ( (tmp & 0xc000) != 0);
}
