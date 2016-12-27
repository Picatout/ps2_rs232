# ps2_rs232
utilisation d'un PIC12F1572 pour interfacer un clavier PS/2 avec sortie RS232 en niveau logique.

## détail
Pour éviter d'avoir à refaire le travail à chaque fois que j'utilise un clavier PS/2 dans un
projet de microcontrôleur, ce module peut y être intégré à faible coût. Il prend en charge l'interface avec
le clavier ainsi que la conversion des codes claviers en codes ASCII. Les touches qui n'ont 
pas de correspondance dans le code ASCII renvoient un code d'une valeur supérieur à 127.

Les relâchements de touches sont ignorés. Les touches ALT,CTRL,SHIFT,NUM et CAPS sont traîtées
par le PIC12F1572 aucun code n'est retransmis pour ces touches.

## codes des touches virtuelles

touche | nom | code
-------|-----|------
F1 | VK_F1 | 128
F2 | VK_F2 | 129
F3 | VK_F3 | 130
F4 | VK_F4 | 131
F5 | VK_F5 | 132
F5 | VK_F6 | 133
F7 | VK_F7 | 134
F8 | VK_F8 | 135
F9 | VK_F9 | 136
F10 | VK_F10 | 138
F11 | VK_F11 | 139
F12 | VK_F12 | 140
flèche haut | VK_UP | 141
flèche bas | VK_DOWN | 142
flèche gauche | VK_LEFT | 143
flèche droite | VK_RIGHT | 144
début | VK_HOME | 145
fin | VK_END | 146
page préc. | VK_PGUP | 147
page suiv. | VK_PGDN | 148
insert | VK_INSERT | 149
efface | VK_DELETE | 150
appli. | VK_APPS | 151
impr. | VK_PRN | 152
pause | VK_PAUSE | 153



