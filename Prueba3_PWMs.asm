;*******************************************************************************
;                                                                              *
;    Filename:	    Pruebas.asm						       *
;    Date:	    noviembre, 2018					       *
;    Autors:	    Jose Pablo De Leon					       *
;		    Jose Pablo Marroquin				       *
;    Description:   PWM using T with TMR1 (20MS)			       *
;		    Delta T_ON with TMR0 (4US)				       *
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
TONMIN		RES 1		; VARIABLE PARA CONTAR DELTAS DE TIEMPO ON, TOTAL 1MS FIJO
TONVAR		RES 1		; VARIABLE PARA CONTAR DELTAS T_ON, ENTRE 0 Y 1MS, DESPUÉS DE 1MS ON (PWM1)
TONVAR2		RES 1		; VARIABLE PARA CONTAR DELTAS T_ON, ENTRE 0 Y 1MS, DESPUÉS DE 1MS ON (PWM2)
DIF_T		RES 1		; VARIABLE PARA CONTAR DELTAS DE TIEMPO
ADCX1		RES 1		; VARIABLE DE VRX JOYSTICK 1
ADCY1		RES 1		; VARIABLE DE VRY JOYSTICK 1
ADCX2		RES 1		; VARIABLE DE VRX JOYSTICK 2
ADCY2		RES 1		; VARIABLE DE VRY JOYSTICK 2
VAL1		RES 1		; VARIABLE MANIPULADA CON VRX JOYSTICK 1
VAL2		RES 1		; VARIABLE MANIPULADA CON VRY JOYSTICK 1
VAL3		RES 1		; VARIABLE MANIPULADA CON VRX JOYSTICK 2
VAL4		RES 1		; VARIABLE MANIPULADA CON VRY JOYSTICK 2
DELAY1		RES 1		; VARIABLE PARA DELAY1
DELAY2		RES 1		; VARIABLE PARA DELAY2
W_TEMP		RES 1
STATUS_TEMP	RES 1

PWM	MACRO	VALOR, PIN
	LOCAL	FIN
    DECFSZ  TONMIN, F
    GOTO    FIN
    
    MOVF    DIF_T,  W	    ; REVISAR SI DIF_T ES MAYOR O IGUAL QUE VALOR
    SUBWF   VAL4,   W
    BTFSS   STATUS, C	    ; ¿DIF_T >= VAL1?
    BCF	    PORTD,  RD3	    ; SÍ -> APAGA EL PIN

FIN:
    ENDM
;*******************************************************************************
; Reset Vector
;*******************************************************************************
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program
;*******************************************************************************
; Interrupt Service Routines
;*******************************************************************************
ISR       CODE    0x0004	; interrupt vector location

PUSH:
    BCF	    INTCON, GIE
    MOVWF   W_TEMP
    SWAPF   STATUS, W
    MOVWF   STATUS_TEMP
ISR:
    BTFSS   PIR1,   TMR1IF
    GOTO    INT0
    MOVLW   .250
    MOVWF   TONMIN
    CLRF    DIF_T
;    BSF	    PORTD,  RD0
;    BSF	    PORTD,  RD1
;    BSF	    PORTD,  RD2
    BSF	    PORTD,  RD3
    
INT0:
    BTFSS   INTCON, T0IF
    GOTO    POP
    MOVLW   .252		; N=252
    MOVWF   TMR0
    BCF	    INTCON, T0IF
    
    INCF    DIF_T
    
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
;    BCF	    TRISD,  RD0
;    BCF	    TRISD,  RD1
;    BCF	    TRISD,  RD2
    BCF	    TRISD,  RD3	; PINS <0:3> PORTD AS PWM OUTPUTS
    CLRF    TRISE
    BSF	    TRISE,  RE0	; PINS <0:1> PORTE AS INPUTS
    BSF	    TRISE,  RE1	; LECTURA DE VOLTAJES ANALÓGICOS

    BSF	    OSCCON, 6	; F_osc = 8 MHZ, INTERNAL OSCILATOR
    BSF	    OSCCON, 5
    BSF	    OSCCON, 4
    
    CALL    CONFIG_TMR0
    CALL    CONFIG_TMR1
    CALL    CONFIG_INTERRUPT
    
    BANKSEL PORTA
    CLRF    PORTA
    BSF     PORTA, RA1
    CLRF    PORTB
    CLRF    PORTC
    CLRF    PORTD
    CLRF    PORTE
;    CLRF    VAL1
    MOVLW   .125
    MOVWF   VAL1
    CLRF    TONMIN
;*******************************************************************************
LOOP:
    PWM	    VAL1,   RD3
    
    GOTO    LOOP
;*******************************************************************************
; SUBRUTINA DE CONFIGURACIÓN TIMER0
;*******************************************************************************
CONFIG_TMR0
    BANKSEL TRISA
    BCF	    OPTION_REG, T0CS
    BCF	    OPTION_REG, PSA	; Asignación de Prescaler al TMR0
    BSF	    OPTION_REG, PS2	; PRESCALER 1:256
    BSF	    OPTION_REG, PS1
    BSF	    OPTION_REG, PS0
    BANKSEL PORTA
    MOVLW   .252		; N = 252
    MOVWF   TMR0
    RETURN
;*******************************************************************************
; SUBRUTINA DE CONFIGURACIÓN TIMER1
;*******************************************************************************
CONFIG_TMR1
    BANKSEL PORTA
    BCF	    T1CON,  TMR1GE	; COUNTING
    BCF	    T1CON,  T1CKPS1	; PRESCALER 1:1
    BCF	    T1CON,  T1CKPS0
    BCF	    T1CON,  TMR1CS	; INTERNAL CLOCK
    BSF	    T1CON,  TMR1ON	; ENABLE TIMER1
    MOVLW   0ECh		; N =  d = 0EC78 h
    MOVWF   TMR1H
    MOVLW   078h
    MOVWF   TMR1L
    BCF	    PIR1,   TMR1IF
    RETURN
;*******************************************************************************
; SUBRUTINA DE CONFIGURACIÓN INTERRUPCIONES TMR1 Y 2
;*******************************************************************************
CONFIG_INTERRUPT
    BANKSEL TRISA
    BSF	    PIE1,   TMR1IE
;    BSF	    PIE1,   TMR2IE
    BANKSEL PORTA
    BSF	    INTCON, GIE
    BSF	    INTCON, PEIE
    BSF	    INTCON, T0IE
    BCF	    INTCON, T0IF
    BCF	    PIR1,   TMR1IF
;    BCF	    PIR1,   TMR2IF
    RETURN
;*******************************************************************************
; SUBRUTINAS PARA DELAYS
;*******************************************************************************
;DELAY_50MS
;    MOVLW   .100	    ; 1US 
;    MOVWF   DELAY2
;    CALL    DELAY_500US
;    DECFSZ  DELAY2	    ; DECREMENTA CONT1
;    GOTO    $-2		    ; IR A LA POSICION DEL PC - 1
;    RETURN
;    
;DELAY_500US
;    MOVLW   .250	    ; 1US 
;    MOVWF   DELAY1	    
;    DECFSZ  DELAY1	    ; DECREMENTA CONT1
;    GOTO    $-1		    ; IR A LA POSICION DEL PC - 1
;    RETURN
;*******************************************************************************
    END