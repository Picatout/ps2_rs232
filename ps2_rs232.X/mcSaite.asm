;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;NOM: ps2_rs232
;DESCRIPTION: adapteur de clavier PS/2 vers RS232 TTL. 
;   le MCU PIC12F1572 lit les codes du clavier et les convertis en codes ASCII
;   pour les retransmettre via le EUSART. 
;CRÉATION:  2016-12-22
;AUTEUR: Jacques Deschênes, Copyright 2016
;This file is part of ps2_rs232.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

; table scancode vers ASCII pour clavier MCSaite
    include ascii.inc
    include ps2_codes.inc
    
    
    code
;table de correspondance code clavier -> code ASCII    
;  dt code_clavier,code_ascii 
    global std_codes
std_codes:
   brw
   dt 0x1c,A_AU	;'A' 
   dt 0x32,A_BU	;'B'
   dt 0x21,A_CU	;'C'
   dt 0x23,A_DU	;'D'
   dt 0x24,A_EU	;'E'
   dt 0x2b,A_FU	;'F'
   dt 0x34,A_GU	;'G'
   dt 0x33,A_HU	;'H'
   dt 0x43,A_IU	;'I'
   dt 0x3B,A_JU	;'J'
   dt 0x42,A_KU	;'K'
   dt 0x4b,A_LU	;'L'
   dt 0x3a,A_MU	;'M'
   dt 0x31,A_NU	;'N'
   dt 0x44,A_OU	;'O'
   dt 0x4d,A_PU	;'P'
   dt 0x15,A_QU	;'Q'
   dt 0x2d,A_RU	;'R'
   dt 0x1b,A_SU	;'S'
   dt 0x2c,A_TU	;'T'
   dt 0x3c,A_UU	;'U'
   dt 0x2a,A_VU	;'V'
   dt 0x1d,A_WU	;'W'
   dt 0x22,A_XU	;'X'
   dt 0x35,A_YU	;'Y'
   dt 0x1a,A_ZU	;'Z'
   dt 0x45,A_0	;'0'
   dt 0x16,A_1	;'1'
   dt 0x1e,A_2	;'2'
   dt 0x26,A_3	;'3'
   dt 0x25,A_4	;'4'
   dt 0x2e,A_5	;'5'
   dt 0x36,A_6	;'6'
   dt 0x3d,A_7	;'7'
   dt 0x3e,A_8	;'8'
   dt 0x46,A_9	;'9'
   dt 0x0e,A_ACUT   ;'`'
   dt 0x4e,A_DASH   ;'-'
   dt 0x55,A_EQUAL  ;'='
   dt 0x5d,A_BSLA   ;'\\'
   dt 0x54,A_LBRK   ;'['
   dt 0x5b,A_RBRK   ;']'
   dt 0x4c,A_SCOL   ;';'
   dt 0x52,A_QUOT   ;'\''
   dt 0x41,A_COMM   ;','
   dt 0x49,A_DOT    ;'.'
   dt 0x7c,A_STAR   ;'*'
   dt 0x79,A_PLUS   ;'+'
   dt 0x29,A_SPACE  ;' '
   dt SC_ENTER,A_CR ;'\r'
   dt SC_BKSP,A_BKSP	;back space
   dt SC_TAB,A_TAB  ; tabulation
   dt SC_ESC,A_ESC  ; échappement
   dt SC_NUM,VK_NUM ; num lock
   dt SC_KP0,A_0    ;'0'
   dt SC_KP1,A_1    ;'1'
   dt SC_KP2,A_2    ;'2'
   dt SC_KP3,A_3    ;'3'
   dt SC_KP4,A_4    ;'4'
   dt SC_KP5,A_5    ;'5'
   dt SC_KP6,A_6    ;'6'
   dt SC_KP7,A_7    ;'7'
   dt SC_KP8,A_8    ;'8'
   dt SC_KP9,A_9    ;'9'
   dt SC_KPMUL,A_STAR	;'*'
   dt SC_KPDIV,A_SLASH	;'/'
   dt SC_KPPLUS,A_PLUS	;'+'
   dt SC_KPMINUS,A_DASH	;'-'
   dt SC_KPDOT,A_DOT	;'.'
   dt SC_KPENTER,A_CR	;'\r'
   dt SC_F1,VK_F1
   dt SC_F2,VK_F2
   dt SC_F3,VK_F3
   dt SC_F4,VK_F4
   dt SC_F5,VK_F5
   dt SC_F6,VK_F6
   dt SC_F7,VK_F7
   dt SC_F8,VK_F8
   dt SC_F9,VK_F9
   dt SC_F10,VK_F10
   dt SC_F11,VK_F11
   dt SC_F12,VK_F12
   dt SC_LSHIFT,VK_LSHIFT
   dt SC_RSHIFT,VK_RSHIFT
   dt SC_LCTRL,VK_LCTRL
   dt SC_LALT,VK_LALT
   dt SC_LSHIFT,VK_LSHIFT
   dt SC_RSHIFT,VK_RSHIFT
   dt SC_CAPS,VK_CAPS
   dt 0

;; codes étendus
   global xt_codes
xt_codes:
    brw
    dt SC_RCTRL,VK_RCTRL
    dt SC_LGUI,VK_LGUI
    dt SC_RGUI,VK_RGUI 
    dt SC_RALT,VK_RALT
    dt SC_APPS,VK_APPS
    dt SC_UP,VK_UP
    dt SC_DOWN,VK_DOWN
    dt SC_LEFT,VK_LEFT
    dt SC_RIGHT,VK_RIGHT
    dt SC_INSERT,VK_INSERT
    dt SC_HOME,VK_HOME
    dt SC_PGUP,VK_PGUP
    dt SC_PGDN,VK_PGDN
    dt SC_DEL,A_DEL
    dt SC_END,VK_END
    dt SC_KPDIV,'/'
    dt SC_KPENTER,'\r'
    dt 0x12,VK_PRN
    dt 0x7c,0
    dt 0
    
   
;table des caractères avec touche SHIFT enfoncée
   global table_shifted
table_shifted:
   brw
   dt A_1,A_EXCLA   ;'!'
   dt A_2,A_AROB    ;'@'
   dt A_3,A_SHARP   ;'#'
   dt A_4,A_DOLLR   ;'$'
   dt A_5,A_PRCNT   ;'%'
   dt A_6,A_CIRC    ;'^'
   dt A_7,A_AMP	    ;'&'
   dt A_8,A_STAR    ;'*'
   dt A_9,A_LPAR    ;'('
   dt A_0,A_RPAR    ;')'
   dt A_DASH,A_UNDR ;'_'
   dt A_EQUAL,A_PLUS	;'+'
   dt A_ACUT,A_TILD ;'~'
   dt A_QUOT,A_DQUOT	;'"'
   dt A_COMM,A_LT   ;'<'
   dt A_DOT,A_GT    ;'>'
   dt A_SLASH,A_QUST	;'?'
   dt A_BSLA,A_PIPE ;'|'
   dt A_SCOL,A_COL  ;':'
   dt A_LBRK,A_LBRC ;'[','{'
   dt A_RBRK,A_RBRC ;']','}'
   dt VK_UP,VK_SUP  ; <SHIFT>-<UP>
   dt VK_DOWN,VK_SDOWN ; <SHIFT>-<DOWN>
   dt VK_LEFT,VK_SLEFT ; <SHIFT>-<LEFT>
   dt VK_RIGHT,VK_SRIGHT ; <SHIFT>-<RIGHT>
   dt VK_HOME,VK_SHOME ; <SHIFT>-<HOME>
   dt VK_END,VK_SEND ; <SHIFT>-<END>
   dt VK_PGUP,VK_SPGUP ; <SHIFT>-<PGUP>
   dt VK_PGDN,VK_SPGDN ; <SHIFT>-<PGDN>
   dt 0
   
;table des caractères avec touche ALTCHAR enfoncée
   global table_altchar
table_altchar:
   brw
   dt A_1,A_BSLA    ;'\\'
   dt A_2,A_AROB    ;'2','@'
   dt A_3,A_SLASH   ;'3','/'
   dt A_6,A_QUST    ;'6','?'
   dt A_7,A_PIPE    ;'7','|'
   dt A_9,A_LBRC    ;'9','{'
   dt A_0,A_RBRC    ;'0','}'
   dt 0
   
; altération par touche CTRL    
    global table_control
table_control: 
    brw
    dt A_CU, A_DC1  ; CTRL-C
    dt A_JU, A_LF   ; CTRL-J
    dt A_MU, A_CR   ; CTRL-M
    dt A_BKSP,A_DC2 ; CTRL-BACKSPACE
    dt A_GU,A_BEL   ; CTRL-G
    dt VK_UP,VK_CUP  ; <CTRL>-<UP>
    dt VK_DOWN,VK_CDOWN ; <CTRL>-<DOWN>
    dt VK_LEFT,VK_CLEFT ; <CTRL>-<LEFT>
    dt VK_RIGHT,VK_CRIGHT ; <CTRL>-<RIGHT>
    dt VK_HOME,VK_CHOME ; <CTRL>-<HOME>
    dt VK_END,VK_CEND ; <CTRL>-<END>
    dt VK_PGUP,VK_CPGUP ; <CTRL>-<PGUP>
    dt VK_PGDN,VK_CPGDN ; <CTRL>-<PGDN>
    dt 0
    
   end
   


