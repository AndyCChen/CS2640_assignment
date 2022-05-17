# Andy Chen
.data
welcome_msg: .asciiz "Welcome to Chuck-a-luck.\n"
input_prompt1: .asciiz "\nEnter a seed number: "
input_prompt2: .asciiz "\nEnter your wager amount: "
input_prompt3: .asciiz "What number do you want to bet on (1-6)? "
input_prompt4: .asciiz "You currently have $"
result_prompt1: .asciiz "\nI roll "
result_prompt2: .asciiz "\nYou matched once.\n"
result_prompt3: .asciiz "\nYou matched twice.\n"
result_prompt4: .asciiz "\nYou matched thrice.\n"
result_prompt5: .asciiz "\nYou did not match any.\n"
end_game: .asciiz "Bye!\n"
lose_game: .asciiz "Game Over! You lost all your money.\n"
error_prompt1: .asciiz "Your bet must be between 1 and 6!\n "
error_prompt2: .asciiz "Your wager must be between zero and the balance amount!\n"
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
	# 		$s0 = balance amount, initilized to 500
	# 		$s1 = 1 min bet value
	#	   $s2  = 6 max bet value
	# 		$v0 = used for syscall and hold returning value from rand which will be saved in $t4
	# Funtion Description:
	#		This routine gets input for seed value and calls getUserInput for
	#		the wager amout and their dice roll	bet.
	#		Then calls rand three times to get the dice roll and compares
	#		with user dice roll bet.
	#########################################################################
	li $s0, 500
	li $s1, 1
	li $s2, 6
	
	# print all opening prompts
	li $v0, 4
	la $a0, welcome_msg
	syscall
	la $a0, input_prompt4
	syscall
	li $v0, 1
	move $a0, $s0
	syscall
	li $v0, 4
	la $a0,input_prompt1
	syscall
	
	# get initial seed value from user input
	li $v0, 5
	syscall
	sw $v0, seed
	
	# jump to getUserInput routine
	game_loop:
	jal getUserInput
	
	# initialize loop counter to 3 and matching dice roll counter to 0
	li $t2, 3
	li $t3, 0
	
	# call rand three times and increment $t3 when $t1 (user bet) equals $t4 (random dice roll)
	loop1: jal rand
	move $t4, $v0		# save random number to $t4
	
	# print dice roll results
	li $v0, 4
	la $a0, result_prompt1
	syscall
	li $v0, 1
	move $a0, $t4
	syscall
	
	bne $t1, $t4, skip	# only increment if $1 == $t4
	addiu $t3, $t3, 1
	skip:
	addi $t2, $t2, -1
	bnez $t2, loop1		# end loop
	
	li $v0, 4		# print string syscall
	
	# skip wager multiplication if $t3 (dice roll matches) equals zero
	beqz $t3, zeroMatch
	mul $t0, $t0, $t3		# multiply wager amount by how many times dice roll matched user dice roll bet
	mflo $t0
	add $s0, $s0, $t0
	
	# branch to appropriate msg depending on how many dice rolls the user matches
	beq $t3, 1, oneMatch
	
	beq $t3, 2, twoMatch
	
	beq $t3, 3, threeMatch
	
	zeroMatch: 
	sub $s0, $s0, $t0		# deduct money from current wager balance
	la $a0, result_prompt5
	j printResult
	
	oneMatch: 
	la $a0, result_prompt2
	j printResult
	
	twoMatch: 
	la $a0, result_prompt3
	j printResult
	
	threeMatch: 
	la $a0, result_prompt4
	j printResult
	
	printResult: syscall
	
	# print game over msg and terminate if balance is zero or less
	ble $s0, $zero, gameOver
	
	# print current wager balance
	li $v0, 4
	la $a0, input_prompt4
	syscall
	li $v0, 1
	la $a0, ($s0)
	syscall
	j game_loop		# loop back to continue playing the game again
	
	gameOver: 
	li $v0, 4
	la $a0, lose_game
	syscall
	li $v0, 10
	syscall
	
getUserInput:
	##########################################################################
	# Registers:
	# 		$t0 = wager amount, $t1 = dice number 
	# Funtion Description:
	#		This routine gets the user input for wager amout and dice roll.
	#		Will loop if dice roll is out of 1-6 range.
	##########################################################################
	
	# loop for wager input and validation
	loop3:
	li $v0, 4
	la $a0, input_prompt2
	syscall
	li $v0, 5
	syscall
	beqz $v0, exit		# if wager input is zero, jump to exit and terminate program
	blt $v0, $zero,invalid_wager
	bgt $v0, $s0, invalid_wager
	move $t0, $v0
	li $v0, 4
	j loop2
	
	# game termination due to user choices
	exit:
	li $v0, 4
	la $a0, end_game
	syscall
	li $v0, 10
	syscall
	
	# print error msg for invalid input
	invalid_wager:
	li $v0, 4
	la $a0, error_prompt2
	syscall
	j loop3
	
	# loop for dice bet input and validation
	loop2:
	la $a0, input_prompt3
	syscall
	li $v0, 5
	syscall
	blt $v0, $s1, invalid_bet
	bgt $v0, $s2, invalid_bet
	move $t1, $v0
	jr $ra
	
	# print error msg for invalid input
	invalid_bet:
	li $v0, 4
	la $a0, error_prompt1
	syscall
	j loop2
	
rand:
	####################################################
	# Registers:
	# 		$v0: return value of random number 1-6
	# 		$t6: temporary value to store calculations
	####################################################
	lw $v0, seed
	sll $t6, $v0, 13
	xor $v0, $v0, $t6
	srl $t6, $v0, 17
	xor $v0, $v0, $t6
	sll $t6, $v0, 5
	xor $v0, $v0, $t6
	sw $v0, seed
	andi $v0, $v0 0xFFFF
	li $t6, 6
	
	div $v0, $t6
	mfhi $v0
	add $v0, $v0, 1
	jr $ra
	
