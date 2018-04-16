*-----------------------------------------------------------
* Title      : Assembly Project
* Written by : Oisín Moore C00226958
* Date       : 13/04/2018
* Description:
*-----------------------------------------------------------
    org $1000

*-------------------------------------------------------
* In This World Only Raiding Castles Matters
*-------------------------------------------------------

*-------------------------------------------------------
*Validation values to be used, modify as needed
*Add additional validation values as required
*-------------------------------------------------------
exit        EQU 0      used to exit assembly program
min_feed    EQU 100    min feed requirement
min_horses  EQU 1      min number of horses
max_horses  EQU 4      max number of horses
min_soldier EQU 1     min soldiers


*Start of Game
start:
    move.b  #100,$9000 put health in memory location $9000
    move.b  #0,$10000 add feed for the horses
    lea     $4000,A3   assign address A3 to that memory location


    bsr     welcome    branch to the welcome subroutine
    bsr     input      branch to the input subroutine
    bsr     game       branch to the game subroutine
*Game loop
    org     $3000      the rest of the program is to be located from 3000 onwards

*-------------------------------------------------------
*-------------------Game Subroutine---------------------
*-------------------------------------------------------
game:
    bsr     gameloop   branch to gameloop subroutine
                             
end:
    simhalt

*-------------------------------------------------------
*-------------------Welcome Subroutine------------------
*-------------------------------------------------------
welcome:
    lea     welcome_msg,A1  assign message to address register A1
    move.b  #14,D0          move literal 14 to DO
    trap    #15             trap and interpret value in D0
    lea     opening_msg,A1     assign message to address register A1
    move.b  #14,D0          move literal 14 to DO
    trap    #15             trap and interpret value in D0
    bsr     input

*-------------------------------------------------------
*---------Gameplay Input Values Subroutine--------------
*-------------------------------------------------------    
input:
    bsr     feed            branch to feed input subroutine
    bsr     horses          branch to ship input subroutine
    bsr     distance        branch to mission distance/location input subroutine
    bsr     soldiers        branch to soldiers input subroutine
    

*-------------------------------------------------------
*----------------Gameloop (main loop)-------------------
*------------------------------------------------------- 
gameloop:
    bsr     update          branch to update game subroutine 
    bsr     clear_screen    clears the screen         
    bsr     draw            branch to draw screen subroutine
    bsr     clear_screen    clears the screen
    bsr     gameplay        branch to gameplay subroutine
    bsr     clear_screen    clears the screen
    bsr     hud             branch to display HUD subroutine
    bsr     clear_screen    clears the screen
    bsr     replay          branch to replay game subroutine
    bsr     clear_screen    clears the screen
*-------------------------------------------------------
*---------------Update Mission Progress-----------------
*  Move to battle location, engage enemy, fire and take
*  fire, complete mission and return to base
*------------------------------------------------------- 
update:
    bsr     endl            print a CR and LF
    bsr     decorate        decorate with dots using a loop
    lea     update_msg,A1   
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts
*-------------------------------------------------------
*---------------Draw Mission Updates--------------------
* Draw the game progress information, status regarding
* mission
*------------------------------------------------------- 
draw:
    bsr     endl
    bsr     decorate
    lea     draw_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts
*-------------------------------------------------------
*-----------------------Horse feed-----------------------
* Input the feed load for each horse. Feed costs money
* For an advanced mark you need to manage this resource
*------------------------------------------------------- 
feed:
    bsr     decorate
    lea     feed_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  #4,D0
    trap    #15
    cmp.l   #100,D1
    blt     INVALID
    cmp.l   #200,D1
    cmp.l   #300,D1
    cmp.l   #400,D1
    bgt     INVALID
    bsr     decorate
    bsr     horses
    rts
    
INVALID:
    bsr     decorate
    lea     invalid_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     feed
*-------------------------------------------------------
*--------------------Horses Inventory---------------------
* Number of horses to be allocated to a mission 
*------------------------------------------------------- 
horses:
    bsr     decorate
    lea     horses_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  #4,D0
    trap    #15
    cmp.l   #1,D1
    blt     INVALID2
    cmp.l   #2,D1
    cmp.l   #3,D1
    cmp.l   #4,D1
    bgt     INVALID2
    bgt     INVALID2
    bsr     decorate
    bsr     soldiers
    rts

INVALID2:
    bsr     decorate
    lea     invalid_msg2,A1
    move.b  #14,D0
    trap    #15
    bsr     horses

*-------------------------------------------------------
*------------------Mission Distance---------------------
* Distance to battle location
*------------------------------------------------------- 
distance:
    bsr     decorate
    lea     distance_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  #4,D0
    trap    #15
    cmp.b   #1,D1
    beq     AldiasKeep
    sub     #25,$9000
    
    
    cmp.b   #2,D1
    beq     VendricksCastle
    sub     #50,$9000
    bsr     decorate
    

AldiasKeep:
    bsr     decorate
    lea     distancetoaldias_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    bsr     AttackAbom


AttackAbom:  
    bsr     decorate
    lea     Attack_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  #4,D0
    trap    #15
    cmp.b   #2,D0
    bgt     collision_hit     
    cmp.b   #2,D0
    blt     collision_miss  
    bsr     decorate
    bsr     endl
victory_screen:
    bsr     decorate
    bsr     decorate
    bsr     decorate
    lea     victory_msg,A1
    move    #14,D0
    trap    #15
    bsr     decorate
    bsr     decorate
    bsr     decorate
    bsr     start

VendricksCastle:
    bsr     decorate
    lea     distancetovendricks_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     AttackVendrick
    bsr     decorate
    
AttackVendrick:
    bsr     decorate
    lea     Attack_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  #4,D0
    trap    #15
    cmp.b   #2,D0
    bgt     collision_hit     
    cmp.b   #2,D0
    blt     collision_miss   

death_screen:
    bsr     decorate
    bsr     decorate
    bsr     decorate
    lea     death_msg,A1
    move    #14,D0
    trap    #15
    bsr     decorate
    bsr     decorate
    bsr     decorate
    bsr     start

*-------------------------------------------------------
*-----------------------Soldiers----------------------
* Number of soldiers
*-------------------------------------------------------   
soldiers:
    bsr     endl
    bsr     decorate
    lea     soldiers_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  #4,D0
    trap    #15
    cmp.b   #1,D1
    bsr     decorate
    bsr     distance
    rts

*-------------------------------------------------------
*---Game Play (Mission Progress, Battle Maneuvers)------
*------------------------------------------------------- 
gameplay:
    bsr     endl
    bsr     decorate
    lea     gameplay_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate

    rts

*-------------------------------------------------------
*-----------------Heads Up Display (Score)--------------
* Retrieves the score from memory location
*-------------------------------------------------------   
hud:

    bsr     endl
    bsr     decorate
    lea     hud_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  (A3),D1     retrieve the value A3 point to and move to D1
    move.b  #3,D0       move literal 3 to D0
    trap    #15         intrepret value in D0, which 3 which displays D1
    bsr     decorate
    rts

*-------------------------------------------------------
*-----------------------Taking Fire---------------------
* This could be used for collision detection, if 
*-------------------------------------------------------

collision_hit:
    *hit
    lea     victory_msg,A1
    move    #14,D0
    trap    #15
    bsr     Clear_screen
    bsr     victory_screen    
collision_miss:
    *miss
    lea     death_msg,A1
    move    #14,D0
    trap    #15
    bsr     Clear_screen
    bsr     death_screen
   
*-------------------------------------------------------
*--------------------------Loop-------------------------
*-------------------------------------------------------
loop:
    move.b  #5, D3 loop counter D3=5
next:
    lea     loop_msg,A1
    move.b  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
    bne     next    repeat until D0=0

*-------------------------------------------------------
*------------------Screen Decoration--------------------
*-------------------------------------------------------
decorate:
    move.b  #60, D3
    bsr     endl
out:
    lea     loop_msg,A1
    move.b  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
    bne     out	    repeat until D0=0
    bsr     endl
    rts
    
clear_screen: 
    move.b  #11,D0      clear screen
    move.w  #$ff00,D1
    trap    #15
    rts
*-------------------------------------------------------
*------------------------Replay-------------------------
*-------------------------------------------------------
replay:
    bsr     endl
    lea     replay_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15

    cmp     #exit,D1
    beq     end         if SR Z register contains 1 beq => Branch Equals
    bsr     gameloop

endl:
    movem.l D0/A1,-(A7)
    move    #14,D0
    lea     crlf,A1
    trap    #15
    movem.l (A7)+,D0/A1
    rts
    
*-------------------------------------------------------
*-------------------Data Delarations--------------------
*-------------------------------------------------------

crlf:           dc.b    $0D,$0A,0
welcome_msg:    dc.b    '************************************************************'
                dc.b    $0D,$0A
                dc.b    'ZorkQuest: Assault on Vendricks Castle'
                dc.b    $0D,$0A
                dc.b    '************************************************************'
                dc.b    $0D,$0A,0
opening_msg:    dc.b    'Hey soldier go feed the horses so we can leave'
                dc.b    $0D,$0A,0

feed_msg:       dc.b    'Feed load (each horse needs at least 100 unit of feed 400 max amount of feed)'
                dc.b    $0D,$0A
                dc.b    'Enter feed load : ',0
invalid_msg:    dc.b    'please pick a number between 100 and 400',0
horses_msg:     dc.b    'Number of horses : ',0
invalid_msg2:   dc.b    'please pick a number between 1 and 4'
distance_msg:   dc.b    'Assault the 1)Aldias keep cost25 or 2)Vendricks Castle50'
                dc.b    'Horses without feed are lost.'
                dc.b    $0D,$0A
                dc.b    'Enter mission distance : ',0 
distancetoaldias_msg: dc.b 'The Knights grow restless as they close in on Aldias keep' 
                dc.b    $0D,$0A
                dc.b    'It is well known for Aldias experiments on its victims'
                dc.b    $0D,$0A
                dc.b    'As the Knights approach the keep the Gate slams open its an ABONANATION'
                dc.b    $0D,$0A
                dc.b    'How will you attack'
                dc.b    $0D,$0A
                dc.b    'Enter attack : ',0
Attack_msg:     dc.b    '1 for light attack 2 for heavy',0
distancetovendricks_msg: dc.b 'Vendricks Castle has been under siege from Aldias abominations ' 
                dc.b    $0D,$0A 
                dc.b    'For weeks dead bodies have littered the grounds of Vendricks castle'
                dc.b    $0D,$0A 
                dc.b    'only one person has been left standing and it is King Vendrick Himself',0
victory_msg     dc.b    'You have slain your foe the spoils of the castle are now yours',0
death_msg       dc.b    'You have been killed',0
hit_msg         dc.b    'Your light attack did nothing to the foe',0                
soldiers_msg:   dc.b    'Each horses need at least 1 Knight'
                dc.b    $0D,$0A
                dc.b    '#choose your knights they must match your num of horses'
                dc.b    $0D,$0A
                dc.b    'Enter # of Knights : ',0
gameplay_msg:   dc.b    'Add Gameplay !',0
update_msg:     dc.b    'Update Gameplay !',0
draw_msg:       dc.b    'Draw Screen !',0

miss_msg:       dc.b    'Miss!',0
loop_msg:       dc.b    '.',0
replay_msg:     dc.b    'Enter 0 to Quit any other number to replay : ',0
hud_msg:        dc.b    'Score : ',0
health:     ds.w    1
score:      ds.w    1 reserve space for score

    end start



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
