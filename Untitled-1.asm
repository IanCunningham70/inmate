//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteCarpetIRQ5:						sta SpriteCarpetIRQ5Aback + 1
										stx SpriteCarpetIRQ5Xback + 1
										sty SpriteCarpetIRQ5Yback + 1

										dec border
										ldy #176
										jsr SpriteCarpetYplot
										jsr SpriteCarpetXplot
										inc border 

										lda #90
										sta raster
										ldx #<SpriteCarpetIRQ5
										ldy #>SpriteCarpetIRQ5
										stx $fffe
										sty $ffff
										inc irqflag
SpriteCarpetIRQ5Aback:					lda #$ff
SpriteCarpetIRQ5Xback:				    ldx #$ff
SpriteCarpetIRQ5Yback:				    ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
