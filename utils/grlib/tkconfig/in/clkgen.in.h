
#if defined CONFIG_CLK_ALTDLL
#define CFG_CLK_TECH CONFIG_SYN_TECH
#elif defined CONFIG_CLK_HCLKBUF
#define CFG_CLK_TECH axcel
#elif defined CONFIG_CLK_LATDLL
#define CFG_CLK_TECH lattice
#elif defined CONFIG_CLK_PRO3PLL
#define CFG_CLK_TECH apa3
#elif defined CONFIG_CLK_PRO3EPLL
#define CFG_CLK_TECH apa3e
#elif defined CONFIG_CLK_PRO3LPLL
#define CFG_CLK_TECH apa3l
#elif defined CONFIG_CLK_FUSPLL
#define CFG_CLK_TECH actfus
#elif defined CONFIG_CLK_CLKDLL
#define CFG_CLK_TECH virtex
#elif defined CONFIG_CLK_CLKPLLE2
#define CFG_CLK_TECH CONFIG_SYN_TECH
#elif defined CONFIG_CLK_DCM
#define CFG_CLK_TECH CONFIG_SYN_TECH
#elif defined CONFIG_CLK_LIB18T
#define CFG_CLK_TECH rhlib18t
#elif defined CONFIG_CLK_RHUMC
#define CFG_CLK_TECH rhumc
#elif defined CONFIG_CLK_SAED32
#define CFG_CLK_TECH saed32
#elif defined CONFIG_CLK_RHS65
#define CFG_CLK_TECH rhs65
#elif defined CONFIG_CLK_DARE
#define CFG_CLK_TECH dare
#elif defined CONFIG_CLK_EASIC45
#define CFG_CLK_TECH easic45
#elif defined CONFIG_CLK_UT130HBD
#define CFG_CLK_TECH ut130
#else
#define CFG_CLK_TECH inferred
#endif

#ifndef CONFIG_CLK_MUL
#define CONFIG_CLK_MUL 2
#endif

#ifndef CONFIG_CLK_DIV
#define CONFIG_CLK_DIV 2
#endif

#ifndef CONFIG_OCLK_DIV
#define CONFIG_OCLK_DIV 1
#endif

#ifndef CONFIG_OCLKB_DIV
#define CONFIG_OCLKB_DIV 0
#endif

#ifndef CONFIG_OCLKC_DIV
#define CONFIG_OCLKC_DIV 0
#endif

#ifndef CONFIG_PCI_CLKDLL
#define CONFIG_PCI_CLKDLL 0
#endif

#ifndef CONFIG_PCI_SYSCLK
#define CONFIG_PCI_SYSCLK 0
#endif

#ifndef CONFIG_CLK_NOFB
#define CONFIG_CLK_NOFB 0
#endif
