#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "ep1c: AWP Fast"
#define VERSION "1.0"
#define AUTHOR "Wilian M."

new cvar_fast_sniper_delay

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	cvar_fast_sniper_delay = register_cvar("fast_sniper_delay", "0.75")
	
	RegisterHam(Ham_Item_Deploy, "weapon_awp",   "ham_item_deploy", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_scout", "ham_item_deploy", 1)
}

public ham_item_deploy(iEnt)
{
	if(!pev_valid(iEnt))
		return HAM_IGNORED
	
	new iPlrId = get_pdata_cbase(iEnt, 41, 4)
	
	if(!is_user_alive(iPlrId))
		return HAM_IGNORED
	
	if(iEnt!=get_pdata_cbase(iPlrId, 373, 5) || get_pdata_float(iEnt, 76, 4)!=get_gametime())
		return HAM_IGNORED
	
	switch(get_pdata_int(iEnt, 43, 4))
	{
		case CSW_AWP:
		{
			set_pdata_float(iEnt, 46, get_pcvar_float(cvar_fast_sniper_delay), 4)
			set_pdata_float(iEnt, 47, get_pcvar_float(cvar_fast_sniper_delay), 4)
			set_pdata_float(iPlrId, 83, get_pcvar_float(cvar_fast_sniper_delay), 5)
		}
		case CSW_SCOUT:
		{
			set_pdata_float(iEnt, 46, get_pcvar_float(cvar_fast_sniper_delay), 4)
			set_pdata_float(iEnt, 47, get_pcvar_float(cvar_fast_sniper_delay), 4)
			set_pdata_float(iPlrId, 83, get_pcvar_float(cvar_fast_sniper_delay), 5)
		}
	}
	
	return HAM_IGNORED
}
