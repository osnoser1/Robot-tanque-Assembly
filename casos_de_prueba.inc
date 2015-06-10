#ifndef CASOS_DE_PRUEBA_INC
#define CASOS_DE_PRUEBA_INC

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
	Servo_update(servo_ultrasonido)
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
		digitalWritei(ledPin, HIGHH)
		Servo_microGiro(servo_ultrasonido, 4, false)
	EndMenor:
.ENDM

.MACRO pruebaSistemaDisparo
	esNegro16 valDerecha,DERECHA
	digitalWrite(ledPin, valDerecha)
	cpi16 valDerecha, true
		jne(EndPruebaSistemaDisparo)
	SistDisparo_press(sist_disparo);
	EndPruebaSistemaDisparo:
.ENDM

#endif // CASOS_DE_PRUEBA_INC
