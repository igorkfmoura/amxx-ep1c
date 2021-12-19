#include <amxmodx>
#include <amxmisc>
#include <cromchat>
#include <cstrike>
#include <fakemeta>
//#include <project-x/project-x_level_system>

new const PLUGIN_VERSION[] = "1.0"
const Float:DELAY_ON_REGISTER = 1.0
const Float:DELAY_ON_CONNECT = 1.0
const Float:DELAY_ON_CHANGE = 0.1
const PLACEHOLDER_LENGTH = 64
const WRITTEN_MESSAGE_SIZE = 120
const FULL_MESSAGE_SIZE = 180
new const ERROR_FILE[] = "px_prefixes_errors.log"

#define TASK_CHATC 240106

#if defined replace_string
	#define replace_all replace_string
#endif

/*
	You can comment placeholders you don't need from the lines below and that will completely deactivate them.
	You can also activate the additional ones if you want to use them.
	Feel free to experiment in making your custom ones as well.
*/

#define ARG_ADMIN_PREFIX        "$admin_prefix$"
#define ARG_DEAD_PREFIX         "$dead_prefix$"
#define ARG_TEAM                "$team$"
#define ARG_NAME                "$name$"
#define ARG_CUSTOM_NAME         "$custom_name$"
#define ARG_IP                  "$ip$"
#define ARG_STEAM               "$steam$"
#define ARG_USERID              "$userid$"
#define ARG_CHAT_COLOR          "$chat_color$"
#define ARG_MESSAGE             "$message$"
#define ARG_TIME                "$time$"
//#define ARG_RANK              "$rank$"
//#define ARG_LEVEL             "$level$"
//#define FLAG_VIP ADMIN_RESERVATION
//#define ARG_CURRENT_XP        "$current_xp$"
//#define ARG_NEXT_XP           "$next_xp$"
//#define ARG_NEXT_LEVEL        "$next_level$"
//#define ARG_NEXT_RANK         "$next_rank$"
//#define ARG_HEALTH            "$health$"
//#define ARG_ARMOR             "$armor$"
//#define ARG_FRAGS             "$frags$"
//#define ARG_DEATHS            "$deaths$"
//#define ARG_CITY              "$city$"
//#define ARG_COUNTRY           "$country$"
//#define ARG_COUNTRY_CODE      "$country_code$"
//#define ARG_CONTINENT         "$continent$"
//#define ARG_CONTINENT_CODE    "$continent_code$"

/*	The settings end here. Don't modify anything below this if you don't know what you're doing. */

#if defined ARG_CITY || defined ARG_COUNTRY || defined ARG_COUNTRY_CODE || defined ARG_CONTINENT || defined ARG_CONTINENT_CODE
	#include <geoip>
#endif

/*#if defined ARG_CURRENT_XP
	native crxranks_get_user_xp(id)
#endif

#if defined ARG_NEXT_XP
	native crxranks_get_user_next_xp(id)
#endif

#if defined ARG_NEXT_LEVEL
	native crxranks_get_user_next_level(id)
#endif

#if defined ARG_NEXT_RANK
	native crxranks_get_user_next_rank(id, buffer[], len)
#endif

forward crxranks_user_level_updated(id, level, bool:levelup)*/

enum
{
	SECTION_NONE,
	SECTION_MAIN_SETTINGS,
	SECTION_ADMIN_PREFIXES,
	SECTION_CHAT_COLORS,
	SECTION_NAME_CUSTOMIZATION,
	SECTION_FORMAT_DEFINITIONS,
	SECTION_SAY_FORMATS
}

enum
{
	INFOTYPE_NONE,
	INFOTYPE_FLAG,
	INFOTYPE_NAME,
	INFOTYPE_IP,
	INFOTYPE_STEAM,
	INFOTYPE_ANY_FLAG,
	INFOTYPE_NO_PREFIX,
	INFOTYPE_LEVEL
}

enum
{
	ALLCHAT_NONE = 0,
	ALLCHAT_NO_TEAM,
	ALLCHAT_SEE_TEAM
}

enum
{
	EDB_IGNORE = 0,
	EDB_COMMENT,
	EDB_REMOVE
}

enum _:PlayerInfo
{
	INFO_TYPE,
	INFO[35],
	DATA[32],
	DATA2[32],
	EXPIRATION_DATE[32]
}

enum _:Settings
{
	ALL_CHAT,
	ADMIN_LISTEN_FLAGS[32],
	DEAD_PREFIX[32],
	ALIVE_PREFIX[32],
	SPEC_PREFIX[32],
	TEAM_PREFIX_T[32],
	TEAM_PREFIX_CT[32],
	TEAM_PREFIX_SPEC[32],
	ERROR_TEXT[32],
	FORMAT_TIME[32],
	CHAT_LOG_FILE[64],
	CHAT_LOG_SAY_FORMAT[32],
	CHAT_LOG_TEAM_FORMAT[32],
	SAY_SOUND[128],
	SAY_TEAM_SOUND[128],
	EXPIRATION_DATE_FORMAT[32],
	EXPIRATION_DATE_BEHAVIOR
}

enum _:PlayerData
{
	PDATA_NAME[32],
	PDATA_CUSTOM_NAME[32],
	PDATA_IP[16],
	PDATA_STEAM[35],
	PDATA_USERID[10],
	PDATA_PREFIX[32],
	PDATA_CHAT_COLOR[6],
	PDATA_SAY_FORMAT[32],
	PDATA_SAY_TEAM_FORMAT[32],
	PDATA_ADMIN_FLAGS,
	bool:PDATA_ADMIN_LISTEN,
	bool:PDATA_PREFIX_ENABLED,
	bool:PDATA_CHAT_COLOR_ENABLED,
	bool:PDATA_CUSTOM_NAME_ENABLED
}

enum _:ADM
{
	AUTH[32],
	DATE[20],
	EXPIRED
}

new g_eSettings[Settings],
	g_ePlayerData[33][PlayerData],
	Array:g_aAdminPrefixes,
	Array:g_aChatColors,
	Array:g_aNameCustomization,
	Array:g_aSayFormats,
	Array:g_aFileContents,
	Array:g_arrAdmins,
	Trie:g_tBlockFirst,
	Trie:g_tFormatDefinitions,
	bool:g_bFileWasRead,
	bool:g_bRankSystem,
	bool:g_bSomethingExpired,
	g_szConfigsName[256],
	g_szFilename[256],
	g_szAuth[33][3][33], 
	g_szDate[33][20], 
	g_expired[33],
	g_fwdUserNameChanged,
	g_fwdOnPlayerDataUpdated,
	g_iAdminPrefixes,
	g_iChatColors,
	g_iNameCustomization,
	g_iSayFormats,
	g_iFileContents = -1,
	g_iToday

public plugin_init()
{
	register_plugin("\r[ep1c] \y[ADDON]: \wChat Manager", PLUGIN_VERSION, "BhK-")
	register_cvar("px_prefixes", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	register_event("SayText", "OnSayTextNameChange", "a", "2=#Cstrike_Name_Change")

	register_clcmd("say /vencimento", "show_expire")
	register_clcmd("say /venc", "show_expire")

	g_arrAdmins = ArrayCreate(ADM)

	file_admin_expired()

	
	register_forward(FM_ClientUserInfoChanged, "OnNameChange", 1)
	register_forward(FM_ClientUserInfoChanged, "ClientUserInfoChanged")
	

	set_task(DELAY_ON_REGISTER, "RegisterCommands")
	g_fwdOnPlayerDataUpdated = CreateMultiForward("cm_on_player_data_updated", ET_IGNORE, FP_CELL)
}

public plugin_end()
{
	ArrayDestroy(g_aAdminPrefixes)
	ArrayDestroy(g_aChatColors)
	ArrayDestroy(g_aNameCustomization)
	ArrayDestroy(g_aSayFormats)
	ArrayDestroy(g_aFileContents)
	TrieDestroy(g_tBlockFirst)
	TrieDestroy(g_tFormatDefinitions)
}

public plugin_precache()
{
	g_aAdminPrefixes = ArrayCreate(PlayerInfo)
	g_aChatColors = ArrayCreate(PlayerInfo)
	g_aNameCustomization = ArrayCreate(PlayerInfo)
	g_aSayFormats = ArrayCreate(PlayerInfo)
	g_aFileContents = ArrayCreate(192)
	g_tBlockFirst = TrieCreate()
	g_tFormatDefinitions = TrieCreate()
	get_configsdir(g_szConfigsName, charsmax(g_szConfigsName))
	formatex(g_szFilename, charsmax(g_szFilename), "%s/arquivos/px_prefixes.ini", g_szConfigsName)

	if(LibraryExists("crxranks", LibType_Library))
	{
		g_bRankSystem = true
	}

	ReadFile()
}

public RegisterCommands()
{
	register_clcmd("say", "Hook_Say")
	register_clcmd("say_team", "Hook_Say")
	register_concmd("px_reload", "Cmd_Reload", ADMIN_ADMIN, "-- Carregar configuração dos prefixos")
}

public client_putinserver(id)
{
	if(!is_user_admin(id))
	{
		g_expired[id] = 3
		return
	}

	get_user_authid(id, g_szAuth[id][0], charsmax(g_szAuth[ ][ ]))
	get_user_name(id, g_szAuth[id][1], charsmax(g_szAuth[ ][ ]))
	get_user_ip(id, g_szAuth[id][2], charsmax(g_szAuth[ ][ ]))
	
	check_admin(id)

	get_user_name(id, g_ePlayerData[id][PDATA_NAME], charsmax(g_ePlayerData[][PDATA_NAME]))
	copy(g_ePlayerData[id][PDATA_CUSTOM_NAME], charsmax(g_ePlayerData[][PDATA_CUSTOM_NAME]), g_ePlayerData[id][PDATA_NAME])
	get_user_ip(id, g_ePlayerData[id][PDATA_IP], charsmax(g_ePlayerData[][PDATA_IP]), 1)
	get_user_authid(id, g_ePlayerData[id][PDATA_STEAM], charsmax(g_ePlayerData[][PDATA_STEAM]))
	num_to_str(get_user_userid(id), g_ePlayerData[id][PDATA_USERID], charsmax(g_ePlayerData[][PDATA_USERID]))
	g_ePlayerData[id][PDATA_PREFIX_ENABLED] = true
	g_ePlayerData[id][PDATA_CHAT_COLOR_ENABLED] = true
	g_ePlayerData[id][PDATA_CUSTOM_NAME_ENABLED] = true
	set_task(DELAY_ON_CONNECT, "UpdateData", id)

	set_task(15.0, "show_expire", id)
}

public show_expire(id)
{
	if(g_expired[id] == 3)
		return PLUGIN_HANDLED

	if(g_expired[id] == -1)
		client_print_color(id, print_team_default, "^4[^1ep1c gaming Brasil^4] ^1Parabéns seu admin é ^4Permanente^1!!!")

	else
		client_print_color(id, print_team_default, "^4[^1ep1c gaming Brasil^4] ^1Seu admin termina no dia: ^4%s ^3| Estado atual: ^4%s", g_szDate[id], g_expired[id] ? "VENCIDO" : "ATIVADO")

	return PLUGIN_HANDLED
}

check_admin(id)
{
	new admin[ADM], bool:found
	for(new i; i < ArraySize(g_arrAdmins); i++)
	{
		ArrayGetArray(g_arrAdmins, i, admin)

		for(new ii; ii < sizeof(g_szAuth[ ]); ii++)
		{
			if(equal(g_szAuth[id][ii], admin[AUTH]))
			{
				found = true
				
				g_expired[id] = admin[EXPIRED]
				copy(g_szDate[id], charsmax(g_szDate[ ]), admin[DATE])

				if(admin[EXPIRED] != -1 && admin[EXPIRED])
					remove_user_flags(id)

				break
			}
		}

		if(found)
			break
	}
}

file_admin_expired()
{
	new szRoute[100]
	get_configsdir(szRoute, charsmax(szRoute))
	format(szRoute, charsmax(szRoute), "%s/users.ini", szRoute)

	new iFile = fopen(szRoute, "rt")

	new szText[110], admin[ADM], szPass[32], szAccess[25], szFlags[8]

	while(!feof(iFile))
	{
		fgets(iFile, szText, charsmax(szText))
		trim(szText)

		if(szText[0] != '"')
			continue

		parse(szText, admin[AUTH], charsmax(admin[AUTH]), szPass, charsmax(szPass), szAccess, charsmax(szAccess), szFlags, charsmax(szFlags), admin[DATE], charsmax(admin[DATE]))
		admin[EXPIRED] = admin_expired(admin[DATE])
		ArrayPushArray(g_arrAdmins, admin)
	}

	fclose(iFile)
}

stock admin_expired(const date[])
{
	if(!str_to_num(date))
		return -1

	new szTempExpire[20], uExpire

	formatex(szTempExpire, charsmax(szTempExpire), "%s 00", date)
	uExpire = parse_time(szTempExpire, "%d/%m/%Y %H")
	
	if(get_systime() > uExpire)
		return 1

	return 0
}

public OnSayTextNameChange(iMsg, iDestination, iEntity)
{
	g_fwdUserNameChanged = register_forward(FM_ClientUserInfoChanged, "OnNameChange")
}

public OnNameChange(id)
{
	if(!is_user_connected(id))
		return

	get_user_name(id, g_ePlayerData[id][PDATA_NAME], charsmax(g_ePlayerData[][PDATA_NAME]))
	copy(g_ePlayerData[id][PDATA_CUSTOM_NAME], charsmax(g_ePlayerData[][PDATA_CUSTOM_NAME]), g_ePlayerData[id][PDATA_NAME])

	UpdateData(id)
	unregister_forward(FM_ClientUserInfoChanged, g_fwdUserNameChanged)
}
/*
public ClientUserInfoChanged(id)

{
    static const name[] = "name"
    static szOldName[32], szNewName[32]
    pev(id, pev_netname, szOldName, charsmax(szOldName))
    if( szOldName[0])
    {
        get_user_info(id, name, szNewName, charsmax(szNewName))
        if( !equal(szOldName, szNewName) )
        {
            set_user_info(id, name, szOldName)
            return FMRES_HANDLED
        }
    }
    return FMRES_HANDLED;
}
*/
public crxranks_user_level_updated(id, iLevel)
{
	set_task(DELAY_ON_CHANGE, "UpdateData", id)
}

public UpdateData(id)
{
	static eItem[PlayerInfo], i
	g_ePlayerData[id][PDATA_PREFIX][0] = EOS
	g_ePlayerData[id][PDATA_CHAT_COLOR][0] = EOS
	g_ePlayerData[id][PDATA_SAY_FORMAT][0] = EOS
	g_ePlayerData[id][PDATA_SAY_TEAM_FORMAT][0] = EOS
	g_ePlayerData[id][PDATA_ADMIN_FLAGS] = get_user_flags(id)
	g_ePlayerData[id][PDATA_ADMIN_LISTEN] = g_eSettings[ADMIN_LISTEN_FLAGS][0] ? (bool:(g_ePlayerData[id][PDATA_ADMIN_FLAGS] & read_flags(g_eSettings[ADMIN_LISTEN_FLAGS])) ? true : false) : false
	copy(g_ePlayerData[id][PDATA_CUSTOM_NAME], charsmax(g_ePlayerData[][PDATA_CUSTOM_NAME]), g_ePlayerData[id][PDATA_NAME])

	if(g_iAdminPrefixes)
	{
		for(i = 0; i < g_iAdminPrefixes; i++)
		{
			ArrayGetArray(g_aAdminPrefixes, i, eItem)

			if(meets_requirements(id, eItem[INFO_TYPE], eItem[INFO]))
			{
				copy(g_ePlayerData[id][PDATA_PREFIX], charsmax(g_ePlayerData[][PDATA_PREFIX]), eItem[DATA])
				break
			}
		}
	}

	if(g_iChatColors)
	{
		for(i = 0; i < g_iChatColors; i++)
		{
			ArrayGetArray(g_aChatColors, i, eItem)

			if(meets_requirements(id, eItem[INFO_TYPE], eItem[INFO]))
			{
				copy(g_ePlayerData[id][PDATA_CHAT_COLOR], charsmax(g_ePlayerData[][PDATA_CHAT_COLOR]), eItem[DATA])
				break
			}
		}
	}

	if(g_iNameCustomization)
	{
		for(i = 0; i < g_iNameCustomization; i++)
		{
			ArrayGetArray(g_aNameCustomization, i, eItem)

			if(meets_requirements(id, eItem[INFO_TYPE], eItem[INFO]))
			{
				copy(g_ePlayerData[id][PDATA_CUSTOM_NAME], charsmax(g_ePlayerData[][PDATA_CUSTOM_NAME]), eItem[DATA])
				break
			}
		}
	}

	if(g_iSayFormats)
	{
		for(i = 0; i < g_iSayFormats; i++)
		{
			ArrayGetArray(g_aSayFormats, i, eItem)

			if(meets_requirements(id, eItem[INFO_TYPE], eItem[INFO]))
			{
				copy(g_ePlayerData[id][PDATA_SAY_FORMAT], charsmax(g_ePlayerData[][PDATA_SAY_FORMAT]), eItem[DATA])
				copy(g_ePlayerData[id][PDATA_SAY_TEAM_FORMAT], charsmax(g_ePlayerData[][PDATA_SAY_TEAM_FORMAT]), eItem[DATA2])
				break
			}
		}
	}

	new iReturn
	ExecuteForward(g_fwdOnPlayerDataUpdated, iReturn, id)
}

ReadFile()
{
	if(g_bFileWasRead)
	{
		g_iAdminPrefixes = 0
		g_iChatColors = 0
		g_iNameCustomization = 0
		g_iSayFormats = 0
		g_iFileContents = -1
		g_bSomethingExpired = false
		ArrayClear(g_aAdminPrefixes)
		ArrayClear(g_aChatColors)
		ArrayClear(g_aNameCustomization)
		ArrayClear(g_aSayFormats)
		ArrayClear(g_aFileContents)
		TrieClear(g_tBlockFirst)
		TrieClear(g_tFormatDefinitions)
	}

	new iFilePointer = fopen(g_szFilename, "rt")

	if(iFilePointer)
	{
		new szData[192], szValue[160], szKey[32], eItem[PlayerInfo], iSection = SECTION_NONE, iChatLogSayLine, iChatLogTeamLine, iSize, iLine

		while(!feof(iFilePointer))
		{
			iLine++
			fgets(iFilePointer, szData, charsmax(szData))
			trim(szData)

			g_iFileContents++
			ArrayPushString(g_aFileContents, szData)

			switch(szData[0])
			{
				case EOS, '#', ';':
				{
					continue
				}
				case '[':
				{
					iSize = strlen(szData)

					if(szData[iSize - 1] == ']')
					{
						switch(szData[1])
						{
							case 'M', 'm': iSection = SECTION_MAIN_SETTINGS
							case 'A', 'a': iSection = SECTION_ADMIN_PREFIXES
							case 'C', 'c': iSection = SECTION_CHAT_COLORS
							case 'N', 'n': iSection = SECTION_NAME_CUSTOMIZATION
							case 'F', 'f': iSection = SECTION_FORMAT_DEFINITIONS
							case 'S', 's': iSection = SECTION_SAY_FORMATS
							default:
							{
								log_config_error(iLine, "Unknown section name: %s", szData)
								iSection = SECTION_NONE
							}
						}
					}
					else
					{
						log_config_error(iLine, "Unclosed section name: %s", szData)
						continue
					}
				}
				default:
				{
					switch(iSection)
					{
						case SECTION_NONE: log_config_error(iLine, "Data is not in any section: %s", szData)
						case SECTION_MAIN_SETTINGS:
						{
							strtok(szData, szKey, charsmax(szKey), szValue, charsmax(szValue), '=')
							trim(szKey); trim(szValue)

							if(!szValue[0])
							{
								continue
							}

							if(equal(szKey, "ALL_CHAT"))
							{
								g_eSettings[ALL_CHAT] = clamp(str_to_num(szValue), ALLCHAT_NONE, ALLCHAT_SEE_TEAM)
							}
							else if(equal(szKey, "ADMIN_LISTEN_FLAGS"))
							{
								copy(g_eSettings[ADMIN_LISTEN_FLAGS], charsmax(g_eSettings[ADMIN_LISTEN_FLAGS]), szValue)
							}
							else if(equal(szKey, "BLOCK_FIRST_SYMBOLS"))
							{
								while(szValue[0] != 0 && strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ','))
								{
									trim(szKey); trim(szValue)
									TrieSetCell(g_tBlockFirst, szKey, 1)
								}
							}
							else if(equal(szKey, "DEAD_PREFIX"))
							{
								copy(g_eSettings[DEAD_PREFIX], charsmax(g_eSettings[DEAD_PREFIX]), szValue)
							}
							else if(equal(szKey, "ALIVE_PREFIX"))
							{
								copy(g_eSettings[ALIVE_PREFIX], charsmax(g_eSettings[ALIVE_PREFIX]), szValue)
							}
							else if(equal(szKey, "SPEC_PREFIX"))
							{
								copy(g_eSettings[SPEC_PREFIX], charsmax(g_eSettings[SPEC_PREFIX]), szValue)
							}
							else if(equal(szKey, "TEAM_PREFIX_T"))
							{
								copy(g_eSettings[TEAM_PREFIX_T], charsmax(g_eSettings[TEAM_PREFIX_T]), szValue)
							}
							else if(equal(szKey, "TEAM_PREFIX_CT"))
							{
								copy(g_eSettings[TEAM_PREFIX_CT], charsmax(g_eSettings[TEAM_PREFIX_CT]), szValue)
							}
							else if(equal(szKey, "TEAM_PREFIX_SPEC"))
							{
								copy(g_eSettings[TEAM_PREFIX_SPEC], charsmax(g_eSettings[TEAM_PREFIX_SPEC]), szValue)
							}
							else if(equal(szKey, "ERROR_TEXT"))
							{
								copy(g_eSettings[ERROR_TEXT], charsmax(g_eSettings[ERROR_TEXT]), szValue)
							}
							else if(equal(szKey, "FORMAT_TIME"))
							{
								copy(g_eSettings[FORMAT_TIME], charsmax(g_eSettings[FORMAT_TIME]), szValue)
							}
							else if(equal(szKey, "CHAT_LOG_FILE"))
							{
								copy(g_eSettings[CHAT_LOG_FILE], charsmax(g_eSettings[CHAT_LOG_FILE]), szValue)
							}
							else if(equal(szKey, "CHAT_LOG_SAY_FORMAT"))
							{
								iChatLogSayLine = iLine
								copy(g_eSettings[CHAT_LOG_SAY_FORMAT], charsmax(g_eSettings[CHAT_LOG_SAY_FORMAT]), szValue)
							}
							else if(equal(szKey, "CHAT_LOG_TEAM_FORMAT"))
							{
								iChatLogTeamLine = iLine
								copy(g_eSettings[CHAT_LOG_TEAM_FORMAT], charsmax(g_eSettings[CHAT_LOG_TEAM_FORMAT]), szValue)
							}
							else if(equal(szKey, "SAY_SOUND") && !g_bFileWasRead)
							{
								precache_sound(szValue)
								copy(g_eSettings[SAY_SOUND], charsmax(g_eSettings[SAY_SOUND]), szValue)
							}
							else if(equal(szKey, "SAY_TEAM_SOUND") && !g_bFileWasRead)
							{
								precache_sound(szValue)
								copy(g_eSettings[SAY_TEAM_SOUND], charsmax(g_eSettings[SAY_TEAM_SOUND]), szValue)
							}
							else if(equal(szKey, "EXPIRATION_DATE_FORMAT"))
							{
								g_iToday = get_systime()
								copy(g_eSettings[EXPIRATION_DATE_FORMAT], charsmax(g_eSettings[EXPIRATION_DATE_FORMAT]), szValue)
							}
							else if(equal(szKey, "EXPIRATION_DATE_BEHAVIOR"))
							{
								g_eSettings[EXPIRATION_DATE_BEHAVIOR] = clamp(str_to_num(szValue), EDB_IGNORE, EDB_REMOVE)
							}
						}
						case SECTION_FORMAT_DEFINITIONS:
						{
							strtok(szData, szKey, charsmax(szKey), szValue, charsmax(szValue), '=')
							trim(szKey); trim(szValue)
							TrieSetString(g_tFormatDefinitions, szKey, szValue)
						}
						case SECTION_ADMIN_PREFIXES:
						{
							eItem[EXPIRATION_DATE][0] = EOS
							parse(szData, szKey, charsmax(szKey), eItem[INFO], charsmax(eItem[INFO]), eItem[DATA], charsmax(eItem[DATA]), eItem[EXPIRATION_DATE], charsmax(eItem[EXPIRATION_DATE]))

							if(is_date_expired(eItem[EXPIRATION_DATE], iLine))
							{
								continue
							}

							eItem[INFO_TYPE] = get_info_type(szKey)

							if(invalid_info_type(eItem[INFO_TYPE], szKey, iLine))
							{
								continue
							}

							ArrayPushArray(g_aAdminPrefixes, eItem)
							g_iAdminPrefixes++
						}
						case SECTION_CHAT_COLORS:
						{
							eItem[EXPIRATION_DATE][0] = EOS
							parse(szData, szKey, charsmax(szKey), eItem[INFO], charsmax(eItem[INFO]), eItem[DATA], charsmax(eItem[DATA]), eItem[EXPIRATION_DATE], charsmax(eItem[EXPIRATION_DATE]))

							if(is_date_expired(eItem[EXPIRATION_DATE], iLine))
							{
								continue
							}

							eItem[INFO_TYPE] = get_info_type(szKey)

							if(invalid_info_type(eItem[INFO_TYPE], szKey, iLine))
							{
								continue
							}

							ArrayPushArray(g_aChatColors, eItem)
							g_iChatColors++
						}
						case SECTION_NAME_CUSTOMIZATION:
						{
							eItem[EXPIRATION_DATE][0] = EOS
							parse(szData, szKey, charsmax(szKey), eItem[INFO], charsmax(eItem[INFO]), eItem[DATA], charsmax(eItem[DATA]), eItem[EXPIRATION_DATE], charsmax(eItem[EXPIRATION_DATE]))

							if(is_date_expired(eItem[EXPIRATION_DATE], iLine))
							{
								continue
							}

							eItem[INFO_TYPE] = get_info_type(szKey)

							if(invalid_info_type(eItem[INFO_TYPE], szKey, iLine))
							{
								continue
							}

							ArrayPushArray(g_aNameCustomization, eItem)
							g_iNameCustomization++
						}
						case SECTION_SAY_FORMATS:
						{
							eItem[EXPIRATION_DATE][0] = EOS
							parse(szData, szKey, charsmax(szKey), eItem[INFO], charsmax(eItem[INFO]), eItem[DATA], charsmax(eItem[DATA]), eItem[DATA2], charsmax(eItem[DATA2]), eItem[EXPIRATION_DATE], charsmax(eItem[EXPIRATION_DATE]))

							if(is_date_expired(eItem[EXPIRATION_DATE], iLine))
							{
								continue
							}

							if(!TrieKeyExists(g_tFormatDefinitions, eItem[DATA]))
							{
								log_config_error(iLine, "Format definition ^"%s^" doesn't exist.", eItem[DATA])
								continue
							}

							if(!TrieKeyExists(g_tFormatDefinitions, eItem[DATA2]))
							{
								log_config_error(iLine, "Format definition ^"%s^" doesn't exist.", eItem[DATA2])
								continue
							}

							eItem[INFO_TYPE] = get_info_type(szKey)

							if(invalid_info_type(eItem[INFO_TYPE], szKey, iLine))
							{
								continue
							}

							ArrayPushArray(g_aSayFormats, eItem)
							g_iSayFormats++
						}
					}
				}
			}
		}

		fclose(iFilePointer)

		if(g_eSettings[CHAT_LOG_FILE][0])
		{
			if(!TrieKeyExists(g_tFormatDefinitions, g_eSettings[CHAT_LOG_SAY_FORMAT]))
			{
				g_eSettings[CHAT_LOG_FILE][0] = EOS
				format_doesnt_exist(iChatLogSayLine, g_eSettings[CHAT_LOG_SAY_FORMAT])
			}

			if(!TrieKeyExists(g_tFormatDefinitions, g_eSettings[CHAT_LOG_TEAM_FORMAT]))
			{
				g_eSettings[CHAT_LOG_FILE][0] = EOS
				format_doesnt_exist(iChatLogTeamLine, g_eSettings[CHAT_LOG_TEAM_FORMAT])
			}
		}

		if(g_bFileWasRead)
		{
			new iPlayers[32], iPnum
			get_players(iPlayers, iPnum)

			for(new i; i < iPnum; i++)
			{
				UpdateData(iPlayers[i])
			}
		}

		g_bFileWasRead = true

		if(g_bSomethingExpired && g_eSettings[EXPIRATION_DATE_BEHAVIOR] != EDB_IGNORE)
		{
			iFilePointer = fopen(g_szFilename, "w")

			for(new i; i < g_iFileContents + 1; i++)
			{
				fprintf(iFilePointer, "%a", ArrayGetStringHandle(g_aFileContents, i))

				if(i < g_iFileContents)
				{
					fprintf(iFilePointer, "^n")
				}
			}

			fclose(iFilePointer)
		}
	}
}

public Cmd_Reload(id, iLevel, iCid)
{
	if(!cmd_access(id, iLevel, iCid, 1))
	{
		return PLUGIN_HANDLED
	}

	ReadFile()
	console_print(id, "[PX] Recarregado com Sucesso!")

	if(is_user_connected(id))
	{
		log_amx("[ %s | %s | %s ] Carregou configurações de prefixos com sucesso", g_ePlayerData[id][PDATA_NAME], g_ePlayerData[id][PDATA_IP], g_ePlayerData[id][PDATA_STEAM])
	}

	return PLUGIN_HANDLED
}

public Hook_Say(id)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED
	}

	static szArgs[WRITTEN_MESSAGE_SIZE]
	read_args(szArgs, charsmax(szArgs)); remove_quotes(szArgs)
	CC_RemoveColors(szArgs, charsmax(szArgs))

	static szFirstChar[2]
	szFirstChar[0] = szArgs[0]

	if(!szArgs[0] || TrieKeyExists(g_tBlockFirst, szFirstChar))
	{
		return PLUGIN_HANDLED
	}

	static iFlags
	iFlags = get_user_flags(id)

	if(g_ePlayerData[id][PDATA_ADMIN_FLAGS] != iFlags)
	{
		UpdateData(id)
		g_ePlayerData[id][PDATA_ADMIN_FLAGS] = iFlags
	}

	static szCommand[5]
	read_argv(0, szCommand, charsmax(szCommand))

	static szMessage[FULL_MESSAGE_SIZE + 32], szSound[128], iPlayers[32], iPnum, bool:bTeam, iAlive, CsTeams:iTeam
	bTeam = szCommand[3] == '_'
	iAlive = is_user_alive(id)
	iTeam = cs_get_user_team(id)

	if(bTeam && g_eSettings[SAY_TEAM_SOUND][0])
	{
		copy(szSound, charsmax(szSound), g_eSettings[SAY_TEAM_SOUND])
	}
	else if(!bTeam && g_eSettings[SAY_SOUND][0])
	{
		copy(szSound, charsmax(szSound), g_eSettings[SAY_SOUND])
	}
	else
	{
		szSound[0] = EOS
	}

	apply_replacements(g_ePlayerData[id][bTeam ? PDATA_SAY_TEAM_FORMAT : PDATA_SAY_FORMAT], id, iAlive, iTeam, szArgs, szMessage, charsmax(szMessage))
	get_players(iPlayers, iPnum, "ch")

	if(g_eSettings[ALL_CHAT] == ALLCHAT_SEE_TEAM)
	{
		CC_SendMatched(0, id, szMessage)

		if(szSound[0])
		{
			client_cmd(0, "spk ^"%s^"", szSound)
		}
	}
	else
	{
		static iPlayer, i

		for(i = 0; i < iPnum; i++)
		{
			iPlayer = iPlayers[i]

			if(g_ePlayerData[iPlayer][PDATA_ADMIN_LISTEN] || (bTeam && iTeam == cs_get_user_team(iPlayer) && iAlive == is_user_alive(iPlayer)) || (!bTeam && (g_eSettings[ALL_CHAT] == 1 || iAlive == is_user_alive(iPlayer))))
			{
				CC_SendMatched(iPlayer, id, szMessage)

				if(szSound[0])
				{
					client_cmd(iPlayer, "spk ^"%s^"", szSound)
				}
			}
		}
	}

	if(g_eSettings[CHAT_LOG_FILE][0])
	{
		apply_replacements(g_eSettings[bTeam ? CHAT_LOG_TEAM_FORMAT : CHAT_LOG_SAY_FORMAT], id, iAlive, iTeam, szArgs, szMessage, charsmax(szMessage))
		log_to_file(g_eSettings[CHAT_LOG_FILE], szMessage)
	}

	return PLUGIN_HANDLED
}

apply_replacements(const szFormat[], const id, const iAlive, const CsTeams:iTeam, const szArgs[], szMessage[], const iLen)
{
	static szPlaceHolder[PLACEHOLDER_LENGTH]
	TrieGetString(g_tFormatDefinitions, szFormat, szMessage, iLen)

	#if defined ARG_ADMIN_PREFIX
	if(g_ePlayerData[id][PDATA_PREFIX_ENABLED])
	{
		replace_all(szMessage, iLen, ARG_ADMIN_PREFIX, g_ePlayerData[id][PDATA_PREFIX])
	}
	else
	{
		replace_all(szMessage, iLen, ARG_ADMIN_PREFIX, "")
	}
	#endif

	#if defined ARG_DEAD_PREFIX
	replace_all(szMessage, iLen, ARG_DEAD_PREFIX, g_eSettings[iAlive ? ALIVE_PREFIX : iTeam == CS_TEAM_SPECTATOR ? SPEC_PREFIX : DEAD_PREFIX])
	#endif

	#if defined ARG_TEAM
	replace_all(szMessage, iLen, ARG_TEAM, g_eSettings[iTeam == CS_TEAM_CT ? TEAM_PREFIX_CT : iTeam == CS_TEAM_T ? TEAM_PREFIX_T : TEAM_PREFIX_SPEC])
	#endif

	#if defined ARG_NAME
	replace_all(szMessage, iLen, ARG_NAME, g_ePlayerData[id][PDATA_NAME])
	#endif

	#if defined ARG_CUSTOM_NAME
	replace_all(szMessage, iLen, ARG_CUSTOM_NAME, g_ePlayerData[id][g_ePlayerData[id][PDATA_CUSTOM_NAME_ENABLED] ? PDATA_CUSTOM_NAME : PDATA_NAME])
	#endif

	#if defined ARG_IP
	replace_all(szMessage, iLen, ARG_IP, g_ePlayerData[id][PDATA_IP])
	#endif

	#if defined ARG_STEAM
	replace_all(szMessage, iLen, ARG_STEAM, g_ePlayerData[id][PDATA_STEAM])
	#endif

	#if defined ARG_USERID
	replace_all(szMessage, iLen, ARG_USERID, g_ePlayerData[id][PDATA_USERID])
	#endif

	#if defined ARG_CHAT_COLOR
	if(g_ePlayerData[id][PDATA_CHAT_COLOR_ENABLED])
	{
		replace_all(szMessage, iLen, ARG_CHAT_COLOR, g_ePlayerData[id][PDATA_CHAT_COLOR])
	}
	else
	{
		replace_all(szMessage, iLen, ARG_CHAT_COLOR, "")
	}
	#endif

	#if defined ARG_TIME
	if(has_argument(szMessage, ARG_TIME))
	{
		get_time(g_eSettings[FORMAT_TIME], szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_TIME, szPlaceHolder)
	}
	#endif

	#if defined ARG_CURRENT_XP
	if(g_bRankSystem && has_argument(szMessage, ARG_CURRENT_XP))
	{
		num_to_str(crxranks_get_user_xp(id), szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_CURRENT_XP, szPlaceHolder)
	}
	#endif

	#if defined ARG_NEXT_XP
	if(g_bRankSystem && has_argument(szMessage, ARG_NEXT_XP))
	{
		num_to_str(crxranks_get_user_next_xp(id), szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_NEXT_XP, szPlaceHolder)
	}
	#endif

	#if defined ARG_NEXT_LEVEL
	if(g_bRankSystem && has_argument(szMessage, ARG_NEXT_LEVEL))
	{
		num_to_str(crxranks_get_user_next_level(id), szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_NEXT_LEVEL, szPlaceHolder)
	}
	#endif

	#if defined ARG_RANK
	if(has_argument(szMessage, ARG_RANK))
	{
		zp_get_user_rank(id, szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_RANK, szPlaceHolder)
	}
	#endif

	#if defined ARG_LEVEL
	if(has_argument(szMessage, ARG_LEVEL))
	{
		num_to_str(zp_get_user_level(id, MODE_VALUE), szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_LEVEL, szPlaceHolder)
	}
	#endif

	#if defined ARG_NEXT_RANK
	if(g_bRankSystem && has_argument(szMessage, ARG_NEXT_RANK))
	{
		crxranks_get_user_next_rank(id, szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_NEXT_RANK, szPlaceHolder)
	}
	#endif

	#if defined ARG_HEALTH
	if(has_argument(szMessage, ARG_HEALTH))
	{
		num_to_str(iAlive ? get_user_health(id) : 0, szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_HEALTH, szPlaceHolder)
	}
	#endif

	#if defined ARG_ARMOR
	if(has_argument(szMessage, ARG_ARMOR))
	{
		num_to_str(iAlive ? get_user_armor(id) : 0, szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_ARMOR, szPlaceHolder)
	}
	#endif

	#if defined ARG_FRAGS
	if(has_argument(szMessage, ARG_FRAGS))
	{
		num_to_str(get_user_frags(id), szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_FRAGS, szPlaceHolder)
	}
	#endif

	#if defined ARG_DEATHS
	if(has_argument(szMessage, ARG_DEATHS))
	{
		num_to_str(cs_get_user_deaths(id), szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_DEATHS, szPlaceHolder)
	}
	#endif

	#if defined ARG_CITY
	if(has_argument(szMessage, ARG_CITY))
	{
		geoip_city(g_ePlayerData[id][PDATA_IP], szPlaceHolder, charsmax(szPlaceHolder))
		check_validity(szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_CITY, szPlaceHolder)
	}
	#endif

	#if defined ARG_COUNTRY
	if(has_argument(szMessage, ARG_COUNTRY))
	{
		#if defined geoip_country_ex
		geoip_country_ex(g_ePlayerData[id][PDATA_IP], szPlaceHolder, charsmax(szPlaceHolder))
		#else
		geoip_country(g_ePlayerData[id][PDATA_IP], szPlaceHolder, charsmax(szPlaceHolder))
		#endif

		check_validity(szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_COUNTRY, szPlaceHolder)
	}
	#endif

	#if defined ARG_COUNTRY_CODE
	if(has_argument(szMessage, ARG_COUNTRY_CODE))
	{
		new szCountryCode[3]

		#if defined geoip_code2_ex
		geoip_code2_ex(g_ePlayerData[id][PDATA_IP], szCountryCode)
		#else
		geoip_code2(g_ePlayerData[id][PDATA_IP], szCountryCode)
		#endif

		check_validity(szCountryCode, charsmax(szCountryCode))
		replace_all(szMessage, iLen, ARG_COUNTRY_CODE, szCountryCode)
	}
	#endif

	#if defined ARG_CONTINENT
	if(has_argument(szMessage, ARG_CONTINENT))
	{
		geoip_continent_name(g_ePlayerData[id][PDATA_IP], szPlaceHolder, charsmax(szPlaceHolder))
		check_validity(szPlaceHolder, charsmax(szPlaceHolder))
		replace_all(szMessage, iLen, ARG_CONTINENT, szPlaceHolder)
	}
	#endif

	#if defined ARG_CONTINENT_CODE
	if(has_argument(szMessage, ARG_CONTINENT_CODE))
	{
		new szContinentCode[3]
		geoip_continent_code(g_ePlayerData[id][PDATA_IP], szContinentCode)
		check_validity(szContinentCode, charsmax(szContinentCode))
		replace_all(szMessage, iLen, ARG_CONTINENT_CODE, szContinentCode)
	}
	#endif

	replace_all(szMessage, iLen, "  ", " ")

	#if defined ARG_MESSAGE
	replace_all(szMessage, iLen, ARG_MESSAGE, szArgs)
	#endif

	trim(szMessage)
}

stock bool:has_argument(const szMessage[], const szArgument[])
{
	return contain(szMessage, szArgument) != -1
}

stock check_validity(szText[], const iLen)
{
	if(!szText[0])
	{
		copy(szText, iLen, g_eSettings[ERROR_TEXT])
	}
}

bool:is_date_expired(const szDate[], const iLine)
{
	if(!szDate[0])
	{
		return false
	}

	if(!g_eSettings[EXPIRATION_DATE_FORMAT][0])
	{
		log_config_error(iLine, "Can't use expiration dates because EXPIRATION_DATE_FORMAT is not set.")
		return false
	}

	if(parse_time(szDate, g_eSettings[EXPIRATION_DATE_FORMAT]) < g_iToday)
	{
		switch(g_eSettings[EXPIRATION_DATE_BEHAVIOR])
		{
			case EDB_COMMENT:
			{
				static szData[192]
				formatex(szData, charsmax(szData), "# %a", ArrayGetStringHandle(g_aFileContents, g_iFileContents))
				ArraySetString(g_aFileContents, g_iFileContents, szData)
			}
			case EDB_REMOVE:
			{
				ArrayDeleteItem(g_aFileContents, g_iFileContents--)
			}
		}

		g_bSomethingExpired = true
		return true
	}

	return false
}

bool:invalid_info_type(const iInfoType, const szInfoType[], const iLine)
{
	if(iInfoType == INFOTYPE_NONE)
	{
		log_config_error(iLine, "Invalid info type: %s", szInfoType)
		return true
	}

	if(!g_bRankSystem && iInfoType == INFOTYPE_LEVEL)
	{
		log_config_error(iLine, "Can't use info type ^"%s^" because OciXCrom's Rank System isn't running.", szInfoType)
		return true
	}

	return false
}

bool:meets_requirements(const id, const iInfoType, const szInfo[])
{
	switch(iInfoType)
	{
		case INFOTYPE_FLAG:
		{
			static iFlags
			iFlags = read_flags(szInfo)

			if(g_ePlayerData[id][PDATA_ADMIN_FLAGS] & iFlags == iFlags)
			{
				return true
			}
		}
		case INFOTYPE_NAME:
		{
			if(equali(g_ePlayerData[id][PDATA_NAME], szInfo))
			{
				return true
			}
		}
		case INFOTYPE_IP:
		{
			if(equal(g_ePlayerData[id][PDATA_IP], szInfo))
			{
				return true
			}
		}
		case INFOTYPE_STEAM:
		{
			if(equal(g_ePlayerData[id][PDATA_STEAM], szInfo))
			{
				return true
			}
		}
		case INFOTYPE_ANY_FLAG:
		{
			if(g_ePlayerData[id][PDATA_ADMIN_FLAGS] & read_flags(szInfo))
			{
				return true
			}
		}
		case INFOTYPE_NO_PREFIX:
		{
			if(!g_ePlayerData[id][PDATA_PREFIX][0] || !g_ePlayerData[id][PDATA_PREFIX_ENABLED])
			{
				return true
			}
		}
		#if defined ARG_LEVEL
		case INFOTYPE_LEVEL:
		{
			if(zp_get_user_level(id, MODE_VALUE) >= str_to_num(szInfo))
			{
				return true
			}
		}
		#endif
	}

	return false
}

log_config_error(const iLine, const szText[], any:...)
{
	static szError[192]
	vformat(szError, charsmax(szError), szText, 3)
	log_to_file(ERROR_FILE, "Line %i: %s", iLine, szError)
}

format_doesnt_exist(const iLine, const szFormat[])
{
	log_config_error(iLine, "Format definition ^"%s^" doesn't exist.", szFormat)
}

get_info_type(const szText[])
{
	static iInfoType
	iInfoType = INFOTYPE_NONE

	switch(szText[0])
	{
		case 'F', 'f': iInfoType = INFOTYPE_FLAG
		case 'N', 'n':
		{
			switch(szText[1])
			{
				case 'A', 'a': iInfoType = INFOTYPE_NAME
				case 'O', 'o': iInfoType = INFOTYPE_NO_PREFIX
			}
		}
		case 'I', 'i': iInfoType = INFOTYPE_IP
		case 'S', 's': iInfoType = INFOTYPE_STEAM
		case 'A', 'a': iInfoType = INFOTYPE_ANY_FLAG
		case 'L', 'l': iInfoType = INFOTYPE_LEVEL
	}

	return iInfoType
}

public plugin_natives()
{
	register_library("chatmanager")
	register_native("cm_get_admin_listen_flags", 		"_cm_get_admin_listen_flags")
	register_native("cm_get_chat_color_by_num", 		"_cm_get_chat_color_by_num")
	register_native("cm_get_prefix_by_num", 			"_cm_get_prefix_by_num")
	register_native("cm_get_user_chat_color", 			"_cm_get_user_chat_color")
	register_native("cm_get_user_chat_color_status", 	"_cm_get_user_chat_color_status")
	register_native("cm_get_user_custom_name",			"_cm_get_user_custom_name")
	register_native("cm_get_user_custom_name_status",	"_cm_get_user_custom_name_status")
	register_native("cm_get_user_prefix", 				"_cm_get_user_prefix")
	register_native("cm_get_user_prefix_status", 		"_cm_get_user_prefix_status")
	register_native("cm_has_user_admin_listen", 		"_cm_has_user_admin_listen")
	register_native("cm_reload_config_file", 			"_cm_reload_config_file")
	register_native("cm_set_user_chat_color", 			"_cm_set_user_chat_color")
	register_native("cm_set_user_chat_color_status", 	"_cm_set_user_chat_color_status")
	register_native("cm_set_user_custom_name_status", 	"_cm_set_user_custom_name_status")
	register_native("cm_set_user_prefix", 				"_cm_set_user_prefix")
	register_native("cm_set_user_prefix_status", 		"_cm_set_user_prefix_status")
	register_native("cm_set_user_say_format", 			"_cm_set_user_say_format")
	register_native("cm_total_chat_colors", 			"_cm_total_chat_colors")
	register_native("cm_total_prefixes", 				"_cm_total_chat_colors")
	register_native("cm_total_say_formats", 			"_cm_total_say_formats")
	register_native("cm_update_player_data", 			"_cm_update_player_data")
	set_native_filter("native_filter")
}

public native_filter(const szNative[], id, iTrap)
{
	if(!iTrap)
	{
		if(equal(szNative, "crxranks_get_user_level") || equal(szNative, "crxranks_user_level_updated"))
		{
			return PLUGIN_HANDLED
		}

		#if defined ARG_CURRENT_XP
		if(equal(szNative, "crxranks_get_user_xp"))
		{
			return PLUGIN_HANDLED
		}
		#endif

		#if defined ARG_NEXT_XP
		if(equal(szNative, "crxranks_get_user_next_xp"))
		{
			return PLUGIN_HANDLED
		}
		#endif

		#if defined ARG_NEXT_LEVEL
		if(equal(szNative, "crxranks_get_user_next_level"))
		{
			return PLUGIN_HANDLED
		}
		#endif

		#if defined ARG_RANK
		if(equal(szNative, "zp_get_user_divisao"))
		{
			return PLUGIN_HANDLED
		}
		#endif

		#if defined ARG_NEXT_RANK
		if(equal(szNative, "crxranks_get_user_next_rank"))
		{
			return PLUGIN_HANDLED
		}
		#endif
	}

	return PLUGIN_CONTINUE
}

public _cm_get_admin_listen_flags(iPlugin, iParams)
{
	set_string(1, g_eSettings[ADMIN_LISTEN_FLAGS], get_param(2))
}

public _cm_get_chat_color_by_num(iPlugin, iParams)
{
	new iNum = get_param(1)

	if(iNum < 0 || iNum >= g_iChatColors)
	{
		return 0
	}

	new szColor[32]
	ArrayGetString(g_aChatColors, iNum, szColor, charsmax(szColor))
	set_string(2, szColor, get_param(3))
	return 1
}

public _cm_get_prefix_by_num(iPlugin, iParams)
{
	new iNum = get_param(1)

	if(iNum < 0 || iNum >= g_iAdminPrefixes)
	{
		return 0
	}

	new szPrefix[32]
	ArrayGetString(g_aAdminPrefixes, iNum, szPrefix, charsmax(szPrefix))
	set_string(2, szPrefix, get_param(3))
	return 1
}

public _cm_get_user_chat_color(iPlugin, iParams)
{
	set_string(2, g_ePlayerData[get_param(1)][PDATA_CHAT_COLOR], get_param(3))
}

public bool:_cm_get_user_chat_color_status(iPlugin, iParams)
{
	return g_ePlayerData[get_param(1)][PDATA_CHAT_COLOR_ENABLED]
}

public _cm_get_user_custom_name(iPlugin, iParams)
{
	set_string(2, g_ePlayerData[get_param(1)][PDATA_CUSTOM_NAME], get_param(3))
}

public bool:_cm_get_user_custom_name_status(iPlugin, iParams)
{
	return g_ePlayerData[get_param(1)][PDATA_CUSTOM_NAME_ENABLED]
}

public _cm_get_user_prefix(iPlugin, iParams)
{
	set_string(2, g_ePlayerData[get_param(1)][PDATA_PREFIX], get_param(3))
}

public bool:_cm_get_user_prefix_status(iPlugin, iParams)
{
	return g_ePlayerData[get_param(1)][PDATA_PREFIX_ENABLED]
}

public bool:_cm_has_user_admin_listen(iPlugin, iParams)
{
	return g_ePlayerData[get_param(1)][PDATA_ADMIN_LISTEN]
}

public _cm_reload_config_file(iPlugin, iParams)
{
	ReadFile()
}

public _cm_set_user_chat_color(iPlugin, iParams)
{
	get_string(2, g_ePlayerData[get_param(1)][PDATA_CHAT_COLOR], charsmax(g_ePlayerData[][PDATA_CHAT_COLOR]))
}

public _cm_set_user_chat_color_status(iPlugin, iParams)
{
	g_ePlayerData[get_param(1)][PDATA_CHAT_COLOR_ENABLED] = _:get_param(2)
}

public _cm_set_user_custom_name_status(iPlugin, iParams)
{
	g_ePlayerData[get_param(1)][PDATA_CUSTOM_NAME_ENABLED] = _:get_param(2)
}

public _cm_set_user_prefix(iPlugin, iParams)
{
	get_string(2, g_ePlayerData[get_param(1)][PDATA_PREFIX], charsmax(g_ePlayerData[][PDATA_PREFIX]))
}

public _cm_set_user_prefix_status(iPlugin, iParams)
{
	static id; id = get_param(1)
	g_ePlayerData[id][PDATA_PREFIX_ENABLED] = _:get_param(2)

	if(get_param(3))
	{
		UpdateData(id)
	}
}

public _cm_set_user_say_format(iPlugin, iParams)
{
	static szFormat[32], id
	id = get_param(1)

	get_string(2, szFormat, charsmax(szFormat))

	if(TrieKeyExists(g_tFormatDefinitions, szFormat))
	{
		copy(g_ePlayerData[id][PDATA_SAY_FORMAT], charsmax(g_ePlayerData[][PDATA_SAY_FORMAT]), szFormat)
	}
	else
	{
		return 0
	}

	get_string(3, szFormat, charsmax(szFormat))

	if(TrieKeyExists(g_tFormatDefinitions, szFormat))
	{
		copy(g_ePlayerData[id][PDATA_SAY_TEAM_FORMAT], charsmax(g_ePlayerData[][PDATA_SAY_TEAM_FORMAT]), szFormat)
	}
	else
	{
		return 0
	}

	return 1
}

public _cm_total_chat_colors(iPlugin, iParams)
{
	return g_iChatColors
}

public _cm_total_prefixes(iPlugin, iParams)
{
	return g_iAdminPrefixes
}

public _cm_total_say_formats(iPlugin, iParams)
{
	return g_iSayFormats
}

public _cm_update_player_data(iPlugin, iParams)
{
	UpdateData(get_param(1))
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
