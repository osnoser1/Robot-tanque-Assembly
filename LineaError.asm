#ifndef LINEA_ERROR_ASM
#define LINEA_ERROR_ASM

#define CANT_LECTURAS_ERROR		100
#define PORCENTAJE_ERROR		0.65

#define LINEA_ERROR_SIZE		SIZE_INT * CANT_LECTURAS_ERROR + SIZE_LONG + 4 * SIZE_INT

#define LineaError(_this) malloc(_this,LINEA_ERROR_SIZE) _linea_error _this
#define LineaError_esBlanco(_var, _this) _linea_error_es_blanco _var,_this,_pinSensor
#define LineaError_esNegro(_var, _this) _linea_error_es_negro _var,_this,_pinSensor
#define LineaError_actualizar(_this, _pinSensor) _linea_error_actualizar _this,_pinSensor

#define lineaError_Sum(_var)				_var // LONG
#define lineaError_Cant(_var)				_var + SIZE_LONG // INT
#define lineaError_Indice(_var)				_var + SIZE_LONG + SIZE_INT // INT
#define lineaError_Blanco(_var)				_var + 2 * SIZE_INT + SIZE_LONG // INT
#define lineaError_Negro(_var)				_var + 3 * SIZE_INT + SIZE_LONG // INT
#define lineaError_Array(_var)				_var + 4 * SIZE_INT + SIZE_LONG // INT ARRAY

// params @0 This
.MACRO _linea_error
	assign32(lineaError_Sum(@0), 0)
	assign16(lineaError_Cant(@0), 0)
	assign16(lineaError_Indice(@0), 0)
.ENDM

// params @0 This
// params @1 Pin sensor de linea
.MACRO _linea_error_actualizar
	analogRead tmpLinea,@1
	cpi16 lineaError_Cant(@0), CANT_LECTURAS_ERROR
	jeq(IgualCantLecturas)
		array_set_elem_16(lineaError_Cant(@0), lineaError_Array(@0), tmpLinea, 'v', 'v', 'v')
		inc16 lineaError_Cant(@0)
		jmp EndCantLecturas
	IgualCantLecturas:
		cpi16 lineaError_Indice(@0),0
		jne(NoEsIgualIndice)
			sub32_16 lineaError_Sum(@0), lineaError_Array(@0) + CANT_LECTURAS_ERROR * 2 - 2
			jmp EndNoEsIguaIndice
		NoEsIgualIndice:
			array_get_el_16(tempInt, lineaError_Indice(@0), lineaError_Array(@0), 'v')
			sub32_16 lineaError_Sum(@0), tempInt
		EndNoEsIguaIndice:
		array_set_elem_16(lineaError_Indice(@0), lineaError_Array(@0), tmpLinea, 'v', 'v', 'v')
		inc16 lineaError_Indice(@0)
		assign16eq lineaError_Indice(@0), CANT_LECTURAS_ERROR, 0
	EndCantLecturas:
	sum32_16 lineaError_Sum(@0), tmpLinea
	LineaError_esNegro(lineaError_Negro(@0), @0)
	LineaError_esBlanco(lineaError_Blanco(@0), @0)
	EndLineaErrorActualizar:
.ENDM

// params @0 Variable
// params @1 This
.MACRO _linea_error_es_blanco
	m_mul16m_16i_32u tempLong, lineaError_Cant(@1),PORCENTAJE_ERROR*1024
	cp32 lineaError_Sum(@1), tempLong
	jlt(SalvarBlanco)
		assign16(@0, 0)
		rjmp EndLineaErrorEsBlanco
	SalvarBlanco:
		assign16(@0, 1)
	EndLineaErrorEsBlanco:
.ENDM

// params @0 Variable
// params @1 This
.MACRO _linea_error_es_negro
	m_mul16m_16i_32u tempLong, lineaError_Cant(@1),PORCENTAJE_ERROR*1024
	cp32 lineaError_Sum(@1), tempLong
	jge(SalvarNegro)
		assign16(@0, 0)
		rjmp EndLineaErrorEsNegro
	SalvarNegro:
		assign16(@0, 1)
	EndLineaErrorEsNegro:
.ENDM

#endif // LINEA_ERROR_ASM
