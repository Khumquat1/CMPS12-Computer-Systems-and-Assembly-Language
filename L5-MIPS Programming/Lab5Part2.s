# Kevin Duong
# keduong 
# Sec 01J - Chandrahas
# Part 2 of Lab 5, sets I/O cover so that LEDs will walk with 
# switches changing delay

#include <WProgram.h>

.global main
    
.ent main

main:
    
    # registers
    ANDI $t0, $t0, 0	   # prep LED reg 		
    ANDI $t1, $t1, 0	   # PORTE
    ANDI $t2, $t2, 0	   # PORTD
    ANDI $t3, $t3, 0	   # temp
    ANDI $t4, $t4, 0	   # temp
    ANDI $t5, $t5, 0	   # temp
    ANDI $t6, $t6, 0	   # temp
    ANDI $t7, $t7, 0	   # switches (delay mult)
    ANDI $t8, $t8, 0	   # temp
    ANDI $t9, $t9, 0	   # delay
    
    ADDI $t9, $t9, 2151    # base delay
    move $a0, $t9
    
    # prep led register
    LW  $t0, TRISE
    LUI $t1, 0
    SW  $t1, ($t0)
    LA  $t1, PORTE
    LUI $t2, 0
    SW  $t2, ($t1)
    
    # store switch values into multdelay
    LW  $t2, PORTD
    LW  $t3, ($t2)
    SRL $t3, 8
    ADDI$t3, $t3, 1
    SW  $t3, ($t7)
    
    # turn on LED1
    LW $t4, ($t1)
    ADDI $t4, $t4, 1
    SW $t4, ($t1)
    
    # delay
    mydelay:
    MULT $a0, $t7
    MFLO $t8
    ADDI $t8, $t8, -1
    BEQ  $t0, 0, go
    j mydelay
    nop
    
    # turn off current LED, turn on next led
    go:
    LW $t6, ($t1)
    ADD $t6, $t6, $t6
    LW $t4, ($t1)
    ADDI $t4, $t4, -1
    SW $t4, ($t1)
    SLL $t1, $t1, 1
    SW $t6, ($t1)
    j mydelay
    
   nop
    .end main
