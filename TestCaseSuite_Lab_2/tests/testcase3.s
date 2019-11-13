n:
	bgtz $a0 target1
	sll $a0 $a0 15
target7:
	jal main
	bgezal $fp target2
target6:
	blez $a0 target3
	addi $a0 $s1 0xFF
target5:
	bltzal $s2 main
	jr $ra
target4:
	beq $t0 $t0 target4
	add $t0 $t0 $a0
target3:
	bltz $v1 target5
	mflo $t5
target2:
	bne $t3 $s1 target6
	add $a0 $t0 $t0
target1:
	bgez $t0 target2
	srl $t1 $t1 12 
