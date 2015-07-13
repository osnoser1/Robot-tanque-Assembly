/*
 * macro_utils.inc
 *
 *  Created: 2/7/2015 10:13:44 AM
 *   Author: AlfonsoAndrés
 */ 

#ifndef _MACRO_UTILS_INC_
#define _MACRO_UTILS_INC_

// #define int(_var) .DSEG _var##: .BYTE 2 .CSEG
// Utilidades

#define millis(var) m_millis var
#define micros(var) m_micros var
#define CONCAT(X,Y) X ## Y

// Operaciones con arrays en la SRAM

#define array_dir(_var,_index,_tam) _var + _index*_tam
#define array_get_dir_elem(_punt,_index,_var,_tam) m_array_get_dir_elem _punt,_index,_var,_tam
#define array_dir_16(_var,_index) array_dir(_var, _index, SIZE_INT)
#define array_dir_32(_var,_index) array_dir(_var, _index, SIZE_LONG)
#define array_get_el_16(_var,_index,_array,_type1) m_array_get_el _var,_index,_array,_type1,'v'
// #define array_set_elem_16(_el,_var,_val) assign16(array_dir_16(_var,_el),_val
#define array_set_elem_16(_el,_var,_val,_type1,_type2,_type3) m_array_set_elem_16 _el,_var,_val,_type1,_type2,_type3
#define array_set_elem_32(_el,_var,_val) assign32(array_dir_32(_var, _el),_val
// #define array_dir_var_16(_var, _varIndex) m_array_dir_var_16 _

// Operaciones para declaración de variables

#define malloc(_var,_bytes) 	.DSEG _var: .BYTE _bytes .CSEG .EQU _var##EQU = _bytes
#define byte(_var,_val) 		.DSEG _var: .BYTE SIZE_BYTE .CSEG .EQU _var##EQU = SIZE_BYTE assign8(_var,_val)
#define int(_var,_val) 			.DSEG _var: .BYTE SIZE_INT .CSEG .EQU _var##EQU = SIZE_INT assign16(_var,_val)
#define long(_var,_val) 		.DSEG _var: .BYTE SIZE_LONG .CSEG .EQU _var##EQU = SIZE_LONG assign32(_var,_val)
#define byte_o(_var) 		.DSEG _var: .BYTE SIZE_BYTE .CSEG .EQU _var##EQU = SIZE_BYTE
#define int_o(_var)		.DSEG _var: .BYTE SIZE_INT .CSEG .EQU _var##EQU = SIZE_INT
#define long_o(_var) 		.DSEG _var: .BYTE SIZE_LONG .CSEG .EQU _var##EQU = SIZE_LONG

// Constantes
#define SIZE_INT	2
#define SIZE_LONG	4
#define SIZE_BYTE	1
#define MAX_LONG	0x7fffffff
#define MAX_ULONG	MAX_LONG * 2 + 1

// Operaciones con variables

#define cp_32_16(_var1,_var2) m_cp_32_16 _var1,_var2
//#define copy16_32(_var,_var2) m_copy _var1, _var2

#define copy(_var1,_var2) 	m_copy _var1,_var2,_var1##EQU,_var2##EQU
#define copy8(_var1,_var2) 	m_copy _var1,_var2,SIZE_BYTE,SIZE_BYTE
#define copy16(_var1,_var2) m_copy _var1,_var2,SIZE_INT,SIZE_INT
#define copy32(_var1,_var2) m_copy _var1,_var2,SIZE_LONG,SIZE_LONG

#define assign(_var,_val) 	m_assign _var,_val,_var##EQU
#define assign8(_var,_val) 	m_assign _var,_val,SIZE_BYTE
#define assign16(_var,_val) m_assign _var,_val,SIZE_INT
#define assign32(_var,_val) m_assign _var,_val,SIZE_LONG

#define set16(_var,_val,_type) m_set_16 _var,_val,_type

#define or8(_var,_mask,_type) 	CONCAT(m_or8_,_type) _var,_mask
#define or16(_var,_mask,_type) 	CONCAT(m_or16_,_type) _var,_mask

// Manejo del flujo del programa

#define jeq(_dir) brne PC+3 jmp _dir
#define jne(_dir) breq PC+3 jmp _dir
#define jge(_dir) brlo PC+3 jmp _dir
#define jlt(_dir) brsh PC+3 jmp _dir
#define cpMillis(_var, _val, _type) CONCAT(m_compare_millis_,_type) _var, _val

// Operaciones matemáticas

#define map16(x,in_min,in_max,out_min,out_max) m_map16 x,in_min,in_max,out_min,out_max
#define map16i(x,in_min,in_max,out_min,out_max) m_map16i x,in_min,in_max,out_min,out_max

// interrupt.h Interrupciones AVR C++

#define sei() sei
#define cli() cli
// ISR(vector) Pronto lo definiré

// Banderas

#define true 	1
#define false 	0

.DEF VH = R25
.DEF VL = R24
.DEF WH = R23
.DEF WL = R22

// Registros temporales de 16 bits

.DEF T1L = R16
.DEF T1H = R17

.DEF T2L = R18
.DEF T2H = R19

.DEF T3L = R20
.DEF T3H = R21

// Registros temporales de 32 bits
.DEF LL1 = R12
.DEF LL2 = R13
.DEF LH1 = R14
.DEF LH2 = R15

.DEF ML1 = R16
.DEF ML2 = R17
.DEF MH1 = R18
.DEF MH2 = R19

.DEF NL1 = R20
.DEF NL2 = R21
.DEF NH1 = R22
.DEF NH2 = R23

.DEF OL1 = R24
.DEF OL2 = R25
.DEF OH1 = R26
.DEF OH2 = R27



// *****************************************************************************
// Manipulación registros, 8 bits
// *****************************************************************************

// params @0 Rr
// params @1 Dirección de memoria
.MACRO read8
	lds @0,@1
.ENDM

// params @0 Dirección de memoria
// params @1 Rr
.MACRO write8
	sts @0,@1
.ENDM

// params @0 Rr
// params @1 Valor inmediato
.MACRO andCp
	ldi rmp1, @1
	cpc @0,rmp1
.ENDM

// params @0 Rr
// params @1 Valor inmediato
.MACRO addi
	ldi rmp1,@1
	add @0,rmp1
.ENDM

// params @0 Rr
// params @1 Rd
.MACRO pop_two
	pop @1
	pop @0
.ENDM

// params @0 Rr
// params @1 Rd
.MACRO push_two
	push @0
	push @1
.ENDM

// params @0 Rr
// params @1 Valor inmediato
.MACRO multi
	ldi rmp1,@1
	mul @0,rmp1
.ENDM

// *****************************************************************************
// Manipulación registros, 16 bits
// *****************************************************************************

// params @0 Registro, 16 bits
// params @1 Registro, 16 bits
.MACRO cpw
	cp @0l,@1l
	cpc @0h,@1h
.ENDM

// params @0 Registro, 16 bits
// params @1 Valor inmediato
.MACRO cpiw
	ldiw T1,@1
	cpw @0,T1
.ENDM

// params @1 Registro, 16 bits
// params @0 Registro, 16 bits (X,Y,Z)
.MACRO ldw
	ld @0l,@1+
	ld @0h,@1
.ENDM

// params @0 Registro, 16 bits
// params @1 Valor inmediato
.MACRO ldiw
	ldi @0l,LOW(@1)
	ldi @0h,HIGH(@1)
.ENDM

// params @0 Registro, 16 bits (X,Y,Z)
// params @1 Registro, 16 bits
.MACRO stw
	st @0+,@1l
	st @0,@1h
.ENDM

// params @0 Registro, 16 bits (X,Y,Z)
// params @1 Valor inmediato
.MACRO stiw
	ldiw T1,@1
	st @0+,T1L
	st @0,T1H
.ENDM

// params @0 Par de registro
.MACRO clrw
	clr @0l
	clr @0h
.ENDM

// params @0 Par de registro
// params @1 Dirección de memoria
.MACRO read16
	read8 @0l,@1 // Parte baja
	read8 @0h,@1+1 // Parte alta
.ENDMACRO

// params @0 Dirección de memoria
// params @1 Par de registro
.MACRO write16
	write8 @0,@1l // Parte baja
	write8 @0+1,@1h // Parte alta
.ENDM

// params @0 Par de registro
// params @1 Par de registro
// < RdH, RdL > = < RdH, RdL > + < RrH, RrL >
.MACRO addw
	add @0l, @1l
    adc @0h, @1h
.ENDM

// params @0 Par de registro
// params @1 Par de registro
// < RdH, RdL > = < RdH, RdL > - < RrH, RrL >
.MACRO subw
    sub @0l, @1l
    sbc @0h, @1h
.ENDM

// Register usage: r0, r1, r2, r3 (4 registers) + 6
// r17:r16 = r25:r24 * r23:r22
// params @0 Par de registro
// params @1 Par de registro
.MACRO mul_16
	mul	@0l, @1l		// al * bl
	movw r3:r2, r1:r0
	mul	@0h, @1l		// ah * bl
	add	r3, r0
	mul	@1h, @0l		// bh * al
	add	r3, r0
	movw @0h:@0l, r3:r2
.ENDM

// Register usage: r0, r1, r2, r3, T1H,T1L (6 registers) + 6
// r17:r16 = r25:r24 * r23:r22
// params @0 Par de registro
// params @1 Valor inmediato
.MACRO mul_16i
	ldiw T1,@1
	mul_16 @0,T1
.ENDM

// Register usage: r0, r1, r2 (3 registers) + 6
// @0h2:@0h1:@0l2:@0l1 = @1h:@1l * @2h:@2l
// params @0 Registro, 32 bits
// params @1 Par de registro
// params @2 Par de registro
.MACRO mul_32
	clr	r2
	mul	@1h, @2h		// ah * bh
	movw @0h2:@0h1, r1:r0
	mul	@1l, @2l		// al * bl
	movw @0l2:@0l1, r1:r0
	mul	@1h, @2l		// ah * bl
	add	@0l2, r0
	adc	@0h1, r1
	adc	@0h2, r2
	mul	@2h, @1l		// bh * al
	add	@0l2, r0
	adc	@0h1, r1
	adc	@0h2, r2
.ENDM

// *****************************************************************************
// Manipulación registros, 32 bits
// *****************************************************************************

// params @0 Registro, 32 bits
// params @1 Registro, 32 bits
.MACRO mov32
	mov @0l1,@1l1
	mov @0l2,@1l2
	mov @0h1,@1h1
	mov @0h2,@1h2
.ENDM

// params @0 Registro, 32 bits
// params @1 Valor inmediato
.MACRO ldi32
	ldi	@0l1,byte1(@1)
    ldi	@0l2,byte2(@1)
    ldi	@0h1,byte3(@1)
    ldi	@0h2,byte4(@1)
.ENDM

// params @0 Registro, 32 bits
// params @1 Registro, 32 bits
.MACRO cpr32
	cp @0l1,@1l1
	cpc @0l2,@1l2
	cpc @0h1,@1h1
	cpc @0h2,@1h2
.ENDM

// params @0 Registro, 32 bits
// params @1 Valor inmediato
.MACRO addi32
	ldi32 M,@1
    add32 @0,M
.ENDM

// params @0 Registro, 32 bits
.MACRO incr32
	addi32 @0,1
.ENDM

// params @0 Registro, 32 bits
// params @1 Valor inmediato
.MACRO subir32
	ldi32 M,@1
    subr32 @0,M
.ENDM

//
//   LSB            MSB       LSB            MSB       LSB            MSB
// < r16, r17, r18, r19 > = < r16, r17, r18, r19 > - < r20, r21, r22, r23 >
//
.MACRO subr32
	sub @0l1,@1l1
	sbc @0l2,@1l2
	sbc @0h1,@1h1
	sbc @0h2,@1h2
.ENDM

//
//   LSB            MSB       LSB            MSB       LSB            MSB
// < r16, r17, r18, r19 > = < r16, r17, r18, r19 > + < r20, r21, r22, r23 >
//
.MACRO add32
	add @0l1,@1l1
	adc @0l2,@1l2
	adc @0h1,@1h1
	adc @0h2,@1h2
.ENDM

// params @0 Registro, 32 bits
// params @1 Valor inmediato
// Cuidado: Usa registro M
.MACRO cpir32
	ldi32 M,@1
	cpr32 @0,M
.ENDM

// params @0 Registro, 32 bits
// params @1 Dirección de memoria
.MACRO read32
	read8 @0l1,@1
	read8 @0l2,@1+1
	read8 @0h1,@1+2
	read8 @0h2,@1+3
.ENDM


// params @0 Dirección de memoria
// params @1 Registro, 32 bits
.MACRO write32
	write8 @0,@1l1
	write8 @0+1,@1l2
	write8 @0+2,@1h1
	write8 @0+3,@1h2
.ENDM

// params @0 Registro, 32 bits
.MACRO lsl32
	lsl @0l1
	rol @0l2
	rol @0h1
	rol @0h2
.ENDM

// params @0 Registro, 32 bits
.MACRO clr32
	clr @0l1
	clr @0l2
	clr @0h1
	clr @0h2
.ENDM

// *****************************************************************************
// Manipulación puertos, 8 bits
// *****************************************************************************

.MACRO andOnPort //.
	in rmp1,@0
	andi rmp1,@1
	out @0,rmp1
.ENDM

// *****************************************************************************
// Manipulación puertos, 16 bits
// *****************************************************************************

// params @0 Puerto de 16 bits
// params @1 Registro, 16 bits
.MACRO outw
	out @0l,@1l
	out @0h,@1h
.ENDM

// params @0 Puerto de 16 bits
// params @1 Valor inmediato, 16 bits
.MACRO outiw
	ldiw T1,@1
	outw @0,V
.ENDM

// *****************************************************************************
// Manipulación de la SRAM, 8 bits
// *****************************************************************************

// params @0 Variable
// params @1 Valor inmediato
.MACRO m_or8_i
	.if @0 < 64
		in rmp1,@0
	.else
		read8 rmp1,@0
	.endif
	ori rmp1,@1
	.if @0 < 64
		out @0,rmp1
	.else
		write8 @0,rmp1
	.endif
.ENDM 

.MACRO orOnPortSts //.
	read8 rmp1,@0
	or rmp1,@1
	write8 @0,rmp1
.ENDM

.MACRO andOnPortStsi //.
	read8 rmp1,@0
	andi rmp1,@1
	write8 @0,rmp1
.ENDM

// params @0 Dirección de memoria
// params @1 Dirección de memoria
.MACRO m_copy8
	read8 rmp1,@1
	write8 @0,rmp1
.ENDM

// params @0 Dirección de memoria
.MACRO inc8
	read8 rmp1,@0
	inc rmp1
	write8 @0,rmp1
.ENDM

// params @0 Dirección de memoria
// params @1 Dirección de memoria
.MACRO cp8
	read8 rmp2,@0
	read8 rmp2,@1
	cp rmp1,rmp2
.ENDM

// params @0 Dirección de memoria
// params @1 Valor inmediato
.MACRO cpi8
	read8 rmp1,@0
	cpi rmp1,@1
.ENDM

// *****************************************************************************
// Manipulación de la SRAM, 16 bits
// *****************************************************************************

// params @0 Dirección de memoria
// params @1 Dirección de memoria
.MACRO m_copy16
	read16 T1,@1
	write16 @0,T1
.ENDM

// params @0 Dirección de memoria
// params @1 Valor inmediato
// params @2 Valor inmediato
// if((@0) == @1) (@0) = @2
.MACRO assign16eq
	cpi16 @0,@1
	brne EndAssignIf16
		assign16(@0, @2) // Se cumple la condicion
	EndAssignIf16:
.ENDM

// params @0 Dirección de memoria
// params @1 Valor inmediato
// params @2 Valor inmediato
// params @3 Tipo @1: {'i': 'inmediato', 'v': 'variable'}
// params @4 Tipo @2: {'i': 'inmediato', 'v': 'variable'}
// if((@0) >= @1) (@0) = @2
.MACRO assign16ge
	.if @3 == 'i'
		cpi16 @0,@1
		brlt EndAssign16ge
		.if @4 == 'i'
			assign16(@0, @2)
		.else 
			copy16(@0, @2) 
		.endif
	.elif @3 == 'v'
		cp16 @0,@1
		brlt EndAssign16ge
		.if @4 == 'i'
			assign16(@0, @2) 
		.else 
			copy16(@0, @2)
		.endif
	.endif
	EndAssign16ge:
.ENDM

// params @0 Dirección de memoria
// params @1 Valor inmediato
// params @2 Valor inmediato
// params @3 Tipo @1: {'i': 'inmediato', 'v': 'variable'}
// params @4 Tipo @2: {'i': 'inmediato', 'v': 'variable'}
// if((@0) < @1) (@0) = @2
.MACRO assign16lt
	.if @3 == 'i'
		cpi16 @0,@1
		brge EndAssign16lt
		.if @4 == 'i'
			assign16(@0, @2)
		.else 
			copy16(@0,@2) 
		.endif
	.elif @3 == 'v'
		cp16 @0,@1
		brge EndAssign16lt
		.if @4 == 'i'
			assign16(@0, @2)
		.else 
			copy16(@0,@2)
		.endif
	.endif
	EndAssign16lt:
.ENDM

// params @0 Dirección de memoria
// params @1 Valor inmediato
// params @2 Valor inmediato
// params @3 Tipo @1: {'i': 'inmediato', 'v': 'variable'}
// params @4 Tipo @2: {'i': 'inmediato', 'v': 'variable'}
// if((@0) < @1) (@0) = @2
.MACRO add16lt
	.if @3 == 'i'
		cpi16 @0,@1
		brge EndAdd16lt
		.if @4 == 'i'
			sumi16 @0,@2
		.else 
			sum16 @0,@2
		.endif
	.elif @3 == 'v'
		cp16 @0,@1
		brge EndAdd16lt
		.if @4 == 'i'
			sumi16 @0, @2
		.else 
			sum16 @0,@2
		.endif
	.endif
	EndAdd16lt:
.ENDM

// params @0 Dirección de memoria
// params @1 Valor inmediato
// params @2 Valor inmediato
// params @3 Tipo @1: {'i': 'inmediato', 'v': 'variable'}
// params @4 Tipo @2: {'i': 'inmediato', 'v': 'variable'}
// if((@0) < @1) (@0) = @2
.MACRO add16ge
	.if @3 == 'i'
		cpi16 @0,@1
		brlt EndAdd16ge
		.if @4 == 'i'
			sumi16 @0,@2
		.else 
			sum16 @0,@2
		.endif
	.elif @3 == 'v'
		cp16 @0,@1
		brlt EndAdd16ge
		.if @4 == 'i'
			sumi16 @0, @2
		.else 
			sum16 @0,@2
		.endif
	.endif
	EndAdd16ge:
.ENDM

// params @0 Dirección de memoria
// params @1 Valor inmediato
// params @2 Valor inmediato
// params @3 Tipo @1: {'i': 'inmediato', 'v': 'variable'}
// params @4 Tipo @2: {'i': 'inmediato', 'v': 'variable'}
// if((@0) < @1) (@0) = @2
.MACRO sub16ge
	.if @3 == 'i'
		cpi16 @0,@1
		brlt EndSub16ge
		.if @4 == 'i'
			subi16 @0,@2
		.else 
			sub16 @0,@2
		.endif
	.elif @3 == 'v'
		cp16 @0,@1
		brlt EndSub16ge
		.if @4 == 'i'
			subi16 @0, @2
		.else 
			sub16 @0,@2
		.endif
	.endif
	EndSub16ge:
.ENDM

// params @0 Dirección de memoria
// params @1 Valor a asignar
// params @2 Valor a comparar 1
// params @3 Valor a comparar 2
// params @4 Tipo @1: {'i': 'inmediato', 'v': 'variable'}
// params @5 Tipo @2: {'i': 'inmediato', 'v': 'variable'}
// params @6 Tipo @3: {'i': 'inmediato', 'v': 'variable'}
// if((@0) >= @1) (@0) = @2
.MACRO assignToOther16ge
	.if @6 == 'i'
		.if @5 == 'i'
			ldiw T2,@2
			cpiw T2,@3
		.else
			cpi16 @2,@3
		.endif
		brlt EndAssignToOther16ge
		.if @4 == 'i'
			assign16(@0, @1)
		.else 
			copy16(@0, @1) 
		.endif
	.elif @6 == 'v'
		.if @5 == 'i'
			ldiw T1,@2
			read16 T2,@3
			cpw T1,T2
		.else
			cp16 @2,@3
		.endif
		brlt EndAssignToOther16ge
		.if @4 == 'i'
			assign16(@0, @1) 
		.else 
			copy16(@0, @1)
		.endif
	.else
		.error "Parámetro no válido"
	.endif
	EndAssignToOther16ge:
.ENDM

// params @0 Dirección de memoria
// params @1 Valor a asignar
// params @2 Valor a comparar 1
// params @3 Valor a comparar 2
// params @4 Tipo @1: {'i': 'inmediato', 'v': 'variable'}
// params @5 Tipo @2: {'i': 'inmediato', 'v': 'variable'}
// params @6 Tipo @3: {'i': 'inmediato', 'v': 'variable'}
// if((@0) >= @1) (@0) = @2
.MACRO assignToOther16lt
	.if @6 == 'i'
		.if @5 == 'i'
			ldiw T2,@2
			cpiw T2,@3
		.else
			cpi16 @2,@3
		.endif
		brge EndAssignToOther16lt
		.if @4 == 'i'
			assign16(@0, @1)
		.else 
			copy16(@0, @1) 
		.endif
	.elif @6 == 'v'
		.if @5 == 'i'
			ldiw T1,@2
			read16 T2,@3
			cpw T1,T2
		.else
			cp16 @2,@3
		.endif
		brge EndAssignToOther16lt
		.if @4 == 'i'
			assign16(@0, @1) 
		.else 
			copy16(@0, @1)
		.endif
	.else
		.error "Parámetro no válido"
	.endif
	EndAssignToOther16lt:
.ENDM



// params @0 Dirección de memoria
// params @1 Dirección de memoria
.MACRO cp16
	read16 T1,@0
	read16 T2,@1
	cpw T1,T2
.ENDM

// params @0 Dirección de memoria
// params @1 Dirección de memoria
.MACRO sum16 
	read16 V,@0
	read16 W,@1
	addw V,W
	write16 @0,V
.ENDM

// params @0 Dirección de memoria
// params @1 Valor inmediato
.MACRO sumi16 
	read16 V,@0
	ldiw W,@1
	addw V,W
	write16 @0,V
.ENDM

// params @0 Dirección de memoria
// params @1 Dirección de memoria
.MACRO sub16 
	read16 V,@0
	read16 W,@1
	subw V,W
	write16 @0,V
.ENDM

// params @0 Dirección de memoria
// params @1 Valor inmediato
.MACRO subi16 
	read16 T1,@0
	ldiw T2,@1
	subw T1,T2
	write16 @0,T1
.ENDM

// params @0 Dirección de memoria
.MACRO inc16
	sumi16 @0,1
.ENDM

// params @0 Dirección de memoria
// params @1 Valor inmediato
.MACRO cpi16
	read16 V,@0
	cpiw V,@1 // Usa registro T
.ENDMACRO

// params @0 Dirección de memoria
// params @1 Valor inmediato
// params @2 Valor inmediato
// params @3 Valor inmediato
// (@0) = (@0) == @1 ? @2 : @3
.MACRO ternario16i
	cpi16 @0,@1
	breq EqualsTernario16i
		assign16(@0, @3) // No son iguales
		rjmp EndTernario16i
	EqualsTernario16i:
		assign16(@0, @2) // Se cumple la condicion
	EndTernario16i:
.ENDM

// params @0 Dirección de memoria
.MACRO true16
	assign16(@0, 1)
.ENDM

// params @0 Dirección de memoria
.MACRO false16
	assign16(@0, 0)
.ENDM

// params @0 Dirección de memoria
.MACRO negarBool16
	ternario16i @0,1,0,1
.ENDM

// params @0 Resultado, dirección de memoria
// params @1 Dirección de memoria
// params @2 Constante
.MACRO m_mul16m_16i_32u
	read16 T1,@1
	ldiw T2,@2
	call mpy16u
	write16 @0,T2
	write16 @0+2,T3
.ENDM

// params @0 Dirección de memoria
// params @1 Dirección de memoria
.MACRO m_mul16_16
	read16 T1,@0
	read16 T2,@1
	mul_16 T1,T2
	write16 @0,T1
.ENDM

// params @0 Dirección de memoria
// params @1 Valor inmediato
.MACRO m_mul16_16i
	read16 T1,@0
	ldiw T2,@1
	mul_16 T1,T2
	write16 @0,T1
.ENDM

// params @0 Índice array
// params @1 Array
// params @2 Valor
// params @3 Tipo @0: {'i': 'inmediato', 'v': 'variable'}
// params @4 Tipo @1: {'p': 'puntero', 'v': 'variable'}
// params @5 Tipo @2: {'i': 'inmediato', 'v': 'variable'}
// Límite: 32000 el. aprox
.MACRO m_array_set_elem_16
	.if @3 == 'v'
		read16 V,@0
		addw V,V
		.if @4 == 'v'
			ldiw X,@1
		.else
			read16 X,@1
		.endif
		addw X,V
		.if @5 == 'i'
			ldiw T1,@2
		.else
			read16 T1,@2
		.endif
		stw X,T1
	.elif @3 == 'i'
		.if @4 == 'v'
			assign16(array_dir_16(@1,@0), @2)
		.else
			ldiw T1,@0*2
			read16 X,@1
			addw X,T1
			.if @5 == 'i'
				ldiw T1,@2
			.else
				read16 T1,@2
			.endif
			stw X,T1
		.endif
	.endif
.ENDM

// params @0 Variable, 2 bytes.
// params @1 Índice del elemento.
// params @2 Array - Dirección del primer el.
// params @3 Tipo @1: {'i': 'inmediato', 'v': 'variable'}
// params @4 Tipo @2: {'p': 'puntero', 'v': 'variable'}
.MACRO m_array_get_el
	.if @4 == 'p'
		.error "ERROR, no implementado todavía"
	.endif
	.if @3 == 'i'
		read16 T1, @2+@1*SIZE_INT
	.else
		ldiw X,@2
		read16 T2,@1
		mul_16i T2,SIZE_INT
		addw X,T2
		ldw T1,X
	.endif
	write16 @0,T1
.ENDM

// params @0 Puntero para almacenar dirección del elemento.
// params @1 Variable, índice del elemento.
// params @2 Array - Dirección del primer el.
// params @3 Valor inmediato, tamaño de cada elemento (bytes).
.MACRO m_array_get_dir_elem
	assign16(@0, 0)
	sum16 @0,@1
	m_mul16_16i @0,@3 // En T1 está almacenado @0, optimizo la operación
	ldiw T2,@2
	addw T1,T2
	write16 @0,T1
.ENDM

// *****************************************************************************
// Manipulación de la SRAM, 32 bits
// *****************************************************************************

// params @0 Dirección de memoria
// params @1 Dirección de memoria
.MACRO m_copy32
	read32 M,@1
	write32 @0,M
.ENDM

// params @0 Dirección de memoria
// params @1 Dirección de memoria
.MACRO cp32
	read32 N,@0
	read32 O,@1
	cpr32 N,O // Usa M
.ENDM

// params @0 Variable, 32 bits
// params @1 Variable, 16 bits
.MACRO m_cp_32_16
	read32 N,@0
	ldi32 O,0
	read16 V,@1
	cpr32 N,O // Usa M
.ENDM

// params @0 Dirección de memoria
// params @1 Valor inmediato
.MACRO cpi32
	read32 N,@0
	cpir32 N,@1
.ENDM

// params @0 Dirección de memoria
// params @1 Dirección de memoria
.MACRO sum32
	read32 M,@0
	read32 N,@1
	call suma32
	write32 @0,M
.ENDM

// params @0 Dirección de memoria
// params @1 Valor inmediato
.MACRO sumi32
	read32 M,@0
	ldi32 N,@1
	add32 M,N
	write32 @0,M
.ENDM

// params @0 Dirección de memoria
.MACRO inc32
	sumi32 @0,1
.ENDM

// params @0 Dirección de memoria
// params @1 Dirección de memoria
.MACRO sub32
	read32 M,@0
	read32 N,@1
	call resta32
	write32 @0,M
.ENDM

// params @0 Variable, 4 bytes
// params @1 Variable, 2 bytes
.MACRO sum32_16
	read32 M,@0
	read16 T3,@1
	clrw W
	call suma32
	write32 @0,M
.ENDM

// params @0 Variable, 4 bytes
// params @1 Variable, 2 bytes
.MACRO sub32_16
	read32 M,@0
	read16 T3,@1
	clrw W
	call resta32
	write32 @0,M
.ENDM

// params @0 Dirección de memoria
// params @1 Dirección de memoria
// .MACRO mult32
// 	read32 M,@0
// 	read32 N,@1
// 	call suma32
// .ENDM

// params @0 Dirección de memoria
// params @1 Valor inmediato
.MACRO div32ui
	read32 N,@0
	ldi32 M,@1
	call Div32b
	write32 @0,N
.ENDM

// *****************************************************************************
// Saltos de tiempo
// *****************************************************************************

.MACRO m_compare_millis_v
	millis(tiempoEnMilis)
	copy32(temp_long, tiempoEnMilis)
	sub32 temp_long,@0
	cp_32_16(temp_long, @1)
.ENDM

.MACRO m_compare_millis_i
	millis(tiempoEnMilis)
	copy32(temp_long, tiempoEnMilis)
	sub32 temp_long,@0
	cpi32 temp_long,@1
.ENDM
// *****************************************************************************
// No organizado
// *****************************************************************************


/*
 * Macro to divide a 4-byte value by a 2-byte value yielding a 2-byte
 * quotient and 2-byte remainder.
 * On entry:   Registro, 32 bits, contains the 4-byte dividend
 *             Registro 16 bits, contains the 2-byte divisor
 *
 * On exit:    XL2,XL1 (X => Registro 32 bits) contains the 2-byte quotient
 *             _tmp1.._tmp0 contains the 2-byte remainder
 * Modifies:   _A3.._A0, _tmp1, _tmp0, _cnt
 *
 */
.macro    div_32_16 //_A3, _A2, _A1, _A0, _B1, _B0, _tmp1, _tmp0, _cnt
    clr     r0
    clr     r1
    ldi     @2, 32
_0div32_16:
    lsl     @0l1
    rol     @0l2
    rol     @0h1
    rol     @0h2
    rol     r0
    rol     r1
    brcs    _1div32_16
    cp      r0, @1l
    cpc     r1, @1h
    brcs    _2div32_16
_1div32_16:
    sub     r0, @1l
    sbc     r1, @1h
    ori     @0l1, 1
_2div32_16:
    dec     @2
    brne    _0div32_16
.endm

// params @0 Variable, valor a transformar
// params @1 Valor inmediato, in_min
// params @2 Valor inmediato, in_max
// params @3 Variable, out_min
// params @4 Variable, out_max
.MACRO m_map16
	subi16 @0,@1 // T1 tiene el valor actual de @0
	read16 T2,@4
	read16 T3,@3
	subw T2,T3
	mul_32 N,T1,T2
	ldiw T2,@2
	ldiw T1,@1
	subw T2,T1
	div_32_16 N,T2,VH
	read16 T1,@3
	addw T3,T1 // T3 es la parte baja de N
	write16 @0,T3
.ENDM

// params @0 Variable, valor a transformar
// params @1 Valor inmediato, in_min
// params @2 Valor inmediato, in_max
// params @3 Valor inmediato, out_min
// params @4 Valor inmediato, out_max
.MACRO m_map16i
	subi16 @0,@1 // T1 tiene el valor actual de @0
	ldiw T2,@4
	ldiw T3,@3
	subw T2,T3
	mul_32 N,T1,T2
	ldiw T2,@2
	ldiw T1,@1
	subw T2,T1
	div_32_16 N,T2,VH
	ldiw T1,@3
	addw T3,T1 // T3 es la parte baja de N
	write16 @0,T3
.ENDM

.MACRO sti
	ldi rmp1, @1
	st @0,rmp1
.ENDM

.MACRO div16uMry
	read8	dd16uL,@1+1
	read8	dd16uH,@1
	ldi	dv16uL,LOW(@2)
	ldi	dv16uH,HIGH(@2)
	rcall	div16u	
	write8 @0,dres16uH		
	write8 @0+1,dres16uL
.ENDM

.MACRO push_all
	push R16
	in R16,SREG
	push_two R16,R17
	push_two R18,R19
	push_two R20,R21
	push_two R22,R23
	push_two R24,R25
	push_two XH,XL
	push_two YH,YL
	push_two ZH,ZL
	push_two R0,R1
	push_two R2,R3
	push_two R12,R13
	push_two R14,R15
.ENDM

.MACRO pop_all
	pop_two R14,R15
	pop_two R12,R13
	pop_two R2,R3
	pop_two R0,R1
	pop_two ZH,ZL
	pop_two YH,YL
	pop_two XH,XL
	pop_two R24,R25
	pop_two R22,R23
	pop_two R20,R21
	pop_two R18,R19
	pop_two R16,R17
	out SREG,R16
	pop R16
.ENDM

// *****************************************************************************
// Nuevas macros para manejo de variables del mismo tamaño
// *****************************************************************************

// params @0 Constante, tamaño 1
// params @1 Constante, tamaño 2
.MACRO m_validate_two
	.if @0 != SIZE_BYTE && @0 != SIZE_INT && @0 != SIZE_LONG || @1 != SIZE_BYTE && @1 != SIZE_INT && @1 != SIZE_LONG
		.error "No se puede realizar operacion"
	.endif
.ENDM

// params @0 Constante, tamaño variable
.MACRO m_validate_one
	.if @0 != SIZE_BYTE && @0 != SIZE_INT && @0 != SIZE_LONG
		.error "No se puede realizar operacion: Dato no es byte, int o long"
	.endif
.ENDM

// params @0 Variable 1
// params @1 Variable 2
// params @2 Constante, tamaño @0
// params @3 Constante, tamaño @1
.MACRO m_copy
	m_validate_two @2,@3
	.if @2 == SIZE_BYTE && @3 == SIZE_BYTE
		m_copy8 @0,@1
	.elif @2 == SIZE_INT && @3 == SIZE_INT
		m_copy16 @0,@1
	.elif @2 == SIZE_LONG && @3 == SIZE_LONG
		m_copy32 @0,@1
	.elif @2 == SIZE_INT
		.if @3 == SIZE_BYTE
			read8 rmp1,@1
			clr rmp2
		.else
			read16 T1,@1
			.warning "Se está copiando una variable de 32 bits a una de 16 bits"
		.endif
		write16 @0,T1
	.elif @2 == SIZE_LONG
		.if @3 == SIZE_INT
			read16 T1,@1
		.else
			read8 rmp1,@1
			clr rmp2
		.endif
		clrw T2
		write32 @0,M
	.else
		.error "No cumple con ninguna condicion"
	.endif
.ENDM

// params @0 Variable
// params @1 Constante, valor
// params @2 Constante, tamaño @0
.MACRO m_assign
	m_validate_one @2
	.if @2 == SIZE_BYTE
		ldi rmp1,@1
		.if @0 < 64
			out @0,rmp1
		.else
			write8 @0,rmp1
		.endif
	.elif @2 == SIZE_INT
		ldiw V,@1
		write16 @0,V
	.else
		ldi32 M,@1
		write32 @0,M
	.endif
.ENDM

// params @0 Variable
// params @1 Valor
// params @2 Constante, tipo de dato de @1
.MACRO m_set 
	.if @2 == 'v'
		copy(@0, @1)
	.elif @2 == 'i'
		assign(@0, @1)
	.else
		.error "Parámetro no permitido"
	.endif
.ENDM

// params @0 Variable
// params @1 Valor
// params @2 Constante, tipo de dato de @1
.MACRO m_set_16
	.if @2 == 'v'
		copy16(@0, @1)
	.elif @2 == 'i'
		assign16(@0, @1)
	.else
		.error "Parámetro no permitido"
	.endif
.ENDM

#endif
