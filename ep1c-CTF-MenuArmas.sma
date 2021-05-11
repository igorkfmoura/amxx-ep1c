#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <fun>

#define PLUGIN  "ep1c-CTF-MenuArmas"
#define VERSION "0.2"
#define AUTHOR  "SHERMAN & lonewolf"

#define PREFIX_MENUS "\r[ep1c gaming Brasil]"
#define PREFIX_CHAT "^4[ep1c gaming Brasil]^1"

#if !defined MAX_MAPNAME_LENGTH
 #define MAX_MAPNAME_LENGTH 64
#endif

new g_szMapsToIgnore[][6] =
{
	"awp_",
    "aim_",
	"35hp_",
	"fy_",
	"he_"
}

enum AmmoInfo
{
  WEAPONID,
  CLIP,
  BPAMMO
};
new weapons[][AmmoInfo] =
{
  {CSW_NONE,        0,   0},
  {CSW_P228,       13,  52},
  {CSW_NONE,        0,   0},
  {CSW_SCOUT,      10,  90},
  {CSW_NONE,        0,   0},
  {CSW_XM1014,      7,  32},
  {CSW_NONE,        0,   0},
  {CSW_MAC10,      30, 100},
  {CSW_AUG,        30,  90},
  {CSW_NONE,        0,   0},
  {CSW_ELITE,      30, 120},
  {CSW_FIVESEVEN,  20, 100},
  {CSW_UMP45,      25, 100},
  {CSW_SG550,      30,  90},
  {CSW_GALIL,      35,  90},
  {CSW_FAMAS,      25,  90},
  {CSW_USP,        12, 100},
  {CSW_GLOCK18,    20, 120},
  {CSW_AWP,        10,  30},
  {CSW_MP5NAVY,    30, 120},
  {CSW_M249,      100, 200},
  {CSW_M3,          8,  32},
  {CSW_M4A1,       30,  90},
  {CSW_TMP,        30, 120},
  {CSW_G3SG1,      20,  90},
  {CSW_NONE,        0,   0},
  {CSW_DEAGLE,      7,  35},
  {CSW_SG552,      30,  90},
  {CSW_AK47,       30,  90},
  {CSW_NONE,        0,   0},
  {CSW_P90,        50, 100},
  {CSW_NONE,        0,   0},
  {CSW_NONE,        0,   0},
  {CSW_NONE,        0,   0}
};

enum Weapon
{
	W_ID,
	W_NAME[10],
	W_ENTITY[20],
	W_AMMO
};

new g_xPrimaryWeapons[][Weapon] =
{
	{CSW_AK47,  "AK47",  "weapon_ak47",  90},
	{CSW_M4A1,  "M4A1",  "weapon_m4a1",  90},
	{CSW_AWP,   "AWP",   "weapon_awp",  30},
	{CSW_FAMAS, "FAMAS", "weapon_famas", 90}
};

new g_xSecondaryWeapons[][Weapon] =
{
	{CSW_DEAGLE, "Desert", "weapon_deagle",  35},
	{CSW_USP,    "USP",    "weapon_usp",    100}
}

new g_iRemember[MAX_PLAYERS+1];
new g_iPrimary[MAX_PLAYERS+1];
new g_iSecondary[MAX_PLAYERS+1];
new g_BoughtThisRound[MAX_PLAYERS+1];
new g_iMenu[MAX_PLAYERS+1];
new bool:g_bInBuyZone[33];

new g_pCvarBuyTime;
new g_pCvarRoundTime;

new bool:g_bAllowBuy = true;

new g_iMenuGunsCheckID;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	new szMapName[MAX_MAPNAME_LENGTH];
	get_mapname(szMapName, charsmax(szMapName));

	new bSpecialMap = false;

	new iLen = sizeof(g_szMapsToIgnore);
	for (new i = 0; i < iLen; ++i)
	{
		if (equal(szMapName, g_szMapsToIgnore[i]))
		{
			bSpecialMap = true;
		}
	}

	register_logevent("RoundStart", 2, "1=Round_Start");
	register_event("HLTV", "NewRound", "a", "1=0", "2=0");

	if (!bSpecialMap)
	{
		register_event("StatusIcon", "player_inBuyZone", "be", "2=buyzone");
	}

	g_pCvarBuyTime = get_cvar_pointer("mp_buytime");
	g_pCvarRoundTime = get_cvar_pointer("mp_roundtime");

	RegisterHam(Ham_Spawn, "player", "HamSpawnPost", true);

	g_iMenuGunsCheckID = menu_makecallback("MenuGunsCheck");

	xRegisterSay("armas", "ShowMenuGuns");
}

public NewRound(id)
{
	g_bAllowBuy = true;
	remove_task(6311);
}

public RoundStart(id)
{
	new Float:fBuyTimeSeconds = 60 * get_pcvar_float(g_pCvarBuyTime);
	if (fBuyTimeSeconds < 0)
	{
	  return;
	}

	new Float:fRoundTime = 60 * get_pcvar_float(g_pCvarRoundTime);
	
	if (fBuyTimeSeconds < fRoundTime)
	{
		set_task(fBuyTimeSeconds, "DisableBuy", 6311);
	}
}

public DisableBuy(id)
{
	g_bAllowBuy = false;
	for (new i = 1; i < MaxClients; ++i)
	{
		if (!is_user_alive(i) || !g_bInBuyZone[i])
			continue;

		new menu;
  		new keys;
		new newmenu;
		player_menu_info(i, menu, newmenu, keys);
		
		if (newmenu >= 0 && newmenu == g_iMenu[i])
		{
			g_iMenu[i] = -1;
			menu_destroy(newmenu);
			//ShowMenuGuns(i);
			client_cmd(i, "slot10");
		}
	}
}


public player_inBuyZone(id)
{
	if (!is_user_alive(id))
		return;
	
	new bool:bInBuyZone = bool:read_data(1);
	
	if (bInBuyZone != g_bInBuyZone[id])
	{
		g_bInBuyZone[id] = bInBuyZone;

		new menu;
  		new keys;
		new newmenu;

		player_menu_info(id, menu, newmenu, keys);
		
		if (newmenu < 0 || newmenu != g_iMenu[id])
		{
			return;
		}

		g_iMenu[id] = -1;
		menu_destroy(newmenu);
		if (bInBuyZone)
		{
			ShowMenuGuns(id);
		}
		else
		{
			client_cmd(id, "slot10");
			GivePlayerWeapons(id);
		}
	}
}


public HamSpawnPost(id)
{
	if(is_user_alive(id))
	{
		g_BoughtThisRound[id] = false;
		g_bInBuyZone[id] = true;

		set_task(0.5, "GiveItems", 2424 + id);
	}
}

public GiveItems(id)
{
	id -= 2424;

	if(!is_user_alive(id))
		return;
	
	if(g_iRemember[id])
	{
		if (!cs_get_user_hasprim(id))
		{
			GivePlayerWeapons(id);
			return;
		}

		fill_player_ammo(id);
	}

	new menu;
  	new keys;
	new newmenu;
	player_menu_info(id, menu, newmenu, keys);
	
	if (newmenu >= 0)
		menu_destroy(newmenu);
	
	ShowMenuGuns(id);
}


public fill_player_ammo(id)
{
  for (new slot = CS_WEAPONSLOT_PRIMARY; slot <= CS_WEAPONSLOT_SECONDARY; ++slot)
  {
    new weapon_id = get_ent_data_entity(id, "CBasePlayer", "m_rgpPlayerItems", slot);
    if (is_valid_ent(weapon_id))
    {
      new weapon_type = get_ent_data(weapon_id, "CBasePlayerItem", "m_iId");
      if (weapon_type > 0 && weapon_type <= CSW_P90 && weapons[weapon_type][WEAPONID])
      {
        static weapon_name[32];
        cs_get_item_alias(weapon_type, weapon_name, charsmax(weapon_name));

        cs_set_weapon_ammo(weapon_id, weapons[weapon_type][CLIP]);
        cs_set_user_bpammo(id, weapon_type, weapons[weapon_type][BPAMMO]);

        client_print_color(id, id, "%s Refilling ^3%s^1 ammo...", PREFIX_CHAT, weapon_name);
      }
    }
  }
}

public client_connected(id)
{
	g_iRemember[id] = false;
	g_iPrimary[id] = 0;
	g_iSecondary[id] = 0;
	g_bInBuyZone[id] = false;
}

public ShowMenuGuns(id)
{
	if(!is_user_connected(id))
		return;

	new szTitle[64];
	formatex(szTitle, charsmax(szTitle), "\wMenu de Armas^n%s", PREFIX_MENUS);

	new xMenu = menu_create(szTitle, "_ShowMenuGuns");
	g_iMenu[id] = xMenu;

	static szItem[48];
	new iSecondary = g_iSecondary[id];
	new iLenPrimary = sizeof(g_xPrimaryWeapons);

	for (new i = 0; i < iLenPrimary; ++i)
	{
		formatex(szItem, charsmax(szItem), "Kit \d[%s%s + %s\d]", (g_bInBuyZone[id] && g_bAllowBuy) ? "\y" : "\d", g_xPrimaryWeapons[i][W_NAME], g_xSecondaryWeapons[iSecondary][W_NAME]);
		menu_additem(xMenu, szItem, _, _, g_iMenuGunsCheckID);
	}
	
	menu_addblank2(xMenu);

	new iNext = (iSecondary + 1) % sizeof(g_xSecondaryWeapons);
	formatex(szItem, charsmax(szItem), "\yTrocar pistola para \d[\y%s\d]", g_xSecondaryWeapons[iNext][W_NAME]);

	menu_additem(xMenu, szItem);

	if(g_iRemember[id])
		menu_additem(xMenu, "\yRelembrar seleção? \d[\yHabilitado\d]");
	else 
		menu_additem(xMenu, "\yRelembrar seleção? \d[\rDesabilitado\d]");

	menu_setprop(xMenu, MPROP_EXITNAME, "Sair");
	menu_display(id, xMenu);
}


public MenuGunsCheck(id)
{
	return (g_bInBuyZone[id] && g_bAllowBuy) ? ITEM_IGNORE : ITEM_DISABLED;
}


public _ShowMenuGuns(id, menu, item)
{
	g_iMenu[id] = -1;

	if(item == MENU_EXIT)
	{
		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	new iLen = sizeof(g_xPrimaryWeapons);
	if (item < iLen && g_bAllowBuy)
	{
		g_iPrimary[id] = item;

		GivePlayerWeapons(id);

		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	if (item == iLen + 1)
	{
		g_iSecondary[id] = (g_iSecondary[id] + 1) % sizeof(g_xSecondaryWeapons);

		menu_destroy(menu);
		ShowMenuGuns(id);
		
		return PLUGIN_HANDLED;
	}
	
	if (item == (iLen + 2))
	{
		g_iRemember[id] = !g_iRemember[id];
		
		menu_destroy(menu);
		ShowMenuGuns(id);

		return PLUGIN_HANDLED;
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}


public GivePlayerWeapons(id)
{
	if (g_BoughtThisRound[id] || !is_user_alive(id))
		return;

	strip_user_weapons(id);
	
	new item = g_iPrimary[id];	
	give_item(id, g_xPrimaryWeapons[item][W_ENTITY]);
	cs_set_user_bpammo(id, g_xPrimaryWeapons[item][W_ID], g_xPrimaryWeapons[item][W_AMMO]);
	
	new iSec = g_iSecondary[id];
	give_item(id, g_xSecondaryWeapons[iSec][W_ENTITY]);
	cs_set_user_bpammo(id, g_xSecondaryWeapons[iSec][W_ID], g_xSecondaryWeapons[iSec][W_AMMO]);

	give_item(id, "weapon_knife");
	give_item(id, "weapon_hegrenade");
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_flashbang");
	give_item(id, "item_assaultsuit");
	
	g_BoughtThisRound[id] = true;

	client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[%s + %s]^1!", PREFIX_CHAT, g_xPrimaryWeapons[item][W_NAME], g_xSecondaryWeapons[iSec][W_NAME]);
	client_print_color(id, print_team_default, "%s Para reabrir o menu de armas digite ^4/armas^1 no chat!", PREFIX_CHAT);
}


stock xRegisterSay(szsay[], szfunction[])
{
	static sztemp[64];

	formatex(sztemp, 63 , "say /%s", szsay);
	register_clcmd(sztemp, szfunction);
	
	formatex(sztemp, 63 , "say .%s", szsay);
	register_clcmd(sztemp, szfunction);
	
	formatex(sztemp, 63 , "say_team /%s", szsay);
	register_clcmd(sztemp, szfunction);
	
	formatex(sztemp, 63 , "say_team .%s", szsay);
	register_clcmd(sztemp, szfunction);
}
