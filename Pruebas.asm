#include "WProgram.asm"
#include "servo_aux.inc"
#include "servo_impl_aux.asm"
#include "sistema_disparo.asm"
#include "Ping.asm"
// #include "Motor.asm"
#include "Motores.asm"
#include "LineaError.asm"
#include "casos_de_prueba.inc"

#define ledPin					6
#define vccA					9	// Izquierdo
#define gndA					10	// Izquierdo
#define vccB					7	// Derecho
#define gndB					8 	// Derecho
#define enableA					0
#define enableB					1
#define pingPin					13
#define servoPin				14
#define sistemaDisparoPin		15

// Sensores de linea
#define DERECHA					A0
#define IZQUIERDA				A1
#define CENTRO_IZQUIERDA		A2
#define CENTRO_DERECHA			A3 

#define Negro					1
#define Blanco					0

#define SENTIDO_DERECHA			1
#define SENTIDO_IZQUIERDA		0
#define SIN_DETECCION			255

#define EDO_ADELANTE			1
#define EDO_DERECHA				2
#define EDO_IZQUIERDA			3
#define EDO_DETENIDO			4
#define EDO_CRUCE_IZQUIERDA		5
#define EDO_CRUCE_DERECHA		6

#define EDO_0					0
#define EDO_1					1
#define EDO_2					2
#define EDO_3					3
#define EDO_4					4
#define EDO_5					5

#define LECTURAS_SENSOR_LINEA	1

// Banderas manejo de error
#define LECTURAS_DET_CRUCE		1500

// #define IZDA_PASO_0				1
byte_o(tempByte);
int_o(tempInt);
long_o(tempLong); 

int_o(i);

int_o(tmpLinea);
int_o(sumLinea);
int_o(valDerecha);
int_o(valIzquierda);
int_o(valCentroDerecha);
int_o(valCentroIzquierda);

int_o(contDetectorCruce);
int_o(estadoCruce)

byte_o(enemigoDetectado);

// Control sensor de linea

#define cpLinea(_pin1,_edo1) cpi8 lineaError_##_edo1##(linea_##_pin1##),1
#define cpLinea_2(_pin1,_pin2,_edo1,_edo2) m_cpLinea_2 lineaError_##_edo1##(linea_##_pin1##), lineaError_##_edo2##(linea_##_pin2##)

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
// .MACRO esNegro16
// 	assign16(sumLinea, 0)
// 	assign16(i, 0)
// 	InicioForLecturas:
// 		analogRead tmpLinea,@1
// 		sum16 sumLinea, tmpLinea
// 		inc16 i
// 		cpi16 i, LECTURAS_SENSOR_LINEA
// 		brne InicioForLecturas
// 	cpi16 sumLinea,LECTURAS_SENSOR_LINEA * 1024 / 2
// 	jge(SalvarNegro)
// 		assign16(@0, 0)
// 		rjmp EndEsNegro
// 	SalvarNegro:
// 		assign16(@0, 1)
// 	EndEsNegro:
// .ENDM

// params @0 Direccion de memoria, 2 bytes.
// params @1 Pin sensor de linea
// .MACRO esBlanco16
// 	assign16(sumLinea, 0)
// 	assign16(i, 0)
// 	InicioForLecturas:
// 		analogRead tmpLinea,@1
// 		sum16 sumLinea, tmpLinea
// 		inc16 i
// 		cpi16 i, LECTURAS_SENSOR_LINEA
// 		brne InicioForLecturas
// 	cpi16 sumLinea,LECTURAS_SENSOR_LINEA * 1024 / 2
// 	jge(SalvarBlanco)
// 		assign16(@0, 0)
// 		rjmp EndEsBlanco
// 	SalvarBlanco:
// 		assign16(@0, 1)
// 	EndEsBlanco:
// .ENDM

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
	esNegro16 valCentroIzquierda,CENTRO_IZQUIERDA
	esNegro16 valCentroDerecha,CENTRO_DERECHA
	esNegro16 valDerecha,DERECHA
	LineaError_actualizar(linea_IZQUIERDA, IZQUIERDA)
	LineaError_actualizar(linea_CENTRO_IZQUIERDA, CENTRO_IZQUIERDA)
	LineaError_actualizar(linea_CENTRO_DERECHA, CENTRO_DERECHA)
	LineaError_actualizar(linea_DERECHA, DERECHA)
	ret

// params @0 Variable, 1 byte.
// params @1 Variable, 1 byte.
.MACRO m_cpLinea_2 
	cpi8 @0,1
	andCpi8 @1,1
.ENDM

// params @0 Rr
// params @1 Rd
// params @2 Constante
// params @3 Constante
.MACRO cmpSensoresLinea_2
	cpi @0,@2
	andCp @1,@3
.ENDM

// params @0 Constante
// params @1 Constante
// params @2 Constante
// params @3 Constante
.MACRO cmpSensoresLinea_4
	cpi XL,@0
	andCp XH,@1
	andCp YL,@2
	andCp YH,@3
.ENDM

estadoIzquierda:
 	read8 XL,valIzquierda
 	read8 XH,valCentroIzquierda
 	read8 YL,valCentroDerecha
 	read8 YH,valDerecha

//	#region Sin considerar salida de borde
 	cmpSensoresLinea_2 YL,YH,0,1
 	breq eiCambioEdoAdelante
 	cmpSensoresLinea_2 YL,YH,0,0
 	breq eiCambioEdoAdelante

 	jmp eiGiroRapidoIzda
// 	#endregion
 	eiCambioEdoAdelante:
 		// digitalWritei(ledPin, LOWW)
 		assign16(estadoActual, EDO_ADELANTE)
		call estadoAdelante
		jmp EndEstadoIzquierda

	eiGiroRapidoIzda:
		 // digitalWritei(ledPin, LOWW)
 		Motores_giroRapidoIzquierda()
 	EndEstadoIzquierda:
 	ret

estadoAdelante:
 	read8 XL,valIzquierda
 	read8 XH,valCentroIzquierda
 	read8 YL,valCentroDerecha
 	read8 YH,valDerecha

 	// Iniciar contador determinar cruce
 	cpLinea_2(IZQUIERDA, CENTRO_IZQUIERDA, Blanco, Blanco)
 	// cmpSensoresLinea_2 XL,XH,0,0
 	brne ElseEaCpDetCruce
 		digitalWritei(ledPin, LOWW)
 		inc16 contDetectorCruce
 		jmp DoneEaCpDetCruce
 	ElseEaCpDetCruce:
 		cpi16 contDetectorCruce, LECTURAS_DET_CRUCE
 		jlt(ElseEaNoHayCruce)
 			// assign16(estadoActual, EDO_DETENIDO)
 			// call estadoDetenido
 			// jmp EndEstadoAdelante

 			assign16(estadoActual, EDO_CRUCE_IZQUIERDA)
 			assign16(estadoCruce, EDO_0)
			call estadoCruceIzquierda
			assign16(contDetectorCruce, 0)
			jmp EndEstadoAdelante
 		ElseEaNoHayCruce:
 	 		digitalWritei(ledPin, HIGHH)
 	 	// 	assign16(estadoActual, EDO_DETENIDO)
 			// call estadoDetenido
 			// jmp EndEstadoAdelante
 			assign16(contDetectorCruce, 0)
 	DoneEaCpDetCruce:


 	// Motores adelante
 	cmpSensoresLinea_4 0,0,0,0
 		breq eaAdelante
 	cmpSensoresLinea_4 1,0,0,1
 		breq eaAdelante
 	cmpSensoresLinea_4 0,0,0,1
 		breq eaAdelante
 	cmpSensoresLinea_4 1,0,0,0
 		breq eaAdelante

 	jmp eaInicioCpDerecha

	eaAdelante:
		Motores_adelante_2(255, 240);
		jmp EndEstadoAdelante
	eaInicioCpDerecha:
		cmpSensoresLinea_4 1,1,0,0
	 	breq eaDerecha
	 	cmpSensoresLinea_4 1,1,0,1
	 	breq eaDerecha

	 	jmp eaInicioCpIzquierda

	eaDerecha:
		// Motores_giroDerecha()
		Motores_adelante_2(255, 200)
		jmp EndEstadoAdelante
	eaInicioCpIzquierda:
		cmpSensoresLinea_4 0,0,1,1
	 	breq eaIzquierda
	 	cmpSensoresLinea_4 1,0,1,1
	 	breq eaIzquierda

	 	jmp eaInicioCpCambioEdoIzda

	eaIzquierda:
		// Motores_giroIzquierda()
	Motores_adelante_2(200, 255)
		jmp EndEstadoAdelante
	eaInicioCpCambioEdoIzda:
		cmpSensoresLinea_4 1,1,1,1
		brne eaDetener
			assign16(estadoActual, EDO_IZQUIERDA)
			call estadoIzquierda
			jmp EndEstadoAdelante
	eaDetener:
		Motores_detener()
	EndEstadoAdelante:
	ret

estadoCruceIzquierda:
	Motores_giroRapidoIzquierda_2(255, 255)
	cpLinea_2(CENTRO_DERECHA, DERECHA, Blanco, Blanco)
	andCpi16 estadoCruce, EDO_0
	brne CpEdo2CruceIzda
		assign16(estadoCruce, EDO_1)
		jmp EndEstadoCruceIzquierda
	CpEdo2CruceIzda:
		cpi16 estadoCruce, EDO_1
			brne EndEstadoCruceIzquierda
		cpLinea(CENTRO_DERECHA, Negro)
			breq EsIgualEdo2CruceLinea
		cpLinea(DERECHA, Negro)
			brne EndEstadoCruceIzquierda
		EsIgualEdo2CruceLinea:
			assign16(estadoActual, EDO_ADELANTE)
			call estadoAdelante
	EndEstadoCruceIzquierda:
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
	cpi16 estadoActual,EDO_CRUCE_IZQUIERDA
	brne PC+4
		call estadoCruceIzquierda
		rjmp EndSwitchEstado
	EndSwitchEstado:
ret

// params @0 Pin seleccionado
// params @1 Valor comprendido entre 0 y 65535
.MACRO analogWrite16i
	ldi rmp2,@0
	ldiw V,@1
	call AnalogWriteSub16
.ENDMACRO

Setup:
	Motores(vccA, gndA, enableA, vccB, gndB, enableB) // {izquierdo, derecho}
	// Motor(motorDerecho, vccB, gndB)
	// Motor(motorIzquierdo, vccA, gndA)
	LineaError(linea_IZQUIERDA)
	LineaError(linea_CENTRO_IZQUIERDA)
	LineaError(linea_CENTRO_DERECHA)
	LineaError(linea_DERECHA)
	pinMode(ledPin, OUTPUT)
	pinMode(IZQUIERDA, INPUT)
	pinMode(DERECHA, INPUT)
	pinMode(CENTRO_IZQUIERDA, INPUT)
	pinMode(CENTRO_DERECHA, INPUT)
	long(duration, MAX_ULONG)
	long(tiempo_ping, 0)
	long(tiempoActualLedPin, 0)
	int(parpadeoLedPin, 0)
	int(estadoActual, EDO_ADELANTE)
	int(varLedPin, 1)
	assign16(contDetectorCruce, 0)
	assign16(enemigoDetectado, SIN_DETECCION)
	Servo(servo_ultrasonido, servoPin)
	SistDisparo(sist_disparo, sistemaDisparoPin)
	// digitalWritei(ledPin, HIGHH)
	// delay(2000)
	// call initServo2
	ret
//
// ============================================
//         P R O G R A M    L O O P
// ============================================
//
Loop:
	// digitalWrite(ledPin, varLedPin)

	call DeteccionEnemigo

	// SistDisparo_press(sist_disparo);
	// Servo_microGiro(servo_ultrasonido, 4, true);

	// Motores_adelante()
	// Motor_adelante(motorDerecho)
	// Motor_adelante(motorIzquierdo)

	// call pruebaServo
	// pruebaSensoresLinea
	// pruebaErrorSensoresLinea
	// pruebaControladorMotor
	// pruebaLatchingPing
	// pruebaSistemaDisparo

	call leerSensoresLinea
	call actualizar
	// delay(100)
	ret // go back to loop

DeteccionEnemigo:
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
		Servo_microGiro(servo_ultrasonido, 4, false);
		// Establacer sentido del enemigo detectado
		cpi16 servo_Grados(servo_ultrasonido),90
		assign16ge_2 enemigoDetectado,SENTIDO_IZQUIERDA,'i'
		assign16lt_2 enemigoDetectado,SENTIDO_DERECHA,'i'

		// Comprobar si puede disparar
		cpi16 servo_Grados(servo_ultrasonido), 120
			jge(EndCompareDisparo)
		cpi16 servo_Grados(servo_ultrasonido), 60
			jlt(EndCompareDisparo)
		SistDisparo_press(sist_disparo);
		EndCompareDisparo:
		// Parpadeo del led
		copy(parpadeoLedPin, duration);
		map16i(parpadeoLedPin, 0, 60, 0, 384);
		cpMillis(tiempoActualLedPin, parpadeoLedPin, v);
			jlt(EndParpadeoLed)
		copy32(tiempoActualLedPin, tiempoEnMilis)
		negarBool16 varLedPin
		EndParpadeoLed:
		digitalWrite(ledPin, varLedPin);
	EndMenor:
	ret

//
// End of source code
//
