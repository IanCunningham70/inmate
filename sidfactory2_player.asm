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
										lda #21
										sta charset
										lda #200
										sta smoothpos
										
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
inmate:									jmp inmate
//------------------------------------------------------------------------------------------------------------------------------------------------------------
										.memblock "Play Music"
IrqPlayMusic:							sta IrqPlayMusicAback + 1
										stx IrqPlayMusicXback + 1
										sty IrqPlayMusicYback + 1

										jsr music.play					// play selected tune

										ldx #$00
								!:		lda $1700,x
										sta $0400,x
										inx
										bne !-





										lda #$00
										sta raster
										ldx #<IrqPlayMusic
										ldy #>IrqPlayMusic
										stx $fffe
										sty $ffff
										inc irqflag
IrqPlayMusicAback:					    lda #$ff
IrqPlayMusicXback:				      	ldx #$ff
IrqPlayMusicYback:				       	ldy #$ff
										rti
//------------------------------------------------------------------------------------------------------------------------------------------------------------
