#-------------------------------
# Branch De-Offsetting - Marking Common File
# Author: Taylor Lloyd
# Date: July 18, 2012
#
#-------------------------------

.data
	.align 2
binary:
	.space 2052
noFileStr:
	.asciiz "Couldn't open specified file.\n"
nlStrCom:
	.asciiz "\n"
pointerStorage:
	.word 0x00
.text
main:
	lw	$a0 4($a1)	# Put the filename pointer into $a0
	li	$a1 0		# Read Only
	li	$a2 0		# No Mode Specified
	li	$v0 13		# Open File
	syscall
	bltz	$v0 main_err	# Negative means open failed

	move	$a0 $v0		#point at open file
	la	$a1 binary	# write into my binary space
	li	$a2 2048	# read a file of at max 2kb
	li	$v0 14		# Read File Syscall
	syscall
	la	$t0 binary
	add	$t0 $t0 $v0	#point to end of binary space

	li	$t1 0xFFFFFFFF	#Place ending sentinel
	sw	$t1 0($t0)

	la	$a0 binary
	main_loop:
		#Check for ending sentinel
		lw	$t0 0($a0)
		li	$t1 -1
		beq	$t0 $t1 main_done

		#run student output code
		sw	$a0 pointerStorage
		jal	disassembleBranch

		#print newline
		la	$a0 nlStrCom
		li	$v0 4
		syscall

		#reload and increment $a0
		lw	$a0 pointerStorage
		addi	$a0 $a0 4
		j	main_loop
	
	main_err:
		la	$a0 noFileStr
		li	$v0 4
		syscall
	main_done:
		li	$v0 10
		syscall
