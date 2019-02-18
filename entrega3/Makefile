# Unix makefile for tigermain example
HOME=/usr/local/bin
#HOME=/usr/bin
MOSMLHOME=${HOME}
MOSMLTOOLS=camlrunm /usr/local/share/mosml/tools
#MOSMLTOOLS=camlrunm /usr/share/mosml/tools
MOSMLLEX=mosmllex
MOSMLYACC=mosmlyac -v

GCC=gcc
CFLAGS= -g
MOSMLC=${MOSMLHOME}/mosmlc -c -liberal
MOSMLL=${MOSMLHOME}/mosmlc

# Unix
REMOVE=rm -f
MOVE=mv
EXEFILE=

# DOS
#REMOVE=del
#MOVE=move
#EXEFILE=.exe

.SUFFIXES :
.SUFFIXES : .sig .sml .ui .uo
GRALOBJS= tigerabs.uo tigergrm.uo tigerlex.uo tigercanon.uo tigermain.uo \
	tigernlin.uo tigerpp.uo tigerescap.uo tigerassem.uo tigertab.uo tigerseman.uo tigertemp.uo topsort.uo tigertree.uo \
	tigertopsort.uo tigerframe.uo tigertrans.uo tigerit.uo tigerpila.uo tigermuestratipos.uo tigerinterp.uo tigerit.uo tigermunch.uo tigerbuild.uo tigercolor.uo \
	tigersimpleregalloc.uo


all: tiger

tiger: $(GRALOBJS) $(OBJSGEN)
	$(MOSMLL) -o tiger $(EXEFILE) tigermain.uo

tigergrm.sml tigergrm.sig: tigergrm.y 
	$(MOSMLYACC) tigergrm.y

tigerlex.sml: tigerlex.lex
	$(MOSMLLEX) tigerlex.lex

clean:
	$(REMOVE) Makefile.bak
	$(REMOVE) tigergrm.output
	$(REMOVE) tigergrm.sig
	$(REMOVE) tigergrm.sml
	$(REMOVE) tigerlex.sml
	$(REMOVE) tigermain
	$(REMOVE) *.ui
	$(REMOVE) *.uo
	$(REMOVE) errlist
	$(REMOVE) *.o

.sig.ui:
	$(MOSMLC) $<

.sml.uo:
	$(MOSMLC) $<

depend: tigerabs.sml tigergrm.sml tigerlex.sml tigermain.sml \
	tigernlin.sml tigerpp.sml tigertopsort.sml tigermuestratipos.sml
	$(REMOVE) Makefile.bak
	$(MOVE) Makefile Makefile.bak
	$(MOSMLTOOLS)/cutdeps < Makefile.bak > Makefile
	$(MOSMLTOOLS)/mosmldep >> Makefile

### DO NOT DELETE THIS LINE
tigerpp.uo: tigerabs.uo 
tigertrans.uo: tigertrans.ui tigertree.uo tigerpila.ui tigerframe.ui \
    tigerit.uo tigertemp.ui tigerabs.uo 
tigertrans.ui: tigertree.uo tigerframe.ui tigertemp.ui tigerabs.uo 
tigerescap.ui: tigerabs.uo 
tigerframe.ui: tigertree.uo tigertemp.ui 
tigerframe.uo: tigerframe.ui tigertree.uo tigertemp.ui 
tigermuestratipos.ui: tigertips.uo 
tigerseman.ui: tigerabs.uo 
tigerescap.uo: tigerescap.ui tigertab.ui tigerabs.uo 
tigerit.uo: tigertree.uo tigertab.ui 
tigertree.uo: tigertemp.ui 
tigerseman.uo: tigerseman.ui tigersres.uo tigertab.ui tigerpila.ui \
    tigerabs.uo tigertrans.ui tigermuestratipos.ui
tigergrm.uo: tigergrm.ui tigernlin.uo tigerabs.uo 
tigerpila.uo: tigerpila.ui 
tigersres.uo: tigertab.ui tigertips.uo tigertemp.ui tigertopsort.ui \
	tigerabs.uo tigertrans.ui 
tigerassem.uo: tigertemp.ui 
tigertab.ui: tigerassem.uo
tigertab.uo: tigertab.ui 
tigercanon.ui: tigertree.uo tigertemp.ui 
tigercanon.uo: tigercanon.ui tigertree.uo tigertab.ui tigertemp.ui 
tigersimpleregalloc.ui: tigerassem.ui tigerframe.ui
tigersimpleregalloc.uo: tigersimpleregalloc.ui
tigerbuild.ui: tigertab.ui tigerassem.ui tigertemp.ui tigerframe.ui
tigerbuild.uo: tigerbuild.ui 
tigercolor.ui: tigertab.ui tigerassem.ui tigertemp.ui tigerbuild.ui tigerframe.ui
tigercolor.uo: tigercolor.ui 
tigermain.uo: tigerseman.ui tigerescap.ui tigergrm.ui tigerlex.uo \
    tigerpp.uo tigerinterp.uo tigerit.uo tigertrans.ui tigermunch.uo tigerbuild.ui tigercanon.ui tigersimpleregalloc.ui \
	tigercolor.ui
tigertemp.uo: tigertemp.ui 
tigerlex.uo: tigergrm.ui tigernlin.uo 
tigertopsort.uo: tigertopsort.ui tigertab.ui tigertips.uo tigerabs.uo \
    tigermuestratipos.ui
tigertopsort.ui: tigertab.ui tigertips.uo tigerabs.uo 
tigermuestratipos.uo: tigermuestratipos.ui tigertips.uo 
tigerinterp.ui: tigertree.uo tigerframe.ui tigertemp.ui 
tigerinterp.uo: tigerinterp.ui tigertree.uo tigertab.ui tigerframe.ui \
    tigerit.uo tigertemp.ui


tigermunch.ui: tigertree.uo tigerassem.uo 
tigermunch.uo: tigermunch.ui tigertree.uo tigerframe.ui tigerassem.uo \
    tigertemp.ui  

tigergrm.ui: tigerabs.uo 
