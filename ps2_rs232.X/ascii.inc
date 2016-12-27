;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;NOM: ps2_rs232
;DESCRIPTION: adapteur de clavier PS/2 vers RS232 TTL. 
;   le MCU PIC12F1572 lit les codes du clavier et les convertis en codes ASCII
;   pour les retransmettre via le EUSART. 
;CRÉATION:  2016-12-22
;AUTEUR: Jacques Deschênes, Copyright 2016
;This file is part of ps2_rs232.
; REF:  http://www.asciitable.com/    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;This file is part of ps2_rs232.
;
;    ps2_rs232 is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    ps2_rs232 is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with ps2_rs232.  If not, see <https://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;liste de code ASCII avec nom symbolique
;REF: www.asciitable.com
    radix dec
; codes de contrôle    
A_NUL	equ	0   ;null
A_SOH	equ	1   ;start of heading
A_STX	equ	2   ;start of text
A_ETX	equ	3   ;end of text
A_EOT	equ	4   ;end of transmission
A_ENQ	equ	5   ;enquiry
A_ACK	equ	6   ;acknowledge
A_BEL	equ	7   ;bell
A_BKSP	equ	8   ;backspace
A_TAB	equ	9   ;horizontal tab
A_LF	equ	10  ;line feed
A_VT	equ	11  ;vertical tab
A_FF	equ	12  ;form feed
A_CR	equ	13  ;carriage return
A_SO	equ	14  ;shift out
A_SI	equ	15  ;shift in
A_DLE	equ	16  ;data link escape
A_DC1	equ	17  ;device control 1
A_DC2	equ	18  ;device control 2
A_DC3	equ	19  ;device control 3
A_DC4	equ	20  ;device control 4
A_NAK	equ	21  ;negative ackowledge
A_SYN	equ	22  ;synchronous idle
A_ETB	equ	23  ;end of trans. block
A_CAN	equ	24  ;cancel
A_EM	equ	25  ;end of medium
A_SUB	equ	26  ;substitute
A_ESC	equ	27  ;escape
A_FS	equ	28  ;file separator	
A_GS	equ	29  ;group separator
A_RS	equ	30  ;record separator
A_US	equ	31  ;unit separator
;caractères
A_SPACE equ	32  ; ' '
A_EXCLA	equ	33  ; '!'
A_DQUOT	equ	34  ; '"'	
A_SHARP equ	35  ; '#'
A_DOLLR	equ	36  ; '$'
A_PRCNT	equ	37  ; '%'
A_AMP	equ	38  ; '&'
A_QUOT	equ	39  ; '\''
A_LPAR	equ	40  ; '('
A_RPAR  equ	41  ; ')'
A_STAR  equ	42  ; '*'
A_PLUS	equ	43  ; '+'
A_COMM	equ	44  ; ','
A_DASH  equ	45  ; '-'
A_DOT	equ	46  ; '.'
A_SLASH equ	47  ; '/'
A_0	equ	48  ; '0'
A_1	equ	49  ; '1'
A_2	equ	50  ; '2'
A_3	equ	51  ; '3'	
A_4	equ	52  ; '4'
A_5	equ	53  ; '5'
A_6	equ	54  ; '6'
A_7	equ	55  ; '7'
A_8	equ	56  ; '8'
A_9	equ	57  ; '9'
A_COL	equ	58  ; ':'
A_SCOL	equ	59  ; ';'
A_LT	equ	60  ; '<'
A_EQUAL equ	61  ; '='
A_GT	equ	62  ; '>'
A_QUST	equ	63  ; '?'
A_AROB	equ	64  ; '@'
A_AU	equ	65  ; 'A'
A_BU	equ	66  ; 'B'
A_CU	equ	67  ; 'C'
A_DU	equ	68  ; 'D'
A_EU	equ	69  ; 'E'
A_FU	equ	70  ; 'F'
A_GU	equ	71  ; 'G'
A_HU	equ	72  ; 'H'
A_IU	equ	73  ; 'I'
A_JU	equ	74  ; 'J'
A_KU	equ	75  ; 'K'
A_LU	equ	76  ; 'L'
A_MU	equ	77  ; 'M'
A_NU	equ	78  ; 'N'
A_OU	equ	79  ; 'O'
A_PU	equ	80  ; 'P'
A_QU	equ	81  ; 'Q'
A_RU	equ	82  ; 'R'
A_SU	equ	83  ; 'S'
A_TU	equ	84  ; 'T'
A_UU	equ	85  ; 'U'
A_VU	equ	86  ; 'V'
A_WU	equ	87  ; 'W'
A_XU	equ	88  ; 'X'
A_YU	equ	89  ; 'Y'
A_ZU	equ	90  ; 'Z'
A_LBRK	equ	91  ; '['
A_BSLA	equ	92  ; '\\'
A_RBRK	equ	93  ; ']'
A_CIRC	equ	94  ; '^'
A_UNDR	equ	95  ; '_'
A_ACUT	equ	96  ; '`'
A_AL	equ	97  ; 'a'
A_BL	equ	98  ; 'b'
A_CL	equ	99  ; 'c'
A_DL	equ	100 ; 'd'
A_EL	equ	101 ; 'e'
A_FL	equ	102 ; 'f'
A_GL	equ	103 ; 'g'
A_HL	equ	104 ; 'h'
A_IL	equ	105 ; 'i'
A_JL	equ	106 ; 'j'
A_KL	equ	107 ; 'k'
A_LL	equ	108 ; 'l'
A_ML	equ	109 ; 'm'
A_NL	equ	110 ; 'n'
A_OL	equ	111 ; 'o'
A_PL	equ	112 ; 'p'
A_QL	equ	113 ; 'q'
A_RL	equ	114 ; 'r'
A_SL	equ	115 ; 's'
A_TL	equ	116 ; 't'
A_UL	equ	117 ; 'u'
A_VL	equ	118 ; 'v'
A_WL	equ	119 ; 'w'
A_XL	equ	120 ; 'x'
A_YL	equ	121 ; 'y'
A_ZL	equ	122 ; 'z'
A_LBRC	equ	123 ; '{'
A_PIPE	equ	124 ; '|'
A_RBRC	equ	125 ; '}'
A_TILD	equ	126 ; '~'
A_DEL	equ	127 ; DELETE	
	
	