.data

#1024 é o limite de caracteres também
output:	.space	1024
#o caminho do arquivo tem que ir todo pra funcionar
fileName: .asciiz "/home/felipe/Documents/Workspace/ArquiteturaComputadores/Projeto/teste.txt"      # filename for input
fileOutputName: .asciiz "/home/felipe/Documents/Workspace/ArquiteturaComputadores/Projeto/output.txt"      # filename for output
fileWords: .space 1024

.text
	.globl main
main:
	#open a file for writing
	li   $v0, 13       # system call for open file
	la   $a0, fileName      # board file name
	li   $a1, 0        # Open for reading
	syscall            # open a file (file descriptor returned in $v0)
	move $s0, $v0      # save the file descriptor 

	#read from file
	li   $v0, 14       # system call for read from file
	move $a0, $s0      # file descriptor 
	la   $a1, fileWords   # address of buffer to which to read
	la   $a2, 1024     # hardcoded buffer length
	syscall            # read from file


	la	$a0, fileWords		#carrega a posição do arquivo
	jal	strlen			# JAL to strlen function, saves return address to $ra
	
	add	$t1, $zero, $v0		# Copy some of our parameters for our reverse function
	add	$t2, $zero, $a0		# We need to save our input string to $t2, it gets
	add	$a0, $zero, $v0		# butchered by the syscall.
	li	$v0, 1			# This prints the length that we found in 'strlen'

	syscall
	
reverse:
	li	$t0, 0			# Set t0 to zero to be sure
	li	$t3, 0			# and the same for t3
	
	reverse_loop:
		add	$t3, $t2, $t0		# $t2 is the base address for our 'input' array, add loop index
		lb	$t4, 0($t3)		# load a byte at a time according to counter
		beqz	$t4, writeFile		# We found the null-byte
		sb	$t4, output($t1)		# Overwrite this byte address in memory	
		subi	$t1, $t1, 1		# Subtract our overall string length by 1 (j--)
		addi	$t0, $t0, 1		# Advance our counter (i++)
		j	reverse_loop		# Loop until we reach our condition
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
	la $a2, ($t0) #valor contido (lenght do texto)
	syscall
	
	#fecha arquivo
	li $v0, 16
	move $a0, $s1
	syscall
exit:
	li	$v0, 4			# Print
	la	$a0, output		# the string!
	syscall
		
	li	$v0, 10			# exit()
	syscall
	

# strlen:
# a0 is our input string
# v0 returns the length
# -- This function loops over the character array until it encounters
# the null byte, interestingly, the 0x0a character is stored by default
# for input strings requested through the syscall. So we just subtract one
# from the end result.

strlen:
	li	$t0, 0
	li	$t2, 0
	
	strlen_loop:
		add	$t2, $a0, $t0
		lb	$t1, 0($t2)
		beqz	$t1, strlen_exit
		addiu	$t0, $t0, 1
		j	strlen_loop
		
	strlen_exit:
		subi	$t0, $t0, 1
		add	$v0, $zero, $t0
		add	$t0, $zero, $zero
		jr	$ra