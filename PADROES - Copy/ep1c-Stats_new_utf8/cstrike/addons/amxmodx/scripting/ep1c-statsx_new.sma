#include <amxmodx>
#include <amxmisc>
#include <csx>
#include <nvault>
#include <cromchat>
#include <hamsandwich>
#include <fakemeta>

/*------------------------------------------------------------------- ----------------------------------------------------------*/

#define DEFAULT_ROLE_NAME "Player"

/* Uncommenct (remove "//") this line if you want to use OciXCrom's Chat Manager's prefixes*/
//#define USE_CRX_PREFIXES

#define STATSX_MOTD_STYLE "<link rel='stylesheet' href='http://fast.mgthost1.com.br/1854/cstrike/extra/statsx.css'><meta charset='UTF-8'>"

#define SHOW_BOTH_MOST "^n^n^n^n^n^n^n"
#define SHOW_ONE_MOST "^n^n^n^n^n^n^n^n^n"
#define SHOW_NO_MOST "^n^n^n^n^n^n^n^n^n^n^n"

/*------------------------------------ Do NOT modify below this line! ----------------------------------------------------------*/

#if defined USE_CRX_PREFIXES
	#include <chatmanager>
#endif

#define TASK_SPEC 14627
#define TASK_COUNT 64315

#if defined client_disconnected
    #define client_disconnect client_disconnected
#endif  

#define STATSX_MOTD_OPENING "<table>"
#define STATSX_MOTD_OPENING_TOPX "<table id=q>"
#define STATSX_MOTD_OPENING_RANKSTATS "<table id=d>"
#define STATSX_MOTD_OPENING_STATS "<table id=c>"
#define STATSX_MOTD_OPENING_WSTATS "<table id=r>"
#define STATSX_MOTD_OPENING_WSTATS2 "<table id=v>"
#define STATSX_MOTD_CLOSE "</table>"
#define STATSX_MOTD_ADDSPACE "<br>"

#define STATSX_MOTD_HEADER_DEFAULT "<tr><th>#<th>%L<th>%s<th>%L<th>%s<th>%s<th>%s<th>%s<th>%L<th>%L<th>%L</tr>"
#define STATSX_MOTD_HEADER_NO_C4 "<tr><th>#<th>%L<th>%s<th>%L<th>%s<th>%s<th>%s<th>%L<th>%L</tr>"
#define STATSX_MOTD_HEADER_CLASSIC "<tr><th>#<th>%L<th>%s<th>%L<th>%s<th>%s<th>%s<th>%L (%)<th>%L (%)</tr>"

#define STATSX_MOTD_TABLE_DEFAULT1 "<tr><td>%d<td>%s<td>%d<td>%d<td>%d<td>%d<td>%d<td>%d<td>%.1f %%<td>%d%<td>%d"
#define STATSX_MOTD_TABLE_DEFAULT2 "<tr id=b><td>%d<td>%s<td>%d<td>%d<td>%d<td>%d<td>%d<td>%d<td>%.1f %%<td>%d%<td>%d"

#define STATSX_MOTD_TABLE_NO_C41 "<tr><td>%d<td>%s<td>%d<td>%d<td>%d<td>%d<td>%d<td>%d<td>%.1f %%"
#define STATSX_MOTD_TABLE_NO_C42 "<tr id=b><td>%d<td>%s<td>%d<td>%d<td>%d<td>%d<td>%d<td>%d<td>%.1f %%"

#define STATSX_MOTD_TABLE_CLASSIC1 "<tr><td>%d<td>%s<td>%d<td>%d<td>%d<td>%d<td>%d<td>%.1f %%<td>%.1f %%"
#define STATSX_MOTD_TABLE_CLASSIC2 "<tr id=b><td>%d<td>%s<td>%d<td>%d<td>%d<td>%d<td>%d<td>%.1f %%<td>%.1f %%"

#define STATSX_MOTD_RANKSTATS1 "<tr><th>%L:<th><tr><td>%s<td>%d (%L %d %L)<tr><td id=b>%L<td id=b>%d<tr><td>%s<td>%d<tr><td id=b>%s<td id=b>%d<tr><td>%s<td>%d<tr><td id=b>%L (%%)<td id=b>%.1f %%<tr><td>%L (%%)<td>%.1f %%"
#define STATSX_MOTD_RANKSTATS2 "<tr><th>%s:<th><tr><td>%s<td>%d<tr><td id=b>%s<td id=b>%d<tr><td>%s<td>%d<tr><td id=b>%s<td id=b>%d<tr><td>%s<td>%d<tr><td id=b>%s<td id=b>%d<tr><td>%s<td>%d"
#define STATSX_MOTD_RANKSTATS3 "<center><font id=f>%L</font></center>"

#define STATSX_MOTD_HEADER_MAPTOP "<tr><th>#<th>%L<th>%s<th>%s<th>%L<th>%L<th>%L<th>%L<th>%L</tr>"
#define STATSX_MOTD_TABLE_MAPTOP1 "<tr><td>%d<td>%s<td>%d<td>%d<td>%.1f %%<td>%d<td>%.1f %%<td>%d<td>%.1f %%"
#define STATSX_MOTD_TABLE_MAPTOP2 "<tr id=b><td>%d<td>%s<td>%d<td>%d<td>%.1f %%<td>%d<td>%.1f %%<td>%d<td>%.1f %%"

#define STATSX_MOTD_STATS1 "<tr><th>%L:<th><tr><td>%s<td>%d (%L %d %L)<tr><td id=b>%L<td id=b>%d<tr><td>%s<td>%d<tr><td id=b>%s<td id=b>%d<tr><td>%s<td>%d<tr><td id=b>%L (%%)<td id=b>%.1f %%<tr><td>%L (%%)<td>%.1f %%"
#define STATSX_MOTD_STATS2 "<tr><th>%L:<th><tr><td>%L<td>%02d %L %02d %L %02d %L<tr><td id=b>%L<td id=b>%d<tr><td>%L<td>%d<tr><td id=b>%L<td id=b>%d<tr><td>%L<td id=clr><b>%s</b><tr><td id=b>%L<td id=b><progress max=100.0 value=%.1f></progress>%.1f %%<tr><td>%L<td>%s"
#define STATSX_MOTD_WSTATS1 "<tr><th>%L<th>%s<th>%L<th>%s<th>%s<th>%s<th>%L (%%)</tr>"
#define STATSX_MOTD_WSTATS2 "<tr><td>%s<td>%d<td>%d<td>%d<td>%d<td>%d<td>%.1f %%"
#define STATSX_MOTD_WSTATS3 "<tr id=b><td>%s<td>%d<td>%d<td>%d<td>%d<td>%d<td>%.1f %%"

public KillerChat
public ShowAttackers
public ShowVictims
public ShowKiller
public ShowTeamScore
public ShowTotalStats
public ShowMostDisruptive
public ShowBestScore
public EndPlayer
public EndTop15
public EndMapTop
public SayHP
public SayStatsMe
public SayRankStats
public SayMe
public SayRank
public SayReport
public SayScore
public SayTop15
public SayMapTop
public SayHS
public SayKnife
public SayGrenade
public SayStatsAll
public ShowStats
public ShowDistHS
public SpecRankInfo

enum _:Stats
{
	STATS_KILLS = 0,
	STATS_DEATHS,
	STATS_HS,
	STATS_TEAMK,
	STATS_SHOTS,
	STATS_HITS,
	STATS_DAMAGE
}

enum _:Stats2
{
	STATS_DEFUSED = 1,
	STATS_PLANTED,
	STATS_EXPLODED
}

enum _:MapStats
{
	ALL_KILLS = 0,
	HS_KILLS,
	KNIFE_KILLS,
	GRENADE_KILLS
}

enum _:KillerInfo
{
	Id,
	Name[32],
	Hp,
	Ap,
	Distance
}

new const BODY_PART[8][] =
{
	"WHOLEBODY", 
	"HEAD", 
	"CHEST", 
	"STOMACH", 
	"LEFTARM", 
	"RIGHTARM", 
	"LEFTARM", 
	"RIGHTARM"
}

enum _:HudSettings
{
	Color[3],
	Float:Position[2],
	Effect,
	Float:DurationEff
}	
	
new Float:g_flCooldown
new bool:g_blStats, bool:g_blPrefix, bool:g_bRankUp[33], bool:g_bEndRound, bool:g_bNewGame
new g_szBuffer[2048], g_szName[32], g_szName2[23], g_szWpn[32], g_szHudBuffer[4][1024], g_szTopX[12], g_iTopNum
new g_szTime[33][32], g_iTotalPlayedTime[33], g_iOldRank[33], g_iKills[33][4], g_iPlayerStats[33][8]
new g_iInfoRank[33], g_iKilled[33][KillerInfo], g_iSwitch[33], g_iHudShow[33]
new g_iTeamScore[4], g_iTeamStats[4][8], g_iGameStats[4][8]

new cvar_top_info, cvar_topx_type, cvar_maptop_num, cvar_prefix, cvar_durationhud
new g_iSpecRank, g_iStats, g_iHudAttacker, g_iHudVictim, g_iHudKiller
new g_iVault, g_iVault2, g_iVault3
new Array:g_aHud

public plugin_init()
{
	register_plugin("ep1c: StatsX New", "1.4", "Tornado_SW")
	register_cvar("StatsXNew", "1.4", FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	register_event("TextMsg", "eventResetStats", "a", "2=#Game_Commencing", "2=#Game_will_restart_in")
	register_event("SendAudio", "eventTerrWin", "a", "2&%!MRAD_terwin")
	register_event("SendAudio", "eventCTWin", "a", "2&%!MRAD_ctwin")
	register_event("ResetHUD", "eventResetHUD", "b")
	register_message(SVC_INTERMISSION, "msgIntermission")
	register_logevent("eventRoundStart", 2, "1=Round_Start")
	register_logevent("eventRoundEnd", 2, "1=Round_End")
	RegisterHam(Ham_Spawn, "player", "hamPlayerSpawn", 1)
	
	register_clcmd("say", "cmdTop")
	register_clcmd("say_team", "cmdTop")
	register_clcmd("say /maptop", "cmdMapTop")
	register_clcmd("say_team /maptop", "cmdMapTop")
	register_clcmd("say /rankstats", "cmdRankStats")
	register_clcmd("say_team /rankstats", "cmdRankStats")
	register_clcmd("say /stats", "cmdStats")
	register_clcmd("say_team /stats", "cmdStats")
	register_clcmd("say /statsme", "cmdStatsMe")
	register_clcmd("say_team /statsme", "cmdStatsMe")
	register_clcmd("say /hp", "cmdHP")
	register_clcmd("say_team /hp", "cmdHP")
	register_clcmd("say /me", "cmdMe")
	register_clcmd("say_team /me", "cmdMe")
	register_clcmd("say /score", "cmdScore")
	register_clcmd("say_team /score", "cmdScore")
	register_clcmd("say /report", "cmdReport")
	register_clcmd("say_team /report", "cmdReport")
	register_clcmd("say /rank", "cmdRank")
	register_clcmd("say_team /rank", "cmdRank")
	register_clcmd("say /switch", "cmdSwitch")
	register_clcmd("say_team /switch", "cmdSwitch")
	register_clcmd("say /inforank", "cmdInfoRank")
	register_clcmd("say_team /inforank", "cmdInfoRank")
	register_clcmd("say /headshot", "cmdShowHS")
	register_clcmd("say_team /headshot", "cmdShowHS")
	register_clcmd("say /knife", "cmdShowKV")
	register_clcmd("say_team /knife", "cmdShowKV")
	register_clcmd("say /grenade", "cmdShowGD")
	register_clcmd("say_team /grenade", "cmdShowGD")
	
	g_iVault = nvault_open("LastActivity")
	g_iVault2 = nvault_open("PlayedTime")
	
	new szFormMap[32], szMap[32]
	get_mapname(szMap, charsmax(szMap))
	formatex(szFormMap, charsmax(szFormMap), "SaveStats_%s", szMap)
	g_iVault3 = nvault_open(szFormMap)
	
	cvar_topx_type = register_cvar("statsx_new_topx_type", "0")
	cvar_top_info = register_cvar("statsx_new_top_info", "15")
	cvar_maptop_num = register_cvar("statsx_new_maptop_num", "10")
	cvar_prefix = register_cvar("statsx_new_prefix", "&x04[ep1c gaming Brasil]&x01")
	cvar_durationhud = register_cvar("amx_statsx_duration", "12.0")
	
	g_iSpecRank = CreateHudSyncObj()
	g_iStats = CreateHudSyncObj()
	g_iHudAttacker = CreateHudSyncObj()
	g_iHudVictim = CreateHudSyncObj()
	g_iHudKiller = CreateHudSyncObj()
	
	set_task(1.0, "taskSpecInfo", TASK_SPEC, .flags = "b")
	
	new szPrefix[32]
	get_pcvar_string(cvar_prefix, szPrefix, charsmax(szPrefix))
	CC_SetPrefix(szPrefix)
	
	register_dictionary("statsx_new.txt")
}

public plugin_cfg()
{
	new addStast[] = "amx_statscfg add ^"%s^" %s"
	
	server_cmd(addStast, "ST_SHOW_KILLER_CHAT", "KillerChat")
	server_cmd(addStast, "ST_SHOW_ATTACKERS", "ShowAttackers")
	server_cmd(addStast, "ST_SHOW_VICTIMS", "ShowVictims")
	server_cmd(addStast, "ST_SHOW_KILLER", "ShowKiller")
	server_cmd(addStast, "ST_SHOW_TEAM_SCORE", "ShowTeamScore")
	server_cmd(addStast, "ST_SHOW_TOTAL_STATS", "ShowTotalStats")
	server_cmd(addStast, "ST_SHOW_MOST_DISRUPTIVE", "ShowMostDisruptive")
	server_cmd(addStast, "ST_SHOW_BEST_SCORE", "ShowBestScore")
	server_cmd(addStast, "ST_SHOW_HUD_STATS_DEF", "ShowStats")
	server_cmd(addStast, "ST_SHOW_DIST_HS_HUD", "ShowDistHS")
	server_cmd(addStast, "ST_STATS_PLAYER_MAP_END", "EndPlayer")
	server_cmd(addStast, "ST_STATS_TOP15_MAP_END", "EndTop15")
	server_cmd(addStast, "ST_STATS_MAPTOP_MAP_END", "EndMapTop")
	server_cmd(addStast, "ST_SAY_HP", "SayHP")
	server_cmd(addStast, "ST_SAY_STATSME", "SayStatsMe")
	server_cmd(addStast, "ST_SAY_RANKSTATS", "SayRankStats")
	server_cmd(addStast, "ST_SAY_ME", "SayMe")
	server_cmd(addStast, "ST_SAY_RANK", "SayRank")
	server_cmd(addStast, "ST_SAY_REPORT", "SayReport")
	server_cmd(addStast, "ST_SAY_SCORE", "SayScore")
	server_cmd(addStast, "ST_SAY_TOP15", "SayTop15")
	server_cmd(addStast, "ST_SAY_MAPTOP", "SayMapTop")
	server_cmd(addStast, "ST_SAY_HS", "SayHS")
	server_cmd(addStast, "ST_SAY_KNIFE", "SayKnife")
	server_cmd(addStast, "ST_SAY_GRENADE", "SayGrenade")
	server_cmd(addStast, "ST_SAY_STATS", "SayStatsAll")
	server_cmd(addStast, "ST_SPEC_RANK", "SpecRankInfo")
	
	g_aHud = ArrayCreate(HudSettings)
	readsettings()
}	

readsettings()
{
	new szHudFile[256]
	get_configsdir(szHudFile, charsmax(szHudFile))
	add(szHudFile, charsmax(szHudFile), "/HudSettings.ini")
	
	new iFile = fopen(szHudFile, "rt")
	
	if(iFile)
	{
		new szData[256], szKey[32], szValue[32]
		new eHud[HudSettings]
		
		while(!feof(iFile))
		{
			fgets(iFile, szData, charsmax(szData))
			trim(szData)
			
			if(szData[0] == '[')
			{
				ArrayPushArray(g_aHud, eHud)
			}
			
			strtok(szData, szKey, charsmax(szKey), szValue, charsmax(szValue), '=')
			trim(szKey)
			trim(szValue)
			
			if(equal(szKey, "COLOR"))
			{
				new szColor[3][4]
				parse(szValue, szColor[0], charsmax(szColor[]), szColor[1], charsmax(szColor[]), szColor[2], charsmax(szColor[]))
				
				for(new i; i < 3; i++)
				{
					eHud[Color][i] = str_to_num(szColor[i])
				}
			}
			else if(equal(szKey, "POSITION"))
			{
				new szPos[2][5]
				parse(szValue, szPos[0], charsmax(szPos[]), szPos[1], charsmax(szPos[]))
				
				for(new i; i < 2; i++)
				{
					eHud[Position][i] = _:str_to_float(szPos[i])
				}
			}
			else if(equal(szKey, "EFFECT"))
			{
				eHud[Effect] = str_to_num(szValue)
			}
			else if(equal(szKey, "DURATION_EFF"))
			{
				eHud[DurationEff] = _:str_to_float(szValue)
			}
		}
		
		ArrayPushArray(g_aHud, eHud)
		fclose(iFile)
	}
}

public plugin_end()
{
	ArrayDestroy(g_aHud)
}
	
public msgIntermission()
{
	new iPlayers[32], iPNum
	get_players(iPlayers, iPNum)
	
	for(new plr, i; i < iPNum; i++)
	{
		plr = iPlayers[i]
		
		if(g_iSwitch[plr])
		{
			if(EndPlayer)
			{
				new szStats[32]
				formatex(szStats, charsmax(szStats), "%L", plr, "STATSME")
				get_stats_format(plr)
				show_motd(plr, g_szBuffer, szStats)
			}
			else if(EndTop15)
			{
				g_iTopNum = 15
				
				new szTopX[12]
				formatex(szTopX, charsmax(szTopX), "%L", plr, "TOP_X", g_iTopNum)
				get_top_format(plr)
				show_motd(plr, g_szBuffer, szTopX)
			}
			else if(EndMapTop)
			{
				get_maptop_format(plr)
				show_motd(plr, g_szBuffer, g_szTopX)
			}
		}
	}
	
	return PLUGIN_HANDLED
}

public client_disconnect(id)
{
	get_time("%m/%d/%Y - %H:%M:%S", g_szTime[id], charsmax(g_szTime[]))
	UseVault(id, 0)
	UseVault2(id, 0)
	UseVault3(id, 0)
}

public client_connect(id)
{
	UseVault(id, 1)
	UseVault2(id, 1)
	UseVault3(id, 1)
	g_iInfoRank[id] = 1
	g_iSwitch[id] = 1
	
	new szText[32]
	
	if(get_user_info(id, "_inforank", szText, charsmax(szText)))
	{
		g_iInfoRank[id] = szText[0] ? str_to_num(szText) : 0
	}
	
	if(ShowStats)
	{
		if(get_user_info(id, "_amxstatsx", szText, charsmax(szText)))
		{
			g_iSwitch[id] = szText[0] ? str_to_num(szText) : 0
		}
	}
	else
	{
		g_iSwitch[id] = 0
	}
}

public eventResetStats()
{
	for(new i; i < 8; i++)
	{
		for(new j = 1; j < 3; j++)
		{
			g_iGameStats[j][i] = 0
			g_iTeamStats[j][i] = 0
			g_iTeamScore[j] = 0
		}
	}
	
	g_bNewGame = true
}

public hamPlayerSpawn(id)
{
	if(!is_user_alive(id))
	{
		return
	}
	
	g_iKilled[id][Id] = 0
	g_iHudShow[id] = 0
	
	for(new i; i < 8; i++)
	{
		g_iPlayerStats[id][i] = 0
	}
	
	set_task(1.0, "taskRankInfo", id)
}

public taskRankInfo(id)
{
	new szName[32], iStats[8], iBody[8], iMax
	new iTopInfo = get_pcvar_num(cvar_top_info)
	
	if(iTopInfo < 1 || !g_iInfoRank[id])
	{
		return PLUGIN_HANDLED
	}
	
	iMax = get_statsnum()
	get_user_name(id, szName, charsmax(szName))
	
	if(!g_bRankUp[id])
	{
		if(get_user_stats(id, iStats, iBody) <= iTopInfo)
		{
			CromChat(id, "%L", id, "TOP_GOOD", iTopInfo)
			CromChat(id, "%L", id, "RANK_NOW", get_user_stats(id, iStats, iBody), iMax)
			
			g_bRankUp[id] = true
			g_iOldRank[id] = get_user_stats(id, iStats, iBody)
			return PLUGIN_CONTINUE
		}
	}
	else
	{
		if(get_user_stats(id, iStats, iBody) > iTopInfo)
		{
			CromChat(id, "%L", id, "TOP_BAD", iTopInfo)
			CromChat(id, "%L", id, "RANK_NOW", get_user_stats(id, iStats, iBody), iMax)
			
			g_bRankUp[id] = false
			g_iOldRank[id] = get_user_stats(id, iStats, iBody)
			return PLUGIN_CONTINUE
		}
	}
	
	if(g_iOldRank[id] > get_user_stats(id, iStats, iBody))
	{
		CromChat(id, "%L", id, "RANK_UP", g_iOldRank[id] - get_user_stats(id, iStats, iBody), id, (g_iOldRank[id] - get_user_stats(id, iStats, iBody)) == 1 ? "RANK" : "RANKS")
	}
	else if(g_iOldRank[id] != 0 && g_iOldRank[id] < get_user_stats(id, iStats, iBody))
	{
		CromChat(id, "%L", id, "RANK_DOWN", get_user_stats(id, iStats, iBody) - g_iOldRank[id], id, (get_user_stats(id, iStats, iBody) - g_iOldRank[id]) == 1 ? "RANK" : "RANKS")
	}
	else if(g_iOldRank[id] == get_user_stats(id, iStats, iBody))
	{
		return PLUGIN_HANDLED
	}
		
	g_iOldRank[id] = get_user_stats(id, iStats, iBody)
	CromChat(id, "%L", id, "RANK_NOW", get_user_stats(id, iStats, iBody), iMax)
	return PLUGIN_HANDLED
}

public eventTerrWin()
{
	g_iTeamScore[1]++
}

public eventCTWin()
{
	g_iTeamScore[2]++
}

public eventResetHUD(id)
{
	new szArgs[1]
	szArgs[0] = id
	showHUD(szArgs)
	
	if(g_bNewGame)
	{
		set_task(3.0, "taskNewGameOff")
	}
}

public showHUD(szArgs[])
{
	if(g_bNewGame)
	{
		return
	}
	
	new id = szArgs[0]
	show_endround_hud(id, get_pcvar_float(cvar_durationhud) - g_flCooldown)
	show_hud_stats(id, get_pcvar_float(cvar_durationhud) - g_flCooldown)
}

public taskNewGameOff()
{
	g_bNewGame = false
}

public eventRoundStart()
{
	for(new i; i < 8; i++)
	{
		g_iTeamStats[1][i] = 0
		g_iTeamStats[2][i] = 0
	}
	
	if(SpecRankInfo)
	{
		if(task_exists(TASK_SPEC))
		{
			remove_task(TASK_SPEC)
		}
		
		set_task(1.0, "taskSpecInfo", TASK_SPEC, .flags = "b")
	}
	
	g_bEndRound = false
	set_task(1.0, "taskResetCooldown")
}

public taskResetCooldown()
{
	if(task_exists(TASK_COUNT))
	{
		remove_task(TASK_COUNT)
	}
	
	g_flCooldown = 0.0
}

public client_death(iAttacker, iVictim, iWpnIndex, iHitPlace)
{
	if(!is_user_connected(iAttacker) && iAttacker == iVictim)
	{
		return
	}
	
	new iOrigin1[3], iOrigin2[3]
	get_user_origin(iVictim, iOrigin1)
	get_user_origin(iAttacker, iOrigin2)
	get_user_name(iAttacker, g_iKilled[iVictim][Name], charsmax(g_iKilled[]))
	
	g_iKilled[iVictim][Id] = iAttacker
	g_iKilled[iVictim][Hp] = get_user_health(iAttacker)
	g_iKilled[iVictim][Ap] = get_user_armor(iAttacker)
	g_iKilled[iVictim][Distance] = get_distance(iOrigin1, iOrigin2)
	
	if(iHitPlace == HIT_HEAD)
	{
		g_iKills[iAttacker][HS_KILLS]++
	}
	
	switch(iWpnIndex)
	{
		case CSW_KNIFE: g_iKills[iAttacker][KNIFE_KILLS]++
		case CSW_HEGRENADE: g_iKills[iAttacker][GRENADE_KILLS]++
	}
	
	if(KillerChat && g_iKilled[iVictim][Id] && g_iKilled[iVictim][Id] != iVictim)
	{
		get_killer(iVictim)
		get_victim(iVictim, g_iKilled[iVictim][Id])
	}
	
	g_iKills[iAttacker][ALL_KILLS]++
	set_task(0.3, "taskShowStats", iVictim)
}

public taskShowStats(id)
{	
	if(g_bEndRound)
	{
		return
	}
	
	show_hud_stats(id, get_pcvar_float(cvar_durationhud))
	g_iHudShow[id] = 1
}

show_hud_stats(id, Float:flDuration)
{
	if(g_iHudShow[id] || !g_iSwitch[id])
	{
		return
	}
	
	new eHud[HudSettings]
	
	if(ShowAttackers)
	{
		ArrayGetArray(g_aHud, 1, eHud)
		format_attackers(id)
		
		if(eHud[Color][0] == 256 || eHud[Color][1] == 256 || eHud[Color][2] == 256)
		{
			set_hudmessage(random(256), random(256), random(256), eHud[Position][0], eHud[Position][1], eHud[Effect], eHud[DurationEff], flDuration, 0.1, 0.1, -1)
		}
		else
		{
			set_hudmessage(eHud[Color][0], eHud[Color][1], eHud[Color][2], eHud[Position][0], eHud[Position][1], eHud[Effect], eHud[DurationEff], flDuration, 0.1, 0.1, -1)
		}
		
		ShowSyncHudMsg(id, g_iHudAttacker, g_szHudBuffer[1])
	}
		
	if(ShowVictims)
	{
		ArrayGetArray(g_aHud, 2, eHud)
		format_victims(id)
		
		if(eHud[Color][0] == 256 || eHud[Color][1] == 256 || eHud[Color][2] == 256)
		{
			set_hudmessage(random(256), random(256), random(256), eHud[Position][0], eHud[Position][1], eHud[Effect], eHud[DurationEff], flDuration, 0.1, 0.1, -1)
		}
		else
		{
			set_hudmessage(eHud[Color][0], eHud[Color][1], eHud[Color][2], eHud[Position][0], eHud[Position][1], eHud[Effect], eHud[DurationEff], flDuration, 0.1, 0.1, -1)
		}
		
		ShowSyncHudMsg(id, g_iHudVictim, g_szHudBuffer[2])
	}	
		
	if(ShowKiller)
	{
		ArrayGetArray(g_aHud, 3, eHud)
		format_killer(id)
		
		if(eHud[Color][0] == 256 || eHud[Color][1] == 256 || eHud[Color][2] == 256)
		{
			set_hudmessage(random(256), random(256), random(256), eHud[Position][0], eHud[Position][1], eHud[Effect], eHud[DurationEff], flDuration, 0.1, 0.1, -1)
		}
		else
		{
			set_hudmessage(eHud[Color][0], eHud[Color][1], eHud[Color][2], eHud[Position][0], eHud[Position][1], eHud[Effect], eHud[DurationEff], flDuration, 0.1, 0.1, -1)
		}
		
		ShowSyncHudMsg(id, g_iHudKiller, g_szHudBuffer[3])
	}
}

public eventRoundEnd()
{	
	if(g_bNewGame)
	{
		return
	}
	
	set_task(0.1, "taskPrepareStats")
	set_task(1.0, "taskCountdown", TASK_COUNT, .flags = "b")
}

public taskPrepareStats()
{	
	new iPlayers[32], iPNum
	get_players(iPlayers, iPNum)
	
	for(new plr, iStats[8], iBody[8], iTeam, i; i < iPNum; i++)
	{
		plr = iPlayers[i]
		g_bEndRound = true
		iTeam = get_user_team(plr)
		get_user_rstats(plr, iStats, iBody)
			
		for(new i; i < 8; i++)
		{
			g_iTeamStats[iTeam][i] += iStats[i]
			g_iGameStats[iTeam][i] += iStats[i]
			g_iPlayerStats[plr][i] += iStats[i]
		}
		
		set_task(0.1, "taskPrepadeHUD", plr)
	}
}

public taskCountdown()
{
	g_flCooldown += 1.0
}

public taskPrepadeHUD(plr)
{
	prepare_hud_stats(plr)
	show_endround_hud(plr, get_pcvar_float(cvar_durationhud))
	show_hud_stats(plr, get_pcvar_float(cvar_durationhud))
}

prepare_hud_stats(id)
{	
	new szHud[512]
	g_szHudBuffer[0][0] = 0
	
	if(ShowMostDisruptive)
	{
		new iMostDamageId = 0, iMostDamage = 0, iMostHits = 0
		
		for(new k = 1; k < get_maxplayers(); k++)
		{
			if(g_iPlayerStats[k][STATS_DAMAGE] >= iMostDamage)
			{
				iMostDamageId = k
				iMostDamage = g_iPlayerStats[k][STATS_DAMAGE]
				iMostHits = g_iPlayerStats[k][STATS_HITS]
			}
		}
			
		if(iMostDamageId && iMostDamage)
		{
			new szName[32]
			new id2 = iMostDamageId
			get_user_name(id2, szName, charsmax(szName))
			formatex(szHud, charsmax(szHud), "%L: %s^n%d %L / %d %L^n%0.2f%% %L / %0.2f%% %L^n^n", id, "MOST_DAMAGE", szName, iMostDamage, id, iMostDamage == 1 ? "DAMAGE" : "DAMAGES", iMostHits, id,
			iMostHits == 1 ? "HIT" : "HITS", eff(g_iPlayerStats[id2]), id, "EFF", acc(g_iPlayerStats[id2]), id, "ACC")
			add(g_szHudBuffer[0], charsmax(g_szHudBuffer[]), szHud)
		}
	}
		
	if(ShowBestScore)
	{
		new iBestId = 0, iMostKills = 0, iMostHS = 0
			
		for(new l = 1; l < get_maxplayers(); l++)
		{
			if(g_iPlayerStats[l][STATS_KILLS] >= iMostKills)
			{
				iBestId = l
				iMostKills = g_iPlayerStats[l][STATS_KILLS]
				iMostHS = g_iPlayerStats[l][STATS_HS]
			}
		}
			
		if(iBestId && iMostKills)
		{
			new szName[32]
			new id3 = iBestId
			get_user_name(id3, szName, charsmax(szName))
			formatex(szHud, charsmax(szHud), "%L: %s^n%d %L / %d %L^n%0.2f%% %L / %0.2f%% %L^n", id, "BEST_SCORE", szName, iMostKills, id, iMostKills == 1 ? "KILL" : "KILLS", iMostHS, id, "HS", eff(g_iPlayerStats[id3]),
			id, "EFF", acc(g_iPlayerStats[id3]), id, "ACC")
			add(g_szHudBuffer[0], charsmax(g_szHudBuffer[]), szHud)
		}
	}
		
	if(ShowMostDisruptive && ShowBestScore)
	{
		add(g_szHudBuffer[0], charsmax(g_szHudBuffer[]), SHOW_BOTH_MOST)
	}
	else if(ShowMostDisruptive || ShowBestScore)
	{
		add(g_szHudBuffer[0], charsmax(g_szHudBuffer[]), SHOW_ONE_MOST)
	}
	else
	{
		add(g_szHudBuffer[0], charsmax(g_szHudBuffer[]), SHOW_NO_MOST)
	}
		
	if(ShowTeamScore)
	{
		formatex(szHud, charsmax(szHud), "%L %d / %0.2f%% %L / %0.2f%% %L^n%L %d / %0.2f%% %L / %0.2f%% %L^n", id, "TERRORIST", g_iTeamScore[1], eff(g_iTeamStats[1]), id, "EFF", acc(g_iTeamStats[1]), id, "ACC", id, "CT",
		g_iTeamScore[2], eff(g_iTeamStats[2]), id, "EFF", acc(g_iTeamStats[2]), id, "ACC")
		add(g_szHudBuffer[0], charsmax(g_szHudBuffer[]), szHud)
	}
		
	if(ShowTotalStats)
	{
		formatex(szHud, charsmax(szHud), "%L: %d %L / %d %L -- %d %L / %d %L", id, "TOTAL", g_iPlayerStats[id][STATS_KILLS], id, g_iPlayerStats[id][STATS_KILLS] == 1 ? "KILL" : "KILLS", g_iPlayerStats[id][STATS_HS],
		id, g_iPlayerStats[id][STATS_HS] == 1 ? "HEADSHOT" : "HEADSHOTS", g_iPlayerStats[id][STATS_HITS], id, g_iPlayerStats[id][STATS_HITS] == 1 ? "HIT" : "HITS", g_iPlayerStats[id][STATS_SHOTS], id,
		g_iPlayerStats[id][STATS_SHOTS] == 1 ? "SHOT" : "SHOTS")
		add(g_szHudBuffer[0], charsmax(g_szHudBuffer[]), szHud)
	}
}

show_endround_hud(id, Float:flDuration)
{
	if(!g_iSwitch[id])
	{
		return
	}
	
	new eHud[HudSettings]
	ArrayGetArray(g_aHud, 4, eHud)
	
	if(eHud[Color][0] == 256 || eHud[Color][1] == 256 || eHud[Color][2] == 256)
	{
		set_hudmessage(random(256), random(256), random(256), eHud[Position][0], eHud[Position][1], eHud[Effect], eHud[DurationEff], flDuration, 0.1, 0.1, -1)
	}
	else
	{
		set_hudmessage(eHud[Color][0], eHud[Color][1], eHud[Color][2], eHud[Position][0], eHud[Position][1], eHud[Effect], eHud[DurationEff], flDuration, 0.1, 0.1, -1)
	}
		
	ShowSyncHudMsg(id, g_iStats, g_szHudBuffer[0])
}

format_attackers(id)
{
	new iStats[8], iBody[8], szFormat[512]
	new iAttacker = g_iKilled[id][Id]
	new iFound = 0
	iStats[STATS_SHOTS] = 0
	g_szHudBuffer[1][0] = 0
	
	if(iAttacker)
	{
		get_user_astats(id, iAttacker, iStats, iBody)
	}
	
	if(iStats[STATS_SHOTS])
	{
		formatex(g_szHudBuffer[1], charsmax(g_szHudBuffer[]), "%L -- %0.2f%% Acc.:^n", id, "ATTACKERS", acc(iStats))
	}
	else
	{
		formatex(g_szHudBuffer[1], charsmax(g_szHudBuffer[]), "%L:^n", id, "ATTACKERS")
	}
	
	for(iAttacker = 1; iAttacker <= get_maxplayers(); iAttacker++)
	{
		if(get_user_astats(id, iAttacker, iStats, iBody, g_szWpn, charsmax(g_szWpn)))
		{
			iFound = 1
			get_user_name(iAttacker, g_szName, charsmax(g_szName))
			
			if(iStats[STATS_KILLS])
			{
				if(!ShowDistHS)
				{
					formatex(szFormat, charsmax(szFormat), "%s -- %d %L / %d %L / %s^n", g_szName, iStats[STATS_HITS], id, iStats[STATS_HITS] == 1 ? "HIT" : "HITS", iStats[STATS_DAMAGE], id,
					iStats[STATS_DAMAGE] == 1 ? "DAMAGE" : "DAMAGES", g_szWpn)
					add(g_szHudBuffer[1], charsmax(g_szHudBuffer[]), szFormat)
				}
				else
				{
					new szHS[16]
					formatex(szHS, charsmax(szHS), "/ %L", id, "HS")
					formatex(szFormat, charsmax(szFormat), "%s -- %d %L / %d %L / %s / %0.2fm %s^n", g_szName, iStats[STATS_HITS], id, iStats[STATS_HITS] == 1 ? "HIT" : "HITS", iStats[STATS_DAMAGE],  id, 
					iStats[STATS_DAMAGE] == 1 ? "DAMAGE" : "DAMAGES", g_szWpn, distance(g_iKilled[id][Distance]), iStats[STATS_HS] ? szHS : "")
					add(g_szHudBuffer[1], charsmax(g_szHudBuffer[]), szFormat)
				}
			}
			else
			{
				formatex(szFormat, charsmax(szFormat), "%s -- %d %L / %d %L^n", g_szName, iStats[STATS_HITS], id, iStats[STATS_HITS] == 1 ? "HIT" : "HITS", iStats[STATS_DAMAGE], id, iStats[STATS_DAMAGE] == 1 ? "DAMAGE" : "DAMAGES")
				add(g_szHudBuffer[1], charsmax(g_szHudBuffer[]), szFormat)
			}
		}
	}
	
	if(!iFound)
	{
		g_szHudBuffer[1][0] = 0
	}
	
	return iFound
}

format_victims(id)
{
	new iStats[8], iBody[8], szFormat[512]
	new iFound = 0
	iStats[STATS_SHOTS] = 0
	g_szHudBuffer[2][0] = 0
	
	get_user_vstats(id, 0, iStats, iBody)
	
	if(iStats[STATS_SHOTS])
	{
		formatex(g_szHudBuffer[2], charsmax(g_szHudBuffer[]), "%L -- %0.2f%% Acc.:^n", id, "VICTIMS", acc(iStats))
	}
	else
	{
		formatex(g_szHudBuffer[2], charsmax(g_szHudBuffer[]), "%L:^n", id, "VICTIMS")
	}
	
	for(new iVictim = 1; iVictim <= get_maxplayers(); iVictim++)
	{
		if(get_user_vstats(id, iVictim, iStats, iBody, g_szWpn, charsmax(g_szWpn)))
		{
			iFound = 1
			get_user_name(iVictim, g_szName, charsmax(g_szName))
			
			if(iStats[STATS_DEATHS])
			{
				if(!ShowDistHS)
				{
					formatex(szFormat, charsmax(szFormat), "%s -- %d %L / %d %L / %s^n", g_szName, iStats[STATS_HITS], id, iStats[STATS_HITS] == 1 ? "HIT" : "HITS", iStats[STATS_DAMAGE], id,
					iStats[STATS_DAMAGE] == 1 ? "DAMAGE" : "DAMAGES", g_szWpn)
					add(g_szHudBuffer[2], charsmax(g_szHudBuffer[]), szFormat)
				}
				else
				{
					new szHS[16]
					formatex(szHS, charsmax(szHS), "/ %L", id, "HS")
					formatex(szFormat, charsmax(szFormat), "%s -- %d %L / %d %L / %s / %0.2fm %s^n", g_szName, iStats[STATS_HITS], id, iStats[STATS_HITS] == 1 ? "HIT" : "HITS", iStats[STATS_DAMAGE], id, 
					iStats[STATS_DAMAGE] == 1 ? "DAMAGE" : "DAMAGES", g_szWpn, distance(g_iKilled[iVictim][Distance]), iStats[STATS_HS] ? szHS : "")
					add(g_szHudBuffer[2], charsmax(g_szHudBuffer[]), szFormat)
				}
			}
			else
			{
				formatex(szFormat, charsmax(szFormat), "%s -- %d %L / %d %L^n", g_szName, iStats[STATS_HITS], id, iStats[STATS_HITS] == 1 ? "HIT" : "HITS", iStats[STATS_DAMAGE], id, iStats[STATS_DAMAGE] == 1 ? "DAMAGE" : "DAMAGES")
				add(g_szHudBuffer[2], charsmax(g_szHudBuffer[]), szFormat)
			}
		}
	}
	
	if(!iFound)
	{
		g_szHudBuffer[2][0] = 0
	}
	
	return iFound
}	

format_killer(id)
{	
	g_szHudBuffer[3][0] = 0
	new iFound = 0
	new iKiller = g_iKilled[id][Id]
	
	if(iKiller && iKiller != id)
	{
		new iStatsA[8], iBodyA[8], iStatsV[8], iBodyV[8], szFormat[512]

		iFound = 1
		iStatsA[STATS_HITS] = 0
		iStatsA[STATS_DAMAGE] = 0
		get_user_astats(id, iKiller, iStatsA, iBodyA, g_szWpn, charsmax(g_szWpn))

		iStatsV[STATS_HITS] = 0
		iStatsV[STATS_DAMAGE] = 0
		get_user_vstats(id, iKiller, iStatsV, iBodyV)
		
		formatex(g_szHudBuffer[3], charsmax(g_szHudBuffer[]), "%L^n", id, "KILLED_WITH", g_iKilled[id][Name], g_szWpn, distance(g_iKilled[id][Distance]))
		formatex(szFormat, charsmax(szFormat), "%L^n", id, "KILLED_DAMAGE", iStatsA[STATS_DAMAGE], id, iStatsA[STATS_DAMAGE] == 1 ? "DAMAGE" : "DAMAGES", iStatsA[STATS_HITS], id, iStatsA[STATS_HITS] == 1 ? "HIT" : "HITS",
		g_iKilled[id][Hp], g_iKilled[id][Ap])
		add(g_szHudBuffer[3], charsmax(g_szHudBuffer[]), szFormat)
		
		if(iStatsV[STATS_HITS])
		{
			formatex(szFormat, charsmax(szFormat), "%L^n", id, "KILLED_YOU_HITS", iStatsV[STATS_DAMAGE], id, iStatsV[STATS_DAMAGE] == 1 ? "DAMAGE" : "DAMAGES", iStatsV[STATS_HITS], id, iStatsV[STATS_HITS] == 1 ? "HIT" : "HITS")
		}
		else
		{
			formatex(szFormat, charsmax(szFormat), "%L^n", id, "KILLED_YOU_NOHITS")
		}
		
		add(g_szHudBuffer[3], charsmax(g_szHudBuffer[]), szFormat)
		
		if(iStatsA[STATS_HITS])
		{
			formatex(szFormat, charsmax(szFormat), "%L", id, "KILLED_HIT", g_iKilled[id][Name])
			add(g_szHudBuffer[3], charsmax(g_szHudBuffer[]), szFormat)
			
			for (new i = 1; i < 8; i++)
			{
				if(!iBodyA[i])
				{
					continue
				}
	
				formatex(szFormat, charsmax(szFormat), "^n%L: %d^n", id, BODY_PART[i], iBodyA[i])
				add(g_szHudBuffer[3], charsmax(g_szHudBuffer[]), szFormat)
			}
		}
		
		if(equal(g_szHudBuffer[3][strlen(g_szHudBuffer[3])-1], ":"))
		{
			formatex(szFormat, charsmax(szFormat), "^n%L", id, "KILLED_NO_HITS")
			add(g_szHudBuffer[3], charsmax(g_szHudBuffer[]), szFormat)
		}
	}
	
	if(!iFound)
	{
		g_szHudBuffer[3][0] = 0
	}
	
	return iFound
}

public taskSpecInfo()
{
	if(!SpecRankInfo)
	{
		remove_task(TASK_SPEC)
	}
	
	new iPlayers[32], iPNum
	get_players(iPlayers, iPNum)
	
	for(new id, iSpec, i; i < iPNum; i++)
	{
		iSpec = iPlayers[i]
		id = pev(iSpec, pev_iuser2)
		
		if(is_user_alive(id) && !is_user_alive(iSpec))
		{
			new iStats[8], iBody[8], szName[32]
			get_user_name(id, szName, charsmax(szName))
			
			new eHud[HudSettings]
			ArrayGetArray(g_aHud, 5, eHud)
			
			if(eHud[Color][0] == 256 || eHud[Color][1] == 256 || eHud[Color][2] == 256)
			{
				set_hudmessage(random(256), random(256), random(256), eHud[Position][0], eHud[Position][1], 0, 0.1, 1.0, 0.1, 0.1, -1)
			}
			else
			{
				set_hudmessage(eHud[Color][0], eHud[Color][1], eHud[Color][2], eHud[Position][0], eHud[Position][1], 0, 0.1, 1.0, 0.1, 0.1, -1)
			}
			
			ShowSyncHudMsg(iSpec, g_iSpecRank, "%L", LANG_PLAYER, "PLAYER_RANK_IS", szName, get_user_stats(id, iStats, iBody), get_statsnum())
		}
	}
}

public cmdInfoRank(id)
{
	if(g_iInfoRank[id]) g_iInfoRank[id] = 0
	else g_iInfoRank[id] = 1
	
	new szText[32]
	num_to_str(g_iInfoRank[id], szText, charsmax(szText))
	client_cmd(id, "setinfo _inforank %s", szText)
	
	CromChat(id, "%L", id, "INFO_RANK", id, g_iInfoRank[id] ? "ENABLED" : "DISABLED")
}

public cmdShowHS(id)
{
	if(!SayHS)
	{
		disabled_msg(id)
		return PLUGIN_HANDLED
	}
	
	CromChat(id, "%L", id, "MAP_HEADSHOTS", g_iKills[id][HS_KILLS], hsperc2(id), "%%", id, g_iKills[id][HS_KILLS] == 1 ? "HEADSHOT" : "HEADSHOTS", g_iKills[id][ALL_KILLS], id, g_iKills[id][ALL_KILLS] == 1 ? "KILL" : "KILLS")
	
	return PLUGIN_CONTINUE
}

public cmdShowKV(id)
{
	if(!SayKnife)
	{
		disabled_msg(id)
		return PLUGIN_HANDLED
	}
	
	CromChat(id, "%L", id, "MAP_KNIVES", g_iKills[id][KNIFE_KILLS], kvperc(id), "%%", id, g_iKills[id][KNIFE_KILLS] == 1 ? "KILL" : "KILLS", g_iKills[id][ALL_KILLS], id, g_iKills[id][ALL_KILLS] == 1 ? "KILL" : "KILLS")
	
	return PLUGIN_CONTINUE
}

public cmdShowGD(id)
{
	if(!SayGrenade)
	{
		disabled_msg(id)
		return PLUGIN_HANDLED
	}
	
	CromChat(id, "%L", id, "MAP_GRENADES", g_iKills[id][GRENADE_KILLS], gdperc(id), "%%", id, g_iKills[id][GRENADE_KILLS] == 1 ? "KILL" : "KILLS", g_iKills[id][ALL_KILLS], id, g_iKills[id][ALL_KILLS] == 1 ? "KILL" : "KILLS")
	
	return PLUGIN_CONTINUE
}

public cmdTop(id)
{
	new szArgs[192]
	read_args(szArgs, charsmax(szArgs))
	remove_quotes(szArgs)
	
	if(equal(szArgs[0], "/top", 4))
	{
		g_iTopNum = str_to_num(szArgs[4])
		cmdTopX(id)
	}
	
	return PLUGIN_CONTINUE
}

public cmdTopX(id)
{
	if(!SayTop15)
	{
		disabled_msg(id)
		return PLUGIN_HANDLED
	}
	
	if(g_iTopNum < 1 || g_iTopNum > 15)
	{
		return PLUGIN_HANDLED
	}
	
	new szTopX[12]
	formatex(szTopX, charsmax(szTopX), "%L", id, "TOP_X", g_iTopNum)
	get_top_format(id)
	show_motd(id, g_szBuffer, szTopX)
	
	return PLUGIN_CONTINUE
}

public cmdMapTop(id)
{
	if(!SayMapTop)
	{
		disabled_msg(id)
		return PLUGIN_HANDLED
	}
	
	new iMapNum = get_pcvar_num(cvar_maptop_num)
	
	if(iMapNum < 1 || iMapNum > 15)
	{
		return PLUGIN_HANDLED
	}
	
	get_maptop_format(id)
	show_motd(id, g_szBuffer, g_szTopX)
	return PLUGIN_CONTINUE
}

public cmdRankStats(id)
{
	if(!SayRankStats)
	{
		disabled_msg(id)
		return PLUGIN_HANDLED
	}
	
	new szRankStats[32]
	formatex(szRankStats, charsmax(szRankStats), "%L", id, "RANKSTATS")
	get_rankstats_format(id, 1)
	show_motd(id, g_szBuffer, szRankStats)
	
	return PLUGIN_CONTINUE
}	

public cmdStatsMe(id)
{
	if(!SayStatsMe)
	{
		disabled_msg(id)
		return PLUGIN_HANDLED
	}
	
	new szStats[32]
	formatex(szStats, charsmax(szStats), "%L", id, "STATSME")
	get_stats_format(id)
	show_motd(id, g_szBuffer, szStats)
	
	return PLUGIN_CONTINUE
}

public cmdStats(id)
{
	if(!SayStatsAll)
	{
		disabled_msg(id)
		return PLUGIN_HANDLED
	}
	
	new iMenu = menu_create("Stats Menu", "handlerStats")
	
	new iPlayers[32], iPNum
	get_players(iPlayers, iPNum)
	
	new szText[64], szKey[5]
	formatex(szText, charsmax(szText), "\r[%L]", id, g_blStats ? "STATS" : "RANKSTATS")
	
	menu_additem(iMenu, szText, "1")
	menu_addblank(iMenu, 0)
	
	for(new plr, i; i < iPNum; i++)
	{
		plr = iPlayers[i]
		num_to_str(plr, szKey, charsmax(szKey))
		get_user_name(plr, g_szName, charsmax(g_szName))
		menu_additem(iMenu, g_szName, szKey)
	}
	
	menu_display(id, iMenu)
	return PLUGIN_HANDLED
}

public handlerStats(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenu)
		return PLUGIN_HANDLED
	}
	
	new szData[20], iAccess, iCallback
	menu_item_getinfo(iMenu, iItem, iAccess, szData, charsmax(szData), .callback = iCallback)
	
	new iPlayer = str_to_num(szData)
	
	if(iItem == 0)
	{
		if(g_blStats) g_blStats = false
		else g_blStats = true
	}
	else
	{
		new szName[32], szFormat[64]
		get_user_name(iPlayer, szName, charsmax(szName))
		
		if(!g_blStats)
		{
			get_rankstats_format(iPlayer, 0)
			formatex(szFormat, charsmax(szFormat), "%L ^"%s^"", id, "RANKSTATS", szName)
			show_motd(id, g_szBuffer, szFormat)
		}
		else
		{
			get_stats_format(iPlayer)
			formatex(szFormat, charsmax(szFormat), "%L ^"%s^"", id, "STATS", szName)
			show_motd(id, g_szBuffer, szFormat)
		}
	}
	
	cmdStats(id)
	menu_destroy(iMenu)
	return PLUGIN_HANDLED
}

public cmdHP(id)
{
	if(!SayHP)
	{
		disabled_msg(id)
		return PLUGIN_HANDLED
	}
	
	get_killer(id)
	return PLUGIN_CONTINUE
}

get_killer(id)
{
	new iFound = 0
	
	if(g_iKilled[id][Id] && g_iKilled[id][Id] != id)
	{
		new iStats[8], iBody[8], szFormat[64]
		iFound = 1
		iStats[STATS_HITS] = 0
		get_user_astats(id, g_iKilled[id][Id], iStats, iBody, g_szWpn, charsmax(g_szWpn))
		
		formatex(g_szBuffer, charsmax(g_szBuffer), "%L", id, "KILLED_BY", g_iKilled[id][Name], g_szWpn, distance(g_iKilled[id][Distance]),
		g_iKilled[id][Hp], g_iKilled[id][Ap])
		
		if(iStats[STATS_HITS])
		{
			for(new i = 1; i < 8; i++)
			{
				if(!iBody[i])
				{
					continue
				}
				
				formatex(szFormat, charsmax(szFormat), " %L", id, "BODY", id, BODY_PART[i], iBody[i])
				add(g_szBuffer, charsmax(g_szBuffer), szFormat)
			}
		}
		
		if(equal(g_szBuffer[strlen(g_szBuffer)-1], ">"))
		{
			formatex(szFormat, charsmax(szFormat), " %L", id, "NO_HITS")
			add(g_szBuffer, charsmax(g_szBuffer), szFormat)
		}
	}
	else
	{
		formatex(g_szBuffer, charsmax(g_szBuffer), "%L", id, "NO_ONE")
	}
	
	CromChat(id, g_szBuffer)
	return iFound
}

public cmdMe(id)
{
	if(!SayMe)
	{
		disabled_msg(id)
		return PLUGIN_HANDLED
	}
	
	get_victim(id, 0)
	return PLUGIN_CONTINUE
}

get_victim(id, iKiller)
{
	new iStats[8], iBody[8], szFormat[64]
	new iFound = 0
	iStats[STATS_HITS] = 0
	iStats[STATS_DAMAGE] = 0
	get_user_vstats(id, iKiller, iStats, iBody)
	
	if(!iStats[STATS_HITS])
	{
		CromChat(id, "%L", id, "NO_DAMAGE")
		return iFound
	}
	
	if(iKiller && iKiller != id)
	{
		iFound = 1
		formatex(g_szBuffer, charsmax(g_szBuffer), "%L", id, "YOU_HIT", iStats[STATS_DAMAGE], id, iStats[STATS_DAMAGE] == 1 ? "DAMAGE" : "DAMAGES", iStats[STATS_HITS], id, iStats[STATS_HITS] == 1 ? "HIT" : "HITS")		
	}
	else
	{
		formatex(g_szBuffer, charsmax(g_szBuffer), "%L", id, "TOTAL_HITS", iStats[STATS_HITS], iStats[STATS_DAMAGE], id, iStats[STATS_DAMAGE] == 1 ? "DAMAGE" : "DAMAGES")
	}
	
	if(iStats[STATS_HITS])
	{
		for(new i = 1; i < 8; i++)
		{
			if(!iBody[i])
			{
				continue
			}
				
			formatex(szFormat, charsmax(szFormat), " %L", id, "BODY", id, BODY_PART[i], iBody[i])
			add(g_szBuffer, charsmax(g_szBuffer), szFormat)
		}
	}
	
	if(equal(g_szBuffer[strlen(g_szBuffer)-1], ">"))
	{
		formatex(szFormat, charsmax(szFormat), " %L", id, "NO_HITS")
		add(g_szBuffer, charsmax(g_szBuffer), szFormat)
	}
	
	CromChat(id, g_szBuffer)
	return iFound
}

public cmdScore(id)
{
	if(!SayScore)
	{
		disabled_msg(id)
		return PLUGIN_HANDLED
	}
	
	CromChat(id, "%L", id, "GAME_SCORE", g_iTeamScore[1], eff(g_iGameStats[1]), "%%", acc(g_iGameStats[1]), "%%", g_iTeamScore[2], eff(g_iGameStats[2]),  "%%", acc(g_iGameStats[2]), "%%")
	
	return PLUGIN_CONTINUE
}	

public cmdRank(id)
{
	if(!SayRank)
	{
		disabled_msg(id)
		return PLUGIN_HANDLED
	}
	
	new iStats[8], iBody[8]
	get_user_stats(id, iStats, iBody)
	CromChat(id, "%L", id, "YOUR_RANK_IS", get_user_stats(id, iStats, iBody), get_statsnum(), iStats[STATS_KILLS], id, iStats[STATS_KILLS] == 1 ? "KILL" : "KILLS", iStats[STATS_HITS], id,
	iStats[STATS_HITS] == 1 ? "HIT" : "HITS", eff(iStats), "%%", acc(iStats), "%%")
	
	return PLUGIN_CONTINUE
}	

public cmdReport(id)
{
	if(!SayReport)
	{
		disabled_msg(id)
		return PLUGIN_HANDLED
	}
	
	if(!is_user_alive(id))
	{
		return PLUGIN_HANDLED
	}
	
	new iClip, iAmmo
	xmod_get_wpnname(get_user_weapon(id, iClip, iAmmo), g_szWpn, charsmax(g_szWpn))
	
	new iHealth = get_user_health(id)
	new iArmor = get_user_armor(id)
	
	if(iClip >=0)
	{
		formatex(g_szBuffer, charsmax(g_szBuffer), "%L", id, "REPORT", g_szWpn, iClip, iAmmo, iHealth, iArmor)
	}
	else
	{
		formatex(g_szBuffer, charsmax(g_szBuffer), "%L", id, "REPORT_NOAMMO", g_szWpn, iHealth, iArmor)
	}
	
	engclient_cmd(id, "say_team", g_szBuffer)
	return PLUGIN_CONTINUE
}
	
public cmdSwitch(id)
{
	if(g_iSwitch[id]) g_iSwitch[id] = 0
	else g_iSwitch[id] = 1
	
	new szText[32]
	num_to_str(g_iSwitch[id], szText, charsmax(szText))
	client_cmd(id, "setinfo _amxstatsx %s", szText)
	
	CromChat(id, "%L", id, "SWITCH", id, g_iSwitch[id] ? "ENABLED" : "DISABLED")
}

get_top_format(id)
{
	new iStats[8], iStats2[4], iBody[8], szTable[256]
	new iMax = get_statsnum()
	new iCvarType = get_pcvar_num(cvar_topx_type)
	
	formatex(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_STYLE)
	add(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_OPENING_TOPX)
	
	new szFormat[256], szStats[5][16]
	formatex(szStats[0], charsmax(szStats[]), "%L", id, "KILLS")
	formatex(szStats[1], charsmax(szStats[]), "%L", id, "SHOTS")
	formatex(szStats[2], charsmax(szStats[]), "%L", id, "HITS")
	formatex(szStats[3], charsmax(szStats[]), "%L", id, "DAMAGE")
	formatex(szStats[4], charsmax(szStats[]), "%L", id, "HEADSHOTS")
	
	for(new i; i < 5; i++)
	{
		ucfirst(szStats[i])
	}
	
	switch(iCvarType)
	{
		case 0:
		{
			formatex(szFormat, charsmax(szFormat), STATSX_MOTD_HEADER_DEFAULT, id, "NAME", szStats[0], id, "DEATHS", szStats[3], szStats[1], szStats[2], szStats[4], id, "PERCENTAGE_HS", id, "C4_PLANTED", id, "C4_DEFUSED")
			add(g_szBuffer, charsmax(g_szBuffer), szFormat)
		}
		case 1: 
		{
			formatex(szFormat, charsmax(szFormat), STATSX_MOTD_HEADER_NO_C4, id, "NAME", szStats[0], id, "DEATHS", szStats[3], szStats[1], szStats[2], szStats[4], id, "PERCENTAGE_HS")
			add(g_szBuffer, charsmax(g_szBuffer), szFormat)
		}
		case 2:
		{
			formatex(szFormat, charsmax(szFormat), STATSX_MOTD_HEADER_CLASSIC, id, "NAME", szStats[0], id, "DEATHS", szStats[2], szStats[1], szStats[4], id, "EFF", id, "ACC")
			add(g_szBuffer, charsmax(g_szBuffer), szFormat)
		}
	}
	
	if(iMax > g_iTopNum) iMax = g_iTopNum
	
	for(new bool:blTable, i; i < iMax; i++)
	{
		if(iCvarType == 0)
		{
			get_stats(i, iStats, iBody, g_szName2, charsmax(g_szName2))
		}
		else
		{
			get_stats(i, iStats, iBody, g_szName, charsmax(g_szName))
		}
		
		get_stats2(i, iStats2)
		replace_all(g_szName, charsmax(g_szName), "<", "[")
		replace_all(g_szName, charsmax(g_szName), ">", "]")
		replace_all(g_szName2, charsmax(g_szName2), "<", "[")
		replace_all(g_szName2, charsmax(g_szName2), ">", "]")
		
		if(blTable)
		{
			blTable = false
			
			switch(iCvarType)
			{
				case 0:
				{
					formatex(szTable, charsmax(szTable), STATSX_MOTD_TABLE_DEFAULT2, i + 1, g_szName2, iStats[STATS_KILLS], iStats[STATS_DEATHS], iStats[STATS_DAMAGE], iStats[STATS_SHOTS], iStats[STATS_HITS], iStats[STATS_HS],
					hsperc(iStats), iStats2[STATS_PLANTED], iStats2[STATS_DEFUSED])
				}
				case 1:
				{
					formatex(szTable, charsmax(szTable), STATSX_MOTD_TABLE_NO_C42, i + 1, g_szName, iStats[STATS_KILLS], iStats[STATS_DEATHS], iStats[STATS_DAMAGE], iStats[STATS_SHOTS], iStats[STATS_HITS], iStats[STATS_HS],
					hsperc(iStats))
				}
				case 2:
				{
					formatex(szTable, charsmax(szTable), STATSX_MOTD_TABLE_CLASSIC2, i + 1, g_szName, iStats[STATS_KILLS], iStats[STATS_DEATHS], iStats[STATS_HITS], iStats[STATS_SHOTS], iStats[STATS_HS], eff(iStats), acc(iStats))
				}
			}
		}
		else
		{
			blTable = true
				
			switch(iCvarType)
			{
				case 0:
				{
					formatex(szTable, charsmax(szTable), STATSX_MOTD_TABLE_DEFAULT1, i + 1, g_szName2, iStats[STATS_KILLS], iStats[STATS_DEATHS], iStats[STATS_DAMAGE], iStats[STATS_SHOTS], iStats[STATS_HITS], iStats[STATS_HS],
					hsperc(iStats), iStats2[STATS_PLANTED], iStats2[STATS_DEFUSED])
				}
				case 1:
				{
					formatex(szTable, charsmax(szTable), STATSX_MOTD_TABLE_NO_C41, i + 1, g_szName, iStats[STATS_KILLS], iStats[STATS_DEATHS], iStats[STATS_DAMAGE], iStats[STATS_SHOTS], iStats[STATS_HITS], iStats[STATS_HS],
					hsperc(iStats))
				}
				case 2:
				{
					formatex(szTable, charsmax(szTable), STATSX_MOTD_TABLE_CLASSIC1, i + 1, g_szName, iStats[STATS_KILLS], iStats[STATS_DEATHS], iStats[STATS_HITS], iStats[STATS_SHOTS], iStats[STATS_HS], eff(iStats), acc(iStats))
				}
			}
		}
		
		add(g_szBuffer, charsmax(g_szBuffer), szTable)
	}
}

get_maptop_format(id)
{
	new szStats[2][16]
	formatex(szStats[0], charsmax(szStats[]), "%L", id, "KILLS")
	formatex(szStats[1], charsmax(szStats[]), "%L", id, "HEADSHOTS")
	
	for(new i; i < 2; i++)
	{
		ucfirst(szStats[i])
	}
	
	new szFormat[512]
	formatex(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_STYLE)
	add(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_OPENING_TOPX)
	formatex(szFormat, charsmax(szFormat), STATSX_MOTD_HEADER_MAPTOP, id, "NAME", szStats[0], szStats[1], id, "PERCENTAGE_HS", id, "KNIVES", id, "PERCENTAGE_KV", id, "GRENADES", id, "PERCENTAGE_GD") 
	add(g_szBuffer, charsmax(g_szBuffer), szFormat)
	
	new iPlayers[32], iPNum
	get_players(iPlayers, iPNum)
	SortCustom1D(iPlayers, iPNum, "funcSorting")
	
	for(new bool:blTable, iMapNum, plr, i; i < iPNum; i++)
	{
		g_szTopX[0] = 0
		plr = iPlayers[i]
		iMapNum = get_pcvar_num(cvar_maptop_num)
		get_user_name(plr, g_szName, charsmax(g_szName))
		
		if(iPNum > iMapNum) iPNum = iMapNum
		
		if(blTable)
		{
			blTable = false
			formatex(szFormat, charsmax(szFormat), STATSX_MOTD_TABLE_MAPTOP2, i + 1, g_szName, g_iKills[plr][ALL_KILLS], g_iKills[plr][HS_KILLS], hsperc2(plr), g_iKills[plr][KNIFE_KILLS], kvperc(plr),
			g_iKills[plr][GRENADE_KILLS], gdperc(plr))
		}
		else
		{
			blTable = true
			formatex(szFormat, charsmax(szFormat), STATSX_MOTD_TABLE_MAPTOP1, i + 1, g_szName, g_iKills[plr][ALL_KILLS], g_iKills[plr][HS_KILLS], hsperc2(plr), g_iKills[plr][KNIFE_KILLS], kvperc(plr),
			g_iKills[plr][GRENADE_KILLS], gdperc(plr))
		}
		
		add(g_szBuffer, charsmax(g_szBuffer), szFormat)
		formatex(g_szTopX, charsmax(g_szTopX), "%L", id, "MAPTOP_X", i + 1)
	}
}

get_rankstats_format(id, own = 0)
{
	new szFormat[512], iStats[8], iBody[8], szStats[4][16]
	get_user_stats(id, iStats, iBody)

	formatex(szStats[0], charsmax(szStats[]), "%L", id, "KILLS")
	formatex(szStats[1], charsmax(szStats[]), "%L", id, "SHOTS")
	formatex(szStats[2], charsmax(szStats[]), "%L", id, "HITS")
	formatex(szStats[3], charsmax(szStats[]), "%L", id, "DAMAGE")
	
	for(new i; i < 4; i++)
	{
		ucfirst(szStats[i])
	}
	
	formatex(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_STYLE)
	
	add(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_OPENING_RANKSTATS)
	formatex(szFormat, charsmax(szFormat), STATSX_MOTD_RANKSTATS1, id, "STATS", szStats[0], iStats[STATS_KILLS], id, "WITH", iStats[STATS_HS], id, "HS", id, "DEATHS", iStats[STATS_DEATHS], szStats[2], 
	iStats[STATS_HITS], szStats[1], iStats[STATS_SHOTS], szStats[3], iStats[STATS_DAMAGE], id, "EFF", eff(iStats), id, "ACC", acc(iStats))
	add(g_szBuffer, charsmax(g_szBuffer), szFormat)
	add(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_CLOSE)
	
	add(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_OPENING_RANKSTATS)
	
	new szBody[8][32]
	for (new i = 1; i < 8; i++)
	{
		formatex(szBody[i], charsmax(szBody[]), "%L", id, BODY_PART[i])
	}
	
	formatex(szFormat, charsmax(szFormat), STATSX_MOTD_RANKSTATS2, szStats[2], szBody[1], iBody[1], szBody[2], iBody[2], szBody[3], iBody[3], szBody[4], iBody[4], szBody[5], iBody[5], szBody[6], iBody[6], szBody[7], iBody[7])
	add(g_szBuffer, charsmax(g_szBuffer), szFormat)
	add(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_CLOSE)

	if(own)
	{
		formatex(szFormat, charsmax(szFormat), STATSX_MOTD_RANKSTATS3, id, "YOUR_RANK", get_user_stats(id, iStats, iBody), get_statsnum())
	}
	else
	{
		get_user_name(id, g_szName, charsmax(g_szName))
		formatex(szFormat, charsmax(szFormat), STATSX_MOTD_RANKSTATS3, id, "PLAYER_RANK_IS", g_szName, get_user_stats(id, iStats, iBody), get_statsnum())
	}
	
	add(g_szBuffer, charsmax(g_szBuffer), szFormat)
	add(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_CLOSE)
}

get_stats_format(id)
{
	new szPrefix[32]
	
	#if defined USE_CRX_PREFIXES
		g_blPrefix = true
		cm_get_user_prefix(id, szPrefix, charsmax(szPrefix))
	#else
		g_blPrefix = false
	#endif
	
	new szFormat[512], iStats[8], iBody[8], iStats2[4], iStatsS[8], szStats[4][16]
	get_user_wstats(id, 0, iStats, iBody)
	get_user_stats2(id, iStats2)
	get_user_stats(id, iStatsS, iBody)	
	
	formatex(szStats[0], charsmax(szStats[]), "%L", id, "KILLS")
	formatex(szStats[1], charsmax(szStats[]), "%L", id, "SHOTS")
	formatex(szStats[2], charsmax(szStats[]), "%L", id, "HITS")
	formatex(szStats[3], charsmax(szStats[]), "%L", id, "DAMAGE")
	
	for(new i; i < 4; i++)
	{
		ucfirst(szStats[i])
	}
	
	formatex(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_STYLE)
	
	add(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_OPENING_STATS)
	formatex(szFormat, charsmax(szFormat), STATSX_MOTD_STATS1, id, "STATS", szStats[0], iStats[STATS_KILLS], id, "WITH", iStats[STATS_HS], id, "HS", id, "DEATHS", iStats[STATS_DEATHS], szStats[2], iStats[STATS_HITS],
	szStats[1], iStats[STATS_SHOTS], szStats[3], iStats[STATS_DAMAGE], id, "EFF", eff(iStats), id, "ACC", acc(iStats))
	add(g_szBuffer, charsmax(g_szBuffer), szFormat)
	add(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_CLOSE)
	
	add(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_OPENING_STATS)
	
	new iPtime = ((g_iTotalPlayedTime[id] + get_user_time(id, 1))/60)%60
	new iPtime2 = ((g_iTotalPlayedTime[id] + get_user_time(id, 1))/3600)%24
	new iPtime3 = (g_iTotalPlayedTime[id] + get_user_time(id, 1))/86400
	
	formatex(szFormat, charsmax(szFormat), STATSX_MOTD_STATS2, id, "PLAYER_STATS", id, "PLAYED_TIME", iPtime3, id, "DAYS", iPtime2, id, "HOURS", iPtime, id, "MINUTES", id, "C4_PLANTED", iStats2[STATS_PLANTED], id, "C4_DEFUSED",
	iStats2[STATS_DEFUSED], id, "C4_EXPLODED", iStats2[STATS_EXPLODED], id, "ROLE", g_blPrefix ? szPrefix : DEFAULT_ROLE_NAME, id, "SKILL", ((eff(iStatsS) + acc(iStatsS)) / 2), ((eff(iStatsS) + acc(iStatsS)) / 2), 
	id, "LAST_ACTIVITY", g_szTime[id])
	add(g_szBuffer, charsmax(g_szBuffer), szFormat)
	add(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_CLOSE)
	
	add(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_OPENING_WSTATS2)
	formatex(szFormat, charsmax(szFormat), STATSX_MOTD_WSTATS1, id, "WEAPON", szStats[0], id, "DEATHS", szStats[2], szStats[1], szStats[3], id, "ACC")
	add(g_szBuffer, charsmax(g_szBuffer), szFormat)
	add(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_OPENING_WSTATS)
	
	for(new bool:blTable, iWeapon = 1; iWeapon < xmod_get_maxweapons(); iWeapon++)
	{				
		if(get_user_wstats(id, iWeapon, iStats, iBody))
		{
			xmod_get_wpnname(iWeapon, g_szWpn, charsmax(g_szWpn))
			
			if(blTable)
			{
				blTable = false
				formatex(szFormat, charsmax(szFormat), STATSX_MOTD_WSTATS3, g_szWpn, iStats[STATS_KILLS], iStats[STATS_DEATHS], iStats[STATS_HITS], iStats[STATS_SHOTS], iStats[STATS_DAMAGE], acc(iStats))
				add(g_szBuffer, charsmax(g_szBuffer), szFormat)
			}
			else
			{
				blTable = true
				formatex(szFormat, charsmax(szFormat), STATSX_MOTD_WSTATS2, g_szWpn, iStats[STATS_KILLS], iStats[STATS_DEATHS], iStats[STATS_HITS], iStats[STATS_SHOTS], iStats[STATS_DAMAGE], acc(iStats))
				add(g_szBuffer, charsmax(g_szBuffer), szFormat)
			}
		}
	}
	
	add(g_szBuffer, charsmax(g_szBuffer), STATSX_MOTD_CLOSE)
}	

public funcSorting(elem1, elem2)
{
	if((g_iKills[elem1][ALL_KILLS] > g_iKills[elem2][ALL_KILLS]) 
	|| (g_iKills[elem1][ALL_KILLS] == g_iKills[elem2][ALL_KILLS] && g_iKills[elem1][KNIFE_KILLS] > g_iKills[elem2][KNIFE_KILLS]) 
	|| (g_iKills[elem1][ALL_KILLS] == g_iKills[elem2][ALL_KILLS] && g_iKills[elem1][GRENADE_KILLS] > g_iKills[elem2][GRENADE_KILLS])
	|| (g_iKills[elem1][ALL_KILLS] == g_iKills[elem2][ALL_KILLS] && g_iKills[elem1][KNIFE_KILLS] == g_iKills[elem2][KNIFE_KILLS] && g_iKills[elem1][GRENADE_KILLS] > g_iKills[elem2][GRENADE_KILLS]) 
	|| (g_iKills[elem1][ALL_KILLS] == g_iKills[elem2][ALL_KILLS] && g_iKills[elem1][GRENADE_KILLS] == g_iKills[elem2][GRENADE_KILLS] && g_iKills[elem1][KNIFE_KILLS] > g_iKills[elem2][KNIFE_KILLS])
	|| (g_iKills[elem1][ALL_KILLS] == g_iKills[elem2][ALL_KILLS] && g_iKills[elem1][HS_KILLS] > g_iKills[elem2][HS_KILLS]))
	{
		return -1
	}
	else if((g_iKills[elem1][ALL_KILLS] < g_iKills[elem2][ALL_KILLS]) 
	|| (g_iKills[elem1][ALL_KILLS] == g_iKills[elem2][ALL_KILLS] && g_iKills[elem1][KNIFE_KILLS] < g_iKills[elem2][KNIFE_KILLS]) 
	|| (g_iKills[elem1][ALL_KILLS] == g_iKills[elem2][ALL_KILLS] && g_iKills[elem1][GRENADE_KILLS] < g_iKills[elem2][GRENADE_KILLS])
	|| (g_iKills[elem1][ALL_KILLS] == g_iKills[elem2][ALL_KILLS] && g_iKills[elem1][KNIFE_KILLS] == g_iKills[elem2][KNIFE_KILLS] && g_iKills[elem1][GRENADE_KILLS] < g_iKills[elem2][GRENADE_KILLS]) 
	|| (g_iKills[elem1][ALL_KILLS] == g_iKills[elem2][ALL_KILLS] && g_iKills[elem1][GRENADE_KILLS] == g_iKills[elem2][GRENADE_KILLS] && g_iKills[elem1][KNIFE_KILLS] < g_iKills[elem2][KNIFE_KILLS])
	|| (g_iKills[elem1][ALL_KILLS] == g_iKills[elem2][ALL_KILLS] && g_iKills[elem1][HS_KILLS] < g_iKills[elem2][HS_KILLS]))
	{
		return 1
	}
	
	return 0
}

UseVault(id, iType)
{        
	new szAuthID[32], szData[32]
	get_user_authid(id, szAuthID, charsmax(szAuthID))
    
	switch(iType)
	{
		case 0:
		{
			formatex(szData, charsmax(szData), "%s", g_szTime[id])
			nvault_set(g_iVault, szAuthID, szData)
		}
		case 1:
		{
			nvault_get(g_iVault, szAuthID, szData, charsmax(szData))
			nvault_get(g_iVault, szAuthID, g_szTime[id], charsmax(g_szTime[]))
		}
	}
}

UseVault2(id, iType)
{
	new szAuthID[32], szData[32]
	get_user_authid(id, szAuthID, charsmax(szAuthID))
	
	switch(iType)
	{
		case 0:
		{
			formatex(szData, charsmax(szData), "%d", g_iTotalPlayedTime[id] + get_user_time(id))
			nvault_set(g_iVault2, szAuthID, szData)
		}
		case 1: 
		{
			nvault_get(g_iVault2, szAuthID, szData, charsmax(szData))
			g_iTotalPlayedTime[id] = str_to_num(szData)
		}
	}
}	
	
UseVault3(id, iType)
{
	new szAuthID[32], szData[32]
	get_user_authid(id, szAuthID, charsmax(szAuthID))
	
	switch(iType)
	{
		case 0:
		{
			formatex(szData, charsmax(szData), "%d %d %d %d", g_iKills[id][ALL_KILLS], g_iKills[id][HS_KILLS], g_iKills[id][KNIFE_KILLS], g_iKills[id][GRENADE_KILLS])
			nvault_set(g_iVault3, szAuthID, szData)
		}
		case 1: 
		{
			nvault_get(g_iVault3, szAuthID, szData, charsmax(szData))
			
			new szArg[4][12]
			parse(szData, szArg[0], charsmax(szArg[]), szArg[1], charsmax(szArg[]), szArg[2], charsmax(szArg[]), szArg[3], charsmax(szArg[]))
			g_iKills[id][ALL_KILLS] = str_to_num(szArg[0])
			g_iKills[id][HS_KILLS] = str_to_num(szArg[1])
			g_iKills[id][KNIFE_KILLS] = str_to_num(szArg[2])
			g_iKills[id][GRENADE_KILLS] = str_to_num(szArg[3])
		}
	}
}

disabled_msg(id)
{
	CromChat(id, "%L", id, "OPTION_DISABLED")
}

Float:distance(iDistance)
{
	return float(iDistance) * 0.0254
}
	
Float:kvperc(id)
{
	return (100.0 * float(g_iKills[id][KNIFE_KILLS]) / float(g_iKills[id][ALL_KILLS]))
}

Float:gdperc(id)
{
	return (100.0 * float(g_iKills[id][GRENADE_KILLS]) / float(g_iKills[id][ALL_KILLS]))
}

Float:hsperc2(id)
{
	return (100.0 * float(g_iKills[id][HS_KILLS]) / float(g_iKills[id][ALL_KILLS]))
}

Float:hsperc(iStats[8])
{
	return (100.0 * float(iStats[STATS_HS]) / float(iStats[STATS_KILLS]))
}

Float:acc(iStats[8])
{
	return (100.0 * float(iStats[STATS_HITS]) / float(iStats[STATS_SHOTS]))
}

Float:eff(iStats[8])
{
	return (100.0 * float(iStats[STATS_KILLS]) / float(iStats[STATS_KILLS] + iStats[STATS_DEATHS]))
}
