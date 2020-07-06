;*********************************************************************************************************
; Código correspondiente al ejercicio planteado en el Trabajo Práctico 4 utilizando resistencias pull-up
; internas del puerto D.
;
; Alumno: Reigada Maximiliano Daniel
; Padrón: 100565
;*********************************************************************************************************

.INCLUDE "m328pdef.inc"

.DEF AUX=R16
.DEF CONTADOR=R17

.CSEG
.ORG 0X0000
		RJMP	config

.ORG INT0addr
		RJMP	isr_int0

.ORG INT_VECTORS_SIZE

config:											;Inicializo el SP al final de la RAM
		LDI		AUX, HIGH(RAMEND)				;Cargo el SPH
		OUT		SPH, AUX			
		LDI		AUX, LOW(RAMEND)				;Cargo el SPL
		OUT		SPL, AUX

		LDI		AUX, 0XFF						
		OUT		DDRB, AUX						;Declaro al puerto B como salida
		LDI		AUX, 0X00							
		OUT		PORTB, AUX						;Inicializo al puerto B en 0X00


		LDI		AUX, 0X00						
		OUT		DDRD, AUX						;Declaro al puerto D como entrada
		LDI		AUX, 0XFF	
		OUT		PORTD, AUX						;Activo las resistencias pull-up del puerto D


		LDI		AUX, (1 << ISC01)				;IE0 por flanco descendente
		STS		EICRA, AUX							
		LDI		AUX, (1 << INT0)					
		OUT		EIMSK, AUX						;Habilito IE0

		SEI										;Habilito interrupciones globales
			
main:
		SBI		PORTB, 0						;Enciendo el LED_0 conectado a PB0
		
loop:	
		RJMP	loop

isr_int0:
		LDI		CONTADOR, 5
		CBI		PORTB, 0						;Apago el LED_0 conectado al PB0
		
loop_parpadeo:
		SBI		PORTB, 1						;Enciendo el LED_1 conectado a PB1
		RCALL	retardo_1000ms
		CBI		PORTB, 1						;Apago el LED_1 conectado al PB1
		RCALL	retardo_1000ms

		DEC		CONTADOR
		BRNE	loop_parpadeo					;Si LED_1 no parpadeo 5 veces, vuelvo a repetir el ciclo

		SBI		PORTB, 0						;Enciendo el LED_0 conectado a PB0
		RETI

;*****************************************************************************************************
;						Retardo de 1000ms calculado con un cristal de 16MHz
;El loop interno se debe ejecutar un numero X de veces para que el tiempo total sea 1000ms.
;Considerando los ciclos de máquina que conlleva cada instrucción ejecutada:
;1000ms=(1/16MHz)*(1+X*160004-1+4) ----> X=100
;*****************************************************************************************************
retardo_1000ms:
		CLR     R18								;1 CM
loop_retardo_1000ms:
		RCALL   retardo_10ms					;160000 CM
		INC     R18								;1 CM
		CPI     R18, 100						;1 CM
		BRNE    loop_retardo_1000ms				;2 CM
												;1 CM (BRNE conlleva 1CM cuando R18=100)
		RET										;4 CM                            



;*****************************************************************************************************
;						Retardo de 10ms calculado con un cristal de 16MHz
;El loop interno se debe ejecutar un numero X de veces para que el tiempo total sea 10ms.
;Considerando los ciclos de máquina que conlleva cada instrucción ejecutada:
;10ms=(1/16MHz)*(1+X*804-1+4) ----> X=199
;*****************************************************************************************************
retardo_10ms:
		CLR     R19								;1 CM
loop_retardo_10ms:
		RCALL   retardo_50us					;800 CM
		INC     R19								;1 CM 
		CPI     R19, 199						;1 CM
		BRNE    loop_retardo_10ms				;2 CM
												;1 CM (BRNE conlleva 1CM cuando R19=199)
		RET										;4 CM                            



;*****************************************************************************************************
;						Retardo de 50us calculado con un cristal de 16MHz
;El loop interno se debe ejecutar un numero X de veces para que el tiempo total sea 50us.
;Considerando los ciclos de máquina que conlleva cada instrucción ejecutada:
;50us=(1/16MHz)*(1+X*4-1+4) ----> X=199
;*****************************************************************************************************
retardo_50us:
		CLR     R20								;1 CM
loop_retardo_50us:
		INC     R20								;1 CM
		CPI     R20, 199						;1 CM
		BRNE    loop_retardo_50us				;2 CM	
												;1 CM (BRNE conlleva 1CM cuando R20=199)
		RET										;4 CM				