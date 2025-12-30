.MODEL LARGE
.STACK 0500H

.DATA
    
    EXIT DB 0
    PLAYER_POS DW 1760D
    ARROW_POS DW 0D
    ARROW_STATUS DB 0D
    ARROW_LIMIT DW 22D

    LOON_POS DW 3860D
    LOON_STATUS DB 0D

    DIRECTION DB 0D

    STATE_BUF DB '00:0:0:0:0:0:00:00$'
    HIT_NUM DB 0D
    HITS DW 0D
    MISS DW 0D  


    GAME_OVER_STR DW '  ',0AH,0DH
    DW '                             |               |',0AH,0DH
    DW '                             |---------------|',0AH,0DH
    DW '                             | ^   SCORE   ^ |',0AH,0DH
    DW '                             |_______________|',0AH,0DH
    DW ' ',0AH,0DH 
    DW ' ',0AH,0DH
    DW ' ',0AH,0DH
    DW ' ',0AH,0DH
    DW ' ',0AH,0DH
    DW ' ',0AH,0DH
    DW '                                GAME OVER',0AH,0DH
    DW '                        PRESS ENTER TO START AGAIN$',0AH,0DH 


    GAME_START_STR DW '  ',0AH,0DH
    DW ' ',0AH,0DH
    DW ' ',0AH,0DH
    DW ' ',0AH,0DH
    DW '                ====================================================',0AH,0DH
    DW '               ||                                                  ||',0AH,0DH                                        
    DW '               ||       *    BALLOON SHOOTING GAME      *          ||',0AH,0DH
    DW '               ||                                                  ||',0AH,0DH
    DW '               ||--------------------------------------------------||',0AH,0DH
    DW '               ||                                                  ||',0AH,0DH
    DW '               ||                                                  ||',0AH,0DH
    DW '               ||                                                  ||',0AH,0DH          
    DW '               ||     USE UP AND DOWN KEY TO MOVE PLAYER           ||',0AH,0DH
    DW '               ||          AND SPACE BUTTON TO SHOOT               ||',0AH,0DH
    DW '               ||                                                  ||',0AH,0DH
    DW '               ||            PRESS ENTER TO START                  ||',0AH,0DH 
    DW '               ||                                                  ||',0AH,0DH
    DW '               ||                                                  ||',0AH,0DH
    DW '                ====================================================',0AH,0DH
    DW '$',0AH,0DH


.CODE

MAIN PROC
    MOV AX,@DATA
    MOV DS,AX
        
    MOV AX,0B800H
    MOV ES,AX
        
    JMP GAME_MENU

MAIN_LOOP:

    MOV AH,1H
    INT 16H
    JNZ KEY_PRESSED
    JMP INSIDE_LOOP

INSIDE_LOOP:

    CMP MISS,9
    JGE GAME_OVER
                
    MOV DX,ARROW_POS
    CMP DX, LOON_POS
    JE HIT
                
    CMP DIRECTION,8D
    JE PLAYER_UP

    CMP DIRECTION,2D
    JE PLAYER_DOWN
                
    MOV DX,ARROW_LIMIT
    CMP ARROW_POS, DX
    JGE HIDE_ARROW
                
    CMP LOON_POS, 0D
    JLE MISS_LOON
    JNE RENDER_LOON 
            

HIT:
    MOV AH,2
    MOV DX, 7D
    INT 21H
                    
    INC HITS
    LEA BX,STATE_BUF
    CALL SHOW_SCORE 

    LEA DX,STATE_BUF
    MOV AH,09H
    INT 21H
                    
    MOV AH,2
    MOV DL, 0DH
    INT 21H    
                    
    JMP FIRE_LOON
            

RENDER_LOON:
    MOV CL, ' '
    MOV CH, 1111B
    MOV BX,LOON_POS 
    MOV ES:[BX], CX
                    
    SUB LOON_POS,160D

    MOV CL, 15D
    MOV CH, 1101B
                
    MOV BX,LOON_POS 
    MOV ES:[BX], CX
                    
    CMP ARROW_STATUS,1D
    JE RENDER_ARROW
    JNE INSIDE_LOOP2 
                
RENDER_ARROW:
    MOV CL, ' '
    MOV CH, 1111B
                
    MOV BX,ARROW_POS
    MOV ES:[BX], CX
                        
    ADD ARROW_POS,4D
    MOV CL, 26D
    MOV CH, 1001B
                
    MOV BX,ARROW_POS 
    MOV ES:[BX], CX
                
INSIDE_LOOP2:
                    
    MOV CL, 125D
    MOV CH, 1100B
                    
    MOV BX,PLAYER_POS 
    MOV ES:[BX], CX
                               
    CMP EXIT,0
    JE MAIN_LOOP

    JMP EXIT_GAME


PLAYER_UP:
    MOV CL, ' '
    MOV CH, 1111B
                
    MOV BX,PLAYER_POS 
    MOV ES:[BX], CX
            
    SUB PLAYER_POS, 160D
    MOV DIRECTION, 0    
        
    JMP INSIDE_LOOP2
            

PLAYER_DOWN:
    MOV CL, ' '
    MOV CH, 1111B
                                                  
    MOV BX,PLAYER_POS 
    MOV ES:[BX], CX
            
    ADD PLAYER_POS,160D
    MOV DIRECTION, 0
            
    JMP INSIDE_LOOP2
        
KEY_PRESSED:
    MOV AH,0
    INT 16H
        
    CMP AH,48H
    JE UPKEY

    CMP AH,50H
    JE DOWNKEY
            
    CMP AH,39H
    JE SPACEKEY
            
    CMP AH,4BH
    JE LEFTKEY
            
    JMP INSIDE_LOOP
        
LEFTKEY:
    INC MISS
                    
    LEA BX,STATE_BUF
    CALL SHOW_SCORE 

    LEA DX,STATE_BUF
    MOV AH,09H
    INT 21H
            
    MOV AH,2
    MOV DL, 0DH
    INT 21H

    JMP INSIDE_LOOP
            

UPKEY:
    MOV DIRECTION, 8D
    JMP INSIDE_LOOP
        
DOWNKEY:
    MOV DIRECTION, 2D
    JMP INSIDE_LOOP
            
SPACEKEY:
    CMP ARROW_STATUS,0
    JE  FIRE_ARROW
    JMP INSIDE_LOOP
        
FIRE_ARROW:
    MOV DX, PLAYER_POS
    MOV ARROW_POS, DX
            
    MOV DX,PLAYER_POS
    MOV ARROW_LIMIT, DX
    ADD ARROW_LIMIT, 22D
            
    MOV ARROW_STATUS, 1D
    JMP INSIDE_LOOP
        

MISS_LOON:
    ADD MISS,1

    LEA BX,STATE_BUF
    CALL SHOW_SCORE 

    LEA DX,STATE_BUF
    MOV AH,09H
    INT 21H

    MOV AH,2
    MOV DL, 0DH
    INT 21H

    JMP FIRE_LOON
            

FIRE_LOON:
    MOV LOON_STATUS, 1D
    MOV LOON_POS, 3860D

    JMP RENDER_LOON
            

HIDE_ARROW:
    MOV ARROW_STATUS, 0
                    
    MOV CL, ' '
    MOV CH, 1111B
            
    MOV BX,ARROW_POS 
    MOV ES:[BX], CX
            
    CMP LOON_POS, 0D 
    JLE MISS_LOON
    JNE RENDER_LOON 
            

GAME_OVER:
    MOV AH,09H
    MOV DX, OFFSET GAME_OVER_STR
    INT 21H
            
    MOV MISS, 0D
    MOV HITS,0D
            
    MOV PLAYER_POS, 1760D
        
    MOV ARROW_POS, 0D
    MOV ARROW_STATUS, 0D 
    MOV ARROW_LIMIT, 22D
        
    MOV LOON_POS, 3860D
    MOV LOON_STATUS, 0D
                 
    MOV DIRECTION, 0D

INPUT:
    MOV AH,1
    INT 21H
    CMP AL,13D
    JNE INPUT

    CALL CLEAR_SCREEN
    JMP MAIN_LOOP
            

GAME_MENU:
    MOV AH,09H
    MOV DX, OFFSET GAME_START_STR
    INT 21H

INPUT2:
    MOV AH,1
    INT 21H
    CMP AL,13D
    JNE INPUT2

    CALL CLEAR_SCREEN
                
    LEA BX,STATE_BUF
    CALL SHOW_SCORE 

    LEA DX,STATE_BUF
    MOV AH,09H
    INT 21H
            
    MOV AH,2
    MOV DL, 0DH
    INT 21H
                
    JMP MAIN_LOOP
        
EXIT_GAME:
    MOV EXIT,10D
    
MAIN ENDP


SHOW_SCORE PROC
    LEA BX,STATE_BUF
        
    MOV DX, HITS
    ADD DX,48D 
        
    MOV [BX+4], 'H'
    MOV [BX+5], 'I'                                        
    MOV [BX+6], 'T'
    MOV [BX+7], 'S'
    MOV [BX+8], ':'
    MOV [BX+9], DX
        
    MOV DX, MISS
    ADD DX,48D
    MOV [BX+11], 'M'
    MOV [BX+12], 'I'
    MOV [BX+13], 'S'
    MOV [BX+14], 'S'
    MOV [BX+15], ':'
    MOV [BX+16], DX

    RET    
SHOW_SCORE ENDP 


CLEAR_SCREEN PROC NEAR
    MOV AH,0
    MOV AL,3
    INT 10H
    RET
CLEAR_SCREEN ENDP

END MAIN
