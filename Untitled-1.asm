SpriteCarpetIRQ:						sta SpriteCarpetIRQAback + 1
										stx SpriteCarpetIRQXback + 1
										sty SpriteCarpetIRQYback + 1


										lda #24
										sta sprite0x
										clc
										adc #48
										sta sprite1x 
										clc
										adc #48
										sta sprite2x
										clc
										adc #48
										sta sprite3x
										clc
										adc #48
										sta sprite4x
										clc
										adc #48
										sta sprite5x
										clc
										adc #48
										sta sprite6x

										lda #%11100000
										ora $d010
										sta $d010


										lda #$00
										sta raster
										ldx #<SpriteCarpetIRQ
										ldy #>SpriteCarpetIRQ
										stx $fffe
										sty $ffff
										inc irqflag
SpriteCarpetIRQAback:					lda #$ff
SpriteCarpetIRQXback:				    ldx #$ff
SpriteCarpetIRQYback:				    ldy #$ff
										rti