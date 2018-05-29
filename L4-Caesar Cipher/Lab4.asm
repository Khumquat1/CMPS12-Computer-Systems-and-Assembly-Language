.ORIG x3000
 
REGISTERS             ; Register initialization and function
   AND R0, R0, 0      ; User input character register
   AND R1, R1, 0      ; Temp register 
   AND R2, R2, 0      ; Temp register
   AND R3, R3, 0      ; Temp register
   AND R4, R4, 0      ; Temp register
   AND R5, R5, 0      ; Temp register
   AND R6, R6, 0      ; Temp register
   AND R7, R7, 0      ; Temp register
   
GREET
   LEA R0, GREETING   ; Load GREETING pointer into R0
   PUTS               ; Print GREETING to screen

MAIN 
   LEA R0, PROMPTCHAR ; Load PROMPTCHAR pointer into R0
   PUTS               ; Print PROMPT to screen
   
INPUT                 ; Get and analyze input
   GETC               ; Store user input into R0
   OUT                ; Echo input 
   AND R2, R2, 0      ; Reset misc. R2
   ADD R2, R2, R0     ; Copy user input into R2
   ADD R2, R2, -16    ; R2 -= 16, -16
   ADD R2, R2, -16    ; R2 -= 16, -32
   ADD R2, R2, -16    ; R2 -= 16, -48
   ADD R2, R2, -16    ; R2 -= 16, -64
   ADD R2, R2, -4     ; R2 -=  4, -68 (ASCII D)
   BRz SETDECRYPT     ; R2 =   0? input = D
   ADD R2, R2, -1     ; R2 -=  1, -69 (ASCII E)
   BRz SETENCRYPT     ; R2  =  0? input = E
   ADD R2, R2, -16    ; R2 -= 16, -85
   ADD R2, R2, -3     ; R2 -=  3, -88 (ASCII X)
   BRz DONE           ; R2  =  0? input = X 
   BRnzp INPUT        ; Loop if bad input

SETDECRYPT
   AND R1, R1, 0      ; Reset R1 
   ADD R1, R1, 1      ; Set R1 to 1 (DECRYPT)
   ST  R1, DEorEN     ; Store R1 to DEorEN flag
   LEA R0, CIPHERSTR  ; Load CIPHERSTR to R0
   PUTS               ; Print R0 to screen
   BRnzp GETCIPHER    ; Go to GETCIPHER

SETENCRYPT 
   AND R1, R1, 0      ; Reset R1 
   ADD R1, R1, 0      ; Set R1 to 0 (ENCRYPT)
   ST  R1, DEorEN     ; Store R1 to DEorEN flag
   LEA R0, CIPHERSTR  ; Load CIPHERSTR to R0
   PUTS               ; Print R0 to screen
   BRnzp GETCIPHER    ; Go to GETCIPHER
   
GETCIPHER  
   GETC               ; Store input into R0
   OUT                ; Echo
   AND R2, R2, 0      ; Reset temp
   ADD R2, R2, R0     ; COPY CHAR IN R6
   ADD R2, R2, -10    ; R2 -= 10
   BRz PROMPT         ; R2  =  0? LF (new line) 

MULTIDIGIT            ; Taking into account multidigit cipher
   AND R2, R2, 0      ; Reset temp
   AND R3, R3, 0      ; Reset temp
   AND R4, R4, 0      ; Reset temp
   AND R6, R6, 0      ; Reset temp
   ADD R6, R6, R0     ; Copy input into R6
   ADD R6, R6, -16    ; R6 -= 16, -16
   ADD R6, R6, -16    ; R6 -= 16, -32
   ADD R6, R6, -16    ; R6 -= 16, -48 (Subtract ASCII value)
   LD R2, CIPHER      ; R2 = CIPHER
   ADD R3, R3, R2     ; Place R2 into R3, prep for multiplcation
   ADD R4, R4, 9      ; Set R4 as counter, initialize to 9 (10 iterations)

MULTIPLY              ; Multiply by 10
   ADD R2, R2, R3     ; Adding value to itself, iterate for multiplication
   ADD R4, R4, -1     ; Decrement counter
   BRp MULTIPLY       ; Continue until counter <= 0
   ADD R2, R2, R6     ; Subtract 48 from CipherSum to get int
   ST  R2, CIPHER     ; Place Cipher into R2
   BRnzp GETCIPHER    ; Keep getting inputs (i.e more digits)

PROMPT
   ADD R5, R5, -1      ; Subtract 1 from R5 because we start from 0.
   ST  R5, STRLEN      ; Using R5 as StringLength
   LEA R0, PROMPTSTR   ; LOAD ADDRESS OF POINTER OF PROMPTSTR
   PUTS                ; PRINT STRING IN R0
 
GETSTRING 
   GETC                ; Store input into R0
   OUT                 ; Echo
   AND R5, R5, 0       ; Reset R5 for String Length
   LD  R5, STRLEN      ; Load StringLength
   ADD R5, R5, 1       ; Increment R5 by 1
   ST  R5, STRLEN      ; Save into Stringlength
   AND R7, R7, 0       ; Reset misc R7
   ADD R7, R7, R0      ; Copy input into R7
   ADD R7, R7, -10     ; R7 -= 10 
   BRz STRINGEND       ; R7 == 0, input is LF/ newline

STORE 
   ST R5, Ci           ; Columns represented with R5
   AND R4, R4, 0       ; Reset R4 temp
   ST R4, Ri           ; Rows represented with R4
   ST R0, PRECHAR      ; Modified Char (en/decryped) in R0
   JSR STORESR         ; Jump to Store Subroutine
   LD R2, DEorEN       ; Load DEorEN (en/decrypt flag) into R2
   BRz ENCRYPTION      ; if DEorEN == 0, go to EncryptSub start
   JSR DECRYPTSR       ; Else go to DecryptSub
   BRnzp GETSTRING     ; Go back to getting rest of String

ENCRYPTION
   JSR ENCRYPTSR       ; Go to EncryptSub
   BRnzp GETSTRING     ; Go back to getting rest of String
 
STRINGEND 
   LEA R0, RESULTSTR   ; Load Result string pointer
   PUTS                ; Print to screen
   JSR PRINTSR         ; Go to printsub (i.e printing the 2D_ARRAY)

RESET 
   JSR RESETARRAYSR    ; Reset 2D_ARRAY for next Loop
   AND R5, R5, 0       ; Clear R5
   ST R5, CIPHER       ; Reset Cipher for next Loop
   BRnzp MAIN          ; Go back to beginning (i.e next full program run)

DONE 
   LEA R0, END         ; Load END pointer into R0
   PUTS                ; Print to screen

HALT                   
;Stored values
GREETING   .STRINGZ "Hi! This is a Caesar Cipher program for CE12\n"
PROMPTCHAR .STRINGZ "Press:(E)ncrypt, (D)ecrypt, or e(X)it. "
CIPHERSTR  .STRINGZ "\nDesired cipher(1-25): "
PROMPTSTR  .STRINGZ "Input a String(<200)\n"
END        .STRINGZ "\nBye!\n"
RESULTSTR  .STRINGZ "Resulting strings:"
ENCRYPTSTR .STRINGZ "\n<Encrypted> "
DECRYPTSTR .STRINGZ "\n<Decrypted> "
DEorEN       .BLKW 1
CIPHER       .BLKW 1
STRLEN       .BLKW 1
Ri           .BLKW 1
Ci           .BLKW 1
POSTCHAR     .BLKW 1
PRECHAR      .BLKW 1
HALF_ARRAY   .FILL 199
ASCII_A      .FILL 65
ASCII_Z      .FILL 90
ASCII_a      .FILL 97
ASCII_z      .FILL 122
ALPHABET     .FILL 26



; STORESR
; pre: takes in coordinates (Ri,Ci) and byte of data
; post: stores coordinates and data into 2D ARRAY
STORESR  
   AND R5, R5, 0     ; Reset temp R5
   AND R3, R3, 0     ; Reset temp R3
   AND R2, R2, 0     ; Reset temp R2
   LD  R5, Ci        ; R5 = Ci (column)
   LD  R0, Ri        ; R0 = Ri (row)
   BRp SNEXTHALF
   BRnz SCLEAR
SNEXTHALF 
   LD  R2, HALF_ARRAY; Place 199 into R2
   ADD R5, R5, R2    ; Add 199 to R5 (Ci)
SCLEAR
   LEA R3, ARRAY     ; Load ARRAY_2D pointer address 
   ADD R3, R3, R5    ; Add counter to base of ARRAY_2D
   LD  R0, PRECHAR   ; Load unmodified character into R0
   STR R0, R3, 0     ; Store unmodified character into R3
   RET               ; Go back to main code (return) 

   
; LOADSR
; pre: takes in coordinates (Ri,Ci) 
; post: Loads a byte of data from ARRAY
LOADSR
   AND R5, R5, 0     ; Reset temp R5
   AND R3, R3, 0     ; Reset temp R3
   AND R2, R2, 0     ; Reset temp R2
   LD  R5, Ci        ; R5 = Ci (column)
   LD  R0, Ri        ; R0 = Ri (row)
   BRp LNEXTHALF
   BRnz LCLEAR
LNEXTHALF 
   LD  R2, HALF_ARRAY; Place 199 into R2
   ADD R5, R5, R2    ; Add 199 to R5 (Ci)
LCLEAR
   LEA R3, ARRAY     ; Load ARRAY pointer address 
   ADD R3, R3, R5    ; Add counter to base of ARRAY
   LDR R3, R3, 0     ; Get value of R3 address
   ST  R3, PRECHAR   ; Put that value into unmodified character
   RET               ; Go back to main code (return)


; ENCRYPTSR
; pre: takes in character and a cipher 
; post: returns encrypted character (based on cipher)
ENCRYPTSR 
   ST  R7, POSTCHAR  ; Modified Char goes into R7
   AND R4, R4, 0     ; Reset Temp R4, prep for Row
   ADD R4, R4, 1     ; Add one to R4
   ST  R4, Ri        ; Row representation with R4

   AND R1, R1, 0     ; Reset Registers
   AND R2, R2, 0     ; Reset Registers
   AND R3, R3, 0     ; Reset Registers
   AND R4, R4, 0     ; Reset Registers
   AND R5, R5, 0     ; Reset Registers
   AND R6, R6, 0     ; Reset Registers
   AND R7, R7, 0     ; Reset Registers
   
   LD R2, ASCII_A    ; Load R2 with beginning of Uppercase A-Z
   LD R3, ASCII_Z    ; Load R3 with end of Uppercase A-Z
   LD R6, ASCII_a    ; Load R6 with beginning of Lowercase a-z
   LD R7, ASCII_z    ; Load R7 with end of Lowercase a-z
   NOT R2, R2        ; Flip R2 (2sc)
   ADD R2, R2, 1     ; Add one to R2 (2sc)
   NOT R3, R3        ; Flip R3 (2sc)
   ADD R3, R3, 1     ; Add one to R3

   NOT R6, R6        ; Flip R6 (2s)
   ADD R6, R6, 1     ; Add one to R6 (2sc)
   NOT R7, R7        ; Flip R7 (2sc)
   ADD R7, R7, 1     ; Add one to R7 (2sc)

CHECKAZ     
   LD R1, PRECHAR    ; Load R1 with unmodified Char 
   ADD R5, R1, R2    ; Add -65 to R1, store into R5
   BRn eSTORE  ; else char doesn't need to be changed, just store it
   AND R5, R5, 0     ; reset temp r5
   ADD R5, R1, R3    ; Add -90 to R1, store to R5
   BRp CHECKaz       ; else keep checking
   LD R2, ASCII_A    ; Load ASCII_A (65) into R2
   ADD R4, R4, R2    ; R4 += 65 (restore value)
   BRnzp eADDCIPHER; Add the Cipher to the A-Z value

CHECKaz
   AND R5, R5, 0
   ADD R5, R1, R6    ; Add -97 to unmodified char, store into R5
   BRn eSTORE        ; else char doesn't need modifying, just store it
   AND R5, R5, 0     ; Reset R5
   ADD R5, R1, R7    ; Add -122 to unmodified value, store to R5
   BRp eSTORE        ; else the char isn't a letter, just store it
   LD R2, ASCII_a    ; Load R2 with ASCII_a, 97
   AND R4, R4, 0     ; Reset TEMP r4
   ADD R4, R4, R2    ; R4 += 97 (restore original value)
   BRnzp eADDCIPHER      ; Add cipher to a-z value
   
eADDCIPHER 
   AND R2, R2, 0     ; reset temp register
   AND R3, R3, 0     ; reset temp register
   AND R5, R5, 0     ; reset temp register
   AND R6, R6, 0     ; reset temp register
   AND R7, R7, 0     ; reset temp register

   LD R7, CIPHER     ; Load r7 with Cipher
   LD R2, ALPHABET   ; Load r2 with 26, i.e alphabet size
   NOT R2, R2        ; flip r2 (2sc)
   ADD R2, R2, 1     ; add one to r2(2sc)

   ADD R5, R5, R4    ; Copy char into r5

   NOT R5, R5        ; flip r5 (2sc) 
   ADD R5, R5, 1     ; add one to r5(2sc)

   ADD R3, R1, R5    ; Add -(char) to R1
   ADD R6, R3, R7    ; Add cipher to character, place in R6
   ADD R5, R6, R2    ; Subtract alphabet size from R6, place in R5
   BRzp eOUTBOUNDS   ; if R5 >= 0, result is out of range 
   BRn eFINISH       ; else store it

eOUTBOUNDS
   AND R6, R6, 0     ; Reset temp r6
   ADD R6, R5, 0     ; Add -(a/A) to modified char to get it back into range

eFINISH
   AND R0, R0, 0     ; reset r0
   ADD R0, R4, R6    ; R0 = Add modified char with original range 
   ST R0, PRECHAR    ; Store new modified char into R0

eSTORE 
   JSR STORESR       ; Save the value into the 2D Array
   LD R7, POSTCHAR   ; Load R7 with changed character
   RET               ; Go back to getting chars


; DECRYPTSR
; pre: takes in character and a cipher 
; post: returns decrypted character (based on cipher)
DECRYPTSR
   ST  R7, POSTCHAR  ; Modified Char goes into R7
   AND R4, R4, 0     ; Reset Temp R4, prep for Row
   ADD R4, R4, 1     ; Add one to R4
   ST  R4, Ri        ; Row representation with R4

   AND R1, R1, 0     ; Reset Registers
   AND R2, R2, 0     ; Reset Registers
   AND R3, R3, 0     ; Reset Registers
   AND R4, R4, 0     ; Reset Registers
   AND R5, R5, 0     ; Reset Registers
   AND R6, R6, 0     ; Reset Registers
   AND R7, R7, 0     ; Reset Registers
   
   LD R2, ASCII_A    ; Load R2 with beginning of Uppercase A-Z
   LD R3, ASCII_Z    ; Load R3 with end of Uppercase A-Z
   LD R6, ASCII_a    ; Load R6 with beginning of Lowercase a-z
   LD R7, ASCII_z    ; Load R7 with end of Lowercase a-z
   NOT R2, R2        ; Flip R2 (2sc)
   ADD R2, R2, 1     ; Add one to R2 (2sc)
   NOT R3, R3        ; Flip R3 (2sc)
   ADD R3, R3, 1     ; Add one to R3
   NOT R6, R6        ; Flip R6 (2s)
   ADD R6, R6, 1     ; Add one to R6 (2sc)
   NOT R7, R7        ; Flip R7 (2sc)
   ADD R7, R7, 1     ; Add one to R7 (2sc)

dCHECKAZ     
   LD R1, PRECHAR    ; Load R1 with unmodified Char 
   ADD R5, R1, R2    ; Add -65 to R1, store into R5
   BRn dSTORE        ; else char doesn't need to be changed, just store it
   AND R5, R5, 0     ; reset temp r5
   ADD R5, R1, R3    ; Add -90 to R1, store to R5
   BRp dCHECKaz      ; else keep checking
   LD R2, ASCII_A    ; Load ASCII_A (65) into R2
   ADD R4, R4, R2    ; R4 += 65 (restore value)
   BRnzp dADDCIPHER  ; Add the Cipher to the A-Z value

dCHECKaz
   AND R5, R5, 0
   ADD R5, R1, R6    ; Add -97 to unmodified char, store into R5
   BRn dSTORE        ; else char doesn't need modifying, just store it
   AND R5, R5, 0     ; Reset R5
   ADD R5, R1, R7    ; Add -122 to unmodified value, store to R5
   BRp dSTORE        ; else the char isn't a letter, just store it
   LD R2, ASCII_a    ; Load R2 with ASCII_a, 97
   AND R4, R4, 0     ; Reset TEMP r4
   ADD R4, R4, R2    ; R4 += 97 (restore original value)
   BRnzp dADDCIPHER  ; Add cipher to a-z value
   
dADDCIPHER 
   AND R2, R2, 0     ; reset temp register
   AND R3, R3, 0     ; reset temp register
   AND R5, R5, 0     ; reset temp register
   AND R6, R6, 0     ; reset temp register
   AND R7, R7, 0     ; reset temp register

   LD R7, CIPHER     ; Load r7 with Cipher
   LD R2, ALPHABET   ; Load r2 with 26, i.e alphabet size
   ADD R5, R5, R4    ; Copy char into r5
   NOT R7, R7        ; flip r7 (2sc)
   ADD R7, R7, 1     ; add one to r2(2sc)
   NOT R2, R2        ; flip r7 (2sc)
   ADD R2, R2, 1     ; add one to r2(2sc)
   NOT R5, R5        ; flip r5 (2sc) 
   ADD R5, R5, 1     ; add one to r5(2sc)

   ADD R3, R1, R5    ; Add -(char) to R1
   ADD R6, R3, R7    ; Add cipher to character, place in R6
   BRn dOUTBOUNDS    ; if R5 >= 0, result is out of range 
   BRzp dFINISH      ; else store it
   
dOUTBOUNDS
   LD R2, ALPHABET   ; Load alphabet size into R2
   ADD R6, R6, R2    ; Add 26 to R6, the modified character

dFINISH
   AND R0, R0, 0     ; reset r0
   ADD R0, R4, R6    ; R0 = Add modified char with original range 
   ST R0, PRECHAR    ; Store new modified char into R0

dSTORE 
   JSR STORESR       ; Save the value into the 2D Array
   LD R7, POSTCHAR   ; Load R7 with changed character
   RET               ; Go back to getting chars


; PRINTSR
; pre: takes in 2D ARRAY
; post: prints out the ARRAY
PRINTSR
   ST R7, POSTCHAR ;POSTCHAR = R7

   AND R1, R1, 0     ; Reset temp register
   AND R2, R2, 0     ; Reset temp register
   AND R3, R3, 0     ; Reset temp register
   AND R4, R4, 0     ; Reset temp register 
   AND R5, R5, 0     ; Reset temp register
   AND R6, R6, 0     ; Reset temp register

   LD R5, DEorEN     ; Load Decrypt/encrypt flag into R5
   BRp ENCLOAD       ; if 1, optimize for encrypted value
   LEA R0, DECRYPTSTR; else load decrypted string address
   
ENCLOAD
   LEA R0, ENCRYPTSTR; Load encrypted string address
   
   PUTS              ; Print string in R0 
PRINTLOOP
   ST R1, Ri         ; Set R1 to represent Rows
   ST R3, Ci         ; R3 will represent columns
   JSR LOADSR
   LD R0, PRECHAR    ; R0 holds char
   OUT               ; Print the char 
   LD R2, HALF_ARRAY ; R2 = HALF_ARRAY
   ADD R4, R4, 0     ; Setting up conditional for later
   BRp NEXTHALF      ; if conditional was met, optimize for 2nd half of array
   NOT R2, R2        ; flip R2 (2sc)
   ADD R2, R2, 1     ; add one to r2 (2sc)
   LD R3, Ci         ; Load column (strlen) into R3
   ADD R3, R3, 1     ; increment R3
   ST R3, Ci         ; Store incremented count into R3
   AND R6, R6, 0     ; Reset temp r6
   ADD R6, R3, R2    ; Add r3(strlen) to R2 (half array size)
   BRn PRINTLOOP     ; keep going until entire half is printed
   
   ADD R4, R4, 1     ; if first half is empty, set condition to print next half
   LD R5, DEorEN     ; Load Decrypt/encrypt flag into R5
   BRp ENCLOAD2      ; if 1, optimize for decrypted value
   LEA R0, ENCRYPTSTR; else load encrypted string address
ENCLOAD2
   LEA R0, DECRYPTSTR; Load encrypted string address
   PUTS              ;
   BRnzp PRINTLOOP   ; go back one more time
NEXTHALF
   ADD R2, R2, R2    ; double R2(array size) so we can account for 2nd half
   NOT R2, R2        ; flip R2 (2sc)
   ADD R2, R2, 1     ; add one to r2 (2sc)
   LD R3, Ci         ; Load column (strlen) into R3
   ADD R3, R3, 1     ; increment R3
   ST R3, Ci         ; Store incremented count into R3
   AND R6, R6, 0     ; Reset temp r6
   ADD R6, R3, R2    ; Add r3(strlen) to R2 (half array size)
   BRn PRINTLOOP     ; keep going until entire half is printed
   AND R0, R0, 0     ; Reset R0
   ADD R0, R0, 10    ; Load R0 with 10, ASCII new line
   OUT               ; Print R0 to screen
   LD R7, POSTCHAR   ; Load R7 with the char
   RET               ; Go back to main program


; RESETARRAYSR
; pre: takes in 2D ARRAY
; post: clears (Resets) ARRAY 
RESETARRAYSR
   AND R1, R1, 0     ; Reset temp array
   AND R4, R4, 0     ; Reset temp array
   LD R3, HALF_ARRAY ; Load R3 with half-array size
   ADD R3, R3, R3    ; double R3 (full array size)
   NOT R3, R3        ; flip r3 (2sc)
   ADD R3, R3, 1     ; add 1 to r3 (2sc)
RESETLOOP
   LEA R2, ARRAY     ; Place array pointer into R2
   ADD R2, R2, R1    ; add to array index
   STR R4, R2, 0     ; Store r2 value into r4 address
   ADD R1, R1, 1     ; increment R1 counter
   ADD R5, R1, R3    ; Add R1(counter) and R3(neg. full array size)
   BRn RESETLOOP     ; When R5 < 0 we have cycled through entire array
   RET               ; Return to main program for next cycle
   
   
ARRAY        .BLKW 400
.END