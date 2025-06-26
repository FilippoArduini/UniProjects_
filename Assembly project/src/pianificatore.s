.section .data

frase_input:
    .ascii "input: ./bin/pianificatore <Ordini/nome_file.txt>\n"
frase_input_len:
    .long .-frase_input

frase_erroreFile:
    .ascii "Ri-eseguire utilizzando un file valido\n"
frase_erroreFile_len:
    .long .-frase_erroreFile

frase_menu:
    .ascii "Selezionare l'algoritmo di pianificazione:\n  1. EDF - Ordina per Scadenza\n  2. HPF - Ordina per Priorità\n  q. Uscire dal programma\n"
frase_menu_len:
    .long .-frase_menu

frase_EDF:
    .ascii "\nPianificazione EDF:\n"
frase_EDF_len:
    .long .-frase_EDF

frase_HPF:
    .ascii "\nPianificazione HPF:\n"
frase_HPF_len:
    .long .-frase_HPF

ascii_1:
    .ascii "1"
ascii_2:
    .ascii "2"  
ascii_q:
    .ascii "q"

argc:
    .int 0

file_desc:
    .int 0

nVal:
    .int 0

controllo:
    .int 0

.section .bss
    algoritmo: .string ""

.section .text
	.global _start

_start:

    	movl $0, controllo 
                            
	popl %esi			    
    	movl %esi, argc        
    	
    	cmpl $2, %esi
    	jg _input               	#Controlla che i parametri non siano maggiori di 2

	popl %esi               

	popl %esi			    
	testl %esi, %esi	    
	jz _input               

	movl $5, %eax		    	#System call Apertura file
	movl %esi, %ebx
	movl $0, %ecx		    

	int $0x80

	cmp $0, %eax            
	jl _erroreFile              	#Errore nel file dei prodotti

    	movl %eax, file_desc        
    
    	movl file_desc, %ebx        

    	call lettura

    	cmpl $77, %ebx              	#Errore nella lettura del FILE        
    	je _end
    
    	movl %ecx, nVal


_menu:
    	movl $4, %eax           	#Stampo richiesta di inserimento algoritmo
    	movl $1, %ebx
    	leal frase_menu, %ecx
    	movl frase_menu_len, %edx
    	int $0x80

    	xorl %ecx, %ecx			#Libero il registro

    	movl $3, %eax           	#System call lettura da tastiera
    	movl $0, %ebx           
    	leal algoritmo, %ecx    
    	movl $60, %edx          

    	int $0x80

    	movb ascii_1, %al
    	movb ascii_2, %bl
    	movb ascii_q, %cl

    	cmp %al, algoritmo      	#In base alla scelta dell'utente, seleziono il percorso 
    	je _EDF

    	cmp %bl, algoritmo
    	je _HPF

    	cmp %cl, algoritmo
    	je _fine                	#Errore in input

    	jmp _menu


_EDF:
    	movb nVal, %al          	#Passo come parametro il numero di valori alla funzione EDF
    	call EDF

    	movl $4, %eax
    	movl $1, %ebx
    	leal frase_EDF, %ecx        
    	movl frase_EDF_len, %edx
    	int $0x80
    
    	movb nVal, %al
    	call stampa                 	#Stampa risultati

    	jmp _menu                  


_HPF:
    	movb nVal, %al           
    	call HPF    

    	movl $4, %eax
    	movl $1, %ebx
    	leal frase_HPF, %ecx
    	movl frase_HPF_len, %edx
    	int $0x80

    	movb nVal, %al
    	call stampa             	#Stampiamo risultati

    	jmp _menu               

_input:
    	movl $4, %eax           	#Stampo frase errore di input
    	movl $2, %ebx
    	leal frase_input, %ecx
    	movl frase_input_len, %edx
    	int $0x80
    	jmp _fine

_erroreFile:
    	movl $4, %eax           	#Stampo frase errore del file
    	movl $2, %ebx
    	leal frase_erroreFile, %ecx
    	movl frase_erroreFile_len, %edx
    	int $0x80
    	jmp _fine

_fine:                      		#Mette il numero di valori inseriti nello stack in ECX
    	movl nVal, %ecx

_end: 
    	cmp $0, %ecx            	#Controlla se lo stack è stato svuotato completamente
    	jne _ciclo

    	mov $6, %eax            	#System call chiusura file
    	mov file_desc, %ecx     	
    	int $0x80               	

    	movl $1, %eax               	#System call fine programma
    	movl $0, %ebx
    	int $0x80          	

_ciclo:
    	popl %eax
    	loop _ciclo
    	jmp _end

