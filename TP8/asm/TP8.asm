;*********************************************************************************************
; Código correspondiente al ejercicio planteado en el Trabajo Práctico 8.
;
; Alumno: Reigada Maximiliano Daniel
; Padrón: 100565
;*********************************************************************************************

.INCLUDE "m328pdef.inc"

.DEF AUX=R16
.DEF CARACTER=R17
.DEF DATO_IN=R18
.DEF MASK_PIN=R19

.CSEG
.ORG 0X0000
		RJMP	config

.ORG INT_VECTORS_SIZE

config:																												
		LDI		AUX, HIGH(RAMEND)					;Inicializo el SP al final de la RAM.
		OUT		SPH, AUX			
		LDI		AUX, LOW(RAMEND)							
		OUT		SPL, AUX

		LDI		AUX, 0XFE							;Declaro PORTD0 como entrada y el resto como salidas.
		OUT		DDRD, AUX							
			
		LDI		AUX, 0XFF							;Declaro al puerto B como salida.
		OUT		DDRB, AUX						

		LDI		AUX, 0X00							;Configuro el Baud Rate del USART0 en 9600 bps, cargando 
		STS		UBRR0H, AUX							;en UBRR0 el valor 103 por tabla de datasheet.
		LDI		AUX, 0X67				
		STS		UBRR0L, AUX

		LDI		AUX, (1<<UCSZ01) | (1<<UCSZ00)		;Configuro el tamaño de los datos en 8N1.
		STS		UCSR0C, AUX

		LDI		AUX, (1<<RXEN0) | (1<<TXEN0)		;Habilito la recepción y transmisión de datos por puerto serie.
		STS		UCSR0B, AUX

main:
		RCALL	enviar_mensaje						;Envío el mensaje inicial por el puerto serie.

leer_dato:											
		LDS		AUX, UCSR0A							;Entro en loop hasta que se reciba un dato.
		SBRS	AUX, RXC0								
		RJMP	leer_dato

		LDS		DATO_IN, UDR0						;Cuando se recibe un dato, lo cargo en DATO_IN.						
		RCALL	procesar_dato						;Proceso el dato recibido.

		RJMP	leer_dato							;Salto a leer el próximo dato.

.ORG 0X500
MENSAJE_PROG:	.DB "*** Hola Labo de Micro ***", '\n','\n',"Escriba 1, 2, 3 o 4 para controlar los LEDs", '\0'


enviar_mensaje:	
		LDI		ZL, LOW(MENSAJE_PROG<<1)			;Apunto al primer elemento de la tabla en 
		LDI		ZH, HIGH(MENSAJE_PROG<<1)			;memoria del programa con el puntero Z.

cargar_caracter:
		LPM		CARACTER, Z+						
		CPI		CARACTER, '\0'						;En caso de que el carácter sea 0, salto a 
		BREQ	fin_envio							;finalizar la transmisión del mensaje.

enviar_caracter:
		LDS		AUX, UCSR0A						
		SBRS	AUX, UDRE0							;Entro en loop hasta que UDR0 este vacío 
		RJMP	enviar_caracter						;y se pueda enviar el próximo carácter.

		STS		UDR0, CARACTER						;Envío el carácter por el puerto serie.
		RJMP	cargar_caracter

fin_envio:
		RET		


procesar_dato:
		CPI		DATO_IN, 0X01						
		BREQ	seleccionar_LED1

		CPI		DATO_IN, 0X02						
		BREQ	seleccionar_LED2

		CPI		DATO_IN, 0X03						
		BREQ	seleccionar_LED3

		CPI		DATO_IN, 0X04						
		BREQ	seleccionar_LED4

fin_procesamiento:									
		RET

seleccionar_LED1:
		LDI		MASK_PIN, (1<<PORTB1)				;Como DATO_IN=1 ----> MASK_PIN=0b00000010.
		RJMP	alternar_LED

seleccionar_LED2:
		LDI		MASK_PIN, (1<<PORTB2)				;Como DATO_IN=2 ----> MASK_PIN=0b00000100.
		RJMP	alternar_LED

seleccionar_LED3:
		LDI		MASK_PIN, (1<<PORTB3)				;Como DATO_IN=3 ----> MASK_PIN=0b00001000.
		RJMP	alternar_LED

seleccionar_LED4:
		LDI		MASK_PIN, (1<<PORTB4)				;Como DATO_IN=4 ----> MASK_PIN=0b00010000.
		RJMP	alternar_LED

alternar_LED:
		IN		AUX, PORTB							
		EOR		AUX, MASK_PIN						;Aplico una XOR entre MASK_PIN y el valor en PORTB
		OUT		PORTB, AUX							;para solo alternar el valor del pin seleccionado.
		RJMP	fin_procesamiento