MODULES = \
	ModuleA.C \
	ModuleB.C


TEMPLATES = \

SRC = \
	$(MODULES)


HEADERS = \
	$(MODULES:.C=.H) \
	$(TEMPLATES)


BUILD_DIRS = SampleLibTest1
INSTALL_DIRS = $(BUILD_DIRS)

LIBINCLNSPATH = jvt/
LIBTGT = SampleLib
SCRIPTSTGT =

#USE_JET=1
#USE_JETSTREAM=1
#USE_LLM=1

#JVTLIBS = jvtFirstTestLib
#SYSLIBS = rt pthread

include $(JVTROOT)/rules/mkrules.mk

