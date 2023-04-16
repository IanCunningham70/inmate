//------------------------------------------------------------------------------------------------------------------------------------------------------------
// Style is Inmate
// 
// idea and gfx : Goerp
// code : Case
// music : TLF
//------------------------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------------------------
#import "..\library\standardlibrary.asm"			
//------------------------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------------------------
.const ScreenMemory	= $0400							// new screen location
.const ColourMemory = $d800							// colour ram never changes
.var screen_data = $3f40
.var colour_data = $4328

//------------------------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------------------------
.var music = LoadSid("sids\SnoopyDrePac.sid")
.pc = music.location "Music"
.fill music.size, music.getData(i)
//------------------------------------------------------------------------------------------------------------------------------------------------------------
										* = $0801 "basic line"
BasicUpstart2(start)

// this is where the code stuff starts 

										*= $080d "Main Code"
start:		
										SetBoth(BLACK)
									
										lda #00
										sta $d41f
										jsr music.init

										sei
										lda #$35
										sta $01
										lda #$7f
										sta $dc0d
										sta $dd0d
										lda $dc0d
										lda $dd0d
										lda #$81
										sta irqenable
										lda #$1b
										sta screenmode
										lda #24
										sta charset
									
										lda #$ff
										sta irqflag

										// 1st IRQ pointers
										lda #$00
										sta raster
										ldx #<IrqPlayMusic
										ldy #>IrqPlayMusic
										stx $fffe
										sty $ffff
										cli

// show artstudio bitmap
										ldx #$00
								!:      lda $3f40,x
								        sta $0400,x
								        lda $403f,x
								        sta $04ff,x
								        lda $413e,x
								        sta $05fe,x
								        lda $423d,x
								        sta $06fd,x
										
								        lda $4338,x
								        sta $d800,x
								        lda $4437,x
								        sta $d8ff,x
								        lda $4536,x
								        sta $d9fe,x
								        lda $4635,x
								        sta $dafd,x
								        inx
								        bne !-

										jsr setSprites

inmate:									jmp inmate
//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.memblock "Play Music"
IrqPlayMusic:							sta IrqPlayMusicAback + 1
										stx IrqPlayMusicXback + 1
										sty IrqPlayMusicYback + 1

										jsr music.play					// play selected tune

          								lda #$32
										sta raster
										ldx #<IrqShowBitmap
										ldy #>IrqShowBitmap
										stx $fffe
										sty $ffff
										inc irqflag
IrqPlayMusicAback:					    lda #$ff
IrqPlayMusicXback:				      	ldx #$ff
IrqPlayMusicYback:				       	ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.memblock "Show Bitmap"
IrqShowBitmap:							sta IrqShowBitmapAback + 1
										stx IrqShowBitmapXback + 1
										sty IrqShowBitmapYback + 1

										lda #$1b
										lda screenmode

										lda #BLACK						// this will be completed when the picture is drawn. 
										sta border
										lda #DARK_GREY
										sta screen

								        lda #24
								        sta charset
								        lda #$3b
								        sta screenmode
								        lda #200
								        sta smoothpos

										lda #$f9
										sta raster
										ldx #<IrqShowNoBorder
										ldy #>IrqShowNoBorder
										stx $fffe
										sty $ffff
										inc irqflag
IrqShowBitmapAback:					    lda #$ff
IrqShowBitmapXback:				      	ldx #$ff
IrqShowBitmapYback:				       	ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.memblock "Remove Upper/Lower Border"
IrqShowNoBorder:						sta IrqShowNoBorderAback + 1
										stx IrqShowNoBorderXback + 1
										sty IrqShowNoBorderYback + 1

										lda #$13
										sta screenmode

										lda #$ff
										sta $3fff


										jsr SinusMovement

										ldy #07
										lda SpriteColor
				!:						sta spritecolors,y 
										dey
										bpl !-
										lda #$00
										sta raster
										ldx #<IrqPlayMusic
										ldy #>IrqPlayMusic
										stx $fffe
										sty $ffff
										inc irqflag
IrqShowNoBorderAback:					lda #$ff
IrqShowNoBorderXback:				    ldx #$ff
IrqShowNoBorderYback:				    ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.memblock "sinus movement"
SinusMovement:

										ldx sinusCounter
										cpx #255
										bne !+

										ldx #$00
										stx sinusCounter

							!:			lda SinusTable,x
										sta sprite0x
										clc
										adc #24
										sta sprite1x 
										clc
										adc #24
										sta sprite2x
										clc
										adc #24
										sta sprite3x
										clc
										adc #24
										sta sprite4x
										clc
										adc #24
										sta sprite5x
										clc
										adc #24
										sta sprite6x

										inc sinusCounter
										inc sinusCounter
										inc sinusCounter
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
setSprites:								lda #$00
										sta spritemulti   			// sprites multi-color mode select
										sta spritermsb				// sprites 0-7 msb of x coordinate
										sta spritepr 				// sprite to background display priority
										sta spriteexpy    			// sprites expand 2x vertical (y)
										sta spriteexpx    			// sprites expand 2x horizontal (x)

										lda #%11111111
										sta spriteset				// sprite display enable
									
										ldx #$0e00/64				// set sprite memory pointers for main logo sprites
										stx 2040
										inx
										stx 2041
										inx
										stx 2042
										inx
										stx 2043
										inx
										stx 2044
										inx
										stx 2045
										inx
										stx 2046

										// set sprite screen position for main logo

										ldy #255			// 78
										sty sprite0y	    // sprite 0 y pos
										sty sprite1y	    // sprite 1 y pos
										sty sprite2y	    // sprite 2 y pos
										sty sprite3y	    // sprite 2 y pos
										sty sprite4y	    // sprite 2 y pos
										sty sprite5y	    // sprite 2 y pos
										sty sprite6y	    // sprite 2 y pos

										lda #108
										sta sprite0x
										clc
										adc #24
										sta sprite1x 
										clc
										adc #24
										sta sprite2x
										clc
										adc #24
										sta sprite3x
										clc
										adc #24
										sta sprite4x
										clc
										adc #24
										sta sprite5x
										clc
										adc #24
										sta sprite6x
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
sinusCounter:							.byte $00
SpriteColor:							.byte YELLOW

										.memblock "sprite sinus"
										*=$c00
SinusTable:								

										.byte $68,$69,$69,$6A,$6B,$6B,$6C,$6C,$6D,$6E,$6E,$6F,$70,$70,$71,$71,$72,$73,$73,$74,$74,$75,$75,$76,$76,$77,$77,$78
										.byte $78,$79,$79,$7A,$7A,$7B,$7B,$7C,$7C,$7C,$7D,$7D,$7E,$7E,$7E,$7F,$7F,$7F,$80,$80,$80,$80,$80,$81,$81,$81,$81,$81
										.byte $82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$81,$81,$81,$81,$81,$80,$80,$80,$80,$80,$7F
										.byte $7F,$7F,$7E,$7E,$7E,$7D,$7D,$7C,$7C,$7C,$7B,$7B,$7A,$7A,$79,$79,$78,$78,$77,$77,$76,$76,$75,$75,$74,$74,$73,$73
										.byte $72,$71,$71,$70,$70,$6F,$6E,$6E,$6D,$6C,$6C,$6B,$6B,$6A,$69,$69,$68,$67,$67,$66,$65,$65,$64,$64,$63,$62,$62,$61
										.byte $60,$60,$5F,$5F,$5E,$5D,$5D,$5C,$5C,$5B,$5B,$5A,$5A,$59,$59,$58,$58,$57,$57,$56,$56,$55,$55,$54,$54,$54,$53,$53
										.byte $52,$52,$52,$51,$51,$51,$50,$50,$50,$50,$50,$4F,$4F,$4F,$4F,$4F,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E
										.byte $4E,$4E,$4E,$4E,$4E,$4F,$4F,$4F,$4F,$4F,$50,$50,$50,$50,$50,$51,$51,$51,$52,$52,$52,$53,$53,$54,$54,$54,$55,$55
										.byte $56,$56,$57,$57,$58,$58,$59,$59,$5A,$5A,$5B,$5B,$5C,$5C,$5D,$5D,$5E,$5F,$5F,$60,$60,$61,$62,$62,$63,$64,$64,$65
										.byte $65,$66,$67,$67
//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.memblock "style is inmate sprites"
										*=$0e00
										.import binary "gfx\text_sprites_6x1.bin"
//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.memblock "bitmap image"
										*=$2000
										.import c64 "gfx\style_final_1_light_grey.art"
//------------------------------------------------------------------------------------------------------------------------------------------------------------
