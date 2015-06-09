/*
 * Pruebas.asm
 *
 *  Created: 1/31/2015 9:49:46 PM
 *   Author: AlfonsoAndrés
 */ 

.NOLIST
.INCLUDE "WProgram.asm"
.INCLUDE "servo_aux.inc"
.INCLUDE "servo_impl_aux.asm"
.INCLUDE "sistema_disparo.asm"
.LIST

#define ledPin					6
#define vccA					3
#define gndA					2
#define vccB					1
#define gndB					0
#define pingPin					13
#define servoPin				14
#define sistemaDisparoPin		15

// Sensores de linea
#define DERECHA					A0
#define IZQUIERDA				A1
#define CENTRO_IZQUIERDA		A2
#define CENTRO_DERECHA			A3 

#define EDO_ADELANTE			1
#define EDO_DERECHA				2
#define EDO_IZQUIERDA			3
#define EDO_DETENIDO			4

int_o(varAnalog);
int_o(varPwm);
int_o(tmpLinea);
int_o(valDerecha);
int_o(valIzquierda);
int_o(valCentroDerecha);
int_o(valCentroIzquierda);
// int_o(tot_overflow);

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
//	assign16(tot_overflow, 0)
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

Setup:
	pinMode(ledPin, OUTPUT)
	pinMode(IZQUIERDA, INPUT)
	pinMode(DERECHA, INPUT)
	pinMode(CENTRO_IZQUIERDA, INPUT)
	pinMode(CENTRO_DERECHA, INPUT)
	pinMode(vccA, OUTPUT)
	pinMode(vccB, OUTPUT)
	pinMode(gndA, OUTPUT)
	pinMode(gndB, OUTPUT)
	long(duration, MAX_ULONG)
	long(tiempo_ping, 0)
	int(estadoActual, EDO_ADELANTE)
	int(varLedPin, 1)
	Servo(servo_ultrasonido, servoPin)
	SistDisparo(sist_disparo, sistemaDisparoPin)
	ret
//
// ============================================
//         P R O G R A M    L O O P
// ============================================
//
Loop:
	//digitalWritei(ledPin, HIGHH)
	// digitalWrite(ledPin, varLedPin)
	Servo_update(servo_ultrasonido)
	// Servo_giro_3(servo_ultrasonido, 4, true)
	SistDisparo_update(sist_disparo)
	// Servo_update(sist_disparo)
	// Servo_giro_3(sist_disparo, 4, true)
	// SistDisparo_press(sist_disparo)
	cpMillis(tiempo_ping, 100, i)
	jlt(EndTiempoPing)
		copy32(tiempo_ping,tiempoEnMilis)
		pinMode(pingPin, OUTPUT);
	  	digitalWritei(pingPin, LOWW);
	  	delayMicroseconds(2);
	  	digitalWritei(pingPin, HIGHH);
	  	delayMicroseconds(5);
	  	digitalWritei(pingPin, LOWW);

	  	pinMode(pingPin, INPUT);
	  	pulseIn(duration, 13, HIGHH);

		ldiw T2,29
		div_32_16 N,T2,VH
		ldiw T2,2
		div_32_16 N,T2,VH
		write32 duration,N 
		jmp EndTiempoPing

		SalidaIncorrectaPingSensor:
		assign32(duration, MAX_ULONG)
	EndTiempoPing:

	cpi32 duration,60
	jlt(Menor)
		digitalWritei(ledPin, LOWW)
		Servo_microGiro(servo_ultrasonido, 4, true)
		rjmp EndMenor 
	Menor:
		digitalWritei(ledPin, HIGHH)
		Servo_microGiro(servo_ultrasonido, 4, false)
		SistDisparo_press(sist_disparo)
	EndMenor:
	
	//analogRead varAnalog,potenciometroPin
	// read8	dd16uL,varAnalog+1
	// read8	dd16uH,varAnalog
	// assign16(varAnalog,768
	//div16uMry varPwm,varAnalog,4
	//analogWrite16 0,varPwm
	//assign16(varAnalog,512
	//div16uMry varPwm,varAnalog,8

	// pruebaSensoresLinea
	// pruebaControladorMotor
	// pruebaLedPinTimer

	// call leerSensoresLinea
	// call actualizar
	ret // go back to loop
//
// End of source code
//
