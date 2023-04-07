.include "C:/devkitPro/FE-CLib/reference/FE8U-20190316.s"
.include "Hooks.s"

SET_FUNC BuildAiUnitList, 0x80399b1
SET_FUNC SortAiUnitList, 0x8039a51
SET_FUNC AiDecideMain, 0x8039CAD 
SET_FUNC PidStatsSubFavval08, 0x80a48dd
SET_FUNC GetUnitAiPriority, 0x8039939
SET_FUNC PlayerPhase_HandleAutoEnd, 0x801DBA5
SET_FUNC PhaseSwitchGfx, 0x801F2AD


SET_DATA AiDecideMainFunc, 0x3004f10
SET_DATA sUnitPriorityArray, 0x2020188



// other stuff 
SET_DATA gAiState, 0x203AA04
SET_DATA gAiDecision, 0x203AA94
SET_DATA gWorkingTerrainMoveCosts, 0x3004BB0
SET_DATA gWorkingBmMap, 0x30049A0
SET_FUNC MapIncInBoundedRange, 0x801B9A5

SET_FUNC GetBallistaItemAt, 0x0803798D
SET_FUNC AiSetMovCostTableWithPassableWalls, 0x8040DCD
SET_FUNC Font_ResetAllocation, (0x08003D20+1) 
SET_FUNC Clean, (0x800F0C8+1) 
SET_DATA gCurrentTextString, 0x202A6AC
//@ Vanilla function declarations:
SET_FUNC PushToSecondaryOAM, 0x08002BB9
SET_FUNC RegisterObjectTileGraphics, 0x8012FF5
SET_FUNC GetUnitRangeMask, (0x080171E8+1)

SET_FUNC CanUnitUseWeapon, (0x8016750+1)

SET_FUNC CanUnitUseStaff, (0x8016800 + 1)

SET_FUNC DrawItemMenuCommand, (0x08016848+1)

SET_FUNC GetWeaponRangeMask, (0x080170D4+1)

SET_FUNC AttackUMEffect, (0x08022B30+1)

SET_FUNC DrawItemRText, (0x08088E60+1)

SET_FUNC RTextUp, (0x08089354+1)

SET_FUNC RTextDown, (0x08089384+1)

SET_FUNC RTextLeft, (0x080893B4+1)

SET_FUNC RTextRight, (0x080893E4+1)

SET_FUNC GetUnitEquippedItem, (0x08016B28+1)

SET_FUNC StartMovingPlatform, (0x080CD408+1)

SET_FUNC SetupMovingPlatform, (0x080CD47C+1)
SET_FUNC DeleteSomeAISStuff, (0x0805AA28+1)

SET_FUNC DeleteSomeAISProcs, (0x0805AE14+1)


SET_FUNC LockGameGraphicsLogic, 0x8030185
SET_FUNC UnlockGameGraphicsLogic, 0x80301B9
SET_FUNC MU_AllDisable, 0x80790E1
SET_FUNC MU_AllEnable, 0x80790ED

//@ Data declarations:
SET_DATA gBG0MapBuffer, 0x02022CA8

SET_DATA gBG1MapBuffer, 0x020234A8

SET_DATA gBG2MapBuffer, 0x02023CA8

SET_DATA gPlayerGold, 0x202BCF8
SET_DATA gSomeAISStruct, 0x030053A0

SET_DATA gSomeAISRelatedStruct, 0x0201FADC

SET_DATA MemorySlot, 0x30004B8




