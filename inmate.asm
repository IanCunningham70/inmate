//------------------------------------------------------------------------------------------------------------------------------------------------------------
// International Ye-Ar Kung Fu version 1.0
// 
// idea and gfx : shaun pearson
// code : ian cunningham
// music : ben daglish
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
// things left to do:
//
// make main logo fade off.
// 1. yellow fades to red (chars)
// 2. logo and sprites fade form RED to BLACK
//------------------------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------------------------
										#import "..\library\standardlibrary.asm"			
										.plugin "se.booze.kickass.CruncherPlugins"

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
.var music = LoadSid("sids\Yie_Ar_Kung_Fu.sid")
.pc = music.location "Music"
.fill music.size, music.getData(i)
//------------------------------------------------------------------------------------------------------------------------------------------------------------

										* = $0801 "basic line"
BasicUpstart2(start)

// this is where the code stuff starts ... hopefully it will work

										*= $1000 "Main Code"
start:		
										SetBoth(BLACK)
									
										lda #00
										sta colorNumber
										sta PackedImage
										sta $d41f
										sta VerticleLineCounter

										jsr WipeColumnReset

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
										ldx #<IrqTitle
										ldy #>IrqTitle
										stx $fffe						
										sty $ffff
										cli

										jsr DoTitleScreen				// display title screen & wipe

										lda #11							// select tune for the main displayer section
										jsr music.init

										sei
										lda #$00
										sta raster
										ldx #<IrqPlayMusic
										ldy #>IrqPlayMusic
										stx $fffe
										sty $ffff
										cli

PackedReset:							lda #$00
										sta PackedImage
										jsr depackImage
			
// the following code will wait for a while and then advance onto the next image when all images have been displayed,  
// it starts again at the first one. the current delay is 3.21 seconds.
										
keyscan2:

										jsr pauseLoop
										jsr pauseLoop
										jsr pauseLoop
										jsr pauseLoop
										jsr pauseLoop
										jsr pauseLoop						
										jsr pauseLoop
										jsr pauseLoop
										jsr pauseLoop
										jsr pauseLoop
										jsr pauseLoop

										lda PackedImage						// check how many images have been depacked, and reloop if needed
										cmp #04								// number of images -1
										beq PackedReset
										inc PackedImage
										jsr depackImage

										jmp keyscan2
//------------------------------------------------------------------------------------------------------------------------------------------------------------
// main depack picture look, images depack to $2000

										.memblock "depack image"
depackImage:			
										lda #$7b
										sta ScreenToggle
										lda #$00					// reset background colour to black
										sta ScreenColor + 1			

										lda #$ad							// stop bitmap plotter from running
										sta PlotBitmap
										lda #$00
										sta VerticleLineCounter

										ldx PackedImage				// image number counter
                        				ldy Packed_Lo,x				// lo byte
                        				lda Packed_Hi,x 			// hi byte
                        				tax
										jsr Decruncher

										jsr BlackenBitmap
										lda #$3b
										sta ScreenToggle
										lda #$20
										sta PlotBitmap
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.memblock "blacken koala"
BlackenBitmap:							ldx #00
										txa
							!:
										sta ScreenMemory,x
										sta ScreenMemory + (255 * 1),x
										sta ScreenMemory + (255 * 2),x
										sta ScreenMemory + (255 * 3),x
										sta ColourMemory,x
										sta ColourMemory + (255 * 1),x
										sta ColourMemory + (255 * 2),x
										sta ColourMemory + (255 * 3),x
										dex
										bne !-
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.memblock "Plot Bitmap 2 Screen - vertical"
PlotBitmap2Screen:						lda BitmapPlotDelay
										sec
										sbc #$05								// hardcode cycle speed
										and #$07
										sta BitmapPlotDelay
										bcc StartVerticle1
										rts
StartVerticle1:							ldx VerticleLineCounter
										cpx #40
										beq BitmapPlotterExit
										jsr DoVerticlePlot
										rts
BitmapPlotterExit:						
										lda #$ad
										sta PlotBitmap
										lda BackGroundColour  	 		// Background bitmap colour.
										sta ScreenColor + 1
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
DoVerticlePlot:							ldx VerticleLineCounter
										lda BitmapScreen + (40 * 0),x
										sta ScreenMemory + (40 * 0),x
										lda BitmapColours + (40 * 0),x
										sta ColourMemory + (40 * 0),x

										lda BitmapScreen + (40 * 1),x
										sta ScreenMemory + (40 * 1),x
										lda BitmapColours + (40 * 1),x
										sta ColourMemory + (40 * 1),x

										lda BitmapScreen + (40 * 2),x
										sta ScreenMemory + (40 * 2),x
										lda BitmapColours + (40 * 2),x
										sta ColourMemory + (40 * 2),x

										lda BitmapScreen + (40 * 3),x
										sta ScreenMemory + (40 * 3),x
										lda BitmapColours + (40 * 3),x
										sta ColourMemory + (40 * 3),x

										lda BitmapScreen + (40 * 4),x
										sta ScreenMemory + (40 * 4),x
										lda BitmapColours + (40 * 4),x
										sta ColourMemory + (40 * 4),x

										lda BitmapScreen + (40 * 5),x
										sta ScreenMemory + (40 * 5),x
										lda BitmapColours + (40 * 5),x
										sta ColourMemory + (40 * 5),x

										lda BitmapScreen + (40 * 6),x
										sta ScreenMemory + (40 * 6),x
										lda BitmapColours + (40 * 6),x
										sta ColourMemory + (40 * 6),x

										lda BitmapScreen + (40 * 7),x
										sta ScreenMemory + (40 * 7),x
										lda BitmapColours + (40 * 7),x
										sta ColourMemory + (40 * 7),x

										lda BitmapScreen + (40 * 8),x
										sta ScreenMemory + (40 * 8),x
										lda BitmapColours + (40 * 8),x
										sta ColourMemory + (40 * 8),x

										lda BitmapScreen + (40 * 9),x
										sta ScreenMemory + (40 * 9),x
										lda BitmapColours + (40 * 9),x
										sta ColourMemory + (40 * 9),x

										lda BitmapScreen + (40 * 10),x
										sta ScreenMemory + (40 * 10),x
										lda BitmapColours + (40 * 10),x
										sta ColourMemory + (40 * 10),x

										lda BitmapScreen + (40 * 11),x
										sta ScreenMemory + (40 * 11),x
										lda BitmapColours + (40 * 11),x
										sta ColourMemory + (40 * 11),x

										lda BitmapScreen + (40 * 12),x
										sta ScreenMemory + (40 * 12),x
										lda BitmapColours + (40 * 12),x
										sta ColourMemory + (40 * 12),x

										lda BitmapScreen + (40 * 13),x
										sta ScreenMemory + (40 * 13),x
										lda BitmapColours + (40 * 13),x
										sta ColourMemory + (40 * 13),x

										lda BitmapScreen + (40 * 14),x
										sta ScreenMemory + (40 * 14),x
										lda BitmapColours + (40 * 14),x
										sta ColourMemory + (40 * 14),x

										lda BitmapScreen + (40 * 15),x
										sta ScreenMemory + (40 * 15),x
										lda BitmapColours + (40 * 15),x
										sta ColourMemory + (40 * 15),x

										lda BitmapScreen + (40 * 16),x
										sta ScreenMemory + (40 * 16),x
										lda BitmapColours + (40 * 16),x
										sta ColourMemory + (40 * 16),x

										lda BitmapScreen + (40 * 17),x
										sta ScreenMemory + (40 * 17),x
										lda BitmapColours + (40 * 17),x
										sta ColourMemory + (40 * 17),x

										lda BitmapScreen + (40 * 18),x
										sta ScreenMemory + (40 * 18),x
										lda BitmapColours + (40 * 18),x
										sta ColourMemory + (40 * 18),x

										lda BitmapScreen + (40 * 19),x
										sta ScreenMemory + (40 * 19),x
										lda BitmapColours + (40 * 19),x
										sta ColourMemory + (40 * 19),x

										lda BitmapScreen + (40 * 20),x
										sta ScreenMemory + (40 * 20),x
										lda BitmapColours + (40 * 20),x
										sta ColourMemory + (40 * 20),x

										lda BitmapScreen + (40 * 21),x
										sta ScreenMemory + (40 * 21),x
										lda BitmapColours + (40 * 21),x
										sta ColourMemory + (40 * 21),x

										lda BitmapScreen + (40 * 22),x
										sta ScreenMemory + (40 * 22),x
										lda BitmapColours + (40 * 22),x
										sta ColourMemory + (40 * 22),x

										lda BitmapScreen + (40 * 23),x
										sta ScreenMemory + (40 * 23),x
										lda BitmapColours + (40 * 23),x
										sta ColourMemory + (40 * 23),x

										lda BitmapScreen + (40 * 24),x
										sta ScreenMemory + (40 * 24),x
										lda BitmapColours + (40 * 24),x
										sta ColourMemory + (40 * 24),x

										inc VerticleLineCounter
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
pauseLoop:              				ldx #255
			            				ldy #255
                !:      				dey
                        				bne !-
                        				dex
                        				bne pauseLoop+2
                        				rts						 
//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.memblock "Title Screen"
IrqTitle:								sta IrqTitleAback + 1
										stx IrqTitleXback + 1
										sty IrqTitleYback + 1

										jsr spaceFlash

          								lda #$e0
										sta raster
										ldx #<IrqTitle
										ldy #>IrqTitle
										stx $fffe
										sty $ffff
										inc irqflag
IrqTitleAback:					        lda #$ff
IrqTitleXback:				         	ldx #$ff
IrqTitleYback:				        	ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.memblock "Flash Space Text"
										
// flash line of text black and white using a table

spaceFlash:								ldx colorNumber
										cpx #96
										bne spaceFlash2
										lda #00
										sta colorNumber
spaceFlash2:							inc colorNumber
										ldx colorNumber
										lda colorTable,x
										ldy #00
spaceFlash3:							sta textFlash,y		
										iny		
										cpy #40		
										bne spaceFlash3		
										rts

//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.memblock "Music BITMAP settings"
IrqTitleWipe:							sta IrqTitleWipeAback + 1
										stx IrqTitleWipeXback + 1
										sty IrqTitleWipeYback + 1

										jsr music.play

										jsr wipeColumn

          								lda #$e0
										sta raster
										ldx #<IrqTitleWipe
										ldy #>IrqTitleWipe
										stx $fffe
										sty $ffff
										inc irqflag
IrqTitleWipeAback:					    lda #$ff
IrqTitleWipeXback:				      	ldx #$ff
IrqTitleWipeYback:				       	ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
// wipe the screen from right to left 1 column at a time
//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.memblock "title screen wipe"
wipeColumn:								
										lda wipeDelay
										sec
										sbc #$03
										and #$07
										sta wipeDelay
										bcc !+
										rts

				!:						ldx column
										cpx #00
										beq WipeColumnReset
										dex
										lda #$00
										sta $d800,x
										sta $d800+(40*1),x
										sta $d800+(40*2),x
										sta $d800+(40*3),x
										sta $d800+(40*10),x
										sta $d800+(40*11),x
										sta $d800+(40*12),x
										sta $d800+(40*13),x
										sta $d800+(40*14),x
										sta $d800+(40*15),x
										sta $d800+(40*16),x
										sta $d800+(40*17),x
										sta $d800+(40*18),x
										sta $d800+(40*19),x
										sta $d800+(40*20),x
										sta $d800+(40*21),x
										sta $d800+(40*22),x
										sta $d800+(40*23),x
										sta $d800+(40*24),x
										dec column
										rts
WipeColumnReset:						lda #40
										sta column	
										rts			

//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.memblock "Play Music"
IrqPlayMusic:							sta IrqPlayMusicAback + 1
										stx IrqPlayMusicXback + 1
										sty IrqPlayMusicYback + 1

										jsr music.play		// play selected tune

          								lda #$34
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

										lda ScreenToggle
										sta screenmode					

										lda #216						// stop smooth scrolling and change to bitmap mode
										sta smoothpos
										lda #%00011000					// point to bitmap data $2000, screen at $0400
										sta charset

PlotBitmap:								jsr PlotBitmap2Screen

ScreenColor:							lda #BLACK						// this will be completed when the picture is drawn. 
										sta screen

										lda #$00
										sta raster
										ldx #<IrqPlayMusic
										ldy #>IrqPlayMusic
										stx $fffe
										sty $ffff
										inc irqflag
IrqShowBitmapAback:					    lda #$ff
IrqShowBitmapXback:				      	ldx #$ff
IrqShowBitmapYback:				       	ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
DoTitleScreen:

										jsr WriteTitleScreen
										jsr setSprites
keyscan:
										lda $dc01
										cmp #$ef
										bne keyscan
				
										lda #10								// select tune
										tay
										tax
										jsr music.init
												
										sei
										lda #$e0
										sta raster
										ldx #<IrqTitleWipe
										ldy #>IrqTitleWipe
										stx $fffe
										sty $ffff
										cli
wait:
										lda column
										bne wait

										jsr pauseLoop
										jsr pauseLoop
										jsr pauseLoop
										jsr pauseLoop
										jsr pauseLoop

										// turn off the sprites
										lda #%00000000
										sta spriteset  		// sprite display enable
										sta spritepr 		// sprite to background display priority

										jsr pauseLoop
										jsr pauseLoop
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
// write intro text to screen			
//------------------------------------------------------------------------------------------------------------------------------------------------------------
WriteTitleScreen:						ldx #$00
				!:						lda title_screen,x		
										sta $0400,x		
										lda title_screen+($ff*1),x		
										sta $0400+($ff*1),x		
										lda title_screen+($ff*2),x		
										sta $0400+($ff*2),x	
										lda title_screen+($ff*3),x		
										sta $0400+($ff*3),x		
										// make all screen white	
										lda #WHITE		
										sta $d800,x		
										sta $d900,x		
										sta $da00,x		
										sta $db00,x		
										inx
										bne !-

										ldx #$00
										lda #YELLOW								// color logo outline YELLOW
			  				!:			sta $d800+(40*4),x
										inx 
										cpx #160
										bne !-
										rts	
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
										lda #RED
				!:						sta spritecolors,y    // sprite 0 color
										dey
										bpl !-

										// set sprite memory pointers for main logo sprites
										ldx #spr_img1/64
										stx 2040
										inx
										stx 2041
										inx
										stx 2042
										inx
										stx 2043
										inx
										stx 2044

										// additional sprites to complete the logo, 1 pixel and 3 pixels.
										lda #spr_img0/64
										sta 2045
										lda #spr_img6/64
										sta 2046

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

										// the dash - not expanded
										ldy #88
										sty sprite4y
										lda #104+48+48+12+1
										sta sprite4x

										// 3 pixels
										ldy #88
										sty sprite5y
										ldx #112
										stx sprite5x

										// 1 pixel
										ldy #88
										sty sprite6y
										ldx #104+48+48+48
										stx sprite6x					
										rts
//------------------------------------------------------------------------------------------------------------------------------------------------------------
                    				    .align $100
										.memblock "Tables"

BitmapPlotDelay:						.byte $00
VerticleLineCounter:					.byte $00

wipeDelay:								.byte $00

ScreenToggle:							.byte $00				// control $d011 screen mode

PackedImage:							.byte $00				// which tune to depack ?

Packed_Hi:								.byte >packedImage01, >packedImage02, >packedImage03, >packedImage04
										.byte >packedImage05
										.byte $ff

Packed_Lo:								.byte <packedImage01, <packedImage02, <packedImage03, <packedImage04
										.byte <packedImage05
										.byte $ff

column:									.byte 40,$00		// column number

colorNumber:							.byte $00


colorTable:								.byte $00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00
										.byte $01,$01,$01,$01,$01,$01,$01,$01
										.byte $00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00
										.byte $01,$01,$01,$01,$01,$01,$01,$01
										.byte $00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00
										.byte $01,$01,$01,$01,$01,$01,$01,$01
										.byte $00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00
										.byte $01,$01,$01,$01,$01,$01,$01,$01
										.byte $00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00
//------------------------------------------------------------------------------------------------------------------------------------------------------------

Decruncher:				
										#import "B2_Decruncher.asm"

//------------------------------------------------------------------------------------------------------------------------------------------------------------
										*= $0e00 "title sprites"
spr_img0:

.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$00,$00,$00,$00,$02
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05

spr_img1:

.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$88,$00,$30,$cb,$00,$70,$db
.byte $00,$70,$d8,$00,$f0,$d8,$20,$d2,$f0,$70,$93,$72,$d1,$b3,$76,$93
.byte $f3,$66,$91,$f3,$64,$a1,$f6,$64,$83,$f6,$cc,$83,$26,$cc,$e3,$64
.byte $88,$e1,$64,$00,$40,$20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05

spr_img2:

.byte $00,$00,$00,$00,$00,$00,$04,$00,$00,$06,$92,$68,$06,$b2,$6c,$04
.byte $b6,$6d,$0d,$b6,$6d,$0d,$b6,$69,$8f,$36,$79,$8f,$26,$fb,$8e,$66
.byte $fb,$0e,$6c,$bb,$1e,$6c,$b3,$1a,$6c,$b3,$1b,$7d,$b3,$13,$79,$b3
.byte $13,$38,$91,$01,$30,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05

spr_img3:

.byte $00,$00,$00,$00,$00,$00,$60,$00,$18,$f0,$00,$3d,$f0,$00,$3d,$b0
.byte $00,$39,$a0,$00,$31,$80,$00,$33,$20,$00,$23,$70,$00,$73,$70,$00
.byte $7b,$20,$00,$72,$60,$00,$62,$60,$00,$62,$c0,$00,$c3,$c0,$00,$c3
.byte $80,$00,$43,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05

spr_img4:

.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$a0,$00,$00,$b0,$00,$00,$b0
.byte $00,$00,$30,$00,$00,$30,$00,$00,$70,$00,$00,$60,$00,$00,$60,$00
.byte $00,$60,$00,$00,$40,$00,$00,$c0,$00,$00,$c0,$00,$00,$c0,$00,$00
.byte $80,$00,$00,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05

spr_img5:

.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $f0,$0c,$01,$f8,$38,$03,$fc,$78,$07,$ff,$f0,$0f,$ff,$e0,$1f,$ff
.byte $e0,$39,$ff,$c0,$70,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05

spr_img6:

.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05
//------------------------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------------------------
										*= $1c00 "title screen"
title_screen:			
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03
										.byte $04,$05,$02,$06,$03,$01,$07,$02,$06,$08,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$09,$0a,$0b,$00,$0c,$0d
										.byte $00,$0e,$0f,$10,$11,$12,$13,$14,$00,$00,$15,$16,$17,$18,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$19,$1a,$1b,$1c,$1d,$1e,$1f,$20,$21,$22,$23,$24,$25,$26
										.byte $27,$28,$29,$2a,$2b,$2c,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$2d,$2e,$2f,$30,$31,$32
										.byte $33,$34,$35,$36,$37,$38,$39,$3a,$3b,$3c,$3d,$3e,$3f,$40,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e
										.byte $00,$00,$4f,$50,$51,$4e,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$52,$05,$04,$53,$53
										.byte $00,$53,$52,$06,$54,$04,$00,$55,$56,$03,$03,$07,$02,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$52,$05,$07,$57,$05,$06,$58,$58,$01,$02,$57,$00,$01
										.byte $59,$54,$56,$02,$02,$01,$02,$57,$5a,$06,$58,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$07,$54
										.byte $06,$03,$01,$07,$02,$00,$57,$05,$06,$52,$5a,$01,$54,$53,$00,$53
										.byte $59,$52,$04,$06,$05,$53,$07,$02,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$53,$07,$56,$02,$5b,$00,$58
										.byte $59,$57,$06,$08,$5c,$06,$5d,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$07,$57,$07,$00,$5e
										.byte $07,$02,$06,$58,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
										.byte $00,$00,$00,$00,$00,$00,$00,$00
//------------------------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------------------------
										*= $2000
TitleFont:								.memblock "Title Charset"
										.byte $00,$00,$00,$00,$00,$00,$00,$00,$3f,$0c,$0c,$0c,$0c,$0c,$3f,$00
										.byte $63,$73,$7b,$7f,$6f,$67,$63,$00,$3f,$0c,$0c,$0c,$0c,$0c,$0c,$00
										.byte $3f,$30,$30,$3e,$30,$30,$3f,$00,$7e,$63,$63,$67,$7c,$6e,$67,$00
										.byte $1c,$36,$63,$63,$7f,$63,$63,$00,$3e,$63,$63,$63,$63,$63,$3e,$00
										.byte $30,$30,$30,$30,$30,$30,$3f,$00,$04,$04,$0a,$0a,$09,$09,$09,$09
										.byte $0c,$0c,$12,$12,$12,$12,$22,$22,$00,$00,$60,$60,$90,$90,$90,$90
										.byte $00,$00,$01,$01,$02,$02,$04,$04,$c0,$c0,$30,$10,$08,$08,$08,$08
										.byte $03,$02,$04,$04,$04,$04,$04,$04,$8c,$8c,$4a,$4a,$52,$52,$92,$92
										.byte $31,$31,$49,$49,$89,$89,$8a,$8a,$81,$81,$42,$42,$22,$22,$22,$22
										.byte $84,$84,$4a,$4a,$49,$49,$49,$49,$03,$02,$0c,$08,$10,$11,$22,$22
										.byte $e0,$20,$10,$10,$10,$10,$90,$90,$00,$00,$01,$01,$01,$01,$00,$00
										.byte $7e,$42,$81,$01,$01,$01,$82,$8e,$18,$18,$24,$24,$44,$44,$45,$45
										.byte $c0,$c0,$a0,$a0,$90,$90,$10,$10,$09,$09,$09,$09,$08,$08,$04,$04
										.byte $24,$24,$44,$44,$89,$09,$11,$11,$60,$00,$01,$01,$86,$84,$48,$49
										.byte $00,$00,$e0,$20,$10,$10,$90,$50,$08,$08,$09,$09,$12,$12,$22,$22
										.byte $08,$88,$48,$48,$48,$48,$88,$88,$00,$00,$ec,$ac,$92,$82,$82,$82
										.byte $08,$08,$09,$09,$08,$08,$10,$10,$a4,$a4,$45,$45,$89,$09,$11,$11
										.byte $92,$92,$12,$12,$14,$14,$24,$24,$24,$24,$24,$24,$24,$24,$48,$48
										.byte $51,$51,$52,$52,$22,$02,$04,$04,$24,$24,$44,$44,$48,$48,$8b,$8a
										.byte $a0,$e0,$00,$00,$e0,$a0,$10,$10,$00,$00,$07,$08,$10,$20,$40,$80
										.byte $00,$00,$80,$41,$22,$1c,$00,$00,$00,$00,$79,$99,$21,$21,$46,$84
										.byte $90,$90,$10,$10,$20,$20,$18,$08,$49,$49,$89,$89,$8a,$8a,$92,$92
										.byte $10,$10,$10,$10,$10,$10,$20,$20,$04,$04,$02,$02,$02,$02,$04,$04
										.byte $12,$12,$22,$22,$44,$44,$44,$44,$49,$4a,$52,$52,$92,$93,$94,$94
										.byte $50,$50,$50,$90,$a0,$20,$c0,$c0,$c1,$80,$40,$40,$40,$40,$80,$86
										.byte $09,$09,$11,$11,$12,$12,$14,$14,$04,$0c,$10,$10,$20,$20,$40,$40
										.byte $10,$10,$10,$10,$20,$22,$25,$25,$22,$22,$42,$42,$22,$22,$22,$22
										.byte $24,$24,$48,$48,$48,$48,$51,$51,$50,$51,$92,$92,$92,$92,$12,$12
										.byte $04,$04,$84,$84,$88,$88,$88,$88,$8a,$8a,$91,$91,$92,$92,$94,$94
										.byte $11,$12,$24,$27,$20,$20,$40,$40,$00,$30,$48,$87,$00,$00,$00,$00
										.byte $00,$01,$06,$f8,$00,$00,$00,$00,$82,$02,$02,$02,$04,$04,$04,$04
										.byte $05,$05,$09,$39,$41,$41,$41,$41,$12,$12,$24,$24,$24,$24,$28,$28
										.byte $20,$20,$40,$40,$40,$80,$80,$80,$08,$08,$11,$11,$12,$12,$0c,$0c
										.byte $89,$89,$09,$09,$0a,$0a,$06,$06,$12,$12,$11,$10,$08,$08,$04,$07
										.byte $00,$00,$c0,$40,$40,$40,$80,$80,$89,$89,$8a,$9a,$52,$52,$31,$31
										.byte $24,$24,$24,$24,$44,$44,$43,$c3,$40,$40,$80,$80,$80,$80,$00,$00
										.byte $45,$45,$48,$48,$48,$48,$30,$30,$12,$12,$8a,$8a,$89,$89,$50,$70
										.byte $21,$01,$02,$02,$04,$04,$88,$f8,$22,$22,$24,$24,$14,$14,$0c,$0c
										.byte $88,$88,$90,$90,$50,$50,$30,$30,$88,$80,$81,$81,$42,$46,$28,$38
										.byte $80,$80,$00,$00,$00,$00,$00,$00,$08,$08,$08,$08,$04,$04,$03,$03
										.byte $81,$81,$81,$81,$80,$80,$00,$00,$10,$00,$01,$01,$82,$82,$44,$7c
										.byte $7e,$63,$63,$63,$7e,$60,$60,$00,$3c,$66,$60,$3e,$03,$63,$3e,$00
										.byte $1e,$33,$60,$60,$60,$33,$1e,$00,$7e,$63,$63,$7e,$63,$63,$7e,$00
										.byte $63,$63,$63,$63,$63,$63,$3e,$00,$1f,$30,$60,$6f,$63,$33,$1f,$00
										.byte $63,$77,$7f,$7f,$6b,$63,$63,$00,$00,$00,$00,$18,$18,$00,$00,$00
										.byte $63,$63,$63,$7f,$63,$63,$63,$00,$7c,$66,$63,$63,$63,$66,$7c,$00
										.byte $63,$63,$6b,$7f,$7f,$77,$63,$00,$33,$33,$33,$1e,$0c,$0c,$0c,$00
										.byte $63,$66,$6c,$78,$7c,$6e,$67,$00
//------------------------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------------------------
// this is where the bitmaps are loaded and packed into memory.  use the .align to seperate them.
//------------------------------------------------------------------------------------------------------------------------------------------------------------

										.pc = $6000 "gfx\koala backdrop 1.prg"
packedImage01:                                        
										.modify B2() {
											.var image01 = LoadBinary ("gfx\koala backdrop 1.kla", BF_KOALA)
											.fill image01.getSize(), image01.get(i)
										}

										.pc = $a000 "gfx\koala picture 2.prg"
packedImage02:                                        
										.modify B2() {
											.var image02 = LoadBinary ("gfx\koala backdrop 2.kla", BF_KOALA)
											.fill image02.getSize(), image02.get(i)
										}

										.pc = * "gfx\koala picture 3.prg"
packedImage03:                                        
										.modify B2() {
											.var image03 = LoadBinary ("gfx\koala backdrop 3.kla", BF_KOALA)
											.fill image03.getSize(), image03.get(i)
										}

										.pc = * "gfx\koala picture 4.prg"
packedImage04:                                        
										.modify B2() {
											.var image04 = LoadBinary ("gfx\koala backdrop 4.kla", BF_KOALA)
											.fill image04.getSize(), image04.get(i)
										}
										.pc = $e000 "gfx\koala picture 5.prg"
packedImage05:                                        
										.modify B2() {
											.var image05 = LoadBinary ("gfx\koala backdrop 5.kla", BF_KOALA)
											.fill image05.getSize(), image05.get(i)
										}
//------------------------------------------------------------------------------------------------------------------------------------------------------------
