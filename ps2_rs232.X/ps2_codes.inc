;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;NOM: ps2_rs232
;DESCRIPTION: adapteur de clavier PS/2 vers RS232 TTL. 
;   le MCU PIC12F1572 lit les codes du clavier et les convertis en codes ASCII
;   pour les retransmettre via le EUSART. 
;CRÉATION:  2016-12-22
;AUTEUR: Jacques Deschênes, Copyright 2016
;This file is part of ps2_rs232.
;REF:
;   http://www.computer-engineering.org/ps2protocol/  
;   http://www.computer-engineering.org/ps2keyboard/scancodes2.html    
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

; scancode clavier PS/2
    radix dec
    
; commandes contrôle clavier
KBD_RESET equ	0xFF  ; commande RAZ clavier
KBD_LED equ	0xED  ; commande de contrôle des LEDS du clavier
KBD_RESEND equ  0xFE  ; demande de renvoie de la commande ou le code clavier
 
; codes d'état du clavier
BAT_OK equ	0xAA ; test clavier réussi
KBD_ACK equ	0xFA ; confirmation réception (envoyé par le clavier)
KEY_REL equ	0xF0 ; touche relâchée 
XT_KEY equ	0xE0 ; touche étendue
XT2_KEY equ	0xE1 ; débute séquence de 8 caractère touche PAUSE
 
; touches de contrôle 
SC_TAB equ	    0x0D    ;standard
SC_ENTER equ	    0x5A    ;standard
SC_CAPS equ	    0x58    ;standard
SC_NUM equ	    0x77    ;standard
SC_SCROLL   equ	    0x7E    ;standard
SC_LSHIFT equ	    0x12    ;standard
SC_RSHIFT equ	    0x59    ;standard
SC_LCTRL equ	    0x14    ;standard
SC_LALT equ	    0x11    ;standard
SC_BKSP equ	    0x66    ;standard
SC_ESC equ	    0x76    ;standard
SC_F1 equ	    0x05    ;standard
SC_F2 equ	    0x06    ;standard
SC_F3 equ	    0x04    ;standard
SC_F4 equ	    0x0c    ;standard
SC_F5 equ	    0x03    ;standard
SC_F6 equ	    0x0b    ;standard
SC_F7 equ	    0x83    ;standard
SC_F8 equ	    0x0a    ;standard
SC_F9 equ	    0x01    ;standard
SC_F10 equ	    0x09    ;standard
SC_F11 equ	    0x78    ;standard
SC_F12 equ	    0x07    ;standard
SC_KPMUL equ	    0x7c    ;standard
SC_KPMINUS equ	    0x7b    ;standard
SC_KPPLUS equ	    0x79    ;standard
SC_KPDOT equ	    0x71    ;standard
SC_KP0 equ	    0x70    ;standard
SC_KP1 equ	    0x69    ;standard
SC_KP2 equ	    0x72    ;standard
SC_KP3 equ	    0x7a    ;standard
SC_KP4 equ	    0x6b    ;standard
SC_KP5 equ	    0x73    ;standard
SC_KP6 equ	    0x74    ;standard
SC_KP7 equ	    0x6c    ;standard
SC_KP8 equ	    0x75    ;standard
SC_KP9 equ	    0x7d    ;standard

; codes étendus. i.e. précédés de 0xe0
SC_RCTRL equ   0x14
SC_LGUI equ    0x1f
SC_RGUI equ    0x27 
SC_RALT equ    0x11
SC_APPS equ    0x2f
SC_UP	 equ    0x75
SC_DOWN equ    0x72
SC_LEFT equ    0x6B
SC_RIGHT equ   0x74
SC_INSERT equ  0x70
SC_HOME equ    0x6c
SC_PGUP equ    0x7d
SC_PGDN equ    0x7a
SC_DEL	 equ    0x71
SC_END	 equ    0x69
SC_KPDIV equ   0x4a
SC_KPENTER equ 0x5a
 
 
;sécquence de codes 
#define SC_PRN	    0xe0,0x12,0xe0,0x7c
#define SC_PRN_REL  0xe0,0xf0,0x7c,0xe0,0xf0,0x12 
#define SC_PAUSE    0xe1,0x14,0x77,0xe1,0xf0,0x14,0xf0,0x77

 
;touches virtuelles
VK_BACK equ	8
VK_TAB equ	9
VK_ESC equ	27
VK_ENTER equ	'\r'
VK_SPACE equ	' ' 
VK_DELETE equ	127 
VK_F1 equ	128
VK_F2 equ	129
VK_F3 equ	130
VK_F4 equ	131
VK_F5 equ	132
VK_F6 equ	133
VK_F7 equ	134
VK_F8 equ	135
VK_F9 equ	136
VK_F10 equ	138
VK_F11 equ	139
VK_F12 equ	140
VK_UP equ	141
VK_DOWN equ	142
VK_LEFT equ	143
VK_RIGHT equ	144
VK_HOME equ	145
VK_END equ	146
VK_PGUP equ	147
VK_PGDN equ	148
VK_INSERT equ	149
VK_APPS equ	151
VK_PRN	equ	152
VK_PAUSE equ	153
VK_NLOCK equ    154 ; numlock
VK_CLOCK equ	155 ; capslock
VK_LSHIFT equ	156
VK_LCTRL equ	157
VK_LALT equ	158
VK_RSHIFT equ	159
VK_LGUI equ	160
VK_RCTRL equ	161
VK_RGUI equ	162
VK_RALT equ	163
VK_SCROLL equ	164
VK_NUM	equ	165 
VK_CAPS equ	168
;<SHIFT>-<KEY> 
VK_SUP	equ	169
VK_SDOWN equ	170
VK_SLEFT equ	171
VK_SRIGHT equ	172
VK_SHOME equ	173
VK_SEND	equ	174
VK_SPGUP equ	175
VK_SPGDN equ	176
;<CTRL>-<KEY>
VK_CUP	equ	177
VK_CDOWN equ	178	
VK_CLEFT equ	179
VK_CRIGHT equ	180
VK_CHOME equ	181
VK_CEND equ	182
VK_CPGUP equ	183
VK_CPGDN equ	184
 
