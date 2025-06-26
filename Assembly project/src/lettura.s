#FUNZIONE CHE LEGGE I DATI PRESENTI NEL FILE DEGLI ORDINI,
#LI CONTROLLA E LI CARICA NELLO STACK

.section .data

frase_erroreFile:
    .ascii "Il file selezionato è vuoto. Ricontrollare il file.\n"
frase_erroreFile_len:
    .long .-frase_erroreFile

frase_erroreID:
    .ascii "Il file selezionato contiene valori di ID non corretti. Ricontrollare il file.\n"
frase_erroreID_len:
    .long .-frase_erroreID

frase_erroreDur:
    .ascii "Il file selezionato contiene valori di Durata non corretti. Ricontrollare il file.\n"
frase_erroreDur_len:
    .long .-frase_erroreDur

frase_erroreScad:
    .ascii "Il file selezionato contiene valori di Scadenza non corretti. Ricontrollare il file.\n"
frase_erroreScad_len:
    .long .-frase_erroreScad

frase_errorePrior:
    .ascii "Il file selezionato contiene valori di Priorità non corretti. Ricontrollare il file.\n"
frase_errorePrior_len:
    .long .-frase_errorePrior

fd:
    .int 0                      # File descriptor

buffer: 
    .string ""                  # Spazio per il buffer di input
newline: 
    .byte 10                    # Valore del simbolo di nuova linea
cf:             		# Carriage Feed
    .byte 13
comma:          		# Virgola
    .byte 44 

valore: 
    .int 0
oldValue:
    .int 0

nvalori:
    .int 0

controllo: 
    .int 1

NUL:
    .ascii "NUL"


.section .text
	.global lettura

.type lettura, @function 

lettura:

    	popl %esi           # Ottengo l'indirizzo della riga di codice dopo la CALL e la metto in ESI, 
                        # cosi' che poi riesco a ritornare nel main
    	movl %ebx, fd                   

    	cmpl NUL, %ebx 

    	je _erroreFile 
    

_read_loop:			# Legge il file riga per riga

    	mov $3, %eax        	# syscall read
    	mov fd, %ebx        	# File descriptor
    	mov $buffer, %ecx   	# Buffer di input 
    	mov $1, %edx        	# Lunghezza massima
    	int $0x80           	# Interruzione del kernel

    	cmp $0, %eax        	# Controllo se ci sono errori o il file è terminato
    	jle _fineFunzione   	# In caso affermativo, chiudo il file 
    
    # Controllo se ho una nuova linea
    	movb buffer, %al    # copio il carattere dal buffer ad AL

    	cmp newline, %al    # confronto AL con il carattere \n
    	jne _insertProduct  # Inserisce il prodotto nello STACK (SE appunto non siamo arrivati alla fine del FILE)

    	jmp _controllo


_controllo:     			#Controllo che i valori dei campi siano corretti                 
    	cmpb $1, controllo      
    	je _ctrl1             
    	cmpb $2, controllo
    	je _ctrl2
    	cmpb $3, controllo     
    	je _ctrl3
    	cmpb $4, controllo
    	je _ctrl4
    

_ifComma:
# incontrata una virgola (o \n) pusco l'intero calcolato nello stack
    	push valore         # Variabile contente il valore intero
    	cmpb comma, %al
    	jne _nvalori
    	cmpb cf, %al        # Controlliamo i valori se non sono {newline, comma, cf}
    	jne _nvalori
    	cmpb newline, %al
    	jne _nvalori
    	movb $0, valore     # Resettiamo il valore di somma a 0
    	movl $0, oldValue
    	jmp _read_loop
 

_nvalori:
# conto i valori inseriti nello stack per poterlo poi svuotare (e stampare)
    	incl nvalori
    	movb $0, valore         # Resettiamo il valore di somma a 0
    	movl $0, oldValue       # e OldValue a 0
    	jmp _read_loop


_ctrl1:				#Controllo sul range di ID: 1-127
    	cmpb $1, valore
    	jl _erroreID
    	cmpb $127, valore
    	jg _erroreID
    
    	incl controllo
    	jmp _ifComma


_ctrl2:				#Controllo sul range della Durata: 1-10 
    	cmpb $1, valore
    	jl _erroreDur
    	cmpb $10, valore
    	jg _erroreDur
    
    	incl controllo
    	jmp _ifComma


_ctrl3:				#Controllo sul range della Scadenza: 1-100
    	cmpb $1, valore
    	jl _erroreScad
    	cmpb $100, valore
    	jg _erroreScad
    
    	incl controllo
    	jmp _ifComma


_ctrl4:				#Controllo sul range della Priorità: 1-5
    	cmpb $1, valore
    	jl _errorePrior
    	cmpb $5, valore
    	jg _errorePrior

    	movl $1, controllo
    	jmp _ifComma


_insertProduct:

    	cmpb cf, %al            
    	je _read_loop           # Controlliamo se {comma, cf}
    	cmpb comma, %al
    	je _controllo

    # Convertire il carattere in un intero 

    	movb %al, valore        # Muovo il contenuto della stringa in valore
    	subl $48, valore        # Converto il codice ASCII della cifra corrispondente

    # Concateno le cifre se non ho finito di leggere il numero con la virgola
    
    	movb oldValue, %al      # Muovo il valore di OldValue in EAX
    	movl $10, %edx
    	mulb %dl                # in EAX e' contenuto 10 (EAX * 10)
    	movb %al, oldValue
    	movb valore, %al
    	addb oldValue, %al      # 30 (oldValue)= + 5 (Value) = 35 (Nuovo valore)
    	movb %al, valore

    	movb %al, oldValue
        
    	jmp _read_loop          # Abbiamo inserito un intero prodotto nello stack (tutti e 4 i campi)


_erroreFile:
    	movl $4, %eax          
    	movl $2, %ebx
    	leal frase_erroreFile, %ecx
    	movl frase_erroreFile_len, %edx
    	int $0x80
    		
    	movl $77, %ebx         
    	jmp _fineFunzione
    
_erroreID:
    	movl $4, %eax           
    	movl $2, %ebx
    	leal frase_erroreID, %ecx
    	movl frase_erroreID_len, %edx
    	int $0x80
    
    	movl $77, %ebx        
    	jmp _fineFunzione
    
_erroreDur:
    	movl $4, %eax          
    	movl $2, %ebx
    	leal frase_erroreDur, %ecx
    	movl frase_erroreDur_len, %edx
    	int $0x80
    
    	movl $77, %ebx         
    	jmp _fineFunzione    

_erroreScad:
    	movl $4, %eax           
    	movl $2, %ebx
    	leal frase_erroreScad, %ecx
    	movl frase_erroreScad_len, %edx
    	int $0x80
    
    	movl $77, %ebx         
    	jmp _fineFunzione
    
_errorePrior:
    	movl $4, %eax           
    	movl $2, %ebx
    	leal frase_errorePrior, %ecx
    	movl frase_errorePrior_len, %edx
    	int $0x80
    
    	movl $77, %ebx         
    	jmp _fineFunzione    
    
_fineFunzione:

    	movl nvalori, %ecx
    
    # Pusho quindi il valore a cui deve ritornare la ret

    	pushl %esi

    	ret
