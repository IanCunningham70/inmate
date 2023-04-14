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

.var BitmapScreen	= $3f40 // + ScreenMemory			// bitmap screen data
.var BitmapColours	= $4328 // + ScreenMemory			// bitmap color data

.var textFlash  = ColourMemory + (40*12)
.var screen_data = $3f40
.var colour_data = $4328
.var BackGroundColour = $4710
//------------------------------------------------------------------------------------------------------------------------------------------------------------
.var music = LoadSid("sids\SnoopyDrePac.sid")
.pc = music.location "Music"
.fill music.size, music.getData(i)
//------------------------------------------------------------------------------------------------------------------------------------------------------------

										* = $0801 "basic line"
BasicUpstart2(start)

// this is where the code stuff starts ... hopefully it will work

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

										jsr setSprites

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


//------------------------------------------------------------------------------------------------------------------------------------------------------------
// setup sprites locations for logo in bottom border			
//------------------------------------------------------------------------------------------------------------------------------------------------------------
setSprites:								lda #$00
										sta spritemulti   			// sprites multi-color mode select
										sta spritermsb				// sprites 0-7 msb of x coordinate
										sta spritepr 				// sprite to background display priority
										sta spriteexpy    			// sprites expand 2x vertical (y)
										sta spriteexpx    			// sprites expand 2x horizontal (x)

										lda #%11111111
										sta spriteset				// sprite display enable

										ldy #07
										lda #WHITE
				!:						sta spritecolors,y 
										dey
										bpl !-
										
										ldx #$1e00/64				// set sprite memory pointers for main logo sprites
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


//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.memblock "style is inmate sprites"
										*=$1e00
										.import binary "gfx\text_sprites_6x1.bin"
//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.memblock "bitmap image"
										*=$2000
										.import c64 "gfx\style_final_1_light_grey.art"
//------------------------------------------------------------------------------------------------------------------------------------------------------------
