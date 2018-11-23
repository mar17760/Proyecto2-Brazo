;*******************************************************************************
;                                                                              *
;    Filename:	    Brazo-PICOnly.asm					       *
;    Date:	    noviembre, 2018					       *
;    Autors:	    Jose Pablo De Leon					       *
;		    Jose Pablo Marroquin				       *
;    Description:   Joystick 1 reading with AN5 and AN6,			       *
;	    X+ increments VAL1 (up to 255), X- decrements VAL1 (down to 0),  *
;	    Y+ increments VAL2 (up to 255), Y- decrements VAL2 (down to 0).  *
;		    Joystick 2 reading with AN and AN,			       *
;	    X+ increments VAL3 (up to 255), X- decrements VAL3 (down to 0),  *
;	    Y+ increments VAL4 (up to 255), Y- decrements VAL4 (down to 0).  *
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
DIF_T		RES 1		; VARIABLE PARA CONTAR DELTAS DE TIEMPO
ADCX1		RES 1		; VARIABLE DE VRX JOYSTICK 1
ADCY1		RES 1		; VARIABLE DE VRY JOYSTICK 1
ADCX2		RES 1		; VARIABLE DE VRX JOYSTICK 2
ADCY2		RES 1		; VARIABLE DE VRY JOYSTICK 2
VAL1		RES 1		; VARIABLE MANIPULADA CON VRX JOYSTICK 1
VAL2		RES 1		; VARIABLE MANIPULADA CON VRY JOYSTICK 1
VAL3		RES 1		; VARIABLE MANIPULADA CON VRX JOYSTICK 2
VAL4		RES 1		; VARIABLE MANIPULADA CON VRY JOYSTICK 2
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
    BTFSC   INTCON, T0IF
    CALL    INT_TMR0
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
;    BSF	    ANSEL,  4
    BSF	    ANSEL,  5
    BSF	    ANSEL,  6
    BSF	    ANSEL,  7	; ANS<4:7> AS ANALOG INPUTS
    
    BANKSEL TRISA
    CLRF    TRISA	; PORTA AS OUTPUT (LEDS REFERENCIA)
    CLRF    TRISB	; PORTB AS OUTPUT (LEDS REFERENCIA)
    CLRF    TRISC	; PORTC AS OUTPUT
    CLRF    TRISD	; PORTD AS OUTPUT
    CLRF    TRISE
;    BSF	    TRISA,  RA5 ; PIN 5 PORTA AS INPUT
    BSF	    TRISE,  RE0	; PINS <0:2> PORTE AS INPUTS
    BSF	    TRISE,  RE1	; LECTURA DE VOLTAJES ANALÓGICOS
    BSF	    TRISE,  RE2

;    BSF	    OSCCON, 6	; F_osc = 1 MHZ, INTERNAL OSCILATOR
;    BCF	    OSCCON, 5
;    BCF	    OSCCON, 4
    
    CALL    CONFIG_ADC
    CALL    CONFIG_TMR0
    
    BANKSEL PORTA
    CLRF    PORTA
    CLRF    PORTB
    CLRF    PORTC
    CLRF    PORTD
    CLRF    PORTE
    CLRF    ADCX1
    CLRF    ADCY1
    CLRF    ADCX2
    CLRF    ADCY2
    CLRF    VAL1
    CLRF    VAL2
    CLRF    VAL3
    CLRF    VAL4
    CLRF    DIF_T
;*******************************************************************************
LOOP:
;JS1_X:
;    BCF ADCON0, CHS3		; AN4
;    BSF ADCON0, CHS2
;    BCF ADCON0, CHS1
;    BCF ADCON0, CHS0
;    CALL    DELAY_500US		; DELAY    
;    BSF	    ADCON0, GO		; EMPIEZA CONVERSIÓN
;CHECKADCX1:
;    BTFSC   ADCON0, GO		; ¿TERMINÓ CONVERSIÓN?
;    GOTO    CHECKADCX1		; NO -> VUELVE A REVISAR
;    MOVF    ADRESH, W		; SÍ -> MUESTRA EL VALOR
;    MOVWF   ADCX1		; MUEVE ADRESH A VARIABLE
;    BCF	    PIR1,   ADIF	; BORRAR BANDERA DE ADC
;;T0X1:
;    MOVLW   .103	    ; LÍMITE 2
;    SUBWF   ADCX1,  W	    ; REVISAR SI ADCX1 < 103 (EJE X1+)
;    BTFSC   STATUS, C	    ; ¿ESTÁ ADCX1 EN PRIMER INTERVALO (RESULTADO NEGATIVO)?
;    GOTO    T1X1	    ; NO -> REVISA SI ADCX1 ESTÁ EN SIGUIENTE INTERVALO
;    MOVF    VAL1,   W	    ; SÍ -> REVISA SI TODAVÍA PUEDE INCREMENTAR VAL1
;    XORLW   0FFh	    ; COMPARACIÓN CON LÍMITE 4
;    BTFSC   STATUS, Z	    ; ¿PUEDE INCREMENTARSE VAL1 (ES MENOR QUE LIMITE)?
;    GOTO    T1X1	    ; NO -> REVISA SI ADCX1 ESTÁ EN SIGUIENTE INTERVALO
;    INCF    VAL1,   F	    ; SÍ -> INCREMENTA VAL1,
;    GOTO    JS1_Y	    ; Y REVISA SIGUIENTE EJE
;T1X1:
;    MOVLW   .163	    ; LÍMITE 3
;    SUBWF   ADCX1,  W	    ; REVISAR SI ADCX1 > 163 (EJE X1-)
;    BTFSS   STATUS, C	    ; ¿ESTÁ EN EL TERCER INTERVALO (RESULTADO POSITIVO)?
;    GOTO    JS1_Y	    ; NO -> REVISA SIGUIENTE EJE
;    MOVF    VAL1,   W	    ; SÍ -> REVISA SI TODAVÍA PUEDE DECREMENTAR VAL1
;    XORLW   .0		    ; COMPARACIÓN CON LÍMITE 1
;    BTFSS   STATUS, Z	    ; ¿PUEDE DECREMENTARSE VAL1?
;    DECF    VAL1,   F	    ; SÍ -> DECREMENTA VAL1
;			    ; NO -> NO CAMBIA VALOR EN VAL1
;JS1_Y:
;    BCF ADCON0, CHS3		; AN5
;    BSF ADCON0, CHS2
;    BCF ADCON0, CHS1
;    BSF ADCON0, CHS0
;    CALL    DELAY_500US		; DELAY    
;    BSF	    ADCON0, GO		; EMPIECE LA CONVERSIÓN
;CHECKADCY1:
;    BTFSC   ADCON0, GO		; ¿TERMINÓ CONVERSIÓN?
;    GOTO    CHECKADCY1		; NO -> VUELVE A REVISAR
;    MOVF    ADRESH, W		; SÍ -> MUESTRA EL VALOR
;    MOVWF   ADCY1		; MUEVE ADRESH A VARIABLE
;    BCF	    PIR1, ADIF		; BORRAR BANDERA DE ADC
;;T0Y1:
;    MOVLW   .109	    ; LÍMITE 2
;    SUBWF   ADCY1,  W	    ; REVISAR SI ADCY1 < 109 (EJE Y1+)
;    BTFSC   STATUS, C	    ; ¿ESTÁ EN EL PRIMER INTERVALO (RESULTADO NEGATIVO)?
;    GOTO    T1Y1	    ; NO -> REVISA SI ADCY1 ESTÁ EN SIGUIENTE INTERVALO
;    MOVF    VAL2,   W	    ; SÍ -> REVISA SI TODAVÍA PUEDE INCREMENTAR VAL2
;    XORLW   0FFh	    ; COMPARACIÓN CON LÍMITE 4
;    BTFSC   STATUS, Z	    ; ¿PUEDE INCREMENTARSE VAL2?
;    GOTO    T1Y1	    ; NO -> REVISA SI ADCY1 ESTÁ EN SIGUIENTE INTERVALO
;    INCF    VAL2,   F	    ; SÍ -> INCREMENTA VAL2;
;    GOTO    JS2_X	    ; Y REVISA SIGUIENTE EJE
;T1Y1:
;    MOVLW   .169	    ; LÍMITE 3
;    SUBWF   ADCY1,  W	    ; REVISAR SI ADCY1 > 169 (EJE Y1-)
;    BTFSS   STATUS, C	    ; ¿ESTÁ EN EL TERCER INTERVALO (RESULTADO POSITIVO)?
;    GOTO    JS2_X	    ; NO -> REVISA SIGUIENTE EJE
;    MOVF    VAL2,   W	    ; SÍ -> REVISA SI TODAVÍA PUEDE DECREMENTAR VAL2
;    XORLW   .0		    ; COMPARACIÓN CON LÍMITE 1
;    BTFSS   STATUS, Z	    ; ¿PUEDE DECREMENTARSE VAL2?
;    DECF    VAL2,   F	    ; SÍ -> DECREMENTA VAL2
;			    ; NO -> NO CAMBIA VALOR EN VAL2
JS2_X:
    BCF ADCON0, CHS3		; AN6
    BSF ADCON0, CHS2
    BSF ADCON0, CHS1
    BCF ADCON0, CHS0
    CALL    DELAY_500US		; DELAY    
    BSF	    ADCON0, GO		; EMPIEZA CONVERSIÓN
CHECKADCX2:
    BTFSC   ADCON0, GO		; ¿TERMINÓ CONVERSIÓN?
    GOTO    CHECKADCX2		; NO -> VUELVE A REVISAR
    MOVF    ADRESH, W		; SÍ -> MUESTRA EL VALOR
    MOVWF   ADCX2		; MUEVE ADRESH A VARIABLE
    BCF	    PIR1,   ADIF	; BORRAR BANDERA DE ADC
;T0X2:
    MOVLW   .121	    ; LÍMITE 2
    SUBWF   ADCX2,  W	    ; REVISAR SI ADCX2 < 121 (EJE X2+)
    BTFSC   STATUS, C	    ; ¿ESTÁ ADCX2 EN PRIMER INTERVALO (RESULTADO NEGATIVO)?
    GOTO    T1X2	    ; NO -> REVISA SI ADCX2 ESTÁ EN SIGUIENTE INTERVALO
    MOVF    VAL3,   W	    ; SÍ -> REVISA SI TODAVÍA PUEDE INCREMENTAR VAL3
    XORLW   0FFh	    ; COMPARACIÓN CON LÍMITE 4
    BTFSC   STATUS, Z	    ; ¿PUEDE INCREMENTARSE VAL3 (ES MENOR QUE LIMITE)?
    GOTO    T1X2	    ; NO -> REVISA SI ADCX2 ESTÁ EN SIGUIENTE INTERVALO
    INCF    VAL3,   F	    ; SÍ -> INCREMENTA VAL3,
    GOTO    JS2_Y	    ; Y REVISA SIGUIENTE EJE
T1X2:
    MOVLW   .181	    ; LÍMITE 3
    SUBWF   ADCX2,  W	    ; REVISAR SI ADCX2 > 181 (EJE X2-)
    BTFSS   STATUS, C	    ; ¿ESTÁ EN EL TERCER INTERVALO (RESULTADO POSITIVO)?
    GOTO    JS2_Y	    ; NO -> REVISA SIGUIENTE EJE
    MOVF    VAL3,   W	    ; SÍ -> REVISA SI TODAVÍA PUEDE DECREMENTAR VAL3
    XORLW   .0		    ; COMPARACIÓN CON LÍMITE 1
    BTFSS   STATUS, Z	    ; ¿PUEDE DECREMENTARSE VAL3?
    DECF    VAL3,   F	    ; SÍ -> DECREMENTA VAL3
			    ; NO -> NO CAMBIA VALOR EN VAL3
JS2_Y:
    BCF ADCON0, CHS3		; AN7
    BSF ADCON0, CHS2
    BSF ADCON0, CHS1
    BSF ADCON0, CHS0
    CALL    DELAY_500US		; DELAY    
    BSF	    ADCON0, GO		; EMPIECE LA CONVERSIÓN
CHECKADCY2:
    BTFSC   ADCON0, GO		; ¿TERMINÓ CONVERSIÓN?
    GOTO    CHECKADCY2		; NO -> VUELVE A REVISAR
    MOVF    ADRESH, W		; SÍ -> MUESTRA EL VALOR
    MOVWF   ADCY2		; MUEVE ADRESH A VARIABLE
    BCF	    PIR1, ADIF		; BORRAR BANDERA DE ADC
;T0Y2:
    MOVLW   .105	    ; LÍMITE 2
    SUBWF   ADCY2,  W	    ; REVISAR SI ADCY2 < 105 (EJE Y2+)
    BTFSC   STATUS, C	    ; ¿ESTÁ EN EL PRIMER INTERVALO (RESULTADO NEGATIVO)?
    GOTO    T1Y2	    ; NO -> REVISA SI ADCY2 ESTÁ EN SIGUIENTE INTERVALO
    MOVF    VAL4,   W	    ; SÍ -> REVISA SI TODAVÍA PUEDE INCREMENTAR VAL4
    XORLW   0FFh	    ; COMPARACIÓN CON LÍMITE 4
    BTFSC   STATUS, Z	    ; ¿PUEDE INCREMENTARSE VAL2?
    GOTO    T1Y2	    ; NO -> REVISA SI ADCY2 ESTÁ EN SIGUIENTE INTERVALO
    INCF    VAL4,   F	    ; SÍ -> INCREMENTA VAL4,
    GOTO    JS1_X	    ; Y REVISA SIGUIENTE EJE
T1Y2:
    MOVLW   .165	    ; LÍMITE 3
    SUBWF   ADCY2,  W	    ; REVISAR SI ADCY2 > 165 (EJE Y2-)
    BTFSS   STATUS, C	    ; ¿ESTÁ EN EL TERCER INTERVALO (RESULTADO POSITIVO)?
    GOTO    JS1_X	    ; NO -> REVISA SIGUIENTE EJE
    MOVF    VAL4,   W	    ; SÍ -> REVISA SI TODAVÍA PUEDE DECREMENTAR VAL4
    XORLW   .0		    ; COMPARACIÓN CON LÍMITE 1
    BTFSS   STATUS, Z	    ; ¿PUEDE DECREMENTARSE VAL4?
    DECF    VAL4,   F	    ; SÍ -> DECREMENTA VAL4
			    ; NO -> NO CAMBIA VALOR EN VAL4
JS1_X:
;    MOVF    VAL3,   W
;    MOVWF   PORTA
    MOVF    VAL4,   W
    MOVWF   PORTB
    GOTO    LOOP
;*******************************************************************************
; SUBRUTINA DE CONFIGURACIÓN ADC
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
; SUBRUTINA DE CONFIGURACIÓN TIMER0
;*******************************************************************************
CONFIG_TMR0
    BANKSEL TRISA
    BCF	    OPTION_REG, T0CS
    BCF	    OPTION_REG, PSA	; Asignación de Prescaler al TMR0
    BSF	    OPTION_REG, PS2	; PRESCALER 1:128
    BSF	    OPTION_REG, PS1
    BCF	    OPTION_REG, PS0
    BANKSEL PORTA
    MOVLW   .244		; N=241
    MOVWF   TMR0
    RETURN
;*******************************************************************************
; SUBRUTINA PARA INTERRUPCIÓN DEL TMR0
;*******************************************************************************
INT_TMR0
    MOVLW   .244		; N=241
    MOVWF   TMR0
    BCF	    INTCON, T0IF

    INCF    DIF_T,  F	    ; INCREMENTA CONTADOR DE DIFERENCIALES DE TIEMPO
;;PWM0:
;    BSF	    PORTD,  RD0
;    MOVF    VAL1,   W	    ; REVISAR SI ES IGUAL QUE DIF_T
;    SUBWF   DIF_T,  W
;    BTFSS   STATUS, C	    ; ¿VAL1 = DIF_T?
;    BCF	    PORTD,  RD0	    ; SÍ -> APAGA EL PIN
;;PWM1:			    ; NO -> CONTINUA ENCENDIDO
;    BSF	    PORTD,  RD1
;    MOVF    VAL2,   W	    ; REVISAR SI ES IGUAL QUE DIF_T
;    SUBWF   DIF_T,  W
;    BTFSS   STATUS, C	    ; ¿VAL1 = DIF_T?
;    BCF	    PORTD,  RD1	    ; SÍ -> APAGA EL PIN
;;PWM2:			    ; NO -> CONTINUA ENCENDIDO
;    BSF	    PORTD,  RD2
;    MOVF    VAL3,   W	    ; REVISAR SI ES IGUAL QUE DIF_T
;    SUBWF   DIF_T,  W
;    BTFSS   STATUS, C	    ; ¿VAL1 = DIF_T?
;    BCF	    PORTD,  RD2	    ; SÍ -> APAGA EL PIN
;PWM3:			    ; NO -> CONTINUA ENCENDIDO
    BSF	    PORTD,  RD3
    MOVF    VAL4,   W	    ; REVISAR SI ES IGUAL QUE DIF_T
    SUBWF   DIF_T,  W
    BTFSS   STATUS, C	    ; ¿VAL1 = DIF_T?
    BCF	    PORTD,  RD3	    ; SÍ -> APAGA EL PIN
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
