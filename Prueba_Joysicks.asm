;*******************************************************************************
;                                                                              *
;    Filename:	    Pruebas.asm						       *
;    Date:	    noviembre, 2018					       *
;    Autors:	    Jose Pablo De Leon					       *
;		    Jose Pablo Marroquin				       *
;    Description:   Joystick reading with AN5 and AN6,			       *
;	    X+ increments PORTA (up to 255), X- decrements PORTA (down to 0),  *
;	    Y+ increments PORTB (up to 255), Y- decrements PORTB (down to 0).  *
;									       *
;*******************************************************************************
;*******************************************************************************
;                                                                              *
;    Revision History:							       *
;                                                                              *
;*******************************************************************************

; INCLUDE
    #include "p16f887.inc"

; CONFIG1
; __config 0xE0D4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
 
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

; TODO PLACE VARIABLE DEFINITIONS GO HERE
GPR_VAR		UDATA
DELAY1		RES 1		; VARIABLE PARA DELAY1
DELAY2		RES 1		; VARIABLE PARA DELAY2
VAL1		RES 1		; VARIABLE MANIPULADA CON JOYSTICK
VAL2		RES 1		; VARIABLE MANIPULADA CON JOYSTICK
W_TEMP		RES 1
STATUS_TEMP	RES 1

;*******************************************************************************
; Reset Vector
;*******************************************************************************

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

;*******************************************************************************
; Interrupt Service Routines
;*******************************************************************************
ISR       CODE    0x0004           ; interrupt vector location

PUSH:
    BCF	    INTCON, GIE
    MOVWF   W_TEMP
    SWAPF   STATUS, W
    MOVWF   STATUS_TEMP
ISR:
   
POP:
    SWAPF   STATUS_TEMP, W
    MOVWF   STATUS
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    BSF	    INTCON, GIE
    RETFIE
;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************
MAIN_PROG CODE                      ; let linker place main program

START
SETUP:
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH	; DIGITAL I/O
    BSF	    ANSEL,  5
    BSF	    ANSEL,  6	; ANS<5:6> AS ANALOG INPUTS
    
    BANKSEL TRISA
    CLRF    TRISA	; PORTA AS OUTPUT (LEDS REFERENCIA)
    CLRF    TRISB	; PORTb AS OUTPUT (LEDS REFERENCIA)
    CLRF    TRISC	; PORTC AS OUTPUT
    CLRF    TRISD	; PORTC AS OUTPUT
    CLRF    TRISE
    BSF	    TRISE,  RE0	; PINS <0:1> PORTE AS INPUTS
    BSF	    TRISE,  RE1	; LECTURA DE VOLTAJES ANALÓGICOS

    BSF	    OSCCON, 6	; F_osc = 1 MHZ, INTERNAL OSCILATOR
    BCF	    OSCCON, 5
    BCF	    OSCCON, 4
    
    CALL    CONFIG_ADC
    
    BANKSEL PORTA
    CLRF    PORTA
    CLRF    PORTB
    CLRF    PORTC
    CLRF    PORTD
    CLRF    PORTE
    CLRF    VAL1
    CLRF    VAL2
;*******************************************************************************
LOOP:
JS1_X:
    BCF ADCON0, CHS3		; AN5
    BSF ADCON0, CHS2
    BCF ADCON0, CHS1
    BSF ADCON0, CHS0
    CALL    DELAY_500US		; DELAY    
    BSF	    ADCON0, GO		; EMPIECE LA CONVERSIÓN
CHECKADC1:
    BTFSC   ADCON0, GO		; ¿TERMINÓ CONVERSIÓN?
    GOTO    CHECKADC1		; NO -> VUELVE A REVISAR
    MOVF    ADRESH, W		; SÍ -> MUESTRA EL VALOR
    MOVWF   VAL1		; MUEVE ADRESH A VARIABLE
    BCF	    PIR1,   ADIF	; BORRAR BANDERA DE ADC

    MOVLW   .108	    ; LÍMITE 1
    SUBWF   VAL1,   W	    ; REVISAR SI VAL1 < 115,
    BTFSC   STATUS, C	    ; ¿ESTÁ VAL1 EN PRIMER INTERVALO (RESULTADO NEGATIVO)?
    GOTO    T1X1	    ; NO -> REVISA SI VAL1 ESTÁ EN SIGUIENTE INTERVALO
    MOVF    PORTA,  W	    ; SÍ -> REVISA SI TODAVÍA PUEDE INCREMENTAR PORTA
    XORLW   0FFh
    BTFSC   STATUS, Z	    ; ¿PUEDE INCREMENTARSE PORTA?
    GOTO    T1X1	    ; NO -> REVISA SI VAL1 ESTÁ EN SIGUIENTE INTERVALO
    INCF    PORTA,  F	    ; SÍ -> INCREMENTA PORTA
    GOTO    JS1_Y
T1X1:
    MOVLW   .158	    ; LÍMITE 3
    SUBWF   VAL1,   W	    ; REVISAR SI VAL1 > 155
    BTFSS   STATUS, C	    ; ¿ESTÁ EN EL TERCER INTERVALO (RESULTADO POSITIVO)?
    GOTO    JS1_Y	    ; NO -> REVISA SIGUIENTE EJE
    MOVF    PORTA,  W	    ; SÍ -> REVISA SI TODAVÍA PUEDE DECREMENTAR PORTA
    XORLW   .0
    BTFSS   STATUS, Z	    ; ¿PUEDE DECREMENTARSE PORTA?
    DECF    PORTA,  F	    ; SÍ -> DECREMENTA PORTA
			    ; NO -> NO CAMBIA VALOR EN PORTA
JS1_Y:
    BCF ADCON0, CHS3		; AN6
    BSF ADCON0, CHS2
    BSF ADCON0, CHS1
    BCF ADCON0, CHS0
    CALL    DELAY_500US		; DELAY    
    BSF	    ADCON0, GO		; EMPIECE LA CONVERSIÓN
CHECKADC2:
    BTFSC   ADCON0, GO		; ¿TERMINÓ CONVERSIÓN?
    GOTO    CHECKADC2		; NO -> VUELVE A REVISAR
    MOVF    ADRESH, W		; SÍ -> MUESTRA EL VALOR
    MOVWF   VAL2		; MUEVE ADRESH A VARIABLE
    BCF	    PIR1, ADIF		; BORRAR BANDERA DE ADC
    
    MOVLW   .114	    ; LÍMITE 1
    SUBWF   VAL2,   W	    ; REVISAR SI VAL1 < 115,
    BTFSC   STATUS, C	    ; ¿ESTÁ EN EL PRIMER INTERVALO (RESULTADO NEGATIVO)?
    GOTO    T1Y1	    ; NO -> REVISA SI VAL2 ESTÁ EN SIGUIENTE INTERVALO
    MOVF    PORTB,  W	    ; SÍ -> REVISA SI TODAVÍA PUEDE INCREMENTAR PORTB
    XORLW   0FFh
    BTFSC   STATUS, Z	    ; ¿PUEDE INCREMENTARSE PORTB?
    GOTO    T1Y1	    ; NO -> REVISA SI VAL2 ESTÁ EN SIGUIENTE INTERVALO
    INCF    PORTB,  F	    ; SÍ -> INCREMENTA PORTB
    GOTO    JS1_X
T1Y1:
    MOVLW   .164	    ; LÍMITE 3
    SUBWF   VAL2,   W	    ; REVISAR SI VAL1 > 155
    BTFSS   STATUS, C	    ; ¿ESTÁ EN EL TERCER INTERVALO (RESULTADO POSITIVO)?
    GOTO    JS1_X	    ; NO -> REVISA SIGUIENTE EJE
    MOVF    PORTB,  W	    ; SÍ -> REVISA SI TODAVÍA PUEDE DECREMENTAR PORTB
    XORLW   .0
    BTFSS   STATUS, Z	    ; ¿PUEDE DECREMENTARSE PORTB?
    DECF    PORTB,  F	    ; SÍ -> DECREMENTA PORTB
			    ; NO -> NO CAMBIA VALOR EN PORTB
    GOTO    LOOP
;*******************************************************************************
; SUBRUTINA DE CONFIGURACIÓN INTERRUPCIONES TMR1 Y 2
;*******************************************************************************
CONFIG_ADC
    BANKSEL PORTA
    BCF	    ADCON0, ADCS1
    BSF	    ADCON0, ADCS0		; FOSC/8 RELOJ TAD
    
    BANKSEL TRISA
    BCF	    ADCON1, ADFM		; JUSTIFICACIÓN A LA IZQUIERDA
    BCF	    ADCON1, VCFG1		; VSS COMO REFERENCIA VREF-
    BCF	    ADCON1, VCFG0		; VDD COMO REFERENCIA VREF+
    BANKSEL PORTA
    BSF	    ADCON0, ADON		; ENCENDER MÓDULO ADC
    RETURN
;*******************************************************************************
; SUBRUTINAS PARA DELAYS
;*******************************************************************************
DELAY_50MS
    MOVLW   .100	    ; 1US 
    MOVWF   DELAY2
    CALL    DELAY_500US
    DECFSZ  DELAY2	    ; DECREMENTA CONT1
    GOTO    $-2		    ; IR A LA POSICION DEL PC - 1
    RETURN
    
DELAY_500US
    MOVLW   .250	    ; 1US 
    MOVWF   DELAY1	    
    DECFSZ  DELAY1	    ; DECREMENTA CONT1
    GOTO    $-1		    ; IR A LA POSICION DEL PC - 1
    RETURN
;*******************************************************************************
    END