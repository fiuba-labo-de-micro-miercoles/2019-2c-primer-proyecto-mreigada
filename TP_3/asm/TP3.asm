;**********************************************************************************
; Rotación en encendido de leds conectados al PORTB
;
; Alumno: Reigada Maximiliano Daniel
; Padrón: 100565
;**********************************************************************************	

.include "m328pdef.inc"

.cseg
.org 0x0000					    
			 rjmp main

.org INT_VECTORS_SIZE

main:
										;Se inicializa el Stack Pointer al final de la RAM 
	ldi R16, HIGH(RAMEND)				;Carga el SPH
	out SPH, R16				
	ldi R16, LOW(RAMEND)				;Carga el SPL
	out SPL, R16
										;Se configura el puerto B
	ldi R16, 0xFF				
	out DDRB, R16						;Configura al puerto B como salida			
	ldi R22,0X01		
										;Se rota el led encendido a izquierda
desplazar_led_izquierda:	
	out		PORTB, R22			    
	rcall	retardo_100ms
	lsl		R22			
	cpi		R22,0X20			
    brne    desplazar_led_izquierda		;Se vuelve a desplazar hasta que R22=0X20
	
										;Se rota el led encendido a derecha
desplazar_led_derecha:
	out		PORTB, R22			    
	rcall	retardo_100ms
	lsr		R22			
	cpi		R22,0X01			
    brne    desplazar_led_derecha

	jmp		desplazar_led_izquierda		;Se vuelve a desplazar hasta que R22=0X01



;******************************************************************************************
;						Retardo de 100ms calculado con un cristal de 16MHz
;El loop interno se debe ejecutar un numero X de veces para que el tiempo total sea 100ms.
;Considerando los ciclos de máquina que conlleva cada instrucción ejecutada:
;100ms=(1/16MHz)*(1+X*160004-1+4) ----> X=10
;******************************************************************************************
retardo_100ms:
    eor     R18, R18				;1 CM
loop_retardo_100ms:
    rcall   retardo_10ms			;160000 CM
    inc     R18						;1 CM
    cpi     R18,10					;1 CM
    brne    loop_retardo_100ms		;2 CM
									;1 CM (brne conlleva 1CM cuando R18=100)
    ret								;4 CM                            



;****************************************************************************************
;						Retardo de 10ms calculado con un cristal de 16MHz
;El loop interno se debe ejecutar un numero X de veces para que el tiempo total sea 10ms.
;Considerando los ciclos de máquina que conlleva cada instrucción ejecutada:
;10ms=(1/16MHz)*(1+X*804-1+4) ----> X=199
;****************************************************************************************
retardo_10ms:
    eor     R19, R19                ;1 CM
loop_retardo_10ms:
    rcall   retardo_50us            ;800 CM
    inc     R19                     ;1 CM 
    cpi     R19,199                 ;1 CM
    brne    loop_retardo_10ms		;2 CM
									;1 CM (brne conlleva 1CM cuando R19=199)
    ret								;4 CM                            



;****************************************************************************************
;						Retardo de 50us calculado con un cristal de 16MHz
;El loop interno se debe ejecutar un numero X de veces para que el tiempo total sea 50us.
;Considerando los ciclos de máquina que conlleva cada instrucción ejecutada:
;50us=(1/16MHz)*(1+X*4-1+4) ----> X=199
;****************************************************************************************
retardo_50us:
    eor     R20, R20				;1 CM
loop_retardo_50us:
    inc     R20						;1 CM
    cpi     R20,199					;1 CM
    brne    loop_retardo_50us		;2 CM	
									;1 CM (brne conlleva 1CM cuando R20=199)
    ret								;4 CM
