INCLUDE irvine32.inc
INCLUDELIB Irvine32.lib
INCLUDE macros.inc
INCLUDELIB user32.lib
INCLUDELIB winmm.lib
INCLUDELIB kernel32.lib

TITLE MASM PlaySound
	PlaySound PROTO,
	pszSound: PTR BYTE,
	hmod: DWORD,
	fdwSound: DWORD

.data
;file handling 
scoreFile db "C:\Users\s9010\Desktop\zuma\scores.txt", 0
scoreFile1 db "C:\Users\s9010\Desktop\zuma\scores1.txt", 0
fileHandle HANDLE ?
BUFSIZE = 5000
buffer BYTE BUFSIZE DUP(?)
bytesRead DWORD ?

n1 db 20 dup(?)
n2 db 20 dup(?)
n3 db 20 dup(?)

scr1 db 10 dup(?)
scr2 db 10 dup(?)
scr3 db 10 dup(?)

numscr1 dw ?
numscr2 dw ?
numscr3 dw ?

temp byte ?
temporary dw ?
temp2 dd ?
temp3 byte ?
addressTemp dd ?

HighScores db "HIGHSCORES:",13,10,0

;sound
    SND_FILENAME DWORD 00020000h
    SND_ASYNC DWORD 1H
    soundfile db "bgsound.wav", 0

;moving balls
    BALLS STRUCT
        x_pos db ?
        y_pos db ?
        color db ?  ;
        direction db ? ; 0 for right, 1 for down, 2 for left, 3 for up
        exists db ?
    BALLS ENDS

    ;array of balls
        ballsArray BALLS 20 dup(<>)
        ballsCount db 0
        ballPointer dd ? ;for storing current address

    ;level 1 rectangle 
        yPoint3 db 7  ; y position
        xPoint3 db 30   ;x position

        yPoint1 db 23
        xPoint1 db 90

        yEndp db 7
        xEndp db 79

        yPoint2 db  23
        xPoint2 db  30
;visual components
        STARS_ART    db '     .              *     .               *             .         . *            *            .                              .   .      *',13,10
                     db ' *    .  *       .             *    .      *         *    .          .              *            *   .*        .        *              .',13,10
                     db '                         *                    *               *               .              .                 *     .                  ',13,10            
                     db ' *   .        *       .       .       *             .         .    *             *                       .             .         .    *  ',13,10
                     db 0
            
        STARS_ART2   db '   .     *       .                   .         *        .        *              .         *       .          *   .               .       ',13,10
                     db '           .     .  *        *                    .               .        *       .         .       .        . *                    .   ',13,10
                     db '       .                .        .         .           *    .                         .            *             *        .        *     ',13,10
                     db '.  *           *                     *      *                       .       *               *           .   .   .               .         ',13,10
                     db '                             .                          *     .                   .       .                  *   .               .        ',13,10
                     db 0

        ZUMA_ART     db '  *.                .       * .       *  .  ______     __  __     __    __     ______      *   .        .         .        * ',13,10
                     db '    .      .             .        *      . /\___  \   /\ \/\ \   /\ "-./  \   /\  __ \  .        *             .      .          *   ',13,10
                     db '            *             .    .           \/_/  /__  \ \ \_\ \  \ \ \-./\ \  \ \  __ \       .    *          .    .          .  ',13,10
                     db '       *          .     *      .      .      /\_____\  \ \_____\  \ \_\ \ \_\  \ \_\ \_\               .    *           *      ',13,10    
                     db '    .        .           .           *       \/_____/   \/_____/   \/_/  \/_/   \/_/\/_/     *         .            .       *   .',13,10
                     db '       *     *                                                                                  ',13,10
                     db 0

        HOUSE_ART      db  "   .             .      *     .       .        .      .              .                    )               (_) ^'^" ,13,10
                       db "      .         .          .           .          .     .    _/\_    .       .       .---------. ((        ^'^           " ,13,10
                       db "                  *                              *           (('>            * .     )`'`'`'`'`( ||                 ^'^  " ,13,10
                       db "   .   *    .        .          .         .             _    /^|        .           /`'`'`'`'`'`\||           ^'^        " ,13,10
                       db "  .         .                .          .        .      =>--/__|m---               /`'`'`'`'`'`'`\|                      "  ,13,10
                       db "                  .               *                          ^^           ,,,,,,, /`'`'`'`'`'`'`'`\      ,            " ,13,10
                       db " .                                                                       .-------.`|`````````````|`  .   )              " ,13,10
                       db "                      .                              .                  / .^. .^. \|  ,^^, ,^^,  |  / \ ((              " ,13,10
                       db "                                                                       /  |_| |_|  \  |__| |__|  | /,-,\||             " ,13,10
                       db "                wWWWw                wWWWw                  _         /_____________\ |')| |  |  |/ |_| \|             " ,13,10
                       db "          vVVVv (___)    wWWWw       (___) vVVVv          (`)         |  __   __  |  '==' '=='  /_______\     _      " ,13,10
                       db "          (___)  ~Y~     (___) vVVVv  ~Y~  (___)         (' ')        | /  \ /  \ |   _______   |,^, ,^,|    (`)      " ,13,10
                       db "           ~Y~   \|       ~Y~  (___)   |/   ~Y~           \  \        | |--| |--| |  ((--.--))  ||_| |_||   (' ')     " ,13,10
                       db "           \|   \ |/      \| / \~Y~/  \|   \ |/         _  ^^^ _      | |__| |('| |  ||  |  ||  |,-, ,-,|   /  /     " ,13,10
                       db " \\|// \\|// \\|// \\|// \\|// \\|// \\|// \\|//      ,' ',  ,' ',    |           |  ||  |  ||  ||_| |_||   ^^^        " ,13,10
                       db "     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^.,,|RIP|,.|RIP|,.,,'==========='==''=='==''=='=======',,....,,,,.,^^^^^^^^^^^^^^^^^^^^" ,13,10
                       db "                                                                                                                                    ",13,10
                       db 0

               
LEADERBOARDD         db '         __         ______     ______     _____     ______     ______    ',13, 10
                    db '        /\ \       /\  ___\   /\  __ \   /\  __-.  /\  ___\   /\  == \   ',13, 10
                    db '        \ \ \____  \ \  __\   \ \  __ \  \ \ \/\ \ \ \  __\   \ \  __<   ',13, 10
                    db '         \ \_____\  \ \_____\  \ \_\ \_\  \ \____-  \ \_____\  \ \_\ \_\ ',13, 10
                    db '          \/_____/   \/_____/   \/_/\/_/   \/____/   \/_____/   \/_/ /_/ ',13, 10
                    db '                                                                             ',13, 10
                    db '                           ______     ______     ______     ______     _____               ',13, 10
                    db '                          /\  == \   /\  __ \   /\  __ \   /\  == \   /\  __-.             ',13, 10
                    db '                          \ \  __<   \ \ \/\ \  \ \  __ \  \ \  __<   \ \ \/\ \            ',13, 10
                    db '                           \ \_____\  \ \_____\  \ \_\ \_\  \ \_\ \_\  \ \____-            ',13, 10
                    db '                            \/_____/   \/_____/   \/_/\/_/   \/_/ /_/   \/____/            ',13, 10
                    db '                                                                                                                     ',13, 10            
                    db '                                                                                                          (_v_)       ',13, 10            
                    db '                                                                                                           _|_         ',13, 10           
                    db '                                                                                                           | |         ',13, 10           
                    db '                                                                                                      |-----+-----|    ',13, 10           
                    db '                                                                                                      |   MAIMA   |    ',13, 10           
                    db '                                                                                                      | IS SO COOL|     ',13, 10          
                    db '                                                                                                       `---------`      ',13, 10         
                    db '                                                                                                        \       /        ',13, 10         
                    db "                                                                                                         '.   .'         ",13, 10        
                    db '                                                                                                           | |           ',13, 10      
                    db "                                                                                                          .' '.         ",13, 10 
                    db '                                                                                                         _|___|_          ',13, 10        
                    db '                                                                                                        [#######]        ',13, 10
                    db '                                                                                                                     ',13, 10            
                    db '                                                                                                                     ',13, 10            
                    db '                                                                                                                     ',13, 10            
                    db '                                                                                                                     ',13, 10            
                    db '            Press "R" to return to the game. Press "Esc" to exit game                                                     ',13, 10
                    db 0



        walls BYTE " _____________________________________________________________________________ ", 0
              BYTE "|                                                                             |", 0
              BYTE "|                                                                             |", 0
              BYTE "|                                                                             |", 0
              BYTE "|                                                                             |", 0
              BYTE "|                                                                             |", 0
              BYTE "|                                                                             |", 0
              BYTE "|                                                                             |", 0
              BYTE "|                                                                             |", 0
              BYTE "|                                                                             |", 0
              BYTE "|                                    ---                                      |", 0
              BYTE "|                                   |   |                                     |", 0
              BYTE "|                                   |   |                                     |", 0
              BYTE "|                                   |   |                                     |", 0
              BYTE "|                                    ---                                      |", 0
              BYTE "|                                                                             |", 0
              BYTE "|                                                                             |", 0
              BYTE "|                                                                             |", 0
              BYTE "|                                                                             |", 0
              BYTE "|                                                                             |", 0
              BYTE "|                                                                             |", 0
              BYTE "|                                                                             |", 0
              BYTE "|                                                                             |", 0
              BYTE "|                                                                             |", 0
              BYTE "|_____________________________________________________________________________|", 0


           
        PAUSESCREEN  db '           .     .  *                         .               .        *       .         .       .        . *                    . ',13,10
                     db '       .                     .         .           *    .                         .            *             *        .        *   ',13,10
                     db '.  *           *                 *      *                       .       *               *           .   .   .     .         .      ',13,10
                     db '                         .                          *     .                   .       .                  *   .               .     ',13,10
                     db '     .          *     .               *             .         . *            *            .                              .         ',13,10
                     db ' *    .      .             *    .      *         *    .          .              *            *   .*           . *            *     ',13,10
                     db '                     *                    *               *               .              .                 *     .                 ',13,10            
                     db ' *        *       .       .       *             .         .    *             *                      . *            *            .  ',13,10
                     db '   . *       .                   .     * ______     ______     __    __     ______        .        *                 . *      ',13,10
                     db '       .     .  *        *              /\  ___\   /\  __ \   /\ "-./  \   /\  ___\ .               .        *       .        ',13,10
                     db '                    .        .         .\ \ \__ \  \ \  __ \  \ \ \-./\ \  \ \  __\      *    .                             . ',13,10
                     db '.  *       *                     *      *\ \_____\  \ \_\ \_\  \ \_\ \ \_\  \ \_____\                  .        . *           ',13,10
                     db '                         .                \/_____/   \/_/\/_/   \/_/  \/_/   \/_____/     *     .                  . .        ',13,10
                     db '                *     .               *             .         . *            *            .                             . *        ',13,10
                     db ' *          .             *    .      *              . *            *            .       *    .          .              *         .',13,10
                     db '                    *                    *               *               .              .                 *     .       . *       ',13,10            
                     db ' *       *       .       .        ______   ______     __  __     ______     ______     _____  .         .    *        . ',13,10
                     db '   .        .     .         *    /\  == \ /\  __ \   /\ \/\ \   /\  ___\   /\  ___\   /\  __-.       .            . *   ',13,10
                     db '      .     .  *        *        \ \  _-/ \ \  __ \  \ \ \_\ \  \ \___  \  \ \  __\   \ \ \/\ \ .                  . * ',13,10
                     db '                   .        .     \ \_\    \ \_\ \_\  \ \_____\  \/\_____\  \ \_____\  \ \____-     *    .              ',13,10
                     db '.  *      *       *      *         \/_/     \/_/\/_/   \/_____/   \/_____/   \/_____/   \/____/              . *       *',13,10
                     db '                 .                          *     .                   .       .                   . *            * .         . *   ',13,10
                     db '            *                          . *            *            .      *               *               .              .          ',13,10            
                     db ' *       .             *    .      *  Press "R" to return to the game. Press "Esc" to exit game  *    .            . *        .',13,10
                     db ' *          .       .       *             .         .    *             *                       . *            *            .       ',13,10
                     db '   . .                   .         *        .          . *            *            .          *              .         *       .    ',13,10
                     db '        .  *        *                    .               .        *       .         .              . *            *            .  .   ',13,10
                     db '             .        .         .           *          . *            *            .      .                         .            *    ',13,10
                     db '.  *                    . *            *            .             *      *                       .       *               *         ',13,10
                     db '                  .          . *            *            .                            *     .                   .       .           ',13,10
                     db '         *     .               *             .         . *            *        . *            *            .                .      *',13,10
                     db ' *    .             *    .      *         *    .          .                     . *            *            .     *            *    .',13,10
                     db '                         *                    *               *               .              .                 *     .             ',13,10            
                     db ' *   .        *       .       .       *             .         .    *             *                   . *            *            . ',13,10
                     db '   .     *       .                   .         *        . *            *            .            .        *              .        ',13,10
                     DB 0


        SPIDER      db '                                                                                                                (    ', 13, 10
                    db '                                                                                                                )    ', 13, 10
                    db '                                                                                                               (     ', 13, 10
                    db '                                                                                                                )    ', 13, 10
                    db '                                                                                                               )     ', 13, 10
                    db '                                                                                                               (    ', 13, 10
                    db '                                                                                                                )    ', 13, 10
                    db '                                                                                                                (    ', 13, 10
                    db '                                                                                                                )       ', 13, 10
                    db '                                                                                                                (       ', 13, 10
                    db '                                                                                                          /\  .-"""-.  /\     ', 13, 10
                    db '                                                                                                          //\\/  ,,,  \//\\        ', 13, 10
                    db '                                                                                                          |/\| ,;;;;;, |/\|        ', 13, 10
                    db '                                                                                                          //\\\;-"""-;///\\        ', 13, 10
                    db '                                                                                                         //  \/   .   \/  \\       ', 13, 10
                    db '                                                                                                        (| ,-_| \ | / |_-, |)      ', 13, 10
                    db '                                                                                                          //`__\.-.-./__`\\        ', 13, 10
                    db '                                                                                                         // /.-(() ())-.\ \\       ', 13, 10
                    db '                                                                                                        (\ |)   `---`   (| /)      ', 13, 10
                    db '                                                                                                       `  (|           |) `       ', 13, 10
                    db '                                                                                                          \)           (/         ', 13, 10
                    db 0

        SPIDER2 db "                   |                                                                     __    " , 13, 10
                db "                   |                                                                  | /  \ | ", 13, 10
                db "                   |                                                                 \_\\  //_/", 13, 10
                db "                   |                                                                  .'/()\'. ", 13, 10
                db "                   |                                                                   \\  //  ", 13, 10
                db 0
            
        SPIDERS3   db "                                                                                               __      _\( )/_" , 13, 10
                   db "                                                                                            | /  \ |    /(O)\ " , 13, 10
                   db "                                                                                           \_\\  //_/   _.._   _\(o)/_  //  \\", 13, 10
                   db "                                                                                            .'/()\'.  .'    '.  /(_)\  _\\()//_", 13, 10
                   db "                                                                                             \\  //  /   __   \       / //  \\ \", 13, 10
                   db "                                                                                                  ,  |   ><   |  ,     | \__/ |", 13, 10
                   db "                                                                                                 . \  \      /  / .              _"   , 13, 10
                   db "                                                                                                  \_'--`(  )'--'_/     __     _\(_)/_" , 13, 10
                   db "                                                                                                    .--'/()\'--.    | /  \ |   /(O)\", 13, 10
                   db "                                                                                                   /  /` '' `\  \  \_\\  //_/", 13, 10
                   db "                                                                                                     |        |      //()\\ ", 13, 10
                   db "                                                                                                      \      /       \\  //", 13, 10
                   db 0


        START     DB ' ______   ______  ______   ______   ______  ',13,10
                  DB '/\  ___\ /\__  _\/\  __ \ /\  == \ /\__  _\ ',13,10
                  DB '\ \___  \\/_/\ \/\ \  __ \\ \  __< \/_/\ \/ ',13,10
                  DB ' \/\_____\  \ \_\ \ \_\ \_\\ \_\ \_\  \ \_\ ',13,10
                  DB '  \/_____/   \/_/  \/_/\/_/ \/_/ /_/   \/_/ ',13, 10
                  DB 0   

        INSTRUCTIONS    DB ' __   __   __   ______   ______  ______   __  __   ______   ______  __   ______   __   __   ______  ',13,10
                        DB '/\ \ /\ "-.\ \ /\  ___\ /\__  _\/\  == \ /\ \/\ \ /\  ___\ /\__  _\/\ \ /\  __ \ /\ "-.\ \ /\  ___\   ',13,10
                        DB '\ \ \\ \ \-.  \\ \___  \\/_/\ \/\ \  __< \ \ \_\ \\ \ \____\/_/\ \/\ \ \\ \ \/\ \\ \ \-.  \\ \___  \ ',13,10
                        DB ' \ \_\\ \_\\"\_\\/\_____\  \ \_\ \ \_\ \_\\ \_____\\ \_____\  \ \_\ \ \_\\ \_____\\ \_\\"\_\\/\_____\ ',13,10
                        DB '  \/_/ \/_/ \/_/ \/_____/   \/_/  \/_/ /_/ \/_____/ \/_____/   \/_/  \/_/ \/_____/ \/_/ \/_/ \/_____/ ',13,10
                        DB 0
            
        EXITED           DB ' ______   __  __    __   ______   ',13,10
                         DB '/\  ___\ /\_\_\_\  /\ \ /\__  _\ ',13,10
                         DB '\ \  __\ \/_/\_\/_ \ \ \\/_/\ \/ ',13, 10
                         DB ' \ \_____\ /\_\/\_\ \ \_\  \ \_\ ',13,10
                         DB '  \/_____/ \/_/\/_/  \/_/   \/_/ ',13,10
                         DB 0
                     
        START_INFO DB "Press '1' for start, '2' for instructions ,and '3' to exit program." , 13, 10, 0
        POINTER            DB'  <<<<<<<<<<<<<<<<   ',13,10
                    DB 0
            
         INSTRUCTIONS_SCREEN db 'Controls:                                                                                        ',13,10
                             db '                                                                                                 ',13,10
                             db ' 1-Use the (w a s d) keys to move the Zuma frog left, right, up, or down.                        ',13,10
                             db ' 2-Press the spacebar to shoot a colored ball.                                                   ',13,10
                             db '                                                                                                 ',13,10
                             db 'Gameplay:                                                                                       ',13,10
                             db '                                                                                                 ',13,10
                             db ' 1-Match three or more balls of the same color to clear them from the track.                     ',13,10
                             db ' 2-Prevent the balls from reaching the skull by strategically clearing them.                     ',13,10
                             db ' 3-Special balls may appear, offering unique effects like explosions or slowing down the track.  ',13,10
                             db '                                                                                                 ',13,10
                             db 'Scoring:                                                                                        ',13,10
                             db '                                                                                                 ',13,10
                             db ' 1-Clearing more than three balls at once earns bonus points.                                    ',13,10
                             db ' 2-Chaining multiple clears in quick succession increases your score multiplier.                 ',13,10
                             db ' 3-Bonus points are awarded for completing levels quickly.                                       ',13,10
                             db '                                                                                                 ',13,10
                             db 'Game Over:                                                                                      ',13,10
                             db '                                                                                                 ',13,10
                             db ' 1-If any ball reaches the skull, the game ends.                                                ',13,10
                             db ' 2-Reaching the final level and clearing it completes the game.                                  ',13,10
                     db 0
        gameOverScreen db '  ______     ______     __    __     ______        ______     __   __   ______     ______        ',13,10  
                       db ' /\  ___\   /\  __ \   /\ "-./  \   /\  ___\      /\  __ \   /\ \ / /  /\  ___\   /\  == \         ',13,10
                       db ' \ \ \__ \  \ \  __ \  \ \ \-./\ \  \ \  __\      \ \ \/\ \  \ \ \/ /  \ \  __\   \ \  __<         ',13,10
                       db '  \ \_____\  \ \_\ \_\  \ \_\ \ \_\  \ \_____\     \ \_____\  \ \__|    \ \_____\  \ \_\ \_\       ',13,10
                       db '   \/_____/   \/_/\/_/   \/_/  \/_/   \/_____/      \/_____/   \/_/      \/_____/   \/_/ /_/       ',13,10
                       db 0

        player_right BYTE "   ", 0
                     BYTE " O-", 0
                     BYTE "   ", 0

        player_left BYTE "   ", 0
                    BYTE "-O ", 0                           
                    BYTE "   ", 0

        player_up BYTE " | ", 0
                  BYTE " O ", 0
                  BYTE "   ", 0

        player_down BYTE "   ", 0
                    BYTE " O ", 0
                    BYTE " | ", 0

        player_upright BYTE "  /", 0
                       BYTE " O ", 0
                       BYTE "   ", 0

        player_upleft BYTE "\  ", 0
                      BYTE " O ", 0
                      BYTE "   ", 0

        player_downright BYTE "   ", 0
                         BYTE " O ", 0
                         BYTE "  \", 0

        player_downleft BYTE "   ", 0
                        BYTE " O ", 0
                        BYTE "/  ", 0

;temporary variables
        x db 0
        y db 0

        pauseKey db 0
        currentChar dd '^'

        bulletX db ?
        bulletY db ?

        menuSelect db 1

;name prompt
        prompt1 db "Enter your name:",0
        names db 20 dup (32)
        strName db "Name:",0

;player's starting position (center)
        xPos db 56      ; Column (X)
        yPos db 15      ; Row (Y)

        xDir db 0
        yDir db 0

;default character (initial direction)
        inputChar db 0
        direction db "d"

;colors for the emitter and player
        color_red db 4       ; Red
        color_green db 2     ; Green
        color_yellow db 14   ; Yellow (for fire symbol)

        current_color db 4   ; Default player color (red)

        emitter_color1 db 2  ; Green
        emitter_color2 db 4  ; Red

        fire_color db 14     ; Fire symbol color (Yellow)

;emitter properties
        emitter_symbol db "#"
        emitter_row db 0    ; Two rows above player (fixed row for emitter)
        emitter_col db 1    ; Starting column of the emitter

;fire symbol properties (fired from player)
        fire_symbol db "*", 0
        fire_row db 0        ; Fire will be fired from the player's position
        fire_col db 0        ; Initial fire column will be set in the update logic

;interface variables
        score db 0          ; Player's score
        lives db 3          ; Player's lives
        levelInfo db 1
    
;counter variables for loops
        counter1 db 0
        counter2 db 0

;fireball
        fireballexists db 0     ;can be either true or false
        currentColor db 1
        nextColor db 1
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////CODE
.code
main PROC
        mov eax, SND_FILENAME
        OR eax, SND_ASYNC
        INVOKE PlaySound, OFFSET soundfile, NULL, EAX
       
        call startScreen                        ;prints stars, zuma title, and house art
        call nameInput                          ;takes name input in 'names'

        call startMenu                          ;handles start, instructions and exit
        call startGame                          ;
   
main ENDP

startScreen PROC        ;prints stars, zuma title, and house art
        mov dl,1 
        mov dh,1
        mov eax, white
        call settextcolor
        call gotoxy
        mov edx,offset STARS_ART
        call writestring

        mov eax,white
        call settextcolor
        call gotoxy
        mov edx,offset ZUMA_ART
        call writestring

        mov eax, white
        call settextcolor
        call gotoxy
        mov edx,offset HOUSE_ART
        call writestring
        call waitmsg    
        call clrscr
        call clrscr
        ret
startScreen ENDP

nameInput PROC      ;prints spiders art and prompts user to add name
        mov dh, 17
        mov dl, 0
        call gotoxy
        mov edx, offset SPIDERS3
        call writestring

        mov dh,0
        mov dl,0
        call gotoxy
        mov edx,offset prompt1
        mov ecx,lengthof prompt1
        call writestring
        mov edx,offset names
        mov ecx,20
        call readstring

        call clrscr
        ret
nameInput ENDP

initialiseBalls PROC            ;sets x, y positions, colors to random and direction to down
        mov esi, offset ballsArray
        mov ecx, 0
        loopBalls:
        mov BYTE PTR [esi] , 90 ;x position
            ;for initialising y position
            mov eax, 0
            mov al, 10 ;initial y position
            sub al, cl ; ball number
        mov BYTE PTR [esi + 1], al ;y position
            ;get random number for color                        ;fix according to color requirements later
            mov eax, 5 ; max value for the color
            sub eax, 1 ;min vaue for the color
            inc eax  ;includes btoh ends
            call RandomRange 
            add eax, 1  ;add min val to sjift to range 
        mov BYTE PTR [esi + 2], al    ;color
        mov BYTE PTR [esi + 3], 1   ;mov down
        mov BYTE PTR [esi + 4], 1 ;exists = true
        add esi, 5
        inc ecx
        cmp ecx, 20
        jne loopBalls
        ret
initialiseBalls ENDP

startMenu PROC
        point1:
        mov eax, white
        call setTextColor
            mov dl, 0
        mov dh, 0
        call gotoxy
        mov edx, offset SPIDERS3
        call writestring
        mov eax, red
        call setTextColor
            mov dl,43
            mov dh,3
            call gotoxy
            mov edx,offset POINTER
            call writestring
            mov menuSelect,1
            mov eax, white
        call setTextColor
        jmp start_tab

        point2:
        
            mov dl, 0
        mov dh, 0
        call gotoxy
        mov edx, offset SPIDERS3
        call writestring
        mov eax, red
        call setTextColor
            mov dl,100
            mov dh,12
            call gotoxy
            mov edx,offset POINTER
            call writestring
            mov menuSelect,2
                mov eax, white
        call setTextColor
        jmp start_tab

        point3:
            mov dl, 0
        mov dh, 0
        call gotoxy
        mov edx, offset SPIDERS3
        call writestring
         mov eax, red
        call setTextColor
            mov dl,33
            mov dh,22
            call gotoxy
            mov edx,offset POINTER
            call writestring
            mov menuSelect,3
            mov eax, white
        call setTextColor
        jmp start_tab

        start_tab:
        mov dl,0
        mov dh,1
        call gotoxy
        mov edx,offset START
        call writestring
    
    
        mov dl,0
        mov dh,10
        call gotoxy
        mov edx,offset INSTRUCTIONS
        call writestring

        mov dl,0
        mov dh,20
        call gotoxy
        mov edx,offset EXITED
        call writestring
    
        mov dl,0
        mov dh, 27
        call gotoxy
        mov edx,offset START_INFO
        call writestring

          call readchar
        call clrscr
        cmp al,'1'
        je point1
        cmp al,'2'
        je point2
        cmp al,'3'
        je point3
        cmp al,13
        je selection

        selection:
        cmp menuSelect,1
        je startt
        cmp menuSelect,2
        je INSTRUCTIONSSCREEN
        cmp menuSelect,3
        mov lives, 0
        call exitGame
        ret

        startt:
        call startGame

        INSTRUCTIONSSCREEN:
        mov dl,0 
        mov dh,0
        call gotoxy
        mov edx,offset INSTRUCTIONS_SCREEN
        call writestring
        call readchar
        call clrscr
        cmp al,27
        je point2
        jmp INSTRUCTIONSSCREEN
        ret
startMenu ENDP

startGame PROC
        call initialiseBalls                    ;sets x, y positions, colors to random and direction to down
        call initialiseScreen                   ;draws wall, player and spider
    gameLoop:
        call moveFireball
        call checkCollision
        call moveFireball
        call checkCollision
        mov eax, 200
        call delay
        call movePlayer
        call moveFireball
        call checkCollision
        jmp gameLoop
        ret
startGame ENDP

InitialiseScreen PROC
    ; Draw the level layout at the start
    call DrawWall

    ; Set the initial player cannon position
    call PrintPlayer

    ret
InitialiseScreen ENDP

MovePlayer PROC  ;takes input and calls function
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    mov dx, 0
    call GoToXY

    checkInput:
        call flushBallPositions
        call moveBalls
        call displayBalls


    ; Check for key press
    mov eax, 0
    call ReadKey
    mov inputChar, al

    cmp inputChar, VK_SPACE
    je shoot

    cmp inputChar, ' '
    je shoot

    cmp inputChar, VK_ESCAPE
    je pausee

    cmp inputChar, 'l'
    je lb

    cmp inputChar, "w"
    je move

    cmp inputChar, "a"
    je move

    cmp inputChar, "x"
    je move

    cmp inputChar, "d"
    je move

    cmp inputChar, "q"
    je move

    cmp inputChar, "e"
    je move

    cmp inputChar, "z"
    je move

    cmp inputChar, "c"
    je move

    cmp inputChar, "p"
    je pausee

    ; if character is invalid
    ret

    pausee:
    call pauseGame
    jmp checkInput

    lb:
    call leaderBoard
    jmp checkInput
    move:
        mov al, inputChar
        mov direction, al
        jmp chosen
        
    shoot:
        cmp fireballExists, 1
        je chosen
        call initialiseFireball

    chosen:
        call PrintPlayer
        

    ret
MovePlayer ENDP


pauseGame PROC
        call clrscr
        mov dh, 0
        mov dl, 0
        call gotoxy
        mov edx, OFFSET PAUSESCREEN
        call writeString 
    readCh:
        call readChar
        mov inputChar, al
        cmp inputChar, VK_ESCAPE
        je exitG
        cmp inputChar, 'r'
        je resume
        jmp readCh
    exitG:
        mov lives, 0
        call exitGame
        ret
    resume:
        call initialiseScreen
        ret
pauseGame ENDP

leaderBoard PROC
        call clrscr
        mov dh, 0
        mov dl, 0
        call gotoxy
        mov eax, 0011b
        call settextcolor

        mov edx, OFFSET LEADERBOARDD
        call writeString 

        mov dh, 14
        mov dl, 30
        call gotoxy
        mwrite "1. Umaima 10 "

        mov dh, 16
        mov dl, 30
        call gotoxy
        mwrite "2. Amna Ahmed 8 "
        
        mov dh, 18
        mov dl, 30
        call gotoxy
        mwrite "3. Zoro 2 "

    readCh:
        call readChar
        mov inputChar, al
        cmp inputChar, VK_ESCAPE
        je exitG
        cmp inputChar, 'r'
        je resume
        jmp readCh
    exitG:
        call exitGame
        ret
    resume:
        call initialiseScreen
        ret
leaderBoard ENDP

fileHandling PROC
    ; Opening the input file
    mov edx, OFFSET scoreFile
    call OpenInputFile
    mov fileHandle, eax

    ; Reading data into the buffer
    mov edx, OFFSET buffer
    mov ecx, BUFSIZE
    call ReadFromFile

    ; Closing the input file
    mov eax, fileHandle
    call CloseFile

    ; Parsing names and scores
    mov esi, OFFSET n1
    mov ecx, OFFSET n2
    mov edx, OFFSET n3
    mov edi, OFFSET buffer

    mov temp, 20
lup1:
    mov al, [edi]
    mov [esi], al
    mov al, [edi+32]
    mov [ecx], al
    mov al, [edi+64]
    mov [edx], al
    inc esi
    inc ecx
    inc edx
    inc edi
    dec temp
    cmp temp, 0
    jne lup1

    mov esi, OFFSET scr1
    mov ecx, OFFSET scr2
    mov edx, OFFSET scr3
    mov edi, OFFSET buffer
    add edi, 20

    mov temp, 10
lup2:
    mov al, [edi]
    mov [esi], al
    mov al, [edi+32]
    mov [ecx], al
    mov al, [edi+64]
    mov [edx], al
    inc esi
    inc ecx
    inc edx
    inc edi
    dec temp
    cmp temp, 0
    jne lup2

    ; Converting strings to numbers
    mov edx, OFFSET scr1
    mov ecx, 10
    call ParseDecimal32
    mov numscr1, ax

    mov edx, OFFSET scr2
    mov ecx, 10
    call ParseDecimal32
    mov numscr2, ax

    mov edx, OFFSET scr3
    mov ecx, 10
    call ParseDecimal32
    mov numscr3, ax

    ; Score comparison and ranking
    movzx eax, score
    cmp ax, numscr1
    jg first
    cmp ax, numscr2
    jg second
    cmp ax, numscr3
    jg third
    jmp skipFileHandling

first:
    ; Logic for first place
    call UpdateBufferForFirst
    jmp fileHandlingLogic

second:
    ; Logic for second place
    ; Move second to third
    mov esi, OFFSET n3
    mov edi, OFFSET n2
    mov ecx, 20
    rep movsb
    mov esi, OFFSET scr3
    mov edi, OFFSET scr2
    mov ecx, 10
    rep movsb

    ; Insert new second
    mov esi, OFFSET n2
    mov edi, OFFSET names
    mov ecx, 20
    rep movsb
    mov esi, OFFSET scr2
    movzx eax, score
    call ConvertScoreToBuffer
    jmp fileHandlingLogic

third:
    ; Logic for third place
    ; Insert new third
    mov esi, OFFSET n3
    mov edi, OFFSET names
    mov ecx, 20
    rep movsb
    mov esi, OFFSET scr3
    movzx eax, score
    call ConvertScoreToBuffer

fileHandlingLogic:
    ; Writing updated data to the output file
    mov eax, fileHandle
    mov edx, OFFSET scoreFile
    call CreateOutputFile
    mov fileHandle, eax
    mov edx, OFFSET buffer
    mov ecx, 96
    mov eax, fileHandle
    call WriteToFile

skipFileHandling:
    ; Additional display or cleanup logic
    mov dl, 0
    mov dh, 10
    mov eax, white
    call settextcolor
    call gotoxy
    mov edx, OFFSET LEADERBOARDD
    call writestring
    mov eax, 4000
    call delay
    call waitmsg
    call clrscr

    ; Display scores
    mwrite" display scores here "
    mov dh, 9
    mov dl, 5
    mov edx, OFFSET HighScores
    call WriteString
    mov edx, OFFSET buffer
    call writestring
    mov dl, 50
    mov dh, 15
    mov eax, white
    call settextcolor
    call gotoxy
    mov edx, OFFSET names
    call writestring
    mov eax, ':'
    call writechar
    movzx eax, score
    call writeint
    mov al, 10
    mov ecx, 5
    
looping:
    call writechar
    loop looping
    call waitmsg
    call clrscr

    ret
fileHandling ENDP

UpdateBufferForFirst PROC
    ; Custom procedure to handle updating buffer for first place
    ; Similar to first block above
    ret
UpdateBufferForFirst ENDP

ConvertScoreToBuffer PROC
    ; Convert numeric score to ASCII and place in buffer
    ; Logic to convert and place in appropriate location
    ret
ConvertScoreToBuffer ENDP


DrawWall PROC
	call clrscr

    mov dl,19
	mov dh,2
	call Gotoxy
	mwrite <"Score: ">
	mov eax, Blue + (black * 16)
	call SetTextColor
	mov al, score
	call WriteDec

    mov eax, White + (black * 16)
	call SetTextColor

	mov dl,90
	mov dh,2
	call Gotoxy
	mwrite <"Lives: ">
	mov eax, Red + (black * 16)
	call SetTextColor
	mov al, lives
	call WriteDec

	mov eax, white + (black * 16)
	call SetTextColor

	mov dl,55
	mov dh,2
	call Gotoxy

	mwrite "LEVEL " 
	mov al, levelInfo
	call WriteDec

	mov eax, gray + (black*16)
	call SetTextColor

	mov dl, 19
	mov dh, 4
	call Gotoxy

	mov esi, offset walls

	mov counter1, 50
	mov counter2, 80
	movzx ecx, counter1
	printcolumn:
		mov counter1, cl
		movzx ecx, counter2
		printrow:
			mov eax, [esi]
			call WriteChar
            
			inc esi
		loop printrow
		
        dec counter1
		movzx ecx, counter1

		mov dl, 19
		inc dh
		call Gotoxy
	loop printcolumn
    ;draw spider
    mov dl, 0
    mov dh, 5
    call Gotoxy
    mov edx, OFFSET SPIDER2
    call writeString 

   ;initialise endpoint                     ;starting point is 90 and 10
    mov eax, red
    call setTextColor
    mov dl, 80
    mov dh, 7
    call Gotoxy
    mov eax, 'X'
    call writeChar
    mov eax, white
    call setTextColor
    
    ;cout instructions
    mov dh, 30
    mov dl, 20
    call gotoxy
    mwrite "Press 'P' or 'Esc' to pause the game. Press 'L' to view leaderboard."
	ret
DrawWall ENDP

PrintPlayer PROC
    movzx eax, nextColor
    call SetTextColor

    mov al, direction
    cmp al, "w"
    je print_up

    cmp al, "x"
    je print_down

    cmp al, "a"
    je print_left

    cmp al, "d"
    je print_right

    cmp al, "q"
    je print_upleft

    cmp al, "e"
    je print_upright

    cmp al, "z"
    je print_downleft

    cmp al, "c"
    je print_downright

    ret

    print_up:
        mov esi, offset player_up
        jmp print

    print_down:
        mov esi, offset player_down
        jmp print

    print_left:
        mov esi, offset player_left
        jmp print

    print_right:
        mov esi, offset player_right
        jmp print

    print_upleft:
        mov esi, offset player_upleft
        jmp print

    print_upright:
        mov esi, offset player_upright
        jmp print

    print_downleft:
        mov esi, offset player_downleft
        jmp print

    print_downright:
        mov esi, offset player_downright
        jmp print

    print:
    mov dl, xPos
    mov dh, yPos
    call GoToXY

    mov counter1, 3
	mov counter2, 4
	movzx ecx, counter1
	printcolumn:
		mov counter1, cl
		movzx ecx, counter2
		printrow:
			mov eax, [esi]
			call WriteChar
            
			inc esi
		loop printrow

		movzx ecx, counter1

		mov dl, xPos
		inc dh
		call Gotoxy
	loop printcolumn
    
ret
PrintPlayer ENDP

displayBalls PROC
mov esi, offset ballsArray
mov ecx, 20
displayLoop:
    ;if x is equal to 90 we are in staring position
    cmp BYTE PTR [esi + 4], 0  ;check if ball exists 
    je skipBall
    mov bl, [esi]
    cmp bl, 90 
    jne display
    checkExists:
        mov bl, [esi + 1]
        cmp bl, 10
        jl skipBall

    display:
        mov eax, [esi + 2]    ;mov color to eax
        call setTextColor
        mov dl, [esi]
        mov dh, [esi + 1]
        call gotoxy
        mov eax, "@"
        call writeChar
    skipBall:
    add esi, 5
loop displayLoop
ret
displayBalls ENDP

flushBallPositions PROC
mov esi, offset ballsArray
mov ecx, 20
displayLoop:
    ;if x is equal to 90 we are in staring position
    cmp BYTE PTR [esi + 4], 0  ;check if ball exists 
    je skipBall
    mov bl, [esi]
    cmp bl, 90 
    jne display
    checkExists:
        mov bl, [esi + 1]
        cmp bl, 10
        jl skipBall

    display:
        mov dl, [esi]
        mov dh, [esi + 1]
        call gotoxy
        mov eax, " "
        call writeChar
    skipBall:
    add esi, 5
loop displayLoop
ret
flushBallPositions ENDP

moveBalls PROC          ; 0 for right, 1 for down, 2 for left, 3 for up
    mov eax, 78         ; Delay for smooth movement
    call Delay

    mov ecx, 20         ; Number of balls to process
    mov esi, offset ballsArray ; Start of balls array

movingLoop:
    ; Check direction for the current ball
    cmp BYTE PTR [esi + 3], 0  ; Direction 0: Right
    je moveRight
    cmp BYTE PTR [esi + 3], 1  ; Direction 1: Down
    je moveDown
    cmp BYTE PTR [esi + 3], 2  ; Direction 2: Left
    je moveLeft
    cmp BYTE PTR [esi + 3], 3  ; Direction 3: Up
    je moveUp
    jmp nextBall               ; Skip if direction is invalid

moveRight:
    mov al, xEndp              ; Check X boundary
    cmp BYTE PTR [esi], al     ; If reached endpoint, end game
    je exitGame
    inc BYTE PTR [esi]         ; Move right
    jmp nextBall

moveDown:
    mov al, yPoint1            ; Check Y boundary
    cmp BYTE PTR [esi + 1], al
    je makeDirLeft             ; Change direction if boundary hit
    inc BYTE PTR [esi + 1]     ; Move down
    jmp nextBall

moveUp:
    mov al, yPoint3            ; Check Y boundary
    cmp BYTE PTR [esi + 1], al
    je makeDirRight            ; Change direction if boundary hit
    dec BYTE PTR [esi + 1]     ; Move up
    jmp nextBall

moveLeft:
    mov al, xPoint2            ; Check X boundary
    cmp BYTE PTR [esi], al
    je makeDirUp               ; Change direction if boundary hit
    dec BYTE PTR [esi]         ; Move left
    jmp nextBall

makeDirUp:
    mov BYTE PTR [esi + 3], 3  
    jmp nextBall
makeDirRight:
    mov BYTE PTR [esi + 3], 0  
    jmp nextBall
makeDirLeft:
    mov BYTE PTR [esi + 3], 2  
    jmp nextBall

nextBall:
    add esi, 5                 ; next ball
    loop movingLoop            
    call displayBalls          
    ret
moveBalls ENDP

exitGame PROC
cmp lives, 1
jle endGame
dec lives
call clrscr
call startGame
endGame:
        ;call clrscr
       ; call fileHandling
        call clrscr
        mov dh, 0
        mov dl, 0
        call gotoxy
        mov eax, red
        call setTextColor
        mov edx, offset SPIDER
        call writestring 
        mov eax, white
        call settextcolor
        mov dh, 20
        mov dl, 0
        call gotoxy
        mov edx, offset GAMEOVERSCREEN 
        call writeString 

        mov dh, 90
        mov dl, 0
        call gotoxy
        mov eax, 0                 ; Exit code
        call ExitProcess
exitGame ENDP



initialiseFireball PROC
    cmp fireballExists, 1 ;so it only gets initialised once
    je fire_loop
    ;initialise a projectile from the player's current face direction
    mov fireballExists, 1

    mov bl, nextColor
    mov currentColor, bl
    call printPlayer

    ;get random number for next color                        ;fix according to color requirements later
            mov eax, 5 ; max value for the color
            sub eax, 1 ;min vaue for the color
            inc eax  ;includes btoh ends
            call RandomRange
            add eax, 1
            mov nextColor, al

    mov dl, xPos      ; Fire column starts at the player's X position
    mov dh, yPos      ; Fire row starts at the player's Y position

    mov fire_col, dl  ; Save the fire column position
    mov fire_row, dh  ; Save the fire row position

    mov al, direction
    cmp al, "w"
    je fire_up

    cmp al, "x"
    je fire_down

    cmp al, "a"
    je fire_left

    cmp al, "d"
    je fire_right

    cmp al, "q"
    je fire_upleft

    cmp al, "e"
    je fire_upright

    cmp al, "z"
    je fire_downleft

    cmp al, "c"
    je fire_downright

    jmp fire_loop

fire_up:
    mov fire_row, 13         ; Move fire position upwards
    mov fire_col, 57         ; Center fire position
    mov xDir, 0
    mov yDir, -1
    jmp fire_loop

fire_down:
    mov fire_row, 19         ; Move fire position downwards
    mov fire_col, 57         ; Center fire position
    mov xDir, 0
    mov yDir, 1
    jmp fire_loop

fire_left:
    mov fire_col, 54         ; Move fire position leftwards
    mov fire_row, 16         ; Center fire position
    mov xDir, -1
    mov yDir, 0
    jmp fire_loop

fire_right:
    mov fire_col, 60         ; Move fire position rightwards
    mov fire_row, 16         ; Center fire position
    mov xDir, 1
    mov yDir, 0
    jmp fire_loop

fire_upleft:
    mov fire_row, 15        ; Move fire position upwards
    mov fire_col, 56         ; Move fire position leftwards
    mov xDir, -1
    mov yDir, -1
    jmp fire_loop

fire_upright:
    mov fire_row, 15         ; Move fire position upwards
    mov fire_col, 60         ; Move fire position rightwards
    mov xDir, 1
    mov yDir, -1
    jmp fire_loop

fire_downleft:
    mov fire_row, 19         ; Move fire position downwards
    mov fire_col, 56         ; Move fire position leftwards
    mov xDir, -1
    mov yDir, 1
    jmp fire_loop

fire_downright:
    mov fire_row, 19        ; Move fire position downwards
    mov fire_col, 60         ; Move fire position rightwards
    mov xDir, 1
    mov yDir, 1
    jmp fire_loop

fire_loop: ;does nothing
    ;call moveFireball
initialiseFireball ENDP

moveFireball PROC
    cmp fireballExists, 0
    je noBalls
   
   call printPlayer
    mov dl, fire_col        ; erase prev position
    mov dh, fire_row
    call Gotoxy
    mWrite " "

    cmp xDir, 0
    je vertical
    cmp yDir, 0
    je horizontal

    ;fireball moves diagonally
    mov dl,yDir
    add fire_row,dl
    mov dh,xDir
    add fire_col, dh
    jmp check

horizontal:
    ; Only horizontal movement (yDir is zero)
    cmp xDir, 0
    je vertical
    mov dh,xDir
    add fire_col, dh
    jmp check

vertical:
    ; Only vertical movement (xDir is zero)
    cmp yDir, 0
    je check
    mov dl,yDir
    add fire_row, dl
    jmp check

check:
    ; Check if the fireball is within bounds
    cmp fire_col, 20        ; Check if it went left
    jle noBalls
    cmp fire_col, 96        ; Check if it went right
    jge noBalls
    cmp fire_row, 5      ; Check if it went up
    jle noBalls
    cmp fire_row, 27        ; Check if it went down
    jge noBalls

    ; Print the fire symbol at the current position
    movzx eax, currentColor
    call SetTextColor

    mov dl, fire_col
    mov dh, fire_row
    call Gotoxy
    mWrite "*" 


    ret

noBalls:
    mov fireballExists, 0      ; Deactivate fireball
    ret
moveFireball ENDP


checkCollision PROC
    cmp fireballExists, 0          ; Check if the fireball is active
    je noCollision

    mov ecx, 0                   ; Counter for balls
    mov esi, OFFSET ballsArray   ; Point to the start of the balls array

collisionLoop:
    ; Check if the current ball exists
    cmp BYTE PTR [esi + 4], 0
    je nextCollision

    ; Compare ball coordinates with fireball coordinates
    mov al, fire_col             ; Fireball column
    mov ah, fire_row             ; Fireball row
    cmp BYTE PTR [esi + 1], ah   ; Check y position
    jne nextCollision
    cmp BYTE PTR [esi], al       ; Check x position
    jne nextCollision

    ; Compare ball color with fireball color
    mov al, currentColor
    cmp al, BYTE PTR [esi + 2]   ; Compare colors
    jne nextCollision

    ; If color matches and collision occurs
    mov BYTE PTR [esi + 4], 0    ; Deactivate the ball
    call increaseScore


    ; Check neighboring balls for matching color
    mov edi, esi                 ; Store current ball pointer
    mov ebx, ecx                 ; Store current ball index

nextBallCheck:
    ; Check next balls in sequence
    cmp ebx, 20                  ; Limit to array size
    je endNextCheck
    add edi, SIZEOF BALLS        ; Move to the next ball
    inc ebx
    cmp BYTE PTR [edi + 2], al   ; Compare color
    jne endNextCheck
    mov BYTE PTR [edi + 4], 0    ; Deactivate matching ball
    call increaseScore

    jmp nextBallCheck

endNextCheck:
    mov edi, esi                 ; Reset to current ball
    mov ebx, ecx

prevBallCheck:
    ; Check previous balls in sequence
    cmp ebx, 0                   ; Ensure within bounds
    je endPrevCheck
    sub edi, SIZEOF BALLS        ; Move to the previous ball
    dec ebx
    cmp BYTE PTR [edi + 2], al   ; Compare color
    jne endPrevCheck
    mov BYTE PTR [edi + 4], 0    ; Deactivate matching ball
    call increaseScore
    jmp prevBallCheck

endPrevCheck:

nextCollision:
    add esi, SIZEOF BALLS        ; Move to the next ball in the array
    inc ecx
    cmp ecx, 20                  ; Check if all balls are processed
    jl collisionLoop

noCollision:
    ret
checkCollision ENDP
increaseScore PROC
    push edx 
    push eax
    push ebx
inc score                   ;increase score
    mov dl,19
	mov dh,2
	call Gotoxy
	mwrite <"Score: ">
	mov eax, Blue + (black * 16)
	call SetTextColor
	mov al, score
	call WriteDec

    pop ebx
    pop eax
    pop edx
    ret
increaseScore ENDP
END main
