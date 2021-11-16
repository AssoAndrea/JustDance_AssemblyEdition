.org $8000  ;inizio del programma


;variabili nella pagina 0
;1 per freccia su, 8 destra, 4 sinistra, 2 giù
init:

    .define su $01
    .define destra $08
    .define sinistra $04
    .define giu $02
    .define red $01
    .define blue $04
    .define green $02

    .define a_counter $01 
    .define a_arrow_color $02
    .define a_line_counter $03
    .define a_linePixel $04
    .define a_Xs $05
    .define a_Ys $06

    .define a_compare $07
    ;lista di frecce da premere in combo
    .define a_comb1 $08
    .define a_comb2 $09
    .define a_comb3 $0A
    .define a_comb4 $0B
    .define a_actualCombo $0C
    .define a_nextArrow $0D
    .define a_errorSaved $0E


    ;pagina 7 per la lista di combo
    
    LDA #$00
    STA a_actualCombo
    LDA #$08
    STA a_nextArrow

    LDX #$FF
    TXS
    LDA #red
    STA a_arrow_color           ;setto il colore per le frecce
    JSR load_ComboList          ;carico la ram con la combo
    JSR load_NextCombo          ;carico la prima combo nelle celle da controllare
    JSR GameLoop


stop:
    ;BRK
    JSR stop

restart:
    JMP init




load_NextCombo:  ;parte da 08 fino a 0B
    LDX a_actualCombo
    LDA $0700,X
    STA a_comb1
    INX
    LDA $0700,X
    STA a_comb2
    INX
    LDA $0700,X
    STA a_comb3
    INX
    LDA $0700,X
    STA a_comb4
    STX a_actualCombo
    RTS

load_ComboList:
    ;combo 1
    LDA #su
    STA $0700
    LDA #sinistra
    STA $0701
    LDA #giu
    STA $0702
    LDA #destra
    STA $0703

    ;combo 2
    LDA #sinistra
    STA $0704
    LDA #su
    STA $0705
    LDA #giu
    STA $0706
    LDA #destra
    STA $0707

    ;combo 3
    LDA #giu
    STA $0708
    LDA #su
    STA $0709
    LDA #giu
    STA $070A
    LDA #sinistra
    STA $070B

    RTS
        

ClearRam_2:
    LDX #$00
    ClearLoop:
        LDA #$00
        STA $0200,X
        INX
        CPX #$FF
        BNE ClearLoop
        STA $02FF
    RTS

GameLoop:
    
    nextLoop:
    JSR drawCombo
    JSR playerInput_loop

    RTS

playerInput_loop:
    LDX #00
    waitForInput1:
        LDA $4000
        BEQ waitForInput1
    check_comb1:
        TAY
        CMP a_comb1
        BNE playerError
        LDA #green
        STA a_arrow_color
        LDX a_comb1
        JSR switch_arrowToDraw


    waitForInput2:
        LDA $4000
        BEQ waitForInput2
    check_comb2:
        TAY
        CMP a_comb2
        BNE playerError
        LDA #green
        STA a_arrow_color
        LDX a_comb2
        JSR switch_arrowToDraw


    waitForInput3:
        LDA $4000
        BEQ waitForInput3
    check_comb3:
        TAY
        CMP a_comb3
        BNE playerError
        LDA #green
        STA a_arrow_color
        LDX a_comb3
        JSR switch_arrowToDraw


    waitForInput4:
        LDA $4000
        BEQ waitForInput4
    check_comb4:
        TAY
        CMP a_comb4
        BNE playerError
        LDA #green
        STA a_arrow_color
        LDX a_comb4
        JSR switch_arrowToDraw

    JSR ClearRam_2
    JSR wait
    JSR load_NextCombo
    JMP nextLoop


playerError:
    TYA
    TAX
    LDA #red
    STA a_arrow_color
    JSR switch_arrowToDraw
    JSR wait
    JMP nextLoop
        


drawCombo:
    LDA #blue
    STA a_arrow_color
    LDX a_comb1
    JSR switch_arrowToDraw
    JSR wait
    LDX a_comb2
    JSR switch_arrowToDraw
    JSR wait
    LDX a_comb3
    JSR switch_arrowToDraw
    JSR wait
    LDX a_comb4
    JSR switch_arrowToDraw
    JSR wait
    RTS

switch_arrowToDraw:
    CPX #su
    BEQ JumpToLoadArrow_1
    CPX #giu
    BEQ JumpToLoadArrow_2
    CPX #sinistra
    BEQ JumpToLoadArrow_4
    CPX #destra
    BEQ JumpToLoadArrow_8

    end_Switch:
    JSR wait
    JSR ClearRam_2
    RTS

JumpToLoadArrow_1:
    JSR load_arrow_1
    JMP end_Switch

JumpToLoadArrow_4:
    JSR load_arrow_4
    JMP end_Switch

JumpToLoadArrow_8:
    JSR load_arrow_8
    JMP end_Switch

JumpToLoadArrow_2:
    JSR load_arrow_2
    JMP end_Switch

wait:
    LDX #0
    LDY #0
    waitLoop_1:
        
        waitLoop_2:
            NOP
            NOP
            NOP
            DEY
            BNE waitLoop_2
        NOP
        NOP
        NOP
        DEX
        BNE waitLoop_1
    RTS

load_arrow_4:          ;togliere 11 e aggiungere F, 10 per riempire
    LDX #$70
    LDY #$80
    LDA a_arrow_color
    STA $0200,X
    STA $0200,Y
    loop_4:
        TXA
        SEC
        SBC #$0F
        CLC
        TAX
        TYA
        ADC #$11
        CLC
        TAY
        STX a_Xs        ;salvo X e Y
        STY a_Ys
        line_loop_4:
            LDA a_arrow_color
            STA $0200,X
            STA $0200,Y
            TXA
            ADC #$10
            CLC
            TAX
            STY a_compare
            CPX a_compare
            BNE line_loop_4
            LDX a_Xs
            LDY a_Ys
        CPX #$16
        BNE loop_4
        LDX #$77
        LDY #$87
        final_loop_4:
            LDA a_arrow_color
            STA $0200,X
            STA $0200,Y
            INX
            INY
            CPX #$7F
            BNE final_loop_4

        RTS

load_arrow_8:          ;togliere 11 e aggiungere F, 10 per riempire
    LDX #$7F
    LDY #$8F
    LDA a_arrow_color
    STA $0200,X
    STA $0200,Y
    loop_8:
        TXA
        SEC
        SBC #$11
        CLC
        TAX
        TYA
        ADC #$F
        CLC
        TAY
        STX a_Xs        ;salvo X e Y
        STY a_Ys
        line_loop_8:
            LDA a_arrow_color
            STA $0200,X
            STA $0200,Y
            TXA
            ADC #$10
            CLC
            TAX
            STY a_compare
            CPX a_compare
            BNE line_loop_8
            LDX a_Xs
            LDY a_Ys
        CPX #$19
        BNE loop_8
        LDX #$79
        LDY #$89
        final_loop_8:
            LDA a_arrow_color
            STA $0200,X
            STA $0200,Y
            DEX
            DEY
            CPX #$70
            BNE final_loop_8

        RTS
            
load_arrow_2:          ;togliere 11 e aggiungere F, 10 per riempire
    LDX #$F7
    LDY #$F8
    LDA a_arrow_color
    STA $0200,X
    STA $0200,Y
    loop_2:
        TXA
        SEC
        SBC #$11
        CLC
        TAX
        TYA
        SEC
        SBC #$F
        CLC
        TAY
        STX a_Xs        ;salvo X e Y
        STY a_Ys
        line_loop_2:
            LDA a_arrow_color
            STA $0200,X
            STA $0200,Y
            TXA
            ADC #$01
            CLC
            TAX
            STY a_compare
            CPX a_compare
            BNE line_loop_2
            LDX a_Xs
            LDY a_Ys
        CPY #$9E
        BNE loop_2
        LDX #$97
        LDY #$98
        final_loop_2:
            LDA a_arrow_color
            STA $0200,X
            STA $0200,Y
            TXA
            SEC
            SBC #$10
            CLC
            TAX
            TYA
            SEC
            SBC #$10
            CLC
            TAY
            CPX #$07
            BNE final_loop_2

        RTS


load_arrow_1:
    LDA #0         ;setto il timer da 0 per arrivare a 7
    STA a_counter
    LDX #$07
    LDY #$08
    LDA a_arrow_color
    STA $0200,X
    STA $0200,Y
    loop_1:
        TXA
        CLC
        ADC #$0F    ;aggiungere F per X, 11 per Y
        TAX
        TYA
        ADC #$11
        TAY
        LDA a_arrow_color
        STA $0200,X
        STA $0200,Y
        STX a_Xs
        STY a_Ys

        line_loop_1:   ;disegno la linea
            INX
            STA $0200,X
            CPX a_Ys
            BNE line_loop_1
            LDX a_Xs
            LDY a_Ys


        CLC
        LDA a_counter
        ADC #1
        STA a_counter
        CMP #6
        
        BNE loop_1  ;branch on not equal
        LDX #$77
        LDY #$78
        LDA #0
        STA a_counter

        final_loop_1:
            LDA a_arrow_color
            STA $0200,X
            STA $0200,Y
            TXA
            CLC
            ADC #$10
            TAX
            TYA
            CLC 
            ADC #$10
            TAY
            CPX #$F7
            BNE final_loop_1
        RTS









copyloop:
    LDA $0400,X
    STA $0200,X
    DEX
    TXA
    AND $00
    BNE copyloop





nonmaskable:
JMP restart
RTI

interrupt:
LDX #$50
RTI

.goto $FFFA
.dw nonmaskable
.dw init
.dw interrupt