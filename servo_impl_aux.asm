#ifndef _SERVO_IMPL_ASM_
#define _SERVO_IMPL_ASM_

initServo:
	int(value_servo_write, 0)
	byte(oldSREG, 0)
	int(temp_int, 0)
	long(temp_long, 0)
	byte(bandera,1)
	call InitTimer1Servo
	// long(ta_millis_giro,0)
	ret

InitTimer1Servo:
	assign8(TCCR3A, (1<<WGM31)|(1<<COM3C1)|(1<<COM3B1))
	assign8(TCCR3B, (1<<WGM33)|(1<<WGM32)|(1<<CS31)) //  div 8 prescaler
	assign16(ICR3L, 39999) // 20ms de retardo
	reti

TIMER1_COMPA_vect:
	push_all
	assign16(TCNT1L, 0)
	cpi8 bandera,1
	brne falsee
		sbi CORE_PIN14_PORTREG,CORE_PIN14_BIT
		assign8(bandera, 0)
		assign16(OCR1AL, 3000)
	rjmp end
	//delayMicroseconds(1500)
	falsee:
		cbi CORE_PIN14_PORTREG,CORE_PIN14_BIT
		assign16(OCR1AL, 40000)
		assign8(bandera, 1)
	//handle_interrupts _timer1,TCNT1L,OCR1AL
	// negarBool16 varLedPin
	end:
 	pop_all
	reti

#endif // _SERVO_IMPL_ASM_
