.data

#1024 é o limite de caracteres 
output:	.space	1024
#o caminho do arquivo tem que ir todo pra funcionar
fileName: .asciiz"/home/felipe/Documents/Workspace/ArquiteturaComputadores/mundo-reverso-assembly/teste.txt"      
fileOutputName: .asciiz "/home/felipe/Documents/Workspace/ArquiteturaComputadores/mundo-reverso-assembly/output.txt"     

fileWords: .space 1024 #buffer

.text

main:
	open_file:
		li   $v0, 13       # codigo de abrir arquivo
		la   $a0, fileName      # carrega endereço de arquivo
		li   $a1, 0        # abre pra leitura
		syscall            
		move $s0, $v0      # salva descritor de arquivo

	read_file:
		li   $v0, 14       # codigo para ler arquivo
		move $a0, $s0      # carrega descritor
		la   $a1, fileWords   # carrega endereço do buffer de leitura
		la   $a2, 1024     # tamanho de buffer hardcoded 
		syscall            

	la	$a0, fileWords		#carrega a posição do arquivo
	jal	strlen			# calcula tamanho da string e salva retorno em $ra
	
	add	$t1, $zero, $v0		# Copia de parametros
	add	$t2, $zero, $a0		
reverse:
	li	$t0, 0			# reseta t0 e t3 
	li	$t3, 0			
	
	reverse_loop:
		add	$t3, $t2, $t0		# endereço de base do array
		lb	$t4, 0($t3)		# carrega a posição de acordo com o contador
		
		beqz	$t4, writeFile		# chegou no final
		
		blt $t4, 'A', checkSpace  # < A, não é uma letra.  Casos especiais 'Ç', 'ã', etc entram aqui, por não ter suporte à unicode o simulador lê um valor negativo
			
		ble $t4, 'Z', isUpper #  >=A e <=Z, é uma letra maiuscula
		
		blt $t4, 'a', checkSpace #  < a, não é uma letra
		
		ble $t4, 'z', isLower #  >=a e <=z, é uma letra minuscula
			
		b save # default case (casos especiais 'Ç', 'ã', etc cairiam aqui se tivesse suporte no mars) 
		
	isUpper:
		addi $t4, $t4, 32 # converte pela tabela ascii maiuscula para minuscula
		b save 
		
	isLower:
		addi $t4, $t4, -32 # converte pela tabela ascii minuscula pra maiuscula
	save:
		sb	$t4, output($t1)	# Sobrescreve o byte			
		subi	$t1, $t1, 1		# subtrai o contador de tamanho da string
		addi	$t0, $t0, 1		# contador + 1
		j	reverse_loop		# jump pra label loop
	
	checkSpace:
		beq $t4, ' ', save		# se for espaço em branco salva e volta pro loop
		add $t1, $t4, $zero
			
writeFile:
	#abre o arquivo output.txt
	li $v0,13
	la $a0, fileOutputName
	li $a1, 1
	syscall
	move $s1, $v0
	
	#escreve 
	li $v0,15
	move $a0,$s1
	la $a1, output
	la $a2, 0($t0)  #carrega tamanho do texto (pra saber onde termina e não imprimir lixo de memória)
	syscall
	
	#fecha arquivo
	li $v0, 16
	move $a0, $s1
	syscall
exit:
	li	$v0, 10			
	syscall

strlen:
	li	$t0, 0
	li	$t2, 0
	
	strlen_loop:
		add	$t2, $a0, $t0 #carrega infos do array para contagem
		lb	$t1, 0($t2)		

		beqz	$t1, strlen_exit
		beq $t1, 0x20, counter_loop #Verifica se é espaço em branco, precisa redirecionar pois 0x20 é menor que 'A'.
		blt $t1, 'A', strlen_exit # Se for menor que A é condição de parada do sistema, então para a contagem

		counter_loop:
			addiu	$t0, $t0, 1 #Incrementa contador
			j	strlen_loop

	strlen_exit:
		subi	$t0, $t0, 1  #subtrai 1 da contagem pra pegar o total
		add	$v0, $zero, $t0 #salva contagem
		add	$t0, $zero, $zero #limpa t0
		jr	$ra

		