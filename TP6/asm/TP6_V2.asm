;****************************************************************************************************************
; C�digo correspondiente al ejercicio planteado en el Trabajo Pr�ctico 6.
;
; Alumno: Reigada Maximiliano Daniel
; Padr�n: 100565
;****************************************************************************************************************

.INCLUDE "m328pdef.inc"

.DEF AUX=R16
.DEF REG_CMP=R17

.CSEG
.ORG 0X0000
		RJMP	config

.ORG OVF1addr	
		RJMP	isr_timer1

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

		LDI		AUX, (1 << TOIE1)					;Habilito interrupci�n de timer1 por overflow.
		STS		TIMSK1, AUX							
		
		SEI											;Habilito interrupciones globales.

main:
		IN		REG_CMP, PIND
		ANDI	REG_CMP, (1 << PIND1 | 1 << PIND0)	;Guardo en REG_CMP el valor de PIND0 y PIND1.

		RCALL	retardo

		IN		AUX, PIND							;Guardo en AUX el valor de PIND0 y PIND1 luego 
		ANDI 	AUX, (1 << PIND1 | 1 << PIND0)		;de esperar un tiempo tras el �ltimo guardado.

		CP		REG_CMP, AUX						;Verifico que las dos muestras sean iguales.
		BRNE	main
		
		RCALL	determinar_parpadeo						
		RJMP	main
							

determinar_parpadeo:		
		CPI		AUX, (1 << PIND1 | 0 << PIND0)
		BREQ	clock_64

		CPI		AUX, (0 << PIND1 | 1 << PIND0)
		BREQ	clock_256

		CPI		AUX, (1 << PIND1 | 1 << PIND0)
		BREQ	clock_1024

		LDI		AUX, 0X00							;Como PIND0=0 y PIND1=0, detengo el timer1 y dejo PB0 encendido.
		STS		TCCR1B, AUX
		SBI		PORTB, 0		
		RET
		 
clock_64:										
		LDI		AUX, 0X03							;Como PIND0=0 y PIND1=1, configuro el timer1 para que cuente 
		STS		TCCR1B, AUX							;los pulsos de clock divididos por prescaler 64.
		RET

clock_256:
		LDI		AUX, 0X04							;Como PIND0=1 y PIND1=0, configuro el timer1 para que cuente 
		STS		TCCR1B, AUX							;los pulsos de clock divididos por prescaler 256.
		RET

clock_1024:
		LDI		AUX, 0X05							;Como PIND0=1 y PIND1=1, configuro el timer1 para que cuente 
		STS		TCCR1B, AUX							;los pulsos de clock divididos por prescaler 1024.
		RET
			
isr_timer1:
		SBIC	PORTB, 0							;Si PORTB0=0, salto la pr�xima instrucci�n.
		RJMP	apagar_led

		SBI		PORTB, 0							;Pongo PORTB0 en estado l�gico alto.
		RETI

apagar_led:
		CBI		PORTB, 0							;Pongo PORTB0 en estado l�gico bajo.
		RETI	


retardo:			
		LDI		AUX, 0X00							;Me aseguro de iniciar el registro TCNT0 en 0.
		OUT		TCNT0, AUX

		LDI		AUX, (1 << CS02 | 1 << CS00)		;Configuro el timer0 en modo normal
		OUT     TCCR0B, AUX							;y seteo al clock con prescaler 1024.
						
loop_retardo:
		IN		AUX, TIFR0							;En caso de que se active el flag de overflow 
		SBRS	AUX, TOV0							;del timer0, esquivo la pr�xima instrucci�n.
		RJMP	loop_retardo

		LDI		AUX, 0X00
		OUT		TCCR0B, AUX							;Desactivo el timer0.
		LDI		AUX, (1<<TOV0)
		OUT		TIFR0, AUX							;Limpio el flag de overflow del timer0.
		
		RET		