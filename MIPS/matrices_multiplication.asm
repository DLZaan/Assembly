#matrices multiplication, can be easily optimised

#s0->number of rows of first matrix in bytes (4*size of ints)
#s1->number of columns of first matrix in bytes
#s2->number of rows of second matrix in bytes
#s3->number of columns of second matrix in bytes
#s4->size of first matrix in bytes
#s5->size of second matrix in bytes
#s6->matrix 1
#s7->matrix 2

#t0->input loops iterator //also buffer in loop3
#t1->loop1 iterator
#t2->loop2 iterator
#t3->loop3 iterator
#t4->=4
#t5->product of multiplication //also buffer in loop3
#t6->first matrix iterator
#t7->second matrix iterator


.text
	li	$t4, 4		#t4=4

	la 	$a0, rows1Matrix
	li 	$v0, 4     # print string
	syscall
	li 	$v0, 5     # read int
	syscall
	mul	$s0, $t4, $v0	#convert to size bytes
	
	la 	$a0, columns1Matrix
	li 	$v0, 4
	syscall
	li 	$v0, 5
	syscall
	mul	$s1, $t4, $v0
	
	la 	$a0, rows2Matrix
	li 	$v0, 4
	syscall
	li 	$v0, 5
	syscall
	mul	$s2, $t4, $v0
	
	la 	$a0, columns2Matrix
	li 	$v0, 4
	syscall
	li 	$v0, 5
	syscall
	mul	$s3, $t4, $v0
	
	#if (s1!=s2||s0<=0||s1<=0||s3<=0) -> wrongData, exit
	bne	$s1, $s2, wrong
	blez	$s0, wrong
	blez	$s1, wrong
	blez	$s3, wrong
	
	# allocate heap memory for first matrix
	mul	$s4, $s0, $s1	#s4=s0*s1
	div	$s4, $s4, $t4
	move	$a0, $s4
	li 	$v0, 9  #allocate memory of size in a0
	syscall	
	move	$s6, $v0
	
	# allocate heap memory for second matrix
	mul	$s5, $s2, $s3	#s5=s2*s3
	div	$s5, $s5, $t4
	move	$a0, $s5
	li 	$v0, 9  #allocate memory of size in a0
	syscall	
	move	$s7, $v0
	
	#get elements of first matrix
	la	$a0, elements1
	li 	$v0, 4     # print string
	syscall
	li 	$t0, 0 #loop iterator=0	
	move 	$t6, $s6 #first matrix iterator=begin	
	jal	loadMatrix1
	
	#get elements of second matrix
	la	$a0, elements2
	li 	$v0, 4     # print string
	syscall
	li 	$t0, 0 #loop iterator=0
	move 	$t7, $s7 #second matrix iterator=begin
	jal	loadMatrix2
	
	#product of matrices
	la	$a0, result
	li 	$v0, 4     # print string
	syscall
	
	jal	outerLoop
	
	li	$v0, 10    # exit
	syscall
	
	
loadMatrix1:
	li 	$v0, 5 #read int
	syscall
	sw 	$v0, ($t6)  # store word; store value to s4
	addi 	$t6, $t6, 4 # first matrix iterator++
	addi 	$t0, $t0, 4 # loop iterator++
	blt 	$t0, $s4, loadMatrix1  # if (t0<t5) go to loadMatrix1
	jr	$ra
	
loadMatrix2:
	li 	$v0, 5 #read int
	syscall
	sw 	$v0, ($t7)  # store word; store value to s5
	addi 	$t7, $t7, 4 # second matrix iterator++
	addi 	$t0, $t0, 4 # loop iterator++
	blt 	$t0, $s5, loadMatrix2  # if (t0<t6) go to loadMatrix2
	jr	$ra

outerLoop:
	addi 	$sp, $sp, -4
	sw 	$ra, ($sp)
	li	$t1, 0	#t1=0 (loop1 iterator = 0)
	loop1:	#for (c = 0; c < s0; c++)
		li	$t2, 0	#t2=0 (loop2 iterator = 0)
		jal	innerLoop
		addi	$t1, $t1, 4 # loop1 iterator++
		la	$a0, endl
		li 	$v0, 4     # print string
		syscall
		blt	$t1, $s0, loop1	#if(t1<s0) go to loop1
	lw 	$ra, ($sp)
	addi 	$sp, $sp, 4
	jr 	$ra
	
innerLoop:
	addi 	$sp, $sp, -4
	sw 	$ra, ($sp)
	loop2: #for (d = 0; d < s3; d++)
		mul	$t6, $t1, $s1
		div	$t6, $t6, $t4
		add	$t6, $s6, $t6 #first matrix iterator
		add	$t7, $s7, $t2 #second matrix iterator
		li	$a0, 0
		li	$t3, 0	#(loop3 iterator = 0)
		jal	loop3
		li	$v0, 1
		syscall
		addi	$t2, $t2, 4 # loop2 iterator++
		la	$a0, tab
		li 	$v0, 4     # print string
		syscall
		blt	$t2, $s3, loop2	#if(t2<s3) go to loop2
	lw 	$ra, ($sp)
	addi 	$sp, $sp, 4
	jr 	$ra
	
loop3:	#for (k = 0; k < s2; k++)
	#sum+=((first[c][k])*(second[k][d])) -> a0+=($t6)*($t7)
	lw	$t0, ($t6)
	lw	$t5, ($t7) 
	mul	$t5, $t0, $t5
	add	$a0, $a0, $t5
	add	$t7, $t7, $s3 #second matrix iterator++
	addi	$t6, $t6, 4 #first matrix iterator++
	addi	$t3, $t3, 4 # loop3 iterator++
	blt	$t3, $s1, loop3 #if(t3<s1) go to loop3
	jr 	$ra
	
wrong:
	la	$a0, wrongData	#print wrong_data
	li	$v0, 4
	syscall
	li	$v0, 10
	syscall

.data
	rows1Matrix: .asciiz "Input number of rows of first matrix: \n"
	columns1Matrix: .asciiz "Input number of columns of first matrix: \n"
	rows2Matrix: .asciiz "Input number of rows of second matrix: \n"
	columns2Matrix: .asciiz "Input number of columns of first matrix: \n"
	wrongData: .asciiz "The matrices can't be multiplied with each other.\n"
	elements1: .asciiz "Input elements of first matrix: \n"
	elements2: .asciiz "Input elements of second matrix: \n"
	result: .asciiz "Product of the matrices: \n"
	tab: .asciiz "   "
	endl: .asciiz "\n"
