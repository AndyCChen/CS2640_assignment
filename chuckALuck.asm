# Andy Chen
.data
welcome_msg: .asciiz "Welcome to Chuck-a-luck.\n"
input_prompt1: .asciiz "Enter a seed number: "
input_prompt2: .asciiz "\nEnter your wager amount: "
input_prompt3: .asciiz "What number do you want to bet on (1-6)? "
input_prompt4: .asciiz "You currently have "
result_prompt1: .asciiz "\nI roll "
result_prompt2: .asciiz "\nYou matched once.\n"
result_prompt3: .asciiz "\nYou matched twice.\n"
result_prompt4: .asciiz "\nYou matched thrice.\n"
result_prompt5: .asciiz "\nYou did not match any.\n"
error_prompt1: .asciiz "Your bet must be between 1 and 6!\n "
seed: .word 19462
.text

main: 
	#########################################################################
	# Registers:
	#		$t0 = wager amount
	#		$t1 = user dice roll bet
	#		$t2 = loop1 counter
	#		$t3 = number of times random dice roll equals user dice roll bet
	#		$t4 = hold random number that is returned from the rand routine
	# 		$s0 = starting money of 500
	# 		$s1 = 1 min bet value, $s2  = 6 max bet value
	# Funtion Description:
	#		This routine gets input for seed value and calls getUserInput for
	#		the wager amout and their dice roll	bet.
	#		Then calls rand three times to get the dice roll and compares
	#		with user dice roll bet.
	#########################################################################
	li $s0, 500
	li $s1, 1
	li $s2, 6
	li $v0, 4
	la $a0, welcome_msg
	syscall
	la $a0,input_prompt1
	syscall
	li $v0, 5
	syscall
	sw $v0, seed
	jal getUserInput
	
	# initialize loop counter to 3 and matching dice roll counter to 0
	li $t2, 3
	li $t3, 0
	
	loop1: jal rand
	move $t4, $v0 # save random number to $t4
	li $v0, 4
	la $a0, result_prompt1
	syscall
	li $v0, 1
	move $a0, $t4
	syscall
	
	bne $t1, $t4, skip
	addiu $t3, $t3, 1
	skip:
	addi $t2, $t2, -1
	bnez $t2, loop1
	
	li $v0, 10
	syscall
	
getUserInput:
	# Registers:
	# 		$t0 = wager amount, $t1 = dice number 
	# Funtion Description:
	#		This routine gets the user input for wager amout and dice roll.
	#		Will loop if dice roll is out of 1-6 range.
	li $v0, 4
	la $a0, input_prompt2
	syscall
	li $v0, 5
	syscall
	move $t0, $v0
	li $v0, 4
	
	loop2:
	la $a0, input_prompt3
	syscall
	li $v0, 5
	syscall
	blt $v0, $s1, invalid_bet
	bgt $v0, $s2, invalid_bet
	move $t1, $v0
	jr $ra
	invalid_bet:
	li $v0, 4
	la $a0, error_prompt1
	syscall
	j loop2
	
rand:
	# Registers:
	# 		$v0: return value of random number 1-6
	# 		$t0: temporary value to store calculations
	lw $v0, seed
	sll $t0, $v0, 13
	xor $v0, $v0, $t0
	srl $t0, $v0, 17
	xor $v0, $v0, $t0
	sll $t0, $v0, 5
	xor $v0, $v0, $t0
	sw $v0, seed
	andi $v0, $v0 0xFFFF
	li $t0, 6
	
	div $v0, $t0
	mfhi $v0
	add $v0, $v0, 1
	jr $ra
	
