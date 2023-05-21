*=$0900 "Wipe Sprites"

WipeSprite0:

.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0f

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
