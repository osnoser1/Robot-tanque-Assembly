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
#define vccA					10	// Izquierdo
#define gndA					9	// Izquierdo
#define vccB					8	// Derecho
#define gndB					7	// Derecho
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

#define NEGRO					1
#define BLANCO					0

#define EDO_ADELANTE			1
#define EDO_DERECHA				2
#define EDO_IZQUIERDA			3
#define EDO_DETENIDO			4

#define EDO_0					0
#define EDO_1					1
#define EDO_2					2
#define EDO_3					3
#define EDO_4					4
#define EDO_5					5

#define LECTURAS_SENSOR_LINEA	1

// Banderas manejo de error
#define LECTURAS_DET_CRUCE		150

// #define IZDA_PASO_0				1
byte_o(tempByte);
int_o(tempInt);
long_o(tempLong); 

int_o(i);

int_o(varAnalog);
int_o(varPwm);
int_o(tmpLinea);
int_o(sumLinea);
int_o(valDerecha);
int_o(valIzquierda);
int_o(valCentroDerecha);
int_o(valCentroIzquierda);

int_o(edoIzda);
int_o(contDetectorCruce);

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
// #endregion

// //	#region Consideración salida de borde
//  	cpi16 edoIzda, EDO_0 // Sin salir del borde
//  	brne elseIzda_1
//  		cmpSensoresLinea_2 YL,YH,1,0
//  			jne(eiGiroRapidoIzda)
//  		cmpSensoresLinea_2 YL,YH,0,0
//  			jne(eiGiroRapidoIzda)
//  		assign16(edoIzda, EDO_1)
//  		jmp eiDetener
//  		jmp eiGiroRapidoIzda
//  	elseIzda_1:
//  	cpi16 edoIzda, EDO_1 // Ya salió del borde
//  	brne elseIzda_2
//  		cmpSensoresLinea_2 YL,YH,1,0
//  			jne(eiGiroRapidoIzda)
//  		cmpSensoresLinea_2 YL,YH,1,1
//  		 	jne(eiGiroRapidoIzda)
//  		assign16(edoIzda, EDO_2)
//  		jmp eiGiroRapidoIzda
//  	elseIzda_2:
//  	brne eiDetener
//  	cpi16 edoIzda, EDO_2 // Regresó al borde
//  		cmpSensoresLinea_2 YL,YH,0,1
//  			breq eiCambioEdoAdelante
//  		cmpSensoresLinea_2 YL,YH,0,0
//  		 	brne eiCambioEdoAdelante
//  		jmp eiGiroRapidoIzda
//  	eiDetener:
//  		digitalWritei(ledPin, LOWW)
//  		assign16(edoIzda, EDO_3)
//  		assign16(estadoActual, EDO_DETENIDO)
//  		call estadoDetenido
//  		jmp EndEstadoIzquierda
// //	#endregion
 	eiCambioEdoAdelante:
 		// digitalWritei(ledPin, LOWW)
 		assign16(edoIzda, EDO_3)
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
 	cmpSensoresLinea_2 XL,XH,0,0
 	brne ElseEaCpDetCruce
 		digitalWritei(ledPin, LOWW)
 		inc16 contDetectorCruce
 		jmp DoneEaCpDetCruce
 	ElseEaCpDetCruce:
 		cpi16 contDetectorCruce, LECTURAS_DET_CRUCE
 		jlt(ElseEaNoHayCruce)
 		// 	assign16(estadoActual, EDO_DETENIDO)
			// call estadoDetenido
			jmp DoneEaCpDetCruce
 		ElseEaNoHayCruce:
 	 		digitalWritei(ledPin, HIGHH)
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
		Motores_adelante();
		jmp EndEstadoAdelante
	eaInicioCpDerecha:
		cmpSensoresLinea_4 1,1,0,0
	 	breq eaDerecha
	 	cmpSensoresLinea_4 1,1,0,1
	 	breq eaDerecha

	 	jmp eaInicioCpIzquierda

	eaDerecha:
		Motores_giroDerecha()
		jmp EndEstadoAdelante
	eaInicioCpIzquierda:
		cmpSensoresLinea_4 0,0,1,1
	 	breq eaIzquierda
	 	cmpSensoresLinea_4 1,0,1,1
	 	breq eaIzquierda

	 	jmp eaInicioCpCambioEdoIzda

	eaIzquierda:
		Motores_giroIzquierda()
		jmp EndEstadoAdelante
	eaInicioCpCambioEdoIzda:
		cmpSensoresLinea_4 1,1,1,1
		brne eaDetener
			assign16(estadoActual, EDO_IZQUIERDA)
			assign16(edoIzda, EDO_0)
			call estadoIzquierda
			jmp EndEstadoAdelante
	eaDetener:
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
	Servo(servo_ultrasonido, servoPin)
	SistDisparo(sist_disparo, sistemaDisparoPin)
	digitalWritei(ledPin, HIGHH)
	// delay(2000)
	ret
//
// ============================================
//         P R O G R A M    L O O P
// ============================================
//
Loop:
	// digitalWrite(ledPin, varLedPin)

	// Servo_update(servo_ultrasonido)
	// SistDisparo_update(sist_disparo);
	// cpMillis(tiempo_ping, 100, i);
	// jlt(EndTiempoPing)
	// 	copy32(tiempo_ping,tiempoEnMilis);
	// 	Ping_fire(duration, 13);
	// 	Ping_toCentimeters(duration);
	// EndTiempoPing:

	// cpi32 duration,60
	// jlt(Menor)
	// 	digitalWritei(ledPin, LOWW);
	// 	Servo_microGiro(servo_ultrasonido, 4, true);
	// 	rjmp EndMenor 
	// Menor:
	// 	Servo_microGiro(servo_ultrasonido, 4, false);
	// 	// Comprobar si puede disparar
	// 	cpi16 servo_Grados(servo_ultrasonido), 110
	// 		jge(EndCompareDisparo)
	// 	cpi16 servo_Grados(servo_ultrasonido), 70
	// 		jlt(EndCompareDisparo)
	// 	SistDisparo_press(sist_disparo);
	// 	EndCompareDisparo:
	// 	// Parpadeo del led
	// 	copy(parpadeoLedPin, duration);
	// 	map16i(parpadeoLedPin, 0, 60, 0, 384);
	// 	cpMillis(tiempoActualLedPin, parpadeoLedPin, v);
	// 		jlt(EndParpadeoLed)
	// 	copy32(tiempoActualLedPin, tiempoEnMilis)
	// 	negarBool16 varLedPin
	// 	EndParpadeoLed:
	// 	digitalWrite(ledPin, varLedPin);
	// EndMenor:

	// Motores_adelante()
	// Motor_adelante(motorDerecho)
	// Motor_adelante(motorIzquierdo)

	// pruebaSensoresLinea
	pouebaErrorSensoresLinea
	// pruebaControladorMotor
	// pruebaLatchingPing
	// pruebaSistemaDisparo

	// call leerSensoresLinea
	// call actualizar
	// delay(100)
	ret // go back to loop
//
// End of source code
//
