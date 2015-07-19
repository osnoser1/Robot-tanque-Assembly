#ifndef MOTORES_ASM
#define MOTORES_ASM

#include "Motor.asm"

#define Motores(_vcc1, _gnd1, _enable1, _vcc2, _gnd2, _enable2) m_motores _vcc1, _gnd1, _enable1, _vcc2, _gnd2, _enable2
#define Motores_adelante() m_motores_adelante 255,255
#define Motores_adelante_2(_vel1,_vel2) m_motores_adelante _vel1,_vel2
#define Motores_detener() m_motores_detener
#define Motores_retroceso() m_motores_retroceso
#define Motores_giroRapidoIzquierda() m_motores_giro_rapido_izquierda 255,255
#define Motores_giroRapidoIzquierda_2(_vel1,_vel2) m_motores_giro_rapido_izquierda _vel1,_vel2
#define Motores_giroRapidoDerecha() m_motores_giro_rapido_derecha 255,255
#define Motores_giroRapidoDerecha_2(_vel1,_vel2) m_motores_giro_rapido_derecha _vel1,_vel2
#define Motores_giroIzquierda() m_motores_giro_izquierda
#define Motores_giroDerecha() m_motores_giro_derecha

.MACRO m_motores
	Motor(motorIzquierdo, @0, @1, @2)
	Motor(motorDerecho, @3, @4, @5)
.ENDM

// params @0 Velocidad, motor izquierdo
// params @1 Velocidad, motor derecho
.MACRO m_motores_adelante
	Motor_adelante_2(motorDerecho, @1)
	Motor_adelante_2(motorIzquierdo, @0)
.ENDM

.MACRO m_motores_detener
	Motor_detener(motorDerecho)
	Motor_detener(motorIzquierdo)
.ENDM

.MACRO m_motores_retroceso
	Motor_retroceso(motorDerecho)
	Motor_retroceso(motorIzquierdo)
.ENDM

// params @0 Velocidad, motor izquierdo
// params @1 Velocidad, motor derecho
.MACRO m_motores_giro_rapido_derecha
	Motor_adelante_2(motorIzquierdo, @0)
	Motor_retroceso_2(motorDerecho, @1)
.ENDM

// params @0 Velocidad, motor izquierdo
// params @1 Velocidad, motor derecho
.MACRO m_motores_giro_rapido_izquierda
	Motor_retroceso_2(motorIzquierdo, @0)
	Motor_adelante_2(motorDerecho, @1)
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
