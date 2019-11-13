.text
main:
	bgtz $a0 target1
target7:
	bgezal $fp target2
target6:
	blez $a0 target3
target5:
	bltzal $s2 main
target4:
	beq $t0 $t0 target4
target3:
	bltz $v1 target5
target2:
	bne $t3 $s1 target6
target1:
	bgez $t0 target2 
