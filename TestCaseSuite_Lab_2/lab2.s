# Unix ID:              Aplu
# Lecture Section:      B2
# Instructor:           Karim Ali
# Lab Section:          H10 (Thursday 1700 - 1930)
# Teaching Assistant:   Ahmed Elbashir
#---------------------------------------------------------------
#---------------------------------------------------------------
# The branchdisassemble program operates on register $a0 which stores an address to a branch instruction
# Then, the program stores $a0 address and the contents into independent registers and stores shifted opcode, (later register t, register s, offset, and pc into independent registers)
# This opcode is checked thoroughly for the specified 8 branch instructions. Depending on which branch instruction, the code may do a secondary check to find the opcode
# After finding the opcode, the program prints the regs after masking shifting left to right until the register s is isolated for printing. The same is done for register t, if applicable
# a 0x is printed before executing the printing of pc address. Since pc will be expressed on the console as decimal, the program implements a loop that reads the 4 msb, stores it into another register, shifts left by 4
# and prints the corresponding value in a stored asciiz hexadecimal string/array. this is repeated until the 8 hexadecimal values are outputted.
#
# Note that if an opcode is incorrect (even if it contains 0000 01 at first), the program will not have an output.
#
# Register Usage:
#
#       $t0: Contains the beq mask, is later set to a loop counter
#       $t1: used as the bne mask, and is later used to store the hexdecnum values
#       $t2: Used as a blez mask, and then used to store the 4 msb to be converted to a hex print character
#       $t3: Used as a bgtz mask, is later used as an 0xF0000000 mask to store the 4 msb in another variable
#       $t4: used as a bgez mask
#       $t5: used as a bltz mask
#       $t6: used as a bgezal mask
#       $t7: used as a bltzal mask
#       $t9: used as a first check mask to indicate if a secondary check is needed for t4 - t7
#       $s0: used to store the contents of $a0 to be masked and processed by other registers
#       $s1: Contains the opcode mask for the first check. Does not function as a mask for further checking
#       $s2: used to store the values in place of t registers for the opcodes that require secondary checking
#       $s3: used to contain regt values and only stores if the given instruction requires a regt output
#       $s4: used to store the offset before and after arithmetic manipulation
#       $s5: used to store the pc value that is later to be shifted and converted into hex print
#       $s6: stores the address of the instruction in a static register to later be used in the pc calculation
#       $a0: stores the instruction address as well as direction to the instruction contents
#       $v0: stores the syscall operation to be done. Used mainly for printing of strings and integers
#---------------------------------------------------------------
#CMPUT 229 Student Submission License (Version 1.1)
#
#Copyright 2018 Allen Lu
#
#Unauthorized redistribution is forbidden in all circumstances. Use of this software without explicit authorization from the author or CMPUT 229 Teaching Staff is prohibited.
#
#This software was produced as a solution for an assignment in the course CMPUT 229 (Computer Organization and Architecture I) at the University of Alberta, Canada. This solution is #confidential and remains confidential after it is submitted for grading. The course staff has the right to run plagiarism-detection tools on any code developed under this license, even #beyond the duration of the course.
#
#Copying any part of this solution without including this copyright notice is illegal.
#
#If any portion of this software is included in a solution submitted for grading at an educational institution, the submitter will be subject to the sanctions for plagiarism at that #institution.
#
#This software cannot be publicly posted under any circumstances, whether by the original student or by a third party. If this software is found in any public website or public #repository, the person finding it is kindly requested to immediately report, including the URL or other repository locating information, to the following email address: #cmput229@ualberta.ca.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF #MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, #EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED #AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED #OF THE POSSIBILITY OF SUCH DAMAGE.


.data
    #the opcodes for secondary distinguishing
    BGEZAL: .asciiz "bgezal $"
    BGEZ: .asciiz "bgez $"
    BLTZ: .asciiz "bltz $"
    BLTZAL: .asciiz "bltzal $"

    #the opcodes for regular distinguishing
    BEQ: .asciiz "beq $"
    BNE: .asciiz "bne $"
    BLEZ: .asciiz "blez $"
    BGTZ: .asciiz "bgtz $"

    Dolsign: .asciiz "$"
    space: .asciiz " "
    comma: .asciiz ", "
    hex_notation: .asciiz "0x"
    .align 2
    hexdecnums: .asciiz "0123456789abcdef"
.text


disassembleBranch:

            #Assumes that $a0 instruction command is already initialized
            #li $a0, 0x1109000b #delete after 
            #li masks for instructions that distinguish based on the 6 MSB
            
            li $t0, 0x10000000    # t0 <- 0001 0000 0000 0000 0000 0000 0000 0000 (beq)
            li $t1, 0x14000000    # t1 <- 0001 0100 0000 0000 0000 0000 0000 0000 (bne)
            li $t2, 0x18000000    # t2 <- 0001 1000 0000 0000 0000 0000 0000 0000 (blez) 
            li $t3, 0x1c000000    # t3 <- 0001 1100 0000 0000 0000 0000 0000 0000 (bgtz)

            #li mask that distinguishes if there is more specification needed
            li $t9, 0x04000000    # t9 <- 0000 0100 0000 0000 0000 0000 0000 0000 (first check)

            #li masks to test alongside t9
            li $t4, 0x00010000    # t4 <- 0000 0000 0000 0001 0000 0000 0000 0000 (bgez)
            li $t5, 0x00000000    # t5 <- 0000 0000 0000 0000 0000 0000 0000 0000 (bltz)
            li $t6, 0x00110000    # t6 <- 0000 0000 0001 0001 0000 0000 0000 0000 (bgezal)
            li $t7, 0x00100000    # t7 <- 0000 0000 0001 0000 0000 0000 0000 0000 (bltzal)

            #access the contents of the address stored in a0
            lw $s0, 0($a0)           # s0 <- *a0
            add $s6, $zero, $a0                # s6 <- address + 0

            srl $s1, $s0, 26      # s1 <- 0000 0000 0000 0000 0000 0000 00nn nnnn
            sll $s1, $s1, 26      # s1 <- nnnn nn00 0000 0000 0000 0000 0000 0000

            # the first check
            bne $t9, $s1, firstcheck  # if opcode(a0) != 0x0c000000 go to firstcheck
            
            sll $s2, $s0, 11      # s2 <- xxxx xiii iiii iiii iiii i000 0000 0000 (i is not wanted)
            srl $s2, $s2, 27      # s2 <- 0000 0000 0000 0000 0000 0000 000x xxxx
            sll $s2, $s2, 16      # s2 <- 0000 0000 000x xxxx 0000 0000 0000 0000

            # now we can check the secondary opcode indicator with the secondary li masks
            bne $s2, $t4, notbgez       # if s2 != 0x00010000 go to not blez
            #this is where Blez gets printed
            li $v0, 4
            la $a0, BGEZ
            syscall
            #include a jump, all to the same place
            j continue
    notbgez:
            bne $s2, $t5, notbltz       # if s2 != 0x00000000 go to notbltz
            #this is where bltz gets printed
            li  $v0, 4
            la  $a0, BLTZ
            syscall
            j continue
    notbltz:
            bne $s2, $t6, notbgezal     # if s2 != 0x00110000 go to notbgezal
            #this is where bgezal gets printed
            li  $v0, 4
            la  $a0, BGEZAL
            syscall
            #include a jump, all to the same place
            j continue
    notbgezal:
            bne $s2, $t7, notbltzal     # if $s2 != 0x00100000 go to notbltzal
            #this is where bltzal gets printed
            li  $v0, 4
            la  $a0, BLTZAL
            syscall
            #include a jump, all to the same place
            j continue  
    notbltzal:
            jr $ra                      # All opcodes for 0x0c000000 are checked at this point. so invalid instruction

firstcheck: bne $s1, $t0, notbeq        # if $s1 != 0x10000000 go to secondcheck
            #this is where beq gets printed
            li  $v0, 4
            la  $a0, BEQ
            syscall
            #include a jump, all to the same place
            j continue
    notbeq: bne $s1, $t1, notbne        # if $s1 != 0x14000000 go to notbne
            #this is where bne gets printed
            li  $v0, 4
            la  $a0, BNE
            syscall
            #include a jump, all to the same place
            j continue
    notbne: bne $s1, $t2, notblez       # if s1 != 0x18000000 go to notblez
            #this is where blez gets printed
            li  $v0, 4
            la  $a0, BLEZ
            syscall
            #include a jump, all to the same place
            j continue
   notblez: bne $s1, $t3, notbgtz       # if s1 != 0x1c000000 go to notbgtz
            #this is where bgtz gets printed
            li  $v0, 4
            la  $a0, BGTZ
            syscall
            #include a jump, all to the same place
            j continue
  notbgtz:


            jr $ra                     # all opcodes are checked at this point, then the instruction isn't of the type listed, so the program should finish


  continue: # shift to get regs
            sll $s2, $s0, 6 #regs <- *$a0 << 11
            srl $s2, $s2, 27 #regs <- *$a0 >> 27
            #print regs
            li $v0, 1
            addi $a0, $s2, 0
            syscall

            beq $t9, $s1, noregt        # if (opcode)*a0 == 0x0c000000 then skip regt printing
            beq $t2, $s1, noregt        # if (opcode)*a0 == 0x18000000 then skip regt printing
            beq $t3, $s1, noregt        # if (opcode)*a0 == 0x1c000000 then skip regt printing
            #shift to get regt

            sll $s3, $s0, 11 #regt <- *$a0 << 6
            srl $s3, $s3, 27 #regt <- regt >> 27
            #print regt
            li $v0, 4
            la $a0, comma               #print comma and space
            syscall

            li $v0, 4
            la $a0, Dolsign             # print $
            syscall

            li $v0, 1
            addi $a0, $s3, 0            #print register t
            syscall

    
    noregt: # calculate offset
            sll $s4, $s0, 16    # offset <- *$a0 << 16
            sra $s4, $s4, 16    # offset <- offset >> 16 (sign extended)
            sll $s4, $s4, 2     # offset <- offset << 2
            
            #calculate PC, print
            addi $s5, $s6, 4    # pc <- address + 4
            add $s5, $s5, $s4  # pc + offset <- (address + 4) + offset

            li $v0, 4
            la $a0, comma               #prints comma and space (string)
            syscall

            li $v0, 4
            la $a0, hex_notation        #prints 0x (string)
            syscall

            li $t0, 8                   # counter for loop
            la $t1, hexdecnums          # t1 <- 0123456789abcdef
            #loop that needs to be fixed
            lui $t3, 0xF000             # t3 <- 1111 0000 0000 0000 0000 0000 0000 0000
      loop: 
            and $t2, $s5, $t3           # t2 <- nnnn 0000 0000 0000 0000 0000 0000 0000
            srl $t2, $t2, 28            # t2 <- 0000 0000 0000 0000 0000 0000 0000 nnnn
            sll $s5, $s5, 4             # shift the pc value left by 4 to change the masking values for the next iteration

            add $t2, $t1, $t2           # adds the updated t2 and uses to index the hexnum
            lb $t2, 0($t2)              # loads the individual hex character onto t2

            li $v0, 11
            addi $a0, $t2, 0            #print the character
            syscall

            addi $t0, $t0, -1           #decrement
            bne $t0, $zero, loop        # if the counter != 0, then continue looping



            jr $ra