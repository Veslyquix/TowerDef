.thumb 
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
strb r0, [r2, #2] 
strb r3, [r2, #3] 
ldr r2, =0x203A4EC @ atkr 
strb r0, [r2, #0x10] 
strb r3, [r2, #0x11] 
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








