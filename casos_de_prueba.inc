#ifndef CASOS_DE_PRUEBA_INC
#define CASOS_DE_PRUEBA_INC

// Prueba sensores linea
.MACRO pruebaSensoresLinea
	esNegro16 valIzquierda,IZQUIERDA
	esNegro16 valDerecha,DERECHA
	esNegro16 valCentroIzquierda,CENTRO_IZQUIERDA
	esNegro16 valCentroDerecha,CENTRO_DERECHA
	digitalWrite(vccA,valIzquierda)
	digitalWrite(gndA,valCentroIzquierda)
	digitalWrite(vccB,valCentroDerecha)
	digitalWrite(gndB,valDerecha)
	digitalWritei(enableA,HIGHH)
	digitalWritei(enableB,HIGHH)
.ENDM

.MACRO pruebaErrorSensoresLinea
	LineaError_actualizar(linea_IZQUIERDA, IZQUIERDA)
	LineaError_actualizar(linea_CENTRO_IZQUIERDA, CENTRO_IZQUIERDA)
	LineaError_actualizar(linea_CENTRO_DERECHA, CENTRO_DERECHA)
	LineaError_actualizar(linea_DERECHA, DERECHA)
	digitalWrite(vccA, lineaError_Negro(linea_IZQUIERDA))
	digitalWrite(gndA, lineaError_Negro(linea_CENTRO_IZQUIERDA))
	digitalWrite(vccB, lineaError_Negro(linea_CENTRO_DERECHA))
	digitalWrite(gndB, lineaError_Negro(linea_DERECHA))
	digitalWritei(enableA,HIGHH)
	digitalWritei(enableB,HIGHH)
.ENDM

// Prueba controlador de motor
.MACRO pruebaControladorMotor
	Motores_adelante()
	delay(3000)
	Motores_retroceso()
	delay(3000)
	Motores_giroRapidoIzquierda()
	delay(3000)
	Motores_giroRapidoDerecha()
	delay(3000)
	Motores_detener()
	delay(3000)
	Motores_giroDerecha()
	delay(3000)
	Motores_detener()
	delay(3000)
	Motores_giroIzquierda()
	delay(3000)
	Motores_detener()
	delay(3000)
.ENDM

// Prueba integración latching con sensor ultrasónico PING
.MACRO pruebaLatchingPing
	// Servo_update(servo_ultrasonido)
	cpMillis(tiempo_ping, 100, i)
	jlt(EndTiempoPing)
		copy32(tiempo_ping,tiempoEnMilis)
		Ping_fire(duration, 13)
		Ping_toCentimeters(duration)
	EndTiempoPing:
	cpi32 duration,60
	jlt(Menor)
		digitalWritei(ledPin, LOWW)
		Servo_microGiro(servo_ultrasonido, 4, true)
		rjmp EndMenor 
	Menor:
		Servo_microGiro(servo_ultrasonido, 4, false)
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
.ENDM

.MACRO pruebaSistemaDisparo
	SistDisparo_update(sist_disparo);
	esNegro16 valDerecha,DERECHA
	digitalWrite(ledPin, valDerecha)
	cpi16 valDerecha, true
		jne(EndPruebaSistemaDisparo)
	SistDisparo_press(sist_disparo);
	EndPruebaSistemaDisparo:
.ENDM

#endif // CASOS_DE_PRUEBA_INC
