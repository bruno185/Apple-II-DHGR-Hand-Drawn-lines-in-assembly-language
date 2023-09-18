* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Functions :
* - Set SetNpPt :
*       ==> Calculate number of points : divide DeltaMax by seglength (constant)
* - SetInc :
*       ==> Calculate increment in X and Y directions.
*       uses a new version of div16, with fixed point (16 bit integer part + 16 bit decimal part )
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

SetNpPt         
* Calculate number of points : divide DeltaMax by seglength (constant)


                DoDivid16 deltaMax;seglength;div16
                movInt dividend;nbpt                            ; sav number of points 
                movInt dividend;savnbpt                         ; in 2 vars.
                rts

SetInc 
* Calculate increment fox X and Y : divide deltaXabs and deltaYabs by number of points.
* DecimalX and DecimmalY calculate decimal part of above division :
*  ===> ALGO <===
* remainder = remaider * 2 ; if remaider < divisor (=nbpt) then shift left XincDec (and YincDec repectively)
* with carry clear and loop (unless already 16 loops)
* if remaider >= divisor (=nbpt) then shift left XincDec (and YincDec repectively)
* with carry set and loop (unless already 16 loops)

DoX 
                DoDivid16 deltaXabs;nbpt;div16dec
                movInt dividend;Xinc                    ; integer part
                movInt decimal;XincDec                  ; decimal part

                cr
                printm deltaXabs                        ; = dividend
                printm nbpt                             ; = divisor
                printm dividend                         ; result of division (integer part)
                printm XincDec                          ; result of division (decimal part)    
                     
DoY
                DoDivid16 deltaYabs;nbpt;div16dec
                movInt dividend;Yinc                    ; integer part  
                movInt decimal;YincDec                  ; decimal part
                cr
                printm deltaYabs                        ; = dividend
                printm nbpt                             ; = divisor
                printm dividend                         ; result of division (integer part)
                printm YincDec                          ; result of division (decimal part)               

endinc          rts
                


* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
