#ifndef _SERVO_IMPL_ASM_
#define _SERVO_IMPL_ASM_

initServo:
	int(value_servo_write, 0)
	byte(oldSREG, 0)
	int(temp_int, 0)
	long(temp_long, 0)
	// long(ta_millis_giro,0)
	ret

#endif // _SERVO_IMPL_ASM_
