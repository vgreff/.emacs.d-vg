
DOXYGEN  = /opt/jump/x86_64/doxygen-1.7.1-JUMP1.00/bin/doxygen

worldinstallg worldinstallo worldinstall worldcleang worldcleano worldclean worldrealcleang worldrealcleano worldrealclean:
	@for d in $(SUBDIRS); do ( $(MAKE) -C $$d $@); if [ $$? -ne 0 ]; then exit 1;fi ; done

cleang : worldcleang

cleano : worldcleano

clean : worldclean

realcleang : worldrealcleang

realcleano : worldrealcleano

realclean : worldrealclean

installg buildg : worldinstallg

installo buildo : worldinstallo

install build : worldinstall

doxy:
	$(DOXYGEN) jvt.doxy

.DEFAULT_GOAL := install
