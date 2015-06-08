/*
 * Pruebas.asm
 *
 *  Created: 1/31/2015 9:49:46 PM
 *   Author: AlfonsoAndrés
 */ 

// Included header file for target AVR type
.NOLIST
.INCLUDE "usb1286def.inc" // Header for AT90USB1286
.INCLUDE "macro_utils.inc"
.INCLUDE "_Delays.asm"
.INCLUDE "arduino_definitions.inc"
.INCLUDE "arduino_macros_fast.inc"
.INCLUDE "arduino_macros.inc"
.INCLUDE "servo_aux.inc"
.INCLUDE "sistema_disparo.asm"
.LIST
//
// ============================================
//   H A R D W A R E   I N F O R M A T I O N   
// ============================================
//
// [Add all hardware information here]
//
// ============================================
//      P O R T S   A N D   P I N S 
// ============================================
//
// [Add names for hardware ports and pins here]
// Format: .EQU Controlportout = PORTA
//         .EQU Controlportin = PINA
//         .EQU LedOutputPin = PORTA2
#define ledPin 6
#define vccA 3
#define gndA 2
#define vccB 1
#define gndB 0
#define servoPin 14
#define pingPin 13
#define sistemaDisparoPin 15

// Sensores de linea
#define DERECHA A0
#define IZQUIERDA A1
#define CENTRO_IZQUIERDA A2
#define CENTRO_DERECHA A3 

#define EDO_ADELANTE 1
#define EDO_DERECHA 2
#define EDO_IZQUIERDA 3
#define EDO_DETENIDO 4

.EQU varServoUltrasonico = 10
//
// ============================================
//    C O N S T A N T S   T O   C H A N G E 
// ============================================
//
// [Add all constants here that can be subject
//  to change by the user]
// Format: .EQU const = $ABCD
//
// ============================================
//  F I X + D E R I V E D   C O N S T A N T S 
// ============================================
//
// [Add all constants here that are not subject
//  to change or calculated from constants]
// Format: .EQU const = $ABCD
//
// ============================================
//   R E G I S T E R   D E F I N I T I O N S
// ============================================
//
// [Add all register names here, include info on
//  all used registers without specific names]
// Format: .DEF rmp1 = R16
.DEF rmp1 = R16 // Multipurpose register
.DEF rmp2 = R17 // Multipurpose register
.DEF rmp3 = R18 // Multipurpose register
.DEF rmp4 = R19 // Multipurpose register
//
// ============================================
//       S R A M   D E F I N I T I O N S
// ============================================
//
.DSEG
//.ORG  0X0100
varAnalog: .BYTE 2
varPwm: .BYTE 2
tmpLinea: .BYTE 2
valDerecha: .BYTE 2
valIzquierda: .BYTE 2
valCentroDerecha: .BYTE 2
valCentroIzquierda: .BYTE 2
varLedPin: .BYTE 2
estadoActual: .BYTE 2
tot_overflow: .BYTE 2
array_prueba: .BYTE 10
// Format: Label: .BYTE N // reserve N Bytes from Label:
//
// ============================================
//     E E P R O M   D E F I N I T I O N S
// ============================================
//
//
// ============================================
//   R E S E T   A N D   I N T   V E C T O R S
// ============================================
//
.CSEG
.ORG $0000
   	jmp Main // Reset vector
	reti // Int vector 1
	nop
	reti // Int vector 2
	nop
	reti // Int vector 3
	nop
	reti // Int vector 4
	nop
	reti // Int vector 5
	nop
	reti // Int vector 6
	nop
	reti // Int vector 7
	nop
	reti // Int vector 8
	nop
	reti // Int vector 9
	nop
	reti // Int vector 10
	nop
	reti // Int vector 11
	nop
	reti // Int vector 12
	nop
	reti // Int vector 13
	nop
	reti // Int vector 14
	nop
	reti // Int vector 15
	nop
	reti // Int vector 16
	nop
//	jmp TIMER1_COMPA_vect
	reti // Int vector 17
	nop
	reti // Int vector 18
	nop
	reti // Int vector 19
	nop
//	jmp TIMER1_OVF_vect
	reti // Int vector 20
	nop
	reti // Int vector 21
	nop
	reti // Int vector 22
	nop
	jmp TIMER0_OVF_vect
	// reti // Int vector 23
	// nop
	reti // Int vector 24
	nop
	reti // Int vector 25
	nop
	reti // Int vector 26
	nop
	reti // Int vector 27
	nop
	reti // Int vector 28
	nop
//
// ============================================
//     I N T E R R U P T   S E R V I C E S
// ============================================
//
// TIMER1_OVF_vect:
// 	push_all
// 	inc16 tot_overflow
// 	cpi16 tot_overflow, 30
// 	brlt EndTIMER1_OVF_vect
// 		negarBool16 varLedPin
// 		assign16(tot_overflow,0
// 	EndTIMER1_OVF_vect:
// 	pop_all
// 	ret

TIMER0_OVF_vect:
	push_all
	read32 N,timer0_millis_count
	read8 XL,timer0_fract_count

	addi32 N,TIMER0_MILLIS_INC
	addi XL,TIMER0_FRACT_INC // TIMER0_FRACT_INC se almacena en registro rmp1
	cpi XL,FRACT_MAX
	jlt(EndError)
		subi XL,FRACT_MAX
		addi32 N,1
	EndError:

	write8 timer0_fract_count,XL
	write32 timer0_millis_count,N
	inc32 timer0_overflow_count
	pop_all
	reti
//
// ============================================
//     M A I N    P R O G R A M    I N I T
// ============================================
//

// Prueba sensores linea
.MACRO pruebaSensoresLinea
	esNegro16 valIzquierda,IZQUIERDA
	esNegro16 valDerecha,DERECHA
	esNegro16 valCentroIzquierda,CENTRO_IZQUIERDA
	esNegro16 valCentroDerecha,CENTRO_DERECHA
	digitalWrite(vccA,valIzquierda)
	digitalWrite(gndA,valDerecha)
	digitalWrite(vccB,valCentroIzquierda)
	digitalWrite(gndB,valCentroDerecha)
.ENDM

// Prueba controlador de motor
.MACRO pruebaControladorMotor
	adelante
	delay 3000
	retroceso
	delay 3000
	giroRapidoIzquierda
	delay 3000
	giroRapidoDerecha
	delay 3000
	detener
	delay 3000
	giroDerecha
	delay 3000
	detener
	delay 3000
	giroIzquierda
	delay 3000
	detener
	delay 3000
.ENDM

// Control sensor de linea

// params @0 Direccion de memoria, 2 bytes.
// params @1 Pin sensor de linea
.MACRO esNegro16
	analogRead tmpLinea,@1
	cpi16 tmpLinea,513
	brge SalvarNegro
		assign16(@0, 0)
		rjmp EndEsNegro
	SalvarNegro:
		assign16(@0, 1)
	EndEsNegro:
.ENDM

// params @0 Direccion de memoria, 2 bytes.
// params @1 Pin sensor de linea
.MACRO esBlanco16
	analogRead tmpLinea,@1
	cpi16 tmpLinea,513
	brge SalvarBlanco
		assign16(@0, 0)
		rjmp EndEsBlanco
	SalvarBlanco:
		assign16(@0, 1)
	EndEsBlanco:
.ENDM

// Control motor

// params @0 vccPin
// params @1 gndPin
.MACRO motorAdelante
	digitalWritei(@0, HIGHH)
	digitalWritei(@1, LOWW)
.ENDM

.MACRO motorAdelantePwmi
	analogWritei @0,@2
	digitalWritei(@1, LOWW)
.ENDM

// params vccPin
// params gndPin
.MACRO motorDetener
	digitalWritei(@0, LOWW)
	digitalWritei(@1, LOWW)
.ENDM

// params vccPin
// params gndPin
.MACRO motorRetroceso
	digitalWritei(@0, LOWW)
	digitalWritei(@1, HIGHH)
.ENDM

// Control ambos motores

.MACRO adelante
	motorAdelante vccA,gndA
	motorAdelante vccB,gndB
.ENDM

.MACRO detener
	motorDetener vccA,gndA
	motorDetener vccB,gndB
.ENDM

.MACRO retroceso
	motorRetroceso vccA,gndA
	motorRetroceso vccB,gndB
.ENDM

.MACRO giroRapidoDerecha
	motorAdelante vccA,gndA
	motorRetroceso vccB,gndB
.ENDM

.MACRO giroRapidoIzquierda
	motorRetroceso vccA,gndA
	motorAdelante vccB,gndB
.ENDM

.MACRO giroDerecha
	motorAdelante vccA,gndA
	motorDetener vccB,gndB
.ENDM

.MACRO giroIzquierda
	motorDetener vccA,gndA
	motorAdelante vccB,gndB
.ENDM

leerSensoresLinea:
	esNegro16 valIzquierda,IZQUIERDA
	esNegro16 valDerecha,DERECHA
	esNegro16 valCentroIzquierda,CENTRO_IZQUIERDA
	esNegro16 valCentroDerecha,CENTRO_DERECHA
	ret

.MACRO cmpSensoresLinea
	cpi R24,@0
	ldi R23,@1
	cpc XL,R23
	ldi R23,@2
	cpc YL,R23
	ldi R23,@3
	cpc ZL,R23
.ENDM

estadoIzquierda:
	read16 V,valIzquierda
	read16 X,valDerecha
	read16 Y,valCentroIzquierda
	read16 Z,valCentroDerecha
	giroRapidoIzquierda
	ret

estadoAdelante:
	read16 V,valIzquierda
	read16 X,valDerecha
	read16 Y,valCentroIzquierda
	read16 Z,valCentroDerecha
	cmpSensoresLinea 1,1,1,1
		brne PC+8
			assign16(estadoActual, EDO_IZQUIERDA)
			jmp EndEstadoAdelante
		breq EdoAdelante
	cmpSensoresLinea 1,1,0,1
		brne PC+8
			assign16(estadoActual, EDO_IZQUIERDA)
			jmp EndEstadoAdelante
	cmpSensoresLinea 0,1,1,1
		breq EdoAdelante
	cmpSensoresLinea 1,0,1,1
		breq EdoAdelante
	cmpSensoresLinea 1,1,1,0
		breq EdoAdelante
	cmpSensoresLinea 1,1,0,0
		breq EdoAdelante
	cmpSensoresLinea 0,0,0,0
		breq EdoAdelante
		
	rjmp CompGiroDerecha
	EdoAdelante:
		adelante
		rjmp EndEstadoAdelante


	CompGiroDerecha:
	cmpSensoresLinea 1,0,1,0
		breq EdoGiroDerecha
	cmpSensoresLinea 1,0,0,0
		breq EdoGiroDerecha
	cmpSensoresLinea 1,0,1,0
		breq EdoGiroDerecha
	cmpSensoresLinea 0,0,1,1
		breq EdoGiroDerecha
	cmpSensoresLinea 1,0,0,1
		breq EdoGiroDerecha
	rjmp CompGiroIzquierda

	EdoGiroDerecha:
		giroDerecha
		rjmp EndEstadoAdelante

	CompGiroIzquierda:
	cmpSensoresLinea 0,1,0,1
		breq EdoGiroIzquierda
	cmpSensoresLinea 0,0,0,1
		breq EdoGiroIzquierda
	cmpSensoresLinea 0,1,1,0
		breq EdoGiroIzquierda
	cmpSensoresLinea 0,1,0,0
		breq EdoGiroIzquierda
	rjmp EdoDetener
	EdoGiroIzquierda:
		giroIzquierda
		rjmp EndEstadoAdelante
	EdoDetener:
		detener
	EndEstadoAdelante:
	ret

estadoDetenido:
	detener
	ret

actualizar:
	cpi16 estadoActual,EDO_ADELANTE
	brne PC+4
		call estadoAdelante
		rjmp EndSwitchEstado
	cpi16 estadoActual,EDO_DETENIDO
	brne PC+4
		call estadoDetenido
		rjmp EndSwitchEstado
	cpi16 estadoActual,EDO_IZQUIERDA
	brne PC+4
		call estadoIzquierda
		rjmp EndSwitchEstado
	EndSwitchEstado:
	ret

.MACRO pruebaLedPinTimer

.ENDM

InitTimer1ParpadeoLed:
	assign8(TCCR1A, 0) // actualizando InitTeensyInternal
	assign8(TCCR1B, (1<<CS11)) // div 8 prescaler
	assign8(TIMSK1, (1<<TOIE1)) // Habilitar interrupción de desbordamiento
	assign16(TCNT1L, 0) // clear the timer count 
	assign16(tot_overflow, 0)
	ret

InitTimer1Servo1:
	assign8(TCCR1A, 0) 
	// assign8(TCCR1B,(1<<CS11) // div 8 prescaler
	assign8(TCCR1B, (1<<WGM12)|(1 << CS11)) // div 256 prescaler and ctc mode
	assign16(TCNT1L, 0) // clear the timer count 
	// assign16(OCR1AL,62499 // set top
	assign16(OCR1AL, 40000) // set top
	assign8(TIMSK1, (1<<OCIE1A)) // enable the output compare interrupt 
	ret

InitTeensyInternal:
	// Adicional, no propio de la rutina
	long(timer0_overflow_count, 0);
	long(timer0_millis_count, 0);
	byte(timer0_fract_count, 0);
	// Inicio de la verdadera rutina
	cli()
	assign8(CLKPR, 0x80)
	assign8(CLKPR, 0)
	// timer 0, fast pwm mode
	assign8(TCCR0A, (1<<WGM00)|(1<<WGM01))
	assign8(TCCR0B,(1<<CS00)|(1<<CS01)) // div 64 prescaler
	sbi(TIMSK0, TOIE0)
	// timer 1, 8 bit phase correct pwm
	assign8(TCCR1A, (1<<WGM10))
	assign8(TCCR1B, (1<<CS11)) // div 8 prescaler
	// timer 2, 8 bit phase correct pwm
	assign8(TCCR2A, (1<<WGM20))
	assign8(TCCR2B, (1<<CS21)) // div 8 prescaler
	// timer 3, 8 bit phase correct pwm
	assign8(TCCR3A, (1<<WGM30))
	assign8(TCCR3B, (1<<CS31))//  div 8 prescaler
	// ADC
	assign8(ADCSRA, (1<<ADEN) | (ADC_PRESCALER + ADC_PRESCALE_ADJUST))
	assign8(ADCSRB, DEFAULT_ADCSRB)
	assign8(DIDR0, 0)
	sei()
	ret

Main:
// Init stack
	// outiw SP,RAMEND
	ldi rmp1, HIGH(RAMEND) // Init MSB stack
	out SPH,rmp1
	ldi rmp1, LOW(RAMEND) // Init LSB stack
	out SPL,rmp1
// Init Teensy
	rcall InitTeensyInternal
	// rcall InitTimer1ParpadeoLed
	// rcall InitTimer1Servo
	// rcall InitTimer1Servo1
	pinMode(ledPin, OUTPUT)
	pinMode(IZQUIERDA, INPUT)
	pinMode(DERECHA, INPUT)
	pinMode(CENTRO_IZQUIERDA, INPUT)
	pinMode(CENTRO_DERECHA, INPUT)
	pinMode(vccA, OUTPUT)
	pinMode(vccB, OUTPUT)
	pinMode(gndA, OUTPUT)
	pinMode(gndB, OUTPUT)
	assign16(estadoActual, EDO_ADELANTE)
	assign16(varLedPin, 1)

	long(duration, 0)
	long(tiempo_ping, 0)

	Servo(servo_ultrasonido, servoPin)
	//Servo(sist_disparo, 15)
	SistDisparo(sist_disparo, sistemaDisparoPin)
	//pinMode(15, OUTPUT)
	//Servo_write(servo_ultrasonido, 30, 'i')
	//Servo_write(servo_ultrasonido, 90, 'i')
	//Servo_write(disparo, 0, 'i')
	//Servo_write(prueba1, 180, 'i')
	//Servo_write(prueba2, 180, 'i')

//
// ============================================
//         P R O G R A M    L O O P
// ============================================
//
Loop:
	//digitalWritei(ledPin, HIGHH)
	Servo_update(servo_ultrasonido)
	SistDisparo_update(sist_disparo)
	//Servo_update(sist_disparo)
	//Servo_giro_3(sist_disparo, 4, true)
	//SistDisparo_press(sist_disparo)
	//Servo_giro_3(servo_ultrasonido, 4, true)
	
	cpMillis(tiempo_ping, 250, i)
	jlt(EndTiempoPing)
		copy32(tiempo_ping,tiempoEnMilis)
		pinMode(pingPin, OUTPUT);
	  	digitalWritei(pingPin, LOWW);
	  	delayMicroseconds(2);
	  	digitalWritei(pingPin, HIGHH);
	  	delayMicroseconds(5);
	  	digitalWritei(pingPin, LOWW);

	  	pinMode(pingPin, INPUT);

	  	//pulseIn(duration, pingPin, HIGH);
  	
		clr32 N
		WhilePreviousPulse:
			sbic CORE_PIN_CONCATENATE(13, PINREG),CORE_PIN_CONCATENATE(13, BIT)
			rjmp WhilePulseStop

		WhilePulseStart:
			sbis CORE_PIN_CONCATENATE(13, PINREG),CORE_PIN_CONCATENATE(13, BIT)
			rjmp WhilePulseStart

		ldi32 M,1
		WhilePulseStop:
			add32 N,M
			sbic CORE_PIN_CONCATENATE(13, PINREG),CORE_PIN_CONCATENATE(13, BIT)
			rjmp WhilePulseStop

		// (width * PULSEIN_CYCLES_PER_LOOP)
		ldi rmp1,PULSEIN_CYCLES_PER_LOOP
		mov32 O,N
		Mult_width:
			add32 N,O
			dec rmp1
			brne Mult_width
		
		addi32 N,PULSEIN_CYCLES_LATENCY
		ldiw T2,clockCyclesPerMicrosecond()
		div_32_16 N,T2,VH

		write32 duration,N

		ldiw T2,29
		div_32_16 N,T2,VH
		ldiw T2,2
		div_32_16 N,T2,VH
		write32 duration,N 
	EndTiempoPing:

	cpi32 duration,60
	jlt(Menor)
		digitalWritei(ledPin, LOWW)
		//Servo_giro_5(servo_ultrasonido, 7, true, 40, 140)
		Servo_microGiro(servo_ultrasonido, 4, true)
		rjmp EndMenor 
	Menor:
		Servo_microGiro(servo_ultrasonido, 4, false)
		//Servo_giro_3(servo_ultrasonido, 7, false)
		SistDisparo_press(sist_disparo)
		digitalWritei(ledPin, HIGHH)
	EndMenor:
	
	//analogRead varAnalog,potenciometroPin
	// read8	dd16uL,varAnalog+1
	// read8	dd16uH,varAnalog
	// assign16(varAnalog,768
	//div16uMry varPwm,varAnalog,4
	//analogWrite16 0,varPwm
	//assign16(varAnalog,512
	//div16uMry varPwm,varAnalog,8

	// giroRapidoDerecha

	// pruebaSensoresLinea
	// pruebaControladorMotor
	// pruebaLedPinTimer

	// call leerSensoresLinea
	// call actualizar
	jmp Loop // go back to loop


.INCLUDE "avr200.inc"
.INCLUDE "math32.inc"
.INCLUDE "arduino_subrutinas.inc"
.INCLUDE "servo_impl_aux.asm"

//
// End of source code
//
