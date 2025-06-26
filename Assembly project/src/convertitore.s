#FUNZIONE CHE CONVERTE UN INTERO IN UNA STRINGA. NECESSARIO PERCHE' LA STAMPA IN ASSEMBLY
#AVVIENE SOLO CON DATI DI TIPO ASCII MENTRE IL PROGRAMMA LAVORA CON DATI DI TIPO INT

.section .data

car: .byte 0			

.section .text
	.global convertitore

.type convertitore, @function		

convertitore:   
	movl $0, %ecx			


_continuaDivisione:
	cmpl $10, %eax	

	jge _dividi			#Salta a dividi se maggiore o uguale a 10

	pushl %eax			
	incl %ecx			

	movl %ecx, %ebx		

	jmp _stampa			


_dividi:
	movl $0, %edx			#Effettuo divisione per 10 del numero
	movl $10, %ebx			
	divl %ebx			

	pushl %edx			#Salva il resto della divisione nello stack

	incl %ecx			#Incrementa il contatore delle cifre 
						
	jmp _continuaDivisione	

	
_stampa:
	cmpl $0, %ebx			

	je _fineConv			#Controlla se ci sono caratteri da stampare o meno

	popl %eax			

	movb %al, car		

	addb $48, car			#Somma il codice ascii dello 0
  
	decl %ebx			#Decrementa le cifre da stampare
  
	pushw %bx			

	movl $4, %eax			#System call per la stampa
	movl $1, %ebx
	leal car, %ecx		
	movl $1, %edx
	int $0x80

	popw %bx			#Recupera gli eventuali caratteri ancora da stampare  
	jmp _stampa

_fineConv:				#Ritorno al programma
	ret
