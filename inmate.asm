//------------------------------------------------------------------------------------------------------------------------------------------------------------
// Style is Inmate
// 
// idea and gfx : Goerp
// code : Case
// music : TLF
// sprites : CUPID
//------------------------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------------------------
#import "..\library\standardlibrary.asm"			
//------------------------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------------------------
.var music = LoadSid("sids\SnoopyDrePac.sid")
.pc = music.location "Music"
.fill music.size, music.getData(i)
//------------------------------------------------------------------------------------------------------------------------------------------------------------
										* = $0801 "basic line"
BasicUpstart2(start)

										* = $5000 "Main Code"
start:
										lda #$35
										sta $01

										lda border
										sta SpriteCarpetColor
										jsr SpriteCarpet

										// fade to black
										// transfer picture
										// new bars sprite carpet
										// pause for a while and remove bars
										// continue.
									
										lda #00
										sta $d41f
										jsr music.init
										
										sei
										lda #$7f
										sta $dc0d
										sta $dd0d
										lda $dc0d
										lda $dd0d
										lda #$ff
										sta irqflag
										lda #$81
										sta irqenable
										lda #$1b
										sta screenmode
										lda #24
										sta charset
										lda #$00
										sta raster
										ldx #<IrqPlayMusic
										ldy #>IrqPlayMusic
										stx $fffe
										sty $ffff
										cli


										jsr SetLogoSprites

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

										lda #BLACK
										sta border
										lda #DARK_GREY
										sta screen

								        lda #24
								        sta charset
								        lda #$3b
								        sta screenmode
								        lda #200
								        sta smoothpos

										jsr SinusMovement
									
										jsr FlashSprites

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
SinusMovement:							ldx sinusCounter
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

										lda #$00
										ora $d010
										sta $d010

										inc sinusCounter
										inc sinusCounter
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.memblock "flash sprites"
FlashSprites:							
										lda FlashDelay
										sec
										sbc #$02
										and #$07
										sta FlashDelay
										bcc !+
										rts

						!:				ldx FlashCounter
										cpx #6
										beq !+
										lda #DARK_GRAY
										sta SpriteColor
										inc FlashCounter
										rts
						!:
										lda #WHITE
										sta SpriteColor
										lda #$00
										sta FlashCounter
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
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SetLogoSprites:							
										jsr setSprites

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
										.memblock "sprite carpet - basic fader"
SpriteCarpet:							
										jsr setSprites

										sei
										lda #$7f
										sta $dc0d
										sta $dd0d
										lda $dc0d
										lda $dd0d
										lda #$1b
										sta screenmode
										lda #$ff
										sta irqflag
										lda #$81
										sta irqenable
										lda #$2f
										sta raster
										ldx #<SpriteCarpetIRQ
										ldy #>SpriteCarpetIRQ
										stx $fffe
										sty $ffff
										cli

										jsr SetCarpetSprites
										jsr SpriteCarpetXplot

										lda #%00000000
										sta spritemulti   			// sprites multi-color mode select
										sta spritermsb				// sprites 0-7 msb of x coordinate
										sta spritepr 				// sprite to background display priority
										lda #%01111111
										sta spriteexpy    			// sprites expand 2x vertical (y)
										sta spriteexpx    			// sprites expand 2x horizontal (x)
										sta spriteset				// sprite display enable

SpriteCarpetLoop:						jmp SpriteCarpetLoop		// wait until the basic fade carpet is complete

										jsr pauseLoop

// fade to black
										sei
										lda #$0b
										sta screenmode
										lda #$ff
										sta irqflag
										lda #$81
										sta irqenable
										lda #$01
										sta raster
										ldx #<FadeIRQ
										ldy #>FadeIRQ
										stx $fffe
										sty $ffff
										cli

BlackPause:								jmp BlackPause				// wait until everything is black


// prison bars

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

										lda SpriteBarsAnimPointers
										sta SpriteCarpetFadePointers

										sei
										lda #$ff
										sta irqflag
										lda #$81
										sta irqenable
										lda #$01
										sta raster
										ldx #<SpriteBarsIRQ
										ldy #>SpriteBarsIRQ
										stx $fffe
										sty $ffff
										cli

										jsr SetCarpetSprites
										jsr SpriteCarpetXplot

										lda #%00000000
										sta spritermsb				// sprites 0-7 msb of x coordinate
										sta spritepr 				// sprite to background display priority
										lda #%01111111
										sta spritemulti   			// sprites multi-color mode select
										sta spriteexpy    			// sprites expand 2x vertical (y)
										sta spriteexpx    			// sprites expand 2x horizontal (x)
										sta spriteset				// sprite display enable

SpriteBarsLoop:							jmp SpriteBarsLoop

										jmp *

										jsr pauseLoop
										jsr pauseLoop
										jsr pauseLoop

										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
FadeIRQ:								sta FadeIRQAback + 1
										stx FadeIRQXback + 1
										sty FadeIRQYback + 1

fade_color:								lda #$00
										sta screen
										sta border

fader_black:							jsr fade2black

										lda #$01
										sta raster
										ldx #<FadeIRQ
										ldy #>FadeIRQ
										stx $fffe
										sty $ffff
										inc irqflag
FadeIRQAback:							lda #$ff
FadeIRQXback:				    		ldx #$ff
FadeIRQYback:				    		ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
fade2black:								lda fade2delay
										sec
										sbc #$04
										and #$07
										sta fade2delay
										bcc !+
										rts
								!:		ldx fade2count
										cpx fade2max
										beq !+
										lda fade2black_table,x
										sta fade_color+1
										inc fade2count
										rts
								!:		lda #$ad
										sta fader_black
										sta BlackPause
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
pauseLoop:      				        ldx #255
			    				        ldy #255
                				!:      dey
                				        bne !-
                				        dex
                				        bne pauseLoop+2
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteCarpetIRQ:						sta SpriteCarpetIRQAback + 1
										stx SpriteCarpetIRQXback + 1
										sty SpriteCarpetIRQYback + 1

										ldx SpriteCarpetFadePointers	// set sprite memory pointers for main logo sprites
										stx 2040
										stx 2041
										stx 2042
										stx 2043
										stx 2044
										stx 2045
										stx 2046

										ldy #50				// top left hand corner of the screen
										jsr SpriteCarpetYplot
										jsr SpriteCarpetXplot

										ldy #07
										lda SpriteCarpetColor
								!:		sta spritecolors,y 
										dey
										bpl !-

										lda #90
										sta raster
										ldx #<SpriteCarpetIRQ1
										ldy #>SpriteCarpetIRQ1
										stx $fffe
										sty $ffff
										inc irqflag
SpriteCarpetIRQAback:					lda #$ff
SpriteCarpetIRQXback:				    ldx #$ff
SpriteCarpetIRQYback:				    ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteCarpetIRQ1:						sta SpriteCarpetIRQ1Aback + 1
										stx SpriteCarpetIRQ1Xback + 1
										sty SpriteCarpetIRQ1Yback + 1

										ldy #92
										jsr SpriteCarpetYplot

										lda #120
										sta raster
										ldx #<SpriteCarpetIRQ2
										ldy #>SpriteCarpetIRQ2
										stx $fffe
										sty $ffff
										inc irqflag
SpriteCarpetIRQ1Aback:					lda #$ff
SpriteCarpetIRQ1Xback:				    ldx #$ff
SpriteCarpetIRQ1Yback:				    ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteCarpetIRQ2:						sta SpriteCarpetIRQ2Aback + 1
										stx SpriteCarpetIRQ2Xback + 1
										sty SpriteCarpetIRQ2Yback + 1

										ldy #92+42
										jsr SpriteCarpetYplot

										lda #160
										sta raster
										ldx #<SpriteCarpetIRQ3
										ldy #>SpriteCarpetIRQ3
										stx $fffe
										sty $ffff
										inc irqflag
SpriteCarpetIRQ2Aback:					lda #$ff
SpriteCarpetIRQ2Xback:				    ldx #$ff
SpriteCarpetIRQ2Yback:				    ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteCarpetIRQ3:						sta SpriteCarpetIRQ3Aback + 1
										stx SpriteCarpetIRQ3Xback + 1
										sty SpriteCarpetIRQ3Yback + 1

										ldy #134
										jsr SpriteCarpetYplot

										lda #174
										sta raster
										ldx #<SpriteCarpetIRQ4
										ldy #>SpriteCarpetIRQ4
										stx $fffe
										sty $ffff
										inc irqflag
SpriteCarpetIRQ3Aback:					lda #$ff
SpriteCarpetIRQ3Xback:				    ldx #$ff
SpriteCarpetIRQ3Yback:				    ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteCarpetIRQ4:						sta SpriteCarpetIRQ4Aback + 1
										stx SpriteCarpetIRQ4Xback + 1
										sty SpriteCarpetIRQ4Yback + 1

										ldy #176
										jsr SpriteCarpetYplot

										lda #216
										sta raster
										ldx #<SpriteCarpetIRQ5
										ldy #>SpriteCarpetIRQ5
										stx $fffe
										sty $ffff
										inc irqflag
SpriteCarpetIRQ4Aback:					lda #$ff
SpriteCarpetIRQ4Xback:				    ldx #$ff
SpriteCarpetIRQ4Yback:				    ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteCarpetIRQ5:						sta SpriteCarpetIRQ5Aback + 1
										stx SpriteCarpetIRQ5Xback + 1
										sty SpriteCarpetIRQ5Yback + 1

										ldy #218
										jsr SpriteCarpetYplot
										jsr SpriteWiper

										lda #$2f
										sta raster
										ldx #<SpriteCarpetIRQ
										ldy #>SpriteCarpetIRQ
										stx $fffe
										sty $ffff
										inc irqflag
SpriteCarpetIRQ5Aback:					lda #$ff
SpriteCarpetIRQ5Xback:				    ldx #$ff
SpriteCarpetIRQ5Yback:				    ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteWiper:							lda SpriteWipeAnimDelay
										sec
										sbc #$02
										and #$07
										sta SpriteWipeAnimDelay
										bcc SpriteWiper2
										rts
SpriteWiper2:							ldx SpriteWipeAnimCounter
										cpx #10
										beq !+
										lda SpriteWipeAnimPointers,x
										sta SpriteCarpetFadePointers										
										inc SpriteWipeAnimCounter
										rts

								!:		lda #$ad
										sta SpriteCarpetLoop
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteCarpetYplot:						sty sprite0y	
										sty sprite1y	
										sty sprite2y	
										sty sprite3y	
										sty sprite4y	
										sty sprite5y	
										sty sprite6y	
										sty sprite7y	
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteCarpetXplot:						lda #24
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
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SetCarpetSprites:						ldy #40				// 78
										sty sprite0y	    // sprite 0 y pos
										sty sprite1y	    // sprite 1 y pos
										sty sprite2y	    // sprite 2 y pos
										sty sprite3y	    // sprite 2 y pos
										sty sprite4y	    // sprite 2 y pos
										sty sprite5y	    // sprite 2 y pos
										sty sprite6y	    // sprite 2 y pos
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteBarsIRQ:							sta SpriteBarsIRQAback + 1
										stx SpriteBarsIRQXback + 1
										sty SpriteBarsIRQYback + 1

								        lda #$3b
								        sta screenmode
								        lda #24
								        sta charset
								        lda #200
								        sta smoothpos

										ldx SpriteCarpetFadePointers	// set sprite memory pointers for main logo sprites
										stx 2040
										stx 2041
										stx 2042
										stx 2043
										stx 2044
										stx 2045
										stx 2046

										ldy #50						// top left hand corner of the screen
										jsr SpriteBarsYplot
										jsr SpriteBarsXplot

										ldy #07
										lda #LIGHT_GREY
								!:		sta spritecolors,y 
										dey
										bpl !-

										lda #DARK_GREY
										sta spritemcol0
										lda #GREY
										sta spritemcol1

										lda #90
										sta raster
										ldx #<SpriteBarsIRQ1
										ldy #>SpriteBarsIRQ1
										stx $fffe
										sty $ffff
										inc irqflag
SpriteBarsIRQAback:						lda #$ff
SpriteBarsIRQXback:				    	ldx #$ff
SpriteBarsIRQYback:				    	ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteBarsIRQ1:							sta SpriteBarsIRQ1Aback + 1
										stx SpriteBarsIRQ1Xback + 1
										sty SpriteBarsIRQ1Yback + 1

										ldy #92
										jsr SpriteBarsYplot

										lda #120
										sta raster
										ldx #<SpriteBarsIRQ2
										ldy #>SpriteBarsIRQ2
										stx $fffe
										sty $ffff
										inc irqflag
SpriteBarsIRQ1Aback:					lda #$ff
SpriteBarsIRQ1Xback:				    ldx #$ff
SpriteBarsIRQ1Yback:				    ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteBarsIRQ2:							sta SpriteBarsIRQ2Aback + 1
										stx SpriteBarsIRQ2Xback + 1
										sty SpriteBarsIRQ2Yback + 1

										ldy #92+42
										jsr SpriteBarsYplot

										lda #160
										sta raster
										ldx #<SpriteBarsIRQ3
										ldy #>SpriteBarsIRQ3
										stx $fffe
										sty $ffff
										inc irqflag
SpriteBarsIRQ2Aback:					lda #$ff
SpriteBarsIRQ2Xback:				    ldx #$ff
SpriteBarsIRQ2Yback:				    ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteBarsIRQ3:							sta SpriteBarsIRQ3Aback + 1
										stx SpriteBarsIRQ3Xback + 1
										sty SpriteBarsIRQ3Yback + 1

										ldy #134
										jsr SpriteBarsYplot

										lda #174
										sta raster
										ldx #<SpriteBarsIRQ4
										ldy #>SpriteBarsIRQ4
										stx $fffe
										sty $ffff
										inc irqflag
SpriteBarsIRQ3Aback:					lda #$ff
SpriteBarsIRQ3Xback:				    ldx #$ff
SpriteBarsIRQ3Yback:				    ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteBarsIRQ4:							sta SpriteBarsIRQ4Aback + 1
										stx SpriteBarsIRQ4Xback + 1
										sty SpriteBarsIRQ4Yback + 1

										ldy #176
										jsr SpriteBarsYplot

										lda #216
										sta raster
										ldx #<SpriteBarsIRQ5
										ldy #>SpriteBarsIRQ5
										stx $fffe
										sty $ffff
										inc irqflag
SpriteBarsIRQ4Aback:					lda #$ff
SpriteBarsIRQ4Xback:				    ldx #$ff
SpriteBarsIRQ4Yback:				    ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteBarsIRQ5:							sta SpriteBarsIRQ5Aback + 1
										stx SpriteBarsIRQ5Xback + 1
										sty SpriteBarsIRQ5Yback + 1

										ldy #218
										jsr SpriteBarsYplot
										jsr SpriteBarsWiper

										lda #$2f
										sta raster
										ldx #<SpriteBarsIRQ
										ldy #>SpriteBarsIRQ
										stx $fffe
										sty $ffff
										inc irqflag
SpriteBarsIRQ5Aback:					lda #$ff
SpriteBarsIRQ5Xback:				    ldx #$ff
SpriteBarsIRQ5Yback:				    ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteBarsWiper:						lda SpriteBarsAnimDelay
										sec
										sbc #$02
										and #$07
										sta SpriteBarsAnimDelay
										bcc SpriteBarsWiper2
										rts
SpriteBarsWiper2:						ldx SpriteBarsAnimCounter
										cpx #6
										beq !+
										lda SpriteBarsAnimPointers,x
										sta SpriteCarpetFadePointers										
										inc SpriteBarsAnimCounter
										rts

								!:		lda #$ad
										sta SpriteBarsLoop
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteBarsYplot:						sty sprite0y	
										sty sprite1y	
										sty sprite2y	
										sty sprite3y	
										sty sprite4y	
										sty sprite5y	
										sty sprite6y	
										sty sprite7y	
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
SpriteBarsXplot:						lda #24
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
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.align $100
										.memblock "sprite pointers"

sinusCounter:							.byte $00
SpriteColor:							.byte $00						
FlashDelay:								.byte $00
FlashCounter:							.byte $00

SpriteCarpetColor:						.byte $00						// match the border color
SpriteCarpetFadePointers:				.byte $00

										// pointers for the basic fade sprites
SpriteWipeAnimDelay:					.byte $00
SpriteWipeAnimCounter:					.byte $00										
SpriteWipeAnimOffset:					.byte $00			// sprite offset, column 1, 2, 3 etc.
SpriteWipeAnimPointers:					.byte WipeSprite1/64,WipeSprite2/64,WipeSprite3/64,WipeSprite4/64,WipeSprite5/64
										.byte WipeSprite6/64,WipeSprite7/64,WipeSprite8/64,WipeSprite9/64,WipeSprite0/64
										

										// pointers for the jail bar sprites
SpriteBarsAnimDelay:					.byte $00
SpriteBarsAnimCounter:					.byte $00										
SpriteBarsAnimPointers:					.byte barSprite0/64,barSprite1/64,barSprite2/64,barSprite3/64,barSprite4/64,barSprite5/64,barSprite6/64


fade2delay:								.byte $00
fade2count:								.byte $00
fade2max:								.byte 8
fade2black_table:						.byte $04,$0a,$09,$02,$00,$00,$00,$00		// from light blue to black
										.byte $ff,$ff

										.align $100

										.memblock "sprite sinus"
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
*=$0840 "Wipe Sprites"

WipeSprite0:

.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0e

WipeSprite1:

.byte $c0,$00,$00,$80,$00,$00,$00,$00,$01,$00,$00,$03,$00,$00,$07,$e0
.byte $00,$00,$c0,$00,$00,$80,$00,$00,$00,$00,$01,$00,$00,$03,$00,$00
.byte $07,$e0,$00,$00,$c0,$00,$00,$80,$00,$00,$00,$00,$01,$00,$00,$03
.byte $00,$00,$07,$e0,$00,$00,$c0,$00,$00,$80,$00,$00,$00,$00,$01,$0e

WipeSprite2:

.byte $f0,$00,$00,$e0,$00,$00,$00,$00,$0f,$00,$00,$1f,$00,$00,$3f,$f8
.byte $00,$00,$f0,$00,$00,$e0,$00,$00,$00,$00,$0f,$00,$00,$1f,$00,$00
.byte $3f,$f8,$00,$00,$f0,$00,$00,$e0,$00,$00,$00,$00,$0f,$00,$00,$1f
.byte $00,$00,$3f,$f8,$00,$00,$f0,$00,$00,$e0,$00,$00,$00,$00,$0f,$0e

WipeSprite3:

.byte $fe,$00,$00,$fc,$00,$00,$00,$00,$3f,$00,$00,$7f,$00,$00,$ff,$ff
.byte $00,$00,$fe,$00,$00,$fc,$00,$00,$00,$00,$3f,$00,$00,$7f,$00,$00
.byte $ff,$ff,$00,$00,$fe,$00,$00,$fc,$00,$00,$00,$00,$3f,$00,$00,$7f
.byte $00,$00,$ff,$ff,$00,$00,$fe,$00,$00,$fc,$00,$00,$00,$00,$3f,$0e

WipeSprite4:

.byte $ff,$80,$00,$ff,$00,$00,$00,$00,$ff,$00,$01,$ff,$00,$03,$ff,$ff
.byte $c0,$00,$ff,$80,$00,$ff,$00,$00,$00,$00,$ff,$00,$01,$ff,$00,$03
.byte $ff,$ff,$c0,$00,$ff,$80,$00,$ff,$00,$00,$00,$00,$ff,$00,$01,$ff
.byte $00,$03,$ff,$ff,$c0,$00,$ff,$80,$00,$ff,$00,$00,$00,$00,$ff,$0e

WipeSprite5:

.byte $ff,$f0,$00,$ff,$e0,$00,$00,$07,$ff,$00,$0f,$ff,$00,$1f,$ff,$ff
.byte $f8,$00,$ff,$f0,$00,$ff,$e0,$00,$00,$07,$ff,$00,$0f,$ff,$00,$1f
.byte $ff,$ff,$f8,$00,$ff,$f0,$00,$ff,$e0,$00,$00,$07,$ff,$00,$0f,$ff
.byte $00,$1f,$ff,$ff,$f8,$00,$ff,$f0,$00,$ff,$e0,$00,$00,$07,$ff,$0e

WipeSprite6:

.byte $ff,$fe,$00,$ff,$fc,$00,$00,$3f,$ff,$00,$7f,$ff,$00,$ff,$ff,$ff
.byte $ff,$00,$ff,$fe,$00,$ff,$fc,$00,$00,$3f,$ff,$00,$7f,$ff,$00,$ff
.byte $ff,$ff,$ff,$00,$ff,$fe,$00,$ff,$fc,$00,$00,$3f,$ff,$00,$7f,$ff
.byte $00,$ff,$ff,$ff,$ff,$00,$ff,$fe,$00,$ff,$fc,$00,$00,$3f,$ff,$0e

WipeSprite7:

.byte $ff,$ff,$80,$ff,$ff,$00,$00,$ff,$ff,$01,$ff,$ff,$03,$ff,$ff,$ff
.byte $ff,$c0,$ff,$ff,$80,$ff,$ff,$00,$00,$ff,$ff,$01,$ff,$ff,$03,$ff
.byte $ff,$ff,$ff,$c0,$ff,$ff,$80,$ff,$ff,$00,$00,$ff,$ff,$01,$ff,$ff
.byte $03,$ff,$ff,$ff,$ff,$c0,$ff,$ff,$80,$ff,$ff,$00,$00,$ff,$ff,$0e

WipeSprite8:

.byte $ff,$ff,$f0,$ff,$ff,$e0,$0f,$ff,$ff,$1f,$ff,$ff,$3f,$ff,$ff,$ff
.byte $ff,$f8,$ff,$ff,$f0,$ff,$ff,$e0,$0f,$ff,$ff,$1f,$ff,$ff,$3f,$ff
.byte $ff,$ff,$ff,$f8,$ff,$ff,$f0,$ff,$ff,$e0,$0f,$ff,$ff,$1f,$ff,$ff
.byte $3f,$ff,$ff,$ff,$ff,$f8,$ff,$ff,$f0,$ff,$ff,$e0,$0f,$ff,$ff,$0e

WipeSprite9:

.byte $ff,$ff,$fc,$ff,$ff,$f8,$3f,$ff,$ff,$7f,$ff,$ff,$ff,$ff,$ff,$ff
.byte $ff,$fe,$ff,$ff,$fc,$ff,$ff,$f8,$3f,$ff,$ff,$7f,$ff,$ff,$ff,$ff
.byte $ff,$ff,$ff,$fe,$ff,$ff,$fc,$ff,$ff,$f8,$3f,$ff,$ff,$7f,$ff,$ff
.byte $ff,$ff,$ff,$ff,$ff,$fe,$ff,$ff,$fc,$ff,$ff,$f8,$3f,$ff,$ff,$0e

*=$0b00 "jail bar Sprites"

barSprite0:

.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0b

barSprite1:

.byte $7d,$00,$00,$5f,$fd,$00,$55,$ff,$fd,$55,$5d,$df,$55,$55,$77,$55
.byte $55,$5f,$55,$55,$57,$55,$55,$57,$55,$55,$57,$55,$55,$57,$55,$55
.byte $55,$55,$55,$57,$55,$55,$55,$55,$55,$57,$55,$55,$55,$55,$55,$55
.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$00,$55,$00,$00,$85

barSprite2:

.byte $1d,$00,$00,$1f,$d0,$00,$15,$fd,$00,$15,$5f,$d0,$15,$57,$f4,$15
.byte $57,$fc,$15,$55,$f4,$15,$57,$f4,$15,$55,$f4,$15,$55,$f4,$15,$55
.byte $74,$15,$55,$f4,$15,$55,$74,$15,$55,$f4,$15,$55,$d4,$15,$55,$54
.byte $15,$55,$50,$15,$55,$00,$15,$50,$00,$15,$00,$00,$15,$00,$00,$85

barSprite3:

.byte $05,$00,$00,$05,$00,$00,$05,$40,$00,$07,$d0,$00,$05,$f4,$00,$05
.byte $f5,$00,$05,$fd,$40,$05,$f5,$40,$05,$7d,$40,$05,$fd,$40,$05,$7d
.byte $40,$05,$fd,$40,$05,$7d,$40,$05,$7d,$40,$05,$7d,$40,$05,$5d,$00
.byte $05,$74,$00,$05,$50,$00,$05,$40,$00,$05,$00,$00,$05,$00,$00,$85

barSprite4:

.byte $01,$40,$00,$01,$d0,$00,$01,$d0,$00,$01,$f4,$00,$01,$f4,$00,$01
.byte $75,$00,$01,$f5,$00,$01,$75,$00,$01,$d5,$00,$01,$75,$00,$01,$d5
.byte $00,$01,$55,$00,$01,$55,$00,$01,$d5,$00,$01,$55,$00,$01,$55,$00
.byte $01,$54,$00,$01,$54,$00,$01,$50,$00,$01,$50,$00,$01,$40,$00,$85

barSprite5:

.byte $00,$15,$00,$00,$17,$00,$00,$15,$00,$00,$17,$00,$00,$17,$00,$00
.byte $1f,$00,$00,$17,$00,$00,$1f,$00,$00,$1f,$00,$00,$1f,$00,$00,$1f
.byte $00,$00,$17,$00,$00,$1f,$00,$00,$17,$00,$00,$17,$00,$00,$15,$00
.byte $00,$17,$00,$00,$15,$00,$00,$15,$00,$00,$15,$00,$00,$15,$00,$85

barSprite6:

.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$85


										*=$0e00
										.memblock "style is inmate sprites"
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$0c,$00,$00,$1c,$00,$00,$18,$03
										.byte $f0,$18,$07,$f8,$30,$0e,$38,$30,$0c,$03,$ff,$0e,$07,$f8,$07,$c0
										.byte $60,$00,$e0,$e0,$00,$70,$c0,$30,$70,$c0,$39,$e1,$80,$3f,$c3,$81
										.byte $1f,$03,$03,$00,$03,$36,$00,$00,$3e,$00,$00,$3c,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$06,$00,$00,$06,$00,$00,$0e,$00,$30,$0c,$00,$71
										.byte $9c,$78,$73,$9c,$fc,$67,$19,$ce,$67,$39,$86,$6e,$73,$8c,$6c,$73
										.byte $38,$78,$e3,$e0,$70,$e3,$80,$e1,$c3,$0c,$c1,$c3,$9c,$83,$81,$f8
										.byte $03,$00,$f0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$10,$00,$00,$78,$00,$00,$20,$00,$00
										.byte $03,$c0,$00,$cf,$f0,$01,$dc,$70,$01,$98,$00,$01,$9c,$00,$03,$0f
										.byte $80,$03,$03,$c0,$07,$00,$c0,$06,$60,$c0,$06,$71,$c0,$00,$7f,$80
										.byte $00,$3e,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$02,$00,$00,$0f,$00,$00,$04,$00,$00,$00
										.byte $00,$00,$0c,$5c,$37,$1c,$7e,$3f,$18,$ee,$79,$38,$c6,$71,$31,$cc
										.byte $73,$71,$8c,$e3,$63,$1c,$e7,$e3,$19,$c7,$c2,$19,$c7,$00,$11,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$e0,$00
										.byte $03,$f0,$8f,$07,$30,$df,$80,$30,$f3,$80,$73,$e7,$0f,$ef,$c7,$3c
										.byte $60,$ce,$70,$e1,$8e,$61,$c1,$0c,$61,$c1,$1c,$7f,$83,$1c,$1f,$83
										.byte $18,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$18,$00,$00,$30,$00,$00,$30,$00,$00,$30
										.byte $38,$00,$70,$fc,$00,$61,$c6,$00,$fd,$86,$00,$f3,$1c,$00,$c3,$78
										.byte $00,$c3,$e0,$00,$83,$86,$00,$83,$0e,$00,$01,$fc,$00,$00,$f0,$00
//------------------------------------------------------------------------------------------------------------------------------------------------------------
										*=$2000 "bitmap image"
										.import c64 "gfx\style_final_1_light_grey.art"
//------------------------------------------------------------------------------------------------------------------------------------------------------------
