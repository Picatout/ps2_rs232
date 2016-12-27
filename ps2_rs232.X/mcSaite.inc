; table scancode vers ASCII pour clavier MCSaite
    include ps2_codes.inc
    
    ;table des codes correspondant à un caractère ASCII    
ascii:
   brw
   dt 0x1c,'A' 
   dt 0x32,'B'
   dt 0x21,'C'
   dt 0x23,'D'
   dt 0x24,'E'
   dt 0x2b,'F'
   dt 0x34,'G'
   dt 0x33,'H'
   dt 0x43,'I'
   dt 0x3B,'J'
   dt 0x42,'K'
   dt 0x4b,'L'
   dt 0x3a,'M'
   dt 0x31,'N'
   dt 0x44,'O'
   dt 0x4d,'P'
   dt 0x15,'Q'
   dt 0x2d,'R'
   dt 0x1b,'S'
   dt 0x2c,'T'
   dt 0x3c,'U'
   dt 0x2a,'V'
   dt 0x1d,'W'
   dt 0x22,'X'
   dt 0x35,'Y'
   dt 0x1a,'Z'
   dt 0x45,'0'
   dt 0x16,'1'
   dt 0x1e,'2'
   dt 0x26,'3'
   dt 0x25,'4'
   dt 0x2e,'5'
   dt 0x36,'6'
   dt 0x3d,'7'
   dt 0x3e,'8'
   dt 0x46,'9'
   dt 0x0e,'`'
   dt 0x4e,'-'
   dt 0x55,'='
   dt 0x5d,'\\'
   dt 0x54,'['
   dt 0x5b,']'
   dt 0x4c,';'
   dt 0x52,'\''
   dt 0x41,','
   dt 0x49,'.'
   dt 0x7c,'*'
   dt 0x79,'+'
   dt 0x29,' '
   dt SC_ENTER,'\r'
   dt SC_BKSP,8
   dt SC_TAB,9
   dt SC_ESC,27
   dt SC_KP0,'0'
   dt SC_KP1,'1'
   dt SC_KP2,'2'
   dt SC_KP3,'3'
   dt SC_KP4,'4'
   dt SC_KP5,'5'
   dt SC_KP6,'6'
   dt SC_KP7,'7'
   dt SC_KP8,'8'
   dt SC_KP9,'9'
   dt SC_KPMUL,'*'
   dt SC_KPDIV,'/'
   dt SC_KPPLUS,'+'
   dt SC_KPMINUS,'-'
   dt SC_KPDOT,'.'
   dt SC_KPENTER,'\r'
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
   dt 0
   
;table des caractères avec touche SHIFT enfoncée
shifted:
   brw
   dt '1','!'
   dt '2','@'
   dt '3','#'
   dt '4','$'
   dt '5','%'
   dt '6','^'
   dt '7','&'
   dt '8','*'
   dt '9','('
   dt '0',')'
   dt '-','_'
   dt '=','+'
   dt '`','~'
   dt '\'','"'
   dt ',','<'
   dt '.','>'
   dt '/','?'
   dt '\\','|'
   dt ';',':'
   dt '[','{'
   dt ']','}'
   dt 0
   
;table des caractères avec touche ALTCHAR enfoncée
altchar:
   brw
   dt '1','\\'
   dt '2','@'
   dt '3','/'
;   dt '4','¢'
;   dt '5','¤'
   dt '6','?'
   dt '7','|'
;   dt '8','²'
   dt '9','{'
   dt '0','}'
;   dt '-','½'
;   dt '=','¾'
   dt 0
   
;; codes étendus
extended:
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
    dt SC_DEL,VK_DELETE
    dt SC_END,VK_END
    dt SC_KPDIV,'/'
    dt SC_KPENTER,'\r'
    dt 0x12,VK_PRN
    dt 0x7c,0
    dt 0
    
; codes spéciaux
special:
   brw
   dt SC_PRN, VK_PRN
   dt SC_PAUSE,VK_PAUSE
   dt 0
   
; code des touches de contrôles  
controls:
   brw
   dt SC_LGUI,VK_LGUI
   dt SC_RCTRL,VK_RCTRL
   dt SC_RGUI,VK_RGUI
   dt SC_RALT,VK_RALT
   dt SC_APPS,VK_APPS
   dt SC_INSERT,VK_INSERT
   dt SC_HOME,VK_HOME
   dt SC_PGUP,VK_PGUP
   dt SC_DEL,VK_DELETE
   dt SC_END,VK_END
   dt SC_PGDN,VK_PGDN
   dt SC_UP,VK_UP
   dt SC_LEFT,VK_LEFT
   dt SC_DOWN,VK_DOWN
   dt SC_RIGHT,VK_RIGHT
   dt SC_KPDIV,'/'
   dt SC_ENTER,VK_ENTER
   dt SC_LSHIFT,VK_LSHIFT
   dt SC_LCTRL,VK_LCTRL
   dt SC_LALT,VK_LALT
   dt SC_RSHIFT,VK_RSHIFT
   dt SC_KPENTER,VK_ENTER
   dt SC_ESC,VK_ESC
   dt SC_NUM,VK_NLOCK
   dt SC_CAPS,VK_CLOCK
   dt 0


