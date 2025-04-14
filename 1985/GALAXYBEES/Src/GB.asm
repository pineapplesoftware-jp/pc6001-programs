;==============================================================================
; GALAXY BEES	9C00H - AFABH(13ACH)
;	Programmed by ComputerKidd 1985
;	Zaoriked by ComputerKidd 2025/03
;	PINEAPPLE SOFTWARE 1985,2025
;==============================================================================

; PC6001 ROM内のサブルーチン
P6_JOYIN	EQU		1061H		; ゲームキー入力(|SPACE| 0|←|→|↓|↑|STOP|SHIFT|)

; 
SCR_PAGE	EQU		0DEFEH		; (B)画面ページ
MOV			EQU		0DEFDH		; (B)エイリアン隊列の移動方向
COUNT		EQU		0DEFCH		; (B)エイリアン隊列の移動数
PTRN		EQU		0DEFBH		; (B)エイリアン隊列の足踏みをそろえるためのカウンタ
ATDTPO		EQU		0DEF9H		; (W)出撃パターン現在位置
ATCO		EQU		0DEF7H		; (W)攻撃カウンタ
FGTRX		EQU		0DEF6H		; (B)プレイヤーのX座標 ※Y座標はA4H
DETH		EQU		0DEF5H		; (B)プレイヤーの死亡フラグ（00h:死, FFh:１面クリア, 80h:ふつう）
SCORE		EQU		0DEF3H		; (W)スコア
POINT		EQU		0DEF2H		; (B)ポイント
WAITCO		EQU		0DEF1H		; (B)WAITINGカウンタ
SCDT		EQU		0DEEAH		; (B*7)スコア表示用バッファ
;HISC		EQU		0DEE8H		; (W)ハイスコア
ALNUM		EQU		0DEE7H		; (B)倒したエイリアンの数
BGMSTEP		EQU		0DEE6H		; (B)BGMのステップ数
ROUND		EQU		0DEE5H		; (B)ROUND数
FGTRNUM		EQU		0DEE4H		; (B)プレイヤー数
LOOP		EQU		0DEE3H		; (B)ループ数
;
STDT		EQU		0DE00H		; 星の情報（00h,01h=星の位置オフセット, 02h=速度(1-)）
FIRE		EQU		0DE50H		; 弾情報（00h=有無, 01h=X座標, 02h=Y座標）
MSINFO_TOP	EQU		0DE80H		; ミサイル情報テーブル先頭
ALDT		EQU		0DEFFH		; エイリアン情報テーブル先頭(80Hで終端)
									; +00h : WAIT
									; +01h : キャラクタ番号
									; +02h : X座標
									; +03h : Y座標
									; +04h : 攻撃移動アドレスL
									; +05h : 攻撃移動アドレスH
									; +06h : X座標
									; +07h : Y座標

		ORG		9C00H


		;--------
		; PATPRS : スプライトパターン出力
		; A		キャラクタ番号(0-)
		; B		X座標(0-)
		; C		Y座標(0-)
		;--------
PATPRS:
		LD		L,A				;
		LD		H,00H
		ADD		HL,HL			; x2
		ADD		HL,HL			; x4
		ADD		HL,HL			; x8
		ADD		HL,HL			; x16
		LD		D,H
		LD		E,L
		ADD		HL,HL			; x32
		ADD		HL,DE			; x48
		LD		DE,CH8X12DAT	; 9ED4H
		ADD		HL,DE
		EX		DE,HL			; DE = CH8X12DAT + [キャラクタ番号] * 30H
		LD		L,C
		LD		H,00H
		ADD		HL,HL			; x2
		ADD		HL,HL			; x4
		ADD		HL,HL			; x8
		ADD		HL,HL			; x16
		ADD		HL,HL			; x32
		LD		A,B
		ADD		A,L
		LD		L,A				; HL = VRAMアドレス
		LD		A,(SCR_PAGE)	; DEFEH
		RRCA
		RRCA
		RRCA
		ADD		A,C2H			; A = C2H or E2H
		ADD		A,H
		LD		H,A				; HL = VRAMアドレス
;
		LD		B,0CH			; B = 縦カウンタ
.j01
		PUSH	BC
		LD		A,(DE)
		AND		(HL)			; A = *VRAM & MASK
		INC		DE
		LD		B,A				; B = *VRAM & MASK
		LD		A,(DE)
		INC		DE
		OR		B
		LD		(HL),A			; *VRAM = (*VRAM & MASK)|PATTERN
		INC		HL
;
		LD		A,(DE)
		AND		(HL)			; A = *VRAM & MASK
		INC		DE
		LD		B,A				; B = *VRAM & MASK
		LD		A,(DE)
		INC		DE
		OR		B
		LD		(HL),A			; *VRAM = (*VRAM & MASK)|PATTERN
;
		LD		BC,001FH
		ADD		HL,BC
		NOP
		POP		BC
		DJNZ	.j01			; 縦カウンタの分だけ繰り返し
;
		RET
		NOP
		NOP


		;--------
		; 8X8PR : 8x8パターン出力
		;	B = 色
		;	C = キャラクタコード
		;	D = X
		;	E = Y
		;--------
PR8X8:
		PUSH	BC
		PUSH	DE
		PUSH	HL
		PUSH	AF
		LD		L,E
		LD		H,00H
		ADD		HL,HL			; x2
		ADD		HL,HL			; x4
		ADD		HL,HL			; x8
		ADD		HL,HL			; x16
		ADD		HL,HL			; x32
		LD		A,(SCR_PAGE)	; DEFEH
		RRCA					; /2 80h
		RRCA					; /4 40h
		RRCA					; /8 20h
		ADD		A,C2H
		ADD		A,H
		LD		H,A
		LD		A,D
		ADD		A,L
		LD		L,A
		EX		DE,HL			; DE = VRAMアドレス(VramTop + E*20H + D)
		LD		L,C
		LD		H,00H
		ADD		HL,HL			; *2
		ADD		HL,HL			; *4
		ADD		HL,HL			; *8
		LD		A,B
		LD		BC,DTTOP2		; 9D34H
		ADD		HL,BC			; HL = DTTOP2 + (C * 8)
		XOR		03H
		LD		C,A
		LD		B,08H			; B = 縦カウンタ
.j04
		PUSH	BC
		LD		A,(HL)
		ADD		A,(HL)
		INC		C
.j02
		DEC		C
		JR		Z,.j01
		SUB		(HL)
		JR		.j02
.j01
		LD		(DE),A			; *VRAM = データ
		INC		HL
		; DE += 20H
		LD		B,20H
.j03
		INC		DE
		DJNZ	.j03
		POP		BC
		DJNZ	.j04			; 縦カウンタの分だけ繰り返し
		POP		AF
		POP		HL
		POP		DE
		POP		BC
		RET
		NOP


		;--------
		; MSGPR : 文字列出力
		; (in)		HL	文字列
		;			C	文字色(0-)
		;			D	X座標(0-)
		;			E	Y座標(0-)
		;--------
MSGPR:
		PUSH	BC
		PUSH	AF
		LD		B,C
.j02
		LD		A,(HL)				; A = 文字コード
		CP		FFH					; 終端(FFh)か？
		JR		Z,.j01				; yes -> 終了
;
		LD		C,A
		CALL	PR8X8	; 9C44H		; １文字出力
		INC		HL
		INC		D					; X座標+1
		JR		.j02
.j01
		POP		AF
		POP		BC
		RET


		;--------
		; ALPO : エイリアン設定ルーチン
		; ALPODTの内容をALDTに展開する
		;--------
ALPO:
		LD		HL,ALDT			; HL = エイリアン情報テーブル先頭(DEFFH)
		LD		DE,ALPODT		; DE = エイリアン隊列位置データ(9CD4H)
;
		LD		BC,1000H		; B = WHITEのエイリアン数, C = WHITEのキャラクタ番号
		CALL	ALPO_SUB		; 9CB6H
		LD		BC,0802H		; B = REDのエイリアン数, C = REDのキャラクタ番号
		CALL	ALPO_SUB		; 9CB6H
		LD		BC,0604H		; B = BLUEのエイリアン数, C = BLUEのキャラクタ番号
		CALL	ALPO_SUB		; 9CB6H
		LD		BC,0206H		; B = BLACKのエイリアン数, C = BLACKのキャラクタ番号
ALPO_SUB:
.j01
		LD		(HL),02H		; *(p+0) = WAIT
		INC		HL
		LD		(HL),C			; *(p+1) = キャラクタ番号
		LD		A,C
		XOR		01H
		LD		C,A
		INC		HL
		LD		A,(DE)
		INC		DE
		LD		(HL),A			; *(p+2) = X座標
		INC		HL
		LD		A,(DE)
		DEC		DE
		LD		(HL),A			; *(p+3) = Y座標
		INC		HL
		INC		HL
		INC		HL
		LD		A,(DE)
		INC		DE
		LD		(HL),A			; *(p+6) = X座標
		INC		HL
		LD		A,(DE)
		INC		DE
		LD		(HL),A			; *(p+7) = Y座標
		INC		HL
		DJNZ	.j01
		RET


		;--------
		; ALPODT : エイリアン隊列位置データ
		;	00H : X座標
		;	01H : Y座標
		;--------
ALPODT:
		DB		02H,5CH,05H,5CH,08H,5CH,0BH,5CH,0EH,5CH,11H,5CH,14H,5CH,17H,5CH		; ５段目：WHITE
		DB		02H,4EH,05H,4EH,08H,4EH,0BH,4EH,0EH,4EH,11H,4EH,14H,4EH,17H,4EH		; ４段目：WHITE
		DB		02H,40H,05H,40H,08H,40H,0BH,40H,0EH,40H,11H,40H,14H,40H,17H,40H		; ３段目：RED
		DB		05H,32H,08H,32H,0BH,32H,0EH,32H,11H,32H,14H,32H						; ２段目：BLUE
		DB		08H,24H,11H,24H														; １段目：BLACK


		;--------
		; ALPR : エイリアンテーブル上のエイリアンを描画する
		;--------
ALPR:
		LD		HL,ALDT			; HL = エイリアン情報テーブル先頭(DEFFH)
.j01
		LD		A,(HL)
		CP		80H			; 終端(80h)か？
		RET		Z			; yes -> 終了
		INC		HL
		LD		D,(HL)		; D = スプライトパターン番号
		INC		HL
		LD		B,(HL)		; B = X座標
		INC		HL
		LD		C,(HL)		; C = Y座標
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		OR		A			; 存在している？
		JR		Z,.j01		; no -> 存在しないなら次へ
		LD		A,D
		PUSH	HL
		CALL	PATPRS		; 9C00H PATPRSスプライト表示
		POP		HL
		JR		.j01
		NOP
		NOP
		NOP


		;--------
		; DTTOP2 : 8X8PR用データ（文字データ）
		;--------
DTTOP2:
		DB		00H,00H,00H,00H,00H,00H,00H,00H		; 00h ' '
		DB		00H,10H,44H,44H,54H,44H,44H,44H 	; 01h 'A'
		DB		00H,50H,44H,44H,50H,44H,44H,50H 	; 02h 'B'
		DB		00H,14H,40H,40H,40H,40H,40H,14H 	; 03h 'C'
		DB		00H,50H,44H,44H,44H,44H,44H,50H 	; 04h 'D'
		DB		00H,54H,40H,40H,54H,40H,40H,54H 	; 05h 'E'
		DB		00H,54H,40H,40H,54H,50H,40H,40H 	; 06h 'F'
		DB		00H,14H,40H,40H,44H,44H,44H,14H 	; 07h 'G'
		DB		00H,44H,44H,44H,54H,44H,44H,44H 	; 08h 'H'
		DB		00H,10H,10H,10H,14H,14H,14H,14H 	; 09h 'I'
		DB		00H,14H,04H,04H,04H,44H,44H,10H 	; 0Ah 'J'
		DB		00H,44H,44H,44H,50H,44H,44H,44H 	; 0Bh 'K'
		DB		00H,40H,40H,40H,40H,40H,40H,54H 	; 0Ch 'L'
		DB		00H,44H,54H,44H,44H,44H,44H,44H 	; 0Dh 'M'
		DB		00H,44H,44H,54H,54H,54H,44H,44H 	; 0Eh 'N'
		DB		00H,10H,44H,44H,44H,44H,44H,10H 	; 0Fh 'O'
		DB		00H,50H,44H,44H,50H,40H,40H,40H 	; 10h 'P'
		DB		00H,10H,44H,44H,44H,44H,10H,04H 	; 11h 'Q'
		DB		00H,50H,44H,44H,50H,44H,44H,44H 	; 12h 'R'
		DB		00H,14H,40H,40H,14H,04H,04H,50H 	; 13h 'S'
		DB		00H,54H,10H,10H,10H,10H,10H,10H 	; 14h 'T'
		DB		00H,44H,44H,44H,44H,44H,44H,54H 	; 15h 'U'
		DB		00H,44H,44H,44H,44H,44H,44H,10H 	; 16h 'V'
		DB		00H,44H,44H,44H,44H,54H,54H,44H 	; 17h 'W'
		DB		00H,44H,44H,44H,10H,44H,44H,44H 	; 18h 'X'
		DB		00H,44H,44H,44H,10H,10H,10H,10H 	; 19h 'Y'
		DB		00H,54H,44H,04H,10H,40H,44H,54H 	; 1Ah 'Z'
		DB		00H,00H,00H,00H,00H,00H,00H,10H 	; 1Bh '.'
		DB		00H,54H,44H,44H,44H,44H,44H,54H 	; 1Ch '0'
		DB		00H,04H,04H,04H,04H,04H,04H,04H 	; 1Dh '1'
		DB		00H,54H,04H,04H,54H,40H,40H,54H 	; 1Eh '2'
		DB		00H,54H,04H,04H,54H,04H,04H,54H 	; 1Fh '3'
		DB		00H,44H,44H,44H,54H,04H,04H,04H 	; 20h '4'
		DB		00H,54H,40H,40H,54H,04H,04H,54H 	; 21h '5'
		DB		00H,54H,40H,40H,54H,44H,44H,54H 	; 22h '6'
		DB		00H,54H,04H,04H,04H,04H,04H,04H 	; 23h '7'
		DB		00H,54H,44H,44H,54H,44H,44H,54H 	; 24h '8'
		DB		00H,54H,44H,44H,54H,04H,04H,54H 	; 25h '9'
		DB		00H,00H,00H,00H,54H,00H,00H,00H 	; 26h '-'
		DB		00H,10H,10H,10H,10H,10H,00H,10H 	; 27h '!'
		DB		00H,14H,40H,40H,40H,40H,40H,14H 	; 28h '('
		DB		00H,50H,04H,04H,04H,04H,04H,50H 	; 29h ')'


		;--------
		; WAITING : エイリアンの待機
		;--------
WAITING:
		LD		A,(MOV)
		LD		B,A				; B = エイリアン隊列の移動方向(DEFDH)
		LD		A,(COUNT)		; A = エイリアン隊列の移動数(DEFCH)
		DEC		A
		OR		A
		JR		NZ,.j01
		LD		A,B
		NEG
		LD		(MOV),A			; エイリアン隊列の移動方向を反転
		LD		A,07H
		LD		B,00H
.j01
		LD		(COUNT),A		; エイリアン隊列の移動数をセット
		LD		A,(PTRN)		; DEFBH 
		XOR		01H
		LD		(PTRN),A		; DEFBH
		LD		C,A
		LD		HL,ALDT			; HL = エイリアン情報テーブル先頭(DEFFH)
.j03
		LD		A,(HL)
		CP		80H				; 終端(80h)か？
		RET		Z				; yes -> 終了
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		PUSH	AF
		LD		A,(HL)
		ADD		A,B		
		LD		(HL),A
		POP		AF
		CP		02H
		JR		NZ,.j02
		LD		D,(HL)
		INC		HL
		LD		E,(HL)
		DEC		HL
		DEC		HL
		DEC		HL
		DEC		HL
		DEC		HL
		DEC		HL
		LD		A,(HL)
		XOR		01H
		NOP
		LD		(HL),A
		INC		HL
		LD		(HL),D
		INC		HL
		LD		(HL),E
		INC		HL
		INC		HL
		INC		HL
.j02
		INC		HL
		INC		HL
		JR		.j03


		;--------
		; 8x12キャラクタデータ
		; マスク、パターンの順で並んでいて
		; １キャラクタは横 8ドット（ 2バイト）×縦12ドット分×（マスク＋パターン）の48バイト
		;--------
CH8X12DAT:
		DB		FFH,00H,FFH,00H,FFH,00H,FFH,00H,F3H,08H,3FH,80H,0CH,F1H,C3H,3CH		; 00h
		DB		00H,F9H,03H,BCH,00H,FDH,03H,FCH,C0H,39H,0FH,B0H,00H,FDH,03H,FCH
		DB		00H,F9H,03H,BCH,C0H,3DH,0FH,F0H,F0H,0DH,3FH,C0H,FFH,00H,FFH,00H
		DB		FFH,00H,FFH,00H,FFH,00H,FFH,00H,F3H,08H,3FH,80H,FCH,01H,FFH,00H		; 01h
		DB		00H,FDH,03H,FCH,00H,F9H,03H,BCH,00H,FDH,03H,FCH,C0H,39H,0FH,B0H
		DB		00H,FDH,03H,FCH,00H,F9H,03H,BCH,CCH,31H,CFH,30H,FFH,00H,FFH,00H
		DB		FFH,00H,FFH,00H,FFH,00H,FFH,00H,F3H,08H,3FH,80H,0CH,53H,C3H,14H		; 02h
		DB		00H,5BH,03H,94H,00H,57H,03H,54H,C0H,1BH,0FH,90H,00H,57H,03H,54H
		DB		00H,5BH,03H,94H,C0H,17H,0FH,50H,F0H,07H,3FH,40H,FFH,00H,FFH,00H
		DB		FFH,00H,FFH,00H,FFH,00H,FFH,00H,F3H,08H,3FH,80H,FCH,03H,FFH,00H		; 03h
		DB		00H,57H,03H,54H,00H,5BH,03H,94H,00H,57H,03H,54H,C0H,1BH,0FH,90H
		DB		00H,57H,03H,54H,00H,5BH,03H,94H,CCH,13H,CFH,10H,FFH,00H,FFH,00H
		DB		FFH,00H,FFH,00H,FFH,00H,FFH,00H,F3H,0CH,3FH,C0H,0CH,A1H,C3H,28H		; 04h
		DB		00H,ADH,03H,E8H,00H,A9H,03H,A8H,C0H,2DH,0FH,E0H,00H,A9H,03H,A8H
		DB		00H,ADH,03H,E8H,C0H,29H,0FH,A0H,F0H,09H,3FH,80H,FFH,00H,FFH,00H
		DB		FFH,00H,FFH,00H,FFH,00H,FFH,00H,F3H,0CH,3FH,C0H,FCH,01H,FFH,00H		; 05h
		DB		00H,A9H,03H,A8H,00H,ADH,03H,E8H,00H,A9H,03H,A8H,C0H,2DH,0FH,E0H
		DB		00H,A9H,03H,A8H,00H,ADH,03H,E8H,CCH,21H,CFH,20H,FFH,00H,FFH,00H
		DB		FFH,00H,FFH,00H,FFH,00H,FFH,00H,F3H,08H,3FH,80H,0CH,F1H,C3H,3CH		; 06h
		DB		00H,CDH,03H,CCH,00H,C1H,03H,0CH,C0H,3DH,0FH,F0H,00H,C1H,03H,0CH
		DB		00H,CDH,03H,CCH,C0H,31H,0FH,30H,F0H,0DH,3FH,C0H,FFH,00H,FFH,00H
		DB		FFH,00H,FFH,00H,FFH,00H,FFH,00H,F3H,08H,3FH,80H,FCH,01H,FFH,00H		; 07h
		DB		00H,FDH,03H,FCH,00H,CDH,03H,CCH,00H,C1H,03H,0CH,C0H,3DH,0FH,F0H
		DB		00H,C1H,03H,0CH,00H,CDH,03H,CCH,CCH,31H,CFH,30H,FFH,00H,FFH,00H
		DB		FFH,00H,3FH,C0H,CCH,13H,0FH,F0H,C0H,16H,00H,FFH,F0H,05H,00H,BFH		; 08h
		DB		C0H,39H,03H,6CH,00H,FEH,03H,5CH,F0H,0FH,00H,96H,F0H,0FH,33H,C4H
		DB		FCH,03H,F3H,08H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H
		DB		FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FCH,03H,F3H,08H		; 09h
		DB		F0H,0FH,33H,C4H,F0H,0FH,00H,96H,00H,FEH,03H,5CH,C0H,39H,03H,6CH
		DB		F0H,05H,00H,BFH,C0H,16H,00H,FFH,CCH,13H,0FH,F0H,FFH,00H,3FH,C0H
		DB		FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,CFH,20H,3FH,C0H		; 0Ah
		DB		CCH,13H,0FH,F0H,00H,96H,0FH,F0H,C0H,35H,00H,BFH,C0H,39H,03H,6CH
		DB		00H,FEH,0FH,50H,00H,FFH,03H,94H,F0H,0FH,33H,C4H,FCH,03H,FFH,00H
		DB		FCH,03H,FFH,00H,F0H,0FH,33H,C4H,00H,FFH,03H,94H,00H,FEH,0FH,50H		; 0Bh
		DB		C0H,39H,03H,6CH,C0H,35H,00H,BFH,00H,96H,0FH,F0H,CCH,13H,0FH,F0H
		DB		CFH,20H,3FH,C0H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H
		DB		FFH,00H,3FH,40H,CCH,31H,0FH,50H,C0H,3EH,00H,55H,F0H,0FH,00H,95H		; 0Ch
		DB		C0H,1BH,03H,E4H,00H,56H,03H,F4H,F0H,05H,00H,BEH,F0H,05H,33H,4CH
		DB		FCH,01H,F3H,08H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H
		DB		FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FCH,01H,F3H,08H		; 0Dh
		DB		F0H,05H,33H,4CH,F0H,05H,00H,BEH,00H,56H,03H,F4H,C0H,1BH,03H,E4H
		DB		F0H,0FH,00H,95H,C0H,3EH,00H,55H,CCH,31H,0FH,50H,FFH,00H,3FH,40H
		DB		FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,CFH,20H,3FH,40H		; 0Eh
		DB		CCH,31H,0FH,50H,00H,BEH,0FH,50H,C0H,1FH,00H,95H,C0H,1BH,03H,E4H
		DB		00H,56H,0FH,F0H,00H,55H,03H,BCH,F0H,05H,33H,4CH,FCH,01H,FFH,00H
		DB		FCH,01H,FFH,00H,F0H,05H,33H,4CH,00H,55H,03H,BCH,00H,56H,0FH,F0H		; 0Fh
		DB		C0H,1BH,03H,E4H,C0H,1FH,00H,95H,00H,BEH,0FH,50H,CCH,31H,0FH,50H
		DB		CFH,20H,3FH,40H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H
		DB		FFH,00H,3FH,80H,CCH,12H,0FH,A0H,C0H,17H,00H,AAH,F0H,05H,00H,EAH		; 10h
		DB		C0H,2DH,03H,78H,00H,ABH,03H,58H,F0H,0AH,00H,D7H,F0H,0AH,33H,84H
		DB		FCH,02H,F3H,0CH,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H
		DB		FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FCH,02H,F3H,0CH		; 11h
		DB		F0H,0AH,33H,84H,F0H,0AH,00H,D7H,00H,ABH,03H,58H,C0H,2DH,03H,78H
		DB		F0H,05H,00H,EAH,C0H,17H,00H,AAH,CCH,12H,0FH,A0H,FFH,00H,3FH,80H
		DB		FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,CFH,30H,3FH,80H		; 12h
		DB		CCH,12H,0FH,A0H,00H,D7H,0FH,A0H,C0H,25H,00H,EAH,C0H,2DH,03H,78H
		DB		00H,ABH,0FH,50H,00H,AAH,03H,D4H,F0H,0AH,33H,84H,FCH,02H,FFH,00H
		DB		FCH,02H,FFH,00H,F0H,0AH,33H,84H,00H,AAH,03H,D4H,00H,ABH,0FH,50H		; 13h
		DB		C0H,2DH,03H,78H,C0H,25H,00H,EAH,00H,D7H,0FH,A0H,CCH,12H,0FH,A0H
		DB		CFH,30H,3FH,80H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H
		DB		FFH,00H,3FH,C0H,CCH,13H,0FH,30H,C0H,14H,00H,3FH,F0H,05H,00H,C3H		; 14h
		DB		C0H,31H,03H,4CH,00H,F3H,03H,5CH,F0H,0CH,00H,16H,F0H,0CH,33H,C4H
		DB		FCH,03H,F3H,08H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H
		DB		FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FCH,03H,F3H,08H		; 15h
		DB		F0H,0CH,33H,C4H,F0H,0CH,00H,16H,00H,F3H,03H,5CH,C0H,31H,03H,4CH
		DB		F0H,05H,00H,C3H,C0H,14H,00H,3FH,CCH,13H,0FH,30H,FFH,00H,3FH,C0H
		DB		FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,CFH,20H,3FH,C0H		; 16h
		DB		CCH,13H,0FH,F0H,00H,97H,0FH,30H,C0H,35H,00H,3FH,C0H,31H,03H,4CH
		DB		00H,C3H,0FH,50H,00H,FCH,03H,14H,F0H,0CH,33H,C4H,FCH,03H,FFH,00H
		DB		FCH,03H,FFH,00H,F0H,0CH,33H,C4H,00H,FCH,03H,14H,00H,C3H,0FH,50H		; 17h
		DB		C0H,31H,03H,4CH,C0H,35H,00H,3FH,00H,97H,0FH,30H,CCH,13H,0FH,F0H
		DB		CFH,20H,3FH,C0H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H,FFH,00H
		DB		FFH,00H,FFH,00H,FCH,02H,FFH,00H,3CH,82H,F3H,08H,CCH,22H,CFH,20H		; 18h
		DB		FFH,00H,FFH,00H,FFH,00H,FFH,00H,0FH,A0H,C3H,28H,FFH,00H,FFH,00H
		DB		FFH,00H,FFH,00H,CCH,22H,CFH,20H,3CH,82H,F3H,08H,FCH,02H,FFH,00H
		DB		CFH,20H,03H,54H,CFH,20H,03H,D4H,CCH,21H,03H,54H,CFH,20H,03H,CCH		; 19h : プレイヤー
		DB		CCH,33H,03H,FCH,C3H,28H,03H,FCH,C0H,3AH,00H,9AH,C0H,2AH,00H,A6H
		DB		CCH,21H,00H,55H,CCH,21H,00H,55H,FCH,01H,30H,45H,F0H,0FH,F0H,0FH
		DB		CFH,20H,FFH,00H,CFH,20H,FFH,00H,03H,A8H,FFH,00H,CFH,20H,FFH,00H		; 1Ah : プレイヤー弾
		DB		CFH,30H,FFH,00H,CFH,30H,FFH,00H,CFH,30H,FFH,00H,CFH,30H,FFH,00H
		DB		C3H,34H,FFH,00H,CFH,30H,FFH,00H,C3H,34H,FFH,00H,CFH,30H,FFH,00H
		DB		FFH,00H,FFH,00H,CFH,20H,FFH,00H,CFH,20H,FFH,00H,CFH,20H,FFH,00H		; 1Bh : ミサイル
		DB		CFH,20H,FFH,00H,CFH,20H,FFH,00H,CFH,20H,FFH,00H,CFH,20H,FFH,00H
		DB		CFH,20H,FFH,00H,CFH,20H,FFH,00H,CFH,20H,FFH,00H,FFH,00H,FFH,00H
		DB		CFH,30H,03H,FCH,CFH,30H,03H,FCH,CCH,33H,03H,FCH,CFH,30H,03H,FCH		; 1Ch : プレイヤーやられ０
		DB		CCH,33H,03H,FCH,C3H,3CH,03H,FCH,C0H,3FH,00H,FFH,C0H,3FH,00H,FFH
		DB		CCH,33H,00H,FFH,CCH,33H,00H,FFH,FCH,03H,30H,CFH,F0H,0FH,F0H,0FH
		DB		CFH,30H,03H,FCH,CFH,30H,03H,7CH,CCH,33H,03H,FCH,CFH,10H,03H,F4H		; 1Dh : プレイヤーやられ１
		DB		CCH,33H,03H,FCH,C3H,3CH,03H,FCH,C0H,1FH,00H,FFH,C0H,3FH,00H,7FH
		DB		CCH,33H,00H,FDH,CCH,33H,00H,FFH,FCH,03H,30H,CFH,F0H,07H,F0H,07H
		DB		CFH,30H,03H,7CH,CFH,30H,03H,1CH,CCH,33H,03H,74H,CFH,00H,03H,D0H		; 1Eh : プレイヤーやられ２
		DB		CCH,33H,03H,F4H,C3H,1CH,03H,FCH,C0H,07H,00H,7FH,C0H,1DH,00H,1DH
		DB		CCH,33H,00H,74H,CCH,33H,00H,FDH,FCH,03H,30H,C7H,F0H,01H,F0H,01H
		DB		CFH,10H,03H,1CH,CFH,10H,03H,04H,CCH,31H,03H,10H,CFH,00H,03H,40H		; 1Fh : プレイヤーやられ３
		DB		CCH,23H,03H,D0H,C3H,18H,03H,B8H,C0H,06H,00H,2EH,C0H,19H,00H,19H
		DB		CCH,22H,00H,60H,CCH,33H,00H,B9H,FCH,02H,30H,C2H,F0H,01H,F0H,01H
		DB		CFH,00H,03H,04H,CFH,00H,03H,00H,CCH,10H,03H,00H,CFH,00H,03H,00H		; 20h : プレイヤーやられ４
		DB		CCH,11H,03H,00H,C3H,10H,03H,54H,C0H,05H,00H,15H,C0H,04H,00H,04H
		DB		CCH,11H,00H,10H,CCH,33H,00H,74H,FCH,01H,30H,C1H,F0H,00H,F0H,00H
		DB		FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH		; 21h
		DB		FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH
		DB		FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH
		DB		FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,00H,00H,00H,00H		; 22h
		DB		00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
		DB		00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H
		DB		00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H		; 23h
		DB		00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,FFH,FFH,FFH,FFH
		DB		FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH,FFH


		;--------
		; ATALSET : 隊列にいるエイリアンを攻撃状態にする
		;--------
ATALSET:
		LD		HL,(ATCO)		; HL = 攻撃カウンタ(DEF7H)
		DEC		HL
		LD		A,H
		OR		L				; 処理するタイミングか？
		JR		Z,.j01			; yes.
		LD		(ATCO),HL
		RET
.j01
		LD		HL,0014H
		LD		(ATCO),HL		; 攻撃カウンタをセット
;
		LD		HL,(ATDTPO)		; HL = 出撃パターン現在位置(DEF9H)
		LD		A,(HL)
		CP		80H				; 出撃パターンの終端(80H)か？
		JR		NZ,.j02			; no.
;
		LD		HL,ATDT + 40H		; A6F8H
.j03
		LD		(ATDTPO),HL		; 出撃パターン現在位置(DEF9H)をセット
		RET
.j02
		LD		B,(HL)			; B = 出撃パターン番号？
		INC		HL
.j06
		; エイリアン番号からエイリアン情報テーブル位置を求める → DE
		LD		DE,ALDT			; DE = エイリアン情報テーブル先頭(DEFFH)
		LD		C,00H
		LD		A,(HL)
		INC		HL
		CP		FFH				; 今回の出撃パターンの終端(FFH)か？
		JR		Z,.j03			; yes.
.j05
		CP		C
		JR		Z,.j04
		INC		C
		INC		DE
		INC		DE
		INC		DE
		INC		DE
		INC		DE
		INC		DE
		INC		DE
		INC		DE
		JR		.j05		;D0
.j04
		LD		A,(DE)
		CP		02H
		JR		NZ,.j06
		LD		A,04H
		LD		(DE),A
		INC		DE
		LD		A,(DE)
		AND		FEH
		ADD		A,A
		ADD		A,08H		;DF
		LD		(DE),A
		INC		DE
		INC		DE
		INC		DE
		PUSH	HL
		PUSH	DE
		; 出撃パターン番号から攻撃パターンポインタを求める → HL
		LD		L,B
		LD		H,00H
		ADD		HL,HL			; * 02h
		ADD		HL,HL			; * 04h
		ADD		HL,HL			; * 08h
		ADD		HL,HL			; * 10h
		ADD		HL,HL			; * 20h
		ADD		HL,HL			; * 40h
		LD		DE,ALMDT		; A8B8H	;F0
		ADD		HL,DE			; HL = 攻撃パターン
		POP		DE
		LD		A,L
		LD		(DE),A
		INC		DE
		LD		A,H
		LD		(DE),A
		POP		HL
		INC		DE
		INC		DE
		INC		DE
		JR		.j06
		NOP
		NOP


		;--------
		; MOVAL : エイリアン情報テーブルにあるエイリアンの移動処理
		;--------
MOVAL:
		LD		HL,ALDT			; HL = エイリアン情報テーブル先頭(DEFFH)
.j02
		LD		A,(HL)
		CP		80H				; 終端(80H)か？
		RET		Z				; yes -> 終了
		CP		03H
		JR		NC,.j01

		; 00h～02h : 次のエイリアン情報へ
.j09
		INC		HL
.j04
		INC		HL
.j04_2
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		JR		.j02
.j01
		CP		07H
		JR		NC,.j03

		; 03h～06h : 
		INC		(HL)			; 状態を更新
		INC		HL
		INC		(HL)			; キャラクタ番号を+1して回転
		JR		.j04

.j03
		JR		NZ,.j05			;
;
		; 07h : 
		INC		HL		; 01h : キャラクタ番号
		INC		HL		; 02h : X座標
		INC		HL		; 03h : Y座標
		INC		HL		; 04h
		LD		E,(HL)
		INC		HL
		LD		D,(HL)	; DE = 
		NOP
		LD		A,(DE)
		LD		B,A
		INC		DE
		LD		(HL),D
		DEC		HL
		LD		(HL),E
		INC		HL
		INC		HL
		LD		D,(HL)
		DEC		HL
		DEC		HL
		DEC		HL
		LD		C,00H
		BIT		3,B
		JR		Z,.j06
		INC		C
		DEC		(HL)
		DEC		(HL)
		DEC		(HL)
		DEC		(HL)
.j06
		BIT		2,B
		JR		Z,.j07
		INC		(HL)
		INC		(HL)
		INC		(HL)
		INC		(HL)
.j07
		LD		A,(HL)
		CP		B2H
		JR		C,.j08
.j12
		LD		(HL),10H
		DEC		HL
		LD		(HL),D
		DEC		HL
		LD		A,(HL)
		AND		1CH
		RRCA
		SUB		04H
		LD		(HL),A
		DEC		HL
		LD		(HL),08H
.j15
		JR		.j09
.j08
		DEC		HL
		BIT		1,B
		JR		Z,.j10
		LD		A,C
		XOR		03H
		LD		C,A
		DEC		(HL)
.j10
		BIT		0,B
		JR		Z,.j11
		INC		(HL)
.j11
		LD		A,(HL)
		INC		HL
		OR		A
		JR		Z,.j12
		CP		1FH
		JR		NC,.j12
		DEC		HL
		DEC		HL
		LD		A,(HL)
		AND		FCH
		OR		C
		LD		(HL),A
		JR		.j04		; .j13

.j05
		; 08h～
		JP		M,.LBLA6B4	; A6B4H
		INC		HL
		LD		A,(HL)
		XOR		01H
		LD		(HL),A
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		LD		B,(HL)
		INC		HL
		LD		A,(HL)
		DEC		HL
		DEC		HL
		DEC		HL
		DEC		HL
		DEC		A
		DEC		A
		CP		(HL)
		JR		NC,.j14
		INC		A
		INC		A
		LD		(HL),A
		DEC		HL
		LD		(HL),B
		DEC		HL
		LD		A,(PTRN)	; DEFBH
		LD		B,A
		LD		A,(HL)
		AND		FEH
		OR		B
		LD		(HL),A
		DEC		HL
		LD		(HL),02H
		JR		.j15
.j14
		LD		A,(HL)
		ADD		A,06H
		LD		(HL),A
		DEC		HL
		LD		(HL),B
		JP		.j04_2			; A60DH
.LBLA6B4
		INC		(HL)
		JP		LBLADC4			; ADC4H


		;--------
		; ATDT : ステージデータ
		;--------
ATDT:
		DB		00H,00H,01H,FFH,01H,06H,07H,FFH,00H,02H,03H,FFH,01H,04H,05H,FFH 	; 01
		DB		02H,08H,10H,FFH,00H,0FH,17H,FFH,01H,09H,0AH,FFH,02H,0DH,0EH,FFH 
		DB		00H,03H,04H,0BH,0CH,FFH,01H,11H,12H,13H,FFH,02H,14H,15H,16H,FFH 
		DB		00H,18H,19H,1AH,1EH,FFH,00H,1BH,1CH,1DH,1FH,14H,15H,16H,FFH,80H 
		DB		03H,06H,07H,0EH,0FH,FFH,00H,03H,04H,05H,FFH,02H,00H,01H,02H,03H 	; 02
		DB		FFH,05H,08H,09H,0AH,FFH,00H,0BH,0CH,0DH,13H,14H,15H,FFH,02H,10H 
		DB		11H,12H,FFH,03H,16H,17H,1DH,FFH,04H,18H,19H,1AH,1BH,1EH,FFH,00H 
		DB		1CH,1DH,1FH,FFH,03H,05H,06H,07H,0DH,0EH,0FH,FFH,80H,00H,00H,00H 
		DB		02H,00H,01H,FFH,03H,02H,03H,FFH,02H,04H,05H,FFH,01H,06H,07H,FFH 	; 03
		DB		02H,08H,09H,0AH,FFH,02H,10H,11H,12H,18H,FFH,01H,0BH,0CH,FFH,01H 
		DB		18H,19H,1AH,1EH,FFH,03H,13H,14H,15H,16H,FFH,01H,1BH,1BH,1DH,1FH 
		DB		FFH,03H,07H,0FH,17H,FFH,00H,00H,08H,10H,FFH,04H,18H,FFH,80H,00H 
		DB		00H,00H,01H,FFH,01H,07H,0FH,17H,FFH,02H,00H,01H,08H,09H,10H,11H 	; 04
		DB		FFH,00H,02H,03H,04H,FFH,00H,05H,06H,07H,FFH,00H,0DH,0EH,0FH,FFH 
		DB		04H,0AH,0BH,0CH,FFH,03H,1BH,1CH,1DH,1FH,FFH,02H,14H,15H,16H,17H 
		DB		FFH,00H,10H,11H,12H,18H,19H,1AH,1FH,FFH,03H,1BH,1CH,1DH,FFH,80H 
		DB		00H,10H,FFH,00H,08H,FFH,00H,11H,18H,FFH,03H,04H,05H,06H,07H,FFH 	; 05
		DB		00H,02H,03H,04H,FFH,03H,0CH,0DH,0EH,0FH,FFH,01H,14H,15H,FFH,01H 
		DB		16H,17H,FFH,04H,12H,13H,19H,1AH,1EH,FFH,04H,1BH,1CH,1DH,1FH,FFH 
		DB		02H,00H,01H,08H,09H,0AH,FFH,01H,13H,14H,15H,FFH,80H,00H,00H,00H 
		DB		00H,01H,FFH,00H,06H,07H,FFH,01H,03H,04H,05H,FFH,06H,00H,FFH,05H 	; 06
		DB		08H,09H,0AH,0BH,0CH,FFH,03H,0DH,0EH,0FH,FFH,02H,10H,11H,12H,FFH 
		DB		04H,18H,19H,1AH,1BH,1CH,1DH,FFH,00H,14H,15H,FFH,04H,1EH,FFH,03H 
		DB		1FH,FFH,03H,03H,04H,05H,06H,FFH,02H,09H,0AH,0BH,12H,FFH,80H,00H 
		DB		00H,01H,FFH,00H,06H,07H,FFH,08H,03H,04H,05H,FFH,06H,00H,FFH,05H 	; 07
		DB		08H,09H,0AH,0BH,0CH,FFH,03H,0DH,0EH,0FH,FFH,02H,10H,11H,12H,FFH 
		DB		09H,18H,19H,1AH,1BH,1CH,1DH,FFH,00H,14H,15H,FFH,04H,1EH,FFH,03H 
		DB		1FH,FFH,07H,03H,04H,05H,06H,FFH,06H,09H,0AH,0BH,12H,FFH,80H,00H 
		DB		00H,00H,01H,02H,03H,04H,05H,06H,07H,FFH,00H,08H,09H,0AH,0BH,0CH 	; 08
		DB		0DH,0EH,0FH,FFH,00H,10H,11H,12H,13H,FFH,09H,14H,15H,16H,17H,FFH 
		DB		00H,18H,19H,1AH,1EH,FFH,00H,1BH,1CH,1DH,1FH,FFH,07H,02H,03H,04H 
		DB		05H,0AH,0BH,0CH,0DH,11H,16H,FFH,00H,19H,1AH,1BH,1CH,FFH,80H,00H 


		;--------
		; ALMDT : 攻撃パターン
		;--------
ALMDT:
		DB		04H,04H,04H,04H,04H,04H,04H,04H,05H,05H,05H,05H,05H,05H,04H,04H 	; パターン00
		DB		06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H 
		DB		06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H 
		DB		06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H 
		DB		04H,04H,04H,04H,04H,04H,04H,04H,06H,06H,06H,06H,06H,06H,04H,04H 	; パターン01
		DB		05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H 
		DB		05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H 
		DB		05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H 
		DB		04H,04H,04H,04H,04H,04H,04H,04H,05H,05H,05H,05H,05H,05H,05H,05H 	; パターン02
		DB		05H,01H,01H,01H,05H,04H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H 
		DB		06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H 
		DB		06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H 
		DB		04H,04H,04H,04H,04H,04H,04H,04H,06H,06H,06H,06H,06H,06H,06H,06H 	; パターン03
		DB		06H,02H,02H,02H,06H,04H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H 
		DB		05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H 
		DB		05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H 
		DB		04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H 	; パターン04
		DB		04H,04H,04H,00H,00H,00H,00H,00H,08H,08H,0AH,02H,06H,06H,06H,06H 
		DB		06H,06H,06H,06H,00H,00H,00H,00H,08H,08H,09H,01H,05H,05H,05H,05H 
		DB		05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H 
		DB		04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,06H,02H,02H,02H 	; パターン05
		DB		02H,06H,04H,04H,04H,04H,04H,04H,04H,04H,05H,01H,01H,01H,01H,01H 
		DB		01H,01H,01H,01H,01H,01H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H 
		DB		05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H 
		DB		04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,01H 	; パターン06
		DB		01H,01H,01H,01H,01H,01H,01H,01H,08H,08H,08H,08H,08H,08H,08H,08H 
		DB		08H,02H,02H,02H,02H,02H,02H,02H,02H,02H,02H,02H,02H,02H,02H,02H 
		DB		06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H,06H 
		DB		04H,04H,04H,05H,05H,05H,05H,05H,01H,02H,01H,02H,01H,02H,0AH,0AH 	; パターン07
		DB		08H,09H,01H,05H,04H,04H,02H,02H,02H,02H,02H,02H,02H,02H,05H,05H 
		DB		05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H 
		DB		05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H,05H 
		DB		04H,04H,04H,04H,04H,04H,04H,04H,05H,05H,05H,05H,05H,05H,01H,01H 	; パターン08
		DB		09H,09H,08H,08H,0AH,02H,02H,02H,06H,06H,04H,04H,04H,05H,00H,00H 
		DB		00H,00H,00H,00H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H 
		DB		04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H 
		DB		04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H 	; パターン09
		DB		04H,04H,04H,00H,00H,00H,00H,00H,00H,00H,00H,00H,04H,04H,04H,04H 
		DB		08H,08H,08H,08H,00H,00H,00H,00H,00H,00H,04H,04H,04H,04H,04H,04H 
		DB		04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H,04H 


		;--------
		; EXVR : 描画画面と表示画面を切り替える
		;--------
EXVR:
		LD		A,(SCR_PAGE)	; DEFEH
		INC		A
		CALL	140CH			; 使用画面設定
		LD		A,(SCR_PAGE)	; DEFEH
		XOR		01H
		LD		(SCR_PAGE),A	; DEFEH
		INC		A
		CALL	13EDH			; 表示画面設定
		RET
		NOP
		NOP
		NOP
		NOP


		;--------
		; CLSCRP : 画面クリア（上部16ラインを除く）
		;--------
CLSCRP:
		LD		A,(SCR_PAGE)	; DEFEH
		RRCA					; *80h
		RRCA					; *40h
		RRCA					; *20h
		ADD		A,C4H
		LD		H,A
		LD		D,A
		LD		L,00H
		LD		E,01H
		LD		(HL),00H
		LD		BC,1600H
		LDIR					; do{ *DE++ = *HL++; } while(--BC > 0);
		RET
		NOP
		NOP


		;--------
		; MSPR : ミサイルプリントルーチン
		;--------
MSPR:
		LD		HL,MSINFO_TOP	; HL = ミサイル情報(DE80H)
.j02
		LD		A,(HL)
		CP		FFH				; バッファの終端？
		RET		Z				; yes. -> ret
;
		OR		A				; ミサイルが存在？
		JR		NZ,.j01			; yes.
;
		INC		HL				; 次のミサイル情報へ
		INC		HL
		INC		HL
		JR		.j02
.j01
		LD		A,1BH			; A = ミサイルのキャラクタ番号(1BH)
		INC		HL
		LD		B,(HL)			; B = X座標
		INC		HL
		LD		C,(HL)			; C = Y座標
		INC		HL
		PUSH	HL
		CALL	PATPRS			; 9C00H PATPRSスプライト表示
		POP		HL
		JR		.j02
		NOP
		NOP
		NOP


		;--------
		; MSSET : 攻撃エイリアンからのミサイル発射
		;--------
MSSET:
		LD		HL,ALDT+03H		; エイリアン情報テーブル先頭(DEFFH + 03H = DF02H)
		LD		DE,MSINFO_TOP	; DE = ミサイル情報テーブル先頭(DE80H)
		CALL	MSSET_SUB		; ABC1H
		CP		FFH				; バッファの終端？
		RET		Z				; yes. -> ret
.j02
		LD		A,(HL)			; A = エイリアンのY座標
		CP		7CH				; y>=124?
		JR		NC,.j01			; yes.
.j03
		; 次のエイリアン情報へ
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		LD		A,(HL)
		CP		80H				; 終端(80H)か？
		RET		Z				; yes -> ret
		INC		HL
		INC		HL
		INC		HL
		JR		.j02
.j01
		CP		84H				; y>=132?
		JR		NC,.j03			; yes.
;
		LD		A,01H
		LD		(DE),A			; ミサイルの存在
		INC		DE
		DEC		HL
		LD		A,(HL)
		LD		(DE),A			; ミサイルのX座標
		INC		DE
		INC		HL
		LD		A,(HL)
		INC		A
		INC		A
		LD		(DE),A			; ミサイルのY座標
		INC		DE
		CALL	MSSET_SUB		; ABC1H
		CP		FFH
		RET		Z
		JR		.j03

		; 空いているミサイル情報を探す
MSSET_SUB:
		LD		A,(DE)
		CP		FFH				; バッファの終端？
		RET		Z				; yes. -> ret
;
		OR		A				; ミサイルが存在？	
		RET		Z				; no. -> ret
;
		INC		DE				; 次のミサイル情報へ
		INC		DE
		INC		DE
		JR		MSSET_SUB


		;--------
		; MOVMS : ミサイルを動かす
		;--------
MOVMS:
		LD		HL,MSINFO_TOP	; HL = ミサイル情報テーブル先頭(DE80H)
.j02
		LD		A,(HL)
		CP		FFH				; バッファの終端？
		RET		Z				; yes. -> ret
		OR		A				; ミサイルが存在？
		JR		NZ,.j01			; yes.
.j05
		; 次のミサイル情報へ
		INC		HL
		INC		HL
.j04
		INC		HL
		JR		.j02
.j01
		INC		HL
		INC		HL
		LD		A,(HL)
		ADD		A,08H			; A = Y座標 + 8
		CP		B4H				; 下限か？
		JR		NC,.j03			; yes.
		LD		(HL),A
		JR		.j04
.j03
		; ミサイルを削除
		LD		(HL),00H
		DEC		HL
		DEC		HL
		LD		(HL),00H
		JR		.j05
		NOP


		;--------
		; MOVST : 星を動かし表示する
		;--------
MOVST:
		LD		HL,STDT			; HL = 星情報テーブル先頭(DE00H)
.j04
		LD		E,(HL)
		INC		HL
		LD		D,(HL)
		INC		HL
		LD		A,D
		CP		E				; DEが0000Hか？
		JR		NZ,.j01			; yes.
		CP		FFH				; 終端(FFH)か？
		RET		Z				; yes. -> ret
.j01
		; 星の位置を更新 -> DE
		LD		B,(HL)			; B = 移動速度(1-)
		PUSH	HL
		LD		HL,0020H
		EX		DE,HL
.j02
		ADD		HL,DE
		DJNZ	.j02
		LD		A,H
		CP		16H				; 下限か？
		JR		C,.j03			; no.
		LD		H,00H			; 下限に達したので、上限にする
.j03
		EX		DE,HL
;
		LD		A,(SCR_PAGE)	; DEFEH
		RRCA
		RRCA
		RRCA
		ADD		A,C4H
		ADD		A,D
		LD		B,D
		LD		D,A
		LD		A,10H
		LD		(DE),A			; 星の位置に星(10H)を書き込む
		POP		HL
		DEC		HL
		LD		(HL),B
		DEC		HL
		LD		(HL),E
		INC		HL
		INC		HL
		INC		HL
		JR		.j04
		NOP


		;--------
		; Key in : キー入力処理
		;--------
GBKEYIN:
		CALL	P6_JOYIN			; 1061H:ゲームキー入力(|SPACE| 0|←|→|↓|↑|STOP|SHIFT|)
		LD		B,A
		LD		A,(FGTRX)		; A = プレイヤーのX座標(DEF6H)
		BIT		5,B				; [←]が押された？
		JR		Z,.j01			; no.
		CP		01H
		JR		Z,.j01
		DEC		A				; x--
.j01
		BIT		4,B				; [→]が押された？
		JR		Z,.j02			; no.
		CP		1DH
		JR		NC,.j02
		INC		A				; x++
.j02
		LD		(FGTRX),A		; A = プレイヤーのX座標(DEF6H)を更新
;
		BIT		7,B				; [SPACE]が押された？
		JR		Z,.j03			; no.

		; 空いている弾バッファを探す
		LD		HL,FIRE			; HL = 弾情報テーブル先頭(DE50H)
.j06
		LD		A,(HL)			; A = 弾情報
		CP		FFH				; バッファの終端？
		JR		Z,.j03			; yes.
		OR		A				; 弾が存在？
		JR		Z,.j05			; no.
		INC		HL
		INC		HL
		INC		HL
		JR		.j06
.j05
		; 空いている弾バッファを見つけたので、弾を発射する
		LD		(HL),01H
		INC		HL
		LD		A,(FGTRX)		; A = プレイヤーのX座標(DEF6H)
		LD		(HL),A
		INC		HL
		LD		A,A4H
		LD		(HL),A
		CALL	FSO2			; AF0CH
.j03
		; 弾の位置を更新する
		LD		HL,FIRE			; HL = 弾情報テーブル先頭(DE50H)
.j09
		LD		A,(HL)
		INC		HL
		INC		HL
		CP		FFH				; バッファの終端？
		JR		Z,.j07			; yes.
		OR		A				; 弾が存在？
		JR		NZ,.j08			; yes.
.LBLAC73
		INC		HL
		JR		.j09
.j08
		LD		A,(HL)
		SUB		0AH				; A = Y座標 - 0AH
		CP		10H				; 画面上限か？
		JR		NC,.j10			; no.
		; 弾を削除
		DEC		HL
		DEC		HL
		LD		(HL),000H
		INC		HL
		INC		HL
		LD		(HL),000H
		INC		HL
		JR		.j09			; LBLAC69
;LBLAC88:
.j10
		LD		(HL),A
		JR		.LBLAC73
;LBLAC8B:
.j07
		CALL	CLSCRP			; 0AB50H 画面クリア
		CALL	MOVST			; 0ABF0H 星を動かし表示
		CALL	MSPR			; 0AB68H ミサイル表示
		CALL	ALPR			; 09D14H エイリアンテーブル上のエイリアンを描画する
;
		; プレイヤー弾を描画する
		LD		HL,FIRE			; HL = 弾情報テーブル先頭(DE50H)
.LBLAC9A
		LD		A,(HL)
		INC		HL
		CP		0FFH			; バッファの終端？
		JR		Z,.j30			; yes.(.LBLACB4)
		OR		A				; 弾が存在？
		JR		NZ,.LBLACA7		; yes.
		INC		HL				; 次の弾情報へ
		INC		HL
		JR		.LBLAC9A
.LBLACA7
		LD		B,(HL)			; B = X座標
		INC		HL
		LD		C,(HL)			; C = Y座標
		INC		HL
		LD		A,01AH			; A = 弾のキャラクタ番号(1AH)
		PUSH	HL
		CALL	PATPRS			; 9C00H PATPRSスプライト表示
		POP		HL
		JR		.LBLAC9A
.j30							; .LBLACB4
		; プレイヤーを描画する
		LD		A,(FGTRX)		; A = プレイヤーのX座標(DEF6H)
		LD		B,A
		LD		C,0A4H
		LD		A,019H
		CALL	PATPRS			; 9C00H PATPRSスプライト表示
;
		JP		EXVR			; AB38H 画面切り替え
		NOP
		NOP


		;--------
		; CRSHCK : プレイヤーとエイリアン、ミサイルとのヒットチェック
		;--------
CRSHCK:
		LD		A,(FGTRX)		; 
		LD		B,A				; B = プレイヤーのX座標(DEF6H)
		XOR		A
		LD		(POINT),A		; ポイント(DEF2H) = 0
		LD		HL,ALDT			; HL = エイリアン情報テーブル先頭(DEFFH)
.l01							; LBLACCF:
		LD		A,(HL)
		INC		HL
		INC		HL
		CP		080H			; バッファの終端？
		JR		Z,.j01			; yes. -> LBLAD07
		NOP
		NOP
		CP		003H			; WAIT >= 3?
		JR		NC,.j02			; yes. -> LBLACE4
.j05							; LBLACDC:
		; 次のエイリアン情報へ
		INC		HL
.j04							; LBLACDD:
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		JR		.l01			; LBLACCF
.j02							; LBLACE4:
		; X座標を比較する
		LD		A,(HL)
		DEC		A
		CP		B
		JR		Z,.j03			; LBLACF1
		INC		A
		CP		B
		JR		Z,.j03			; LBLACF1
		INC		A
		CP		B
		JR		NZ,.j05			; LBLACDC
.j03							; LBLACF1:
		; Y座標を比較する
		INC		HL
		LD		A,(HL)
		CP		09FH
		JR		C,.j04			; LBLACDD
		CP		0B0H
		JR		NC,.j04			; LBLACDD
		DEC		HL
		DEC		HL
		LD		(HL),018H		; キャラクタ番号 = 18H
		DEC		HL
		LD		(HL),0FFH		; WAIT = FFH
.j06							; LBLAD02:
		XOR		A
		LD		(DETH),A		; プレイヤーの死亡フラグ(DEF5H) = 死亡(00H)
		RET
.j01							; LBLAD07:
		LD		HL,0DE7FH		; HL = ？エイリアン情報テーブル終端(DE7FH)
.j07							; LBLAD0A:
		INC		HL
		LD		A,(HL)
		CP		0FFH
		JR		Z,.j09			; LBLAD29
		INC		HL
		LD		A,(HL)
		INC		HL
		CP		B
		JR		Z,.j08			; LBLAD1A
		DEC		A
		CP		B
		JR		NZ,.j07			; LBLAD0A
.j08							; LBLAD1A:
		LD		A,(HL)
		CP		09FH
		JR		C,.j07			; LBLAD0A
		CP		0B0H
		JR		NC,.j07			; LBLAD0A
		DEC		HL
		DEC		HL
		LD		(HL),000H
		JR		.j06			; LBLAD02
.j09							; LBLAD29:
		LD		DE,ATDTPO		; DE = 出撃パターン現在位置(0DEF9H)
.j10							; LBLAD2C:
		INC		DE
		INC		DE
		INC		DE
		INC		DE
		INC		DE
		INC		DE
		LD		A,(DE)
		INC		DE
		INC		DE
		CP		080H
		RET		Z
		JR		NC,.j10			; LBLAD2C
		NOP
		OR		A
		JR		Z,.j10			; LBLAD2C

		LD		HL,0DE4EH
.j11							; LBLAD41:
		INC		HL
.j12							; LBLAD42:
		INC		HL
		LD		A,(HL)
		INC		HL
		CP		0FFH
		JR		Z,.j10			; LBLAD2C
		OR		A
		JR		Z,.j11			; LBLAD41
		LD		A,(DE)
		LD		B,A
		LD		A,(HL)
		INC		HL
		CP		B
		JR		Z,.j13			; LBLAD57
		DEC		A
		CP		B
		JR		NZ,.j12			; LBLAD42
.j13							; LBLAD57:
		INC		DE
		LD		A,(DE)
		LD		B,A
		DEC		DE
		LD		A,(HL)
		ADD		A,00BH
		CP		B
		JR		C,.j12			; LBLAD42
		SUB		017H
		CP		B
		JR		NC,.j12			; LBLAD42
		DEC		HL
		DEC		HL
		LD		(HL),000H
		INC		HL
		INC		HL
		EX		DE,HL
		DEC		HL
		LD		A,(HL)
		LD		(HL),018H
		DEC		HL
		LD		(HL),0FFH
		INC		HL
		INC		HL
		EX		DE,HL
		AND		01EH
		ADD		A,002H
		RRCA
		INC		A
		LD		B,A
		LD		A,(POINT)		; A = ポイント(DEF2H)
		ADD		A,B
		LD		(POINT),A		; ポイント(DEF2H)を更新
		CALL	HITSO			; MDLAEC4
		JR		.j10			; LBLAD2C
		NOP
		NOP


		;--------
		; SCPR : スコア表示ルーチン
		;--------
SCPR:
		LD		DE,SCDT			; DE = スコア表示用バッファ(DEEAH)
		LD		HL,(SCORE)		; HL = スコア(DEF3H)
		LD		BC,2710H		; BC = '10000'
		CALL	COUNT_BASE		; MDLADB6
		LD		BC,03E8H		; BC = '1000'
		CALL	COUNT_BASE		; MDLADB6
		LD		BC,0064H		; BC = '100'
		CALL	COUNT_BASE		; MDLADB6
		LD		C,00AH			; BC = '10'
		JP		COUNT_BASE_2	; LBLADD4
		NOP


		;--------
		;--------
LBLADAA:
		LD		(DE),A
		LD		HL,SCDT			; HL = スコア表示用バッファ(DEEAH)
		LD		DE,1A08H
		LD		C,003H
		JP		MSGPR			; 文字列出力(9C88H)

		;--------
		; COUNT_BASE : HLの値にBCで指定された基数がいくつあるかを求め、キャラクタコードとして返す
		; (out)
		;	A	キャラクタコード(1CH～)
		;--------
COUNT_BASE:
;MDLADB6:
		LD		A,01CH		; A = 8x8キャラクタコード '0'
;LBLADB8:
.j01
		OR		A
		SBC		HL,BC
		JR		C,.j02		; LBLADC0
		INC		A
		JR		.j01		; LBLADB8
.j02
;LBLADC0:
		ADD		HL,BC
		LD		(DE),A
		INC		DE
		RET


		;--------
		;--------
LBLADC4:
		LD	A,(HL)
		OR	A
		JR	NZ,.j01			; LBLADD0
		INC	HL
		INC	HL
		INC	HL
		LD	(HL),000H
		DEC	HL
		DEC	HL
		DEC	HL
.j01
;LBLADD0:
		JP	MOVAL.j09		; 0A60BH
		NOP


		;--------
		;--------
COUNT_BASE_2:					; LBLADD4:
		CALL	COUNT_BASE		; MDLADB6
		LD		A,L
		ADD		A,01CH
		JP		LBLADAA
		NOP
		NOP
		NOP


		;--------
		; MAIN
		;--------
MAIN:
LBLADE0:
		XOR		A
		LD		(POINT),A		; ポイント(DEF2H) = 0
		CALL	CRSHCK			; プレイヤーとエイリアン、ミサイルとのヒットチェック
;
		; スコアにポイントを加算する
		LD		A,(POINT)		; A = ポイント(DEF2H)
		LD		HL,(SCORE)		; HL = スコア(DEF3H)
		ADD		A,L
		LD		L,A
		LD		A,000H
		ADC		A,H
		LD		H,A
		LD		(SCORE),HL		; スコア(DEF3H)を更新
;
		LD		A,(DETH)		; A = プレイヤーの死亡フラグ(DEF5H)
		OR		A
		RET		Z
		CALL	SCPR			; スコア表示
		CALL	GBKEYIN			; START
		CALL	MOVAL			; エイリアン情報テーブルにあるエイリアンの移動処理(0A600H)
		CALL	ATALSET			; 隊列にいるエイリアンを攻撃状態にする(0A594H)
		CALL	MOVMS			; ミサイルを動かす(0ABCCH)
		CALL	MSSET			; 攻撃エイリアンからのミサイル発射(0AB88H)
		LD		HL,ALDT			; HL = エイリアン情報テーブル先頭(DEFFH)
		LD		C,000H
LBLAE12:
		LD		A,(HL)
		CP		080H
		JR		Z,LBLAE25
		OR		A
		JR		NZ,LBLAE1B
		INC		C
LBLAE1B:
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		INC		HL
		JR		LBLAE12
LBLAE25:
		LD		A,C
		LD		(ALNUM),A		; 倒したエイリアン数(DEE7H)を更新
		CP		020H
		JR		C,LBLAE33
		LD		A,0FFH
		LD		(DETH),A		; プレイヤーの死亡フラグ(DEF5H) = １面クリア(0FFH)
		RET	
LBLAE33:
		LD		A,(WAITCO)		; A = WAITINGカウンタ(0DEF1H)
		DEC		A
		JR		NZ,LBLAE3E
		CALL	WAITING			; 9E84H
		LD		A,006H
LBLAE3E:
		LD		(WAITCO),A		; WAITINGカウンタ(0DEF1H)を更新
		CALL	BGM				; MDLAE54
		; 総攻撃判定
		LD		A,(ALNUM)		; A = 倒したエイリアン数(DEE7H)
		CP		018H
		JR		C,LBLAE50
		LD		A,001H
		LD		(ATCO),A		; DEF7H
LBLAE50:
		JR		MAIN			; LBLADE0
		NOP
		NOP


		;--------
		; BGM
		;--------
BGM:
		LD		A,008H
		LD		E,00AH
		CALL	1BC5H			; PSG出力(8,10)
;
		LD		A,(BGMSTEP)		; BGMのステップ(DEE6H)
		LD		E,A
		ADD		A,020H
		LD		(BGMSTEP),A		; BGMのステップ(DEE6H)を更新
		XOR		A
		JP		1BC5H			; PSG出力(0,?)


		;--------
		; MSG-I : SCORE,FIGHTER...などの文字を表示
		;--------
MSG_I:
		LD		HL,MSG_I_D01	; AE98H HL = 'FIGHTER ROUND'
		LD		DE,0000H
		LD		C,04H
		CALL	MSGPR			; 9C88H 文字列出力
;
		LD		HL,MSG_I_D02	; AEA6H HL = 'GALAXY BEES'
		LD		DE,0E00H
		LD		C,03H
		CALL	MSGPR			; 9C88H 文字列出力
;
		LD		HL,MSG_I_D03	; AEB2H HL = '-AMPLE (C)-'
		LD		DE,0E08H
		LD		C,02H
		CALL	MSGPR			; 9C88H 文字列出力
;
		LD		HL,MSG_I_D04	; AEBEH HL = 'SCORE'
		LD		DE,1B00H
		LD		C,04H
		CALL	MSGPR			; 9C88H 文字列出力
		JP		SCPR			; スコア表示(AD8CH)
		NOP


		;--------
		; MSGS
		; 000000000000000011111111111111112222222222222222
		; 0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
		;  ABCDEFGHIJKLMNOPQRSTUVWXYZ
		;--------
MSG_I_D01:
		DB		'FIGH'
		DB		'TER '
		DB		'ROUN'
		DB		'D',FFH
MSG_I_D02:
		DB		'GA'
		DB		'LAXY'
		DB		' BEE'
		DB		'S',FFH
MSG_I_D03:
		DB		' P'			; '-A'
		DB		'INEA'			; 'MPLE'
		DB		'PPLE'			; ' (C)'
		DB		' ',FFH			; '-',FFH
MSG_I_D04:
		DB		'SC'
		DB		'ORE',FFH

		;--------
		; HITSO : ヒット音出力？
		;	B	
		;--------
HITSO:
		PUSH	DE
		NOP
		RLC		B			; x2
		RLC		B			; x4
		RLC		B
		LD		E,B
		LD		A,02H
		CALL	1BC5H		; PSG出力(2,E)
		LD		A,09H
		LD		E,0FH
		CALL	1BC5H		; PSG出力(9,15)
		LD		A,03H
		LD		B,08H
.j02
		LD		E,B
		CALL	1BC5H		; PSG出力(3,8->1)
		LD		C,FFH
.j01
		DEC		C
		JR		NZ,.j01
		DJNZ	.j02
		LD		E,B
		LD		A,09H
		CALL	1BC5H		; PSG出力(9,0)
		POP		DE
		RET


		;--------
		; FSO
		;--------
FSO:
		LD		A,005H
		LD		E,000H
		CALL	1BC5H			; PSG出力(5,0)
		LD		E,B
		LD		B,020H
LBLAEFA:
		LD		A,004H
		CALL	1BC5H			; PSG出力(4,?)
		LD		A,00AH
		LD		D,E
		LD		E,00FH
		CALL	1BC5H			; PSG出力(10,15)
		LD		E,D
		DEC		E
		DJNZ	LBLAEFA
		RET	

		;--------
		; FSO2 : ショット音出力
		;--------
FSO2:
;MDLAF0C:
		LD		B,040H
		CALL	FSO			; MDLAEF0
		LD		B,070H
		CALL	FSO			; MDLAEF0
		LD		B,0A0H
		CALL	FSO			; MDLAEF0
		LD		A,00AH
		LD		E,B
		JP		1BC5H
		RST		38H
		RST		38H
		RST		38H


		;--------
		; ATDTSET : プレイヤー数、ラウンド数、ループ数の表示
		;--------
ATDTSET:
		LD		A,(FGTRNUM)		; A = プレイヤーの数(DEE4H)
		ADD		A,1CH
		LD		C,A
		LD		B,03H
		LD		DE,0508H
		CALL	PR8X8	; 9C44H		; １文字出力
		LD		A,(LOOP)		; A = ループ数(DEE3H)
		ADD		A,1CH
		LD		C,A
		LD		B,09H
		CALL	PR8X8	; 9C44H		; １文字出力
		INC		D
		LD		C,26H
		CALL	PR8X8	; 9C44H		; １文字出力
		INC		D
;
		; ラウンド数に対応するステージデータ情報を確定する → A5AFH
		LD		A,(ROUND)			; A = ROUND数(DEE5H)
		LD		BC,0040H
		LD		HL,ATDT				; A6B8H
.loop
		DEC		A
		JR		Z,.j01
		ADD		HL,BC
		JR		.loop
.j01
		LD      (A5AFH),HL
;
		LD		A,(ROUND)			; A = ROUND数(DEE5H)
		ADD		A,1CH
		LD		C,A
		LD		B,03H
		JP		PR8X8	; 9C44H		; １文字出力
		NOP
		NOP
		NOP

		;--------
		; AFTERDETH
		;--------
AFTERDETH:
		LD		DE,1C08H
.loop02
		PUSH	DE
		CALL	CLSCRP			; AB50H 画面クリア
		CALL	MOVST			; ABF0H 星を動かし表示
		CALL	MSPR			; AB68H ミサイル表示
		CALL	ALPR			; 9D14H エイリアンテーブル上のエイリアンを描画する
;
		LD		A,(FGTRX)		; A = プレイヤーのX座標(DEF6H)
		LD		B,A
		LD		C,A4H
		POP		DE
		LD		A,D
		PUSH	DE
		CALL	PATPRS			; 9C00H PATPRSスプライト表示
		CALL	EXVR			; AB38H
		CALL	MOVMS			; ミサイルを動かす(0ABCCH)
		CALL	MOVAL			; エイリアン情報テーブルにあるエイリアンの移動処理(0A600H)
		LD		A,(WAITCO)		; A = WAITINGカウンタ(DEF1H)
		DEC		A
		JR		NZ,.jp01
		CALL	WAITING			; 9E84H
		LD		A,06H
.jp01
		LD		(WAITCO),A		; WAITINGカウンタ(DEF1H)を更新
		CALL	BGM				; AE54H
		CALL	SCPR			; スコア表示(AD8CH)
		POP		DE
		DEC		E
		JR		NZ,.loop02		;
		LD		E,08H
		INC		D
		LD		A,D
		CP		21H
		JR		NZ,.loop02
		RET


		;FF FF 9E
		DB		0FFH
		DB		0FFH

		; ロードチェックサム : 09EH



