M_ISMINGW  = $(if $(strip $(shell uname | grep MINGW32)),y,)
M_ISCYGWIN = $(if $(strip $(shell uname | grep CYGWIN)),y,)

WIN32-LIBS = $(if $(strip $(shell uname -a | grep -i -E mingw)),-lWs2_32,)$(if $(ISCROSS),-lws2_32,)
POSTFIX = $(if $(strip $(ISCROSS)$(shell uname -a | grep -i -E mingw)),.exe,)

TARGET=sparc-elf
CC=$(TARGET)-gcc
HOSTCC   = $(if $(ISCROSS),mingw32-,)gcc
HOSTCC  += -m32
HOSTCC  += -O2
HOSTCC  += -Wall -Wextra -pedantic
AR=$(TARGET)-ar
RANLIB=$(TARGET)-ranlib
AS=$(TARGET)-gcc -c
CFLAGS= -O2 $(XFLAGS) -Wall -DRELEASE_VERSION="$(RELEASE_VERSION)"
ASFLAGS= -O2 $(XFLAGS)
LIBOBJ=libmkprom.a libmkamba.a
RELEASE_VERSION=2.0.65
WPREFIX = c:/opt/mkprom2
PREFIX ?= $(if $(FORCE_MINGW)$(M_ISMINGW),c:/opt/mkprom2,/opt/mkprom2$(if $(ISCROSS),-mingw,))
TOOLBASE ?=$(if $(ISCROSS),$(WPREFIX),$(PREFIX))
INCDIR=$(PREFIX)/include

OBJS= promcore.o promcore_svt.o promcore_svt_vhdl.o \
      promcrt0.o \
      prominit.o prominit_resident_svt.o prominit_resident_mvt.o \
      promload.o promload_copyonly.o prombdinit.o promdecomp.o  \
      prominit_leon2.o prominit_leon3.o prominit_erc32.o prominit_agga4.o \
      promft_leon2.o promft_leon3.o promft_erc32.o promft_none.o mp.o

OBJS_AMBA=prominit_leon3_amba.o prominit_leon3_gpio.o

all:	mkprom2 mkprom2-compile

cross:
	source /usr/local32/cross/cross_local32.sh; make ISCROSS=y all createdist

cross-only:
	source /usr/local32/cross/cross_local32.sh; make ISCROSS=y all 

%.o: %.S
	$(AS) $(ASFLAGS) -o $@ $<

libmkprom.a: $(OBJS)
	$(AR) cr libmkprom.a $(OBJS)
	$(RANLIB) libmkprom.a

libmkamba.a: $(OBJS_AMBA)
	$(AR) cr libmkamba.a $(OBJS_AMBA)
	$(RANLIB) libmkamba.a

multi-do:
	compiler="$(CC)"; \
	  for i in `cat multilibs_gcc-3.4.4`; do \
	    dir=`echo $$i | sed -e 's/;.*$$//'`; \
	        flags=`echo $$i | sed -e 's/^[^;]*;//' -e 's/@/ -/g'`; \
		$(MAKE) $(FLAGS_TO_PASS) \
				CFLAGS="$(CFLAGS) $${flags}" \
				ASFLAGS="$(ASFLAGS) $${flags}" \
				FCFLAGS="$(FCFLAGS) $${flags}" \
				FFLAGS="$(FFLAGS) $${flags}" \
				prefix="$(prefix)" \
				PREFIX="$(PREFIX)" \
				exec_prefix="$(exec_prefix)" \
				GCJFLAGS="$(GCJFLAGS) $${flags}" \
				CXXFLAGS="$(CXXFLAGS) $${flags}" \
				LIBCFLAGS="$(LIBCFLAGS) $${flags}" \
				LIBCXXFLAGS="$(LIBCXXFLAGS) $${flags}" \
				LDFLAGS="$(LDFLAGS) $${flags}" \
				MULTIFLAGS="$${flags}" \
				DESTDIR="lib/$${dir}" \
				INSTALL="$(INSTALL)" \
				INSTALL_DATA="$(INSTALL_DATA)" \
				INSTALL_PROGRAM="$(INSTALL_PROGRAM)" \
				INSTALL_SCRIPT="$(INSTALL_SCRIPT)" \
				$(DO);  \
	  done; \

install:
	@if [ ! -d $(PREFIX)/$(DESTDIR) ] ; then mkdir -p $(PREFIX)/$(DESTDIR); fi
	for i in $(OBJS); do \
		install $$i $(PREFIX)/$(DESTDIR); \
	done; \
	install libmkamba.a $(PREFIX)/$(DESTDIR); \



multi-all: $(LIBOBJ) 

mkprom2-compile:
	make PREFIX=$(PREFIX) clean
	make PREFIX=$(PREFIX) multi-do DO="clean multi-all install"
	make clean

mkprom2: clean
	mkdir -p $(PREFIX)
	$(HOSTCC) $(if $(LYNXOS_TOOL),-DLYNXOS_TOOL,) -DTOOLBASE="\"$(TOOLBASE)\"" -DRELEASE_VERSION="\"$(RELEASE_VERSION)\""  -I$(INCDIR) -g -Wall --static mkprom.c -o mkprom2$(POSTFIX) -lm $(WIN32-LIBS)
	install mkprom2$(POSTFIX) $(if $(LYNXOS_TOOL),$(LYNXOS_TOOL)/,$(PREFIX)/)
	install linkprom $(PREFIX)/
	install linkbch $(PREFIX)/
	install linkpromerc32 $(PREFIX)/
	install linkpromecos $(PREFIX)/
	install linkpromflash $(PREFIX)/
	install linkpromerc32flash $(PREFIX)/
	install linkpromecosflash $(PREFIX)/

clean:
	-rm -rf  *.o *.a mkprom2

cleaner:
	-rm -rf *~ */*~ 

testall:
	make -C testing testall


DISTDIR=dist

createdist:
	cd docbook; make -f Makefile.mkprom2 DOCVER="$(RELEASE_VERSION)" pdf
	-rm -rf $(DISTDIR)
	mkdir $(DISTDIR)
	cp -r $(PREFIX) $(DISTDIR)/mkprom2
	-rm -rf $(DISTDIR)/mkprom2/src
	-git archive --format tar --prefix=$(DISTDIR)/mkprom2/src/ HEAD  | tar x
	-rm $(DISTDIR)/mkprom2/src/.gitmodules
	-rm $(DISTDIR)/mkprom2/src/Lindent
	cp $(DISTDIR)/mkprom2/src/README $(DISTDIR)/mkprom2/README
	rm -rf $(DISTDIR)/mkprom2/src/releases
	rm -rf $(DISTDIR)/mkprom2/src/mkprom2-GUI
	rm -rf $(DISTDIR)/mkprom2/src/mkprom2-GUI-build
	rm -rf $(DISTDIR)/mkprom2/src/doc/*
	rm -rf $(DISTDIR)/mkprom2/src/releases
	rm -rf $(DISTDIR)/mkprom2/src/scripts
	-rm -rf $(DISTDIR)/mkprom2/src/docbook
	-mkdir $(DISTDIR)/mkprom2/doc
	cp docbook/pdf/mkprom2.pdf $(DISTDIR)/mkprom2/doc/mkprom2.pdf 
	cd $(DISTDIR); tar cvf $(CURDIR)/$(DISTDIR)/mkprom2-$(RELEASE_VERSION).tar mkprom2
	gzip $(CURDIR)/$(DISTDIR)/mkprom2-$(RELEASE_VERSION).tar
	cp $(CURDIR)/$(DISTDIR)/mkprom2-$(RELEASE_VERSION).tar.gz releases/mkprom2-$(RELEASE_VERSION)$(if $(FORCE_MINGW)$(ISCROSS)$(M_ISMINGW),-mingw,).tar.gz

upload-only:
	python3 ../upload.py $(RELEASE_VERSION)

upload: createdist cross
	python ../upload.py $(RELEASE_VERSION)
	-rm -rf dist-test
	-mkdir dist-test
	-mkdir dist-test/win
	-mkdir dist-test/lin
	cd dist-test; \
		wget ftp://gaisler.com/gaisler.com/mkprom2/windows/mkprom2-$(RELEASE_VERSION)-mingw.tar.gz; \
		wget ftp://gaisler.com/gaisler.com/mkprom2/linux/mkprom2-$(RELEASE_VERSION).tar.gz; \
		(cd win; tar xvf ../mkprom2-$(RELEASE_VERSION)-mingw.tar.gz);\
		(cd lin; tar xvf ../mkprom2-$(RELEASE_VERSION).tar.gz);\

download:
	python ../download.py $(RELEASE_VERSION)

