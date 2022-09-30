;
; Created: 9/30/2022 12:16:27 AM
; Author : Gavins M.
;
.CSEG
.ORG       0x0000

 ; Initialize and setup ADC once

Start: 
        
        ; set clock divider
		LDI R16, 0x0011    ; clock divided by 8 for 1MHz (0x00 divides by 1 - RUNS AT 8MHz)
		LDI R17, 0xD8      ; the key for CCP
		OUT CCP, R17       ; Configuration Change Protection, allows protected changes
		OUT CLKPSR, R16    ; sets the clock divider

INIT_ADC:  
        ; set up the ADC
        ; ADCSRA contains [ADEN, ADSC, ADATE, ADIF, ADIE, ADPS2, ADPS1, ADPS0]
        ; which means: enable, start, trigger enable, int flag, int enable, clock prescaler
        ;
        ; ADCSRB contains [-,-,-,-,-,ADTS2, ADTS1, ADTS0]
        ; means: auto trigger soure 0=free running, 1=analog comparator, 2=int0, 3,5=timer comp. A,B,
        ;        4=tmer overflow, 6=pinchange int, 7=timer capture
        ;
        ; ADMUX contains [-,-,-,-,-,-,MUX1,MUX0]
        ; sets the channel(pin) for conversion
        ;
        ; DIDR0 contains [-,-,-,-,ADC3D to ADC0D]
        ; disables the digital input, not necessary, but uses less power

        LDI R17, (1<<ADC1D)       ; disable digital on PB1
        OUT DIDR0, R17
        LDI R18, (1<<MUX0)        ; Analog Channel: ADC1 admux=>01 (PB1)
        OUT ADMUX, R18
        
        LDI   R20, 0b10000110    ; Enable ADC, ADC prescaler CLK/64
        OUT   ADCSRA, R20
        
          ; FOR INTERRUPT
          ;LDI R19, 0x00 ; Free Running mode
          ;OUT ADCSRB, R19
          ;LDI R20, (1<<ADEN)|(1<<ADSC)|(1<<ADATE)|(1<<ADIE) ; enable, start, trigger, int enable, prescaler=2(min)
          ;OUT ADCSRA, R20

 ; To be Looped
REPEAT:

    READ_ADC:
        LDI   R16, 0b01000000     ; Set ADSC in ADCSRA to start conversion 
        IN    R17, ADCSRA         ;
        OR    R17, R16            ; 
        OUT   ADCSRA, R17
        
    WAIT_ADC:
        IN    R16, ADCSRA        ; check ADIF flag in ADCSRA
        SBRS  R16, 4             ; skip jump when conversion is done (flag set)
        RJMP  WAIT_ADC           ; loop until ADIF flag is set
        
        LDI   R17,  0b00010000   ; Set the flag again to signal 'ready-to-be-cleared' by hardware
        IN    R18, ADCSRA        ;
        OR    R18, R17           ;
        OUT   ADCSRA, R18        ; so that controller clears ADIF
      

        IN    R18, ADCL 

        ; do cool stuff with ADC value :)


        RJMP  REPEAT