#ifndef _SERVO_INC
#define _SERVO_INC

.SET firstTime = false

#define MIN_PULSE_WIDTH       544     // the shortest pulse sent to a servo  
#define MAX_PULSE_WIDTH      2400     // the longest pulse sent to a servo 
#define DEFAULT_PULSE_WIDTH  1500     // default pulse width when servo is attached
#define REFRESH_INTERVAL    20000     // minumim time to refresh servos in microseconds 

#define usToTicks(_us) (clockCyclesPerMicrosecond()* (_us)) / 8  // converts microseconds to tick (assumes prescale of 8) 

#define TRIM_DURATION       2                               // compensation ticks to trim adjust for digitalWrite delays // 12 August 2009

#define SERVO_SIZE 			8 * SIZE_INT + 2 * SIZE_LONG

// convenience macros

#define Servo(_var,_pin) malloc(_var,SERVO_SIZE) _servo_construct _var##,##_pin // 3 variables de 2 bytes
#define Servo_write(_var,_value,_type) _servo_write _var,_value,_type
#define Servo_writeMicroseconds(_var,_value,_type) _servo_writeMicroseconds _var,_value,_type
#define Servo_update(_var) _servo_update _var
#define Servo_giro_5(_var, _millis, _bool, _limInf, _limSup) _servo_giro _var,_millis,_bool,_limInf,_limSup,'i','i'
#define Servo_giro_3(_var, _millis, _bool) _servo_giro _var,_millis,_bool,0,180,'i','i'
#define Servo_giro(_var, _millis, _bool, _limInf, _limSup,_type1,_type2) _servo_giro _var,_millis,_bool,_limInf,_limSup,_type1,_type2
#define Servo_microGiro(_var, _millis, _bool) _servo_micro_giro _var,_millis,_bool,30,135,'i','i'
// Estructura: { servo_Pin, servoMin, servoMax }

#define servo_Pin(_var) 				array_dir_16(_var, 0) 
#define servo_PulseWidth(_var) 			array_dir_16(_var, 1) 
#define servo_IsPulseWidth(_var) 		array_dir_16(_var, 2) 
#define servo_IsGiro(_var) 				array_dir_16(_var, 3) 
#define servo_Grados(_var) 				array_dir_16(_var, 4)
#define servo_Sentido(_var) 			array_dir_16(_var, 5) 
#define servo_barridoLimInf(_var) 		array_dir_16(_var, 6) 
#define servo_barridoLimSup(_var) 		array_dir_16(_var, 7) 
#define servo_TiempoActual(_var) 		array_dir_16(_var, 8)  // 32 bits
#define servo_TiempoActualGiro(_var) 	array_dir_16(_var, 10)  // 32 bits

// params @0 Variable
// params @1 Pin
.MACRO _servo_construct
	//.if SERVO_INDEX_TO_TIMER(@1) == false
	.if firstTime == false
		.set firstTime = true
		call initServo
	.endif
	assign16(servo_Pin(@0), @1)
	assign16(servo_PulseWidth(@0), DEFAULT_PULSE_WIDTH)
	assign32(servo_TiempoActual(@0), 0)
	assign32(servo_TiempoActualGiro(@0), 0)
	assign16(servo_IsPulseWidth(@0), false)
	assign16(servo_IsGiro(@0), true)
	assign16(servo_Grados(@0), 90)
	assign16(servo_barridoLimInf(@0), 0)
	assign16(servo_barridoLimSup(@0), 180)
	assign16(servo_Grados(@0), 90)
	assign16(servo_Sentido(@0), 1)
.ENDM

// Macros para manipulación de estructura

// params @0 Variable
// params @1 Valor
// params @2 type @1: {'i': 'inmediato', 'v': 'variable'}
.MACRO _servo_write
	.if @2 == 'i'
		assign16(value_servo_write, @1)
		assign16(servo_Grados(@0), @1)
	.else
		copy16(value_servo_write, @1)
		copy16(servo_Grados(@0), @1)
	.endif
	cpi16 value_servo_write,MIN_PULSE_WIDTH
	jge(EndServoWrite)
		assign16ge value_servo_write,180,180,'i','i'
		map16i(value_servo_write, 0, 180, MIN_PULSE_WIDTH, MAX_PULSE_WIDTH)
	EndServoWrite:
	Servo_writeMicroseconds(@0, value_servo_write, 'v')
.ENDM

// params @0 Variable
// params @1 Valor
// params @2 type @1: {'i': 'inmediato', 'v': 'variable'}
.MACRO _servo_writeMicroseconds
	.if @2 == 'i'
		assign16(value_servo_write, @1)
	.else
		copy16(value_servo_write, @1)
	.endif
	assign16lt value_servo_write,MIN_PULSE_WIDTH,MIN_PULSE_WIDTH,'i','i'
	assign16ge value_servo_write,MAX_PULSE_WIDTH,MAX_PULSE_WIDTH,'i','i'
	subi16 value_servo_write, TRIM_DURATION
	copy16(servo_PulseWidth(@0), value_servo_write)
.ENDM

// params @0 Variable
.MACRO _servo_update
	micros(tiempoEnMicros)
	copy32(temp_long, tiempoEnMicros)
	sub32 temp_long,servo_TiempoActual(@0)
	cpi16 servo_IsPulseWidth(@0), true
	jeq(IsPulseWidth)
		cpi32 temp_long,REFRESH_INTERVAL
		rjmp EndPulse
	IsPulseWidth:
		cp_32_16(temp_long, servo_PulseWidth(@0))
	EndPulse:
	jlt(EndServoUpdate)
		copy32(servo_TiempoActual(@0), tiempoEnMicros)
		negarBool16 servo_IsPulseWidth(@0)
		digitalWrite_v_v(servo_Pin(@0), servo_IsPulseWidth(@0))
	EndServoUpdate:
.ENDM

// params @0 Variable
// params @1 Tiempo en milisegundos
// params @2 Boolean, indicdor de giro
// params @3 Límite inferior
// params @4 Límite superior
// params @5 Tipo @3: {'i': 'inmediato', 'v': 'variable'}
// params @6 Tipo @4: {'i': 'inmediato', 'v': 'variable'}
.MACRO _servo_giro
	ldiw T2,@2
	write16 servo_IsGiro(@0),T2
	cpiw T2,1
	jeq(EsIgual)
		jmp EndServoGiro
	EsIgual:
		cpMillis(servo_TiempoActualGiro(@0), @1, i)
		jlt(EndServoGiro)
			copy32(servo_TiempoActualGiro(@0), tiempoEnMilis)
			assignToOther16lt servo_Sentido(@0),1,servo_Grados(@0),@3,'i','v',@5
			assignToOther16ge servo_Sentido(@0),-1,servo_Grados(@0),@4,'i','v',@6
			sum16 servo_Grados(@0),servo_Sentido(@0)
			Servo_write(@0, servo_Grados(@0), 'v')
	EndServoGiro:
.ENDM

// params @0 Variable
// params @1 Tiempo en milisegundos
// params @2 Boolean, indicdor de giro
// params @3 Límite inferior
// params @4 Límite superior
// params @5 Tipo @3: {'i': 'inmediato', 'v': 'variable'}
// params @6 Tipo @4: {'i': 'inmediato', 'v': 'variable'}
.MACRO _servo_micro_giro
 	ldiw T2,@2
 	cpiw T2,true
 	jeq(EsIgual)	
 		write16 servo_IsGiro(@0),T2
 		jmp EndServoGiro
 	EsIgual:
 		cpi16 servo_IsGiro(@0),true
 		jeq(ContinueServoMicro)
 			copy16(servo_barridoLimSup(@0), servo_Grados(@0))
 			copy16(servo_barridoLimInf(@0), servo_Grados(@0))
 		ContinueServoMicro:
 		assign16(servo_IsGiro(@0), true)
 		cpMillis(servo_TiempoActualGiro(@0), @1, i)
 		jlt(EndServoGiro)
 			copy32(servo_TiempoActualGiro(@0), tiempoEnMilis)
 			assignToOther16lt servo_Sentido(@0),1,servo_Grados(@0),servo_barridoLimInf(@0),'i','v','v'
 			assignToOther16ge servo_Sentido(@0),-1,servo_Grados(@0),servo_barridoLimSup(@0),'i','v','v'
 			cp16 servo_Grados(@0), servo_barridoLimSup(@0)
 			brge SumaEsp
 				jmp EndSumaEsp
 			SumaEsp:
 				sumi16 servo_barridoLimSup(@0),10
 			EndSumaEsp:
 			cp16 servo_Grados(@0), servo_barridoLimInf(@0)
 			brlt RestaEsp
 				jmp EndRestaEsp
 			RestaEsp:
 				sumi16 servo_barridoLimInf(@0),-10
 			EndRestaEsp:
 			assignToOther16ge servo_barridoLimInf(@0),@3,servo_barridoLimSup(@0),@4,@5,'v',@6
 			assignToOther16lt servo_barridoLimSup(@0),@4,servo_barridoLimInf(@0),@3,@6,'v',@5
 			assign16ge servo_barridoLimSup(@0),@4,@4,@6,@6
 			assign16lt servo_barridoLimInf(@0),@3,@3,@5,@5
 			sum16 servo_Grados(@0),servo_Sentido(@0)
 			Servo_write(@0, servo_Grados(@0), 'v')
	EndServoGiro:
.ENDM

#endif // _SERVO_INC
