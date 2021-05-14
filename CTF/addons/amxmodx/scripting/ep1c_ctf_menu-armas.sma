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
	BPAMMO,
	NAME[32],
	ENTITY[32]
};
new weapons[][AmmoInfo] =
{
	{CSW_NONE,      0,   0,   "",          ""},
	{CSW_P228,      13,  52,  "P228",      "weapon_p228"},
	{CSW_NONE,      0,   0,   "",          "weapon_shield"},
	{CSW_SCOUT,     10,  90,  "SCOUT",     "weapon_scout"},
	{CSW_NONE,      0,   0,   "",          ""},
	{CSW_XM1014,    7,   32,  "XM1014",    "weapon_xm1014"},
	{CSW_NONE,      0,   0,   "",          ""},
	{CSW_MAC10,     30,  100, "MAC10",     "weapon_mac10"},
	{CSW_AUG,       30,  90,  "AUG",       "weapon_aug"},
	{CSW_NONE,      0,   0,   "",          "weapon_smokegrenade"},
	{CSW_ELITE,     30,  120, "ELITE",     "weapon_elite"},
	{CSW_FIVESEVEN, 20,  100, "FIVESEVEN", "weapon_fiveseven"},
	{CSW_UMP45,     25,  100, "UMP45",     "weapon_ump45"},
	{CSW_SG550,     30,  90,  "SG550",     "weapon_sg550"},
	{CSW_GALIL,     35,  90,  "Galil",     "weapon_galil"},
	{CSW_FAMAS,     25,  90,  "Famas",     "weapon_famas"},
	{CSW_USP,       12,  100, "USP",       "weapon_usp"},
	{CSW_GLOCK18,   20,  120, "GLOCK18",   "weapon_glock18"},
	{CSW_AWP,       10,  30,  "AWP",       "weapon_awp"},
	{CSW_MP5NAVY,   30,  120, "MP5NAVY",   "weapon_mp5navy"},
	{CSW_M249,      100, 200, "M249",      "weapon_m249"},
	{CSW_M3,        8,   32,  "M3",        "weapon_m3"},
	{CSW_M4A1,      30,  90,  "M4A1",      "weapon_m4a1"},
	{CSW_TMP,       30,  120, "TMP",       "weapon_tmp"},
	{CSW_G3SG1,     20,  90,  "G3SG1",     "weapon_g3sg1"},
	{CSW_NONE,      0,   0,   "",          ""},
	{CSW_DEAGLE,    7,   35,  "Deagle",    "weapon_deagle"},
	{CSW_SG552,     30,  90,  "SG552",     "weapon_sg552"},
	{CSW_AK47,      30,  90,  "AK47",      "weapon_ak47"},
	{CSW_NONE,      0,   0,   "",          "weapon_knife"},
	{CSW_P90,       50,  100, "P90",       "weapon_p90"},
	{CSW_NONE,      0,   0,   "",          ""},
	{CSW_NONE,      0,   0,   "",          ""},
	{CSW_NONE,      0,   0,   "",          ""},
};

new g_iPrimaryWeaponsLen = 4;
new g_xPrimaryWeapons[CsTeams][4] =
{
	{},
	{CSW_AK47, CSW_M4A1, CSW_AWP, CSW_FAMAS},
	{CSW_AK47, CSW_M4A1, CSW_AWP, CSW_FAMAS},
	{}
};

new g_iSecondaryWeaponsLen = 4;
new g_xSecondaryWeapons[CsTeams][4] =
{
	{},
	{CSW_DEAGLE, CSW_USP},
	{CSW_DEAGLE, CSW_USP},
	{}
}

new g_iRemember[MAX_PLAYERS+1];
new g_iPrimarySelection[MAX_PLAYERS+1];
new g_iSecondarySelection[MAX_PLAYERS+1];
new g_BoughtThisRound[MAX_PLAYERS+1];
new g_iMenu[MAX_PLAYERS+1];
new CsTeams:g_iTeams[MAX_PLAYERS+1];
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
	register_event("TeamInfo", "player_joinTeam", "a");

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
			new CsTeams:team = g_iTeams[id];
			GivePlayerWeapons(id, g_xPrimaryWeapons[team][g_iPrimarySelection[id]], g_xSecondaryWeapons[team][g_iSecondarySelection[id]]);
		}
	}
}


public HamSpawnPost(id)
{
	if(is_user_alive(id))
	{
		g_BoughtThisRound[id] = false;
		g_bInBuyZone[id] = true;

		if (!task_exists(2424 + id))
			// set_task(0.5, "GiveItems", 2424 + id);
			set_task(0.3, "GiveItems", 2424 + id);
	}
}

public player_joinTeam(id)
{
	g_iRemember[id]  = false;
	g_bInBuyZone[id] = true;
	g_iTeams[id] = cs_get_user_team(id);

	g_iPrimarySelection[id]   = 0;
	g_iSecondarySelection[id] = 0;
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
			new CsTeams:team = g_iTeams[id]
			GivePlayerWeapons(id, g_xPrimaryWeapons[team][g_iPrimarySelection[id]], g_xSecondaryWeapons[team][g_iSecondarySelection[id]]);
			return;
		}
		else
		{
			// new pistol_id = get_ent_data_entity(id, "CBasePlayer", "m_rgpPlayerItems", CS_WEAPONSLOT_SECONDARY);
			// if (!is_valid_ent(pistol_id))
    		// {
			// 	new secondary = g_xSecondaryWeapons[g_iSecondary[id]];
			// 	if (secondary > CSW_NONE && secondary < CSW_P90)
			// 	{	
			// 		give_item(id, weapons[secondary][ENTITY]);
			// 		cs_set_user_bpammo(id, secondary, weapons[secondary][BPAMMO]);
			// 	}
			// }

			new weapon_id = get_ent_data_entity(id, "CBasePlayer", "m_rgpPlayerItems", CS_WEAPONSLOT_PRIMARY);
			new weapon_type = get_ent_data(weapon_id, "CBasePlayerItem", "m_iId");

			new CsTeams:team = g_iTeams[id];
			client_print_color(id, id, ("(GiveItems) primary: %d, secondary: %d", weapon_type, g_xSecondaryWeapons[team][g_iSecondarySelection[id]]));
			
			GivePlayerWeapons(id, weapon_type, g_xSecondaryWeapons[team][g_iSecondarySelection[id]]);
			return;
		}
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

        // client_print_color(id, id, "%s Refilling ^3%s^1 ammo...", PREFIX_CHAT, weapon_name);
      }
    }
  }
}

public client_connected(id)
{
	g_iRemember[id]  = false;
	g_bInBuyZone[id] = true;
	g_iPrimarySelection[id]   = 0;
	g_iSecondarySelection[id] = 0;
}

public client_disconnected(id)
{
	g_iRemember[id]  = false;
	g_bInBuyZone[id] = true;
	g_iPrimarySelection[id]   = 0;
	g_iSecondarySelection[id] = 0;
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

	new CsTeams:team = g_iTeams[id];
	new iSecondary = g_xSecondaryWeapons[team][g_iSecondarySelection[id]];
	new iLen = g_iPrimaryWeaponsLen;

	for (new i = 0; i < iLen; ++i)
	{
		new w = g_xPrimaryWeapons[team][i];
		if (!w)
		{
			continue;
		}
		formatex(szItem, charsmax(szItem), "Kit \d[%s%s + %s\d]", (g_bInBuyZone[id] && g_bAllowBuy) ? "\y" : "\d", weapons[w][NAME], weapons[iSecondary][NAME]);

		static info[4];
		num_to_str(i, info, charsmax(info));

		menu_additem(xMenu, szItem, info, charsmax(info), g_iMenuGunsCheckID);
	}
	
	menu_addblank2(xMenu);

	new iNext = (g_iSecondarySelection[id] + 1) % g_iSecondaryWeaponsLen;
	formatex(szItem, charsmax(szItem), "\yTrocar pistola para \d[\y%s\d]", weapons[g_xSecondaryWeapons[team][iNext]][NAME]);

	new const change[] = "change";
	menu_additem(xMenu, szItem, change, charsmax(change));

	new const remember[] = "remember";
	if(g_iRemember[id])
		menu_additem(xMenu, "\yRelembrar seleção? \d[\yHabilitado\d]", remember, charsmax(remember));
	else 
		menu_additem(xMenu, "\yRelembrar seleção? \d[\rDesabilitado\d]", remember, charsmax(remember));

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

	if(item == MENU_EXIT || !is_user_connected(id))
	{
		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	new info[4];
 	menu_item_getinfo(menu, item, _, info, charsmax(info));

	new CsTeams:team = g_iTeams[id];
	new i = str_to_num(info);

	if (i > 0 && i < g_iPrimaryWeaponsLen && g_bAllowBuy)
	{
		g_iPrimarySelection[id] = i;
		new w1 = g_xPrimaryWeapons[team][i];
		new w2 = g_xSecondaryWeapons[team][i];

		client_print_color(id, id, "^4(_ShowMenuGuns)^1 weapon_id: ^3%d^1, sec: ^3%d^1", w1, w2);
		GivePlayerWeapons(id, w1, w2);

		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	if (strfind("change", info) == 0)
	{
		g_iSecondarySelection[id] = (g_iSecondarySelection[id] + 1) % sizeof(g_xSecondaryWeapons);

		menu_destroy(menu);
		ShowMenuGuns(id);
		
		return PLUGIN_HANDLED;
	}
	
	if (strfind("remember", info) == 0)
	{
		g_iRemember[id] = !g_iRemember[id];
		
		menu_destroy(menu);
		ShowMenuGuns(id);

		return PLUGIN_HANDLED;
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}


public GivePlayerWeapons(id, primary, secondary)
{
	if (g_BoughtThisRound[id] || !is_user_alive(id))
		return;

	strip_user_weapons(id);
	
	if (primary > CSW_NONE && primary < CSW_P90)
	{	
	  give_item(id, weapons[primary][ENTITY]);
	  cs_set_user_bpammo(id, primary, weapons[primary][BPAMMO]);
	}

	if (secondary > CSW_NONE && secondary < CSW_P90)
	{	
	  give_item(id, weapons[secondary][ENTITY]);
	  cs_set_user_bpammo(id, secondary, weapons[secondary][BPAMMO]);
	}
	
	give_item(id, "weapon_knife");
	give_item(id, "item_assaultsuit");
	give_item(id, "weapon_hegrenade");
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_flashbang");
	
	g_BoughtThisRound[id] = true;

	client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[%s + %s]^1!", PREFIX_CHAT, weapons[primary][NAME], weapons[secondary][NAME]);
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
