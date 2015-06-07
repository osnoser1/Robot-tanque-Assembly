#ifndef _SERVO_INC
#define _SERVO_INC

// #if defined(__AVR_AT90USB646__) || defined(__AVR_AT90USB1286__)
// #define _useTimer3
// #define _useTimer1
#define _timer1			0
// .EQU _timer3 = 1
#define _Nbr_16timers	1
// #endif

.SET isTimer1Active = false

#define MIN_PULSE_WIDTH       544     // the shortest pulse sent to a servo  
#define MAX_PULSE_WIDTH      2400     // the longest pulse sent to a servo 
#define DEFAULT_PULSE_WIDTH  1500     // default pulse width when servo is attached
#define REFRESH_INTERVAL    20000     // minumim time to refresh servos in microseconds 

#define SERVOS_PER_TIMER        5     //12     // the maximum number of servos controlled by one timer 
#define MAX_SERVOS   (_Nbr_16timers  * SERVOS_PER_TIMER)

#define INVALID_SERVO         255     // flag indicating an invalid servo index

#define usToTicks(_us) (clockCyclesPerMicrosecond()* (_us)) / 8  // converts microseconds to tick (assumes prescale of 8) 
#define usToTicksVar(_var) m_usToTicks _var  // converts microseconds to tick (assumes prescale of 8) 

//#define ticksToUs(_ticks) (( (unsigned)_ticks * 8)/ clockCyclesPerMicrosecond() ) // converts from ticks back to microseconds


#define TRIM_DURATION       2                               // compensation ticks to trim adjust for digitalWrite delays // 12 August 2009

// convenience macros
#define SERVO_INDEX_TO_TIMER(_servo_nbr) _servo_nbr / SERVOS_PER_TIMER  // returns the timer controlling this servo
#define SERVO_INDEX_TO_CHANNEL(_servo_nbr) (_servo_nbr % SERVOS_PER_TIMER)       // returns the index of the servo on this timer
#define SERVO_INDEX(_var,_timer,_channel)  m_servo_index _var,_timer,_channel    // macro to access servo index by timer and channel
#define SERVO(_var,_ind) m_servo _var,_ind            // macro to access servo class by timer and channel

#define SERVO_MIN(_var) _servo_min_max SERVO_MIN_tmp,servoMin(_var),'-'  // minimum value in uS for this servo
#define SERVO_MAX(_var) _servo_min_max SERVO_MAX_tmp,servoMax(_var) ,'+' // maximum value in uS for this servo 

#define Servo(_var,_pin) malloc(_var, 3 * SIZE_INT) _servo_construct _var##,##_pin // 3 variables de 2 bytes
#define Servo_write(_var,_value,_type) _servo_write _var,_value,_type
#define Servo_writeMicroseconds(_var,_value,_type) _servo_writeMicroseconds _var,_value,_type

// Estructura: { servoIndex, servoMin, servoMax }

#define servoIndex(_var) 	array_dir_16(_var, 0) 
#define servoMin(_var) 		array_dir_16(_var, 1) 
#define servoMax(_var) 		array_dir_16(_var, 2) 

.DSEG
	servos: .BYTE MAX_SERVOS * 6 // Pin (2 byte), ticks (2 bytes), isActive (2 bytes)
	Channel: .BYTE _Nbr_16timers
	// ServoCount in servo_impl
.CSEG

// params @0 Variable
// params @1 Pin
.MACRO _servo_construct
	//.if SERVO_INDEX_TO_TIMER(@1) == false
	.if isTimer1Active == false
		.set isTimer1Active = true
		call initServo
	.endif
	cpi16 ServoCount,MAX_SERVOS
	jge(EndServoConstruct)
		copy16(servoIndex(@0), ServoCount)	
		inc16 ServoCount
		servo_ticks_set servoIndex(@0),usToTicks(DEFAULT_PULSE_WIDTH),'i'
		_servo_attach @0,@1,MIN_PULSE_WIDTH,MAX_PULSE_WIDTH
	EndServoConstruct:
.ENDM

// Macros para manipulación de estructura

// params @0 Variable
// params @1 Pin
.MACRO _servo_attach
	pinMode(@1, OUTPUT)
	servo_pin_nbr_set servoIndex(@0),@1
    // todo min/max check: abs(min - MIN_PULSE_WIDTH) /4 < 128 
	assign16(servoMin(@0), (MIN_PULSE_WIDTH - @2)/4)
	assign16(servoMax(@0), (MAX_PULSE_WIDTH - @3)/4)
	// initialize the timer if it has not already been initialized 
    // timer16_Sequence_t timer = SERVO_INDEX_TO_TIMER(servoIndex);
    // if(isTimerActive(timer) == false)
    //   initISR(timer);    
	servo_is_active_set servoIndex(@0),true
.ENDM

// params @0 Variable
// params @1 Valor
// params @2 type @1: {'i': 'inmediato', 'v': 'variable'}
.MACRO _servo_write
	.if @2 == 'i'
		assign16(value_servo_write, @1)
	.else
		copy16(value_servo_write, @1)
	.endif
	cpi16 value_servo_write,MIN_PULSE_WIDTH
	jge(EndServoWrite)
		assign16ge value_servo_write,180,180,'i','i'
		SERVO_MIN(@0)
		SERVO_MAX(@0)
		map16(value_servo_write, 0, 180, SERVO_MIN_tmp, SERVO_MAX_tmp)
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
	cpi16 servoIndex(@0),MAX_SERVOS
	jge(EndWriteMicroseconds)
		SERVO_MIN(@0)
		SERVO_MAX(@0)
		assign16lt value_servo_write,SERVO_MIN_tmp,SERVO_MIN_tmp,'v','v'
		assign16ge value_servo_write,SERVO_MAX_tmp,SERVO_MAX_tmp,'v','v'
		subi16 value_servo_write, TRIM_DURATION
		usToTicksVar(value_servo_write)

		in rmp1,SREG
		write8 oldSREG,rmp1

		cli()
		servo_ticks_set servoIndex(@0),value_servo_write,'v'

		read8 rmp1,oldSREG
		out SREG,rmp1
	EndWriteMicroseconds:
.ENDM

// params @0 Variable temporal SERVO_XXX_temp
// params @1 Variable servoMin o servoMax de this
// params @2 Caracter que indica si es min o max (-, +)
.MACRO _servo_min_max
	read16 T2,@1
	mul_16i T2,4
	.if @2 == '-'
		ldiw T1,MIN_PULSE_WIDTH
	.else
		ldiw T1,MAX_PULSE_WIDTH
	.endif
	subw T1,T2
	write16 @0,T1
.ENDM

// Macros para manipulación de arreglo servos

// params @0 Variable, índice
// params @1 Valor
// params @2 type @1: {'i': 'inmediato', 'v': 'variable'}
.MACRO servo_ticks_set
	array_get_dir_elem(servo_indice_tmp,@0,servos,6)
	array_set_elem_16(1, servo_indice_tmp, @1, 'i', 'p', @2)
.ENDM

// params @0 Variable, índice
// params @1 Valor inmediato
.MACRO servo_pin_nbr_set
	array_get_dir_elem(servo_indice_tmp,@0,servos,6)
	array_set_elem_16(0, servo_indice_tmp, @1, 'i', 'p', 'i')
.ENDM

// params @0 Variable, índice
// params @1 Valor inmediato
.MACRO servo_is_active_set
	array_get_dir_elem(servo_indice_tmp,@0,servos,6)
	array_set_elem_16(2, servo_indice_tmp, @1, 'i', 'p', 'i')
.ENDM

// params @0 Variable
// params @1 Puntero a elemento
.MACRO servo_is_active_get
	read16 X,@1
	ldiw T1,4
	addw X,T1
	ldw T1,X
	write16 @0,T1
.ENDM

// params @0 Variable
// params @1 Puntero a elemento
.MACRO servo_pin_nbr_get
	read16 X,@1
	ldw T1,X
	write16 @0,T1
.ENDM

// params @0 Variable
// params @1 Puntero a elemento
.MACRO servo_ticks_get
	read16 X,@1
	ldiw T1,2
	addw X,T1
	ldw T1,X
	write16 @0,T1
.ENDM

// clockCyclesPerMicrosecond()* _us) / 8
// params @0 Variable
.MACRO m_usToTicks
	read16 T1,@0
	ldiw T2,clockCyclesPerMicrosecond()
	mul_32 N,T1,T2
	ldiw T1,8
	div_32_16 N,T1,VH
	write16 @0,T3  // T3 es la parte baja de N
.ENDM 

// params @0 Variable
// params @1 Valor inmediato, Timer
// params @2 Variable, canal del timer
.MACRO m_servo_index
	assign16(@0, @1*SERVOS_PER_TIMER)
	sum16 @0,@2
.ENDM

// params @0 Puntero donde almacenará dirección de instancia
// params @1 Variable, índice de elem. servos
.MACRO m_servo
	array_get_dir_elem(@0, @1, servos, 6)
.ENDM

#endif // _SERVO_INC
