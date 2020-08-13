;*********************************************************************************************
; Código correspondiente al ejercicio planteado en el Trabajo Práctico 7.
;
; Alumno: Reigada Maximiliano Daniel
; Padrón: 100565
;*********************************************************************************************

.INCLUDE "m328pdef.inc"

.DEF AUX=R16

.CSEG
.ORG 0X0000
		RJMP	config


.ORG INT_VECTORS_SIZE

config:																												
		LDI		AUX, HIGH(RAMEND)					;Inicializo el SP al final de la RAM.
		OUT		SPH, AUX			
		LDI		AUX, LOW(RAMEND)							
		OUT		SPL, AUX

		LDI		AUX, 0X00							;Declaro al puerto D como entrada.
		OUT		DDRD, AUX		

		LDI		AUX, 0XFF							;Declaro al puerto B como salida.
		OUT		DDRB, AUX		
			
		LDI		AUX, (1 << COM1A1 | 1 << WGM10)		;Configuro el timer1 en modo PWM rápido de 
		STS     TCCR1A, AUX							;8 bits y seteo al clock sin prescaler.

		LDI		AUX, (1 << WGM12 | 1 << CS10)
		STS     TCCR1B, AUX 

main:
		SBIC	PIND, 0								;Si PIND0=1, incremento el ancho de pulso.
		RCALL	incrementar_PW

		SBIC	PIND, 1								;Si PIND1=1, decremento el ancho de pulso.
		RCALL	decrementar_PW

		RCALL	retardo								;Ejecuto un retardo de aproximadamente 16ms para que
													;la transición de los estados del LED sea visible.
		RJMP	main


incrementar_PW:
		LDS		AUX, OCR1AL	
		CPI		AUX, 0XFF							;Si OCR1AL=255 retorno porque el ancho de pulso ya llegó  
		BREQ	retorno_inc							;a su máximo y no es posible seguir incrementándolo.

		INC		AUX
		STS		OCR1AL, AUX

retorno_inc:
		RET

decrementar_PW:
		LDS		AUX, OCR1AL							;Si OCR1AL=0 retorno porque el ancho de pulso ya llegó 
		CPI		AUX, 0X00							;a su mínimo y no es posible seguir decrementándolo.
		BREQ	retorno_dec

		DEC		AUX
		STS		OCR1AL, AUX

retorno_dec:
		RET				
		
retardo:			
		LDI		AUX, 0X00							;Me aseguro de iniciar el registro TCNT0 en 0.
		OUT		TCNT0, AUX

		LDI		AUX, (1 << CS02 | 1 << CS00)		;Configuro el timer0 en modo normal
		OUT     TCCR0B, AUX							;y seteo al clock con prescaler 1024.
						
loop_retardo:
		IN		AUX, TIFR0							;En caso de que se active el flag de overflow 
		SBRS	AUX, TOV0							;del timer0, esquivo la próxima instrucción.
		RJMP	loop_retardo

		LDI		AUX, 0X00
		OUT		TCCR0B, AUX							;Desactivo el timer0.
		LDI		AUX, (1<<TOV0)
		OUT		TIFR0, AUX							;Limpio el flag de overflow del timer0.
		
		RET			