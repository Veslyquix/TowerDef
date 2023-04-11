.align 4
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm
	.thumb

	.equ MemorySlot, 0x30004B8 
	.equ GetUnitByEventParameter, 0x0800BC51
	.equ HandleAllegianceChange, 0x801034D 
	.equ EventEngine, 0x800D07C
	
	.equ GetUnit, 0x8019431

.global ChangeS1UnitIntoLowestUnitID
.type ChangeS1UnitIntoLowestUnitID, %function 
ChangeS1UnitIntoLowestUnitID:
push {r4-r5, lr}
bl FindFreeSlot
mov r4, r0 
ldr r3, =MemorySlot 
ldr r0, [r3, #0x1*4] @ s1 as unit ID 
blh GetUnitByEventParameter
cmp r0, #0 
beq Change_Error
mov r5, r0 @ Unit ram 
cmp r4, #0xFF 
beq Change_Error

mov r0, r4 
mov r1, #0x34 @ Size of Character table 
mul r0, r1 
ldr r3, =0x8017D64 @ POIN CharacterTable 
ldr r3, [r3] @ Char table unit 0 
add r0, r3 @ Character table entry 
str r0, [r5] @ change unit pointer 


ldr r3, =MemorySlot 
ldrh r0, [r3, #4*0x0C]
ldrh r1, [r3, #4*0x0C+2]
strb r0, [r5, #0x10] 
strb r1, [r5, #0x11] 

	blh  0x0801a1f4   @RefreshFogAndUnitMaps
	blh  0x080271a0   @SMS_UpdateFromGameData
	blh  0x08019c3c   @UpdateGameTilesGraphics

Change_Error:

pop {r4-r5} 
pop {r0}
bx r0
.ltorg 
.align 


.global FindFreeSlot
.type FindFreeSlot, %function 
FindFreeSlot:
push {r4, lr}
ldr r3, =0x8017D64 @ POIN CharacterTable 
ldr r3, [r3] @ Char table unit 0 

mov r4, #0x01 @counter 


LoopThroughUnits:
mov r0, r4 
cmp r4, #40 @ 0x3F theoretical maximum 
bgt Error 		@ Can't have more than 40 units. Ten Units (0x29 - 0x33) are reserved for special events 
blh GetUnitByEventParameter @ 0x0800BC51
cmp r0,#0
beq FoundUnit
@NextUnit:
add r4,#1
b LoopThroughUnits 
Error:
mov r4, #0xFF 
FoundUnit:
mov r0, r4 

pop {r4}
pop {r1}
bx r1 

.ltorg 
.align 

	