* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*                                     Fixed point division                                      *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Functions :                                                                                   *
                                                                                                * 
* 1/ cmp16 : Compares two 16 bits values, passed on the stack.                                  *
* 2/ div16 : Divides two 16 bits values, passed on the stack (standard 16 bits division).       * 
*         Result in dividend var (16 bits), remainder in rem var (16 bit).                      * 
* 3/ div16dec : Divides two 16 bits values, passed on the stack                                 *                                     
*            Result :                                                                           *
*               - integer part in dividend var (16 bit).                                        *
*               - decimal part in decimal var (16 bit).                                         *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
cmp16
* ref : 6502_Assembly_Language_Subroutines.pdf
* IN : 
        ;return address ; subtrahend ; minuend
* OUT :
        ; C=1 : first number pushed on the stack is bigger
        ; C=0 : second number pushed on the stack is bigger
       
        ;Flags set as if subtrahend had been subtracted from minuend, with a correction if
        ;two's complement overflow occurred.
        ;Zero flag = 1 if subtrahend and minuend are equal, 0 if they are not equal.
        ;Carry flag = 0 if subtrahend is larger than minuend in the unsigned sense, 1 if it is less
        ;than or equal to the minuend.
        ;Negative flag = 1 if subtrahend is larger than minuend in the signed sense, 0 if it is less
        ;than or equal to the minuend. This flag is corrected if two's complement overflow occurs.
                        ;save the return address
                pla
                sta ret2+1
                pla
                sta ret+1
                ;get op1
                pla
                sta op1
                pla
                sta op1+1
                ;get op2
                pla
                sta op2
                pla
                sta op2+1
                ;restore return address
ret             lda #0
                pha
ret2            lda #0
                pha

                lda op2
                cmp op1 ;compare low bytes
                beq equalcmp ;branch if they are equal
                ;low bytes are not equal - compare high bytes
                lda op2+1
                sbc op1+1 ;compare high bytes
                ora #1 ;make z = 0, since low bytes are not equal
                bvs ovflow ;must handle overflow for signed arithmatic
                rts ;exit
                ;low bytes are equal - compare high bytes
equalcmp
                lda op2+1
                sbc op1+1 ;upper bytes
                bvs ovflow ;must handle overflow for signed arithmetic
                rts ;return with flags set
                ;overflow with signed arithmetic so complement the negative flag
                ; do not change the carry flag and make the zero flag equal 0.
                ; complement negative flag by exclusive-oring 80h and accumulator.
ovflow
                eor #$80 ;complement negative flag
                ora #1 ;if overflow then the words are not equal z=0
                ;carry unchanged
                rts

retadrcmp       ds 2
op1             ds 2
op2             ds 2
*
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* division 16 bits V2
* ref : 6502_Assembly_Language_Subroutines.pdf
*
div16
                ;save return address
                pla
                sta retadr
                pla
                sta retadr+1
                ;get divisor
                pla
                sta divisor
                pla
                sta divisor+1
                ;get dividend
                pla
                sta dividend
                pla
                sta dividend+1

                ;restore return address
                lda retadr+1
                pha
                lda retadr
                pha

* perform division
                lda #0                          ;initialize rem to 0
                sta rem
                sta rem+1
                ldx #16                         ;there are 16 bits in dividend
l1              asl dividend                    ;shift hi bit of dividend into rem
                rol dividend+1                  ;(vacating the lo bit, which will be used for the quotient)
                rol rem
                rol rem+1
                lda rem
                sec                             ;trial subtraction
                sbc divisor
                tay
                lda rem+1
                sbc divisor+1
                bcc l2                          ;did subtraction succeed?
                sta rem+1                       ;if yes, save it
                sty rem
                inc dividend                    ;and record a 1 in the quotient
l2              dex
                bne l1
                rts
*
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* division 16 bit + decimal
*
div16dec
                ;save return address
                pla
                sta retadr
                pla
                sta retadr+1

                ;get divisor
                pla
                sta divisor
                pla
                sta divisor+1
                ;get dividend
                pla
                sta dividend
                pla
                sta dividend+1

                ;restore return address
                lda retadr+1
                pha
                lda retadr
                pha

* perform division, integer part
                lda #0                          ;initialize rem to 0
                sta rem
                sta rem+1
                ldx #16                         ;there are 16 bits in dividend
l11             asl dividend                    ;shift hi bit of dividend into rem
                rol dividend+1                  ;(vacating the lo bit, which will be used for the quotient)
                rol rem
                rol rem+1
                lda rem
                sec                             ;trial subtraction
                sbc divisor
                tay
                lda rem+1
                sbc divisor+1
                bcc l22                         ;did subtraction succeed?
                sta rem+1                       ;if yes, save it
                sty rem
                inc dividend                    ;and record a 1 in the quotient
l22             dex
                bne l11 

* now decimal part
*
                lda #0                          ; init decimal part to 0
                sta decimal
                sta decimal+1

                lda rem                         ; test remainder 
                ora rem+1                       ; if remainder = 0 : exit
                beq endec

                movInt dividend;tempo           ; save result (integer part)
                jsr Decimal                     ; calculate decimal part
                movInt tempo;dividend           ; restore result (integer part)

endec           rts             
* 
*
Decimal                                                ; calcute decimal part
* ALGO :
* remainder = remainder * 2 ; 
* if remainder < divisor then shift left decimal var with carry clear and loop (unless already 16 loops)
* if remainder >= divisor then shift left decimal var with carry set,
* divide remainder by divisor and loop (unless already 16 loops)
*
                lda #16                                 ; init loop counter
                sta loopcnt

restart         asl rem                                 ; remainder x 2
                rol rem+1
                DoCompare16 rem;divisor;cmp16           ; compare with divisor
                beq equal 
                bcs bigger                              ; branch if equal or bigger
                clc
                rol decimal                             ; else shift left decimal with carry clear
                rol decimal+1
                dec loopcnt                             ; loop if not 16 loops
                beq endfunc
                bne restart
equal
bigger
                sec                                     ; here if remainder >= divisor. 
                rol decimal                             ; rol decimal with carry set
                rol decimal+1
                DoDivid16 rem;divisor;div16             ; divide again to get a new remainder
                dec loopcnt                             ; loop if not 16 loops
                bne restart
endfunc
                rts
*
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* Variables
*
rem             dw 0
decimal         dw 0
dividend        dw 0
divisor         dw 0
retadr          dw 0
loopcnt         ds 1
tempo           ds 2