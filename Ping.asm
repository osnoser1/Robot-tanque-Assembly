#ifndef _PING_ASM_
#define _PING_ASM_

#define Ping() call r_ping_construct
#define Ping_fire(_var,_pin) m_ping_fire _var,_pin,CORE_PIN_CONCATENATE(_pin, PINREG),CORE_PIN_CONCATENATE(_pin, BIT)
#define Ping_toCentimeters(_var) m_ping_to_centimeters _var
//#define Ping_millisFire(_var,_pin,_tiempo)

r_ping_construct:
	ret

// params @0 Variable
// params @1 Pin
// params @0 Pinreg
// params @1 Bitreg
.MACRO m_ping_fire
	pinMode(@1, OUTPUT);
  	digitalWritei(@1, LOWW);
  	delayMicroseconds(2);
  	digitalWritei(@1, HIGHH);
  	delayMicroseconds(5);
  	digitalWritei(@1, LOWW);

  	pinMode(@1, INPUT);
  	m_pulse_in @0, @2, @3, HIGHH;
.ENDM

// params @0 Variable
.MACRO m_ping_to_centimeters
	read32 N,@0
	cpir32 N,MAX_ULONG
		jeq(EndPingToCentimeters)
	ldiw T2,29
	div_32_16 N,T2,VH
	ldiw T2,2
	div_32_16 N,T2,VH
	write32 @0,N 
	EndPingToCentimeters:
.ENDM

#endif
