#this example should teach you why to use inline functions

#s0->size of array in bytes (4*size of ints)
#s1->values of array

.text
  .globl main
  main:
	jal inputArray
	move 	 $a0, $v0 #argument 0=size in ints
	move 	 $a1, $v1 #argument 1=array 
	jal bubbleSort
	move 	 $a0, $v0 #argument 0=size in ints
	move 	 $a1, $v1 #argument 1=array
	jal printArray
	
	li $v0, 10    # exit
	syscall
	
	bubbleSort:
	#t0->outer loop iterator
	#t1->outer loop stopper
	#t2->inner loop adress iterator
	#t3->inner loop stopper, end of array
	
		move 	 $s0, $a0 #argument 0=size in ints
		move 	 $s1, $a1 #argument 1=array
		 
		li 	$t0, 0
		move 	$t1, $s0
		subi	$t1, $t1, 4
		
		for3: beq $t0, $t1, exit3 #while (t0!=t1)
			move $t2, $s1
			add $t3, $t2, $t1 #pointer to end of array
			sub $t3, $t3 ,$t0 #pointer to end of unsorted part of array
			for4: beq $t2, $t3, exit4 #while (t2!=t3)
				
				lw $a0, ($t2) 			#a0->first number to compare
				addi $t2, $t2, 4 		#go to next element
				lw $a1, ($t2) 			#a1->second number to compare
				subi $t2, $t2, 4		#get back with iterator
				
				bgt $a1, $a0, exit6		#if (a1>a0) go to exit6 (do nothing, right order)
					addi $sp, $sp, -4
					sw $ra, ($sp)
					jal swap
					lw $ra, ($sp)
					addi $sp, $sp, 4
					sw $v0, ($t2) 			#a0->first number to compare
					addi $t2, $t2, 4 		#go to next element
					sw $v1, ($t2) 			#a1->second number to compare
					subi $t2, $t2, 4
					
				exit6:
				addi $t2, $t2, 4 
				j for4 					
			exit4:					#end of inner loop
			addi $t0, $t0, 4		
			j for3
		exit3:						#end of outer loop
		move 	 $v0, $s0 #return value 0 = size in ints
		move 	 $v1, $s1 #return value 1 = array
		jr $ra 
	
	printArray:
		move 	 $s0, $a0 #argument 0=size in ints
		move 	 $s1, $a1 #argument 1=array
		 
		li 	$t0, 0 #loop iterator=0
		move 	$t1, $s1 #array iterator
		
		for2: beq $t0, $s0, exit2 #while(t0!=s0)
			li $v0, 1 
			lw $t2, ($t1)
	 		move $a0, $t2 
	 		syscall
	 		li 	$v0, 4
			la 	$a0, coma
			syscall
	 		addi $t0, $t0, 4 
	 		addi $t1, $t1, 4
	 		j for2
		
		exit2:
		jr $ra 	
	
	
	inputArray:
		la 	$a0, length
		li 	$v0, 4     # print string
		syscall
		li 	$v0, 5     # read int
		syscall
		move 	$s2, $v0	#s2=size_in_ints
		li	$s0, 4		#s0=4
		mul	$s0, $s0, $s2	#s0=4*size_in_ints = size_in_bytes
		
		la 	$a0, ask
		li 	$v0, 4     # print string
		syscall
		
		# allocate heap memory
		move 	$a0, $s0#a0=s0=size_in_bytes
		li 	$v0, 9  #allocate memory of size a0
		syscall		#allocate memory for array
		move 	 $s1, $v0 #give s2 adress of allocated memory
		
		li 	$t0, 0 #loop iterator=0
		move 	$t1, $s1 #array iterator
		
		for1: beq $t0, $s0, exit1	 	#while(t0!=s0)
			li $v0, 5 #read value			 	
			syscall
	 		sw $v0, ($t1) 	 	
	 		addi $t1, $t1, 4 # array iterator++
	 		addi $t0, $t0, 4 # loop iterator++
	 		j for1
		exit1:
		move 	 $v0, $s0 #return value 0 = size in ints
		move 	 $v1, $s1 #return value 1 = array
		
		jr $ra
	swap:
		move 	 $v1, $a0 #argument 0 goes to output 1
		move 	 $v0, $a1 #argument 1 goes to output 0
		
		jr $ra 
.data
	length: .asciiz "Input the size of the array: "
	ask: .asciiz "Input the array data:\n"
  	endl: .asciiz "\n"
  	coma: .asciiz ","
  	
