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
add r0, #1 
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
ldr r3, =0x202BCF0 @ gChData 
ldrb r0, [r3, #0x0F] 
cmp r0, #0 
beq Exit_ClearNextAi 
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
ClearStuffLoop: 
cmp r5, r4 
@bgt Exit_ClearNextAi 
bgt MakeNewList 
ldrb r0, [r5] 
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

