/*
 * arduino.inc
 *
 *  Created: 2/7/2015 12:52:03 AM
 *   Author: AlfonsoAndr?s
 */ 
#ifndef _ARDUINO_INC_
#define _ARDUINO_INC_

#define HIGHH_asm sbi
#define LOWW_asm cbi
#define CORE_INSTRUCCION(_var) CONCAT(_var,_asm)

// #define pinMode(pin,mode) m_pinMode pin,mode
#define pinMode(pin,mode) m_fast_pin_mode pin,mode
#define pinMode_v_i(pin,mode) m_pinMode_v_i pin,mode
#define digitalWrite(pin,value) m_digitalWrite pin,value,'v'
#define digitalWritei(pin,value) m_digitalWrite pin,value,'i'
#define digitalWriteFast(pin,value) CORE_INSTRUCCION(value) CORE_PORTREG(pin), CORE_BIT(pin)
#define digitalWrite_v_i(pin,value) m_digitalWrite_v_i pin,value
#define digitalWrite_v_v(pin,value) m_digitalWrite_v_v pin,value
#define pulseIn(var,pin,state) m_pulse_in var,CORE_PIN_CONCATENATE(pin, PINREG),CORE_PIN_CONCATENATE(pin, BIT),state


.MACRO cmp
   ldi rmp1,@0
   cpi rmp1,@1
.ENDMACRO

.MACRO ldie
	breq EqualLdie // Si Z = 1, son iguales y bifurco a EqualLdie
		ldi @0,@2 // Asigno el tercer parámetro en el registro (primer parámetro)
		rjmp EndLdie
	EqualLdie:
		ldi @0,@1 // Asigno el segundo parámetro en el registro (primer parámetro)
	EndLdie:
.ENDMACRO

.MACRO digitalReadPort
	in @0,@1
	andi @0,@2
	cpi @0,0
	ldie @0,0,1
.ENDMACRO

.MACRO digitalRead
	cmp @1,0
	brne PC+10
		digitalReadPort @0,CORE_PIN0_PINREG,CORE_PIN0_BITMASK
		jmp EndDigitalRead
	cmp @1,1
	brne PC+10
		digitalReadPort @0,CORE_PIN1_PINREG,CORE_PIN1_BITMASK
		jmp EndDigitalRead
	cmp @1,2
	brne PC+10
		digitalReadPort @0,CORE_PIN2_PINREG,CORE_PIN2_BITMASK
		jmp EndDigitalRead
	cmp @1,3
	brne PC+10
		digitalReadPort @0,CORE_PIN3_PINREG,CORE_PIN3_BITMASK
		jmp EndDigitalRead
	cmp @1,4
	brne PC+10
		digitalReadPort @0,CORE_PIN4_PINREG,CORE_PIN4_BITMASK
		jmp EndDigitalRead
	cmp @1,5
	brne PC+10
		digitalReadPort @0,CORE_PIN5_PINREG,CORE_PIN5_BITMASK
		jmp EndDigitalRead
	cmp @1,6
	brne PC+10
		digitalReadPort @0,CORE_PIN6_PINREG,CORE_PIN6_BITMASK
		jmp EndDigitalRead
	cmp @1,7
	brne PC+10
		digitalReadPort @0,CORE_PIN7_PINREG,CORE_PIN7_BITMASK
		jmp EndDigitalRead
	cmp @1,8
	brne PC+10
		digitalReadPort @0,CORE_PIN8_PINREG,CORE_PIN8_BITMASK
		jmp EndDigitalRead
	cmp @1,9
	brne PC+10
		digitalReadPort @0,CORE_PIN9_PINREG,CORE_PIN9_BITMASK
		jmp EndDigitalRead
	cmp @1,10
	brne PC+10
		digitalReadPort @0,CORE_PIN10_PINREG,CORE_PIN10_BITMASK
		jmp EndDigitalRead
	cmp @1,11
	brne PC+10
		digitalReadPort @0,CORE_PIN11_PINREG,CORE_PIN11_BITMASK
		jmp EndDigitalRead
	cmp @1,12
	brne PC+10
		digitalReadPort @0,CORE_PIN12_PINREG,CORE_PIN12_BITMASK
		jmp EndDigitalRead
	cmp @1,13
	brne PC+10
		digitalReadPort @0,CORE_PIN13_PINREG,CORE_PIN13_BITMASK
		jmp EndDigitalRead
	cmp @1,14
	brne PC+10
		digitalReadPort @0,CORE_PIN14_PINREG,CORE_PIN14_BITMASK
		jmp EndDigitalRead
	cmp @1,15
	brne PC+10
		digitalReadPort @0,CORE_PIN15_PINREG,CORE_PIN15_BITMASK
		jmp EndDigitalRead
	cmp @1,16
	brne PC+10
		digitalReadPort @0,CORE_PIN16_PINREG,CORE_PIN16_BITMASK
		jmp EndDigitalRead
	cmp @1,17
	brne PC+10
		digitalReadPort @0,CORE_PIN17_PINREG,CORE_PIN17_BITMASK
		jmp EndDigitalRead
	cmp @1,18
	brne PC+10
		digitalReadPort @0,CORE_PIN18_PINREG,CORE_PIN18_BITMASK
		jmp EndDigitalRead
	cmp @1,19
	brne PC+10
		digitalReadPort @0,CORE_PIN19_PINREG,CORE_PIN19_BITMASK
		jmp EndDigitalRead
	cmp @1,20
	brne PC+10
		digitalReadPort @0,CORE_PIN20_PINREG,CORE_PIN20_BITMASK
		jmp EndDigitalRead
	cmp @1,21
	brne PC+10
		digitalReadPort @0,CORE_PIN21_PINREG,CORE_PIN21_BITMASK
		jmp EndDigitalRead
	cmp @1,22
	brne PC+10
		digitalReadPort @0,CORE_PIN22_PINREG,CORE_PIN22_BITMASK
		jmp EndDigitalRead
	cmp @1,23
	brne PC+10
		digitalReadPort @0,CORE_PIN23_PINREG,CORE_PIN23_BITMASK
		jmp EndDigitalRead
	cmp @1,24
	brne PC+10
		digitalReadPort @0,CORE_PIN24_PINREG,CORE_PIN24_BITMASK
		jmp EndDigitalRead
	cmp @1,25
	brne PC+10
		digitalReadPort @0,CORE_PIN25_PINREG,CORE_PIN25_BITMASK
		jmp EndDigitalRead
	cmp @1,26
	brne PC+10
		digitalReadPort @0,CORE_PIN26_PINREG,CORE_PIN26_BITMASK
		jmp EndDigitalRead
	cmp @1,27
	brne PC+10
		digitalReadPort @0,CORE_PIN27_PINREG,CORE_PIN27_BITMASK
		jmp EndDigitalRead
	cmp @1,28
	brne PC+10
		digitalReadPort @0,CORE_PIN28_PINREG,CORE_PIN28_BITMASK
		jmp EndDigitalRead
	cmp @1,29
	brne PC+10
		digitalReadPort @0,CORE_PIN29_PINREG,CORE_PIN29_BITMASK
		jmp EndDigitalRead
	cmp @1,30
	brne PC+10
		digitalReadPort @0,CORE_PIN30_PINREG,CORE_PIN30_BITMASK
		jmp EndDigitalRead
	cmp @1,31
	brne PC+10
		digitalReadPort @0,CORE_PIN31_PINREG,CORE_PIN31_BITMASK
		jmp EndDigitalRead
	cmp @1,32
	brne PC+10
		digitalReadPort @0,CORE_PIN32_PINREG,CORE_PIN32_BITMASK
		jmp EndDigitalRead
	cmp @1,33
	brne PC+10
		digitalReadPort @0,CORE_PIN33_PINREG,CORE_PIN33_BITMASK
		jmp EndDigitalRead
	cmp @1,34
	brne PC+10
		digitalReadPort @0,CORE_PIN34_PINREG,CORE_PIN34_BITMASK
		jmp EndDigitalRead
	cmp @1,35
	brne PC+10
		digitalReadPort @0,CORE_PIN35_PINREG,CORE_PIN35_BITMASK
		jmp EndDigitalRead
	cmp @1,36
	brne PC+10
		digitalReadPort @0,CORE_PIN36_PINREG,CORE_PIN36_BITMASK
		jmp EndDigitalRead
	cmp @1,37
	brne PC+10
		digitalReadPort @0,CORE_PIN37_PINREG,CORE_PIN37_BITMASK
		jmp EndDigitalRead
	cmp @1,38
	brne PC+10
		digitalReadPort @0,CORE_PIN38_PINREG,CORE_PIN38_BITMASK
		jmp EndDigitalRead
	cmp @1,39
	brne PC+10
		digitalReadPort @0,CORE_PIN39_PINREG,CORE_PIN39_BITMASK
		jmp EndDigitalRead
	cmp @1,40
	brne PC+10
		digitalReadPort @0,CORE_PIN40_PINREG,CORE_PIN40_BITMASK
		jmp EndDigitalRead
	cmp @1,41
	brne PC+10
		digitalReadPort @0,CORE_PIN41_PINREG,CORE_PIN41_BITMASK
		jmp EndDigitalRead
	cmp @1,42
	brne PC+10
		digitalReadPort @0,CORE_PIN42_PINREG,CORE_PIN42_BITMASK
		jmp EndDigitalRead
	cmp @1,43
	brne PC+10
		digitalReadPort @0,CORE_PIN43_PINREG,CORE_PIN43_BITMASK
		jmp EndDigitalRead
	cmp @1,44
	brne PC+10
		digitalReadPort @0,CORE_PIN44_PINREG,CORE_PIN44_BITMASK
		jmp EndDigitalRead
	cmp @1,45
	brne PC+10
		digitalReadPort @0,CORE_PIN45_PINREG,CORE_PIN45_BITMASK
		jmp EndDigitalRead
	CLR @0
	EndDigitalRead:
.ENDMACRO

// params @0 Valor inmediato, pin seleccionado
// params @1 HIGH, LOW
// params @2 Tipo @1: {'i': 'inmediato', 'v': 'variable'}
.MACRO m_digitalWrite
	ldi rmp2,@0
	.if @2 == 'v'
		read8 rmp3,@1
	.else
		ldi rmp3,@1
	.endif
	call DigitalWriteSub
.ENDMACRO

// params @0 Variable, pin seleccionado
// params @1 Valor inmediato, HIGH, LOW
.MACRO m_digitalWrite_v_i
	read8 rmp2,@0
	ldi rmp3,@1
	call DigitalWriteSub
.ENDMACRO

// params @0 Variable, pin seleccionado
// params @1 Variable, HIGH, LOW
.MACRO m_digitalWrite_v_v
	read8 rmp2,@0
	read8 rmp3,@1
	call DigitalWriteSub
.ENDMACRO

// params @0 Pin seleccionado
// params @1 Valor comprendido entre 0 y 255
.MACRO analogWritei
	ldi rmp2,@0
	ldi rmp3,@1
	call AnalogWriteSub
.ENDMACRO

// params @0 Variable, pin seleccionado
// params @1 Valor inmediato, HIGH, LOW
.MACRO m_fast_digital_write
	CORE_INSTRUCCION(@1) CORE_PORTREG(@0), CORE_BIT(@0)
.ENDM

// params @0 Pin seleccionado
// params @1 Direccion de memoria, 1 byte.
.MACRO analogWrite
	ldi rmp2,@0
	read8 rmp3,@1
	call AnalogWriteSub
.ENDMACRO

// params @0 Dirección de memoria, 2 bytes
// params @1 Pin seleccionado
.MACRO analogRead
	ldiw X,@0
	ldi rmp1,@1
	call AnalogReadSub
.ENDMACRO

.MACRO m_pinMode
   	ldi rmp2,@0
	ldi rmp3,@1
	call PinModeSub
.ENDMACRO

.MACRO m_pinMode_v_i
   	read8 rmp2,@0
	ldi rmp3,@1
	call PinModeSub
.ENDMACRO

// params @0 Variable, 4 bytes
.MACRO m_millis
	in rmp1,SREG
	cli()

	// disable interrupts while we read timer0_millis or we might get an
    // inconsistent value (e.g. in the middle of a write to timer0_millis)
	read32 N,timer0_millis_count
	out SREG,rmp1

	write32 @0,N
.ENDM

// params @0 Variable, 4 bytes
.MACRO m_micros
	in XL,SREG

	cli()
	read32 N,timer0_overflow_count
	in rmp1,TCNT0

// if ((TIFR0 & _BV(TOV0)) && (t & 255))
	in rmp2,TIFR0
	andi rmp2,_BV(TOV0)
	cpi rmp1,255
	jge(EndIncT0OC)
		cpi rmp2,0
		jeq(EndIncT0OC)
			incr32 N
	EndIncT0OC:
	out SREG,XL
	lsl32 N
	lsl32 N
	lsl32 N
	lsl32 N
	lsl32 N
	lsl32 N
	lsl32 N  
	lsl32 N
	ldi rmp2,0
	ldi rmp3,0
	ldi rmp4,0
	add32 N,M
	lsl32 N
	lsl32 N
	write32 @0,N
.ENDM

// wiring.h

// params @0 Dirección de memoria, 4 bytes
// .MACRO clockCyclesToMicroseconds
//  (a) / clockCyclesPerMicrosecond
// .ENDM

// params @0 Dirección de memoria, 4 bytes
// .MACRO microsecondsToClockCycles
//  ( (a) * clockCyclesPerMicrosecond() )
// .ENDM

// wiring.c

#define PULSEIN_CYCLES_PER_LOOP  17
#define PULSEIN_CYCLES_LATENCY   5

// params @0 Variable, 32 bits
// params @1 Valor inmediato, pinreg
// params @2 Valor inmediato, bitreg
// params @3 Valor inmediato, HIGH, LOW
.MACRO m_pulse_in 
	// convert the timeout from microseconds to a number of times through
	ldi32 O, 50000 * clockCyclesPerMicrosecond() / PULSEIN_CYCLES_PER_LOOP;
	mov32 L,O
	// Asignar a 0 'N': {'Duración'}, 'O': {'numLoops'}
	clr32 N
	clr32 O
	// Valor de incremento de 'N', y 'O'
	ldi32 M,1
	// wait for any previous pulse to end
	WhilePreviousPulse:
		add32 O,M
		cpr32 O,L
		jeq(SalidaIncorrectaPingSensor)
		.if @3 == HIGHH
			sbic @1,@2
		.else
			sbis @1,@2
		.endif
		rjmp WhilePulseStop

	// wait for the pulse to start
	WhilePulseStart:
		add32 O,M
		cpr32 O,L
		jeq(SalidaIncorrectaPingSensor)
		.if @3 == HIGHH
			sbis @1,@2
		.else
			sbic @1,@2
		.endif
		rjmp WhilePulseStart

	// wait for the pulse to stop
	WhilePulseStop:
		add32 O,M
		cpr32 O,L
		jeq(SalidaIncorrectaPingSensor)
		add32 N,M
		.if @3 == HIGHH
			sbic @1,@2
		.else
			sbis @1,@2
		.endif
		rjmp WhilePulseStop

	// (width * PULSEIN_CYCLES_PER_LOOP)
	ldi rmp1,PULSEIN_CYCLES_PER_LOOP
	mov32 O,N
	Mult_width:
		add32 N,O
		dec rmp1
		brne Mult_width
	
	SalidaCorrectaPingSensor:
	addi32 N,PULSEIN_CYCLES_LATENCY
	ldiw T2,clockCyclesPerMicrosecond()
	div_32_16 N,T2,VH

	write32 @0,N

	rjmp EndPulseIn
	SalidaIncorrectaPingSensor:
	assign32(duration, MAX_ULONG)
	EndPulseIn:
.ENDM

#endif
