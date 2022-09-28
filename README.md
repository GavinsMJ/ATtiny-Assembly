## ATtiny-Assembly
ATtiny Assembly

The following sections give some tips on programming the ATtiny10.

# pinMode

```assembly
LDI    R16,  0b0101
OUT    DDRB, R16         ; Equivalent to pinMode(1, OUTPUT); pinMode(3, OUTPUT);
```

# Input pullups

Unlike the older AVR chips, such as the ATmega328 and ATtiny85, the ATtiny10 enables pullup resistors using a separate pullup register, PUEB. To set pullups on input pins you set the corresponding bits in this register. For example, to set a pullup resistor on input pin 2:

```assembly
LDI    R16,  0b0010
OUT    PUEB, R16         ; Equivalent to pinMode(2, INPUT_PULLUP);
``` 

# Write and Read Input

digitalWrite
To set the state of an output you set the corresponding bits in the PORTB register. For example, to set bit 1 low and bit 3 high (assuming they have been defined as outputs):

```assembly
LDI    R16,  0b0100
OUT    PORTB, R16         ; Equivalent to digitalWrite(1, LOW); digitalWrite(3, HIGH); 
```
  
digitalRead
To read the state of the I/O pins you read the PINB register:

```assembly
IN     R16,   PINB
```

# PWM Output

PWM 
You can use OC0A (PB0) and OC0B (PB1) for PWM output. You first need to configure the Timer/Counter into PWM mode for that pin; for example, using PB0 in C:

```c
TCCR0A = 2<<COM0A0 | 3<<WGM00; // 10-bit PWM on OC0A (PB0), non-inverting mode
TCCR0B = 0<<WGM02 | 1<<CS00;   // Divide clock by 1
DDRB = 0b0001;                 // Make PB0 an output
To output we write the value to the appropriate output compare register, OCR0A:

OCR0A = 1000;                  // Equivalent to analogWrite(0, 1000)
//With a 5V supply this will set PB0 to 1000/1024 * 5V, or 4.88V.
```

In assembly 
```assembly

;Too large check separate repo

```

# Analog signal read
To use an I/O pin for analogue input you first need to configure the Analogue-to-Digital Converter. For example, to use ADC0 in C:


```c
ADMUX = 0<<MUX0;               // ADC0 (PB0)
ADCSRA = 1<<ADEN | 3<<ADPS0;   // Enable ADC, 125kHz clock
To read an analogue value from the pin we then need to start a conversion, and when the conversion is ready read the ADC register:

ADCSRA = ADCSRA | 1<<ADSC;     // Start
while (ADCSRA & 1<<ADSC);      // Wait while conversion in progress
int temp = ADCL;               // Copy result to temp
```

In assembly 
```assembly`
 ; CALL to Initialize and setup ADC once
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
        STS   ADCSRA, R20
		RET
          ; FOR INTERRUPT
          ;LDI R19, 0x00 ; Free Running mode
          ;OUT ADCSRB, R19
          ;LDI R20, (1<<ADEN)|(1<<ADSC)|(1<<ADATE)|(1<<ADIE) ; enable, start, trigger, int enable, prescaler=2(min)
          ;OUT ADCSRA, R20
		

 ; To be repeated multiple times
REPEAT:
		CALL  READ_ADC
		CALL  WAIT_ADC
		LDS   R18, ADCL            ; Must read ADCL first, and ADCH after that
		LDS   R19, ADCH            ;
;-----------------------------------------------------------------------


READ_ADC:
		LDI   R16, 0b01000000     ; Set ADSC in ADCSRA to start conversion 
		LDS   R17, ADCSRA         ;
		OR    R17, R16            ; 
		STS   ADCSRA, R17
		RET
        
WAIT_ADC:
		LDS   R16, ADCSRA		 ; check ADIF flag in ADCSRA
		SBRS  R16, 4       		 ; skip jump when conversion is done (flag set)
		RJMP  WAIT_ADC    		 ; loop until ADIF flag is set
        
		LDI   R17,  0b00010000	 ; Set the flag again to signal 'ready-to-be-cleared' by hardware
		LDS   R18, ADCSRA		 ;
		OR    R18, r17			 ;
		STS   ADCSRA, R18		 ; so that controller clears ADIF
		RET
```