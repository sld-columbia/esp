#if defined CONFIG_SYN_INFERRED
#define CONFIG_SYN_TECH inferred
#elif defined CONFIG_SYN_UMC
#define CONFIG_SYN_TECH umc
#elif defined CONFIG_SYN_RHUMC
#define CONFIG_SYN_TECH rhumc
#elif defined CONFIG_SYN_DARE
#define CONFIG_SYN_TECH dare
#elif defined CONFIG_SYN_SAED32
#define CONFIG_SYN_TECH saed32
#elif defined CONFIG_SYN_RHS65
#define CONFIG_SYN_TECH rhs65
#elif defined CONFIG_SYN_ATC18
#define CONFIG_SYN_TECH atc18s
#elif defined CONFIG_SYN_ATC18RHA
#define CONFIG_SYN_TECH atc18rha
#elif defined CONFIG_SYN_AXCEL
#define CONFIG_SYN_TECH axcel
#elif defined CONFIG_SYN_AXDSP
#define CONFIG_SYN_TECH axdsp
#elif defined CONFIG_SYN_PROASICPLUS
#define CONFIG_SYN_TECH proasic
#elif defined CONFIG_SYN_ALTERA
#define CONFIG_SYN_TECH altera
#elif defined CONFIG_SYN_STRATIX
#define CONFIG_SYN_TECH stratix1
#elif defined CONFIG_SYN_STRATIXII
#define CONFIG_SYN_TECH stratix2
#elif defined CONFIG_SYN_STRATIXIII
#define CONFIG_SYN_TECH stratix3
#elif defined CONFIG_SYN_STRATIXIV
#define CONFIG_SYN_TECH stratix4
#elif defined CONFIG_SYN_CYCLONEII
#define CONFIG_SYN_TECH stratix2
#elif defined CONFIG_SYN_CYCLONEIII
#define CONFIG_SYN_TECH cyclone3
#elif defined CONFIG_SYN_CYCLONEIV
#define CONFIG_SYN_TECH cyclone3
#elif defined CONFIG_SYN_IHP25
#define CONFIG_SYN_TECH ihp25
#elif defined CONFIG_SYN_IHP25RH
#define CONFIG_SYN_TECH ihp25rh
#elif defined CONFIG_SYN_CMOS9SF
#define CONFIG_SYN_TECH cmos9sf
#elif defined CONFIG_SYN_LATTICE
#define CONFIG_SYN_TECH lattice
#elif defined CONFIG_SYN_ECLIPSE
#define CONFIG_SYN_TECH eclipse
#elif defined CONFIG_SYN_PEREGRINE
#define CONFIG_SYN_TECH peregrine
#elif defined CONFIG_SYN_PROASIC
#define CONFIG_SYN_TECH proasic
#elif defined CONFIG_SYN_PROASIC3
#define CONFIG_SYN_TECH apa3
#elif defined CONFIG_SYN_PROASIC3E
#define CONFIG_SYN_TECH apa3e
#elif defined CONFIG_SYN_PROASIC3L
#define CONFIG_SYN_TECH apa3l
#elif defined CONFIG_SYN_IGLOO
#define CONFIG_SYN_TECH apa3
#elif defined CONFIG_SYN_IGLOO2
#define CONFIG_SYN_TECH igloo2
#elif defined CONFIG_SYN_SF2
#define CONFIG_SYN_TECH smartfusion2
#elif defined CONFIG_SYN_RTG4
#define CONFIG_SYN_TECH rtg4
#elif defined CONFIG_SYN_FUSION
#define CONFIG_SYN_TECH actfus
#elif defined CONFIG_SYN_SPARTAN2
#define CONFIG_SYN_TECH virtex
#elif defined CONFIG_SYN_VIRTEX
#define CONFIG_SYN_TECH virtex
#elif defined CONFIG_SYN_VIRTEXE
#define CONFIG_SYN_TECH virtex
#elif defined CONFIG_SYN_SPARTAN3
#define CONFIG_SYN_TECH spartan3
#elif defined CONFIG_SYN_SPARTAN3E
#define CONFIG_SYN_TECH spartan3e
#elif defined CONFIG_SYN_SPARTAN6
#define CONFIG_SYN_TECH spartan6
#elif defined CONFIG_SYN_VIRTEX2
#define CONFIG_SYN_TECH virtex2
#elif defined CONFIG_SYN_VIRTEX4
#define CONFIG_SYN_TECH virtex4
#elif defined CONFIG_SYN_VIRTEX5
#define CONFIG_SYN_TECH virtex5
#elif defined CONFIG_SYN_VIRTEX6
#define CONFIG_SYN_TECH virtex6
#elif defined CONFIG_SYN_VIRTEX7
#define CONFIG_SYN_TECH virtex7
#elif defined CONFIG_SYN_KINTEX7
#define CONFIG_SYN_TECH kintex7
#elif defined CONFIG_SYN_ARTIX7
#define CONFIG_SYN_TECH artix7
#elif defined CONFIG_SYN_ZYNQ7000
#define CONFIG_SYN_TECH zynq7000
#elif defined CONFIG_SYN_ARTIX77
#define CONFIG_SYN_TECH artix7
#elif defined CONFIG_SYN_ZYNQ7000
#define CONFIG_SYN_TECH zynq7000
#elif defined CONFIG_SYN_RH_LIB18T
#define CONFIG_SYN_TECH rhlib18t
#elif defined CONFIG_SYN_SMIC13
#define CONFIG_SYN_TECH smic013
#elif defined CONFIG_SYN_UT025CRH
#define CONFIG_SYN_TECH ut25
#elif defined CONFIG_SYN_UT130HBD
#define CONFIG_SYN_TECH ut130
#elif defined CONFIG_SYN_UT90NHBD
#define CONFIG_SYN_TECH ut90
#elif defined CONFIG_SYN_TSMC90
#define CONFIG_SYN_TECH tsmc90
#elif defined CONFIG_SYN_TM65GPLUS
#define CONFIG_SYN_TECH tm65gplus
#elif defined CONFIG_SYN_CUSTOM1
#define CONFIG_SYN_TECH custom1
#else
#error "unknown target technology"
#endif

#if defined CONFIG_SYN_INFER_RAM
#define CFG_RAM_TECH inferred
#elif defined CONFIG_MEM_UMC
#define CFG_RAM_TECH umc
#elif defined CONFIG_MEM_RHUMC
#define CFG_RAM_TECH rhumc
#elif defined CONFIG_MEM_DARE
#define CFG_RAM_TECH dare
#elif defined CONFIG_MEM_SAED32
#define CFG_RAM_TECH saed32
#elif defined CONFIG_MEM_RHS65
#define CFG_RAM_TECH rhs65
#elif defined CONFIG_MEM_VIRAGE
#define CFG_RAM_TECH memvirage
#elif defined CONFIG_MEM_ARTISAN
#define CFG_RAM_TECH memartisan
#elif defined CONFIG_MEM_CUSTOM1
#define CFG_RAM_TECH custom1
#elif defined CONFIG_MEM_VIRAGE90
#define CFG_RAM_TECH memvirage90
#elif defined CONFIG_MEM_INFERRED
#define CFG_RAM_TECH inferred
#else
#define CFG_RAM_TECH CONFIG_SYN_TECH
#endif

#if defined CONFIG_TRANS_GTP0
#define CFG_TRANS_TECH GTP0
#elif defined CONFIG_TRANS_GTP1
#define CFG_TRANS_TECH GTP1
#elif defined CONFIG_TRANS_GTX0
#define CFG_TRANS_TECH GTX0
#elif defined CONFIG_TRANS_GTX1
#define CFG_TRANS_TECH GTX1
#elif defined CONFIG_TRANS_GTH0
#define CFG_TRANS_TECH GTH0
#elif defined CONFIG_TRANS_GTH1
#define CFG_TRANS_TECH GTH1
#else
#define CFG_TRANS_TECH GTP0
#endif

#if defined CONFIG_SYN_INFER_PADS
#define CFG_PAD_TECH inferred
#else
#define CFG_PAD_TECH CONFIG_SYN_TECH
#endif

#ifndef CONFIG_SYN_NO_ASYNC
#define CONFIG_SYN_NO_ASYNC 0
#endif

#ifndef CONFIG_SYN_SCAN
#define CONFIG_SYN_SCAN 0
#endif

