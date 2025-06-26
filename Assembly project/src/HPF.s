#ORDINA I PRODOTTI TRAMITE BUBBLE SORT METTENDO
#IN CIMA QUELLI CON PRIORITA' PIU' ALTA

.section .data

flag:					#Se =0 non ordinato, se =1 ordinato
    .int 0

dim:
    .int 0

priorita:
    .int 0

prioritaSeg: 
    .int 0

.section .text
	.global HPF


.type HPF, @function

HPF:
    
    	movb $4, %bl
    	divb %bl

    	movb %al, dim       

    	movl $0, flag       
    
_while:

    	cmpb $0, flag       		#Se flag a 1, i prodotti sono ordinati. Posso uscire
    	jne _next           
    	movl $1, flag

    	movl $0, %ecx       

    	movl $4, priorita   

_ciclo:
    
    	movl dim, %ebx
    	subl $1, %ebx
    	cmpl %ebx, %ecx
    	je _while           		#Controlla se siamo arrivati alla fine del ciclo

    	movl priorita, %edx
    	addl $16, %edx
    	movl %edx, prioritaSeg     
    	movl priorita, %eax         

    
    	movl (%esp, %eax), %ebx 

   
    	movl prioritaSeg, %eax 
    	cmpl (%esp, %eax), %ebx 
    
    	jl _scambio  			#Se la prima Priorità è maggiore, faccio lo scambio

    	cmpl (%esp, %eax), %ebx     	#Caso in cui le Priorità sono uguali
    	je _uguali 

    	incl %ecx                   	#Incrementiamo di 1
    	addl $16, priorita

    	jmp _ciclo                  	#Ricomincio il ciclo


_uguali:				#Se Priorità uguale, ordino per Scadenza 

    	movl priorita, %eax
    	addl $4, %eax    
    	movl (%esp, %eax), %eax   

    	movl prioritaSeg, %ebx
    	addl $4, %ebx   
    	movl (%esp, %ebx), %ebx  
		
    	cmpl %ebx, %eax         
    	jg _scambio        
    	                        
    	incl %ecx 
    	addl $16, priorita
    	jmp _ciclo 


_scambio:				#Scambio i 4 valori di ciascun Prodotto
		#Scambio Priorità
    	movl priorita, %eax        
    	movl prioritaSeg, %ebx

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

    	jmp _ciclo      		#Continuo fino a che lo stack non è ordinato


_next:					#Prodotti ordinati, ritorno in Pianificatore
	ret
