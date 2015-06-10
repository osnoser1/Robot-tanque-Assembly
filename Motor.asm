#ifndef MOTOR_ASM
#define MOTOR_ASM

#define Motor(_var, _vcc, _gnd) .EQU _var = 0 .EQU CONCAT(_var,vcc) = _var .EQU CONCAT(_var,gnd) = _gnd m_motor_construct CONCAT(_var,vcc), CONCAT(_var,gnd)
//#define Motor_4(_var, _vcc, _gnd, _enable)
#define Motor_adelante(_var) _motor_adelante CONCAT(_var,vcc), CONCAT(_var,gnd)
#define Motor_detener(_var) _motor_adelante CONCAT(_var,vcc), CONCAT(_var,gnd)
#define Motor_retroceso(_var) _motor_adelante CONCAT(_var,vcc), CONCAT(_var,gnd)

// params @0 Valor, vcc
// params @1 Valor, gnd
.MACRO m_motor_construct 
	pinMode(@0, OUTPUT)
	pinMode(@1, OUTPUT)
.ENDM

// params @0 Valor, vcc
// params @1 Valor, gnd
.MACRO _motor_adelante 
	digitalWritei(@0, HIGHH)
	digitalWritei(@1, LOWW)
.ENDM

// params @0 Valor, vcc
// params @1 Valor, gnd
.MACRO _motor_detener
	digitalWritei(@0, LOWW)
	digitalWritei(@1, LOWW)
.ENDM

// params @0 Valor, vcc
// params @1 Valor, gnd
.MACRO _motor_retroceso
	digitalWritei(@0, LOWW)
	digitalWritei(@1, HIGHH)
.ENDM


.MACRO motorAdelantePwmi
	analogWritei @0,@2
	digitalWritei(@1, LOWW)
.ENDM

#endif // MOTOR_ASM
