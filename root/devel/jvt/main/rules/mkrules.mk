include $(wildcard $(JVTROOT)/rules/thirdparty.txt)

# GLOBAL STUFF -----------------------------------------------------------------
DEBUG=-g
OPT=-O2
NDEBUG=-DNDEBUG
SH=.H
SF=.C

CC=g++
#DOXYGEN  = /opt/jump/x86_64/doxygen-1.7.1-JUMP1.00/bin/doxygen
#INSTALL  = @ /usr/bin/install
INSTALL  = /usr/bin/install
STRIP    = /usr/bin/strip
MKDIR    = mkdir -p
RM       = rm -rf

CODEGENBASE  = $(JVTROOT)/ruby/codegenerator/lib
# RUBYLIB= $(CODEGENBASE)
CODEGEN  = $(CODEGENBASE)/jvt/codegen_all.rb
CODEGENLOCAL = $(CODEGEN) -L 
# CODEGENLOCAL = @ $(CODEGEN) -L > /dev/null

BUILDDIROBJ=.Build
BUILDDIRSHARE=$(JVTROOT)/BUILD
BUILDDIRBIN=$(BUILDDIRSHARE)/bin
BUILDDIRLIB=$(BUILDDIRSHARE)/lib

# LOCAL REPO -----------------------------------------------------------------
#JVTROOT=/home/vgreff/src/jvt/main
JVTVERSIONFILE=$(JVTROOT)/cpp/jvt/Version.H 
MAJOR = $(shell grep JVT_VERSION_MAJOR $(JVTVERSIONFILE) | cut -f3 -d" ")
MINOR = $(shell grep JVT_VERSION_MINOR $(JVTVERSIONFILE) | cut -f3 -d" ")
PATCH = $(shell grep JVT_VERSION_PATCH $(JVTVERSIONFILE) | cut -f3 -d" ")
JVTVERSION = $(MAJOR).$(MINOR).$(PATCH)

DEBPKGVERSION ?= 00
DEBPKGNAME = jvt-$(JVTVERSION).jump1.$(DEBPKGVERSION)

INSTALLDIRBASE = $(JVTROOT)/$(DEBPKGNAME)
INSTALLDIR     = $(INSTALLDIRBASE)/home/jvt/packages/$(JVTVERSION)
INSTALLDIRINC  = $(INSTALLDIR)/include
INSTALLDIRLIB = $(INSTALLDIR)/lib
INSTALLDIRBIN = $(INSTALLDIR)/bin

include $(wildcard $(JVTROOT)/cpp/jvtflags)

# DEFAULT FLAGS ----------------------------------------------------------------
CFLAGS += -Wextra  -g -I. 
#CFLAGS += -Wall
#CFLAGS += -Werror
CFLAGS += -mssse3

LFLAGS += -lpthread -lrt

#ifdef USE_BOOST
#CFLAGS += -ftemplate-depth-128 -O0 
CFLAGS += -I$(BOOST)/include 
LFLAGS += -L$(BOOST)/lib -Wl,-rpath,$(BOOST)/lib
#endif

CFLAGS += -DBOOST_DATE_TIME_POSIX_TIME_STD_CONFIG -DBOOST_UBLAS_SHALLOW_ARRAY_ADAPTOR
LFLAGS += -lboost_thread -lboost_system -lboost_date_time -lboost_program_options

# enable std::hash_map by default
#ifdef USE_C++0X
CFLAGS += -std=gnu++0x
#endif


# GLOBAL PATHS -----------------------------------------------------------------
#USE_JET=1
#USE_JETSTREAM=1


ifdef USE_JET
JETPKGDIR=$(JETROOT)/jet-$(JETPKGVERSION).jump1.00/home/jet/packages/$(JETPKGVERSION)
CFLAGS += -I$(JETPKGDIR)/include -DJS_AFFINITY
LFLAGS += -L$(JETPKGDIR)/bin -Wl,-rpath,$(JETPKGDIR)/bin
LFLAGSDEBUG += -ljet$(DEBUG)
LFLAGSOPT += -ljet$(OPT)
endif

ifdef USE_JETSTREAM
JETSTREAM = $(JETSTREAMROOT)/jetstream/build/pic/x86_64
CFLAGS += -I$(JETSTREAM)/include
LFLAGS += -L$(JETSTREAM)/lib -ljetstream -lrdmacm -libverbs
# LFLAGS += -L$(JETSTREAM)/lib -Wl,--whole-archive -ljetstream -Wl,--no-whole-archive -lrdmacm -libverbs
endif

ifdef USE_LLM
CFLAGS += -I$(LLM)/include -DRMM_UNIX
LFLAGS += -L$(LLM)/lib64 -lrmm -lfmdutil -Wl,-rpath,$(LLM)/lib64
endif

ifdef USE_PQ
CFLAGS += -I/usr/include/postgresql
LFLAGS += -L/usr/lib/postgresql/8.4/lib -lpq -Wl,-rpath,/usr/lib/postgresql/8.4/lib
endif

ifdef USE_GSL
#GSL=/opt/jump/x86_64/gsl-1.15/
CFLAGS += -I$(GSL)/include
LFLAGS += -L$(GSL)/lib -lgsl -lgslcblas -Wl,-rpath,$(GSL)/lib
endif

ifdef USE_SYBASE
CFLAGS += -I$(SYBASE)/include
LFLAGS += -L$(SYBASE)/lib -lsybblk64 -lsybct64 -lsybcs64 -lsybtcl64 -lsybcomn64 -lsybintl64 -lsybunic64 -Wl,-rpath,$(SYBASE)/lib64
endif

ifdef USE_SQLAPI
CFLAGS += -I$(JVTSQLAPI)/include
LFLAGS += -L$(JVTSQLAPI)/lib -lsqlapi
endif

ifdef USE_EXSTREAMSPEED
CFLAGS += -I$(EXSTREAMSPEED)/include
LFLAGS += -L$(EXSTREAMSPEED)/lib -les
endif

# ifdef USE_TIBRV
# TIBRV=/usr/tibco/tibrv
# CFLAGS += -I$(TIBRV)/include
# LFLAGS += -L$(TIBRV)/lib
# SFLAGS += -ltibrv64 -ltibrvcpp64 -Wl,-rpath,$(TIBRV)/lib
# endif

# DEFINE PROJECT -----------------------------------------------------------------
ifdef BINTGT

ifdef REGTEST
BINTGTEXE = $(BINTGT)RGT
LFLAGS += -lboost_unit_test_framework
else
BINTGTEXE = $(BINTGT)
endif

BINDEBUG = $(BINTGTEXE)$(DEBUG)
BINOPT   = $(BINTGTEXE)$(OPT)
BININST  = $(BINTGTEXE)

BLDBINDEBUG   = $(BUILDDIRBIN)/$(BINDEBUG)
BLDBINOPT     = $(BUILDDIRBIN)/$(BINOPT)
BLDBININST    = $(BUILDDIRBIN)/$(BININST)

INSTBINDEBUG  = $(INSTALLDIRBIN)/$(BINDEBUG)
INSTBINOPT    = $(INSTALLDIRBIN)/$(BINOPT)
INSTBININST   = $(INSTALLDIRBIN)/$(BININST)
endif

ifdef LIBTGT
CFLAGS += -fPIC
LFLAGS += -z now 

ifndef LIBINCLNSPATH
LIBINCLNSPATH = jvt/
endif
LIBINCLNSPREFIX = $(subst /,_,$(LIBINCLNSPATH))
LIBINCLNAME   = $(LIBINCLNSPATH)$(LIBTGT)

LIBDEBUGBASE      = $(LIBINCLNSPREFIX)$(LIBTGT)$(DEBUG)
LIBOPTBASE        = $(LIBINCLNSPREFIX)$(LIBTGT)$(OPT)
LIBINSTBASE       = $(LIBINCLNSPREFIX)$(LIBTGT)-stripped
LIBDEBUG      = lib$(LIBDEBUGBASE).so
LIBOPT        = lib$(LIBOPTBASE).so
LIBINST       = lib$(LIBINSTBASE).so
LIBDEBUGLINK      = -l$(LIBDEBUGBASE)
LIBOPTLINK        = -l$(LIBOPTBASE)
LIBINSTLINK       = -l$(LIBINSTBASE)

BLDLIBDEBUG   = $(BUILDDIRLIB)/$(LIBDEBUG)
BLDLIBOPT     = $(BUILDDIRLIB)/$(LIBOPT) 
BLDLIBINST    = $(BUILDDIRLIB)/$(LIBINST) 
INSTLIBDEBUG  = $(INSTALLDIRLIB)/$(LIBDEBUG)
INSTLIBOPT    = $(INSTALLDIRLIB)/$(LIBOPT)
INSTLIBINST   = $(INSTALLDIRLIB)/$(LIBINST)
INSTALLDIRINCLIB = $(INSTALLDIRINC)/$(LIBINCLNAME)
endif

CFLAGS += -I$(INSTALLDIRINC)
LFLAGS += -L$(INSTALLDIRLIB)

ifdef JVTLIBS
JVTLIBSDEBUG = $(patsubst %,-l%$(DEBUG),$(JVTLIBS))
JVTLIBSOPT   = $(patsubst %,-l%$(OPT),$(JVTLIBS))

LFLAGSDEBUG += $(JVTLIBSDEBUG)
LFLAGSOPT   += $(JVTLIBSOPT)
endif

ifdef SYSLIBS
LFLAGSDEBUG += $(patsubst %,-l%,$(SYSLIBS))
LFLAGSOPT   += $(patsubst %,-l%,$(SYSLIBS))
endif

# LOCAL RULES -----------------------------------------------------------------

ALLDIRS := $(BUILDDIROBJ) $(BUILDDIRBIN) $(BUILDDIRLIB) $(INSTALLDIRINCLIB) $(INSTALLDIRBIN) $(INSTALLDIRLIB)

.PHONY: realclean clean cleang cleano create-dir buildg buildo build install-headers install installg installo rewrite createpkg install-scripts install-scripts-build world worldg worldo worldinstallg worldinstallo worldinstall worldcleang worldcleano worldclean worldrealclean clean-bing clean-installbing clean-locbuild clean-bino clean-installbino clean-bin clean-libg clean-installlibg clean-libo clean-installlibo clean-lib clean-installlib-headers install-libg install-libo install-lib install-bing install-bino install-bin install-win install-docs subdirs $(ALLDIRS) clean-install-scripts clean-install-scripts-build $(TESTTGTDEBUG) $(TESTTGTOPT) test testo clean-test testg clean-testg clean-testo cleandep cleandepg cleandepo lcode sql

$(ALLDIRS) :
	@ $(MKDIR) $@

buildg : $(BLDLIBDEBUG) $(BLDBINDEBUG) | install-scripts-build 

buildo : $(BLDLIBOPT) $(BLDBINOPT) $(BLDBININST) | install-scripts-build

build : buildg buildo

INSTALLDIRINCLIBHEADERS := $(foreach hdr,$(HEADERS),$(INSTALLDIRINCLIB)/$(hdr))

$(INSTALLDIRINCLIB)/% : % | $(INSTALLDIRINCLIB)
	$(INSTALL) -p $< $@

install-headers: $(INSTALLDIRINCLIBHEADERS)

# DEBUG Dependencies ---------------------------------------------------------
OBJDEBUG = $(patsubst %$(SF),$(BUILDDIROBJ)/%$(DEBUG).o,$(SRC))
DEPDEBUG = $(patsubst %$(SF),$(BUILDDIROBJ)/%$(DEBUG).d,$(SRC))

$(BUILDDIROBJ)/%$(DEBUG).d : %$(SF) | $(BUILDDIROBJ) 
	@ $(CC) -MM $(CFLAGS) $< | sed 's,\($*\)\.o[ :]*,$(BUILDDIROBJ)/\1$(DEBUG).o $@ : ,g' > $@

$(BUILDDIROBJ)/%$(DEBUG).o : %$(SF) | $(BUILDDIROBJ) 
	$(CC) $(CFLAGS) $(DEBUG) -c $< -o $@


# OPT Dependencies ----------------------------------------------------------
OBJOPT = $(patsubst %$(SF),$(BUILDDIROBJ)/%$(OPT).o,$(SRC))
DEPOPT = $(patsubst %$(SF),$(BUILDDIROBJ)/%$(OPT).d,$(SRC))

$(BUILDDIROBJ)/%$(OPT).d :  %$(SF) | $(BUILDDIROBJ) 
	@ $(CC) -MM $(CFLAGS) $< | sed 's,\($*\)\.o[ :]*,$(BUILDDIROBJ)/\1$(OPT).o $@ : ,g' > $@

$(BUILDDIROBJ)/%$(OPT).o : %$(SF) | $(BUILDDIROBJ) 
	$(CC) $(NDEBUG) $(CFLAGS) $(OPT) -c $< -o $@

# include dep ----------------------------------------------------------------

ifneq ($(strip $(findstring clean, $(MAKECMDGOALS))),clean)

-include $(DEPDEBUG)
-include $(DEPOPT)

endif

# Declare Rules --------------------------------------------------------------
cleang :

cleano :

installg:

installo:

# UNITTEST Rules ---------------------------------------------------------------
ifdef UNITTEST

UNITTESTTGT += $(LIBTGT)UTF$(SF)

endif

# UNITTESTTGT Rules ---------------------------------------------------------------
ifdef UNITTESTTGT

TESTTGT += $(UNITTESTTGT)
LFLAGSTEST += -lboost_unit_test_framework

endif

# TESTTGT Rules ---------------------------------------------------------------

ifdef TESTTGT
TESTTGTEXEDEBUG = $(patsubst %$(SF),$(BUILDDIRBIN)/jvt%$(DEBUG),$(TESTTGT))
TESTTGTDEBUG = $(patsubst %$(SF),jvt%$(DEBUG),$(TESTTGT))

TESTDEPDEBUG = $(patsubst %$(SF),$(BUILDDIROBJ)/%$(DEBUG).dt,$(TESTTGT))

$(BUILDDIROBJ)/%$(DEBUG).dt : %$(SF) | $(BUILDDIRBIN) $(BUILDDIROBJ)
	@ $(CC) -MM $(CFLAGS) $< | sed 's,\($*\)\.o[ :]*,$(BUILDDIRBIN)/jvt\1$(DEBUG) $@ : ,g' > $@

-include $(TESTDEPDEBUG)

TESTDEPOPT = $(patsubst %$(SF),$(BUILDDIROBJ)/%$(OPT).dt,$(TESTTGT))

$(BUILDDIROBJ)/%$(OPT).dt : %$(SF) | $(BUILDDIRBIN) $(BUILDDIROBJ)
	@ $(CC) -MM $(CFLAGS) $< | sed 's,\($*\)\.o[ :]*,$(BUILDDIRBIN)/jvt\1$(OPT) $@ : ,g' > $@

-include $(TESTDEPOPT)

$(TESTTGTDEBUG) : $(TESTTGTEXEDEBUG)

$(TESTTGTEXEDEBUG) : $(INSTLIBDEBUG) | $(BUILDDIRBIN)

$(BUILDDIRBIN)/jvt%$(DEBUG) : %$(SF) $(INSTLIBDEBUG) | $(BUILDDIRBIN)
	$(CC) -DJVTTEST $(CFLAGS) $(DEBUG) $(LFLAGS) $(LFLAGSTEST) $(LFLAGSDEBUG) -o $@ $< $(LIBDEBUGLINK) $(SFLAGS)


TESTTGTEXEOPT = $(patsubst %$(SF),$(BUILDDIRBIN)/jvt%$(OPT),$(TESTTGT))
TESTTGTOPT = $(patsubst %$(SF),jvt%$(OPT),$(TESTTGT))

$(TESTTGTOPT) : $(TESTTGTEXEOPT)

$(TESTTGTEXEOPT) : $(INSTLIBOPT) | $(BUILDDIRBIN)

$(BUILDDIRBIN)/jvt%$(OPT) : %$(SF) $(INSTLIBOPT) | $(BUILDDIRBIN)
	$(CC) -DJVTTEST $(NDEBUG) $(CFLAGS) $(OPT) $(LFLAGS) $(LFLAGSTEST) $(LFLAGSOPT) -o $@ $< $(LIBOPTLINK) $(SFLAGS)


TESTTGTEXEINST = $(patsubst %$(SF),$(BUILDDIRBIN)/jvt%,$(TESTTGT))
TESTTGTINST = $(patsubst %$(SF),jvt%,$(TESTTGT))

$(TESTTGTINST) : $(TESTTGTEXEINST)

$(TESTTGTEXEINST) :  | $(BUILDDIRBIN)

$(BUILDDIRBIN)/jvt% : $(BUILDDIRBIN)/jvt%$(OPT) $(INSTLIBOPT) | $(BUILDDIRBIN)
	$(STRIP) $< -o $@


TESTTGTEXEDEBUGINST = $(patsubst %$(SF),$(INSTALLDIRBIN)/jvt%$(DEBUG),$(TESTTGT))
TESTTGTEXEOPTINST = $(patsubst %$(SF),$(INSTALLDIRBIN)/jvt%$(OPT),$(TESTTGT))
TESTTGTEXEINSTINST = $(patsubst %$(SF),$(INSTALLDIRBIN)/jvt%,$(TESTTGT))

clean-testg : 
	$(RM) $(TESTTGTEXEDEBUG) $(TESTTGTEXEDEBUGINST) $(TESTDEPDEBUG)

clean-testo : 
	$(RM) $(TESTTGTEXEOPT) $(TESTTGTEXEINST) $(TESTTGTEXEOPTINST) $(TESTTGTEXEINSTINST)  $(TESTDEPOPT)

clean-test : clean-testg clean-testo 

cleang : clean-testg

cleano : clean-testo

test : testo testg

testg : $(TESTTGTEXEDEBUG)

testo : $(TESTTGTEXEOPT) $(TESTTGTEXEINST)

buildg : testg

buildo : testo

installg :$(TESTTGTEXEDEBUGINST)

installo :$(TESTTGTEXEOPTINST) $(TESTTGTEXEINSTINST)

endif

# BINTGT Rules ---------------------------------------------------------------
ifdef BINTGT
$(BLDBINDEBUG) : $(OBJDEBUG) | $(BUILDDIRBIN)
	$(CC) $(CFLAGS) $(LFLAGS) $(LFLAGSDEBUG) -o $@ $(OBJDEBUG) $(SFLAGS)

$(BLDBINOPT) : $(OBJOPT) | $(BUILDDIRBIN)
	$(CC) $(CFLAGS) $(LFLAGS) $(LFLAGSOPT) -o $@ $(OBJOPT) $(SFLAGS)

$(BLDBININST) : $(BLDBINOPT) | $(BUILDDIRBIN)
	$(STRIP) $< -o $@

cleang : clean-bing

cleano : clean-bino


installg: install-bing $(SUBBLDG)

installo: install-bino $(SUBBLDO)

# installg: install-bing
# 	@for d in $(INSTALL_DIRS); do ( $(MAKE) -C $$d $@); done

# installo: install-bino
# 	@for d in $(INSTALL_DIRS); do ( $(MAKE) -C $$d $@); done

endif

# LIBTGT Rules ---------------------------------------------------------------
ifdef LIBTGT
$(BLDLIBINST) : $(BLDLIBOPT)
	$(STRIP) $< -o $@

cleano : 

cleang : 

clean : | clean-installlib-headers

$(BLDLIBDEBUG) :

$(BLDLIBOPT) :

installg:  | install-headers

installo:   | install-headers

worldinstallg: | install-headers

worldinstallo: | install-headers

ifndef HEADERONLYLIB

$(BLDLIBDEBUG) : $(OBJDEBUG) | $(BUILDDIRLIB)
	$(CC) -shared $(CFLAGS) $(LFLAGS) $(LFLAGSDEBUG) -o $@ $(OBJDEBUG) $(SFLAGS)

$(BLDLIBOPT) : $(OBJOPT) | $(BUILDDIRLIB)
	$(CC)  -shared $(CFLAGS) $(LFLAGS) $(LFLAGSOPT) -o $@ $(OBJOPT) $(SFLAGS)

cleano : clean-libo

cleang : clean-libg


installg: $(SUBBLDG)  |  install-libg 

installo: $(SUBBLDO)  |  install-libo 

# installg: install-headers install-libg
# 	@for d in $(INSTALL_DIRS); do ( $(MAKE) -C $$d $@); done

# installo: install-headers install-libo
# 	@for d in $(INSTALL_DIRS); do ( $(MAKE) -C $$d $@); done


endif

createpkg: install
	$(JVTROOT)/scripts/createpkg $(JVTROOT)/$(DEBPKGNAME) $(LIBTGT) $(JETVERSION) $(DEBPKGVERSION)

rewrite: $(HEADERS)
	perl -p -i -e's,^//([^/]),///\1,' $?
	perl -p -i -e's,([^/])//([^/]),\1///\2,' $?
endif

install-scripts:

install-scripts-build:

# SCRIPTSTGT Rules ---------------------------------------------------------------
ifdef SCRIPTSTGT

INSTALLDIRBINSCRIPTS := $(foreach scr,$(SCRIPTSTGT),$(INSTALLDIRBIN)/$(scr))

install-scripts:  $(INSTALLDIRBINSCRIPTS) | $(INSTALLDIRBIN)

clean-install-scripts:
	$(RM) $(INSTALLDIRBINSCRIPTS)

installg installo : | install-scripts

BUILDDIRBINSCRIPTS := $(foreach scr,$(SCRIPTSTGT),$(BUILDDIRBIN)/$(scr))

install-scripts-build:  $(BUILDDIRBINSCRIPTS) | $(BUILDDIRBIN)

clean-install-scripts-build:
	$(RM) $(BUILDDIRBINSCRIPTS)

clean-locbuild : clean-install-scripts-build

clean:  clean-locbuild clean-install-scripts

endif

# BUILD_DIRS Rules -------------------------------------------------------------

ifdef BUILD_DIRS
SUBBLDG = $(patsubst %,%.bldg,$(BUILD_DIRS))
SUBBLDO = $(patsubst %,%.bldo,$(BUILD_DIRS))


worldinstallg  : $(SUBBLDG)

worldinstallo : $(SUBBLDO)

ifndef HEADERONLYLIB
$(SUBBLDG) : $(BLDLIBDEBUG) $(INSTLIBDEBUG)

$(SUBBLDO) : $(BLDLIBOPT) $(INSTLIBOPT)
endif

# %.bldg  : %
# 	@ (cd $<; $(MAKE) $(MAKECMDGOALS) ; )

%.bldg  : %
	 (cd $<; $(MAKE)  worldinstallg; )

%.bldo : %
	 (cd $<; $(MAKE)  worldinstallo ; )

endif

# INSTALL_DIRS Rules -------------------------------------------------------------

# ifdef INSTALL_DIRS
# SUBINSTG = $(patsubst %,%.instg,$(INSTALL_DIRS))
# SUBINSTO = $(patsubst %,%.insto,$(INSTALL_DIRS))


# worldinstallg  : $(SUBINSTG)

# worldinstallo : $(SUBINSTO)

# ifndef HEADERONLYLIB
# $(SUBINSTG) : $(INSTLIBDEBUG)

# $(SUBINSTO) : $(INSTLIBOPT)

# endif
# %.instg %.insto: %
# 	(cd $<; $(MAKE) $(MAKECMDGOALS) ; )

# endif

# Shared Rules -------------------------------------------------------------

clean : cleang cleano

install: installg installo

worldinstallg: installg

worldinstallo: installo

worldinstall: worldinstallg worldinstallo

worldg : worldinstallg

worldo : worldinstallo

world: worldinstall

# worldcleang: cleang

# worldcleano: cleano

# worldclean : clean


worldcleang: cleang
	@for d in $(BUILD_DIRS); do ( $(MAKE) -C $$d $<); done

worldcleano: cleano
	@for d in $(BUILD_DIRS); do ( $(MAKE) -C $$d $<); done

worldclean: clean
	@for d in $(BUILD_DIRS); do ( $(MAKE) -C $$d $<); done

worldrealclean: realclean
	@for d in $(BUILD_DIRS); do ( $(MAKE) -C $$d $<); done


cleanb : clean-bin clean-lib

cleanbg : clean-bing clean-libg

cleanbo : clean-bino clean-libo

clean-locbuild :
	$(RM) $(BUILDDIROBJ)

cleandepg :
	$(RM) $(DEPDEBUG)  $(TESTDEPDEBUG)

cleandepo :
	$(RM) $(DEPOPT) $(TESTDEPOPT)

cleandep : cleandepg cleandepo

clean-bing : clean-installbing 
	$(RM) $(BLDBINDEBUG) $(OBJDEBUG) $(DEPDEBUG)

clean-bino : clean-installbino
	$(RM) $(BLDBINOPT) $(BLDBININST) $(OBJOPT) $(DEPOPT)

clean-bin : clean-bing clean-bino

clean-libg : clean-installlibg
	$(RM) $(BLDLIBDEBUG) $(OBJDEBUG) $(DEPDEBUG)

clean-libo : clean-installlibo
	$(RM) $(BLDLIBOPT) $(BLDLIBINST) $(OBJOPT) $(DEPOPT)

clean-lib : clean-libg clean-libo

realclean:
	$(RM) $(INSTALLDIRBASE) $(BUILDDIRSHARE) $(BUILDDIROBJ)

clean-installlib-headers:
	$(RM) $(INSTALLDIRINCLIB)

clean-installlibg: 
	$(RM) $(INSTLIBDEBUG)

clean-installlibo: 
	$(RM) $(INSTLIBOPT)

clean-installlib: clean-installlibg clean-installlibo

clean-installbing:
	$(RM) $(INSTBINDEBUG)

clean-installbino:
	$(RM) $(INSTBINOPT) $(INSTBININST)

clean-installbin: clean-installbing clean-installbino

$(BUILDDIRBIN)/% : % | $(BUILDDIRBIN)
	$(INSTALL) -p $< $@

# $(INSTALLDIRBIN)/% : % | $(INSTALLDIRBIN)
# 	$(INSTALL) -p $< $@

$(INSTALLDIRBIN)/% : $(BUILDDIRBIN)/% | $(INSTALLDIRBIN)
	$(INSTALL) -p $< $@

$(INSTALLDIRLIB)/% : $(BUILDDIRLIB)/% | $(INSTALLDIRLIB)
	$(INSTALL) -p $< $@


install-bing: $(INSTBINDEBUG)

install-bino: $(INSTBININST) $(INSTBINOPT)

install-bin: install-bing install-bino

install-libg: $(INSTLIBDEBUG)

install-libo: $(INSTLIBOPT)

install-lib: install-libg install-libo

lcode:
	$(CODEGENLOCAL)

sql:
	$(CODEGENLOCAL) -S

# $(INSTALLDIR)/win32 :
# 	$(MKDIR) $(INSTALLDIR)/win32


# install-win: $(INSTALLDIR)/win32
# 	$(INSTALL) $(WINSRC) $(INSTALLDIR)/win32

# install-docs: doxy
# 	/bin/cp -pr ./docs $(INSTALLDIR)

# doxy:
# 	$(DOXYGEN) jvt.doxy

# Default Rule -------------------------------------------------------------
.DEFAULT_GOAL := build
