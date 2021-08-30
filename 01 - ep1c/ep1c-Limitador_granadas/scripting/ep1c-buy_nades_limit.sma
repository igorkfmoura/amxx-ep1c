/* */
#include <amxmodx>
#include <reapi>

#if !defined MAX_PLAYERS
const MAX_PLAYERS = 32;
#endif

enum (+=1)
{
	NADE_FLASH = 0,
	NADE_HE,
	NADE_SMOKE,

	NADE_NONE
};

new const g_szMessages[][]=
{
	"BNL_FLASHBANG",
	"BNL_HEGRENADE",
	"BNL_SMOKEGRENADE"
};

new g_pCvars[NADE_NONE];
new g_iLimit[MAX_PLAYERS+1][NADE_NONE];

public plugin_init()
{
	register_plugin("ep1c: Limitador de granadas", "0.0.3a", "steelzorrr");

	RegisterHookChain(RG_CBasePlayer_HasRestrictItem, "CPlayer_HasRestrictItem_Pre", .post = false);
	RegisterHookChain(RG_CBasePlayer_Spawn, "CPlayer_Spawn_Post", .post = true);

	g_pCvars[NADE_FLASH] = register_cvar("amx_flashbang_max", "2");
	g_pCvars[NADE_HE] = register_cvar("amx_hegrenade_max", "1");
	g_pCvars[NADE_SMOKE] = register_cvar("amx_smokegrenade_max", "1");

	register_dictionary("buy_nades_limit.txt");
}

public CPlayer_HasRestrictItem_Pre(iPlayer, ItemID:iItem, ItemRestType:iType)
{
	if(iType != ITEM_TYPE_BUYING)
	{
		return HC_CONTINUE
	}

	new iKey = getKeybyItemID(iItem);

	if(iKey == NADE_NONE)
	{
		return HC_CONTINUE;
	}

	if(rg_get_user_bpammo(iPlayer, any:iItem) >= rg_get_weapon_info(any:iItem, WI_MAX_ROUNDS))
	{
		return HC_CONTINUE;
	}

	new iLimit = get_pcvar_num(g_pCvars[iKey]);

	if(++g_iLimit[iPlayer][iKey] > iLimit)
	{
		client_print(iPlayer, print_center, "%L", iPlayer, g_szMessages[iKey], iLimit);
		SetHookChainReturn(ATYPE_BOOL, true);
		return HC_SUPERCEDE;
	}

	return HC_CONTINUE;
}

public CPlayer_Spawn_Post(iPlayer)
{
	if(!is_user_connected(iPlayer))
	{
		return;
	}

	arrayset(g_iLimit[iPlayer], 0, sizeof(g_iLimit[]));
}

getKeybyItemID(ItemID:item)
{
	switch(item)
	{
		case ITEM_FLASHBANG:
		{
			return NADE_FLASH;
		}
		case ITEM_HEGRENADE:
		{
			return NADE_HE;
		}
		case ITEM_SMOKEGRENADE:
		{
			return NADE_SMOKE;
		}
	}
	return NADE_NONE;
}
