#simple dynamic allocation of heap

#t0->loops iterator
#s0->size of vectors in ints
#s1->size of vectors in bytes (4*size of ints)
#s2->values of vector 1
#s3->order of vector 1
#s4->values of vector 2
#s5->order of vector 2
#s6->result

.text
	la 	$a0, length
	li 	$v0, 4     # print string
	syscall
	li 	$v0, 5     # read int
	syscall
	move 	$s0, $v0	#s0=size_in_ints
	li	$s1, 4		#s1=4
	mul	$s1, $s1, $s0	#s1=4*size_in_ints = size_in_bytes
	
	# allocate heap memory
	move 	$a0, $s1 #a0=s1=size_in_bytes
	li 	$v0, 9  #allocate memory of size in a0
	syscall			#allocate memory for vector1values
	move 	 $s2, $v0 #give s2 adress of allocated memory
	li 	$v0, 9
	syscall			#allocate memory for orderVector1
	move 	 $s3, $v0
	li 	$v0, 9
	syscall		  	#allocate memory for vector2values
	move 	 $s4, $v0
	li 	$v0, 9
	syscall			#allocate memory for ord2
	move 	 $s5, $v0
	
	
	li 	$t0, 0 #clear iterator
	move 	$t2, $s2
	move 	$t3, $s3
	la 	$a0, inVector1
	li 	$v0, 4 #print string
	syscall
	
loadVector1: #reading values to vector1 in loop
	li 	$v0, 5 #read int
	syscall
	addi 	$t0, $t0, 4 #increment iterator
	beq 	$v0, 0, vector1_Zero  # branch if equal; if (v0==0) go to vector1_zero

	sw 	$v0, ($t2)  # store word; store value to s2
	addi 	$t2, $t2, 4 #increment iterator
	
	addi 	$v0, $zero, 1 # v0=1
	sw 	$v0, ($t3) #add 1 to s3
	j 	vector1_nonZero
	
vector1_Zero:
	sw 	$zero, ($t3) #add 0 to s3
	
vector1_nonZero:
	addi 	$t3, $t3, 4 #increment iterator
	blt 	$t0, $s1, loadVector1  # branch if less than; if (t0<s1) go to loadVector1:
	
	li 	$t0, 0 #clear iterator
	move 	$t4, $s4 
	move 	$t5, $s5
	
	la 	$a0, inVector2
	li 	$v0, 4 #print string
	syscall 
	
loadVector2: #reading values to vector1 in loop
	li 	$v0, 5
	syscall
	addi 	$t0, $t0, 4
	beq 	$v0, 0, vector2_nonZero
	
	sw 	$v0, ($t4)
	addi 	$t4, $t4, 4
	
	addi 	$v0, $zero, 1
	sw 	$v0, ($t5)
	j 	vector2_nonZero
	
vector2_Zero:
	sw 	$zero, ($t5)
	
vector2_nonZero:	
	addi 	$t5, $t5, 4
	blt 	$t0, $s1, loadVector2

	li 	$t0, 0 #clear iterator
	move 	$t2, $s2
	move 	$t3, $s3
	move 	$t4, $s4
	move 	$t5, $s5
	
	
dotPr: #calculating dot product
	li 	$t6, 0
	li 	$t7, 0
	
	addi 	$t0, $t0, 4 #increment iterator
	
	lw 	$t1, ($t3) # t1=t3
	beq 	$t1, 0, vec1_wasZero #if (t1==0) go to vec1_wasZero
	lw	$t6, ($t2) #load value
	addi 	$t2, $t2, 4 #++vector1 values iterator
	
vec1_wasZero:
	lw 	$t1, ($t5)
	beq 	$t1, 0, vec2_wasZero #if (t1==0) go to vec2_wasZero
	lw	$t7, ($t4) #load value
	addi 	$t4, $t4, 4 #++vector2 values iterator
	
vec2_wasZero:
	mult $t6, $t7 #result of multiplication goes to LO
	mflo $t6  # move from LO register
	
	add $s6, $s6, $t6 #s6+=t6
	addi 	$t3, $t3, 4 #++vector1 order iterator
	addi 	$t5, $t5, 4 #++vector2 order iterator
	
	blt	$t0, $s1, dotPr # if(t1<s1) go to dotPr
	
	li $v0, 4
	la $a0, result
	syscall
	
	li $v0, 1
	move $a0, $s6
	syscall
	
	li $v0, 10    # exit
	syscall
	
	
.data
	length: .asciiz "Input the size of the vector: "
	inVector1: .asciiz "Input the values of the first vector: \n"
	inVector2: .asciiz "Input the values of the second vector: \n"
	result: .asciiz "The scalar product is: "
