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
#define vccA					8	// Izquierdo
#define gndA					7	// Izquierdo
#define vccB					10	// Derecho
#define gndB					9 	// Derecho
#define enableA					1
#define enableB					0
#define pingPin					13
#define servoPin				14
#define sistemaDisparoPin		15
#define impactoPin1				3
#define impactoPin2				2

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

#define ESTRATEGIA_ATAQUE_1		0
#define ESTRATEGIA_ATAQUE_2		1
#define ESTRATEGIA_HUIDA		2

#define LECTURAS_SENSOR_LINEA	1

// Banderas manejo de error
#define LECTURAS_DET_CRUCE		600

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

int_o(contDetectorCruceIzda);
int_o(contDetectorCruceDcha);
byte_o(cruceIzda);
byte_o(cruceDcha);
byte_o(hayCruceDerecha);
byte_o(hayCruceIzquierda);
int_o(estadoCruce);

byte_o(enemigoDetectado);

byte_o(fueImpactado);
byte_o(estaApagado);
byte_o(estrategiaActual);

#define cpLinea(_pin1,_edo1) cpi8 lineaError_##_edo1##(linea_##_pin1##),1
#define cpLinea_2(_pin1,_pin2,_edo1,_edo2) m_cpLinea_2 lineaError_##_edo1##(linea_##_pin1##), lineaError_##_edo2##(linea_##_pin2##)
#define cpLinea_4(_edo1,_edo2,_edo3,_edo4) m_cpLinea_4 lineaError_##_edo1##(linea_IZQUIERDA), lineaError_##_edo2##(linea_CENTRO_IZQUIERDA), lineaError_##_edo3##(linea_CENTRO_DERECHA), lineaError_##_edo4##(linea_DERECHA)

// Interrupcion externa
INT_vect:
	assign8(fueImpactado, true)
	assign8(EIMSK, 0)
	reti

IniciarInterrupcionesExternas:
	pinMode(impactoPin1, INPUT_PULLUP)
	pinMode(impactoPin2, INPUT_PULLUP)
	digitalWritei(impactoPin1, HIGHH)
	digitalWritei(impactoPin2, HIGHH)
	assign8(EICRA, (FALLING << ISC30) | (FALLING << ISC20))
	assign8(EIMSK, _BV(INT3) | _BV(INT2))
	ret

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

.MACRO m_cpLinea_4
	m_cpLinea_2 @0,@1
	andCpi8 @2,1
	andCpi8 @3,1
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
//	#region Sin considerar salida de borde
 	cpLinea_2(CENTRO_DERECHA, DERECHA, Blanco, Negro)
 		breq eiCambioEdoAdelante
 	cpLinea_2(CENTRO_DERECHA, DERECHA, Blanco, Blanco)
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

estadoDerecha:
	// digitalWritei(ledPin, HIGHH)
//	#region Sin considerar salida de borde

	// cpLinea(IZQUIERDA, Negro)
	// brne NoEsIgualTest
	// 	digitalWritei(ledPin, HIGHH)
	// 	jmp EndIgualTest
	// NoEsIgualTest:
 // 		digitalWritei(ledPin, LOWW)
 // 	EndIgualTest:

 	cpLinea_2(IZQUIERDA, CENTRO_IZQUIERDA, Negro, Blanco)
 		breq edCambioEdoAdelante
 	cpLinea_2(IZQUIERDA, CENTRO_IZQUIERDA, Blanco, Blanco)
 		breq edCambioEdoAdelante
 	jmp edGiroRapidoDcha
// 	#endregion
 	edCambioEdoAdelante:
 		assign16(estadoActual, EDO_ADELANTE)
		call estadoAdelante
		jmp EndEstadoDerecha

	edGiroRapidoDcha:
		 // digitalWritei(ledPin, LOWW)
 		Motores_giroRapidoDerecha()
 	EndEstadoDerecha:
 	ret

estadoAdelante:
 	// Iniciar contador determinar cruce izquierda
 	// cpLinea_2(IZQUIERDA, CENTRO_IZQUIERDA, Blanco, Blanco)
 	// brne ElseEaCpDetCruceIzda
 	// 	// digitalWritei(ledPin, LOWW)
 	// 	inc16 contDetectorCruceIzda
 	// 	jmp DoneEaCpDetCruceIzda
 	// ElseEaCpDetCruceIzda:
 	// 	cpi16 contDetectorCruceIzda, LECTURAS_DET_CRUCE
 	// 	jlt(ElseEaNoHayCruceIzda)
 	// 		cpLinea_4(Negro, Negro, Negro, Negro)
 	// 			jeq(EjecutarCruceBorde)
 	// 		assign16(estadoActual, EDO_CRUCE_IZQUIERDA)
 	// 		assign16(estadoCruce, EDO_0)
		// 	call estadoCruceIzquierda
		// 	assign16(contDetectorCruceIzda, 0)
 	// 		inc8 cruceIzda
		// 	jmp EndEstadoAdelante
 	// 	ElseEaNoHayCruceIzda:
 	//  		// digitalWritei(ledPin, HIGHH)
 	// 		assign16(contDetectorCruceIzda, 0)
 	// DoneEaCpDetCruceIzda:

 	// Iniciar contador determinar cruce derecha
 	cpLinea_2(DERECHA, CENTRO_DERECHA, Blanco, Blanco)
 	brne ElseEaCpDetCruceDcha
 		// digitalWritei(ledPin, LOWW)
 		inc16 contDetectorCruceDcha
 		jmp DoneEaCpDetCruceDcha
 	ElseEaCpDetCruceDcha:
 		cpi16 contDetectorCruceDcha, LECTURAS_DET_CRUCE
 		jlt(ElseEaNoHayCruceDcha)
 			cpLinea_4(Negro, Negro, Negro, Negro)
 				jeq(EjecutarCruceBorde)
			assign16(contDetectorCruceDcha, 0)
 			inc8 cruceDcha
 			assign8(hayCruceDerecha, true)
			jmp EndEstadoAdelante
 		ElseEaNoHayCruceDcha:
 	 		// digitalWritei(ledPin, HIGHH)
 			assign16(contDetectorCruceDcha, 0)
 			assign8(hayCruceDerecha, false)
 	DoneEaCpDetCruceDcha:

 	// Motores adelante
 	cpLinea_4(Blanco, Blanco, Blanco, Blanco)
 		breq eaAdelante
 	cpLinea_4(Negro, Blanco, Blanco, Negro)
 		breq eaAdelante
 	cpLinea_4(Blanco, Blanco, Blanco, Negro)
 		breq eaAdelante
 	cpLinea_4(Negro, Blanco, Blanco, Blanco)
 		breq eaAdelante

 	jmp eaInicioCpDerecha

	eaAdelante:
		Motores_adelante();
		jmp EndEstadoAdelante
	eaInicioCpDerecha:
		cpLinea_4(Negro, Negro, Blanco, Blanco)
	 		breq eaDerecha
	 	cpLinea_4(Negro, Negro, Blanco, Negro)
	 		breq eaDerecha
	 	cpLinea_4(Blanco, Negro, Blanco, Blanco) // No debería ocurrir, corrección de error
	 		breq eaDerecha

	 	jmp eaInicioCpIzquierda

	eaDerecha:
		Motores_giroDerecha()
		// Motores_adelante_2(255, 200)
		jmp EndEstadoAdelante
	eaInicioCpIzquierda:
		cpLinea_4(Blanco, Blanco, Negro, Negro)
	 		breq eaIzquierda
	 	cpLinea_4(Negro, Blanco, Negro, Negro)
	 		breq eaIzquierda

	 	jmp eaInicioCpCambioEdoIzda

	eaIzquierda:
		Motores_giroIzquierda()
		// Motores_adelante_2(200, 255)
		jmp EndEstadoAdelante
	eaInicioCpCambioEdoIzda:
		cpLinea_4(Negro, Negro, Negro, Negro)
			brne eaDetener
		EjecutarCruceBorde:
			assign8(cruceIzda, 0)
			assign8(cruceDcha, 0)
			// assign16(estadoActual, EDO_IZQUIERDA)
			// call estadoIzquierda
			assign16(estadoActual, EDO_DERECHA)
			call estadoDerecha
			jmp EndEstadoAdelante
	eaDetener:
		Motores_detener()
	EndEstadoAdelante:
	ret

estadoCruceIzquierda:
	Motores_giroRapidoIzquierda_2(255, 255)
	cpLinea_2(CENTRO_DERECHA, DERECHA, Blanco, Blanco)
	andCpi16 estadoCruce, EDO_0
	brne Cp2daCondicionCruce
		assign16(estadoCruce, EDO_1)
		jmp EndEstadoCruceIzquierda
	Cp2daCondicionCruce:
	cpLinea_2(CENTRO_DERECHA, DERECHA, Negro, Negro)
	andCpi16 estadoCruce, EDO_0
	brne CpEdo2CruceIzda
		assign8(cruceIzda, 0)
		assign8(cruceDcha, 0)
		assign16(estadoActual, EDO_IZQUIERDA)
		call estadoIzquierda
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

estadoCruceDerecha:
	Motores_giroRapidoDerecha_2(255, 255)
	cpLinea_2(CENTRO_IZQUIERDA, IZQUIERDA, Blanco, Blanco)
	andCpi16 estadoCruce, EDO_0
	brne ecdCp2daCondicionCruce
		assign16(estadoCruce, EDO_1)
		jmp EndEstadoCruceDerecha
	ecdCp2daCondicionCruce:
	cpLinea_2(CENTRO_IZQUIERDA, IZQUIERDA, Negro, Negro)
	andCpi16 estadoCruce, EDO_0
	brne ecdCpEdo2CruceDcha
		assign8(cruceIzda, 0)
		assign8(cruceDcha, 0)
		assign16(estadoActual, EDO_DERECHA)
		call estadoDerecha
		jmp EndEstadoCruceDerecha
	ecdCpEdo2CruceDcha:
		cpi16 estadoCruce, EDO_1
			brne EndEstadoCruceDerecha
		cpLinea(CENTRO_IZQUIERDA, Negro)
			breq ecdEsIgualEdo2CruceLinea
		cpLinea(IZQUIERDA, Negro)
			brne EndEstadoCruceDerecha
		ecdEsIgualEdo2CruceLinea:
			assign16(estadoActual, EDO_ADELANTE)
			call estadoAdelante
	EndEstadoCruceDerecha:
	ret

estadoDetenido:
	Motores_detener()
	ret

estrategiaAtaque_1:
	cpi8 hayCruceDerecha, true
	jne(EndEstrategiaAtaque_1)
		assign8(hayCruceDerecha, false)
		assign16(estadoActual, EDO_CRUCE_DERECHA)
 		assign16(estadoCruce, EDO_0)
		call estadoCruceDerecha
	EndEstrategiaAtaque_1:
	ret

estrategiaAtaque_2:
	ret

estrategiaHuida:
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
	cpi16 estadoActual,EDO_DERECHA
	brne PC+4
		call estadoDerecha
		rjmp EndSwitchEstado
	cpi16 estadoActual,EDO_CRUCE_DERECHA
	brne PC+4
		call estadoCruceDerecha
		rjmp EndSwitchEstado
	EndSwitchEstado:
ret

actualizarEstrategia:
	cpi8 estrategiaActual,ESTRATEGIA_ATAQUE_1
	brne PC+4
		call estrategiaAtaque_1
		rjmp EndSwitchEstrategia
	cpi8 estrategiaActual,ESTRATEGIA_ATAQUE_2
	brne PC+4
		call estrategiaAtaque_2
		rjmp EndSwitchEstrategia
	cpi8 estrategiaActual,ESTRATEGIA_HUIDA
	brne PC+4
		call estrategiaHuida
		rjmp EndSwitchEstrategia
	EndSwitchEstrategia:
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
	assign8(fueImpactado, false)
	assign8(estaApagado, false)
	assign8(estrategiaActual, ESTRATEGIA_ATAQUE_1)
	assign16(contDetectorCruceIzda, 0)
	assign16(contDetectorCruceDcha, 0)
	assign8(cruceDcha, 0)
	assign8(cruceIzda, 0)
	assign8(hayCruceIzquierda, false);
	assign8(hayCruceDerecha, false);
	assign16(enemigoDetectado, SIN_DETECCION)
	Servo(servo_ultrasonido, servoPin)
	SistDisparo(sist_disparo, sistemaDisparoPin)
	call IniciarInterrupcionesExternas
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
	call ComprobarImpacto
		jeq(EndLoop)
	call DeteccionEnemigo

	// SistDisparo_press(sist_disparo);
	// Servo_microGiro(servo_ultrasonido, 4, true);

	// Motores_adelante()
	// Motores_giroDerecha()
	// Motor_adelante(motorDerecho)
	// Motor_adelante(motorIzquierdo)
	// Motores_giroRapidoIzquierda()

	// call pruebaServo
	// pruebaSensoresLinea
	// pruebaErrorSensoresLinea
	// pruebaControladorMotor
	// pruebaLatchingPing
	// pruebaSistemaDisparo

	call leerSensoresLinea
	call actualizar
	call actualizarEstrategia

	// delay(100)
	EndLoop:
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
		// digitalWritei(ledPin, LOWW);
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
		// digitalWrite(ledPin, varLedPin);
	EndMenor:
	ret

ComprobarImpacto:
	cpi8 fueImpactado, true
	andCpi8 estaApagado, false
	breq ImpactoTrue
		jmp EndComprobarImpacto
	ImpactoTrue:
		cpi8 fueImpactado, true
		call ApagarSistema
	EndComprobarImpacto:
	cpi8 estaApagado, true
	ret

// Rutina para apagar el sistema
ApagarSistema:
	assign8(estaApagado, true)
	digitalWritei(ledPin, HIGHH)
	pinMode(impactoPin1, INPUT)
	Motores_detener()
	Servo_write(servo_ultrasonido, 90, 'i')
	SistDisparo_reset(sist_disparo)
	ret

//
// End of source code
//
