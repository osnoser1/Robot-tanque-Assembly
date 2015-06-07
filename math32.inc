/*
 * macro_utils.inc
 *
 *  Created: 5/6/2015 11:32:12 PM
 *   Author: AlfonsoAndrés
 */ 

#ifndef _MATH_32_
#define _MATH_32_

;
; < r16, r17, r18, r19 > = < r16, r17, r18, r19 > + < r20, r21, r22, r23 >
;
suma32: 
    add   r16, r20
    adc   r17, r21
    adc   r18, r22
    adc   r19, r23
    ret

;
;   LSB            MSB       LSB            MSB       LSB            MSB
; < r16, r17, r18, r19 > = < r16, r17, r18, r19 > - < r20, r21, r22, r23 >
;
resta32:
    sub   r16, r20
    sbc   r17, r21
    sbc   r18, r22
    sbc   r19, r23
    ret

 ;***************************************************************************
;*
;* Div32 == 32/32 Bit Unsigned Division
;*
;* dd32uL::dd32uH / dv32uL::dv32uH = dres32uL::dres32uH (drem32uL::drem32uH)
;*    dividend		divisor 	   result	     remainder
;*  r20r21r22r23  /  r16r17r18r19  =	r20r21r22r23	    r24r25r26r27
;*
;***************************************************************************
.def	dv32u0	 =r16	; divisor byte 0 (LSB)
.def	dv32u1	 =r17	; divisor byte 1
.def	dv32u2	 =r18	; divisor byte 2
.def	dv32u3	 =r19	; divisor byte 3 (MSB)
.def	dres32u0 =r20	; result byte 0 (LSB)
.def	dres32u1 =r21	; result byte 1
.def	dres32u2 =r22	; result byte 2
.def	dres32u3 =r23	; result byte 3 (MSB)
.def	dd32u0	 =r20	; dividend byte 0 (LSB)
.def	dd32u1	 =r21	; dividend byte 1
.def	dd32u2	 =r22	; dividend byte 2
.def	dd32u3	 =r23	; dividend byte 3 (MSB)
.def	drem32u0 =r24	; remainder byte 0 (LSB)
.def	drem32u1 =r25	; remainder byte 1
.def	drem32u2 =r26	; remainder byte 2
.def	drem32u3 =r27	; remainder byte 3 (MSB)
.def	dcnt32u  =r28	; loop counter
                                    
Div32b: 	clr	dv32u1		;divisor is one byte
Div32w: 	clr	dv32u2		;	    two bytes
Div32t: 	clr	dv32u3		;	    three bytes
Div32:		clr	drem32u0	;clear 4 lower remainde byte
			clr	drem32u1	;
			clr	drem32u2	;
			sub	drem32u3,drem32u3;and carry
			ldi	dcnt32u,33	;init loop counter
d32u_loop:	rol	dd32u0		;shift left dividend
			rol	dd32u1		;
			rol	dd32u2		;
			rol	dd32u3		;
			dec	dcnt32u 	;decrement loop counter
			breq	Com32		;if counter zero invert result
			rol	drem32u0	;shift dividend into remainder
			rol	drem32u1	;
			rol	drem32u2	;
			rol	drem32u3	;
			sub	drem32u0,dv32u0 ;remainder = remainder - divisor
			sbc	drem32u1,dv32u1 ;
			sbc	drem32u2,dv32u2 ;
			sbc	drem32u3,dv32u3 ;
			brcc	d32u_loop	;clear carry to be shifted into res
			add	drem32u0,dv32u0 ;if result negative
			adc	drem32u1,dv32u1 ;   restore remainder
			adc	drem32u2,dv32u2 ;
			adc	drem32u3,dv32u3 ;
			rjmp	d32u_loop	;   set carry to be shifted into res
Com32:		com	dres32u0		;	&
            com	dres32u1		;   (com result)
            com	dres32u2		;
            com	dres32u3		;   return set carry after com
	ret

.undef	dv32u0
.undef	dv32u1
.undef	dv32u2
.undef	dv32u3
.undef	dres32u0
.undef	dres32u1
.undef	dres32u2
.undef	dres32u3
.undef	dd32u0
.undef	dd32u1
.undef	dd32u2
.undef	dd32u3
.undef	drem32u0
.undef	drem32u1
.undef	drem32u2
.undef	drem32u3
.undef	dcnt32u

;***************************************************************************
;*
;* Mul32 == 32x32 Bit Unsigned Multiplication
;*
;* mp32uL::mp32uH  x  mc32uL::mc32uH  =  m32uL::m32uH
;*   multiplier        multiplicand	    result
;*  r20r21r22r23   x   r16r17r18r19   =  r20r21r22r23r24r25r26r27
;*
;***************************************************************************
.def	mc32u0	=r16	; multiplicand byte 0 (LSB)
.def	mc32u1	=r17	; multiplicand byte 1
.def	mc32u2	=r18	; multiplicand byte 2
.def	mc32u3	=r19	; multiplicand byte 3 (MSB)
.def	mp32u0	=r20	; multiplier byte 0 (LSB)
.def	mp32u1	=r21	; multiplier byte 1
.def	mp32u2	=r22	; multiplier byte 2
.def	mp32u3	=r23	; multiplier byte 3 (MSB)
.def	m32u0	=r20	; result byte 0 (LSB)
.def	m32u1	=r21	; result byte 1
.def	m32u2	=r22	; result byte 2
.def	m32u3	=r23	; result byte 3
.def	m32u4	=r24	; result byte 4
.def	m32u5	=r25	; result byte 5
.def	m32u6	=r26	; result byte 6
.def	m32u7	=r27	; result byte 7 (MSB)
.def	mcnt32u =r28	; loop counter
                                    
Mul32b: 	clr	mc32u1		;multiplicand is one byte
Mul32w: 	clr	mc32u2		;		 two bytes
Mul32t: 	clr	mc32u3		;		 three bytes
Mul32:		clr	m32u7		;clear 4 highest bytes of result
			clr	m32u6		;
			clr	m32u5		;
			sub	m32u4,m32u4	;and carry
			ldi	mcnt32u,33	;init loop counter
m32u_loop:	ror	m32u3		;rotate result and multiplier
			ror	m32u2		;
			ror	m32u1		;
			ror	m32u0		;
			dec	mcnt32u 	;decrement loop counter
			breq	EndMul32b	;if counter zero return
			brcc	m32u_skip	;if bit 0 of multiplier set
			add	m32u4,mc32u0	;   add multiplicand to result
			adc	m32u5,mc32u1	;
			adc	m32u6,mc32u2	;
			adc	m32u7,mc32u3	;
m32u_skip:	ror	m32u7		;shift right result byte 7
			ror	m32u6		;rotate right result
			ror	m32u5		;
			ror	m32u4		;
			rjmp	m32u_loop	;
	EndMul32b:
	ret

.undef	mc32u0
.undef	mc32u1
.undef	mc32u2
.undef	mc32u3
.undef	mp32u0
.undef	mp32u1
.undef	mp32u2
.undef	mp32u3
.undef	m32u0
.undef	m32u1
.undef	m32u2
.undef	m32u3
.undef	m32u4
.undef	m32u5
.undef	m32u6
.undef	m32u7
.undef	mcnt32u

#endif
