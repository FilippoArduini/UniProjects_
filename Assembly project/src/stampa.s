#FUNZIONE CHE STAMPA A VIDEO I RISULTATI

.section .data

penalty:
    .int 0

tempo:
    .int 0

nVal:
    .int 0

i:
    .int 0

due_punti:
    .ascii ":"
due_punti_len:
    .long .-due_punti

a_capo:
    .ascii "\n"
a_capo_len:
    .long .-a_capo

conclusione:
    .ascii "Conclusione: "
conclusione_len:
    .long .-conclusione

frase_penalty:
    .ascii "Penalty: "
frase_penalty_len:
    .long .-frase_penalty


.section .text
	.global stampa


.type stampa, @function

stampa:

    	movl $0, tempo      
    	movl $0, penalty
    
    	movl $4, %edx
    	mull %edx
    
    	movl %eax, nVal
    	movl $4, %ecx       


_for:
    	movl %ecx, i

    	cmp nVal, %ecx         
    	jg _last

    	movl %ecx, %ebx         	#Stampa ID del prodotto
    	addl $12, %ebx
    	movl (%esp, %ebx), %eax

    	call convertitore               

    	movl $4, %eax           	#Stampa i due punti
    	movl $1, %ebx
    	leal due_punti, %ecx
    	movl due_punti_len, %edx
    	int $0x80

    	movl tempo, %eax 
    	call convertitore               # Stampo il tempo in cui il prodotto corrente inizia la produzione
	
    	movl $4, %eax          		#Stampa andata a capo
    	movl $1, %ebx
    	leal a_capo, %ecx
    	movl a_capo_len, %edx
    	int $0x80
	
    	movl i, %ecx
	
    	movl $0, %eax
    	movl %ecx, %ebx     
    	addl $8, %ebx
    	addl (%esp, %ebx), %eax
    	addl %eax, tempo            	# aggiorno il tempo sommandogli la durata del prodotto corrente
		
    	movl %ecx, %ebx     
    	addl $4, %ebx               	# ottengo il valore di scadenza del prodotto corrente
    	movl (%esp, %ebx), %eax     	# per evenualmente calcolarne la penalita'

    	cmpl %eax, tempo        	#Confronto tempo e scadenza
    	jg _if                  	#Se t>s, devo calcolare la penalità

    	addl $16, %ecx          	#Passo al prodotto successivo
	
    	jmp _for


_if:					#Calcolo delle penalità

    	movl %ecx, %ebx     
    	addl $4, %ebx
    	movl (%esp, %ebx), %eax     

    	movl tempo, %ebx
    	subl %eax, %ebx     
    	movl %ebx, %eax    
   	
    	movl (%esp, %ecx), %edx     
    	mull %edx 
    		
    	addl penalty, %eax
  
    	movl %eax, penalty
	
    	addl $16, %ecx

    	jmp _for        


_last: 

    	movl $4, %eax           	#Stampa conclusione
    	movl $1, %ebx
    	leal conclusione, %ecx
    	movl conclusione_len, %edx
    	int $0x80
	
    	movl tempo, %eax
    	call convertitore               

    	movl $4, %eax           	#Stampa andata a capo
    	movl $1, %ebx
    	leal a_capo, %ecx
    	movl a_capo_len, %edx
    	int $0x80

    	movl $4, %eax           	#Stampa penalita' 
    	movl $1, %ebx
    	leal frase_penalty, %ecx
    	movl frase_penalty_len, %edx
    	int $0x80

    	movl penalty, %eax
    	call convertitore               	 

    	movl $4, %eax           	#Stampa andata a capo
    	movl $1, %ebx
    	leal a_capo, %ecx
    	movl a_capo_len, %edx
    	int $0x80
	
    	movl $4, %eax           	#Stampa andata a capo
    	movl $1, %ebx
    	leal a_capo, %ecx
    	movl a_capo_len, %edx
    	int $0x80

    	ret                     	#Torno al pianificatore
