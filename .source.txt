//------------------------------------------------------------------------------------------------------------------------------------------------------------
// Style is Inmate
// 
// idea and gfx : shaun pearson
// code : code
// music : tlf
// help & support : Dano & Anonym
//------------------------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------------------------
// memory map 
// 
// $080d-$1aff - main code
// $1b00-$1bff - sprite data
// $1c00-$17ff - title screen text
// $2000-$22ff - title screen font
// $8000-$9e7f - Music
// $6000-$7fff - picture 1
// $a000-$ffff - pictures 2,3,4,5
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

										lda #$7f
										sta $3fff

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


// setup sprites locations etc for title page			
//------------------------------------------------------------------------------------------------------------------------------------------------------------
setSprites:								lda #$00
										sta spritemulti   	// sprites multi-color mode select
										sta spritermsb		// sprites 0-7 msb of x coordinate

										lda #%11111111
										sta spriteset		// sprite display enable
										lda #%11111111	  		
										sta spritepr 		// sprite to background display priority

										lda #%00001111
										sta spriteexpy    	// sprites expand 2x vertical (y)
										lda #%00001111
										sta spriteexpx    	// sprites expand 2x horizontal (x)

										ldy #07
										lda #WHITE
				!:						sta spritecolors,y    // sprite 0 color
										dey
										bpl !-

										// set sprite memory pointers for main logo sprites
										ldx #($0c00/64)
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
										inx
										stx 2047


										// set sprite screen position for main logo

										ldy #78				// 78
										sty sprite0y	    // sprite 0 y pos
										sty sprite1y	    // sprite 1 y pos
										sty sprite2y	    // sprite 2 y pos
										sty sprite3y	    // sprite 2 y pos

										lda #108
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

										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------





//------------------------------------------------------------------------------------------------------------------------------------------------------------

*=$2000
.import binary "gfx\style_final_1_light_grey.art"
