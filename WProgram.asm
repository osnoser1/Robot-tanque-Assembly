#ifndef _W_PROGRAM_ASM_
#define _W_PROGRAM_ASM_
/*
 * Pruebas.asm
 *
 *  Created: 1/31/2015 9:49:46 PM
 *   Author: AlfonsoAndrés
 */ 

// Included header file for target AVR type
//.NOLIST
#include "usb1286def.inc" // Header for AT90USB1286
#include "macro_utils.inc"
#include "_Delays.asm"
#include "arduino_definitions.inc"
#include "arduino_macros_fast.inc"
#include "arduino_macros.inc"
//.LIST
//
// ============================================
//   H A R D W A R E   I N F O R M A T I O N   
// ============================================
//
// [Add all hardware information here]
//
// ============================================
//      P O R T S   A N D   P I N S 
// ============================================
//
// [Add names for hardware ports and pins here]
// Format: .EQU Controlportout = PORTA
//         .EQU Controlportin = PINA
//         .EQU LedOutputPin = PORTA2

//
// ============================================
//    C O N S T A N T S   T O   C H A N G E 
// ============================================
//
// [Add all constants here that can be subject
//  to change by the user]
// Format: .EQU const = $ABCD
//
// ============================================
//  F I X + D E R I V E D   C O N S T A N T S 
// ============================================
//
// [Add all constants here that are not subject
//  to change or calculated from constants]
// Format: .EQU const = $ABCD
//
// ============================================
//   R E G I S T E R   D E F I N I T I O N S
// ============================================
//
// [Add all register names here, include info on
//  all used registers without specific names]
// Format: .DEF rmp1 = R16
.DEF rmp1 = R16 // Multipurpose register
.DEF rmp2 = R17 // Multipurpose register
.DEF rmp3 = R18 // Multipurpose register
.DEF rmp4 = R19 // Multipurpose register
//
// ============================================
//       S R A M   D E F I N I T I O N S
// ============================================
//
// ============================================
//   R E S E T   A N D   I N T   V E C T O R S
// ============================================
//
.CSEG
.ORG $0000
   	jmp Main // Reset vector
	reti // Int vector 1
	nop
	reti // Int vector 2
	nop
	reti // Int vector 3
	nop
	reti // Int vector 4
	nop
	reti // Int vector 5
	nop
	reti // Int vector 6
	nop
	reti // Int vector 7
	nop
	reti // Int vector 8
	nop
	reti // Int vector 9
	nop
	reti // Int vector 10
	nop
	reti // Int vector 11
	nop
	reti // Int vector 12
	nop
	reti // Int vector 13
	nop
	reti // Int vector 14
	nop
	reti // Int vector 15
	nop
	reti // Int vector 16
	nop
//	jmp TIMER1_COMPA_vect
	reti // Int vector 17
	nop
	reti // Int vector 18
	nop
	reti // Int vector 19
	nop
//	jmp TIMER1_OVF_vect
	reti // Int vector 20
	nop
	reti // Int vector 21
	nop
	reti // Int vector 22
	nop
	jmp TIMER0_OVF_vect
	// reti // Int vector 23
	// nop
	reti // Int vector 24
	nop
	reti // Int vector 25
	nop
	reti // Int vector 26
	nop
	reti // Int vector 27
	nop
	reti // Int vector 28
	nop
//
// ============================================
//     I N T E R R U P T   S E R V I C E S
// ============================================
//
// TIMER1_OVF_vect:
// 	push_all
// 	inc16 tot_overflow
// 	cpi16 tot_overflow, 30
// 	brlt EndTIMER1_OVF_vect
// 		negarBool16 varLedPin
// 		assign16(tot_overflow,0
// 	EndTIMER1_OVF_vect:
// 	pop_all
// 	ret

TIMER0_OVF_vect:
	push_all
	read32 N,timer0_millis_count
	read8 XL,timer0_fract_count

	addi32 N,TIMER0_MILLIS_INC
	addi XL,TIMER0_FRACT_INC // TIMER0_FRACT_INC se almacena en registro rmp1
	cpi XL,FRACT_MAX
	jlt(EndError)
		subi XL,FRACT_MAX
		addi32 N,1
	EndError:

	write8 timer0_fract_count,XL
	write32 timer0_millis_count,N
	inc32 timer0_overflow_count
	pop_all
	reti
//
// ============================================
//     M A I N    P R O G R A M    I N I T
// ============================================
//

InitTeensyInternal:
	// Adicional, no propio de la rutina
	long(timer0_overflow_count, 0);
	long(timer0_millis_count, 0);
	byte(timer0_fract_count, 0);
	// Inicio de la verdadera rutina
	cli()
	assign8(CLKPR, 0x80)
	assign8(CLKPR, 0)
	// timer 0, fast pwm mode
	assign8(TCCR0A, (1<<WGM00)|(1<<WGM01))
	assign8(TCCR0B,(1<<CS00)|(1<<CS01)) // div 64 prescaler
	sbi(TIMSK0, TOIE0)
	// timer 1, 8 bit phase correct pwm
	assign8(TCCR1A, (1<<WGM10))
	assign8(TCCR1B, (1<<CS11)) // div 8 prescaler
	// timer 2, 8 bit phase correct pwm
	assign8(TCCR2A, (1<<WGM20))
	assign8(TCCR2B, (1<<CS21)) // div 8 prescaler
	// timer 3, 8 bit phase correct pwm
	assign8(TCCR3A, (1<<WGM30))
	assign8(TCCR3B, (1<<CS31))//  div 8 prescaler
	// ADC
	assign8(ADCSRA, (1<<ADEN) | (ADC_PRESCALER + ADC_PRESCALE_ADJUST))
	assign8(ADCSRB, DEFAULT_ADCSRB)
	assign8(DIDR0, 0)
	sei()
	ret

Main:
// Init stack
	// outiw SP,RAMEND
	ldi rmp1, HIGH(RAMEND) // Init MSB stack
	out SPH,rmp1
	ldi rmp1, LOW(RAMEND) // Init LSB stack
	out SPL,rmp1
// Init Teensy
	rcall InitTeensyInternal
	// rcall InitTimer1ParpadeoLed
	// rcall InitTimer1Servo
	// rcall InitTimer1Servo1
	call Setup

//
// ============================================
//         P R O G R A M    L O O P
// ============================================
//
While:
	call Loop
	jmp While // go back to loop


.INCLUDE "avr200.inc"
.INCLUDE "math32.inc"
.INCLUDE "arduino_subrutinas.inc"

#endif
//
// End of source code
//
