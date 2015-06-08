#ifndef _SISTEMA_DISPARO_ASM_
#define _SISTEMA_DISPARO_ASM_

#define RETARDO 				2000 // 2 segundos
#define DISPARO_ANGULO 			60

#define SistDisparo(_var,_pin) malloc(_var, SERVO_SIZE + 1 * SIZE_INT + 1 * SIZE_LONG) _sistema_disparo_construct _var,_pin // 3 variables de 2 bytes.
#define SistDisparo_update(_var) _sistema_disparo_update _var
#define SistDisparo_press(_var) _sistema_disparo_press _var

#define disparo_TiempoActual(_var) 		array_dir_32(_var, 0)  // 32 bits
#define disparo_Grados(_var) 			array_dir_16(_var, 2) // 16 bits
#define disparo_Servo(_var) 			array_dir_16(_var, 3) // SERVO_SIZE

// params @0 Variable
// params @1 Pin
.MACRO _sistema_disparo_construct
	_servo_construct disparo_Servo(@0),@1
	Servo_write(disparo_Servo(@0), 0, 'i')
	assign32(disparo_TiempoActual(@0), 0)
	assign16(disparo_Grados(@0), 0)
.ENDM

// params @0 Variable
.MACRO _sistema_disparo_update
	Servo_update(disparo_Servo(@0))
	// Servo_giro_3(disparo_Servo(@0), 4, true)
.ENDM

// params @0 Variable
.MACRO _sistema_disparo_press
	cpMillis(disparo_TiempoActual(@0), RETARDO, i)
		jlt(EndSistemaDisparoPress)
	copy32(disparo_TiempoActual(@0), tiempoEnMilis)
	sumi16 disparo_Grados(@0),DISPARO_ANGULO
	assign16ge disparo_Grados(@0),181,0,'i','i'
	Servo_write(disparo_Servo(@0), disparo_Grados(@0), 'v')
	EndSistemaDisparoPress:
.ENDM

#endif
