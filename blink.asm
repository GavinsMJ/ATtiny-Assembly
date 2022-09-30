;
; Created: 9/27/2022 10:30:01 PM
; Author : Gavins M.
;
 .CSEG
 .ORG		0x0000			         ;Beginning of program memory


 MAIN:
		LDI	  R16, HIGH(RAMEND)  ;Initialize the stack
		OUT   SPH, R16
		LDI   R16, LOW(RAMEND)
		OUT   SPL, R16
		CLR   R16

        ; set clock divider
		LDI R16, 0x0011    ; clock divided by 8 for 1MHz (0x00 divides by 1 - RUNS AT 8MHz)
		LDI R17, 0xD8      ; the key for CCP
		OUT CCP, R17       ; Configuration Change Protection, allows protected changes
		OUT CLKPSR, R16    ; sets the clock divider

                   
		LDI   R16, 1<<PB0        ; SET PB0 as output
		OUT   DDRB, R16

loop:                 
		SBI   PORTB, 0           ;Set pin PB0 HIGH
		RCALL       DELAY       
		CBI   PORTB, 0           ;clear pin PB0 LOW
		RCALL       DELAY      
		RJMP        loop    

;------------------------------ If Running at 1 MHz
DELAY:           LDI    R16,10   ; then 1000ms delay i.e 250,000*4 clock cycles
LOOP1:           LDI    R17,100
LOOP2:           LDI    R18,250
LOOP3:           NOP
          DEC  R18
	      BRNE        LOOP3

	      DEC  R17
	      BRNE        LOOP2

	      DEC  R16
	      BRNE        LOOP1 
          RET
