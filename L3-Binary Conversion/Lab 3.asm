; Kevin Duong
; keduong
; Fall 2016 CMPE 12
; Section 1J Tu,Thur 7:00 - 9:00 PM
; TA: Chandrahas
; Due: Oct. 23, 2016
; Decimal to Binary LC-3 Converter

.ORIG x3000

GREETING
   LEA R0, GREET 	; Load WELCOME pointer
   TRAP x22 	        ; PUTS, prints R0

MAIN_LOOP 
   LEA R0, INPUT 	; Load INPUT pointer
   TRAP x22 		; PUTS, prints R0

REGISTERS		; Basic desc. of each register
   AND R0, R0, 0 	; User input
   AND R1, R1, 0 	; Negative Condition Code
   AND R2, R2, 0 	; Misc. 
   AND R3, R3, 0 	; Loop Checker for Mask_Loop
   AND R4, R4, 0 	; Misc.
   AND R5, R5, 0 	; Misc.
   AND R6, R6, 0 	; Storing user input in R6
   AND R7, R7, 0 	; Misc.

READ 
   TRAP x20 		; GETC, read the character
   TRAP x21 		; OUT, output the char. (echo)
   AND R2, R2, 0 	; Resetting misc. registers
   AND R4, R4, 0 	; Resetting misc. registers
   AND R5, R5, 0 	; Resetting misc. registers
   AND R7, R7, 0 	; Resetting misc. registers

INPUT_CHECK		; Check input for "-"
   ADD R5, R5, R0 	; Temp. storing user input in R5
   ADD R5, R5, -16 	; Subtract 16 from R5
   ADD R5, R5, -16 	; Subtract 16 from R5 (-32)
   ADD R5, R5, -13 	; Subtract 16 from R5 (-45)
   BRz NEGATIVE_INPUT 	; If R5 = 0, input is determined to be "-" (45)
   ADD R2, R2, R0 	; Temp storing user input in R2
   ADD R2, R2, -10 	; Subtract 10 from R5
   BRz GOOD_INPUT  	; If R2 = 0, input determined to be "LF"(Line Feed/ New line) (10)

EXIT_TEST 		; Check input for "X"
   AND R2, R2, 0 	; Resetting misc. register
   ADD R2, R2, R0 	; Temp. storing user input in R2
   ADD R2, R2, -16 	; Subtract 16 from R2 
   ADD R2, R2, -16 	; Subtract 16 from R2 (-32)
   ADD R2, R2, -16 	; Subtract 16 from R2 (-48)
   ADD R2, R2, -16 	; Subtract 16 from R2 (-64)
   ADD R2, R2, -16 	; Subtract 16 from R2 (-80)
   ADD R2, R2, -8 	; Subtract 8 from R2  (-88)
   BRz END		; If R2 = 0, input determined to be "X" (88)

DIGIT 
   ADD R7, R7, R0 	; Temp. storing user input in R7 (digit)
   ADD R7, R7, -16 	; Subtract 16 from R7
   ADD R7, R7, -16 	; Subtract 16 from R7 (-32)
   ADD R7, R7, -16 	; Subtract 16 from R7 (-48)
   AND R4, R4, 0 	; Resetting misc. register
   AND R2, R2, 0 	; Resetting misc. register
   ADD R2, R2, R6 	; Temp. storing R6 into R2 to prepare for Multiplication
   ADD R4, R4, 9 	; Using R4 as our counter for multiplication (10 iterations) 
   BRnzp MULTIPLICATION ; Start multiplying

MULTIPLICATION 
   ADD R6, R6, R2 	; Adding value to itself, through loop this is Mult.
   ADD R4, R4, -1 	; decrement our counter 
   BRp MULTIPLICATION 	; continue until counter < 0
   ADD R6, R6, R7 	; Add R6(int) with R7 (User In - 48)
   BRnzp READ 		; Return to reading inputs
   
NEGATIVE_INPUT 		; If "-" was detected in input
   ADD R1, R1, 1 	; Setup R1 Condition Code
   BRnzp READ 		; Return to reading inputs

COMPLEMENT 		; Converting to 2sc
   NOT R6, R6 		; Inverting the int
   ADD R6, R6, 1        ; Add one to the inverted int 
   BRnzp MASK_LOOP 	; Start checking value with Mask pointers

GOOD_INPUT 
   LEA R0, VALID 	; Load VALID pointer
   TRAP x22 		; PUTS, print R0
   ADD R1, R1, 0 	; See if R1 condition code was met
   BRp COMPLEMENT 	; If R1 is (1), value is negative and we find the 2sc

MASK_LOOP 
   LEA R4, MASK 	; Load the first memory location in binary mask
   ADD R4, R4, R2 	; Use R2 as our array index and ad it to first location
   LDR R4, R4, 0 	; Load next binary mask to R4
   AND R5, R5, 0 	; Resetting temp. registers
   AND R0, R0, 0 	; Resetting temp. registers
   AND R5, R4, R6 	; AND user input with binary mask
   BRz PRINT_ZERO 	; IF resulting AND is 0 (no match) print 0
   BRnp PRINT_ONE 	; else print 1

PRINT_ZERO 
   LD R0, ASCII_ZERO	; Load String 1 into R0
   TRAP x21 		; PUTS, Print R0
   ADD R2, R2, 1 	; Increment the counter 
   ADD R3, R2, -16 	; Checking if Counter-16 <0
   BRn MASK_LOOP 	; If condition met, we've iterated enough and can stop
   LD R0, ENTER         ; Load R0 with New Line 
   TRAP x21 		; Print the New Line 
   BRzp MAIN_LOOP 	; Return to beginning of the code (Full Loop)

PRINT_ONE 
   LD R0, ASCII_ONE	; Load String 1 into R0
   TRAP x21 		; PUTS, Print R0
   ADD R2, R2, 1 	; Increment the counter 
   ADD R3, R2, -16 	; Checking if Counter-16 <0
   BRn MASK_LOOP 	; If condition met, we've iterated enough and can stop
   LD R0, ENTER         ; Load R0 with New Line 
   TRAP x21 		; Print the New Line 
   BRzp MAIN_LOOP 	; Return to beginning of the code (Full Loop)

END
   LEA R0, EXIT 	; Load EXIT pointer in R0
   TRAP x22 		; PUTS, print R0
   TRAP x25 		; HALT, stop the program

; Stored Values
ENTER       .FILL  x000A; Ascii Code New Line/ Line Feed
ASCII_ZERO  .FILL  x0030; Ascii Code 0
ASCII_ONE   .FILL  x0031; Ascii Code 1
ASCII_MINUS .FILL  x002D; Ascii Code -
ASCII_X     .FILL  x0058; Ascii Code X
GREET       .STRINGZ "Hey there!\nThis is a decimal to binary conversion program.\n "
INPUT       .STRINGZ "Please enter a decimal number, or X to quit: "
VALID       .STRINGZ "Here's that number in 16-bit binary: "
EXIT 	    .STRINGZ "\nThis was created for UCSC's Fall 2016 CMPE12 class. Thanks for trying it!\n"
	
; Binary Mask
MASK    .FILL   b1000000000000000
        .FILL   b0100000000000000
        .FILL   b0010000000000000
        .FILL   b0001000000000000
        .FILL   b0000100000000000
        .FILL   b0000010000000000
        .FILL   b0000001000000000
        .FILL   b0000000100000000
        .FILL   b0000000010000000
        .FILL   b0000000001000000
        .FILL   b0000000000100000
        .FILL   b0000000000010000
        .FILL   b0000000000001000
        .FILL   b0000000000000100
        .FILL   b0000000000000010
        .FILL   b0000000000000001

.END
