# Kevin Duong
# keduong 
# Sec 01J - Chandrahas
# Part 1 of Lab 5, sets I/O cover so that btn 1-4 light up ld 5-8
# and sw 1-4 light up ld 1-4

#include <WProgram.h>

.global main
    
.ent main

main:
    
    # registers
    ANDI $t0, $t0, 0	   # Enable LED by clearing TRISE, PORTE, then set PORTE		
    ANDI $t1, $t1, 0	   # used to hold word from PORT D 
    ANDI $t2, $t2, 0	   # used to hold word from PORT F 
    ANDI $t3, $t3, 0	   # holds address of PORT E
    ANDI $t4, $t4, 0	   # temp
    ANDI $t5, $t5, 0	   # temp
    ANDI $t6, $t6, 0	   # temp
    ANDI $t7, $t7, 0	   # temp
    ANDI $t8, $t8, 0	   # temp
    ANDI $t9, $t9, 0	   # temp
    
    # set port e to input mode and clear led register
    ADDI $t0, $t0, 255	
    SW   $t0, TRISECLR	
    SW   $t0, PORTECLR
    SW   $t0, PORTESET	
    
    whileloop:		      # default main body loop
    
    LW   $t1, PORTD	   # hold port d word (bits 5,6,7)
    LW   $t2, PORTF     # hold port f word (bit 1)
    LA   $t3, PORTE	   # hold port e address (lower 8 bits)

    # LED 6-8 : PORT D - Buttons 2-4
    ANDI $t4, $t1, 224	# imm and port d with 224 (mask bit 5,6,7)
    ADD  $t5, $t5, $t4  # copy t4 into t5
    SW   $t5, ($t3)     # store t5 result into PORTE

    # LED 5 : PORT F - Button 1
    SLL  $t6, $t2, 3    # sll 3 to put portf content into 4th bit
    ANDI $t9, $t6, 16   # imm and t6 with 16, copy into t9 (alt use OR porte) 
    SW   $t9, ($t3)     # store t9 into port e (led)

    # LED 1-4 : PORT D - Switches 1-4
    SRL  $t4, $t1, 8    # srl 8 bits to line LED bit(0,1,2,3) with portD (8,9,10,11)
    ANDI $t5, $t4, 15   # imm and t4 with 15 copy into t5 (alt use or PORTe)
    SW   $t5, ($t3)     # copy result into port e (led)
    
    J    whileloop      # loop forever
    nop                 # just in case
.end main
