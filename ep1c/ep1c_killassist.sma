#include <amxmodx>
#include <fakemeta>
#include <reapi>

#define ASSIST_ALGORITHM			ADVANCED	/* 	Алгоритм для определения помощников в убийтве. По-умолчанию используется ADVANCED.
	CSSTATSX — эквивалентный CSstatsX алгоритм учёта помощи по убийствам с использованием соответствующего квара. Алгоритм выбирает такого игрока, который 
нанес больше всего ущерба жертве и не менее допустимого значения, определяемое кваром csstats_sql_assisthp из CSstatsX либо кваром aka_damage.
Если CSstatsX не установлен, то для просчётов используется значение aka_damage.
	ADVANCED — улучшенная и более справедливая формула, которая выбирает из ряда других ассистентов такого, кто больше всего нанес урона
жертве и чей процент урона от общего ущерба от всех составляет не менее aka_damage процентов. Этот алгоритм не синхронизируется 
с CSstatsX, что может повлечь к неучёту их в статистике. */

#define NAMES_LENGTH				28
#define is_user_valid(%0)			(0 < %0 && %0 < g_iMaxPlayers)

#if AMXX_VERSION_NUM < 183
	#define client_disconnected client_disconnect
#endif

#if REAPI_VERSION < 52121
    #error This plugin supports ReAPI >=5.2.0.121
#endif

#define DEBUG

enum
{
	CSSTATSX,
	ADVANCED
}

enum _:CVARS_DATA
{
	CVAR_FRAG,
	CVAR_MONEY,
	CVAR_DAMAGE
}

enum _:PLAYER_DATA
{
	CONNECTED,
	DAMAGE_ON[33],
	BLINDED_ON[33],
	Float:BLINDED_ON_ENDTIME[33],
	Float:DAMAGE_ON_TIME[33],
	NAME[32]
};

enum ASSIST_TYPE
{
	DAMAGE,
	BLINDED
};

new const PREFIX[] = "^4[ep1c gaming Brasil]^1";

new g_ePlayerData[33][PLAYER_DATA];
new g_pCvars[CVARS_DATA];
new g_iMaxPlayers;
new g_iMsgScoreInfo;
new g_szDeathString[32];
new g_iAssistKiller;
// new g_iAssistKillerReset;

// new HookChain:g_pSV_WriteFullClientUpdate;
new HookChain:g_pCBasePlayer_Killed_Post;

#if ASSIST_ALGORITHM == CSSTATSX
	new g_pCvarAssistHp
#endif

new g_iFW_assist;

public plugin_init()
{
	register_plugin("Advanced Kill Assists", "1.3", "Xelson + lonewolf")

	RegisterHookChain(RG_CBasePlayer_Spawn, "CBasePlayer_Spawn_Post", true)
	RegisterHookChain(RG_CBasePlayer_Killed, "CBasePlayer_Killed_Pre", false)
	RegisterHookChain(RG_CBasePlayer_TakeDamage, "CBasePlayer_TakeDamage_Post", true)
	DisableHookChain((g_pCBasePlayer_Killed_Post = RegisterHookChain(RG_CBasePlayer_Killed, "CBasePlayer_Killed_Post", true)))
	// DisableHookChain((g_pSV_WriteFullClientUpdate = RegisterHookChain(RH_SV_WriteFullClientUpdate, "SV_WriteFullClientUpdate", false)))
	register_message(get_user_msgid("DeathMsg"), "Message_DeathMsg")
	
	RegisterHookChain(RG_PlayerBlind, "event_RG_PlayerBlind");

	#if defined DEBUG
		register_clcmd("assist", "ClCmd_Assist")
	#endif

	#if ASSIST_ALGORITHM == CSSTATSX
		g_pCvarAssistHp = get_cvar_pointer("csstats_sql_assisthp")
	#endif

	g_iMsgScoreInfo = get_user_msgid("ScoreInfo")
	g_iMaxPlayers = get_maxplayers() + 1

	g_iFW_assist = CreateMultiForward("onKillAssist", ET_IGNORE, FP_CELL);
}

public plugin_cfg()
{
	g_pCvars[CVAR_FRAG] = register_cvar("aka_frag", "1")
	g_pCvars[CVAR_MONEY] = register_cvar("aka_money", "100")
	g_pCvars[CVAR_DAMAGE] = register_cvar("aka_damage", "30.0")
}

public client_infochanged(id)
{
	// new name[MAX_NAME_LENGTH];
	// copy(name, charsmax(name), g_ePlayerData[id][NAME]);
	get_user_info(id, "name", g_ePlayerData[id][NAME], charsmax(g_ePlayerData[][NAME]))

	// if (equal(name, g_ePlayerData[id][NAME]))
	// {
	// 	return PLUGIN_CONTINUE;
	// }

	// if(id == g_iAssistKiller)
	// {
	// 	set_user_info(id, "name", g_szDeathString);
	// 	// client_print(0, print_chat, "KA[%d]-> ^"%s^", len: %d", id, g_szDeathString, strlen(g_szDeathString));
	// }
	// else if (id == g_iAssistKillerReset)
	// {
	// 	set_user_info(id, "name", g_ePlayerData[id][NAME]);
	// 	g_iAssistKillerReset = 0;
	// 	// client_print(0, print_chat, "KA[%d]-> ^"%s^", len: %d", id, g_szDeathString, strlen(g_szDeathString));
	// }
}

public event_RG_PlayerBlind(const id, const inflictor, const attacker, Float:fadetime, Float:fadehold, alpha, Float:color[3]) 
{
	if ((id == attacker) || !g_ePlayerData[id][CONNECTED] || !g_ePlayerData[attacker][CONNECTED])
	{
		return HC_CONTINUE;
	}
	
	if (!is_user_alive(id))
	{
		return HC_CONTINUE;
	}

	new CsTeams:teamA = get_member(id, m_iTeam);
	new CsTeams:teamB = get_member(attacker, m_iTeam);

	if ((teamA == teamB) || (teamA == CS_TEAM_SPECTATOR) || (teamB == CS_TEAM_UNASSIGNED))
	{
		return HC_CONTINUE;
	}

	g_ePlayerData[attacker][BLINDED_ON][id] = 1;
	g_ePlayerData[attacker][BLINDED_ON_ENDTIME][id] = get_gametime() + fadetime;

	return HC_CONTINUE;
}

public client_putinserver(id) 
{
	g_ePlayerData[id][CONNECTED] = true;
	get_user_name(id, g_ePlayerData[id][NAME], charsmax(g_ePlayerData[][NAME]));
}

public client_disconnected(id)
{
	g_ePlayerData[id][CONNECTED] = false
	arrayset(g_ePlayerData[id][DAMAGE_ON], 0, sizeof g_ePlayerData[][DAMAGE_ON])
	arrayset(g_ePlayerData[id][BLINDED_ON], 0, sizeof g_ePlayerData[][BLINDED_ON])
}

public CBasePlayer_Spawn_Post(id)
{
	arrayset(g_ePlayerData[id][DAMAGE_ON], 0, sizeof g_ePlayerData[][DAMAGE_ON])
	arrayset(g_ePlayerData[id][BLINDED_ON], 0, sizeof g_ePlayerData[][BLINDED_ON])
}

public CBasePlayer_TakeDamage_Post(iVictim, iWeapon, iAttacker, Float:fDamage) //todo: check post
{
	if(is_user_valid(iAttacker) && iVictim != iAttacker && rg_is_player_can_takedamage(iVictim, iAttacker))
	{
		#if ASSIST_ALGORITHM == ADVANCED
			new Float:fHealth; get_entvar(iVictim, var_health, fHealth);
			if(fDamage > fHealth) fDamage = fHealth;
		#endif
		g_ePlayerData[iAttacker][DAMAGE_ON][iVictim] += floatround(fDamage, floatround_floor);
		g_ePlayerData[iAttacker][DAMAGE_ON_TIME][iVictim] = get_gametime();
	}
}

public CBasePlayer_Killed_Pre(iVictim, iKiller)
{
	new iAssistant, iMaxDamage, Float:fLastEndTime, ASSIST_TYPE:xAssistType;
	new Float:fDamageForAssist = get_pcvar_float(g_pCvars[CVAR_DAMAGE]);

	// client_print_color(0, print_team_red, "%s 1", PREFIX);

#if ASSIST_ALGORITHM == ADVANCED
	new iTotalDamage
	for(new id = 1; id < g_iMaxPlayers; id++)
	{
		if(g_ePlayerData[id][CONNECTED])
		{
			if(id != iKiller && g_ePlayerData[id][DAMAGE_ON][iVictim] > 0)
			{
				xAssistType = DAMAGE;
				if(g_ePlayerData[id][DAMAGE_ON][iVictim] > iMaxDamage)
				{
					iAssistant = id
					iMaxDamage = g_ePlayerData[id][DAMAGE_ON][iVictim]
				}
				else if(g_ePlayerData[id][DAMAGE_ON][iVictim] == iMaxDamage) 
				{
					iAssistant = g_ePlayerData[id][DAMAGE_ON_TIME][iVictim] > g_ePlayerData[iAssistant][DAMAGE_ON_TIME][iVictim] ? id : iAssistant
				}
			}
			iTotalDamage += g_ePlayerData[id][DAMAGE_ON][iVictim]
			g_ePlayerData[id][DAMAGE_ON][iVictim] = 0
		}
	}

	// client_print_color(0, print_team_red, "%s 2, iAssistant: ^4%d^1, iMaxDamage: ^4%d^1, iTotalDamage: ^4%d^1, xAssistType: ^4%d^1", PREFIX, iAssistant, iMaxDamage, iTotalDamage, _:xAssistType);

	new Float:max_health = get_entvar(iVictim, var_max_health);

	if (!iAssistant || (((float(iMaxDamage) / max_health) * 100.0) < fDamageForAssist))
	{
		new Float:gametime = get_gametime();

		iAssistant = 0;
		
		for (new id = 1; id < g_iMaxPlayers; id++)
		{
			if (!g_ePlayerData[id][CONNECTED])
			{
				continue;
			}
			if (id != iKiller && id != iVictim && g_ePlayerData[id][BLINDED_ON][iVictim])
			{
				new Float:fEndTime = g_ePlayerData[id][BLINDED_ON_ENDTIME][iVictim];
				if ((gametime < fEndTime) && (fEndTime >= fLastEndTime))
				{
					iAssistant = id;
					fLastEndTime = fEndTime;
					xAssistType = BLINDED;
				}
			}
			g_ePlayerData[id][BLINDED_ON][iVictim] = 0;
		}
	}
#elseif ASSIST_ALGORITHM == CSSTATSX
	new iNeedDamage = g_pCvarAssistHp ? get_pcvar_num(g_pCvarAssistHp) : floatround(fDamageForAssist)
	for(new id = 1; id < g_iMaxPlayers; id++)
	{
		if(g_ePlayerData[id][CONNECTED] && id != iKiller && g_ePlayerData[id][DAMAGE_ON][iVictim] > iMaxDamage)
		{
			if(g_ePlayerData[id][DAMAGE_ON][iVictim] > iNeedDamage)
			{
				iAssistant = id
				iMaxDamage = g_ePlayerData[id][DAMAGE_ON][iVictim]
			}
			else if(g_ePlayerData[id][DAMAGE_ON][iVictim] == iNeedDamage)
				iAssistant = g_ePlayerData[id][DAMAGE_ON_TIME][iVictim] > g_ePlayerData[iAssistant][DAMAGE_ON_TIME][iVictim] ? id : iAssistant
		}
	}
#endif

	// client_print_color(0, print_team_red, "%s 3, iAssistant: ^4%d^1, iMaxDamage: ^4%d^1, xAssistType: ^4%d^1", PREFIX, iAssistant, iMaxDamage, _:xAssistType);
	if(!iAssistant || iKiller == iVictim) return HC_CONTINUE

	new szName[2][32], iLen[2], iExcess
	copy(szName[1], charsmax(szName[]), g_ePlayerData[iAssistant][NAME])
	iLen[1] = strlen(szName[1])

	// EnableHookChain(g_pSV_WriteFullClientUpdate)
	
	if(!is_user_valid(iKiller) && g_ePlayerData[iAssistant][CONNECTED])
	{
		static const szWorldName[] = "world"

		iExcess = iLen[1] - NAMES_LENGTH - (sizeof szWorldName)
		if(iExcess > 0) strclip(szName[1], iExcess)
		formatex(g_szDeathString, charsmax(g_szDeathString), "%s + %s", szWorldName, szName[1])

		g_iAssistKiller = iAssistant
		// rh_update_user_info(iAssistant)
		set_user_fake_name(iKiller, g_szDeathString)
	}
	else
	{
		g_ePlayerData[iKiller][DAMAGE_ON][iVictim] = 0
		
		copy(szName[0], charsmax(szName[]), g_ePlayerData[iKiller][NAME])
		iLen[0] = strlen(szName[0])

		new iLenSum = (iLen[0] + iLen[1])
		iExcess = iLenSum - NAMES_LENGTH
		
		// szName[0] = ep1c ' lonewolf
		// iLen[0]   = 15
		// szName[1] = ep1c ' S H E R M A N
		// iLen[1]   = 20
		// iLen[0] + iLen[1] = 35
		// iExcess = 35 - 20 = 15

		// client_print(0, print_chat, "KA: [0]: %s, [1]: %s, EX: %d", szName[0], szName[1], iExcess)
		if(iExcess > 0)
		{
			// new iLongest = iLen[0] > iLen[1] ? 0 : 1
			// new iShortest = iLongest == 1 ? 0 : 1

			// if(float(iExcess) / float(iLen[iLongest]) > 0.60)
			// {
			// 	new iNewLongest = floatround(float(iLen[iLongest]) / float(iLenSum) * float(iExcess))
			// 	strclip(szName[iLongest], iNewLongest)
			// 	strclip(szName[iShortest], iExcess - iNewLongest)
			// }
			// else 
			// {
			// 	strclip(szName[iLongest], iExcess)
			// }

			// if ((iLongest == 1) || ((iLen[1] - iExcess) >= 4))
			// {
			// 	strclip(szName[1], iExcess)
			// }
			// else 
			// {
			// 	strclip(szName[1], iExcess)
			// }
			strclip(szName[1], min(iExcess, iLen[1]));

		}
		// client_print(0, print_chat, "KA: [0:%d]: %s, [1:%d]: %s, EX: %d, d: %d", iKiller, szName[0], iAssistant, szName[1], iExcess, iVictim)
		// client_print(0, print_chat, "KA: g_szDeathString: %s", g_szDeathString)
		formatex(g_szDeathString, charsmax(g_szDeathString), "%s + %s", szName[0], szName[1])

		g_iAssistKiller = iKiller
		// rh_update_user_info(g_iAssistKiller)
		set_user_fake_name(iKiller, g_szDeathString)
	}
	if(g_ePlayerData[iAssistant][CONNECTED])
	{   
		g_ePlayerData[iAssistant][DAMAGE_ON][iVictim] = 0

		new iAddMoney = get_pcvar_num(g_pCvars[CVAR_MONEY])
		if(iAddMoney > 0) rg_add_account(iAssistant, iAddMoney)

		if(get_pcvar_num(g_pCvars[CVAR_FRAG]))
		{
			new Float:fNewFrags; get_entvar(iAssistant, var_frags, fNewFrags)
			fNewFrags++
			set_entvar(iAssistant, var_frags, fNewFrags)

			message_begin(MSG_ALL, g_iMsgScoreInfo)
			write_byte(iAssistant)
			write_short(floatround(fNewFrags))
			write_short(get_member(iAssistant, m_iDeaths))
			write_short(0)
			write_short(get_member(iAssistant, m_iTeam))
			message_end()

			if (xAssistType == DAMAGE)
			{
				client_print_color(iAssistant, iVictim, "%s Você recebeu ^4+1 frag^1 por contribuir com ^4%d de dano^1 na morte de ^3%s^1!", PREFIX, iMaxDamage, g_ePlayerData[iVictim][NAME]);
			}
			else
			{
				client_print_color(iAssistant, iVictim, "%s Você recebeu ^4+1 frag^1 por contribuir com uma ^4Flashbang^1 na morte de ^3%s^1!", PREFIX, g_ePlayerData[iVictim][NAME]);
			}
		}

		ExecuteForward(g_iFW_assist, _, iAssistant)
	}

	EnableHookChain(g_pCBasePlayer_Killed_Post)
	return HC_CONTINUE
}

// public SV_WriteFullClientUpdate(id, pBuffer)
// {
// 	if(id == g_iAssistKiller)
// 	{
// 		set_key_value(pBuffer, "name", g_szDeathString);
// 		// client_print(0, print_chat, "KA[%d]-> ^"%s^", len: %d", id, g_szDeathString, strlen(g_szDeathString));
// 	}
// }

public Message_DeathMsg()
{
	new iWorld = get_msg_arg_int(1)
	if(iWorld == 0 && g_iAssistKiller)
		set_msg_arg_int(1, ARG_BYTE, g_iAssistKiller)
}

public CBasePlayer_Killed_Post(iVictim, iKiller)
{
	DisableHookChain(g_pCBasePlayer_Killed_Post);

	// new iAssistKiller = g_iAssistKiller; 
	g_iAssistKiller = 0;

	// rh_update_user_info(iAssistKiller);
	reset_user_info(iKiller);
}

// stock strclip(szString[], iSize, iClip)
// {
// 	copy(szString, iClip - 2, szString)
// 	add(szString, iSize, "..")
// }

stock strclip(szString[], iClip, szEnding[] = "..")
{
	new iLen = strlen(szString) - 1 - strlen(szEnding) - iClip
	format(szString[iLen], iLen, szEnding)
}

stock reset_user_info(id)
{
	new szUserInfo[256]
	copy_infokey_buffer(engfunc(EngFunc_GetInfoKeyBuffer, id), szUserInfo, charsmax(szUserInfo))
	#if defined HLTV_FIX
	for(new i = 1; i < g_iMaxPlayers; i++)
	{
		if(!is_user_hltv(i) && g_ePlayerData[i][CONNECTED])
		{
			message_begin(MSG_ONE, SVC_UPDATEUSERINFO, _, i)
	#else
			message_begin(MSG_ALL, SVC_UPDATEUSERINFO)
	#endif
			write_byte(id - 1)
			write_long(get_user_userid(id))
			write_string(szUserInfo)
			write_long(0)
			write_long(0)
			write_long(0)
			write_long(0)
			message_end()
	#if defined HLTV_FIX
		}
	}
	#endif
}

stock set_user_fake_name(const id, const name[])
{
	#if defined HLTV_FIX
	for(new i = 1; i < g_iMaxPlayers; i++)
	{
		if(!is_user_hltv(i) && g_ePlayerData[i][CONNECTED])
		{
			message_begin(MSG_ONE, SVC_UPDATEUSERINFO, _, i)
	#else
			message_begin(MSG_ALL, SVC_UPDATEUSERINFO)
	#endif
			write_byte(id - 1)
			write_long(get_user_userid(id))
			write_char('\')
			write_char('n')
			write_char('a')
			write_char('m')
			write_char('e')
			write_char('\')
			write_string(name)
			for(new i; i < 16; i++) write_byte(0)
			message_end()
	#if defined HLTV_FIX
		}
	}
	#endif
}

#if defined DEBUG
#include <hamsandwich>
public ClCmd_Assist()
{
	new id[4], szArg[64]
	for(new i; i < 4; i++)
	{
		read_argv(i + 1, szArg, charsmax(szArg))
		id[i] = str_to_num(szArg)
	}
	g_ePlayerData[id[1]][DAMAGE_ON][id[2]] = id[3] ? id[3] : 100
	ExecuteHamB(Ham_Killed, id[2], id[0], 0)
	ExecuteHamB(Ham_CS_RoundRespawn, id[2])
}
#endif