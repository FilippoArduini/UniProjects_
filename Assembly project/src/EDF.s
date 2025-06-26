#ORDINA I PRODOTTI TRAMITE BUBBLE SORT METTENDO
#IN CIMA QUELLI CON DEADLINE PIU' VICINA

.section .data

flag:					#Se =0 non ordinato, se =1 ordinato
    .int 0

dim:
    .int 0

scadenza:
    .int 0

scadenzaSeg: 
    .int 0


.section .text
	.global EDF


.type EDF, @function

EDF:

    	movb $4, %bl
    	divb %bl

    	movb %al, dim       

    	movl $0, flag       

_while:
    	cmpb $0, flag       		#Se flag a 1, i prodotti sono ordinati. Posso uscire
    	jne _next           	
	
    	movl $1, flag

    	movl $0, %ecx       

    	movl $8, scadenza                       

_ciclo:
    	movl dim, %ebx
    	subl $1, %ebx
    	cmpl %ebx, %ecx
    	je _while           		#Controlla se siamo arrivati alla fine del ciclo
	
    	movl scadenza, %edx
    	addl $16, %edx
    	movl %edx, scadenzaSeg     
    	movl scadenza, %eax         

    
    	movl (%esp, %eax), %ebx 

    		#Confronto due scadenze vicine
    	movl scadenzaSeg, %eax  
    	cmpl (%esp, %eax), %ebx 
    		
    	jg _scambio  			#Se la prima scadenza è maggiore, faccio lo scambio

    	cmpl (%esp, %eax), %ebx     	#Caso in cui le Scadenze sono uguali
    	je _uguali 

    	incl %ecx                   	#Incrementiamo di 1
    	addl $16, scadenza

    	jmp _ciclo                  	#Ricomincio il ciclo 


_uguali:				#Se Scadenza uguale, ordino per Priorità

    	movl scadenza, %eax
    	subl $4, %eax    
    	movl (%esp, %eax), %eax     

    	movl scadenzaSeg, %ebx
    	subl $4, %ebx   
    	movl (%esp, %ebx), %ebx     

    	cmpl %ebx, %eax             
    	jle _scambio        
                                
    	incl %ecx                   
    	addl $16, scadenza
    	jmp _ciclo 


_scambio:				#Scambio i 4 valori di ciascun Prodotto

    	movl scadenza, %edx         
    	subl $4, %edx               
    	movl %edx, %eax
	
    	movl scadenzaSeg, %edx
    	subl $4, %edx 
    	movl %edx, %ebx
    
    		#Scambio Priorità
    	movl (%esp, %eax), %edx
    	movl (%esp, %ebx), %edi    
    	movl %edi, (%esp, %eax)    
    	movl %edx, (%esp, %ebx)

    		#Scambio Scadenza
    	addl $4, %eax
    	addl $4, %ebx

    	movl (%esp, %eax), %edx
    	movl (%esp, %ebx), %edi    
    	movl %edi, (%esp, %eax)    
    	movl %edx, (%esp, %ebx)

    		#Scambio Durata
    	addl $4, %eax
    	addl $4, %ebx

    	movl (%esp, %eax), %edx
    	movl (%esp, %ebx), %edi    
    	movl %edi, (%esp, %eax)   
    	movl %edx, (%esp, %ebx)

    		#Scambio ID
    	addl $4, %eax
    	addl $4, %ebx

    	movl (%esp, %eax), %edx
    	movl (%esp, %ebx), %edi    
    	movl %edi, (%esp, %eax)    
    	movl %edx, (%esp, %ebx)

    	movl $0, flag   		#Scambio terminato quindi imposto flag a 0

    	jmp _ciclo     			#Continuo fino a che lo stack non è ordinato

_next:					#Prodotti ordinati, torno in pianificatore
	ret
