#include <amxmodx>
#include <amxmisc>
#include <fvault>
#include <hamsandwich>
#if AMXX_VERSION_NUM < 183 || !defined set_dhudmessage
	#tryinclude <dhudmessage>

	#if !defined _dhudmessage_included
		#error "dhudmessage.inc" is missing in your "scripting/include" folder. Download it from: "https://amxx-bg.info/inc/"
	#endif
#endif
#define color(%1) %1 == -1 ? random(256) : %1

#define DHUD_PHOLDER color(g_eData[DHUD_COLOR][0]), color(g_eData[DHUD_COLOR][1]), color(g_eData[DHUD_COLOR][2]),\
g_eData[DHUD_POSITION][0], g_eData[DHUD_POSITION][1], 0, 0.1, 1.0, 0.1, 0.1

#define DHUD_PHOLDER_DEAD color(g_eData[DHUD_COLOR][0]), color(g_eData[DHUD_COLOR][1]), color(g_eData[DHUD_COLOR][2]),\
g_eData[DHUD_POSITION_DEAD][0], g_eData[DHUD_POSITION_DEAD][1], 0, 0.1, 1.0, 0.1, 0.1

const MAX_MESSAGE_LENGTH = 32

new const g_szFileName[] = "SavedPlayers"
new const KeyDates[] = "EndDate"
new const g_szVault[] = "SaveDate"
new const TASK_ID = 17109
#define TASKID_MESSAGE 791725
#define VERSION "1.0"
new g_iPlayers, bool:g_bLastRound = false;

enum _:SaveDateTime
{
	NewDateTime[3]
}

enum _:ChangeRound
{
	CHANGE_INSTANT,
	CHANGE_AFTER,
}

enum _:DhudType
{
	DHUD_ONLY_DEAD,
	DHUD_ONLY_ALIVE,
	DHUD_BOTH,
}

enum _:ResetType
{
	RESET_MANUAL,
	RESET_AUTO,
}

enum _:Settings
{
	DHUD_COLOR[3],
	Float:DHUD_POSITION[2],
	Float:DHUD_POSITION_DEAD[2],
	CLEAR_TIME_HOUR,
	CLEAR_TIME_MINUTES,
	CHANGE_TYPE,
	RESET_TYPE[3],
	DHUD_VISIBILITY,
	DHUD_MESSAGE[MAX_MESSAGE_LENGTH],
	bool:DHUD_USE_DHUD,
}

new g_eData[Settings]

public plugin_init()
{
	register_plugin("ep1c: Visitantes", VERSION, "aTmAx")
	register_cvar("DailyVisitors", VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	RegisterHam(Ham_Spawn, "player", "fwdPlayerSpawnPost", 1)
	
	fvault_load(g_szFileName)
	DataGet()
	
	set_task(0.1, "taskCheckTime", TASK_ID, _, _, "b")
}

public plugin_end()
{
	save_set_date()
}

public plugin_precache()
{
	ReadFile()
}

public taskCheckTime()
{
	new szSaveDate[3],strSaveDate
	get_time("%d",szSaveDate,charsmax(szSaveDate))
	strSaveDate = str_to_num(szSaveDate)
	new szMapName[32]
	new tDate[128],tDays,strDays[15]
	if(g_eData[RESET_TYPE] == RESET_AUTO)
	{
		fvault_get_data(g_szVault, KeyDates, tDate, charsmax(tDate))
		get_mapname(szMapName, charsmax(szMapName))
		
		parse(tDate, strDays, 14)
		tDays = str_to_num(strDays)
		if(tDays)
		{
			if(!(tDays == strSaveDate))
			{
				get_change_type()
			}
		}
	}
	else if(g_eData[RESET_TYPE] == RESET_MANUAL)
	{
		new szMapName[32]
		new szHours[16], szMinutes[16], szSeconds[16]
		get_time("%H", szHours, charsmax(szHours))
		get_time("%M", szMinutes, charsmax(szMinutes))
		get_time("%S", szSeconds, charsmax(szSeconds))
		get_mapname(szMapName, charsmax(szMapName))
		if(str_to_num(szHours) == g_eData[CLEAR_TIME_HOUR] && str_to_num(szMinutes) == g_eData[CLEAR_TIME_MINUTES] && str_to_num(szSeconds) <= 03)
		{
			get_change_type()
		}
	}
}

public fwdPlayerSpawnPost()
{
	if(g_bLastRound == true)
	{
		new vaultkey[64], szMapName[32]
		get_mapname(szMapName, charsmax(szMapName))
		fvault_remove_key(g_szFileName, vaultkey)
		fvault_clear(g_szFileName)
		g_iPlayers = 0
		g_bLastRound = false;
		server_cmd("amx_map %s", szMapName)
	}
}

public save_set_date()
{
	new szSaveDate[3],strSaveDate,fmSaveDate[64]
	get_time("%d",szSaveDate,charsmax(szSaveDate))
	strSaveDate = str_to_num(szSaveDate)
	
	formatex(fmSaveDate,charsmax(fmSaveDate),"%i",strSaveDate)
	fvault_set_data(g_szVault,KeyDates,fmSaveDate)
}

public client_putinserver(id)
{
	new szAuthID[36], szName[33]
	get_user_authid(id, szAuthID, charsmax(szAuthID))
	get_user_name(id, szName, charsmax(szName))
	
	new vaultkey[64],vaultdata[256]
    
	formatex(vaultkey,63,"%s", szAuthID)
	formatex(vaultdata,255,"%s#%s#", szName, szAuthID)
	
	if(!fvault_get_data(g_szFileName,vaultkey,vaultdata,charsmax(vaultdata)))
	{
		g_iPlayers++
		savePlayers()
		DataSet(szAuthID, szName)
	}
	set_task(1.0, "dhudMessage", id + TASKID_MESSAGE, _, _, "b")
}

public client_disconnected(id)
{
	new iTask = id + TASKID_MESSAGE
    
	if(task_exists(iTask))
		remove_task(iTask)
}

public dhudMessage(id)
{
	id -= TASKID_MESSAGE

	if(is_user_bot(id))
		return
	
	new iPlayer = id
	
	switch(g_eData[DHUD_VISIBILITY])
	{
		case DHUD_ONLY_DEAD:
		{
			if(g_eData[DHUD_USE_DHUD])
			{
				if(!is_user_alive(iPlayer))
				{
					set_dhudmessage(DHUD_PHOLDER_DEAD)
					show_dhudmessage(iPlayer, g_eData[DHUD_MESSAGE], g_iPlayers)
				}
				else
				{
					return
				}
			}
			else
			{
				if(!is_user_alive(iPlayer))
				{
					set_hudmessage(DHUD_PHOLDER_DEAD, -1)
					show_hudmessage(iPlayer, g_eData[DHUD_MESSAGE], g_iPlayers)
				}
				else
				{
					return
				}
			}
		}
		case DHUD_ONLY_ALIVE:
		{
			if(g_eData[DHUD_USE_DHUD])
			{
				if(is_user_alive(iPlayer))
				{
					set_dhudmessage(DHUD_PHOLDER)
					show_dhudmessage(iPlayer, g_eData[DHUD_MESSAGE], g_iPlayers)
				}
				else
				{
					return
				}
			}
			else
			{
				if(is_user_alive(iPlayer))
				{
					set_hudmessage(DHUD_PHOLDER, -1)
					show_hudmessage(iPlayer, g_eData[DHUD_MESSAGE], g_iPlayers)
				}
				else
				{
					return
				}
			}
		}
		case DHUD_BOTH:
		{
			if(g_eData[DHUD_USE_DHUD])
			{
				if(is_user_alive(iPlayer))
				{
					set_dhudmessage(DHUD_PHOLDER)
					show_dhudmessage(iPlayer, g_eData[DHUD_MESSAGE], g_iPlayers)
				}
				else
				{
					set_dhudmessage(DHUD_PHOLDER_DEAD)
					show_dhudmessage(iPlayer, g_eData[DHUD_MESSAGE], g_iPlayers)	
				}
			}
			else if(!g_eData[DHUD_USE_DHUD])
			{
				if(is_user_alive(iPlayer))
				{
					set_hudmessage(DHUD_PHOLDER, -1)
					show_hudmessage(iPlayer, g_eData[DHUD_MESSAGE], g_iPlayers)
				}
				else
				{
					set_hudmessage(DHUD_PHOLDER_DEAD, -1)
					show_hudmessage(iPlayer, g_eData[DHUD_MESSAGE], g_iPlayers)	
				}
			}
		}
	}
}

stock savePlayers()
{
	new szPlayers[32], vaultdata[256]
	
	num_to_str(g_iPlayers, szPlayers, charsmax(szPlayers))
	fvault_set_data(g_szFileName,vaultdata,szPlayers)
}

stock get_change_type()
{
	new vaultkey[64], szMapName[32]
	get_mapname(szMapName, charsmax(szMapName))
	switch(g_eData[CHANGE_TYPE])
	{
		case CHANGE_INSTANT:
		{
			fvault_remove_key(g_szFileName, vaultkey)
			fvault_clear(g_szFileName)
			g_iPlayers = 0
			server_cmd("amx_map %s", szMapName)
		}
		case CHANGE_AFTER:
		{
			g_bLastRound = true;
		}
	}
}

stock DataGet()
{
	new szPlayers[32], vaultdata[256]
	fvault_get_data(g_szFileName, vaultdata, szPlayers, charsmax(szPlayers))
	g_iPlayers = str_to_num(szPlayers)
}

stock DataSet(const szAuthID[], const szName[])
{
	fvault_set_data(g_szFileName, szAuthID, szName)
}

ReadFile()
{
	new szFilename[256],szKey[64],szValue[32]
	get_configsdir(szFilename, charsmax(szFilename))
	add(szFilename, charsmax(szFilename), "/PlayerVisit.ini")

	new iFilePointer = fopen(szFilename, "rt")

	if(iFilePointer)
	{
		new szData[128],szTemp[4][5]

		while(!feof(iFilePointer))
		{
			fgets(iFilePointer, szData, charsmax(szData))
			trim(szData)

			switch(szData[0])
			{
				case EOS, ';', '#': continue
				default:
				{
					strtok(szData, szKey, charsmax(szKey), szValue, charsmax(szValue), '=')
					trim(szKey); trim(szValue)
					
					if(!szValue[0])
						continue
					if(equal(szKey, "DHUD_COLOR"))
					{
						parse(szValue, szTemp[0], charsmax(szTemp[]), szTemp[1], charsmax(szTemp[]), szTemp[2], charsmax(szTemp[]))

						for(new i = 0; i < 3; i++)
						{
							g_eData[DHUD_COLOR][i] = clamp(str_to_num(szTemp[i]), -1, 255)
						}
					}
					else if(equal(szKey, "DHUD_POSITION"))
					{
						parse(szValue, szTemp[0], charsmax(szTemp[]), szTemp[1], charsmax(szTemp[]))

						for(new i = 0; i < 2; i++)
						{
							g_eData[DHUD_POSITION][i] = _:floatclamp(str_to_float(szTemp[i]), -1.0, 1.0)
						}
					}
					else if(equal(szKey, "DHUD_POSITION_DEAD"))
					{
						parse(szValue, szTemp[0], charsmax(szTemp[]), szTemp[1], charsmax(szTemp[]))

						for(new i = 0; i < 2; i++)
						{
							g_eData[DHUD_POSITION_DEAD][i] = _:floatclamp(str_to_float(szTemp[i]), -1.0, 1.0)
						}
					}
					else if(equal(szKey, "CLEAR_TIME_HOUR"))
					{
						g_eData[CLEAR_TIME_HOUR] = clamp(str_to_num(szValue))
					}
					else if(equal(szKey, "CLEAR_TIME_MINUTES"))
					{
						g_eData[CLEAR_TIME_MINUTES] = clamp(str_to_num(szValue))
					}
					else if(equal(szKey, "CHANGE_TYPE"))
					{
						g_eData[CHANGE_TYPE] = clamp(str_to_num(szValue), CHANGE_INSTANT, CHANGE_AFTER)
					}
					else if(equal(szKey, "RESET_TYPE"))
					{
						g_eData[RESET_TYPE] = clamp(str_to_num(szValue), RESET_MANUAL, RESET_AUTO)
					}
					else if(equal(szKey, "DHUD_VISIBILITY"))
					{
						g_eData[DHUD_VISIBILITY] = clamp(str_to_num(szValue), DHUD_ONLY_DEAD, DHUD_BOTH)
					}
					else if(equal(szKey, "DHUD_MESSAGE"))
					{
						copy(g_eData[DHUD_MESSAGE], charsmax(g_eData[DHUD_MESSAGE]), szValue)
					}
					else if(equal(szKey, "DHUD_USE_DHUD"))
					{
						g_eData[DHUD_USE_DHUD] = _:clamp(str_to_num(szValue), false, true)
					}
				}
			}
		}

		fclose(iFilePointer)
	}
}
