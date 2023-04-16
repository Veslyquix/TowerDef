.thumb 
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm
.type SavePlayerCoord, %function 
.global SavePlayerCoord
SavePlayerCoord: 
push {lr} 
mov r0, #0x31 
add r0, r4 
mov r12, r0 
mov r0, #1 
mov r1, r12 
strb r0, [r1] 

ldr r3, =0x3004E50 @ gCurrentUnit 
ldr r3, [r3] 
ldrh r0, [r3, #0x10] @ xxyy 
ldr r2, =0x202bd34 @ unused bytes in gChData ? 
strh r0, [r2] 
pop {r0} 
bx r0 
.ltorg 


.type ResetPlayerCoord, %function 
.global ResetPlayerCoord
ResetPlayerCoord: 
push {lr} 
@ r1 = current char 
ldrb r0, [r1, #0x0B] @ deployment byte 
lsr r0, #7 
cmp r0, #0 
bne VanillaBehaviour 
ldr r3, =0x202bd34 
ldrb r0, [r3] @ xx 
ldrb r3, [r3, #1] @ yy 
strb r0, [r1, #0x10] @ xx 
strb r3, [r1, #0x11] @ yy 
ldr r2, =0x203AA94
strb r0, [r2, #2] @ these coords are what are saved after battle 
strb r3, [r2, #3] 
@ldr r2, =0x203A4EC @ atkr - this makes them attack as if from range
@strb r0, [r2, #0x10] 
@strb r3, [r2, #0x11] 
b Exit 

VanillaBehaviour: 
@ r1 = unit 
ldr r2, =0x203AA94
ldrb r0, [r2, #2] @ x 
ldrb r3, [r2, #3] @ y 
strb r0, [r1, #0x10] 
strb r3, [r1, #0x11] 

Exit: 
pop {r0} 
bx r0 
.ltorg 

.equ MemorySlot,0x30004B8
.equ CurrentUnit, 0x3004E50
.equ EventEngine, 0x800D07C
.equ NextRN_N, 0x8000C80
.equ GetPhaseAbleUnitCount, 0x8024CEC
.global PutRandomEnemyIntoMemSlot2
.type PutRandomEnemyIntoMemSlot2, %function 
PutRandomEnemyIntoMemSlot2: 
push {lr} 

ldr r0, =Enemy_NumberOfEntries 
ldr r0, [r0] 
blh NextRN_N 
ldr r3, =TableOfEnemiesToLoad 
lsl r0, #2 
ldr r2, =MemorySlot 
ldr r0, [r3, r0] 
str r0, [r2, #4*2] 
pop {r0} 
bx r0 
.ltorg 

	.equ GetUnit, 0x8019430
.global CountHalfPlayers 
.type CountHalfPlayers, %function 
CountHalfPlayers: 
push {lr} 
mov r0, #0 
blh GetPhaseAbleUnitCount 
lsr r0, #1 @ half rounded up 
add r0, #1 
ldr r3, =MemorySlot 
str r0, [r3, #4*0x0C] 
pop {r0} 
bx r0 
.ltorg 

.global MaybeClearNextAIActor
.type MaybeClearNextAIActor, %function 
MaybeClearNextAIActor:
push {r4-r6, lr} 

ldr r3, =gCurrentUnit 
ldr r3, [r3] 
ldr r3, [r3] @ char 
ldr r2, =0x8806770
cmp r2, r3 
bne NoBreak 
mov r11, r11 
NoBreak: 

ldr r3, =0x202BCF0 @ gChData 
ldrb r0, [r3, #0x0F] 
cmp r0, #0 
beq Exit_ClearNextAi @ do nothing on player phase 
ldr r0, =0x203A56C
ldr r1, =0x8807164 
ldr r0, [r0] 
cmp r0, r1 
bne ContinueNormal 
bl ClearAiList @ after attacking the wall, end the turn 
b Exit_ClearNextAi 

ContinueNormal: 
ldr r4, =0x203AA78 @ poin to the next actor 
ldr r5, [r4] 
cmp r5, #0 
beq MakeNewList 
ldrb r0, [r5] 
cmp r0, #0 
beq MakeNewList 

ldr r6, =0x1000C @ escaped, undeployed, dead
@ldr r6, =0x1000E @ escaped, undeployed, dead, acted
ClearStuffLoop: 
cmp r5, r4 
@bgt Exit_ClearNextAi 
bgt MakeNewList 
ldrb r0, [r5] 
cmp r0, #0 
beq MakeNewList 
blh GetUnit 
cmp r0, #0 
beq NextClearLoop
ldr r1, [r0] 
cmp r1, #0 
beq NextClearLoop
ldr r1, [r0, #0x0C] 
tst r1, r6 
bne NextClearLoop 
str r5, [r4] 
b Exit_ClearNextAi

NextClearLoop: 
add r5, #1 
b ClearStuffLoop
 
MakeNewList: 
bl ClearAiList 
mov r0, #0 
bl RefreshFaction
mov r0, #0x40 
bl RefreshFaction 
mov r0, #0x80 
bl RefreshFaction 
bl BuildAiUnitListAll
ldr r3, =0x203AA04 
str r3, [r4] 
Exit_ClearNextAi: 
pop {r4-r6} 
pop {r0} 
bx r0 
.ltorg 

ClearAiList:
mov r0, #0 
ldr r3, =0x203AA04 
ldr r2, =0x203AA78 
SomeLoop: 
str r0, [r3] 
add r3, #4 
cmp r3, r2 
blt SomeLoop 
bx lr 

.global HalfMovementOnEnemyPhase
.type HalfMovementOnEnemyPhase, %function 
HalfMovementOnEnemyPhase:
push {lr} 
ldr r3, =0x202BCF0 @ gChData 
ldrb r2, [r3, #0x0F] 
cmp r2, #0 
beq DoNothing 
ldrb r2, [r1, #0x0B] 
lsr r2, #7 
cmp r2, #0 
bne DoNothing @ enemies don't have reduced mvt 
lsr r0, #1 

DoNothing: 
pop {r1} 
bx r1 
.ltorg 

.equ AiScriptCmd_0C_MoveTowardsSetPoint, 0x803CB88
.equ gCurrentUnit, 0x3004E50 
.equ AiDecision, 0x203AA94
.global TryBreakWall
.type TryBreakWall, %function 
TryBreakWall: 
push {r4, lr} 

ldr r0, =0x803D228 @ try attack snag/wall  
mov lr, r0 
ldr r0, =gCurrentUnit
ldr r0, [r0] 
add r0, #0x45
ldrb r1, [r0] 
.short 0xf800 


mov r0, #1 @ true 
ldr r2, =AiDecision 
ldrh r2, [r2, #2] @ xxyy 
ldr r3, =gCurrentUnit 
ldr r3, [r3] 
ldrh r1, [r3, #0x10] 
cmp r2, r1 
beq DontBreakWall 
b BreakWall 


 

DontBreakWall: 


mov r0, #0xE
mov r1, #0xD @ move towards gate 
add r3, #0x44 @ ai2 counter 
@strb r1, [r3] 
strb r0, [r3, #1] 


ldr r2, =AiDecision 
mov r1, #0 
str r1, [r2]
str r1, [r2, #4]
str r1, [r2, #8]



.equ gpAiScriptCurrent, 0x30017D0 

@ move towards enemies 
@ldr r0, =gpAiScriptCurrent
@ldr r0, [r0] 
@mov r1, #255 @ safety 
@strb r1, [r0, #2] @ safety 
@
@
@ldr r0, =0x803CE18 
@mov lr, r0 
@ldr r0, =0x3004E50 
@ldr r0, [r0] 
@add r0, #0x45
@.short 0xf800 
@
@mov r0, #1 
@ldr r2, =AiDecision 
@ldrh r2, [r2, #2] @ xxyy 
@ldr r3, =gCurrentUnit 
@ldr r3, [r3] 
@ldrh r1, [r3, #0x10] 
@cmp r2, r1 
@bne BreakWall 


ldr r0, =gpAiScriptCurrent
ldr r0, [r0] 
mov r1, #255 @ safety 
strb r1, [r0, #2] @ safety 
mov r1, #13 
mov r2, #3 @ beside gate 
strb r1, [r0, #1] @ xx 
strb r2, [r0, #3] @ yy 

ldr r0, =AiScriptCmd_0C_MoveTowardsSetPoint 
mov lr, r0 
ldr r0, =0x3004E50 
ldr r0, [r0] 
add r0, #0x45
.short 0xf800 

ldr r2, =AiDecision 
mov r0, #5 @ staff 
strb r0, [r2] 
strb r0, [r2, #0x0B] @ action taken 


mov r0, #1 


BreakWall: @ returns 1 true or 0 false 
pop {r4} 
pop {r1} 
bx r1 
.ltorg 

 @ at 2A8C4 does bl Can_Attack_Target 801ACFC 

.global P_CounterUncounterable
.type P_CounterUncounterable, %function 
P_CounterUncounterable: 
push {r4-r7, lr} 
mov r4, r0 @attacker
mov r5, r1 @defender
mov r6, r2 @battle buffer
mov r7, r3 @battle data

mov r0, r5 @ unit 
ldr r1, =CounterUncounterableID
lsl r1, #24 
lsr r1, #24 
bl SkillTester 
cmp r0, #0 
beq ExitP_CounterUncounterable
mov r0, #1 
mov r1, #0x52 
add r1, r5  
strb r0, [r1] @ s8 canCounter 

ExitP_CounterUncounterable: 
pop {r4-r7} 
pop {r0} 
bx r0 
.ltorg 

.equ Defender, 0x203a56c @ defender 
.equ gBattleStats, 0x203A4D4 
.equ Can_Attack_Target, 0x801ACFC 
.global CounterUncounterable_3
.type CounterUncounterable_3, %function 
CounterUncounterable_3: 
push {lr} 

ldr r3, =Defender 
cmp r3, r5 
bne Vanilla_CounterUncounterable 
mov r0, r5 @ unit 
ldr r1, =CounterUncounterableID
lsl r1, #24 
lsr r1, #24 
bl SkillTester 
cmp r0, #0 
bne ExitCounterUncounterable_3 

Vanilla_CounterUncounterable: 
ldrh r0, [r4] 
ldr r1, =gBattleStats 
ldrb r1, [r1, #2] 
mov r2, r5 
blh Can_Attack_Target 


ExitCounterUncounterable_3: 
pop {r3} 
bx r3 
.ltorg 

