
# Kevin Duong
# keduong 
# Sec 01J - Chandrahas
# Lab6- Decimal Converter
# Reads/ copy value in inDecimalString, converts to Binary
# write into new location and print
#include <WProgram.h>

#include <xc.h>
/* define all global symbols here */
.global main
.global read
.text
.set noreorder

.ent main
main:
    /* this code blocks sets up the ability to print, do not alter it */
   ADDIU $v0,$zero,1
    LA $t0,__XC_UART
    SW $v0,0($t0)
    LA $t0,U1MODE
    LW $v0,0($t0)
    ORI $v0,$v0,0b1000
    SW $v0,0($t0)
    LA $t0,U1BRG
    ADDIU $v0,$zero,12
    SW $v0,0($t0)

    
    
    LA $a0,WelcomeMessage
    JAL puts
    NOP
    
    
    /* your code goes underneath this */
    la $a0, inNumericString   ; load address of input
    add $t0, $0, $a0          ; copy in temp
    la $a0, outBinaryString   ; load address of output
    li $t3, 1                 ; add 1 to temp 
    sll $t3, $t3, 31          ; shift t3 by 31 left
    li $t4, 32                ; counter
    add $t2, $0, $0           ; 0 out t2
    loop:
    and $t2, $t0, $t3         ; bitwise and t3 and user input
    beq $t2, 0, out           ; if 0, no match, print 0
    add $t2, $0, $0           ; zero out t2
    addi $t2, $t2, 1          ; place 1 (for print)
    j out
    nop
    out:
    move $a0, $t2             ; whatever in t2 goes into output
    srl $t3, $t3,1            ; shift right by 1
    addi $t4,$t4,-1           ; decrement
    bne $t4,0, endProgram     ; after 32 iterations exit
    j loop
    nop
     
    
    /* your code goes above this */
    
    LA $a0,DecimalMessage
    JAL puts
    NOP
    LA $a0,inNumericString
    JAL puts
    NOP
    
    LA $a0,BinaryMessage
    JAL puts
    NOP
    LA $a0,outBinaryString
    JAL puts
    NOP
    

endProgram:
    J endProgram
    NOP
.end main




.data
WelcomeMessage: .asciiz "Welcome to the converter\n"
DecimalMessage: .asciiz "The decimal number is: "
BinaryMessage: .asciiz "The decimal number is: "
    
inNumericString: .asciiz "255" 
outBinaryString: .asciiz ""

