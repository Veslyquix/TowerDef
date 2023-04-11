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


.global CountHalfPlayers 
.type CountHalfPlayers, %function 
CountHalfPlayers: 
push {lr} 
mov r0, #0 
blh GetPhaseAbleUnitCount 
lsr r0, #1 @ half 
add r0, #1 
ldr r3, =MemorySlot 
str r0, [r3, #4*0x0C] 
pop {r0} 
bx r0 
.ltorg 




