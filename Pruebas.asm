#include "WProgram.asm"
#include "servo_aux.inc"
#include "servo_impl_aux.asm"
#include "sistema_disparo.asm"
#include "Ping.asm"
#include "Motores.asm"
#include "casos_de_prueba.inc"

#define ledPin					6
#define vccA					3	// Izquierdo
#define gndA					2	// Izquierdo
#define vccB					1	// Derecho
#define gndB					0	// Derecho
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
	Motores_giroRapidoIzquierda()
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
		Motores_adelante()
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
		Motores_giroDerecha()
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
		Motores_giroIzquierda()
		rjmp EndEstadoAdelante
	EdoDetener:
		Motores_detener()
	EndEstadoAdelante:
	ret

estadoDetenido:
	Motores_detener()
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

Setup:
	Motores(vccA, gndA, vccB, gndB) // {izquierdo, derecho}
	pinMode(ledPin, OUTPUT)
	pinMode(IZQUIERDA, INPUT)
	pinMode(DERECHA, INPUT)
	pinMode(CENTRO_IZQUIERDA, INPUT)
	pinMode(CENTRO_DERECHA, INPUT)
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
	SistDisparo_update(sist_disparo);
	cpMillis(tiempo_ping, 100, i);
	jlt(EndTiempoPing)
		copy32(tiempo_ping,tiempoEnMilis);
		Ping_fire(duration, 13);
		Ping_toCentimeters(duration);
	EndTiempoPing:

	cpi32 duration,60
	jlt(Menor)
		digitalWritei(ledPin, LOWW);
		Servo_microGiro(servo_ultrasonido, 4, true);
		rjmp EndMenor 
	Menor:
		digitalWritei(ledPin, HIGHH);
		Servo_microGiro(servo_ultrasonido, 4, false);
		SistDisparo_press(sist_disparo);
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
	// pruebaLatchingPing
	// pruebaSistemaDisparo

	// call leerSensoresLinea
	// call actualizar
	ret // go back to loop
//
// End of source code
//
