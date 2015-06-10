#ifndef MOTORES_ASM
#define MOTORES_ASM

#include "Motor.asm"

#define Motores(_vcc1, _gnd1, _vcc2, _gnd2) m_motores _vcc1, _gnd1, _vcc2, _gnd2
#define Motores_adelante() m_motores_adelante
#define Motores_detener() m_motores_detener
#define Motores_retroceso() m_motores_retroceso
#define Motores_giroRapidoIzquierda() m_motores_giro_izquierda
#define Motores_giroRapidoDerecha() m_motores_giro_rapido_derecha
#define Motores_giroIzquierda() m_motores_giro_izquierda
#define Motores_giroDerecha() m_motores_giro_derecha

.MACRO m_motores
	Motor(motorIzquierdo, @0, @1)
	Motor(motorDerecho, @2, @3)
.ENDM

.MACRO m_motores_adelante
	Motor_adelante(motorDerecho)
	Motor_adelante(motorIzquierdo)
.ENDM

.MACRO m_motores_detener
	Motor_detener(motorDerecho)
	Motor_detener(motorIzquierdo)
.ENDM

.MACRO m_motores_retroceso
	Motor_retroceso(motorDerecho)
	Motor_retroceso(motorIzquierdo)
.ENDM

.MACRO m_motores_giro_rapido_derecha
	Motor_adelante(motorIzquierdo)
	Motor_retroceso(motorDerecho)
.ENDM

.MACRO m_motores_giro_rapido_izquierda
	Motor_retroceso(motorIzquierdo)
	Motor_adelante(motorDerecho)
.ENDM

.MACRO m_motores_giro_derecha
	Motor_adelante(motorIzquierdo)
	Motor_detener(motorDerecho)
.ENDM

.MACRO m_motores_giro_izquierda
	Motor_detener(motorIzquierdo)
	Motor_adelante(motorDerecho)
.ENDM


#endif // MOTORES_ASM
