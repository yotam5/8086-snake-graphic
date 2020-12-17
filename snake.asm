IDEAL
MODEL small
STACK 100H
P386
DATASEG
;Snake game 
;CNTR + F12 to boost FPS rate for better experience
;-----------



;colors values
appleColor db 4
snakeColor db 10
snakeHeadColor db 4
COLOR db 2
;text mgs values
msgScore db 'Score:$'
msg1 db 'Made by: well,me$'
msg2 db 'Game name: Snake$'
msg3 db 'Explained:$'
msg4 db 'The player control the snake$'
msg5 db 'move with the following keys:$' 
msg6 db 'W->Up A->Left S->Down D->Right$'
msg7 db 'The player need to gather apples$'
msg8 db 'and nor touching itself\outline$'
msg9 db 'Choose color for the Snake Body:$'
msg10 db 'R-Red | B-Blue | G-Green | W-White$'
msg11 db 'Choose snake head Color:$'
msg12 db 'Thank U for Playing!$'
msg13 db 'Choose Apple color:$'
msg14 db 'also can use arrows the same way $'
msg15 db 'You made new Record! $'
msg16 db 'Too bad! Try again later $'
msg17 db 'Prev Record:$'
msg18 db 'New Record:$'
msg19 db 'Current Record:$'
msg20 db 'Your Score:$'
msg21 db 'Press T to run again!$'
msg22 db 'IGN:$'
;length values and counters
COUNTLENGTH dw 4
SIZEB dw 5
leng db 4
appleCount dw 0

;locations values
xStart db 40
yStart db 50
xBoard dw 0
yBoard dw 0
XARRAY db 100 dup(?)
YARRAY db 100 dup(?)

;values for snake movment algoritm
tmp1 db ? 
tmp2 db ?

;draw false circle values
XsquareToC db 0,0,4,4,0
YsquareToC db 0,4,4,0,0

;snake moving values
MOVE_STATE db 'R' ;initial direction
dirX db 5
dirY db 0
tmp dw ?

;apple values
XAPPLE db ?
YAPPLE db ?

;for function snake
numstr db '$$$$$'
askName db 'Enter your player name: $'
player_name db 20 dup('$')
player_nameFile db 20 dup('$')
Clock equ es:6CH

;file 
Filename db 'score.txt',0
Filename1 db 'name.txt',0
handle dw ?
scoreRead db 4 dup('$') ;the score from file
A db '$'

;stint2num vars
tmp5 dw 0
mul1 db 1 

CODESEG

proc getFileName
;get player file name
    lea dx,[Filename1]
    call OpenFile
    mov dx,offset player_nameFile 
    mov cx,15
    call ReadFile
    call CloseFile
ret 
endp getFileName

proc WriteNameToFile
;write player name to file
    lea dx,[Filename1]
    call OpenFile
    mov cx,15
    mov dx,offset player_name
    call WriteFile
    call CloseFile
ret 
endp WriteNameToFile

proc HandleRecord
    ;handle situation if a new recorded appeared or not if
    ;it does than inform the user and display on screen
    ;also update score file and name file
    call getFileName
    lea dx,[Filename]
    call OpenFile
    mov dx,offset scoreRead
    mov cx,3
    call ReadFile
    call CloseFile
    mov bx,offset scoreRead
    call CountDigits
    call string2num
    xor ax,ax 
    xor dx,dx 
    mov ax,[tmp5] ;ax in the previus record
    mov dx,[COUNTLENGTH]
    cmp ax,dx 
    jae noRec
       ; jmp exit
        call WriteNameToFile
        lea dx,[Filename]
        call OpenFile
        mov ax,[COUNTLENGTH]
        call number2string
        mov cx,4 ;delete prev record
        mov dx,offset numstr
        call WriteFile
        call CloseFile
        call clrscr
        mov dl,9
        mov dh,3
        mov ah,2
        mov bh,0
        int 10h 
        mov ah,9h 
        mov dx,offset msg15 
        int 21h
        mov dl,9
        mov dh,7
        mov ah,2
        mov bh,0
        int 10h 
        mov ah,9h 
        mov dx,offset msg17
        int 21h        
        mov dx,offset scoreRead
        int 21h
        mov dl,25
        mov dh,7
        mov ah,2
        mov bh,0
        int 10h 
        mov ah,9h    
        mov dx,offset msg22 
        int 21h
        mov dx,offset player_nameFile
        int 21h
        mov dl,9
        mov dh,9
        mov ah,2
        mov bh,0
        int 10h 
        mov ah,9h    
        mov dx,offset msg18 
        int 21h
        mov dx,offset numstr
        int 21h
        mov dl,25
        mov dh,9
        mov ah,2
        mov bh,0
        int 10h 
        mov ah,9h    
        mov dx,offset msg22 
        int 21h
        mov dx,offset player_name
        int 21h
    jmp RecYes
    noRec:
    call clrscr
    mov dl,3
    mov dh,3
    mov ah,2
    mov bh,0
    int 10h 
    mov ah,9h 
    mov dx,offset msg16
    int 21h 
    mov dl,3
    mov dh,5
    mov ah,2
    mov bh,0
    int 10h 
    mov ah,9h 
    mov dx,offset msg19 
    int 21h
    mov dx,offset scoreRead
    int 21h
    mov dl,23
    mov dh,5
    mov ah,2
    mov bh,0
    int 10h 
    mov ah,9h    
    mov dx,offset msg22 
    int 21h
    mov dx,offset player_nameFile
    int 21h
    mov dl,3
    mov dh,7
    mov ah,2
    mov bh,0
    int 10h 
    mov ah,9h 
    mov dx,offset msg20
    int 21h
    mov dx,offset numstr
    int 21h
    mov dl,23
    mov dh,7
    mov ah,2
    mov bh,0
    int 10h 
    mov ah,9h    
    mov dx,offset msg22 
    int 21h
    mov dx,offset player_name
    int 21h
    RecYes:
    call clearBuffer
    mov ah,1h 
    int 21h
    call clrscr
ret 
endp HandleRecord

proc string2num
;make string to number
;scoreRead
;length in cx
;mul1 = 1
;tmp5 dw = 0
push si
push cx
mov si,0

mov si,cx
dec si
conver:  
    mov dl,[scoreRead + si]
    sub dl,30h
    mov al,dl 
    mov bl,[mul1]
    mul bl 
    add [tmp5],ax 
    xor ax,ax   
    mov al,[mul1]
    mov bl,10
    mul bl 
    mov [mul1],al
    dec si
loop conver

finish:    
pop cx
pop si 
ret 
endp string2num

proc OpenFile
    ;open file parameter dx
    mov ah,3Dh
    mov al,2
    ;lea dx,Filename
    int 21h 
    mov [handle],ax
    ret 
endp OpenFile

proc ReadFile
    ;cx parameter length
    ;dx offset loc read to
    mov ah,3Fh
    mov bx,[handle]
    int 21h
    ret 
endp ReadFile

proc CloseFile
    ;close the file
    mov ah,3Eh
    mov bx,[handle]
    int 21h
ret 
endp CloseFile

proc CountDigits
;bx offset 
;res in cx
push bx
push ax
mov cx,0
lCount:
    mov al,[bx]
    cmp al,'$'
    je endNum
    inc cx 
    inc bx
jmp lCount
endNum:
pop ax
pop bx  
ret 
endp CountDigits

proc WriteFile
    ;cx length
    ;dx offset
    mov ah,40h
    mov bx,[handle]
    ;mov cx,4 ;delete prev record
    ;mov dx,offset numstr
    int 21h
    ret 
endp WriteFile

proc FinishGame 
;print player name and indictae that game ended
push ax 
push dx 
push bx 
mov dl,2
mov dh,3
mov ah,2
mov bh,0
int 10h 
mov dx,offset msg12 
mov ah,9h 
int 21h
mov dx,offset player_name 
mov ah,9h 
int 21h
call newLine
pop bx 
pop dx 
pop ax
ret 
endp FinishGame

proc newLine 
;print new line
push dx 
push ax 
 mov dl, 10 ;printing new line
 mov ah, 02h
 int 21h
 mov dl, 13
 mov ah, 02h
 int 21h
pop ax 
pop dx 
ret 
endp newLine

proc OpeningScreen
;print game rules and instructions 
push ax 
push cx 
push dx 
push bx 


mov dl,7
mov dh,1
mov ah,2
mov bh,0
int 10h 

mov dx,offset msg1 
mov ah,9h
int 21h 
mov dl,7
mov dh,3
mov ah,2
mov bh,0
int 10h 

mov dx,offset msg2 
mov ah,9h
int 21h 

mov dl,7
mov dh,5
mov ah,2
mov bh,0
int 10h 

mov dx,offset msg3 
mov ah,9h
int 21h 

mov dl,7
mov dh,7
mov ah,2
mov bh,0
int 10h 

mov dx,offset msg4
mov ah,9h
int 21h 

mov dl,7
mov dh,9
mov ah,2
mov bh,0
int 10h 

mov dx,offset msg5
mov ah,9h
int 21h 

mov dl,7
mov dh,11
mov ah,2
mov bh,0
int 10h 
mov dx,offset msg6
mov ah,9h
int 21h 

mov dl,7
mov dh,13
mov ah,2
mov bh,0
int 10h 
mov dx,offset msg14
mov ah,9h
int 21h 

mov dl,7
mov dh,15
mov ah,2
mov bh,0
int 10h 
mov dx,offset msg7
mov ah,9h
int 21h 

mov dl,7
mov dh,17
mov ah,2
mov bh,0
int 10h 
mov dx,offset msg8
mov ah,9h
int 21h 

mov ah,1h
int 21h
pop bx
pop dx 
pop cx 
pop ax
ret 
endp OpeningScreen

proc getPlayerName
;get the player name and save to player_name
push cx 
push dx 
push si 
push ax
push bx 

mov dl,1
mov dh,1
mov ah,2
mov bh,0
int 10h 
mov dx,offset askName
mov ah,9h 
int 21h
mov si,0
getChar:
 mov ah,1h ;in al char
 int 21h 
 cmp al,13 ;tab to finish name
 je finishNameEnter 
 mov [player_name + si],al 
 inc si 
 jmp getChar
 
mov bl,'$'
mov [player_name + 10],bl
finishNameEnter:

pop bx
pop ax 
pop si 
pop dx 
pop cx
ret 
endp getPlayerName

proc ThemAdjust
;ask player to choose colors for game
push ax 
push dx ;push bx
push cx

mov dl,3
mov dh,1
mov ah,2
mov bh,0
int 10h 
mov dx,offset msg9
mov ah,9h
int 21h 
call newLine
call newLine
mov dl,3
mov dh,3
mov ah,2
mov bh,0
int 10h 
mov dx,offset msg10 
mov ah,9h 
int 21h
mov ah,1h 
int 21h 
cmp al,'G'
jne noGreen
mov [snakeColor],2 
jmp endsnakecolor
;just for code fold
 noGreen:
 cmp al,'W'
 jne noWhite
 mov [snakeColor],7
 jmp endsnakecolor1
 noWhite: 
 cmp al,'B'
 jne noBlue
 mov [snakeColor],1
 jmp endsnakecolor
 noBlue:
 cmp al,'R'
 mov [snakeColor],4
 jmp endsnakecolor
 endsnakecolor:
 call clrscr
 mov dl,3
 mov dh,1
 mov ah,2
 mov bh,0
 int 10h 
 mov dx,offset msg11
 mov ah,9h
 int 21h 
 mov dl,3
 mov dh,3
 mov ah,2
 mov bh,0
 int 10h 
 mov dx,offset msg10
 mov ah,9h 
 int 21h
 mov ah,1h 
 int 21h 
 cmp al,'G'
 jne noGreen1
 mov [snakeHeadColor],2 
 jmp endsnakecolor1
 noGreen1:
 cmp al,'W'
 jne noWhite1
 mov [snakeHeadColor],7
 jmp endsnakecolor1
 noWhite1:
 cmp al,'B'
 jne noBlue1
 mov [snakeHeadColor],1
 jmp endsnakecolor1
 noBlue1:
 cmp al,'R'
 mov [snakeColor],4
 jmp endsnakecolor1
 endsnakecolor1:
 mov dl,3
 mov dh,1
 mov ah,2
 mov bh,0
 int 10h 
 call clrscr
 mov dx,offset msg13 
 mov ah,9h 
 int 21h 
 mov dl,3
 mov dh,3
 mov ah,2
 mov bh,0
 int 10h 
 mov dx,offset msg10 
 mov ah,9h
 int 21h
 call newLine
 call newLine
 mov ah,1h 
 int 21h
 cmp al,'G'
 jne noGreen2
 mov [appleColor],2 
 jmp endsnakecolor2
 noGreen2:
 cmp al,'W'
 jne noWhite2
 mov [appleColor],7
 jmp endsnakecolor2
 noWhite2:
 cmp al,'B'
 jne noBlue2
 mov [appleColor],1
 jmp endsnakecolor2
 noBlue2:
 cmp al,'R'
 mov [appleColor],4
 jmp endsnakecolor2
 endsnakecolor2:

pop cx 
pop dx 
pop ax 
ret 
endp ThemAdjust

proc dollars ;No parms. Fills area in memory with "$" 
 push cx 
 push di 
 mov cx, 5
 mov di, offset numstr
dollars_loop: mov bl, '$' 
 mov [ di ], bl
 inc di
 loop dollars_loop
 pop di
 pop cx 
 ret
endp dollars
;---------------------------------------------------------------------------
proc number2string 
 push cx
 push ax
 push dx
 push bx
 
 call dollars ;FILL STRING WITH $.
 mov bx, 10 ;DIGITS ARE EXTRACTED DIVIDING BY 10.
 mov cx, 0 ;COUNTER FOR EXTRACTED DIGITS.
;EXTRACT DIGITS 
cycle1: mov dx, 0 ;NECESSARY TO DIVIDE BY BX. 
 div bx ;DX:AX / 10 = AX:QUOTIENT DX:REMAINDER.
 push dx ;PRESERVE DIGIT EXTRACTED FOR LATER.
 inc cx ;INCREASE COUNTER FOR EVERY DIGIT EXTRACTED.
 cmp ax, 0 ;IF NUMBER IS NOT YET ZERO, LOOP.
 jne cycle1 ; 
;NOW RETRIEVE PUSHED DIGITS.
 mov si, offset numstr
cycle2: pop dx 
 add dl, 48 ;CONVERT DIGIT TO CHARACTER. 48 is '0' in ASCII 
 mov [ si ], dl
 inc si
 loop cycle2 
 pop bx
 pop dx
 pop ax
 pop cx
 ret
endp number2string

proc ScoreDisplay
;print the score to the right of screen
push dx 
push ax 
push bx 

mov dl,33
mov dh,1
mov ah,2
mov bh,0
int 10h 

mov dx,offset msgScore
mov ah,9h 
int 21h

xor ax,ax 
mov ax,[appleCount]
call number2string
mov dl,35
mov dh,3
mov ah,2
mov bh,0
int 10h 
mov dx,offset numstr
mov ah,9h
int 21h
pop bx 
pop ax 
pop dx
ret 
endp ScoreDisplay

proc Board
;print the board limits
push ax 
push cx 
push dx 
push bx 
xor ax,ax 
mov al,[COLOR]
push ax
mov [COLOR],14
mov cx,255
mov bx,1
mov dx,1
loopRight:
 push cx
 mov cx,bx
 mov al,[COLOR]
 mov ah,0ch
 int 10h 
 inc bx
 pop cx 
loop loopRight

mov cx,200
loopDown:
 push cx
 mov cx,bx
 mov al,[COLOR]
 mov ah,0ch
 int 10h 
 inc dx
 pop cx 
loop loopDown

mov cx,255
mov dx,199
loopLeft:
 push cx
 mov cx,bx
 mov al,[COLOR]
 mov ah,0ch
 int 10h 
 dec bx
 pop cx 
loop loopLeft

mov cx,199
mov dx,199
mov bx,1
loopUp:
 push cx
 mov cx,bx
 mov al,14
 mov ah,0ch
 int 10h 
 dec dx
 pop cx 
loop loopUp

pop ax 
mov [COLOR],al
pop bx
pop dx 
pop cx 
pop ax 
ret 
endp Board

proc addSnake
;add snake pice to the array of X and Y snake
push si 
push ax 
push dx

;xor ax,ax
;mov al,[leng]
mov si,[COUNTLENGTH]
xor dx,dx 
dec si
mov dl,[YARRAY + si] ;y
mov dh,[XARRAY + si] ;x
cmp [MOVE_STATE],'R'
jne notR1 
add dh,5
jmp finish1
notR1:
cmp [MOVE_STATE],'L'
jne notL1
sub dh,5
jmp finish1
notL1:
cmp [MOVE_STATE],'U'
jne notU1
sub dl,5
jmp finish1
notU1:
cmp [MOVE_STATE],'D'
;last opt
add dl,5
finish1:
inc si 
mov [YARRAY + si],dl
mov [XARRAY + si],dh 
inc [leng] ;TRACK LENGTH 
inc [COUNTLENGTH]
pop dx 
pop ax 
pop si
ret 
endp addSnake

proc prepairSnake
;prepair the snake initial size and place
push cx 
push si 
push dx 

xor cx,cx 
mov si,0
mov cl,[leng]
mov dl,[XAPPLE]
mov [xStart],dl 
mov dl,[YAPPLE]
sub dl,5 
mov [yStart],dl
snakePrep:
 mov dl,[xStart]
 mov [XARRAY + si],dl 
 mov dl,[yStart]
 mov [YARRAY + si],dl ;!
 add [xStart],5;5
 inc si 
loop snakePrep

pop dx
pop si 
pop cx
ret 
endp prepairSnake

proc checkIfInRec
;check if (x,y) in in (x1,y1) (x2,y2) radio
;al left x rec1
;ah right x rec1
;dh upper y rec1 
;dl lower y rec1
;cl x2
;ch y2
;IF they are in in bl there is 'T'!
push ax 
push dx
push cx 

cmp cl,al 
jbe notintRec
cmp cl,ah 
jae notintRec
cmp ch,dl 
jae notintRec
cmp ch,dh 
jbe notintRec
mov bl,'T'

notintRec:
pop cx 
pop dx 
pop ax
ret 
endp checkIfInRec

proc checkAppleEaten
;check if apple is eaten and if so make snake longer
push ax 
push cx
push dx 
push si 
push bx
    xor ax,ax 
    xor bx,bx 
    mov bx,[COUNTLENGTH]
    dec bx
    mov al,[XARRAY + bx]
    cmp al,[XAPPLE] ;CMP UY OF APPLE
    jne noSameAll
    mov al,[YARRAY + bx] 
    cmp al,[YAPPLE]
    jne noSameAll
    jmp eaten
    noSameAll:
    mov al,[XAPPLE] 
    mov ah,[XAPPLE]
    add ah,5
    mov dh,[YAPPLE] ;IMPO
    mov dl,[YAPPLE]
    add dl,5
    mov bx,[COUNTLENGTH]
    dec bx
    mov ch,[YARRAY + bx]
    mov cl,[XARRAY + bx]
    call checkIfInRec
    cmp bl,'T'
    je eaten

    mov ch,[YARRAY + bx]
    mov cl,[XARRAY + bx]
    add cl,4
    add ch,4
    call checkIfInRec
    cmp bl,'T'
    je eaten

    mov ch,[YARRAY + bx]
    mov cl,[XARRAY +bx]
    add cl,4
    call checkIfInRec
    cmp bl,'T'
    je eaten

    mov ch,[YARRAY + bx]
    mov cl,[XARRAY +bx]
    add ch,4
    call checkIfInRec
    cmp bl,'T'
    je eaten
    jmp noEaten
    eaten:
    call randomNum
    call addSnake
    inc [appleCount]


noEaten:
pop bx
pop si
pop dx
pop cx
pop ax
ret 
endp checkAppleEaten

proc ArraySort
 ;add the speed to last value and them replace values backwards
 ;array offset in bx 
 ;addition in dl 
 ;length in leg var
 push ax 
 push bx 
 push si 
 push dx 
 push cx
 push dx 

 xor ax,ax 
 mov al,[leng]
 mov si,ax 
 dec si
 mov ah,[bx + si]
 mov [tmp1],ah 
 add [bx + si],dl ;ADD NUM IN AL
 dec si 
 mov ah,[bx + si]
 mov [tmp2],ah 
 mov al,[tmp1]
 mov [bx + si],al
 dec si 
 mov cx,si 
 inc cx
 l3:
    mov al,[bx + si]
    mov [tmp1],al
    mov ah,[tmp2]
    mov [bx + si],ah 
    mov ah,[tmp1]
    mov [tmp2],ah 
    dec si
 loop l3
 pop dx
 pop cx 
 pop dx 
 pop si 
 pop bx 
 pop ax
ret 
endp ArraySort

proc drawApple
;draw the apple
 push ax 
 push dx 
 push bx 
 push cx
 ;call randomNum
 xor bx,bx
 mov al,[appleColor]
 mov [COLOR],al
 mov bl,[XAPPLE]
 xor dx,dx
 mov dl,[YAPPLE]
 call squareColored
 xor dx,dx 
 xor cx,cx

 mov cx,4
 mov si,0
 loopToC:   
    push cx
    mov dl,[YAPPLE]
    mov cl,[XAPPLE]
    add dl,[YsquareToC + si]
    add cl,[XsquareToC + si]
    mov al,0
    mov ah,0ch
    int 10h 
    pop cx
    inc si
loop loopToC

 mov al,[snakeColor]
 mov [COLOR],al
 pop cx
 pop bx
 pop dx 
 pop ax 

ret 
endp drawApple

proc drawLine
;draw line get y in dx and x in bx
;the length in in SIZEB var
;y in dx x in bx
push bx 
push cx
push dx
mov cx,[SIZEB]
;add bx,5?
loopLine:
 push cx 
 mov cx,bx ;x y in dx 
 mov al,[COLOR] ;change
 mov ah,0ch
 int 10h 
 inc bx 
 pop cx
loop loopLine
pop dx
pop cx
pop bx 
ret 
endp drawLine

proc handleMovment 
;apply movment to the array
push bx
push dx
mov bx,offset XARRAY
mov dl,[dirX]
call ArraySort
;call checkAppleEaten
mov bx,offset YARRAY
mov dl,[dirY]
call ArraySort
pop dx 
pop bx
ret 
endp handleMovment

proc randomNum
;generate random number
 push ax 
 push cx 
 push dx 

 mov ax,40h
 mov es,ax 
 mov ax,[es:6Ch]
 add ax,cx
 and ax,11100010b
 add al,14
 mov [XAPPLE],al
 
 
 mov ax,40h
 mov es,ax 
 mov ax,[es:6Ch]
 add ax,4
 and ax,10011000b
 add al,13
 mov [YAPPLE],al
 pop dx 
 pop cx 
 pop ax 
 ret 
endp randomNum

proc squareColored
;draw full colored square 
;y in dx and x in bx
push cx
push bx 
push dx
mov cx,[SIZEB]

draw1:
 push cx
 call drawLine
 inc dx 
 pop cx
loop draw1

pop dx 
pop bx 
pop cx
ret
endp squareColored

proc clrscr
;clear screen
push ax 
push cx 
push dx 
push bx
mov ax,0600H ;06 TO SCROLL & 00 FOR FULLJ SCREEN
mov bh,0H ;ATTRIBUTE 7 FOR BACKGROUND AND 1 FOR FOREGROUND
mov cx,0000H ;STARTING COORDINATES
mov dx,184FH ;ENDING COORDINATES
int 10H ;FOR VIDEO DISPLAY
pop bx
pop dx 
pop cx 
pop ax
ret
endp clrscr

proc Delay
;delay for 0.055s 
 push cx 
 push ax 
 mov ax,40h 
 mov es,ax 
 mov ax,[Clock]
 FirstTick: 
 cmp ax,[Clock]
 je FirstTick
 mov cx,1
 DelayLoop:
 mov ax,[Clock]
 Tick:
 cmp ax,[Clock]
 je Tick
 loop DelayLoop 
 pop ax
 pop cx 
 ret 
endp Delay

proc drawArray
 push ax 
 push bx 
 push cx 
 push dx
 push si 
 xor bx,bx
 xor dx,dx 
 
 mov cx,[COUNTLENGTH]
 dec cx
 mov si,0
 lmanage:
 push cx
 xor dx,dx 
 xor bx,bx
 mov dl,[YARRAY + si];y
 mov bl,[XARRAY + si];x
 mov cl,[COLOR]
 mov ch,[snakeColor]
 mov [COLOR],ch 
 call squareColored
 mov [COLOR],cl
 xor cx,cx
 xor dx,dx
 mov dl,[YARRAY + si]
 mov cl,[XARRAY + si]
 mov al,0
 mov ah,0ch
 int 10h 
 
 mov cx,4
 mov bx,0
 xor dx,dx
 loopToC1:   
    push cx
    mov dl,[YARRAY + si]
    mov cl,[XARRAY + si]
    add dl,[YsquareToC + bx]
    add cl,[XsquareToC + bx]
    mov al,0
    mov ah,0ch
    int 10h 
    pop cx
    inc bx
loop loopToC1

 xor ax,ax
 inc si

 pop cx
 loop lmanage
 ;HEAD COLORED
 mov al,[snakeHeadColor]
 mov [COLOR],al
 mov si,[COUNTLENGTH]
 dec si 
 mov dl,[YARRAY + si];y
 mov bl,[XARRAY + si];x 
 call squareColored
 mov dl,[YARRAY + si]
 mov cl,[XARRAY + si]
 mov cx,4 
 mov bx,0
 loopToC2:   
    push cx
    mov dl,[YARRAY + si]
    mov cl,[XARRAY + si]
    add dl,[YsquareToC + bx]
    add cl,[XsquareToC + bx]
    mov al,0
    mov ah,0ch
    int 10h 
    pop cx
    inc bx
loop loopToC2
 pop si
 pop dx 
 pop cx 
 pop bx 
 pop ax
ret 
endp drawArray

proc directionHandle
;handle key presses
 push ax 

 in al,64h 
 cmp al,10b 

 in al,60h ;ESC quite
 cmp al,1
 je endgame1
 cmp al,20h ;d 
 je rightx
 cmp al,4Dh
 je rightx
 cmp al,1eh;a
 je leftx
 cmp al,4Bh
 je leftx
 cmp al,11h;w
 je UPy
 cmp al,48h
 je UPy
 cmp al,1fh;s
 je DOWNy
 cmp al,50h
 je DOWNy
 jmp enddir
 UPy:
 mov [MOVE_STATE],'U'
 cmp [dirY],0
 jne enddir
 mov [dirX],0
 mov [dirY],-5
 jmp enddir
 DOWNy:
 mov [MOVE_STATE],'D'
 cmp [dirY],0
 jne enddir
 mov [dirX],0
 mov [dirY],5
 jmp enddir
 rightx:
 mov [MOVE_STATE],'R'
 cmp [dirX],0
 jne enddir
 mov [dirY],0
 mov [dirX],5
 jmp enddir
 leftx:
 mov [MOVE_STATE],'L'
 cmp [dirX],0
 jne enddir
 mov [dirY],0
 mov [dirX],-5
 enddir:
 pop ax
ret 
endp directionHandle

proc checkMove
;check if move is legal
push ax 
push bx 
push si 
push dx 
push cx 

xor ax,ax 
mov al,[leng]
mov si,ax 
dec si
mov dl,[XARRAY + si] ;x head
mov dh,[YARRAY + si];y head
cmp dl,3
jbe endgame1
cmp dl,253
jae endgame1
cmp dh,3
jbe endgame1
cmp dh,197
jae endgame1
xor cx,cx 
mov si,0
mov cl,[leng]
dec cl
dec cl
dec cl
loopLegal:
 push cx 
 mov cl,[XARRAY + si] ;x
 mov ch,[YARRAY + si] ;y
 cmp cl,dl 
 jne noPixel 
 cmp ch,dh 
 jne noPixel
 jmp endgame1
 noPixel: 
 inc si
 pop cx
loop loopLegal
pop cx
pop dx 
pop si 
pop bx
pop ax
ret 
endp checkMove

proc clearBuffer 
;clear buffer 
mov ah,0Ch 
mov al,07h 
int 21h
ret 
endp clearBuffer

endgame1:
jmp endgame
start:
 mov ax,@data 
 mov ds,ax 
;---------------
;code here
;---------------
mov ah, 0 ; set display mode function.
mov al, 13h ; mode 13h = 320x200 pixels, 256 colors.
int 10h
rerun:
mov [COUNTLENGTH],4
mov [leng],4
call clrscr
run:
mov [XAPPLE],90
mov [YAPPLE],90
mov dx,50
mov bx,50
call OpeningScreen
call clrscr
call getPlayerName
call clrscr
call ThemAdjust
call clrscr
mov cx,-1 ;for infinite loop
call prepairSnake
moveBox:
 push cx 
 call Board
 call ScoreDisplay
 call checkMove
 call directionHandle
 call drawApple
 call checkAppleEaten
 call handleMovment
 ;call legalMove
 ;call checkMove
 call drawArray
 xor ax,ax 
 ;just to see where head initial place

 ;end initial place
 call Delay
 call clrscr
 pop cx
loop moveBox
endgame:
call HandleRecord
call FinishGame
call clearBuffer
call clrscr

finishedgame:
;---- 
call clrscr
mov dl,7
mov dh,3
mov ah,2
mov bh,0
int 10h 
mov ah,9h
mov dx,offset msg21 
int 21h 
call newLine
call newLine
;call clearBuffer
mov ah,1h 
int 21h 
cmp al,'T'
je rerun
cmp al,'t'
je rerun
mov ah,0
mov al,2
int 10h
exit:
 mov ax,4c00h
 int 21h
END start
