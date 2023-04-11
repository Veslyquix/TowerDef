#include "gbafe.h"
#include "stdlib.h" 
extern u8 * * gMapRange;
extern u8 * * gMapMovement2;
extern u8 * * gMapMovement;
extern u8 * * gMapUnit;
extern u8 * * gMapTerrain;
int CouldUnitBeInRangeHeuristic(struct Unit* unit, struct Unit* other, int item);
void FillMovementAndRangeMapForItem(struct Unit* unit, int item);
extern struct AiState gAiState;
#define UNIT_MOV(aUnit) ((aUnit)->movBonus + UNIT_MOV_BASE(aUnit))
#define UNIT_MOV_BASE(aUnit) ((aUnit)->pClassData->baseMov)

struct AiState
{
    /* 00 */ u8 units[116];
    /* 74 */ u8* unitIt;
    /* 78 */ u8 orderState;
    /* 79 */ u8 decideState;
    /* 7A */ s8 dangerMapFilled; // bool
    /* 7B */ u8 flags;
    /* 7C */ u8 unk7C;
    /* 7D */ u8 combatWeightTableId;
    /* 7E */ u8 unk7E;
    /* 7F */ u8 unk7F;
    /* 80 */ u32 specialItemFlags;
    /* 84 */ u8 unk84;
    /* 85 */ u8 bestBlueMov;
    /* 86 */ u8 unk86[8];
};
enum
{
    AI_FLAGS_NONE = 0,

    AI_FLAG_0 = (1 << 0),
    AI_FLAG_1 = (1 << 1), // do not move 
    AI_FLAG_BERSERKED = (1 << 2),
    AI_FLAG_3 = (1 << 3),
};
extern u8** gWorkingBmMap;
extern u8 gWorkingTerrainMoveCosts[];

extern int BuildAiUnitList(void);
extern void SortAiUnitList(int count);
void AiDecideMain(void);
extern void(*AiDecideMainFunc)(void);
extern int GetUnitAiPriority(struct Unit* unit);
extern void PidStatsSubFavval08(u8 pid);
void RefreshFaction(int faction); 
extern void PlayerPhase_HandleAutoEnd(Proc* proc); 
extern void PhaseSwitchGfx(Proc* proc); 


void NewPlayerPhase_HandleAutoEnd(Proc* proc) { 
	RefreshFaction(0); 
	PhaseSwitchGfx(proc); 
	//SMS_UpdateFromGameData();
	//RenderBmMap();
	//PlayerPhase_HandleAutoEnd(proc); 
} 

int BuildAiUnitListAll(void); 
#define CONST_DATA const __attribute__((section(".data")))
u32* CONST_DATA sUnitPriorityArray = (void*) gGenericBuffer;
void NewCpOrderFunc_BeginDecide(Proc* proc)
{
	int unitAmt = 0; 
	if (gChapterData.currentPhase>>7) { // on enemy phase only 
		RefreshFaction(0); // refresh players 
		RefreshFaction(0x40); // refresh NPCs 
		RefreshFaction(0x80); // refresh enemies 
		unitAmt = BuildAiUnitListAll(); // for current phase 
	} 

    if (unitAmt != 0)
    {
        SortAiUnitList(unitAmt);

        gAiState.units[unitAmt] = 0;
        gAiState.unitIt = gAiState.units;

        AiDecideMainFunc = AiDecideMain;

        ProcStartBlocking(gProc_CpDecide, proc);
    }
	//else { 
	//	asm("mov r11, r11"); // 0x801DF0A
	//	RefreshFaction(0); 
	//} 
}




// 18890 
// 39E2C AiDecisionMaker_AiScript2 
// 39B88 in CpDecide_Main at 39B00 

int BuildAiUnitListAll(void)
{
	int aiNum = 0; 
    int phaseNum = false;
    u32* prioIt = sUnitPriorityArray;
	
    //int factionUnitCountLut[3] = { 62, 20, 50 }; // TODO: named constant for those

    //for (i = 0; i < factionUnitCountLut[faction >> 6]; ++i)
	//for (int c = 0; c<25; c++) { 
		for (int i = 0; i < 0xBF; ++i)
		{
			if (aiNum > 120) break; 
			//struct Unit* unit = GetUnit(faction + i + 1);
			struct Unit* unit = GetUnit(i + 1);

			if (!unit->pCharacterData)
				continue;

			if (unit->statusIndex == UNIT_STATUS_SLEEP)
				continue;

			if (unit->statusIndex == UNIT_STATUS_BERSERK)
				continue;

			if (unit->state & (US_NOT_DEPLOYED | US_DEAD | US_RESCUED | US_HAS_MOVED_AI)) // | US_UNSELECTABLE
				continue;
			if ((unit->index & 0xC0) == gChapterData.currentPhase) phaseNum = true; 

			//gAiState.units[aiNum] = faction + i + 1;
			gAiState.units[aiNum] = i + 1;
			*prioIt++ = GetUnitAiPriority(unit);

			aiNum++;
		}

	if (phaseNum) return aiNum; 
    return false;
}

#define UNIT_IS_VALID(aUnit) ((aUnit) && (aUnit)->pCharacterData)
void RefreshFaction(int faction) {
    int i;

    if (faction == 0) { // blue 
        int i;

        for (i = 1; i < 0x40; ++i) {
            struct Unit* unit = GetUnit(i);

            if (!UNIT_IS_VALID(unit))
                continue;

            if (UNIT_CATTRIBUTES(unit) & CA_SUPPLY)
                continue;

            if (unit->state & (US_UNAVAILABLE | US_UNSELECTABLE))
                continue;

            PidStatsSubFavval08(unit->pCharacterData->number);
        }
    }

    for (i = faction + 1; i < faction + 0x40; ++i) {
        struct Unit* unit = GetUnit(i);

        if (UNIT_IS_VALID(unit))
            unit->state = unit->state &~ (US_UNSELECTABLE | US_HAS_MOVED | US_HAS_MOVED_AI);
    }
}


