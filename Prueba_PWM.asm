;*******************************************************************************
;                                                                              *
;    Filename:	    Pruebas.asm						       *
;    Date:	    noviembre, 2018					       *
;    Autors:	    Jose Pablo De Leon					       *
;		    Jose Pablo Marroquin				       *
;    Description:   PWM using T with TMR0 (20MS)			       *
;		    Delta T_ON with TMR1 (4US)				       *
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
TONVAR		RES 1		; VARIABLE PARA CONTAR DELTAS T_ON, ENTRE 0 Y 1MS, DESPUÉS DE 1MS ON
VAL1X		RES 1		; VARIABLE DE ADC MANIPULADA CON JOYSTICK1 - X
VAL1Y		RES 1		; VARIABLE DE ADC MANIPULADA CON JOYSTICK1 - Y
VAL2X		RES 1		; VARIABLE DE ADC MANIPULADA CON JOYSTICK2 - X
VAL2Y		RES 1		; VARIABLE DE ADC MANIPULADA CON JOYSTICK2 - Y
DELAY1		RES 1		; VARIABLE PARA DELAY1
DELAY2		RES 1		; VARIABLE PARA DELAY2
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
;    BTFSC   INTCON, T0IF
;    CALL    INT_TMR0
    BTFSS   INTCON, T0IF
    GOTO    INT1
    BSF	    PORTD, RD3
    MOVLW   .50
    MOVWF   TONMIN
    MOVLW   .50		; VALOR ENTRE 0 Y 50
;    MOVF    VAL1,   W
    MOVWF   TONVAR

INT1:
;    BTFSC   PIR1,   TMR1IF
;    CALL    INT_TMR1
    BTFSS   PIR1,   TMR1IF
    GOTO    POP
    DECFSZ  TONMIN, F
    GOTO    POP
    DECFSZ  TONVAR, F
    GOTO    POP
    BCF	    PORTD,  RD3
    
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
    CLRF    PORTB
    CLRF    PORTC
    CLRF    PORTD
    CLRF    PORTE
    CLRF    TONVAR
    CLRF    TONMIN
;*******************************************************************************
LOOP:

    
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
    MOVLW   .100		; N = 100 d = 0064 h
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
    MOVLW   0FFh		; N = 65496 d = 0FFD8 h
    MOVWF   TMR1H
    MOVLW   0D8h
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
;;*******************************************************************************
;; SUBRUTINA PARA TMR0
;;*******************************************************************************
;INT_TMR0
;    MOVLW   .254		; N=254
;    MOVWF   TMR0
;    BCF	    INTCON, T0IF
;    
;;    CALL    
;    RETURN
;;*******************************************************************************
;; SUBRUTINA PARA TMR1
;;*******************************************************************************
;INT_TMR1
;    MOVLW   00Bh		; N = 3036 d = 0BDC h
;    MOVWF   TMR1H
;    MOVLW   0DCh
;    MOVWF   TMR1L
;    BCF	    PIR1,   TMR1IF
;    
;;    CALL    
;    RETURN
;;*******************************************************************************
;; SUBRUTINA PARA 
;;*******************************************************************************

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