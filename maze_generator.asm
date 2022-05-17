# Andy Chens
.data
promptOne: .asciiz "Please enter a random seed: "
promptTwo: .asciiz "Enter the width of the maze: "
promptThree: .asciiz	"Enter the height of the maze: "
wid:     .word 10    # Length of one row, must be 4n - 1
hgt:     .word 10    # Number of rows
cx:     .word 0
cy:     .word 0
numLeft:      .word 0
board:     .space 1600    # Max 40 x 40 maze
.text

main:
	jal getSize	
	
	jal initBoard
	
	li $v0, 10
	syscall

########################################################################
# Function Name: getSize
########################################################################
# Functional Description:
#    Ask the user for the size of the maze.  If they ask for a dimension
#    less than 5, we will just use 5.  If they ask for a dimension greater
#    than 40, we will just use 40.  This routine will store the size into
#    the globals wid and hgt.
#
########################################################################
# Register Usage in the Function:
#    $t0 -- Pointer into the board
#    $t1, $t2 -- min and max values
#    $t3, $t4 -- loop counters
#    $t6 -- the value to store
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Prompt for the two values
#    2. Fetch each of the two values
#    3. Limit the values to the range 5 <= n <= 40
#    4. Store into wid and hgt
#
########################################################################
getSize:
	# load min and max values for user input
	li $t1, 5
	li $t2, 40


	# print prompt
	li $v0, 4
	la $a0, promptTwo
	syscall
	# read integer for width
	li $v0, 5
	syscall
	blt, $v0, 5, lessThanFive
	bgt $v0, 40, greaterThanForty
	# store input into wid label
	sw $v0, wid
	j readHeight # jump to get height from user
	
	# if user input less than 5, just use 5 
	lessThanFive: sw $t1, wid
		j readHeight
		# if user input greater than 40, just use 40
	greaterThanForty: sw $t2, hgt
		j readHeight
	
	readHeight:
	# print prompt
	li $v0, 4
	la $a0, promptThree
	syscall
	# read integer for height
	li $v0, 5
	syscall
	# store input into hgt label
	sw $v0, hgt
	
	jr $ra
	# end getSize
	
########################################################################
# Function Name: initBoard
########################################################################
# Functional Description:
#    Initialize the board array.  All of the cells in the middle of the
#    board will be set to 0 (empty), and all the cells on the edges of
#    the board will be set to 5 (border).
#
########################################################################
# Register Usage in the Function:
#    $t0 -- Pointer into the board
#    $t1, $t2 -- wid - 1 and hgt - 1, the values for the right edge and
#     bottom row.
#    $t3, $t4 -- loop counters
#    $t6 -- the value to store
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Set $t0 to point to the board
#    2. Build nested loops for each row and column
#     2a. If we are in the first or last iteration of either loop,
#     place a 5 in the board.
#     2b. Otherwise, place a 0 in the board
#     2c. Increment $t0 after each placement, to go to the next cell.
#
########################################################################
initBoard: 
	# initialize loop counter
	li $t3, 0 # outer loop - row
	li $t4, 0 # innter loop - column
	
	# initialize width and height
	la $t1, wid
	la $t2, hgt
		
	# base address of 2d array representing the board
	la $t0, board 
	
	outer_loop: beq $t3, $t2
			
	inner_loop: beq $t4, $t1
	
	exit_loop:
		
	jr $ra

	
	
