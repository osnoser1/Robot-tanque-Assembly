#ifndef MOTOR_ASM
#define MOTOR_ASM

#define Motor(_var, _vcc, _gnd, _enable) .EQU CONCAT(_var,Vcc) = _vcc .EQU CONCAT(_var,Gnd) = _gnd .EQU CONCAT(_var,Enable) = _enable m_motor_construct CONCAT(_var,Vcc), CONCAT(_var,Gnd), CONCAT(_var,Enable)
//#define Motor_4(_var, _vcc, _gnd, _enable)
#define Motor_adelante(_var) _motor_adelante CONCAT(_var,Vcc), CONCAT(_var,Gnd), CONCAT(_var,Enable)
#define Motor_adelante_2(_var, _vel) _motor_adelante_pwm CONCAT(_var,Vcc), CONCAT(_var,Gnd), CONCAT(_var,Enable), _vel
#define Motor_detener(_var) _motor_detener CONCAT(_var,Vcc), CONCAT(_var,Gnd), CONCAT(_var,Enable)
#define Motor_retroceso(_var) _motor_retroceso CONCAT(_var,Vcc), CONCAT(_var,Gnd), CONCAT(_var,Enable)
#define Motor_retroceso_2(_var, _vel) _motor_retroceso_pwm CONCAT(_var,Vcc), CONCAT(_var,Gnd), CONCAT(_var,Enable), _vel

// params @0 Valor, vcc
// params @1 Valor, gnd
// params @2 Valor, enable
.MACRO m_motor_construct 
	pinMode(@0, OUTPUT)
	pinMode(@1, OUTPUT)
	pinMode(@2, OUTPUT)
.ENDM

// params @0 Valor, vcc
// params @1 Valor, gnd
// params @2 Valor, enable
.MACRO _motor_adelante 
	digitalWritei(@2, HIGHH)
	digitalWritei(@0, HIGHH)
	digitalWritei(@1, LOWW)
.ENDM

// params @0 Valor, vcc
// params @1 Valor, gnd
// params @2 Valor, enable
.MACRO _motor_detener
	digitalWritei(@2, LOWW)
	digitalWritei(@0, LOWW)
	digitalWritei(@1, LOWW)
.ENDM

// params @0 Valor, vcc
// params @1 Valor, gnd
// params @2 Valor, enable
.MACRO _motor_retroceso
	digitalWritei(@2, HIGHH)
	digitalWritei(@0, LOWW)
	digitalWritei(@1, HIGHH)
.ENDM

// params @0 Valor, vcc
// params @1 Valor, gnd
// params @2 Constante, enable
// params @3 Constante, velocidad
.MACRO _motor_retroceso_pwm
	digitalWritei(@0, LOWW)
	digitalWritei(@1, HIGHH)
	analogWritei @2, @3
.ENDM

// params @0 Valor, vcc
// params @1 Valor, gnd
// params @2 Constante, enable
// params @3 Constante, velocidad
.MACRO _motor_adelante_pwm
	digitalWritei(@0, HIGHH)
	digitalWritei(@1, LOWW)
	analogWritei @2, @3
.ENDM

#endif // MOTOR_ASM
