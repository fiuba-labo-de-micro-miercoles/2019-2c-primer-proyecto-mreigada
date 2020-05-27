;***********************************************************************************
;Encendido de un led ubicado en PORTB.2, mediante botón ubicado en PORTB.0
;
; Alumno: Reigada Maximiliano Daniel
; Padrón: 100565
;***********************************************************************************

.INCLUDE "M328PDEF.INC"

.EQU PUERTO_SALIDA = PORTB
.EQU PUERTO_ENTRADA = PINB
.EQU CONF_PUERTO = DDRB
.EQU BOTON = 0
.EQU LED = 2

.CSEG
.ORG 0x0000	
	 JMP MAIN

.ORG INT_VECTORS_SIZE 

MAIN:
								; Se inicializan puertos 
	LDI R18, 0x24
	OUT CONF_PUERTO, R18
								; Se controla el LED
CONTROLAR_LED:
	CALL DETECTAR_ALTO			; Se espera hasta que el botón en el puerto de entrada sea presionado
	SBI	 PUERTO_SALIDA, LED   
	CALL DETECTAR_BAJO			; Se espera hasta que el botón en el puerto de entrada deje de estar presionado
	CBI	 PUERTO_SALIDA, LED   
	JMP  CONTROLAR_LED			; Se reinicia el ciclo de control
	

	
								; Detecta flancos bajos en pin conectado al botón
DETECTAR_BAJO: 
	SBIC PUERTO_ENTRADA, BOTON
	JMP  DETECTAR_BAJO
	RET

								; Detecta flancos altos en pin conectado al botón
DETECTAR_ALTO:
	SBIS PUERTO_ENTRADA, BOTON
	JMP  DETECTAR_ALTO
	RET