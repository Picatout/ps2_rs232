;NOM: ps2_rs232
;DESCRIPTION: adapteur de clavier PS/2 vers RS232 TTL. 
;   le MCU PIC12F1572 lit les codes du clavier et les convertis en codes ASCII
;   pour les retransmettre via le EUSART. 
;CRÉATION:  2016-12-22
;AUTEUR: Jacques Deschênes, Copyright 2016
;REF:
;   http://www.computer-engineering.org/ps2protocol/  
;   http://www.computer-engineering.org/ps2keyboard/scancodes2.html    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
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
    
#define DEBUG    
    
    include p12f1572.inc
    include ascii.inc
    include ps2_codes.inc
    
    extern std_codes,xt_codes,table_shifted,table_altchar,table_control
    
    __config _CONFIG1, _FOSC_INTOSC&_WDTE_OFF
    __config _CONFIG2, _LVP_OFF&_PLLEN_OFF
    
    radix dec
    
FOSC equ 4000000 ; 4Mhz 
FCY  equ 1000000 ; 1Mhz
BAUD equ 9600

NRST equ RA5
TX equ RA4
CLK equ RA2
DAT equ RA1

#define HEAD_PTRL FSR0L
#define HEAD_PTRH FSR0H
#define QUEUE_HEAD INDF0 
#define TAIL_PTRL FSR1L
#define TAIL_PTRH FSR1H 
#define QUEUE_TAIL INDF1
 
; indicateurs booléens pour kbd_state
F_SCRLL equ	0 ; scroll lock kbd_leds
F_NUM equ	1 ; numlock dans kbd_leds
F_CAPS equ	2 ; capslock dans kbd_leds
F_SHIFT equ	3  ; shift dans kbd_leds
F_CTRL equ	4  ; touche CTRL droite ou gauche enfoncée
F_ALT equ	5  ; touche ALT enfoncée
F_ACK	equ	6  ;  mis à 1 par réception d'un code ACK
F_BATOK equ	7  ; mis à 1 par réception d'un code BAT_OK	
	
; indicateurs booléens pour rxflags 
F_XT equ	1    
F_REL equ	2

 
;;;;;;;;;;;;;;;;;;;;
;   macros
;;;;;;;;;;;;;;;;;;;;
 
case macro n, label
    xorlw n
    skpnz
    bra label
    xorlw n
    endm
    
search macro table
    movwf t0
    clrf t1
    call table
    endm
 
queue  udata 0x20
in_queue res 16  ; file en réception codes clavier
 
    udata_shr 0x70
qhead res 1  ; pointeur de tête file in_queue
qtail res 1  ; pointeur de queue file in_queue
bitcntr res 1  ; compteur de bits réception du clavier
in_byte res 1  ; construction de l'octeten réception du clavier
parity res 1   ; contrôle de la parité sur code reçu de clavier
cmd res 1      ; octet à envoyer au clavier
kbd_state res 1; états des touches d'alteration du clavier
rxflags res 1  ; indicateur booléens utilisés pour la conversion des caractères
t0 res 1    ; registre temporaire
t1 res 1    ; registre temporaire
 
    org 0
;;;;;;;;;;;;;;;;;;;;;;
;  point d'entrée
;  réinitialisation
;  du MCU
;;;;;;;;;;;;;;;;;;;;;;;    
rst:
    banksel ANSELA
    clrf ANSELA
    goto init
    nop
    
    org 4
;;;;;;;;;;;;;;;;;;;;;;;;;
; service d'intterruption
;;;;;;;;;;;;;;;;;;;;;;;;;    
; cette interruption est déclenchée
; lorsque le signal clock du clavier
; passe à 0.    
; chaque interruption reçoit
; 1 bit du clavier
; lorsque la réception d'un octet est
; complétée s'il n'y a pas d'erreur
; de réception l'octet sauvegardé 
; dans la file 'in_queue'    
isr:    
    banksel IOCAF
    movlw 255
    xorwf IOCAF,W
    andwf IOCAF,F
;    bcf INTCON,IOCIF
    banksel PORTA
    movfw bitcntr
    skpnz
    bra start_bit
    xorlw 2
    skpnz
    bra parity_bit
    movfw bitcntr
    xorlw 1
    skpnz
    bra stop_bit
    lsrf in_byte,F
    btfss PORTA,DAT
    bra $+3
    bsf in_byte,7
    incf parity,F
    bra isr_exit
parity_bit:
    btfsc PORTA,DAT
    incf parity,F
    bra isr_exit
stop_bit:
    btfss PORTA,DAT
    bra isr_exit ; erreur de réception, code non retenu.
parity_check:  
    btfss parity,0
    bra isr_exit ; erreur de parité, code non retenu.
    movlw BAT_OK
    xorwf in_byte,W
    skpz
    bra $+3
    bsf kbd_state,F_BATOK
    bra isr_exit
    movlw KBD_ACK
    xorwf in_byte,W
    skpz
    bra $+3
    bsf kbd_state,F_ACK
    bra isr_exit
    movlw KBD_RESEND
    xorwf in_byte,W
    skpz
    bra $+3
    bcf kbd_state,F_ACK
    bra isr_exit
    movlw in_queue
    movwf TAIL_PTRL
    movfw qtail
    addwf TAIL_PTRL,F
    movfw in_byte
    movwf QUEUE_TAIL
    incf qtail,F
    movlw 15
    andwf qtail,F
    bra isr_exit
start_bit:
    clrf parity
    movlw 11
    movwf bitcntr
isr_exit:
    decf bitcntr,F
    retfie

;uart_send
; envoie le contenu de WREG via 
; le périphérique EUSART    
uart_send:
    banksel TXSTA
    btfss TXSTA,TRMT
    bra $-1
    movwf TXREG
    return
    
;to_hex
; convertie le digit 
;qui est dans WREG en
;caractère hexadécimal
to_hex:
    addlw '0'
    movwf t1
    movlw '9'+1
    subwf t1,W
    skpnc
    addlw 7
    addlw '9'+1
    return

#ifdef DEBUG    
;send_hex
;envoie WREG en hexadécimal via EUSART    
hex_send:
    movwf t0
    movlw 0xf0
    andwf t0,W
    swapf WREG
    call to_hex
    call uart_send
    movlw 0xf
    andwf   t0,W
    call to_hex
    call uart_send
    movlw 32
    call uart_send
    return
#endif
    
;micro_delay
; boucle de délais 
; entrée: WREG délais en multiple de 3 µSec
;   TCY=1µsec on a 4 µsec d'overhead  call/return         
micro_delay:
    decfsz WREG
    bra $-1
    return

wait_kbd_clock:
    banksel PORTA
    btfss PORTA,CLK
    bra $-1
    btfsc PORTA,CLK
    bra $-1
    return
    
;kbd_send
;envoie un octet au clavier
; argument:
;  WREG: octet à envoyer
; sortie:
;   rien    
kbd_send:
    movwf cmd
    movlw 8
    movwf bitcntr
    bcf INTCON,IOCIE ; blocage des interruptions
    clrf parity
; prise de contrôle de l'interface PS/2
; par le MCU    
    banksel TRISA
    bcf TRISA, CLK
    banksel LATA
    bcf LATA,CLK
    movlw 150/3 ; délais 150µsec
    call micro_delay
    banksel TRISA
    bcf TRISA, DAT
    banksel LATA
    bcf LATA,DAT  ; start bit
    banksel TRISA
    bsf TRISA,CLK ; relâche la ligne clock
kbd_send_loop:
    call wait_kbd_clock
    bcf PORTA,DAT
    btfss cmd,0
    bra $+3
    bsf PORTA,DAT
    incf parity,F
    lsrf cmd,F
    decfsz bitcntr
    bra kbd_send_loop
; envoie paritée    
    call wait_kbd_clock
    bcf PORTA,DAT
    btfss parity,0
    bsf PORTA,DAT
    call wait_kbd_clock
;envoie stop bit    
    banksel TRISA
    bsf TRISA,DAT ; relâche ligne data
    banksel PORTA  
    btfss PORTA,CLK
    bra $-1
    movlw (1<<DAT)|(1<<CLK)
    movwf t0
;attend bit ack DAT et CLK à zéro 
    movfw t0
    andwf PORTA,W
    skpz
    bra $-3
;attend relâchement des lignes    
    movfw t0
    andwf PORTA,W
    xorwf t0,W
    skpz
    bra $-4
; réactive interruption
    banksel IOCAF
    clrf IOCAF
    bsf INTCON,IOCIE
    return

;set_leds
;contrôle les LEDs du clavier
set_leds:
    movlw KBD_LED
    bcf kbd_state,F_ACK
    call kbd_send
    btfss kbd_state,F_ACK
    bra $-1
    bcf kbd_state,F_ACK
    movlw 7
    andwf kbd_state,W
    call kbd_send
    btfss kbd_state,F_ACK
    bra $-1
    return

;signal_reset
; la combinaison de touches
; <CTRL>+<ALT>+<DEL> a été enfoncée.
; la broche NRST est mise à zéro
; pour 100µSec pour signaler à l'hôte
; une demande de réinitialisation    
signal_reset:
    banksel PORTA
    bcf PORTA, NRST
    movlw 25
    nop
    decfsz WREG
    goto $-2
    bsf PORTA, NRST
    return
    
    
; attend la séquence des codes PAUSE    
get_pause: 
    movlw 8
    movwf t0
wait_code:
    movfw qhead
    xorwf qtail,W
    skpnz
    bra wait_code
    incf qhead,F ;jette le code
    movlw 15
    andwf qhead,F
    decfsz  t0
    bra wait_code
    movlw VK_PAUSE
    call uart_send
    decf qhead,F
    return

    
;_shifted
; retourne le caractère de la touche lorsque SHIFT est enfoncée
; entrée: WREG=caractère non shifté    
; sortie: WREG=caractère shifté|0    
_shifted:
    movfw t1
    incf t1,F
    call table_shifted
    movf WREG,F
    skpnz
    return ; pas dans cette table
    xorwf t0,W
    skpnz
    bra shifted_found
    incf t1,F
    bra _shifted
shifted_found:
    movfw t1
    call table_shifted
    return
    
_altchar:
    movfw t1
    incf t1,F
    call table_altchar
    movf WREG,F
    skpnz
    return ; pas dans cette table
    xorwf t0,W
    skpnz
    bra altchar_found
    incf t1,F
    bra _altchar
altchar_found:
    movfw t1
    call table_altchar
    return
    

_control:
    movfw t1
    incf t1,F
    call table_control
    movf WREG,F
    skpnz
    return
    xorwf t0,W
    skpnz
    bra control_found
    incf t1,F
    bra _control
control_found:
    movfw t1
    call table_control
    return
    
    
;alpha
;vérifie si WREG est une lettre {'A'..'Z'}
; sortie:
;   C=1 -> alpha
;   C=0 -> non alpha    
alpha:
    movwf t0
    movlw 'A'
    subwf t0,W
    skpc
    bra not_alpha
    movfw t0
    sublw 'Z'
not_alpha:
    movfw t0
    return

;if_shifted
; vérifie l'état de F_CAPS et F_SHIFT
; et applique la transformation requise
; au contenu de WREG
; entré: WREG contient le caractère
; sortie: WREG contient le caractère modifié (si requis)
if_shifted:
    call alpha
    skpnc
    bra letter
    btfss kbd_state,F_SHIFT
    return
    search _shifted
    return
letter:
    btfsc kbd_state,F_SHIFT
    bra shift_on
    btfss kbd_state,F_CAPS
    addlw 32
    return
shift_on:
    btfsc kbd_state,F_CAPS
    addlw 32
    return

;translate
; converti le scancode en valeur ASCII ou touche virtuelle
; entrée: WREG=scancode    
translate:
    movwf t0
    clrf t1
trans_loop:
    movfw t1
    incf t1,F
    btfss rxflags,F_XT
    call std_codes
    btfsc rxflags,F_XT
    call xt_codes
    skpnz
    return ; not found
    xorwf t0,W
    skpnz
    bra found
    incf t1,F
    bra trans_loop
found:
    movfw t1
    btfss rxflags,F_XT
    call std_codes
    btfsc rxflags,F_XT
    call xt_codes
    return
    
;code_convert
; conversion code clavier
; vers code ASCII
; argument:
;  code dans in_queue
; sortie:
;   code ASCII dans out_queue
code_convert:
    movlw in_queue
    movwf HEAD_PTRL
    movfw qhead
    addwf HEAD_PTRL
    movfw QUEUE_HEAD
    case KEY_REL, key_release
    case XT_KEY, xkey
    case XT2_KEY, pkey
    call translate
    skpnz
    bra ignore_code
    case VK_LSHIFT, shiftkey
    case VK_RSHIFT, shiftkey
    case VK_CAPS, capskey
    case VK_LCTRL, ctrlkey
    case VK_RCTRL, ctrlkey
    case VK_LALT, altkey
    case VK_RALT, altkey
    case VK_NUM, numkey
    case A_DEL, delete
    btfsc rxflags,F_REL
    bra ignore_code
    btfsc kbd_state,F_CTRL
    bra ctrl_down
    btfsc kbd_state,F_ALT
    bra alt_down
    call if_shifted
    call uart_send
    bra clear_flags
delete:
    btfsc kbd_state,F_CTRL
    btfss kbd_state,F_ALT
    bra $-4
    call signal_reset
    bra clear_flags
ctrl_down:
    search _control
    skpz
    call uart_send
    bra clear_flags
alt_down:
    search _altchar
    skpz
    call uart_send
    bra clear_flags
ctrlkey:
    bcf kbd_state, F_CTRL
    btfss rxflags, F_REL
    bsf kbd_state,F_CTRL
    bra clear_flags
altkey:
    bcf kbd_state, F_ALT
    btfss rxflags, F_REL
    bsf kbd_state,F_ALT
    bra clear_flags
capskey: ; touche verr. majuscule
    btfsc rxflags, F_REL
    bra clear_flags
    movlw 1<<F_CAPS
    xorwf kbd_state,F
    call set_leds
    bra clear_flags
numkey:
    btfsc rxflags, F_REL
    bra clear_flags
    movlw 1<<F_NUM
    xorwf kbd_state,F
    call set_leds
    bra clear_flags
shiftkey: ; touche shift droite|gauche
    bcf kbd_state,F_SHIFT
    btfss rxflags,F_REL
    bsf kbd_state,F_SHIFT
    bra clear_flags
key_release: ; touche relâchée
    bsf rxflags, F_REL
    bra code_done
pkey: ; PAUSE key   
    call get_pause
    bra code_done
xkey: ; extended key
    bsf rxflags, F_XT
    bra code_done
clear_flags:    
ignore_code:
    bcf rxflags,F_REL
    bcf rxflags,F_XT
code_done:
    incf qhead,F
    movlw 15
    andwf qhead,F
    return
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; initialisation matérielle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
init:
; configure Fosc à 4Mhz
    banksel OSCCON
    movlw 0xD<<IRCF0 ; 1Mhz x 4 (PLL)
    movwf OSCCON
    banksel LATA
    bsf LATA, NRST
; configure TX sur la broche RA4    
    banksel APFCON
    bsf APFCON, TXCKSEL
    banksel TRISA
    bcf TRISA, TX
    bcf TRISA, NRST
; configuration du EUSART
; mode asynchrone 9600 BAUD
; communication à sens unique    
    banksel SPBRG
    bsf BAUDCON, BRG16
    movlw ((FOSC/16/BAUD)&0xff)-1
    movwf SPBRGL
    movlw (FOSC/16/BAUD-1)>>8
    movwf SPBRGH
    bsf TXSTA,TXEN
    bsf RCSTA, SPEN
; configuration interruption sur broche CLK
; pour produire une interruption sur
; la transistion descendante.
    banksel IOCAN
    bsf IOCAN,CLK
    banksel INTCON
; les broches associées au clavier sont
; sont configurées Open Drain    
    banksel ODCONA
    bsf ODCONA, CLK
    bsf ODCONA, DAT
; on désactive les pullup sur CLK et DAT.
; pullup externes.    
    banksel WPUA
    movlw ~((1<<CLK)|(1<<DAT))
    movwf WPUA
; raz ram
    movlw 0x20
    movwf FSR0L
    clrf FSR0H
    movlw 96
    clrf INDF0
    incf FSR0L,F
    decfsz WREG
    bra $-3
; initialisation des variables
    clrf  HEAD_PTRH
    clrf  TAIL_PTRH
    movlw in_queue
    movwf HEAD_PTRL
    movwf HEAD_PTRL
; activation des interruptions
    bcf INTCON, IOCIF
    bsf INTCON,IOCIE
    bsf INTCON,GIE
;envoie une commande de réinitialisation au clavier
    movlw KBD_RESET
    call kbd_send
; attend réception ACK
    btfss kbd_state,F_ACK
    bra $-1
; attend réception BAT_OK
    btfss kbd_state,F_BATOK
    bra $-1
    call set_leds
#ifdef DEBUG    
test:    
    movlw 'O'
    call uart_send
    movlw 'K'
    call uart_send
    movlw '\r'
    call uart_send
    movlw '\n'
    call uart_send
#endif
    
;;;;;;;;;;;;;;;;;;;    
; boucle principale
;;;;;;;;;;;;;;;;;;;    
main:
;s'il y a des caractères dans la 
; file les envoyer via l'EUSART
    movfw qhead
    xorwf qtail,W
    skpnz
    bra main
;#define SHOW_HEX    
#ifdef SHOW_HEX
    movlw in_queue
    movwf HEAD_PTRL
    movfw qhead
    addwf HEAD_PTRL
    movfw QUEUE_HEAD
    call hex_send
    incf qhead,F
    movlw 15
    andwf qhead,F
    bra main
#else    
    call code_convert
#endif    
    bra main
    

    end

    