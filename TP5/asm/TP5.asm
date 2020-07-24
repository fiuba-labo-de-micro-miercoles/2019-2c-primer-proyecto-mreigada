;****************************************************************************************************************
; Código correspondiente al ejercicio planteado en el Trabajo Práctico 5.
;
; Alumno: Reigada Maximiliano Daniel
; Padrón: 100565
;****************************************************************************************************************

.INCLUDE "m328pdef.inc"

.DEF AUX=R16

.CSEG
.ORG 0X0000
		RJMP	config

.ORG ADCCaddr	
		RJMP	isr_adc

.ORG INT_VECTORS_SIZE

config:																												
		LDI		AUX, HIGH(RAMEND)				;Inicializo el SP al final de la RAM
		OUT		SPH, AUX			
		LDI		AUX, LOW(RAMEND)							
		OUT		SPL, AUX

		LDI		AUX, 0X00						;Declaro al puerto C como entrada
		OUT		DDRC, AUX						
			
		LDI		AUX, 0XFF						;Declaro al puerto B como salida
		OUT		DDRB, AUX						

		LDI		AUX, 0XAF						;ADSCRA: 0b10101111 -> Habilito el ADC, el disparo automático, la interrupción de
		STS		ADCSRA, AUX						;conversión y seteo el prescaler en 128 para no superar la máxima velocidad de conversión

		LDI		AUX, 0X62						;ADMUX: 0b01100010 -> Configuro como tensión de referencia externa la del pin AVCC,
		STS		ADMUX, AUX						;ajusto el resultado a izquierda y selecciono PA2 como canal de entrada analógico

		SEI										;Habilito interrupciones globales	

main:
		LDS		AUX, ADCSRA							
		ORI		AUX, (1<<ADSC)
		STS		ADCSRA, AUX						;Inicio conversión poniendo al bit ADSC en 1
		
end:	
		RJMP	end

isr_adc:
		LDS		AUX, ADCH						;Cargo en AUX el resultado de la conversión total dividido por 4

		LSR		AUX								;Divido el anterior valor por 4 nuevamente para poder representarlo mediante 6 bits
		LSR		AUX

		OUT		PORTB, AUX						;Al resultado anterior, lo muestro por el puerto B

		RETI