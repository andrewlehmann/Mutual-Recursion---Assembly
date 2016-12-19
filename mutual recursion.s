.data

# Andrew Lehmann
# Pls don't steal

eol: .asciiz "\n"
input: .asciiz ">>>"

.align 2
num: .word 0
fib: .word 0
luc: .word 0

.text

.globl main

main:

la $a0, input
jal display_str

li $v0, 5
syscall

sw $v0, num

lw $a0, num
jal rec_fib
sw $v0, fib

lw $a0, num
jal rec_lucas
sw $v0, luc

la $a0, eol
jal display_str

la $a0, fib
jal display_int

la $a0, eol
jal display_str

la $a0, luc
jal display_int

li $v0, 10
syscall




# rec_fib($a0 = n): return n-th fibonacci number
rec_fib:

	#Here we will be pushing every saved register we USE (and in the process change) in the function into the stack.
	#--------------------------------------------------#
	#Need to push 3 registers into the stack ($ra, a register to save the return value of first Lucas call, and $a0)
	addi $sp, $sp, -16	# Allocate space for 3 registers
	sw $ra, 0($sp)		# save $ra
	sw $s0, 4($sp)		# register for saving return value of first lucas call
	sw $a0, 8($sp)		# save a0, which is n
	sw $s5, 12($sp)		# TESTING
	#--------------------------------------------------#
	
beq $a0, 0, fibretzero
beq $a0, 1, fibretone
beq $a0, 2, fibretone

	#----------------------------------#
	
	#Change argument and call lucas function, move return value to saved register (same one pushed into stack)
	move $s5, $a0
	addi $a0, $a0, -1	# calculate a - 1
	jal rec_lucas
	move $s0, $v0

	#Change argument and call lucas function again.
	move $a0, $s5
	#lw $a0, 8($sp)
	addi $a0, $a0, 1	#calculate a + 1
	jal rec_lucas
	
	#Do the following: ([Lucas(a-1) + Lucas (a+1)]/5), move result to return register
	add $a1, $s0, $v0	# calculate lucas(a-1) + lucas(a+1)
	li $a2, 5
	div $a1, $a2		#divide by 5
	mflo $v0
	
	#Jump to return of fibreturn
	j fibreturn
	#------------------------------------------#
	
fibretzero:

li $v0, 0
j fibreturn
fibretone:
li $v0, 1
j fibreturn

fibreturn:

	#----------------------------#
	#pop all registers from the stack (stack should be empty before the jr $ra instruction)
	lw $ra, 0($sp)		# save $ra
	lw $s0, 4($sp)		# register for saving return value of first lucas call
	lw $a0, 8($sp)		# save a0, which is n
	lw $s5, 12($sp)		# TESTING
	addi $sp, $sp, 16
	#-----------------------------#
jr $ra



# rec_lucas($a0): return ($a0)-th lucas number
rec_lucas:

	#Here we will be pushing every saved register we USE (and in the process change) in the function into the stack.

	#-------------------------------------#
	#pushing 7 register's values into stack
	#$ra, registers to save returns of first, second and third function calls, $a0, register for m and register for n)(total 7)
	addi $sp, $sp, -28
	sw $ra, 0($sp)		#return address
	sw $s1, 4($sp)		#return of first
	sw $s2, 8($sp)		#return of second
	sw $s3, 12($sp)		#return of third
	sw $a0, 16($sp)		#a0
	sw $t3, 20($sp)		#register for m
	sw $t4, 24($sp)		#refister for n
	


	#---------------------------------------#

beq $a0, 0, lucasrettwo
beq $a0, 1, lucasretone
beq $a0, 2, lucasretthree

	#------------------------------------------#
	#split argument value into m and n
	li $a1, 2
	div $a0, $a1		#divide A by 2
	mflo $a1
	mfhi $a3
	bne $a3, $zero, notZero	#if remainder is NOT zero, jump
	
	move $t3, $a1		#save m
	move $t4, $a1		#save n
	j afterSettingMN
	
	notZero:
	
	addi $a2, $a1, 1	# a2 = a1 + 1 (n)
	move $t3, $a1		# save m in t3
	move $t4, $a2		# save n in t4
	
	afterSettingMN:
	#Load argument and call Lucas function recursively, save return value to register we saved in stack for it.
	
	move $a0, $t3
	addi $a0, $a0, 1	
	jal rec_lucas		#calls L(m+1)
	move $s1, $v0		#store return value
	
	#Load argument and call Fib function, save return value to register we saved in stack for it.
	move $a0, $t4
	jal rec_fib		#calls F(n)
	move $s2, $v0
	
	#Load argument and call Lucas function recursively, save return value to register we saved in stack for it.
	move $a0, $t3
	jal rec_lucas		#calls L(m)
	move $s3, $v0
	
	#Load argument and call Fib function, can use this return value directly (no need to save)
	move $a0, $t4
	addi $a0, $a0, -1
	jal rec_fib		#calls F(n - 1)
	
	#Solve the following expression: L(m + 1)F(n) + L(m)F(n - 1), store result in return register
	mult $s1, $s2		#THIS WORKS AS INTENDED
	mflo $t0
	mult $s3, $v0
	mflo $t1
	add $v0, $t0, $t1
	#jump to lucasreturn
	j lucasreturn

	#------------------------------------------#

lucasrettwo:
li $v0, 2
j lucasreturn

lucasretone:
li $v0, 1
j lucasreturn

lucasretthree:
li $v0, 3
j lucasreturn

lucasreturn:

	#--------------------------------#
	#pop all registers from stack (it has to be empty before the jr $ra instruction)
	lw $ra, 0($sp)		#return address
	lw $s1, 4($sp)		#return of first
	lw $s2, 8($sp)		#return of second
	lw $s3, 12($sp)		#return of third
	lw $a0, 16($sp)		#a0
	lw $t3, 20($sp)		#register for m
	lw $t4, 24($sp)		#refister for n
	addi $sp, $sp, 28
	#-------------------------------#
jr $ra

display_str: # $a0: address of the string to display
li $v0, 4
syscall
jr $ra

display_int: # $a0: the ADDRESS of the int value to display
lw $a0, ($a0)
li $v0, 1
syscall
jr $ra
