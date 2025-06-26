AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

all: bin/pianificatore

bin/pianificatore: obj/pianificatore.o obj/EDF.o obj/HPF.o obj/lettura.o obj/stampa.o obj/convertitore.o 
	ld $(LD_FLAGS)  obj/pianificatore.o obj/EDF.o obj/HPF.o obj/lettura.o obj/stampa.o obj/convertitore.o -o bin/pianificatore

obj/pianificatore.o: src/pianificatore.s
	as $(AS_FLAGS) $(DEBUG) src/pianificatore.s -o obj/pianificatore.o
	
obj/EDF.o: src/EDF.s
	as $(AS_FLAGS) $(DEBUG) src/EDF.s -o obj/EDF.o
	
obj/HPF.o: src/HPF.s
	as $(AS_FLAGS) $(DEBUG) src/HPF.s -o obj/HPF.o

obj/lettura.o: src/lettura.s
	as $(AS_FLAGS) $(DEBUG) src/lettura.s -o obj/lettura.o

obj/stampa.o: src/stampa.s
	as $(AS_FLAGS) $(DEBUG) src/stampa.s -o obj/stampa.o

obj/convertitore.o: src/convertitore.s
	as $(AS_FLAGS) $(DEBUG) src/convertitore.s -o obj/convertitore.o

clean:
	rm -f obj/*.o bin/pianificatore bin/EDF bin/HPF bin/lettura bin/stampa bin/convertitore
