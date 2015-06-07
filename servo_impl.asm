#ifndef _SERVO_IMPL_ASM_
#define _SERVO_IMPL_ASM_

// params @0 Timer
// params @1 TCNTm
// params @2 OCRnA
.MACRO handle_interrupts
	// call Handle
	call Handle2
	// cpi16 array_dir_16(Channel, @0),254
	// jlt(_else_1_h_i)
	// 	assign16(@1,0
	// 	jmp _end_else_1_h_i
	// _else_1_h_i:
	// 	SERVO_INDEX(SERVO_INDEX_tmp, @0, array_dir_16(Channel, @0))
	// 	SERVO(SERVO_tmp, SERVO_INDEX_tmp)
	// 	cp16 SERVO_INDEX_tmp,ServoCount
	// 	jge(_end_else_1_h_i)
	// 		servo_is_active_get SERVO_attr_int_tmp,SERVO_tmp
	// 		cpi16 SERVO_attr_int_tmp,true
	// 		jne(_end_else_1_h_i)
	// 			servo_pin_nbr_get SERVO_attr_int_tmp,SERVO_tmp
	// 			m_digitalWritePinVar SERVO_attr_int_tmp,LOWW
	// _end_else_1_h_i:
	// // increment to the next channel
	// inc16 array_dir_16(Channel, @0)
	// assign16ge array_dir_16(Channel, @0),254,0,'i','i'

	// SERVO_INDEX(SERVO_INDEX_tmp, @0, array_dir_16(Channel, @0))
	// SERVO(SERVO_tmp, SERVO_INDEX_tmp)
	// cp16 SERVO_INDEX_tmp,ServoCount
	// jge(_else_2_h_i)
	// 	cpi16 array_dir_16(Channel, @0),SERVOS_PER_TIMER
	// 	jge(_else_2_h_i)
	// 		copy16(temp_int, @1)
	// 		servo_ticks_get SERVO_attr_int_tmp,SERVO_tmp
	// 		sum16 temp_int,SERVO_attr_int_tmp
	// 		copy16(@2, temp_int)
	// 		servo_is_active_get SERVO_attr_int_tmp,SERVO_tmp
	// 		cpi16 SERVO_attr_int_tmp,true
	// 		jne(EndHandleInterrupts)
	// 			servo_pin_nbr_get SERVO_attr_int_tmp,SERVO_tmp
	// 			m_digitalWritePinVar SERVO_attr_int_tmp,HIGHH
	// 			jmp EndHandleInterrupts 
	// _else_2_h_i:
	// 	copy16(temp_int, @1)
	// 	sumi16 temp_int,4
	// 	cpi16 temp_int,usToTicks(REFRESH_INTERVAL)
	// 	jge(_else_2_else_1h_i)
	// 		assign16(@2,usToTicks(REFRESH_INTERVAL)
	// 		jmp _end_else_2_else_1h_i
	// 	_else_2_else_1h_i:
	// 		copy16(@2, temp_int)
	// 	_end_else_2_else_1h_i:
	// 	assign16(array_dir_16(Channel, @0),254
	// _end_else_2_h_i:
	// EndHandleInterrupts:
.ENDM

Handle2:
	micros(tiempoTranscurrido)
	assign16(TCNT1L, 0)
	cpi16 array_dir_16(Channel, 0),0
	jeq(_else_1_h_i)
		assign16(OCR1AL, usToTicks(1500))
		sbi CORE_PIN15_PORTREG,CORE_PIN15_BIT
		assign16(array_dir_16(Channel, 0), 0)
		//delayMicroseconds(1500)
		jmp EndHandleInterrupts
	_else_1_h_i:
		cbi CORE_PIN15_PORTREG,CORE_PIN15_BIT
		assign16(OCR1AL, usToTicks(REFRESH_INTERVAL))
		assign16(array_dir_16(Channel, 0), 1)
	// increment to the next channel	
		// sumi16 OCR1AL,usToTicks(REFRESH_INTERVAL)
	EndHandleInterrupts:
	copy(temp1_l, tiempoTranscurrido)
	sub32 temp1_l,tiempoActual
	copy(tiempoActual, tiempoTranscurrido)
	ret

Handle:
	// cpi16 array_dir_16(Channel, 0),INVALID_SERVO
	// jlt(_else_1_h_i)
	// 	assign16(TCNT1L,0
	// 	jmp _end_else_1_h_i
	// _else_1_h_i:
	// 	SERVO_INDEX(SERVO_INDEX_tmp, 0, array_dir_16(Channel, 0))
	// 	SERVO(SERVO_tmp, SERVO_INDEX_tmp)
	// 	cp16 SERVO_INDEX_tmp,ServoCount
	// 	jge(_end_else_1_h_i)
	// 		servo_is_active_get SERVO_attr_int_tmp,SERVO_tmp
	// 		cpi16 SERVO_attr_int_tmp,true
	// 		jne(_end_else_1_h_i)
	// 			servo_pin_nbr_get SERVO_attr_int_tmp,SERVO_tmp
	// 			m_digitalWritePinVar SERVO_attr_int_tmp,LOWW
	// _end_else_1_h_i:
	// // increment to the next channel
	// inc16 array_dir_16(Channel, 0)

	// SERVO_INDEX(SERVO_INDEX_tmp, 0, array_dir_16(Channel, 0))
	// SERVO(SERVO_tmp, SERVO_INDEX_tmp)
	// cp16 SERVO_INDEX_tmp,ServoCount
	// jge(_else_2_h_i)
	// 	cpi16 array_dir_16(Channel, 0),SERVOS_PER_TIMER
	// 	jge(_else_2_h_i)
	// 		copy16(temp_int, TCNT1L)
	// 		servo_ticks_get SERVO_attr_int_tmp,SERVO_tmp
	// 		sum16 temp_int,SERVO_attr_int_tmp
	// 		copy16(OCR1AL, temp_int)
	// 		servo_is_active_get SERVO_attr_int_tmp,SERVO_tmp
	// 		cpi16 SERVO_attr_int_tmp,true
	// 		jne(EndHandleInterrupts)
	// 			servo_pin_nbr_get SERVO_attr_int_tmp,SERVO_tmp
	// 			m_digitalWritePinVar SERVO_attr_int_tmp,HIGHH
	// 			// sbi CORE_PIN15_PORTREG,CORE_PIN15_BIT
	// 			jmp EndHandleInterrupts
	// _else_2_h_i:
	// 	copy16(temp_int, TCNT1L)
	// 	sumi16 temp_int,4
	// 	cpi16 temp_int,usToTicks(REFRESH_INTERVAL)
	// 	jge(_else_2_else_1h_i)
	// 		// assign16(OCR1AL,usToTicks(REFRESH_INTERVAL)
	// 		sumi16 OCR1AL,usToTicks(REFRESH_INTERVAL)
	// 		jmp _end_else_2_else_1h_i
	// 	_else_2_else_1h_i:
	// 		copy16(OCR1AL, temp_int)
	// 	_end_else_2_else_1h_i:
	// 	assign16(array_dir_16(Channel, 0),65535
	// _end_else_2_h_i:
	// EndHandleInterrupts:
	ret

initServo:
	int(ServoCount, 0)
	int(servo_indice_tmp, 0)
	int(value_servo_write, 0)
	byte(oldSREG, 0)
	int(SERVO_MIN_tmp, 0)
	int(SERVO_MAX_tmp, 0)
	int(SERVO_INDEX_tmp, 0)
	int(SERVO_tmp, 0)
	int(SERVO_attr_int_tmp, 0)
	int(temp_int, 0)
	byte(bandera,1)
	call InitTimer1Servo
	ret

InitTimer1Servo:
	assign8(TCCR1A, 0) ; normal counting mode
	assign8(TCCR1B, _BV(CS11)) ; div 8 prescaler
	assign16(TCNT1L, 0) ; clear the timer count 

	or8(TIFR1, _BV(OCF1A), i)     ; clear any pending interrupts; 
    or8(TIMSK1, _BV(OCIE1A), i) ; enable the output compare interrupt  
	ret

TIMER1_COMPA_vect:
	push_all
	assign16(TCNT1L, 0)
	read8 rmp1,bandera
	cpi rmp1,1
	brne falsee
		sbi CORE_PIN15_PORTREG,CORE_PIN15_BIT
		write8 bandera,0
		assign16(OCR1AL, 3000)
	rjmp end
	//delayMicroseconds(1500)
	falsee:
		cbi CORE_PIN15_PORTREG,CORE_PIN15_BIT
		assign16(OCR1AL, 40000)
		assign8(bandera, 1)
	//handle_interrupts _timer1,TCNT1L,OCR1AL
	// negarBool16 varLedPin
	end:
 	pop_all
	reti

#endif // _SERVO_IMPL_ASM_
