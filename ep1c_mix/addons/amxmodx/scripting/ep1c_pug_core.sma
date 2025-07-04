#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <regex>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <cromchat>
#include <nvault>
#include <time>
#include <reapi>

#define PLUGIN	"ep1c: Pug mix"
#define VERSION	"1.2"
#define AUTHOR	"EFFx / IceeedR / alex rafael / lonewolf"

#define FOLDER	"pug_perfect"

#define MIN_AFK_TIME 		20
#define WARNING_TIME 		10
#define WARNING_TIME 		10
#define CHECK_FREQ 		5
#define SELECTMAPS		10						
#define MAX_MAPS 		100
#define BLOCK_MAPS		10
#define FILE_BLOCKEDMAPS 	"addons/amxmodx/data/mm_last.ini"
#define MAX_NOMINATE		3
#define MAX_USER_NOMINATE	2
#define	SLOT_PRIMARY		1
#define	SLOT_SECONDARY		2
#define	SLOT_C4			5
#define LOGEVENTS		"pug_eventos.log"
#define LOGFILE			"pug_restart.log"
#define WARNMAPS		"pug_mapchooser.log"
#define BANLEAVER		"pug_leaver.log"
#define isPlayer(%0)		(1 <= %0 <= gMaxPlayers)
#define isTeam(%0) 		(CS_TEAM_T <= cs_get_user_team(%0) <= CS_TEAM_CT)
#define isAdmin(%1)		(get_user_flags(%1) & ADMIN_CFG)
#define InvalidSound(%1)	client_cmd(%1, "speak buttons/button11")

#define TASK_CHAMAR		1000
#define TASK_PLACAR		3000
#define TASK_CHECKPLAYERS	5000
#define TASK_CONTADOR		6000
#define TASK_CHECKREADY		7000
#define TASK_MIADO		8000
#define TASK_SELECTPLAYERS	9000
#define TASK_SHOWMONEY		10000
#define TASK_HUD_REMOVE 	11000
#define TASK_MESSAGE		12000
#define TASK_votacao		13000

#define PATTERN_IP "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"

#pragma dynamic 32768

new bool:gPrimeiraVez4fun;

new const Pug_TagPrefix_hud[] = "ep1c gaming Brasil" // hud n�o colocar cor so nome padrao  
new const Pug_TagPrefix[] = "^x04[ep1c gaming Brasil]^x01:"
new const Pug_MenuPrefix[] = "Pug Menu"

new g_iCurTeam[MAX_PLAYERS + 1] = {'S', 'T', 'C'}
new CsTeams:g_CurTeam[MAX_PLAYERS + 1]

enum uUserData
{	
	szName[MAX_PLAYERS],
	iKills,
	iHsKills,
	bool:bFirstSpawn,
	bool:bIsReady,
	bool:bSurrender,
	bool:bIsSelected,
	SpecName[MAX_PLAYERS],
	g_iTimeDonated[MAX_PLAYERS]
}

enum bBool
{
	bMD3,
	bReady,
	bPlayerTRSelected,
	bChat,
	bPlayerCTSelected,
	iOvT,
	iLive,
	iFun,
	iKnife,
	iDisabled,
	g_Freezetime,
	iEagle,
	g_Surrender,
	g_SecondTime,
	g_SurrenderOnMap,
	g_KnifeTrWinner,
	g_KnifeCtWinner,
	g_MoneyMaker,
	g_MoneyTrWinner,
	g_SwapFF,
	g_bVoteRunning,
	g_Swapped,
	g_HasMd3,
}

enum iNums
{
	iTempo,
	iCTsPlacar,
	iTRsPlacar,
	iCTsPlacarOT,
	iSwapPlacar,
	iTRsPlacarOT,
	iRRs,
	iRounds,
	iChamarTR,
	iChamarCT,
	iOwnerID,
	iOwnerKnifeiKiller,
	iOwnerKnifeiVictim,
	iOwnerIDHS,
	iCaptainTR,
	iCaptainCT,
	iMiadoCountDown,
	iOverTimeCountDown,
	iBestFragFirstH,
	iBestFragSecH,
	iFirstHalfKill,
	iSecHalfKill
}

enum hHuds
{
	hHudAce,
	hHudHS,
	hHudMK,
	hHudK,
	hTRWins,
	hCTWins,
	hBestFraggers,
	hContador,
	hPlacar,
	hAviso,
	hMapsVote,
	hLiveMessage,
	hVotemapCountdown,
	hVotemapResult,
	hHudCounter,
	hszVotos,
	hszVotacao,
	hHudTRvsCT,
	hszMsgPregame,
	hHudOt,
	hszOTVotacao,
	hszVotosOT,
	hRoundDeagleNames
}

enum vVoteType
{
	vOverTime,
	vMD3,
	vKnife,
	vRT,
	vSurrender,
	vFF
}

new WeaponSlots[] =
{
	0,
	2,	//CSW_P228
	0,
	1,	//CSW_SCOUT
	4,	//CSW_HEGRENADE
	1,	//CSW_XM1014
	5,	//CSW_C4
	1,	//CSW_MAC10
	1,	//CSW_AUG
	4,	//CSW_SMOKEGRENADE
	2,	//CSW_ELITE
	2,	//CSW_FIVESEVEN
	1,	//CSW_UMP45
	1,	//CSW_SG550
	1,	//CSW_GALIL
	1,	//CSW_FAMAS
	2,	//CSW_USP
	2,	//CSW_GLOCK18
	1,	//CSW_AWP
	1,	//CSW_MP5NAVY
	1,	//CSW_M249
	1,	//CSW_M3
	1,	//CSW_M4A1
	1,	//CSW_TMP
	1,	//CSW_G3SG1
	4,	//CSW_FLASHBANG
	2,	//CSW_DEAGLE
	1,	//CSW_SG552
	1,	//CSW_AK47
	3,	//CSW_KNIFE
	1	//CSW_P90
}

new MaxBPAmmo[] =
{
	0,
	52,	//CSW_P228
	0,
	90,	//CSW_SCOUT
	1,	//CSW_HEGRENADE
	32,	//CSW_XM1014
	1,	//CSW_C4
	100,	//CSW_MAC10
	90,	//CSW_AUG
	1,	//CSW_SMOKEGRENADE
	120,	//CSW_ELITE
	100,	//CSW_FIVESEVEN
	100,	//CSW_UMP45
	90,	//CSW_SG550
	90,	//CSW_GALIL
	90,	//CSW_FAMAS
	100,	//CSW_USP
	120,	//CSW_GLOCK18
	30,	//CSW_AWP
	120,	//CSW_MP5NAVY
	200,	//CSW_M249
	32,	//CSW_M3
	90,	//CSW_M4A1
	120,	//CSW_TMP
	90,	//CSW_G3SG1
	2,	//CSW_FLASHBANG
	35,	//CSW_DEAGLE
	90,	//CSW_SG552
	90,	//CSW_AK47
	0,	//CSW_KNIFE
	100	//CSW_P90
}

new bool:g_bPlayerMuted[MAX_PLAYERS +1][MAX_PLAYERS + 1]

new Regex:Result,ReturnValue,Error[64],AllArgs[1024]

new g_mMessageScreenShake, g_mMessageScreenFade, g_mMessageHostName

new g_dUserData[MAX_PLAYERS + 1][uUserData], g_iVote[vVoteType][2], g_iNums[iNums], g_hHuds[hHuds], g_bBooleans[bBool]

new g_iPlayerSteam[MAX_PLAYERS + 1][MAX_PLAYERS + 3]

new Float:g_Time, Float:gametime

new g_sVoteMap[SELECTMAPS+2][MAX_PLAYERS], g_iMapInMenu[SELECTMAPS+1], g_iVoteCount[SELECTMAPS + 2], g_sMap[MAX_MAPS][MAX_PLAYERS], g_iVoteMapNum, g_iMapCount,g_NextMap[MAX_PLAYERS]

new VarMini,VarShowHP,VarSay,VarAfkKick,VarAfkTime, VarFriendly,VarPlr,OverTimeMoney, VarVoteMd3,VarLockReady,VarMoney,VarSpawnDelay,
VarChangeMap,VarHostNamePlacar,VarTagReady, VarminKills, VarReadyTime,VarMiado, VarDescriptionPlacar,VarDeadMic, VarBan, 
VarSelfTK, VarFFVote, VarPunishment, VarLockBombs, VarReset, VarEagleAkc, VarRandomize, VarAdminKick, VarChamados, VarHudMoney, 
VarLeaver, VarBanLive, VarSurrender, VarLockSurrender, VarBestPlayers, VarCountDown, VarDonateMoney,VarAllowVote, VarMaxDonate, VarFreezePlacar, VarDisable, VarDebug, VarLetsGo

new g_iMic, gMsgMoney, g_iMsgMoney, gMaxPlayers, g_iDamage[MAX_PLAYERS + 1][MAX_PLAYERS + 1], g_iHits[MAX_PLAYERS + 1][MAX_PLAYERS + 1]

const m_bitsDamageType = 76

new gOriginalHostName[99], gOldAngles[MAX_PLAYERS + 1][3], gAfkTime[MAX_PLAYERS + 1], gHPKiller[MAX_PLAYERS + 1], Winner[MAX_PLAYERS + 1], Loser[MAX_PLAYERS + 1], StatsVault

new g_iNomMap[MAX_PLAYERS + 1], g_iIdMapNom[MAX_NOMINATE+1], g_iCountNom, g_sNomMap[MAX_NOMINATE+1][MAX_PLAYERS], g_iMapsMenu, 
g_sLastMap[BLOCK_MAPS+1][MAX_PLAYERS], g_iLastMap = 1, g_sCurMap[MAX_PLAYERS]

new const g_szCommandMessage[] = "/mute"
new const g_szDefuseSound[] = "weapons/c4_disarm.wav"
new const g_szKnifeSound[] = "pugiceeedr/facax.wav"
new const g_szMoneySpriteClassName[] =	"pug_moneysprite"
new const g_szAceSounds[][] =
{
	"pugiceeedr/neide.wav",
	"pugiceeedr/neidex.wav",
	"pugiceeedr/neidexx.wav"	
}

enum sSpriteData
{
	szSpriteName[MAX_PLAYERS],
	iSpriteID
}

new const g_szMoneySprites[][sSpriteData] =
{
	{"sprites/cash.spr", 5},
	{"sprites/1.spr", 4},
	{"sprites/10.spr", 3},
	{"sprites/100.spr", 2},
	{"sprites/1000.spr", 1},
	{"sprites/10000.spr", 0}
}

new HamHook:g_iSetModel, g_iUserSprites[MAX_PLAYERS + 1][sizeof g_szMoneySprites]

new donateReceiver[MAX_PLAYERS + 1];


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	/*
	new szServerIP[21]
	get_user_ip(0, szServerIP, charsmax(szServerIP), false)
	if(!equal(szServerIP, "185.50.105.212:27426")) //Adicionar o ip para evitar roubo
	{
		set_fail_state("Pug privado, compre-o (CSBRGames) - 18 99790-7560") // Essa mensagem so aparece se alguem tentar furtar o pug, pe�o que nao alterem porque nao vai ter propagando no seu servidor.
	}
	
	new szMap[4]
	get_mapname(szMap , charsmax(szMap))
	if (!equal(szMap,"de_"))
	{
		static szNameFail[64]
		formatex(szNameFail,63,"[%s]: Este plugin so funciona em mapas de_ !",PLUGIN)
		set_fail_state(szNameFail)
	}
	*/
	register_dictionary("time.txt")
	CC_SetPrefix(Pug_TagPrefix)
	register_logevent("EventEndRnd", 2, "1=Round_End")
	register_event("SendAudio", "EventTRWin","a", "2&%!MRAD_terwin") 
	register_event( "SendAudio", "EventCTWin", "a", "2=%!MRAD_ctwin" );
	register_event("HLTV","EventNewRnd", "a", "1=0", "2=0")
	register_event("CurWeapon","CurWeapon","be","1=1")
	register_event("DeathMsg", "event_deathMsg", "a")
	register_event("BarTime", "event_Defusing", "be", "1=5", "1=10")
	register_event( "TeamInfo", "TeamInfo", "a")
	register_clcmd("nightvision", "PUG_AdminMenu")

	RegisterHam(Ham_TakeDamage, "player", "PlayerDamage")
	RegisterHam(Ham_Spawn, "player", "PlayerSpawn", 1)

	register_menucmd(register_menuid("MapChoose"), (-1^(-1<<(SELECTMAPS+2))), "votemenu_handler")
	register_menucmd(-2,MENU_KEY_1|MENU_KEY_2|MENU_KEY_5|MENU_KEY_6,"PugTeamSelect")
	register_menucmd(register_menuid("Team_Select",1),MENU_KEY_1|MENU_KEY_2|MENU_KEY_5|MENU_KEY_6,"PugTeamSelect")

	g_iMic = register_forward(FM_Voice_SetClientListening, "Forward_SetClientListening")
	new g_TimeOut = get_cvar_pointer("sv_timeout")
	set_pcvar_bounds(g_TimeOut, CvarBound_Upper,true,30.0); // Max
	set_pcvar_bounds(g_TimeOut, CvarBound_Lower,true,25.0); // Min
	g_mMessageScreenShake = get_user_msgid("ScreenShake")
	g_mMessageScreenFade = get_user_msgid("ScreenFade")
	g_mMessageHostName = get_user_msgid("ServerName")

	register_clcmd("say", "Say_Cmmds")
	register_clcmd("say_team", "SayTeam_Hook")
	register_clcmd("jointeam","PugJoinTeam")
	register_clcmd("say","xFilterSayIP")
	register_clcmd("say_team","xFilterSayIP")
	register_clcmd("vote","vote_grab",ADMIN_LEVEL_A," <number>. Vote against a player form your team to kick.") 
	register_clcmd("votekick","vote_grab",ADMIN_LEVEL_A," <number>. Vote to kick.") 
	register_clcmd("voteban","vote_grab",ADMIN_LEVEL_A," <number>. Vote to ban.") 
	register_clcmd("votemap","vote_grab",ADMIN_LEVEL_A," <number>. Vote to change a map.") 
	register_clcmd("VALOR","VALORCmd")
	
	register_forward(FM_GetGameDescription, "GameDesc")
	register_forward(FM_ClientUserInfoChanged, "ClientUserInfoChanged")
	
	VarFriendly = get_cvar_pointer( "mp_friendlyfire")
	
	VarTagReady = register_cvar ("pug_readytag","***")
	VarDescriptionPlacar = register_cvar("pug_descricao_info", "1")
	VarDeadMic = register_cvar("pug_deadmic", "1")
	VarMini = register_cvar("pug_mini","10")
	VarminKills = register_cvar("pug_minkills", "2")
	VarShowHP = register_cvar("pug_showhp","1")
	VarVoteMd3 = register_cvar("pug_md3vote","1")
	VarSay = register_cvar ("pug_nosay","0")
	VarPlr = register_cvar ("pug_plrlmt","5")
	VarAfkKick = register_cvar("pug_afkkick","1")
	VarAfkTime = register_cvar("pug_timeaway","30")
	VarLockReady = register_cvar("pug_lockready","1")
	VarMoney = register_cvar("pug_money","850")
	VarSpawnDelay = register_cvar("pug_spawndelay","0.75")
	VarHostNamePlacar = register_cvar("pug_servername_placar", "1")
	VarBan = register_cvar("pug_bantime", "45")
	VarSelfTK = register_cvar("pug_self_tk", "1")
	VarFFVote = register_cvar("pug_ff_vote", "1")
	VarPunishment = register_cvar("pug_punishment", "ready")
	VarReadyTime = register_cvar("pug_readytime", "20")
	OverTimeMoney = register_cvar("pug_overtime_money", "10000")
	VarMiado = register_cvar("pug_miado_num", "3")
	VarChangeMap = register_cvar("pug_changemap", "4")
	VarLockBombs = register_cvar("pug_blockbombs", "1")
	VarReset = register_cvar("pug_restart", "1")
	VarEagleAkc = register_cvar("pug_onlyeagle", "0")
	VarRandomize = register_cvar("pug_randomize", "1")
	VarAdminKick = register_cvar("pug_admin_kick", "1")
	VarChamados = register_cvar("pug_call_spec", "6")
	VarHudMoney = register_cvar("pug_hud_money", "1")
	VarLeaver = register_cvar ("pug_leaver", "1")
	VarBanLive = register_cvar("pug_ban_live","5")
	VarSurrender = register_cvar("pug_surrender", "3")
	VarLockSurrender = register_cvar("pug_lock_surrender","1")
	VarBestPlayers = register_cvar("pug_bestplayers", "1")
	VarCountDown = register_cvar("pug_count_down", "60")
	VarDonateMoney = register_cvar("pug_donate_money", "1500")
	VarAllowVote = register_cvar("pug_allow_vote", "1")
	VarMaxDonate = register_cvar("pug_max_donate", "2")
	VarFreezePlacar = register_cvar("pug_freeze_placar", "1")
	VarDisable = register_cvar("pug_disable", "1")
	VarDebug = register_cvar("pug_debug", "1")
	VarLetsGo = register_cvar("pug_letsgo", "1")

	register_message(get_user_msgid("SayText"),"PugMsgSayText")
	gMsgMoney = get_user_msgid("Money")
	gMaxPlayers = get_maxplayers()
	g_iSetModel = RegisterHam(Ham_Touch, "weaponbox", "WeaponBox_Touch", 1)
	register_cvar("pug_afkminplayers", "0")
	register_cvar("pug_versao", VERSION, FCVAR_PROTECTED)
	register_cvar("pug_contact","Whats: 061 99188-3344",FCVAR_PROTECTED)
	register_think(g_szMoneySpriteClassName, "sprite_Think")
	g_bBooleans[g_Freezetime] = get_cvar_pointer("mp_freezetime")							   
	for(new i;i < sizeof g_hHuds;i++)
	{
		g_hHuds[hHuds:i] = CreateHudSyncObj()
	}
	
	set_task(20.0,"pub_pregame",.flags = "b") //20
	set_task(3.0, "SetMode", 3)
	set_task(3.0, "hostName")
}

public plugin_cfg()
{
	StatsVault = nvault_open("StatsVault")
	
	if(StatsVault == INVALID_HANDLE)
		set_fail_state("nvault StatsVault falhou ao abrir.")
		
	server_cmd("amx_pausecfg add ^"%s^"",PLUGIN)
	g_iMapsMenu = menu_create("\y[\wPugMod - \rEscolha um mapa: \y]", "mapsmenu_handler")
	get_mapname(g_sCurMap, charsmax(g_sCurMap))
	LoadBlockMaps() 
	LoadMaps()
	
	gametime = get_gametime()
	execCfg(5)
}

public plugin_precache()
{
	precache_model("sprites/gas_puff_01.spr")
	
	for (new i = 0 ; i < sizeof( g_szAceSounds ) ; i++ )
		precache_sound( g_szAceSounds[ i ] )
		
	precache_sound(g_szDefuseSound)
	precache_sound(g_szKnifeSound)
	
	for(new i;i < sizeof g_szMoneySprites;i++)
		precache_model(g_szMoneySprites[sSprites:i][szSpriteName])
}

public WeaponBox_Touch(iEntity) 
{
	if(pev_valid(iEntity))
	{
		set_pev(iEntity, pev_flags, FL_KILLME)
		dllfunc(DLLFunc_Think, iEntity)
	}
}

public event_Defusing(id)
	emit_sound(id, CHAN_AUTO, g_szDefuseSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
 
public infoMessage()
{
	if(g_bBooleans[iFun])
	{
		CC_SendMatched(0, RED, "Para resetar seu score, digite ^x04.rr^x01.")
	}
	if(g_bBooleans[iLive] || g_bBooleans[iOvT])
	{
		CC_SendMatched(0, RED, "Para doar^x04 $%i^x01 para um companheiro de time, digite ^x04.donate^x01.", get_pcvar_num(VarDonateMoney))
		CC_SendMatched(0, RED, "Para mutar um jogador, digite^x04 %s.", g_szCommandMessage)
		
		if(get_pcvar_num(VarLockSurrender) == 0)
			CC_SendMatched(0, RED, "Para se render na partida, digite ^x04.surrender^x01.")
	}
	
}


public UTMessage()
{
	set_dhudmessage(255, 0, 0, -1.0, 0.3, 0, 1.0, 5.0)
	show_dhudmessage(0,"ULTIMO ROUND!")
}

public EventNewRnd()
{
	if(g_bBooleans[iLive] || g_bBooleans[iOvT])
	{
		if(get_pcvar_num(VarHudMoney) == 2)
		{
			remove_task(TASK_HUD_REMOVE) 
			set_task(floatclamp(get_pcvar_float(_:g_bBooleans[g_Freezetime]), 1.0, 60.0 * 20.0), "removeMoneySprites", TASK_HUD_REMOVE)
		}
		
		if(g_iNums[iRRs])
		{
			if(g_iNums[iOwnerID])
				set_task(1.0, "showAce")

			if(g_iNums[iOwnerKnifeiKiller] && !g_iNums[iOwnerIDHS] && !g_iNums[iOwnerID])
				set_task(1.0, "showKnife")
				
			if(g_iNums[iOwnerIDHS] && !g_iNums[iOwnerID])
				set_task(1.0, "showHs")
				
			if(!g_iNums[iOwnerIDHS] && !g_iNums[iOwnerID] && !g_iNums[iOwnerKnifeiKiller])
				set_task(2.0, "showMultiKills")
		}
		
		RestoreDonate()

		if(get_pcvar_num(VarFreezePlacar))
		{
			set_task(1.0,"Placar",3000, .flags = "b") // live
		}
		else
		{
			if(task_exists(3000))
			{
				remove_task(3000)
				set_task(1.0,"Placar",3000 ,.flags = "a", .repeat = get_pcvar_num(g_bBooleans[g_Freezetime]))
			}
			else 
				set_task(1.0,"Placar",3000 ,.flags = "a", .repeat = get_pcvar_num(g_bBooleans[g_Freezetime]))
		}

		set_task(8.0, "resetFrag")
		
		//if(g_iNums[iRounds] == 15 || g_bBooleans[iOvT] && g_iNums[iRounds] == 3)
		if((g_iNums[iCTsPlacar] + g_iNums[iTRsPlacar]) == 14 || g_bBooleans[iOvT] && g_iNums[iRounds] == 3) // EDI��O ALEX
		
		{
			client_cmd(0, "spk ^"doop.final round^"")
			set_task(2.0, "UTMessage")
		}
			
		set_task(1.0, "DeadOnResp", .flags = "a", .repeat = 11)

		if(get_pcvar_num(VarSelfTK) && get_pcvar_num(VarFFVote))
			server_cmd("mp_friendlyfire 1")
		
		if(g_bBooleans[g_Surrender])
			set_task(1.0, "SurrenderVote")
	
	}
	if(g_bBooleans[iKnife])
	{
		if(g_bBooleans[g_KnifeTrWinner] || g_bBooleans[g_KnifeCtWinner])
			set_task(0.1,"KnifeWinner")
	}
}

public showKnife()
{
	set_hudmessage(78, 244, 66, -1.0, 0.33, 0, 0.1, 4.0)
	ShowSyncHudMsg(0, g_hHuds[hHudHS], "============= FACA =============^n%s matou o noob do %s na faca^n============= FACA =============", g_dUserData[g_iNums[iOwnerKnifeiKiller]][szName], g_dUserData[g_iNums[iOwnerKnifeiVictim]][szName])
	
	message_begin(MSG_ALL, g_mMessageScreenShake)
	write_short(255 << 15)
	write_short(255 << 15)
	write_short(255 << 15)
	message_end()
	
	client_cmd(0, "spk %s", g_szKnifeSound)
	
	g_iNums[iOwnerKnifeiKiller] = g_iNums[iOwnerKnifeiVictim] = 0
}

public showHs()
{
	set_hudmessage(217, 4, 4, -1.0, 0.33, 0, 0.1, 4.0)
	ShowSyncHudMsg(0, g_hHuds[hHudHS], "============= HS =============^n%s fez um semi-neide so de HS na equipe %s^n============= HS =============", g_dUserData[g_iNums[iOwnerIDHS]][szName], (g_CurTeam[iOwnerIDHS] = CS_TEAM_T) ? "CT" : "TR")
	
	message_begin(MSG_ALL, g_mMessageScreenShake)
	write_short(255 << 15)
	write_short(255 << 15)
	write_short(255 << 15)
	message_end()
	
	client_cmd(0, "spk %s",g_szAceSounds[random_num(0,2)])
	
	g_iNums[iOwnerIDHS] = 0
}

public showMultiKills()
{	
	new iPlayers[MAX_PLAYERS],  iNum,id, szMessage[6][100], iUserTeam,szHs[5]
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
	for(new i; i < iNum;i++)
	{
		id = iPlayers[i]
		
		num_to_str(g_dUserData[id][iHsKills], szHs, charsmax(szHs))
		if(g_dUserData[id][iKills] >= get_pcvar_num(VarminKills))
		{
			iUserTeam = get_user_team(id)
			formatex(szMessage[iUserTeam], charsmax(szMessage[]), "%s%s - %d Kills(Hs - %s)^n", szMessage[iUserTeam], g_dUserData[id][szName], g_dUserData[id][iKills], (g_dUserData[id][iHsKills] >= 1) ? szHs : "Nenhum")
		}
			
		g_dUserData[id][iKills] = g_dUserData[id][iHsKills] = 0
		
		if(isTeam(id))
		{
			iUserTeam = get_user_team(id)

			set_hudmessage(0, 255, 0, -1.0, 0.17, 0, 1.0, 4.0)
			ShowSyncHudMsg(id, g_hHuds[hHudMK], "Multi-Kills dos %s", (g_CurTeam[id] == CS_TEAM_T) ? "TRs" : "CTs")

			set_hudmessage(255, 255, 255, -1.0, 0.21, 0, 1.0, 4.0)
			ShowSyncHudMsg(id, g_hHuds[hHudK], szMessage[iUserTeam][0] ? szMessage[iUserTeam] : "Ninguem deu multi-kill")
		}
	}
}

public EventEndRnd()
{		
	if(g_bBooleans[iLive])
	{
		g_iNums[iRounds]++

		if(g_bBooleans[bMD3])
		{
			if(g_iNums[iTRsPlacar] == 1 && g_iNums[iCTsPlacar] == 1)
			{
				if(g_iNums[iTempo] == 1)
				{
					CC_SendMatched(0, RED, "O^x04 MD3^x01 empatou, iniciando o^x04 live..")
					
					g_iNums[iCTsPlacar] = 0
					g_iNums[iTRsPlacar] = 0
					g_iNums[iRounds] = 1
					
					restartRound(3)
					client_cmd(0, "spk ^"doop.no team victor^"")
					
					g_bBooleans[bMD3] = false
					g_bBooleans[iLive] = true
				}
				// if(g_iNums[iTempo] == 2 && !g_bBooleans[g_Swapped])
				// {
				// 	CC_SendMatched(0, RED, "O^x04 MD3^x01 empatou, iniciando o^x04 live..")
				// 	g_iNums[iCTsPlacar] = 0
				// 	g_iNums[iTRsPlacar] = 0
					
				// 	//restartRound(3)
				// 	client_cmd(0, "spk ^"doop.no team victor^"")
					
				// 	g_bBooleans[bMD3] = false
				// 	g_bBooleans[iLive] = true
				// }
				// else if(g_iNums[iTempo] == 2 && g_bBooleans[g_Swapped])
				// {
				// 	CC_SendMatched(0, RED, "O^x04 MD3^x01 empatou, restaurando o placar e iniciando o^x04 live..")
				// 	g_bBooleans[bMD3] = false
				// 	g_bBooleans[iLive] = true
						
				// 	restartRound(1)
				// 	g_iNums[iCTsPlacar] = nvault_get( StatsVault , "TScore")
				// 	g_iNums[iTRsPlacar] = nvault_get( StatsVault , "CTScore")
				// 	client_cmd(0, "spk ^"doop.am d three victor^"")
				// }
			}
			return
		}
		if((g_iNums[iCTsPlacar] + g_iNums[iTRsPlacar]) == 15)
		{
			if(g_iNums[iTempo] == 1)
			{
				SaveScore()

				g_bBooleans[g_Swapped] = true
				g_iNums[iBestFragFirstH] = getFragger()
				g_iNums[iFirstHalfKill] = get_user_frags(g_iNums[iBestFragFirstH])
				g_iNums[iSwapPlacar] = g_iNums[iCTsPlacar]
				set_task(2.0, "SwapTeams")
			}
		}
		
		if(!g_bBooleans[iOvT])
		{
			if(g_iNums[iCTsPlacar] == 15 && g_iNums[iTRsPlacar] == 15)
			{
				g_iNums[iOverTimeCountDown] = 8
				set_task(1.0, "otCountDown", .flags = "a", .repeat = g_iNums[iOverTimeCountDown])
			}
		}
		else
		{
			if(g_iNums[iRounds] == 4)
			{
				set_task(2.0, "SwapTeams")
			}
		}
		
	}
}

SaveScore()
{
	new szTScore[ 4 ] , szCTScore[ 4 ]
	num_to_str( g_iNums[iCTsPlacar] , szCTScore , charsmax( szCTScore ) )
	num_to_str( g_iNums[iTRsPlacar] , szTScore , charsmax( szTScore ) )			
	nvault_set( StatsVault , "CTScore", szCTScore )
	nvault_set( StatsVault , "TScore", szTScore )
}

LoadScoreTR()
{
	g_bBooleans[bMD3] = false
	g_bBooleans[iLive] = true
		
	g_iNums[iCTsPlacar] = nvault_get( StatsVault , "TScore")
	g_iNums[iTRsPlacar] = (nvault_get( StatsVault , "CTScore") +1)
}

LoadScoreCT()
{
	g_bBooleans[bMD3] = false
	g_bBooleans[iLive] = true
		
	g_iNums[iCTsPlacar] = (nvault_get( StatsVault , "TScore") + 1)
	g_iNums[iTRsPlacar] = nvault_get( StatsVault , "CTScore")
}

public otCountDown()
{
	g_iNums[iOverTimeCountDown]--
	CC_SendMatched(0, TEAM_COLOR, "Votacao para overtime iniciara em^x04 %d^x01 segundo%s.", g_iNums[iOverTimeCountDown], (g_iNums[iOverTimeCountDown] > 1) ? "s": "")

	new const szSounds[][] = 
	{
		"",
		"one",
		"two",
		"three",
		"four",
		"five",
		"six",
		"seven"
	}
	
	client_cmd(0, "spk ^"fvox/%s^"", szSounds[g_iNums[iOverTimeCountDown]])
	
	if(g_iNums[iOverTimeCountDown] == 0)
	{
		OT_Votacao()
	}
}

public pub_pregame()
{	
	if(g_bBooleans[iFun] && get_pcvar_num(VarDisable) == 0)
	{
		switch(random_num(0,1))
		{
			case 0:
			{	
				set_hudmessage(100,100,255,-1.0,0.0,0,2.0,4.0)
				ShowSyncHudMsg(0,g_hHuds[hszMsgPregame],"%s Agradece sua visita", Pug_TagPrefix_hud)
			}	
			case 1:
			{	
				set_hudmessage(100,100,255,-1.0,0.0,0,2.0,4.0)
				ShowSyncHudMsg(0,g_hHuds[hszMsgPregame],"Tenham um bom jogo!^n%s agradece pela preferencia!", Pug_TagPrefix_hud)
			}
		}
	}
}
	
public hostName()
{
	get_cvar_string("hostname",gOriginalHostName,charsmax(gOriginalHostName))
	
	if(strlen(gOriginalHostName))
	{
		PlacarHostName()
		set_task(1.0,"PlacarHostName", .flags = "b")
	}
}

public PlacarHostName()
{	
	new NewHostName[100]
	new szModo[20]
	get_pugmode(szModo, charsmax(szModo))
	if(get_pcvar_num(VarHostNamePlacar))
	{
		if(g_bBooleans[iLive] || g_bBooleans[iOvT] || g_bBooleans[iEagle] || g_bBooleans[iKnife])
			formatex(NewHostName,charsmax(NewHostName),"%s [%s][%dT-R:%d][CT:%d TR:%d]",gOriginalHostName, szModo, g_iNums[iTempo], g_iNums[iRounds], (g_iNums[iCTsPlacar] + g_iNums[iCTsPlacarOT]), (g_iNums[iTRsPlacar] + g_iNums[iTRsPlacarOT]))

		else
			formatex(NewHostName,charsmax(NewHostName),"%s .",gOriginalHostName)
	}
	else
		formatex(NewHostName,charsmax(NewHostName),"%s .",gOriginalHostName)
		
	set_cvar_string("hostname", NewHostName)
		
	message_begin(MSG_BROADCAST, g_mMessageHostName)
	write_string(NewHostName)
	message_end()
}

public plugin_end()
{
	set_cvar_string("hostname", gOriginalHostName)
	nvault_close( StatsVault)
}


setTag(id, iRemove)
{
	new szReadyTag[MAX_PLAYERS]
	get_pcvar_string(VarTagReady, szReadyTag, charsmax(szReadyTag))
	switch(iRemove)
	{
		case 0:
		{
			if(containi(g_dUserData[id][szName], szReadyTag) != -1)
				return

			new szFullName[MAX_PLAYERS]
			formatex(szFullName, charsmax(szFullName), "%s %s", szReadyTag, g_dUserData[id][szName])	
			set_user_info(id, "name", szFullName)
		}
		case 1:
		{
			if(containi(g_dUserData[id][szName], szReadyTag) != -1)
			{
				replace(g_dUserData[id][szName], charsmax(g_dUserData[]), szReadyTag, "")
				set_user_info(id, "name", g_dUserData[id][szName])
			}
		}
	}
}

public ClientUserInfoChanged(id)
{
	if(is_user_connected(id))
	{
		new szOldName[MAX_PLAYERS]
		pev(id,pev_netname,szOldName,charsmax(szOldName))
		
		if(szOldName[0])
		{
			new const name[] = "name"
			new szNewName[MAX_PLAYERS]
			get_user_info(id,name,szNewName,charsmax(szNewName))
			
			Result = regex_match(szNewName,PATTERN_IP,ReturnValue,Error,63)
			
			if(Result)
			{
				set_user_info(id,name,"Anti-IP by")
					
				return FMRES_HANDLED
			}
		
		}
	}
	
	return FMRES_SUPERCEDE
}

public xFilterSayIP(id)
{	
	read_args(AllArgs,1023)
	
	Result = regex_match(AllArgs,PATTERN_IP,ReturnValue,Error,63)

	new BanTime = get_pcvar_num(VarBan)
	
	if(Result)
	{		
		if(BanTime >= 1)
		{
			CC_SendMatched(0, TEAM_COLOR,"Jogador ^4%s ^3foi banido por %d minuto%s por Divulgar ^4IP's ^3no servidor.",g_dUserData[id][szName], BanTime, (BanTime > 1) ? "s": "")
			server_cmd("amx_ban ^"%s^"^"%i^"^"Divulgando IP's^"", g_iPlayerSteam[id], BanTime)
		}
		else if(BanTime == 60)
		{
			CC_SendMatched(0, TEAM_COLOR,"Jogador ^4%s ^3foi banido permanentemente por Divulgar ^4IP's ^3no servidor.",g_dUserData[id][szName])
			server_cmd("amx_ban ^"%s^"^"%i^"^"Divulgando IP's^"", g_iPlayerSteam[id], BanTime)
		}		
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public OT_Votacao()
{
	new szTittle[60]
	formatex(szTittle, charsmax(szTittle), "\y[\w%s\d - \rOverTime? \y]", Pug_MenuPrefix)
	new iMenu = menu_create(szTittle, "ot_vote_handler")

	menu_additem(iMenu, "\ySim")
	menu_additem(iMenu, "\rNao")

	new iPlayers[MAX_PLAYERS], iNum, id
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
	for(new i; i < iNum;i++)
	{
		id = iPlayers[i]
		
		if(isTeam(id))
		{
			client_cmd(id, "spk Gman/Gman_Choose2")
			menu_display(id, iMenu)
		}
	}
	menu_setprop(iMenu, MPROP_EXIT, MEXIT_NEVER)

	set_task(10.0, "OT_Resultado")
	g_bBooleans[g_bVoteRunning] = true
}

public ot_vote_handler(id, menu,iItem)
{
	client_cmd(0,"spk buttons/button3")

	switch(iItem)
	{
		case 0: g_iVote[vOverTime][0]++
		case 1: g_iVote[vOverTime][1]++
	}
	
	CC_SendMatched(0, TEAM_COLOR, "Jogador^x03 %s^x01 %squer jogar o^x04 OverTime.", g_dUserData[id][szName], (iItem == 0) ? "": "nao ")
}

public OT_Resultado()
{
	show_menu(0, 0, "^n", 1)
	
	if(g_iVote[vOverTime][0] > g_iVote[vOverTime][1])
	{
		CC_SendMatched(0,RED,"Os jogadores decidiram jogar o OverTime. %i a favor e %i contra!",g_iVote[vOverTime][0], g_iVote[vOverTime][1])
		CC_SendMatched(0,RED,"Iniciando o primeiro round do OT...")
					
		set_task(0.5, "SetMode", 2)
		restartRound(1)
	}
	else if(g_iVote[vOverTime][1] > g_iVote[vOverTime][0])
	{
		CC_SendMatched(0,RED,"Os jogadores decidiram nao jogar o OverTime. %i a favor e %i contra!",g_iVote[vOverTime][1], g_iVote[vOverTime][0])
		CC_SendMatched(0,RED,"Executando 4FUN....")
		
		set_task(1.0, "SetMode", 3)
		set_task(1.0, "showVotemapHud", .flags = "a", .repeat = 3)
		set_task(4.0,"voteNextMap")
	}
	else
	{
		CC_SendMatched(0,RED,"O(s) voto(s) empataram!")
		CC_SendMatched(0,RED,"Iniciando o primeiro round do OT...")

		set_task(0.5, "SetMode", 2)
		restartRound(1)
	}
	
	g_iVote[vOverTime][0] = g_iVote[vOverTime][1] = 0
}

public EventTRWin() 
{
	if(g_bBooleans[iKnife])
	{
		g_iNums[iTRsPlacar]++

		if(g_iNums[iTRsPlacar] == 1 && g_iNums[iCTsPlacar] == 0)
		{
			CC_SendMatched(0, RED, "Os^x03 TRs^x01 venceram o round^x04 faca.")
			client_cmd(0, "spk ^"doop.round one victor^"")
			g_bBooleans[g_KnifeTrWinner] = true
			g_bBooleans[g_MoneyTrWinner] = true
		}
	}
	if(g_bBooleans[iLive])
	{
		if(g_bBooleans[bMD3])
		{
	
			g_iNums[iTRsPlacar]++

			if(g_iNums[iTRsPlacar] == 1 && g_iNums[iCTsPlacar] == 0)
			{
				CC_SendMatched(0, RED, "TRs^x01 venceram o primeiro Round: ^x04TRs: 1 ^x01-^x04 CTs: 0")
				client_cmd(0, "spk ^"doop.round one victor^"")
				restartRound(1)
			}
			else if(g_iNums[iTRsPlacar] == 2)
			{
				if(g_iNums[iTempo] == 1 && !g_bBooleans[g_Swapped])
				{
					CC_SendMatched(0, RED, "Os TRs^x01 venceram o MD3 ^x04 TRs: 2 ^x01-^x04 CTs: 0^x01")
			
					g_iNums[iTRsPlacar] -= 1
					client_cmd(0, "spk ^"doop.am d three victor^"")
					g_bBooleans[bMD3] = false
					g_bBooleans[iLive] = true
					g_iNums[iRounds] = 0
					// alex
					
				}
				else if(g_bBooleans[g_Swapped])
				{
					LoadScoreTR()		
					client_cmd(0, "spk ^"doop.am d three victor^"")
				}
			}
			return
		}
	
		if(!g_bBooleans[iOvT])
		{
			g_iNums[iTRsPlacar]++
			
			if(g_iNums[iTRsPlacar] == 16)
			{
				set_task(3.0, "SetMode", 3)
				set_task(1.0, "showVotemapHud", .flags = "a", .repeat = 3)
				set_task(4.0,"voteNextMap")
				TRWins()
	
				g_iNums[iBestFragSecH] = getFragger()
			}
		}
		else
		{
			g_iNums[iTRsPlacarOT]++
			
			if(g_iNums[iTRsPlacarOT] == 4)
			{
				set_task(3.0, "SetMode", 3)
				set_task(1.0, "showVotemapHud", .flags = "a", .repeat = 3)
				set_task(4.0,"voteNextMap")
				TRWins()
			}
		}
	}
}

public EventCTWin()
{
	CC_SendMatched(0, RED, "^x04 ep1c girls Brasil")
	if(g_bBooleans[iKnife])
	{
		g_iNums[iCTsPlacar]++
		if(g_iNums[iCTsPlacar] == 1 && g_iNums[iTRsPlacar] == 0)
		{
			CC_SendMatched(0, RED, "Os^x03 CTs^x01 venceram o round^x04 faca.")
			client_cmd(0, "spk ^"doop.round one victor^"")
			g_bBooleans[g_KnifeCtWinner] = true
			
		}
	}
	if(g_bBooleans[iLive])
	{
		if(g_bBooleans[bMD3])
		{
			g_iNums[iCTsPlacar]++
			
			if(g_iNums[iCTsPlacar] == 1 && g_iNums[iTRsPlacar] == 0)
			{
				//CC_SendMatched(0, BLUE, "Os^x03 CTs^x01 venceram o primeiro round do^x04 MD3.")
				CC_SendMatched(0, RED, "Os CTs^x01 venceram o primeiro Round MD3: ^x04CTs: 1 ^x01-^x04 TRs: 0")
					
				client_cmd(0, "spk ^"doop.round one victor^"")
				restartRound(1)
		
			}
			else if(g_iNums[iCTsPlacar] == 2)
			{
				if(g_iNums[iTempo] == 1 && !g_bBooleans[g_Swapped])
				{
					//CC_SendMatched(0, BLUE, "Os^x03 CTs^x01 venceram o^x04 MD3^x01 e comecam na vantagem!")
					CC_SendMatched(0, RED, "Os CTs^x01 venceram o MD3 ^x04 CTs: 2 ^x01-^x04 TRs: 0")
				
					g_iNums[iCTsPlacar] -= 1
					client_cmd(0, "spk ^"doop.no team victor^"")
					
					g_bBooleans[bMD3] = false
					g_bBooleans[iLive] = true
					g_iNums[iRounds] = 0
					// alex
				}
				else if(g_bBooleans[g_Swapped])
				{
					LoadScoreCT()
					client_cmd(0, "spk ^"doop.no team victor^"")
				}
			}
			return
		}
		if(!g_bBooleans[iOvT])
		{
			g_iNums[iCTsPlacar]++
			
			if(g_iNums[iCTsPlacar] == 16)
			{
				set_task(3.0, "SetMode", 3)
				set_task(1.0, "showVotemapHud", .flags = "a", .repeat = 3)
				set_task(4.0,"voteNextMap")
				CTWins()
	
				g_iNums[iBestFragSecH] = getFragger()
				
			}
		}
		else
		{
			g_iNums[iCTsPlacarOT]++
			if(g_iNums[iCTsPlacarOT] == 4)
			{
				set_task(3.0, "SetMode", 3)
				set_task(1.0, "showVotemapHud", .flags = "a", .repeat = 3)
				set_task(4.0,"voteNextMap")
				CTWins()
			}
		}
	}
}

public GameDesc() 
{ 
	if(!get_pcvar_num(VarDescriptionPlacar) || get_pcvar_num(VarDisable))
	{
		return FMRES_IGNORED
	}
	
	static szModo[20], szGameName[20]
	get_pugmode(szModo, charsmax(szModo))
	formatex(szGameName, charsmax(szGameName), "[%s]", szModo)
	forward_return(FMV_STRING, szGameName)
	return FMRES_SUPERCEDE
}

public PlayerDamage(id, inflictor, attacker, Float:damage, damagetype)
{	
	if(!g_bBooleans[iLive] || !g_bBooleans[iOvT] || !is_user_connected(attacker) || !is_user_connected(id) || attacker == id)
		return HAM_IGNORED

	if(!get_pcvar_num(VarFriendly))
		return HAM_IGNORED

	if(get_pcvar_num(VarSelfTK) && cs_get_user_team(id) == cs_get_user_team(attacker))
		SetHamParamEntity(1, attacker)
	
	return HAM_IGNORED
}

public event_deathMsg()
{
	new iVictim = read_data(2), iKiller = read_data(1), Hs = read_data(3), BonusHP = 15, MaxHP = 100, BonusHS = 30
											
	if(g_bBooleans[iFun])
	{
		if (gPrimeiraVez4fun)
		{
		set_task(get_pcvar_float(VarSpawnDelay),"PugRespawn",iVictim)
		}
	}
	
	if(iVictim == iKiller)
		return
	
	if(g_bBooleans[iEagle])
	{
		new vicname[MAX_PLAYERS], killname[MAX_PLAYERS], health
		
		health = get_user_health(iKiller)
		Winner[iVictim] = iKiller
		Loser[iKiller] = iVictim
		
		get_user_name(iVictim,vicname,31)
		get_user_name(iKiller,killname,31)
		
		g_bBooleans[iEagle] = false

		set_task(3.7, "SetMode", 3)
		
		server_cmd("sv_alltalk 1")
		
		client_cmd(0,"spk ^"all.talk.on^"")
		
		if(get_pcvar_num(VarShowHP) == 1)
		{
			if(g_dUserData[iVictim][bIsSelected])
			{
				CC_SendMatched(0, RED,"%s^x01 matou^x04 %s^x01 e ficou com^x04 %i HP.",killname,vicname,health)
				CC_SendMatched(0, RED,"Portanto, ^x03%s^1 comeca escolhendo.", killname)
				
				gHPKiller[iKiller] = health
			}
		}
	}
	
	new vicname[MAX_PLAYERS], killname[MAX_PLAYERS], health
		
	health = get_user_health(iKiller)
	Winner[iVictim] = iKiller
	Loser[iKiller] = iVictim
	new weapon
	
	get_user_name(iVictim,vicname,31)
	get_user_name(iKiller,killname,31)

	if(is_user_connected(iKiller))
		weapon = get_user_weapon(iKiller)
	
	if(g_bBooleans[iLive] || g_bBooleans[iOvT])
	{
		removeMoneySprite(iVictim)
		
		if(get_pdata_int(iVictim, m_bitsDamageType) & DMG_BLAST)
			return
		
		g_dUserData[iKiller][iKills]++
		
		if(Hs)
			g_dUserData[iKiller][iHsKills]++

		if(weapon == CSW_KNIFE)
		{
			g_iNums[iOwnerKnifeiKiller] = iKiller
			g_iNums[iOwnerKnifeiVictim] = iVictim
		}
		
		if(g_dUserData[iKiller][iKills] == get_pcvar_num(VarPlr))
			g_iNums[iOwnerID] = iKiller
		
		if(g_dUserData[iKiller][iHsKills] == g_dUserData[iKiller][iKills] && g_dUserData[iKiller][iHsKills] == 4)
			g_iNums[iOwnerIDHS] = iKiller
		
		if(get_pcvar_num(VarShowHP) == 1)
		{
			CC_SendMatched(iVictim,RED,"%s^x01 te matou, ficando com^x04 %i HP.", killname, health)
			gHPKiller[iKiller] = health
		}
	}
	if(g_bBooleans[iFun] || get_pcvar_num(VarEagleAkc))
	{
		if( iKiller && iVictim != iKiller ) 
		{
			if( health != MaxHP ) 
			{
				new OverLoadHP = (MaxHP - health)
				if(Hs) 
				{
					if( health + BonusHS > MaxHP ) 
					{
						set_user_health(iKiller, MaxHP)
						CC_SendMatched(iKiller,RED,"Você matou^x03 %s^x01 com ^x04HS^x01, e ganhou^x04 %i HP.", vicname, OverLoadHP)
					}
					else
					{
						set_user_health(iKiller, health + BonusHS)
						CC_SendMatched(iKiller,RED,"Você matou^x03 %s^x01 com ^x04HS^x01, e ganhou^x04 %i HP.", vicname, BonusHS)
					}					
				}
				else 
				{
					if( health + BonusHP > MaxHP ) 
					{
						set_user_health(iKiller, MaxHP)
						CC_SendMatched(iKiller,RED,"Você matou^x03 %s^x01, e ganhou^x04 %i HP.", vicname, OverLoadHP )
					}
					else
					{
						set_user_health(iKiller, health + BonusHP)
						CC_SendMatched(iKiller,RED,"Você matou^x03 %s^x01, e ganhou^x04 %i HP.", vicname, BonusHP)
					}
				}
			}
		}
	}
}

public client_damage(iAttacker,iVictim,iDamage,iWP,iPlace,TA)
{
	if(g_bBooleans[iLive] || g_bBooleans[iOvT])
	{
		g_iHits[iAttacker][iVictim]++
		g_iDamage[iAttacker][iVictim] += iDamage
	}
}

public PlayerSpawn(id)
{
	if(is_user_alive(id))
	{
		if(g_bBooleans[iEagle] || get_pcvar_num(VarEagleAkc))
		{
			strip_user_weapons(id)
			give_item(id, "weapon_deagle")
			give_item(id, "weapon_knife")
			
			cs_set_user_money(id, 0)
			cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM)
			cs_set_user_bpammo(id, CSW_DEAGLE, 35)
		}
		
		if(g_bBooleans[iFun])
		{
			if(get_pcvar_num(VarEagleAkc) == 0)
				cs_set_user_money(id, get_pcvar_num(VarMoney))

			if(!g_bBooleans[iEagle] && !g_dUserData[id][bFirstSpawn] && get_pcvar_num(VarLockReady) == 0)
			{
				g_dUserData[id][bFirstSpawn] = true

				new szPunishment[10], szMessage[MAX_PLAYERS]
				get_pcvar_string(VarPunishment, szPunishment, charsmax(szPunishment))
				switch(szPunishment[0])
				{
					case 'n', 'N':	return PLUGIN_HANDLED
					case 's', 'S':
					{
						formatex(szMessage, charsmax(szMessage), "transferido para spec")
					}
					case 'k', 'K':
					{
						formatex(szMessage, charsmax(szMessage), "kickado")
					}
					default:
					{
						formatex(szMessage, charsmax(szMessage), "forcado a dar^x04 .ready")
					}
				}
				if(g_dUserData[id][bIsReady] || get_pcvar_num(VarDisable))
					return PLUGIN_HANDLED
				if(szPunishment[0])
				{
					new iReadyTime = get_pcvar_num(VarReadyTime)
					set_task(float(iReadyTime), "forceReady", id + TASK_CHECKREADY)

					CC_SendMatched(id, RED, "Bem vindo, você tem^x04 %d^x01 segundo%s para dar .ready.", iReadyTime, (iReadyTime > 1) ? "s": "")
					CC_SendMatched(id, RED, "Caso contrario, sera %s.", szMessage)
				}
				return PLUGIN_HANDLED
			}
		}
		if(g_bBooleans[iLive])
		{
			if(g_bBooleans[g_MoneyMaker])
			{
				SetMoney()
				g_bBooleans[g_MoneyMaker] = false
				g_bBooleans[g_MoneyTrWinner] = false
				
			}
			if(get_pcvar_num(VarHudMoney) == 1)
			{
				set_task(1.0, "showMoney", id + TASK_SHOWMONEY, .flags = "a", .repeat = 6)
			}
			else if((get_pcvar_num(VarHudMoney) == 2) && task_exists(TASK_HUD_REMOVE))
			{
				removeMoneySprite(id)
				setMoneySprite(id)
			}
		}
		if(g_bBooleans[iKnife])
		{
			strip_user_weapons(id)
			give_item(id, "weapon_knife")
			
			cs_set_user_money(id, 0)
			cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM)
		}
		if(g_bBooleans[iOvT])
		{
			if(g_iNums[iRounds] == 1)
			{
				cs_set_user_money(id, get_pcvar_num(OverTimeMoney))
			}
		}
	}
	return PLUGIN_CONTINUE
}

public forceReady(TaskId)
{
	new id = TaskId - TASK_CHECKREADY

	new szPunishment[10], szMessage[64]
	get_pcvar_string(VarPunishment, szPunishment, charsmax(szPunishment))
	switch(szPunishment[0])
	{
		case 'n', 'N':	return
		case 's', 'S':
		{
			formatex(szMessage, charsmax(szMessage), "transferido para spec por nao da^x04 .ready")

			dllfunc(DLLFunc_ClientKill, id)
			cs_set_user_team(id, CS_TEAM_SPECTATOR)
		}
		case 'k', 'K':
		{
			server_cmd("kick #%i ^"Kickado por nao ficar ready^"", get_user_userid(id))
		}
		default:
		{
			ReadyCMD(id)
			formatex(szMessage, charsmax(szMessage), "auto forcado a dar^x04 .ready")
		}
	}
	CC_SendMatched(id, RED, "Você foi %s.", szMessage)
}

NoReadySpec()
{
	new iPlayers[MAX_PLAYERS], iNum, id
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
	for(new i; i < iNum;i++)
	{
		id = iPlayers[i]
		
		if(!g_dUserData[id][bIsReady] && isTeam(id))
		{
			dllfunc(DLLFunc_ClientKill, id)
			cs_set_user_team(id, CS_TEAM_SPECTATOR)
			CC_SendMatched(id, RED,"Você foi transferido para^x03 Spec")
		}
	}
}

CheckAwayTime(id)
{
	if(!cs_get_user_buyzone(id))
		return
	
	new iMaxAfkTime = get_pcvar_num(VarAfkTime)
	if(iMaxAfkTime < MIN_AFK_TIME) 
	{
		iMaxAfkTime = MIN_AFK_TIME
		set_pcvar_num(VarAfkTime, MIN_AFK_TIME)
	}
	
	if((iMaxAfkTime - WARNING_TIME) <= gAfkTime[id] < iMaxAfkTime) 
	{
		new iTimeLeft = iMaxAfkTime - gAfkTime[id]
		CC_SendMatched(id, RED, "Você tem^x04 %i^x01 segundos para se mover ou ser expulso por estar^x04 away.", iTimeLeft)
		client_cmd(id,"speak away")
	} 
	else if(gAfkTime[id] > iMaxAfkTime) 
	{
		CC_SendMatched(0, RED, "%s^x01 foi expulso por estar^x04 away base^x01 mais de^x04 %i^x01 segundos", g_dUserData[id][szName], iMaxAfkTime)
		server_cmd("kick #%d ^"Você foi expulso por estar AWAY mais de %i segundos^"", get_user_userid(id), iMaxAfkTime)
	}
}

public Forward_SetClientListening(iReceiver, iSender, bool:bListen)
{
	if(g_bPlayerMuted[iReceiver][iSender]) 
	{
		engfunc(EngFunc_SetClientListening, iReceiver, iSender, false)
		forward_return(FMV_CELL, false)
		return FMRES_SUPERCEDE
	}
	else
	{
		if(get_pcvar_num(VarDeadMic))
		{
			if(get_user_team(iSender) == get_user_team(iReceiver))
			{
				engfunc(EngFunc_SetClientListening, iReceiver, iSender, true)
				forward_return(FMV_CELL, true)
				return FMRES_SUPERCEDE
			}
		}
	}
	return FMRES_IGNORED
}

public DeadOnResp(id)
{
	new iPlayers[MAX_PLAYERS], iNum, id
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeAlive | GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
	for(new i; i < iNum;i++)
	{
		id = iPlayers[i]

		if(isTeam(id))
		{
			ExecuteHamB(Ham_CS_RoundRespawn, id)
		}	
	}
}

public CheckPlayers() 
{
	if(!g_bBooleans[iLive] || !g_bBooleans[iOvT] || !get_pcvar_num(VarAfkKick))
		return

	new iPlayers[MAX_PLAYERS], iNum, id
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeDead | GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
	
	for(new i; i < iNum;i++)
	{
		if(!iNum)
			return

		id = iPlayers[i]
	
		new NewAngle[3]
		get_user_origin(id, NewAngle)
		
		if (NewAngle[0] == gOldAngles[id][0] && NewAngle[1] == gOldAngles[id][1] && NewAngle[2] == gOldAngles[id][2]) 
		{
			gAfkTime[id] += CHECK_FREQ
			CheckAwayTime(id)
		} 
		else 
		{
			gOldAngles[id][0] = NewAngle[0]
			gOldAngles[id][1] = NewAngle[1]
			gOldAngles[id][2] = NewAngle[2]

			gAfkTime[id] = 0
		}
	}
}

getReadyNum(iTeam = 0) 
{
	new iPlayers[MAX_PLAYERS], iPlayerNum, iReturnNum
	if(iTeam)
	{
		get_players_ex(iPlayers, iPlayerNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots | GetPlayers_MatchTeam, (iTeam == 1) ? "TERRORIST" : "CT")
	}
	else
	{
		get_players_ex(iPlayers, iPlayerNum)
	}
	
	for(new i = 0; i < iPlayerNum; i++)
	{
		if(g_dUserData[iPlayers[i]][bIsReady])
		{
			iReturnNum++
		}
	}
	return iReturnNum
}

public removeAllRdy()
{
	new iPlayers[MAX_PLAYERS], iNum, id
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
	for(new i; i < iNum;i++)
	{
		id = iPlayers[i]

		if(task_exists(id + TASK_CHECKREADY))
		{
			remove_task(id + TASK_CHECKREADY)
		}

		g_dUserData[id][bIsReady] = false
		g_dUserData[id][bIsSelected] = false
		g_dUserData[id][bFirstSpawn] = false
		setTag(id, 1)
	}
}

allSpec()
{
	new iPlayers[MAX_PLAYERS], iNum, id
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
	for(new i; i < iNum;i++)
	{
		id = iPlayers[i]

		if(!g_dUserData[id][bIsSelected])
		{
			dllfunc(DLLFunc_ClientKill, id)
			cs_set_user_team(id, CS_TEAM_SPECTATOR)
		}
	}
	
	removeAllRdy()
	HudSpec()
}

public PugJoinTeam(id) 
{
	new szArg[3]
	read_argv(1, szArg, charsmax(szArg))

	return PugCheckTeam(id, str_to_num(szArg))
}

public PugTeamSelect(id, iKey) return PugCheckTeam(id, iKey + 1)

PugCheckTeam(id, iTeamNew) 
{	
	if(iTeamNew == 6)
		return PLUGIN_CONTINUE
		
	if(g_bBooleans[iEagle])
	{
		if(g_dUserData[id][bIsSelected])
		{
			if(iTeamNew != get_user_team(id))
			{
				CC_SendMatched(id, RED, "Tiracao de times em andamento, nao tente entrosar.")
				InvalidSound(id)
				return PLUGIN_HANDLED
			}
		}
		else
		{
			CC_SendMatched(id, RED, "Tiracao de times em andamento, nao tente entrosar.")
			InvalidSound(id)
			return PLUGIN_HANDLED
		}
	}
	
	new iPlrLmt = get_pcvar_num(VarPlr)
	if(g_bBooleans[g_bVoteRunning])
	{
		if(iTeamNew == 5)
		{
			CC_SendMatched(id, RED, "Opcao desativada.")
			InvalidSound(id)
			return PLUGIN_HANDLED
		}
		else
		{	
			new iPlayers[MAX_PLAYERS], iNum[CsTeams]
			get_players_ex(iPlayers, iNum[CS_TEAM_CT], GetPlayers_ExcludeHLTV | GetPlayers_MatchTeam, "CT")
			get_players_ex(iPlayers, iNum[CS_TEAM_T], GetPlayers_ExcludeHLTV | GetPlayers_MatchTeam, "TERRORIST")
		
			
			if(iNum[CS_TEAM_CT] >= iPlrLmt || iNum[CS_TEAM_T] >= iPlrLmt)
			{
				CC_SendMatched(id, RED, "Este time ja esta completo.")
				InvalidSound(id)
				return PLUGIN_HANDLED
			}
		}
		return PLUGIN_CONTINUE
	}
	
	if(g_bBooleans[iFun])
	{
		if(iTeamNew == 5)
		{
			CC_SendMatched(id, RED, "Opcao desativada.")
			InvalidSound(id)
			return PLUGIN_HANDLED
		}
		else
		{			
			if(getReadyNum(iTeamNew) >= iPlrLmt)
			{
				CC_SendMatched(id, RED, "Este time ja esta completo.")
				InvalidSound(id)
				return PLUGIN_HANDLED
			}
			
			if(!isTeam(id))
			{
				set_task(get_pcvar_float(VarSpawnDelay),"PugRespawn",id)
			}
		}
		return PLUGIN_CONTINUE
	}
	
	switch(iTeamNew)
	{
		case 1, 2, 5:
		{
			new iPlayers[MAX_PLAYERS], iNum[CsTeams]
			get_players_ex(iPlayers, iNum[CS_TEAM_CT], GetPlayers_ExcludeHLTV | GetPlayers_MatchTeam, "CT")
			get_players_ex(iPlayers, iNum[CS_TEAM_T], GetPlayers_ExcludeHLTV | GetPlayers_MatchTeam, "TERRORIST")
	
			if((iNum[CS_TEAM_T] >= iPlrLmt) && (iTeamNew == 1) || (iNum[CS_TEAM_CT] >= iPlrLmt) && (iTeamNew == 2) || (iTeamNew == 5))
			{
				CC_SendMatched(id, RED, "%^x03 Este time ja esta completo!")
				engclient_cmd(id,"chooseteam")

				InvalidSound(id)
				return PLUGIN_HANDLED
			}
		}
	}
	return PLUGIN_CONTINUE
}

needPlayers(id)
{
	new iPcvarMin = get_pcvar_num(VarMini), iPlayersNum = get_playersnum()
	if((iPlayersNum - iPcvarMin) < 0)
	{
		new iPlayersNeeded = (iPcvarMin - iPlayersNum)

		CC_SendMatched(id, RED,"Falta%s^x04 %d^x01 jogador%s para o inicio do^x04 MIX!", (iPlayersNeeded >= 2) ? "m": "", iPlayersNeeded, (iPlayersNeeded >= 2) ? "es": "")
		InvalidSound(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public client_infochanged(id)
{
	get_user_info(id, "name", g_dUserData[id][szName], charsmax(g_dUserData[]))

	if(g_bBooleans[iLive] || g_bBooleans[iOvT])
		return

	new szReadyTag[MAX_PLAYERS]
	get_pcvar_string(VarTagReady, szReadyTag, charsmax(szReadyTag))
	
	if((containi(g_dUserData[id][szName], szReadyTag) == -1) && g_dUserData[id][bIsReady])
	{
		new szUserName[MAX_PLAYERS]
		formatex(szUserName, charsmax(szUserName), "%s %s", szReadyTag, g_dUserData[id][szName])
		set_user_info(id, "name", szUserName)
	}
} 

public PugMsgSayText(iMsg,MSG_DEST,id)
{
	static sBuffer[23]
	get_msg_arg_string(2,sBuffer,charsmax(sBuffer))
	
	if(equal(sBuffer,"#Cstrike_Name_Change")) 
		return PLUGIN_HANDLED

	return PLUGIN_CONTINUE
}

ReadyCMD(id)
{
	new iNeededPlayers = get_pcvar_num(VarMini)
	new AlreadyReady = (iNeededPlayers - getReadyNum())

	if(!is_user_connected(id))
		return PLUGIN_HANDLED
		
	else if(!isTeam(id))
	{
		CC_SendMatched(id, RED, "Você precisa estar em um time.")
		client_cmd(id, "spk buttons/blip2")
		return PLUGIN_HANDLED
	}
	else if(get_pcvar_num(VarLockReady) == 1)
	{
		CC_SendMatched(id, RED, "O comando ^x04.ready^x01 esta desativado.")
		client_cmd(id, "spk buttons/blip2")
		return PLUGIN_HANDLED
	}
	else if(get_pcvar_num(VarDisable))
	{
		CC_SendMatched(id, RED, "O comando ^x04.ready^x01 esta desativado.")
		client_cmd(id, "spk buttons/blip2")
		return PLUGIN_HANDLED
	}
	else if(g_bBooleans[iLive] || g_bBooleans[iOvT])
	{
		CC_SendMatched(id, RED, "Ja esta^x04 LIVE.")
		client_cmd(id, "spk buttons/blip2")
		return PLUGIN_HANDLED
	}
	else if(g_dUserData[id][bIsReady])
	{
		CC_SendMatched(id, RED, "Você ja esta pronto. Mais^x04 %d jogador%s^x01 para comecar.", AlreadyReady, (AlreadyReady > 1) ? "es": "")
		client_cmd(id, "spk buttons/blip2")
		return PLUGIN_HANDLED
	}
	else if(getReadyNum(get_user_team(id)) >= get_pcvar_num(VarPlr))
	{
		CC_SendMatched(id, RED, "Todos os jogadores do seu time ja estao prontos.")
		client_cmd(id, "spk buttons/blip2")
		return PLUGIN_HANDLED
	}

	setTag(id, 0)
	remove_task(id + TASK_CHECKREADY)

	g_dUserData[id][bIsReady] = true

	new iReadys = (iNeededPlayers - getReadyNum())

	if((iReadys) >= 1)
		CC_SendMatched(0, TEAM_COLOR, "Jogador^x04 %s^x01 pronto. Mais^x04 %d jogador%s^x01 para comecar.", g_dUserData[id][szName], (iReadys), (iReadys > 1) ? "es": "")
	else
		CC_SendMatched(0, TEAM_COLOR, "Todos os jogadores estao^x04 prontos,^x01 se preparem para iniciar a ^x04partida.")
		
	if(getReadyNum() == iNeededPlayers)
	{
		CC_SendMatched(0, RED,"Iniciando as ^x04votacoes!")
		
		NoReadySpec()
		g_bBooleans[g_bVoteRunning] = true

		set_pcvar_num(VarLockReady,1)
		set_pcvar_num(VarEagleAkc, 0)
		
		if (get_pcvar_num(VarRandomize))
		{
			set_task(3.0,"RandomizeVote")
		}
		else if (get_pcvar_num(VarFFVote))
		{
			set_task(3.0,"FFVotacao")
		}
		else if (get_pcvar_num(VarVoteMd3))
		{
			set_task(3.0,"MD3Votacao", TASK_votacao)
		}
			
		removeAllRdy()
	}
	return PLUGIN_HANDLED
}

public RandomizeVote()
{
	new szTittle[60]
	formatex(szTittle, charsmax(szTittle), "\y[\w%s\d - \rMisturar os times?\y]", Pug_MenuPrefix)
	new iMenu = menu_create(szTittle, "randomize_vote_handler")

	menu_additem(iMenu, "\ySim")
	menu_additem(iMenu, "\rNao")

	new iPlayers[MAX_PLAYERS], iNum, id
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
	for(new i; i < iNum;i++)
	{
		id = iPlayers[i]
		
		if(isTeam(id))
		{
			client_cmd(id, "spk Gman/Gman_Choose2")
			menu_display(id, iMenu)
		}
	}
	menu_setprop(iMenu, MPROP_EXIT, MEXIT_NEVER)

	set_task(10.0, "RandomizeVotacao_Finalizada")
	g_bBooleans[g_bVoteRunning] = true
}

public randomize_vote_handler(id,menu,iItem)
{
	client_cmd(0,"spk buttons/button3")

	switch(iItem)
	{
		case 0: g_iVote[vRT][0]++
		case 1: g_iVote[vRT][1]++
	}
	
	CC_SendMatched(0, TEAM_COLOR, "Jogador^x03 %s^x01 %squer^x04 misturar os times.", g_dUserData[id][szName], (iItem == 0) ? "": "nao ")
}

public RandomizeVotacao_Finalizada()
{
	show_menu(0, 0, "^n", 1)
	
	if(g_iVote[vRT][0] > g_iVote[vRT][1])
	{
		CC_SendMatched(0, RED,"Os players decidiram ^x04misturar os times.")
		RandomizeTeams()
		restartRound(1)
		
	}
	else if(g_iVote[vRT][1] > g_iVote[vRT][0])
	{
		CC_SendMatched(0, RED,"Os players decidiram ^x04nao misturar os times.")
		// MD3Votacao()

	}
	else if(g_iVote[vRT][0] == g_iVote[vRT][1])
	{
		CC_SendMatched(0, RED,"Os votos empataram, ^x04misturando os times....")
		RandomizeTeams()
		restartRound(1)
	}
	
	if(get_pcvar_num(VarFFVote))
	{
		CC_SendMatched(0, RED,"Iniciando a votacao para habilitar o^x04 TK!")
		set_task(3.0,"FFVotacao")
	}
	else if(get_pcvar_num(VarVoteMd3))
	{
		set_task(3.0,"MD3Votacao")
		CC_SendMatched(0, RED,"Iniciando a votacao para^x04 Live ou MD3!")
	}
	else
	{
		CC_SendMatched(0, RED,"Iniciando ^x04Live.")
		g_bBooleans[bMD3] = false
		set_task(3.0, "SetMode", 0)
	}

	g_iVote[vRT][0] = g_iVote[vRT][1] = 0
}

RandomizeTeams()
{
	new iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum)
    
	for(new i; i < iNum; i++)
	{
		if(!(CS_TEAM_T <= cs_get_user_team(iPlayers[i]) <= CS_TEAM_CT))
		{
			iPlayers[i--] = iPlayers[--iNum]
		}
	}
    
	new iPlayer, iRandom, CsTeams:iTeam = random(2) ? CS_TEAM_T : CS_TEAM_CT
	while(iNum)
	{
		iRandom = random(iNum)
		iPlayer = iPlayers[iRandom]
        
		cs_set_user_team(iPlayer, iTeam)
        
		iPlayers[iRandom] = iPlayers[--iNum]
		iTeam = CsTeams:((_:iTeam) % 2 + 1)
	}
}

public FFVotacao()
{
	new szTittle[60]
	formatex(szTittle, charsmax(szTittle), "\y[\w%s\d - \rHabilitar o TK? \y]", Pug_MenuPrefix)
	new iMenu = menu_create(szTittle, "ff_vote_handler")

	menu_additem(iMenu, "\ySim")
	menu_additem(iMenu, "\rNao")

	new iPlayers[MAX_PLAYERS], iNum, id
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
	for(new i; i < iNum;i++)
	{
		id = iPlayers[i]
		
		if(isTeam(id))
		{
			client_cmd(id, "spk Gman/Gman_Choose2")
			menu_display(id, iMenu)
		}
	}
	menu_setprop(iMenu, MPROP_EXIT, MEXIT_NEVER)

	set_task(10.0, "FFVotacao_Finalizada")
	g_bBooleans[g_bVoteRunning] = true
}

public ff_vote_handler(id,menu,iItem)
{
	client_cmd(0,"spk buttons/button3")

	switch(iItem)
	{
		case 0: g_iVote[vFF][0]++
		case 1: g_iVote[vFF][1]++
	}
	
	CC_SendMatched(0, TEAM_COLOR, "Jogador^x03 %s^x01 %squer habilitar o^x04 TK.", g_dUserData[id][szName], (iItem == 0) ? "": "nao ")
}

public FFVotacao_Finalizada()
{
	show_menu(0, 0, "^n", 1)
	
	if(g_iVote[vFF][0] > g_iVote[vFF][1])
	{
		CC_SendMatched(0, RED,"Os players decidiram ^x04habilitar o TK.")
		set_pcvar_num(VarSelfTK, 1)
	}
	else if(g_iVote[vFF][1] > g_iVote[vFF][0])
	{
		CC_SendMatched(0, RED,"Os players decidiram ^x04nao habilitar o TK.")
		set_pcvar_num(VarSelfTK, 0)
		g_bBooleans[bMD3] = false
	}
	else if(g_iVote[vFF][0] == g_iVote[vFF][1])
	{
		CC_SendMatched(0, RED,"Os votos empataram. Habilitando o ^x04TK...")
		set_pcvar_num(VarSelfTK, 1)
	}
	
	if(get_pcvar_num(VarVoteMd3))
	{
		CC_SendMatched(0, RED,"Iniciando votacao para ^x04Live^x01 ou ^x04MD3 Rounds...")
		set_task(3.0,"MD3Votacao")
	}
	else
	{
		CC_SendMatched(0, RED,"Iniciando ^x04Live.")
		g_bBooleans[bMD3] = false
		set_task(3.0, "SetMode", 0)
	}

	g_iVote[vFF][0] = g_iVote[vFF][1] = 0
}

public MD3Votacao()
{	
		
	static szTittle[60]
	formatex(szTittle, charsmax(szTittle), "\y[\w%s\d - \rJogar MD3? \y]", Pug_MenuPrefix)
	new iMenu = menu_create(szTittle, "md3_vote_handler")

	menu_additem(iMenu, "\ySim")
	menu_additem(iMenu, "\rNao")

	new iPlayers[MAX_PLAYERS], iNum, id
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
	for(new i; i < iNum;i++)
	{
		id = iPlayers[i]
		
		if(isTeam(id))
		{
			client_cmd(id, "spk Gman/Gman_Choose2")
			menu_display(id, iMenu)
		}
	}
	menu_setprop(iMenu, MPROP_EXIT, MEXIT_NEVER)

	set_task(10.0, "MD3Votacao_Finalizada")
	g_bBooleans[g_bVoteRunning] = true
}

public md3_vote_handler(id,menu,iItem)
{
	client_cmd(0,"spk buttons/button3")

	switch(iItem)
	{
		case 0: g_iVote[vMD3][0]++
		case 1: g_iVote[vMD3][1]++
	}
	
	CC_SendMatched(0, TEAM_COLOR, "Jogador^x03 %s^x01 %squer jogar o^x04 MD3.", g_dUserData[id][szName], (iItem == 0) ? "": "nao ")
}

public MD3Votacao_Finalizada()
{
	show_menu(0, 0, "^n", 1)
	
	if(g_iVote[vMD3][0] > g_iVote[vMD3][1])
	{
		CC_SendMatched(0, TEAM_COLOR, "^x04Md3^x01 venceu com^x04 %i^x01 voto%s a favor e^x04 %i^x01 voto%s contra.", g_iVote[vMD3][0], (g_iVote[vMD3][0] > 1) ? "s" : "", g_iVote[vMD3][1], (g_iVote[vMD3][1] > 1) ? "s" : "")
		g_bBooleans[bMD3] = true
		g_bBooleans[g_HasMd3] = true
		
	}
	else if(g_iVote[vMD3][1] > g_iVote[vMD3][0])
	{
		CC_SendMatched(0, TEAM_COLOR, "^x04Live^x01 venceu com^x04 %i^x01 voto%s a favor e^x04 %i^x01 voto%s contra.", g_iVote[vMD3][1], (g_iVote[vMD3][0] > 1) ? "s" : "", g_iVote[vMD3][0], (g_iVote[vMD3][1] > 1) ? "s" : "")
		CC_SendMatched(0, TEAM_COLOR, "Iniciando^x04 LIVE...")
		g_bBooleans[bMD3] = false
		g_bBooleans[g_HasMd3] = false
	}
	else
	{
		CC_SendMatched(0, RED,"Os votos empataram. Iniciando^x04 MD3...")
		g_bBooleans[bMD3] = true
		g_bBooleans[g_HasMd3] = true
	}

	set_task(3.0, "SetMode", 0)
	
	g_iVote[vMD3][0] = g_iVote[vMD3][1] = 0
}

public client_putinserver(id)
{
	get_user_name(id, g_dUserData[id][szName], charsmax(g_dUserData[]))
	get_user_authid(id, g_iPlayerSteam[id], charsmax(g_iPlayerSteam[]))
	g_dUserData[id][g_iTimeDonated] = 0
}

public CheckMiado()
{
	if(g_bBooleans[iLive] || g_bBooleans[iOvT])
	{
		new iPlayers[MAX_PLAYERS], iNum[CsTeams],Miado = get_pcvar_num(VarMiado)
		get_players_ex(iPlayers, iNum[CS_TEAM_CT], GetPlayers_ExcludeHLTV | GetPlayers_MatchTeam, "CT")
		get_players_ex(iPlayers, iNum[CS_TEAM_T], GetPlayers_ExcludeHLTV | GetPlayers_MatchTeam, "TERRORIST")
		
		if(iNum[CS_TEAM_T] > Miado && iNum[CS_TEAM_CT] > Miado)
			remove_task(TASK_MIADO)
			
		else if(iNum[CS_TEAM_T] <= Miado || iNum[CS_TEAM_CT] <= Miado)
		{
			if(!task_exists(TASK_MIADO))
			{
				g_Time = get_gametime() + get_pcvar_float(VarCountDown)
       
				CountDownRestore()
				set_task(0.5,"CountDownRestore",TASK_MIADO, .flags="b")
			}
		}
	}
}

public client_disconnected(id)
{	
	setTag(id, 1)
	ClearMuteList(id)
	removeMoneySprite(id)
	gAfkTime[id] = 0
	remove_task(id + TASK_CHECKREADY)
	remove_task(id + TASK_SHOWMONEY)

	new iPlayersNum = get_playersnum()
	new LiveBan = get_pcvar_num(VarBanLive)
	new Float:TimeToRestart = get_gametime()

	donateReceiver[id] = 0;

	if(get_pcvar_num(VarReset) && iPlayersNum <= 0 && (TimeToRestart - gametime) >= 10.0)
		set_task(1.0, "checkRestart")
	
	if(g_bBooleans[iEagle])
	{
		if(isAdmin(id))
		{
			set_task(2.0 , "RestorePug", 1)
		}
		else if(g_dUserData[id][bIsSelected])
		{
			g_bBooleans[(g_CurTeam[id] == CS_TEAM_T) ? bPlayerTRSelected : bPlayerCTSelected] = false
			g_dUserData[id][bIsSelected] = false
					
			client_print_color(0, RED, "Jogador selecionado^x04 %s^x01 se desconectou.", g_dUserData[id][szName])
			client_print_color(0, RED, "Admin%s, de allspec e selecione outro.", (getAdminsNum() > 1) ? "s": "")
		}
	}
	if(get_pcvar_num(VarEagleAkc))
	{
		set_task(2.0 , "RestorePug", 2)
	}
	
	if(g_bBooleans[iLive] || g_bBooleans[iOvT])
	{
		if(g_CurTeam[id] == CS_TEAM_T || g_CurTeam[id] == CS_TEAM_CT)
		{       
			if(iPlayersNum <= 7)
			{
				set_task(1.0,"CheckMiado", .flags = "b")
			}
				
			new Leaver = get_pcvar_num(VarLeaver)
			switch(Leaver)
			{
				case 1:
				{
					client_print_color(0, RED, "%s^x01 se desconectou no ^x04live^x01 e sua saida ficou registrada!", g_dUserData[id][szName])
					log_to_file(BANLEAVER, "[PUGMOD] [Nick: %s] [Steam: %s] se desconectou no live e sua saida ficou registrada!", g_dUserData[id][szName], g_iPlayerSteam[id])
				}
				case 2:
				{
					client_print_color(0, RED, "%s^x01 se desconectou no ^x04live^x01 e foi banido por^x04 %d minuto%s!", g_dUserData[id][szName],LiveBan, (LiveBan > 1) ? "s": "")
					log_to_file(BANLEAVER, "[PUGMOD] [Nick: %s] [Steam: %s] se desconectou no live e foi banido!", g_dUserData[id][szName], g_iPlayerSteam[id])
					server_cmd("amx_ban ^"%s^"^"%d^"^"Miou no Live^"",g_iPlayerSteam[id], LiveBan)
				}
				default: return PLUGIN_HANDLED

			}
		}
	}
		
	if(iPlayersNum <= get_pcvar_num(VarChangeMap))
	{	
		if(g_bBooleans[iLive] || g_bBooleans[iOvT])
		{
			new szMap[9]
			get_mapname( szMap , charsmax(szMap))
			if(equali(szMap,"de_dust2"))
			{
				client_print_color(0, RED, "Numero de jogadores insuficientes, configurando o servidor para o^x04 4FUN.")
				set_task(1.5, "SetMode", 3)
			}
			if(!equali(szMap,"de_dust2"))
			{
				client_print_color(0, RED, "Numero de jogadores insuficientes, trocando mapa para^x04 de_dust2.")
				set_task(3.0, "changeToD2")
			}
		}
		else if(g_bBooleans[iFun] && (TimeToRestart - gametime) >= 10.0)
		{
			new szMap[9]
			get_mapname( szMap , charsmax(szMap))
			if(!equali(szMap,"de_dust2"))
			{
				client_print_color(0, RED, "Numero de jogadores insuficientes, trocando mapa para^x04 de_dust2.")
				set_task(3.0, "changeToD2")
			}
		}
	}
	
	if(g_bBooleans[iFun])
	{
		if(g_dUserData[id][bIsReady])
		{
			g_dUserData[id][bIsReady] = false
			g_dUserData[id][bFirstSpawn] = false
		
			new iPlayersNeeded = (get_pcvar_num(VarMini) - getReadyNum())
		
			client_print_color(0, RED, "%s^x01 saiu.^x04 %d jogador%s^x01 pronto%s, falta%s^x04 %d para o inicio do^x04 mix!", g_dUserData[id][szName], getReadyNum(), (iPlayersNeeded >= 2) ? "es": "", (iPlayersNeeded >= 2) ? "s": "", (iPlayersNeeded >= 2) ? "m": "",iPlayersNeeded)
		}
		if(isAdmin(id))
		{
			set_task(2.0 , "RestorePug", 3)
		}
	}
	if(g_bBooleans[iDisabled])
	{
		if(isAdmin(id))
		{
			set_task(2.0 , "RestorePug", 3)
		}
	}

	return PLUGIN_CONTINUE
}

public RestorePug(iCase)
{
	switch(iCase)
	{
		case 1:
		{
			client_print_color(0,RED,"O admin se desconectou, cancelando tiracao de times e iniciando 4fun...")
			set_task(2.0, "SetMode", 3)
		}
		case 2:
		{
			if(getAdminsNum() <= 0)
			{
				client_print_color(0,RED,"O admin se^x04 desconectou^x01, retornando para o aquecimento^x04 all armas.")
				set_task(2.0, "SetMode", 3)
			}
		}
		case 3:
		{
			if(getAdminsNum() <= 0)
			{
				if(get_pcvar_num(VarDisable))
				{
					set_pcvar_num(VarDisable,0)
					set_task(1.0, "SetMode", 3)
							
					CC_SendMatched(0,RED,"Nenhum ADM online ativando o^x04 pug...")
				}

				if(get_pcvar_num(VarLockReady) == 1)
				{
					set_pcvar_num(VarLockReady, 0)
					restartRound(1)
					
				}

				new szMap[9]
				get_mapname( szMap , charsmax(szMap))
				if(!equali(szMap,"de_dust2") && get_playersnum() <= 0)
				{
					client_print_color(0, RED, "Numero de jogadores insuficientes, trocando mapa para^x04 de_dust2.")
					set_task(3.0, "changeToD2")
				}
			}
		}
	}
}

ClearMuteList(id)
{
	new iPlayers[MAX_PLAYERS], iNum
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots | GetPlayers_MatchTeam, (g_CurTeam[id] == CS_TEAM_T) ? "TERRORIST" : "CT")
	for(new i, iPlayer;i < iNum;i++)
	{
		iPlayer = iPlayers[i]

		if(g_CurTeam[id] == CS_TEAM_T || g_CurTeam[id] == CS_TEAM_CT && g_bPlayerMuted[id][iPlayer])
		{
			g_bPlayerMuted[id][iPlayer] = false
		}
	}
}

public checkRestart()
{
	new currentdate[12], lastrestarted[12]
	get_time("%d/%m/%Y",currentdate,11)

	if (!vaultdata_exists("lastrestarted")) 
		set_vaultdata("lastrestarted",currentdate)

	get_vaultdata("lastrestarted",lastrestarted,11)
	
	if (!equal(currentdate,lastrestarted)) 
	{
		new iNum = get_playersnum( )
    
		if(iNum == 0)
		{
			set_vaultdata("lastrestarted",currentdate)
			log_to_file(LOGFILE, "Reiniciando o servidor (Ultimo Restart: %s)",lastrestarted)
			server_print("no_amxx_uncompress")
			server_cmd("exit") 
		}
	}
}
	
public chamarTime()
{
	new iPlayers[MAX_PLAYERS], iNum[CsTeams], iMaxPlayers = get_pcvar_num(VarMini), iPlrLmt = get_pcvar_num(VarPlr)
	get_players_ex(iPlayers, iNum[CS_TEAM_CT], GetPlayers_ExcludeHLTV | GetPlayers_MatchTeam, "CT")
	get_players_ex(iPlayers, iNum[CS_TEAM_T], GetPlayers_ExcludeHLTV | GetPlayers_MatchTeam, "TERRORIST")

	if((iNum[CS_TEAM_T] + iNum[CS_TEAM_CT]) >= iMaxPlayers)
	{
		g_iNums[iChamarTR] = g_iNums[iChamarCT] = 0
		return
	}
		
	new iNeeded, iChamados = get_pcvar_num(VarChamados), iRandomSpec, iSpecNum, id
	get_players_ex(iPlayers, iNum[CS_TEAM_SPECTATOR], GetPlayers_ExcludeHLTV | GetPlayers_MatchTeam, "SPECTATOR")
	
	if(iNum[CS_TEAM_T] < iPlrLmt)
	{
		iNeeded = (iPlrLmt - iNum[CS_TEAM_T])

		new LetsGo = get_pcvar_num(VarLetsGo)

		for(new i; i < iNum[CS_TEAM_SPECTATOR];i++)
		{
			iSpecNum++
			if (!LetsGo)
				continue;

			id = iPlayers[i]
		
			if(!isTeam(id))
			{
				client_cmd(id, "spk scientist/letsgo")
				CC_SendMatched(id, RED, "Time^x03 TR^x01 precisando de^x04 %d^x01 jogador%s.", iNeeded, (iNeeded > 1) ? "es": "")
			}
		}

		if(++g_iNums[iChamarTR] >= iChamados)
		{
			if(!iSpecNum)
				return
				
			if(iSpecNum >= 1)
			{
				iRandomSpec = getRandomSpec()
				
				if(isAdmin(iRandomSpec) && !get_pcvar_num(VarAdminKick))
				{
					return
				}
				server_cmd("kick #%i", get_user_userid(iRandomSpec))
				CC_SendMatched(0, RED, "%s^x01 foi kickado por nao entrar nos^x04 Terroristas.", g_dUserData[iRandomSpec][szName])
			}
			g_iNums[iChamarTR] = 0
		}
	}

	if(iNum[CS_TEAM_CT] < iPlrLmt)
	{
		iNeeded = (iPlrLmt - iNum[CS_TEAM_CT])

		for(new i; i < iNum[CS_TEAM_SPECTATOR];i++)
		{
			iSpecNum++
			
			id = iPlayers[i]
		
			if(!isTeam(id))
			{
				client_cmd(id, "spk scientist/letsgo")
				CC_SendMatched(id, BLUE, "Time^x03 CT^x01 precisando de^x04 %d^x01 jogador%s.", iNeeded, (iNeeded > 1) ? "es": "")
			}
		}

		if(++g_iNums[iChamarCT] >= iChamados)
		{
			if(!iSpecNum)
				return
				
			if(iSpecNum >= 1)
			{
				iRandomSpec = getRandomSpec()
				
				if(isAdmin(iRandomSpec) && !get_pcvar_num(VarAdminKick))
				{
					return
				}
				server_cmd("kick #%i", get_user_userid(iRandomSpec))
				CC_SendMatched(0, RED, "%s^x01 foi kickado por nao entrar nos^x04 Contra-Terroristas.", g_dUserData[iRandomSpec][szName])
			}
			g_iNums[iChamarCT] = 0
		}
	}
}

getRandomSpec()
{
	new iPlayers[MAX_PLAYERS], iNum, iSpec[MAX_PLAYERS + 1], iSpecNum, id
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
	for(new i; i < iNum;i++)
	{
		id = iPlayers[i]
		
		if(g_CurTeam[id] >= CS_TEAM_SPECTATOR)
		{
			iSpec[++iSpecNum] = id
		}
	}
	
	return iSpec[random_num(1, iSpecNum)]
}

public changeToD2() 
	server_cmd("changelevel de_dust2")

public bomb_planted()
{
	server_cmd("mp_friendlyfire 0")
}

public PugRespawn(id)
{
	if(!is_user_connected(id) || is_user_alive(id))
		return

	if(!isTeam(id))
	{
		g_dUserData[id][bIsReady] = false
		g_dUserData[id][bFirstSpawn] = false
		setTag(id, 1)
		
		if(task_exists(id + TASK_CHECKREADY))
		{
			remove_task(id + TASK_CHECKREADY)
		}
		return
	}
		
	ExecuteHamB(Ham_CS_RoundRespawn, id)
		
	set_pev(id, pev_takedamage, DAMAGE_NO)
	set_task(2.0, "UnProtect", id)
}

public UnProtect(id) 
	if(is_user_connected(id)) 
		set_pev(id,pev_takedamage,DAMAGE_AIM)

public SetMode(iMode)
{
	switch(iMode)
	{
		case 0: // live
		{ 
			g_bBooleans[iFun] = false
			gPrimeiraVez4fun = false
			g_bBooleans[iLive] = true
			g_bBooleans[iEagle] = false
			g_bBooleans[iOvT] = false
			g_bBooleans[iKnife] = false
			g_bBooleans[g_bVoteRunning] = false
			g_bBooleans[bPlayerCTSelected] = false
			g_bBooleans[bPlayerTRSelected] = false
			g_bBooleans[g_Swapped] = false
			g_bBooleans[g_SurrenderOnMap] = false
			g_bBooleans[g_KnifeTrWinner] = false
			g_bBooleans[g_KnifeCtWinner] = false
			
			g_iNums[iRounds] = 1
			g_iNums[iTempo] = 1
			g_iNums[iOwnerID] = 0
			g_iNums[iOwnerIDHS] = 0
			g_iNums[iCaptainCT] = 0
			g_iNums[iCaptainTR] = 0
	
			PugRemoveC4(false)
			UnRegisterWarmCmds()
	
			if(!task_exists(1000))
			set_task(2.0, "chamarTime", 1000, .flags = "b") // live
			
			if(get_pcvar_num(VarFreezePlacar))
			{
				set_task(1.0,"Placar",3000, .flags = "b") // live
			}
			else
			{
				if(task_exists(3000))
				{
					remove_task(3000)
					set_task(1.0,"Placar",3000 ,.flags = "a", .repeat = get_pcvar_num(g_bBooleans[g_Freezetime]))
				}
				else 
					set_task(1.0,"Placar",3000 ,.flags = "a", .repeat = get_pcvar_num(g_bBooleans[g_Freezetime]))
			}

			if(!task_exists(5000))
				set_task(5.0,"CheckPlayers",5000, .flags = "b") // live
				
			if(task_exists(6000))
				remove_task(6000) // 4fun

			if(task_exists(12000))
				remove_task(12000)
				
			if(task_exists(8000))
				remove_task(8000)
			
			if(task_exists(9000))
				remove_task(9000)
				
			set_pcvar_num(VarSay,0)
			set_pcvar_num(VarLockReady,1)
			set_pcvar_num(VarLockBombs,0)
			set_pcvar_num(VarEagleAkc, 0)

			removeAllRdy()
			
			if(!g_bBooleans[bMD3])
			{
				set_task(3.0, "liveMessage")
				g_iNums[iRRs] = -1
			}
			else set_task(3.0, "threeRRs")
			
			restartRound(1)
		}
		case 1:// Eagle
		{
			g_bBooleans[iFun] = false
			gPrimeiraVez4fun = false
			g_bBooleans[iOvT] = false
			g_bBooleans[iLive] = false
			g_bBooleans[iEagle] = true
			g_bBooleans[iKnife] = false
			
			g_bBooleans[g_bVoteRunning] = false
			g_iNums[iTempo] = 1
			g_iNums[iRounds] = 1
			g_bBooleans[g_Swapped] = false
			
			
			if(task_exists(1000))
				remove_task(1000) // live
			
			if(get_pcvar_num(VarFreezePlacar))
			{
				set_task(1.0,"Placar",3000, .flags = "b") // live
			}
			else
			{
				if(task_exists(3000))
				{
					remove_task(3000)
					set_task(1.0,"Placar",3000 ,.flags = "a", .repeat = get_pcvar_num(g_bBooleans[g_Freezetime]))
				}
				else 
					set_task(1.0,"Placar",3000 ,.flags = "a", .repeat = get_pcvar_num(g_bBooleans[g_Freezetime]))
			}

			if(task_exists(4000))
				remove_task(4000) // live e OVT
				
			if(task_exists(5000))
				remove_task(5000) // live
				
			if(task_exists(6000))
				remove_task(6000) // 4fun
				
			if(task_exists(8000))
				remove_task(8000)

			if(task_exists(12000))
				remove_task(12000)
		
			PugRemoveC4(true)
			set_pcvar_num(VarSay,0)
			set_pcvar_num(VarLockReady,1)
			set_pcvar_num(VarLockBombs,1)
			gPrimeiraVez4fun = true
			
			restartRound(1)
			
		}
		case 2:// OverTime
		{
			g_bBooleans[iFun] = false
			gPrimeiraVez4fun = false
			g_bBooleans[iOvT] = true
			g_bBooleans[iLive] = true
			g_bBooleans[iEagle] = false
			g_bBooleans[iKnife] = false

			g_bBooleans[g_bVoteRunning] = false
			g_bBooleans[g_Swapped] = false
			g_iNums[iTempo] = 1
			g_iNums[iRounds] = 1
			g_iNums[iTRsPlacar] = 0
			g_iNums[iCTsPlacar] = 0
		
			if(!task_exists(1000))
			set_task(2.0, "chamarTime", 1000, .flags = "b") // live

			if(get_pcvar_num(VarFreezePlacar))
			{
				set_task(1.0,"Placar",3000, .flags = "b") // live
			}
			else
			{
				if(task_exists(3000))
				{
					remove_task(3000)
					set_task(1.0,"Placar",3000 ,.flags = "a", .repeat = get_pcvar_num(g_bBooleans[g_Freezetime]))
				}
				else 
					set_task(1.0,"Placar",3000 ,.flags = "a", .repeat = get_pcvar_num(g_bBooleans[g_Freezetime]))
			}
			
			if(!task_exists(5000))
				set_task(5.0,"CheckPlayers",5000, .flags = "b") // live
				
			if(task_exists(6000))
				remove_task(6000) // 4fun
				
			if(task_exists(8000))
				remove_task(8000)
			
			if(task_exists(9000))
				remove_task(9000)

			if(task_exists(12000))
				remove_task(12000)
			
			restartRound(1)
			set_pcvar_num(VarSay,0)
			set_pcvar_num(VarLockReady,1)
			set_pcvar_num(VarLockBombs,0)
			
			set_task(2.0,"OTSound")
		}
		case 3:// 4Fun
		{
			g_bBooleans[iFun] = true
			gPrimeiraVez4fun = true
			g_bBooleans[iKnife] = false
			g_bBooleans[iOvT] = false
			g_bBooleans[iLive] = false
			g_bBooleans[iEagle] = false
			g_bBooleans[bChat] = false
			g_bBooleans[g_bVoteRunning] = false
			g_bBooleans[g_Swapped] = false
			g_bBooleans[iDisabled] = false
			g_iNums[iTempo] = 0
			g_iNums[iCTsPlacar] = 0
			g_iNums[iTRsPlacar] = 0
			g_iNums[iCTsPlacarOT] = 0
			g_iNums[iTRsPlacarOT] = 0
			g_iNums[iRRs] = 0
			g_iNums[iRounds] = 0
			g_bBooleans[g_SurrenderOnMap] = false
			g_bBooleans[g_KnifeTrWinner] = false
			g_bBooleans[g_KnifeCtWinner] = false

			
			if(task_exists(1000))
				remove_task(1000) // live
			
			if(task_exists(11000))
				remove_task(11000) // live
				
			if(task_exists(3000))
				remove_task(3000)
				
			if(!task_exists(4000))
				remove_task(4000) // live e OVT
				
			if(task_exists(5000))
				remove_task(5000) // live
				
			if(task_exists(8000))
				remove_task(8000)
				
			if(task_exists(9000))
				remove_task(9000)
				
			// if(!task_exists(6000))
				// set_task(1.0,"Contador",6000, .flags = "b")

			if(!task_exists(12000))
				set_task(300.0, "infoMessage",12000, .flags = "b")
		
			RegisterWarmCmds()
			GameDesc()
			
			new iPlayers[MAX_PLAYERS], iNum, id
			get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
			for(new i; i < iNum;i++)
			{
				id = iPlayers[i]
				
				g_dUserData[id][bSurrender] = false
				g_dUserData[id][bFirstSpawn] = false
			}
			
			set_pcvar_num(VarSay,0)
			set_pcvar_num(VarLockReady,0)
			set_pcvar_num(VarLockBombs,1)
			set_pcvar_num(VarEagleAkc, 0)
			set_pcvar_num(VarDisable, 0)
			PugRemoveC4(true)
			removeMoneySprites()
			CC_SendMatched(0,RED," --^x04 4FUN Config ativada no servidor^x01 --")
			gPrimeiraVez4fun = true
				
			restartRound(1)
			
			set_task(4.0,"removeAllRdy")
			
		}
		case 4:// knife
		{
			g_bBooleans[iFun] = false
			gPrimeiraVez4fun = false
			g_bBooleans[iKnife] = true
			g_bBooleans[iOvT] = false
			g_bBooleans[iLive] = false
			g_bBooleans[iEagle] = false
			g_bBooleans[bChat] = false
			g_bBooleans[g_bVoteRunning] = false
			g_bBooleans[g_Swapped] = false
			g_iNums[iTempo] = 1
			g_iNums[iRounds] = 1
			g_iNums[iOwnerID] = 0
			g_iNums[iOwnerIDHS] = 0
			g_iNums[iCaptainCT] = 0
			g_iNums[iCaptainTR] = 0
			g_bBooleans[g_SurrenderOnMap] = false
			g_bBooleans[g_KnifeTrWinner] = false
			g_bBooleans[g_KnifeCtWinner] = false
			
			if(!task_exists(5000))
			set_task(5.0,"CheckPlayers",5000, .flags = "b") // live

			if(task_exists(12000))
				remove_task(12000)
			
			set_pcvar_num(VarSay,0)
			set_pcvar_num(VarLockReady,1)
			set_pcvar_num(VarLockBombs,1)
			set_pcvar_num(VarEagleAkc, 0)
			PugRemoveC4(true)		
				
			restartRound(3)
			
			set_task(4.0,"removeAllRdy")
		}
	}
	
	set_member_game(m_bGameStarted, true)
	client_cmd(0, "speak deeoo")
	execCfg(iMode)
}

public OTSound()
	client_cmd(0, "spk ^"doop.over time^"")

public threeRRs()
{
	g_iNums[iRRs] = 2;

	restartRound( 3 );

	// static Float:fTime
	// if(!fTime)
	// 	fTime = 1.0
		
	// switch(g_iNums[iRRs])
	// {
	// 	case 0:	
	// 	{
	// 		g_iNums[iRRs]++
	// 	}
	// 	case 1:	
	// 	{
	// 		g_iNums[iRRs]++
	// 		fTime = 3.0
	// 	}
	// 	case 2:
	// 	{
	// 		g_iNums[iRRs] = -1
	// 		fTime = 1.0
			
	// 		removeAllRdy()
	// 		set_task(3.0, "liveMessage")
	// 	}
	// }
	
	// if(g_iNums[iRRs] >= 0)
	// {
	// 	set_task(fTime, "threeRRs")
	// 	restartRound(floatround(fTime))
	// 	
					
	// }
}

public liveMessage()
{
	set_hudmessage(random(256), random(256), random(256), -1.0, 0.3, 0, 1.0, 5.0)
	ShowSyncHudMsg(0, g_hHuds[hLiveMessage], "A PARTIDA COMECOU, BOA SORTE!")
}

public PUG_AdminMenu(id)
{
	if(isAdmin(id))
	{
		static szMenu[50], szItem[32]
		formatex(szMenu, charsmax(szMenu), "\y[\w%s \rADMIN MENU \y]", Pug_MenuPrefix)
		new iMenu = menu_create(szMenu, "PUG_AdminMenuHandler")
		
		formatex(szItem, charsmax(szItem),"Iniciar PUG")
		menu_additem(iMenu, szItem)
		formatex(szItem, charsmax(szItem),"Carregar Modo 4FUN")
		menu_additem(iMenu, szItem)
		formatex(szItem, charsmax(szItem),"Reiniciar Round")
		menu_additem(iMenu, szItem)
		formatex(szItem, charsmax(szItem),"Mover para Spectator")
		menu_additem(iMenu, szItem)
		formatex(szItem, charsmax(szItem),"Iniciar Votemap")
		menu_additem(iMenu, szItem)
		formatex(szItem, charsmax(szItem),"Iniciar Round Faca \r[CF]")
		menu_additem(iMenu, szItem)
		
		formatex(szItem, charsmax(szItem),"Say %s%s",g_bBooleans[bChat] ? "\y": "\r", g_bBooleans[bChat] ? "[ON]": "[OFF]")
		menu_additem(iMenu, szItem)
		
		formatex(szItem, charsmax(szItem), "Ready %s%s", get_pcvar_num(VarLockReady) ? "\y": "\r", get_pcvar_num(VarLockReady) ? "[ON]": "[OFF]")
		menu_additem(iMenu, szItem)
		
		formatex(szItem, charsmax(szItem), "Bombs %s%s", get_pcvar_num(VarLockBombs) ? "\y": "\r", get_pcvar_num(VarLockBombs) ? "[ON]": "[OFF]")
		menu_additem(iMenu, szItem)
		
		formatex(szItem, charsmax(szItem), "Mostrar HP %s%s", get_pcvar_num(VarShowHP) ? "\r": "\y", get_pcvar_num(VarShowHP) ? "[OFF]": "[ON]")
		menu_additem(iMenu, szItem)
		
		formatex(szItem, charsmax(szItem), "Pre-Game So Eagle %s%s", get_pcvar_num(VarEagleAkc) ? "\r": "\y", get_pcvar_num(VarEagleAkc) ? "[OFF]": "[ON]")
		menu_additem(iMenu, szItem)
		
		formatex(szItem, charsmax(szItem), "Morto falar com vivo %s%s", get_pcvar_num(VarDeadMic) ? "\r": "\y", get_pcvar_num(VarDeadMic) ? "[OFF]": "[ON]")
		menu_additem(iMenu, szItem)

		formatex(szItem, charsmax(szItem), "Desligar o pug %s%s", get_pcvar_num(VarDisable) ? "\y": "\r", get_pcvar_num(VarDisable) ? "[ON]": "[OFF]")
		menu_additem(iMenu, szItem)
		
		formatex(szItem, charsmax(szItem),"Mudar map")
		menu_additem(iMenu, szItem)
		
		menu_display(id, iMenu)
	}
	else
	{
		CC_SendMatched(id,RED,"Você nao tem acesso a este comando.")
		InvalidSound(id)
	}
	
	return PLUGIN_HANDLED
}

public PUG_AdminMenuHandler(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenu)
		return
	}
	
	switch(iItem)
	{
		case 0:
		{
			if(task_exists(13000))
			{
				CC_SendMatched(0, RED,"Ja tem uma votacao em andamento.")
				InvalidSound(id)
				return 		
			}
			if(!g_bBooleans[iLive] || !g_bBooleans[iOvT])
			{
				if((get_pcvar_num(VarDebug) || !needPlayers(id)) && !g_bBooleans[g_bVoteRunning])
				{	
					if (get_pcvar_num(VarRandomize))
					{
						set_task(3.0,"RandomizeVote")
						CC_SendMatched(0, RED,"O admin ^x04%s^x01 iniciou a votacao para habilitar o^x04 Randomize!", g_dUserData[id][szName])
					}
					else if(get_pcvar_num(VarFFVote))
					{
						set_pcvar_num(VarLockReady,1)
						removeAllRdy()
						set_pcvar_num(VarEagleAkc, 0)
						set_task(2.0,"FFVotacao")
						CC_SendMatched(0, RED,"O admin ^x04%s^x01 iniciou a votacao para habilitar o^x04 TK!", g_dUserData[id][szName])
					}
					else if(get_pcvar_num(VarVoteMd3))
					{	// alex edi��o
						set_task(2.0,"MD3Votacao")
						CC_SendMatched(0, RED,"O admin ^x04%s^x01 iniciou a votacao para^x04 Live ou MD3!", g_dUserData[id][szName])	
						
					}
					else
					 {	
						// alex edi��o
						g_bBooleans[bMD3] = false
						set_task(3.0, "SetMode", 0)
						
						set_pcvar_num(VarLockReady,1)
						set_pcvar_num(VarEagleAkc, 0)	
						removeAllRdy()
						CC_SendMatched(0, RED,"O admin ^x04%s^x01 Iniciando ^x04Live.",g_dUserData[id][szName])

						
					}
				}
				else
				{			
					CC_SendMatched(0, RED,"Ja tem uma votacao em andamento, ou faltam jogadores.")
					InvalidSound(id)
				
				}
			}
			else
			{
				CC_SendMatched(0, RED,"Ja esta live você nao pode usar esse comando.")
				InvalidSound(id)
			}
		}
		case 1:
		{
			if(!g_bBooleans[iFun])
			{
				set_task(1.0, "SetMode", 3)
				
			
				CC_SendMatched(0,RED,"O admin ^x03%s^x01 executou o^x04 4fun.",g_dUserData[id][szName])
			}
			else
			{
				CC_SendMatched(id,RED,"Ja estamos em 4fun, utilize o^x04 rr!")
				InvalidSound(id)
				return
			}
		}
		case 2:	
		{
			restartRound(1, id)
			CC_SendMatched(0,RED,"O admin ^x03%s^x01 ^x04Restartou o round.",g_dUserData[id][szName])
		}
		case 3:
		{
			if(g_bBooleans[iLive] || g_bBooleans[iOvT])
			{
				CC_SendMatched(id, RED, "O pug esta^x04 LIVE,^x03 opcao bloqueada.")
				InvalidSound(id)
				return
			}

			if(!needPlayers(id) && !g_bBooleans[g_bVoteRunning])
			{
				allSpec()
				restartRound(1)
				
				g_bBooleans[iEagle] = true

				set_task(3.0, "selectPlayers", id + TASK_SELECTPLAYERS)
				CC_SendMatched(0, TEAM_COLOR, "Admin^x04 %s^x01 mandou todos para^x04 spec.", g_dUserData[id][szName])
			}
		}
		case 4:
		{
			if(g_bBooleans[iLive] || g_bBooleans[iOvT])
			{
				CC_SendMatched(id, RED, "O pug esta^x04 LIVE,^x03 opcao bloqueada.")
				InvalidSound(id)
				return
			}
			set_task(1.0, "showVotemapHud", .flags = "a", .repeat = 3)
			set_task(4.0,"voteNextMap")
		}
		case 5:
		{
			if(!needPlayers(id))
			{
				if(g_bBooleans[iLive] || g_bBooleans[iOvT])
				{
					CC_SendMatched(id, RED, "O pug esta^x04 LIVE,^x03 opcao bloqueada.")
					InvalidSound(id)
					return
				}
				CC_SendMatched(0, RED,"Iniciando o round^x04 faca!")
				set_task(2.0, "SetMode", 4)
				removeAllRdy()
			}
		}
		case 6:
		{	
			g_bBooleans[bChat] = g_bBooleans[bChat] ? false : true
		
			CC_SendMatched(0, TEAM_COLOR, "Admin^x04 %s^x01 %sativou o^x04 say", g_dUserData[id][szName], g_bBooleans[bChat] ? "des": "")
			client_cmd(0, "speak fvox/%s", g_bBooleans[bChat] ? "deactivated": "activated")
		}
		case 7:
		{
			if(g_bBooleans[iFun])
			{
				if(get_pcvar_num(VarLockReady) == 1)
				{
					set_pcvar_num(VarLockReady,0)
					new iPlayers[MAX_PLAYERS], iNum, id
					get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
					for(new i; i < iNum;i++)
					{
						id = iPlayers[i]
						g_dUserData[id][bFirstSpawn] = false
					}
					restartRound(1)
					
				}
				else
				{
					set_pcvar_num(VarLockReady,1)
					new iPlayers[MAX_PLAYERS], iNum, id
					get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
					for(new i; i < iNum;i++)
					{
						id = iPlayers[i]
						g_dUserData[id][bFirstSpawn] = true
					}
					removeAllRdy()	
				}
				
				CC_SendMatched(0,RED,"O admin ^x03%s^x01 %sativou o^x04 ready.",g_dUserData[id][szName], get_pcvar_num(VarLockReady) == 0 ? "": "des")
				client_cmd(0,"speak buttons/blip2")
				
				PUG_AdminMenu(id)
			}
			else
			{
				
				CC_SendMatched(id, TEAM_COLOR, "Você so pode alterar o ready no^x04 aquecimento!")
				client_cmd(id,"spk buttons/blip2")
			}
		}
		case 8:
		{
			if(g_bBooleans[iFun])
			{
				
				if(get_pcvar_num(VarLockBombs) == 1)
					set_pcvar_num(VarLockBombs,0)
				
				else
					set_pcvar_num(VarLockBombs,1)
				
				
				CC_SendMatched(0,RED,"O admin ^3%s ^4^1 %sativou as^x04 bombas.",g_dUserData[id][szName], get_pcvar_num(VarLockBombs) == 0 ? "": "des")
				client_cmd(0,"speak buttons/blip2")
			}
			else
			{
				CC_SendMatched(id,GREEN,"Você nao pode restringir as bombas no^x03 live.")
				client_cmd(0,"speak buttons/blip2")
			}
		}
		case 9:
		{
			if(g_bBooleans[iLive] || g_bBooleans[iOvT])
			{
				
				if(get_pcvar_num(VarShowHP) == 1)
					set_pcvar_num(VarShowHP,0)
					
				else				
					set_pcvar_num(VarShowHP,1)
				
				CC_SendMatched(0,RED,"O admin ^3%s ^4^1 %sativou a informacao de ^x04HP no LIVE.",g_dUserData[id][szName], get_pcvar_num(VarShowHP) == 1 ? "": "des")
				client_cmd(0,"speak buttons/blip2")
			}
			else
			{
				CC_SendMatched(id,GREEN,"Você nao pode restringir o HP no^x03 4fun.")
				client_cmd(0,"speak buttons/blip2")
			}
		}
		case 10:
		{
			if(g_bBooleans[iFun])
			{
				
				if(get_pcvar_num(VarEagleAkc) == 1)
					set_pcvar_num(VarEagleAkc,0)

				else
					set_pcvar_num(VarEagleAkc,1)
				
				CC_SendMatched(0,RED,"O admin ^3%s ^4^1 %sativou o ^x04Pre-game so eagle",g_dUserData[id][szName], get_pcvar_num(VarEagleAkc) == 1 ? "": "des")
				client_cmd(0,"speak buttons/blip2")
				restartRound(1)
				
			}
			else
			{
				CC_SendMatched(id,GREEN,"Você nao pode habilitar o so eagle no^x03 live.")
				client_cmd(0,"speak buttons/blip2")
			}
		}
		case 11:
		{
			if(g_bBooleans[iLive] || g_bBooleans[iOvT])
			{
				
				if(get_pcvar_num(VarDeadMic) == 1)
					set_pcvar_num(VarDeadMic,0)
					
				else
					set_pcvar_num(VarDeadMic,1)
				
				CC_SendMatched(0,RED,"O admin ^3%s ^4^1%sativou o^x04 Morto falar com vivo.",g_dUserData[id][szName], get_pcvar_num(VarDeadMic) == 1 ? "": "des")
				client_cmd(0,"speak buttons/blip2")
			}
			else
			{
				CC_SendMatched(id,GREEN,"Você nao pode habilitar morto falar com vivo no ^x03 4fun.")
				client_cmd(0,"speak buttons/blip2")
			}
		}
		case 12:
		{
			if(get_pcvar_num(VarDisable))
			{
				set_pcvar_num(VarDisable,0)
				set_task(1.0, "SetMode", 3)
				g_bBooleans[iDisabled] = false
				
				CC_SendMatched(0,RED,"O admin ^x03%s^x01 executou o^x04 4fun.",g_dUserData[id][szName])
				restartRound(1)
				
			}	
			else
			{
				set_pcvar_num(VarDisable,1)
				g_bBooleans[iDisabled] = true

				if(task_exists(1000))
					remove_task(1000)
			
				if(task_exists(11000))
					remove_task(11000)
						
				if(task_exists(3000))
					remove_task(3000)
						
				if(!task_exists(4000))
					remove_task(4000)
						
				if(task_exists(5000))
					remove_task(5000)
						
				if(task_exists(8000))
					remove_task(8000)
						
				if(task_exists(9000))
					remove_task(9000)
						
				if(task_exists(6000))
					remove_task(6000)

				if(task_exists(7000))
					remove_task(7000)

				if(task_exists(12000))
					remove_task(12000)

				DisableHamForward(g_iSetModel)
				if(g_iMsgMoney)
					unregister_message(gMsgMoney,g_iMsgMoney)
					
				PugRemoveC4(false)
				removeAllRdy()

				restartRound(1)
		
				
				CC_SendMatched(0,RED,"O admin ^3%s ^4^1%sativou o^x04 pug.",g_dUserData[id][szName], get_pcvar_num(VarDisable) ? "des": "")
				client_cmd(0,"speak buttons/blip2")
			}

			PUG_AdminMenu(id)
		}
		case 13:
		{
			client_cmd(id, "amx_mapmenu")
		}
	}
	menu_destroy(iMenu)
}

public selectPlayers(TaskId)
{
	new id = TaskId - TASK_SELECTPLAYERS

	new szTittle[65]
	formatex(szTittle, charsmax(szTittle), "\y[\w%s - \rEscolha um jogador: \y]", Pug_MenuPrefix)
	new iMenu = menu_create(szTittle, "select_players_handler")

	new iPlayers[MAX_PLAYERS],iNum
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
	for(new i, iPlayer; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if(!isTeam(iPlayer))
		{
			menu_additem(iMenu, g_dUserData[iPlayer][szName])
		}
	}
	menu_display(id, iMenu)
	return PLUGIN_HANDLED
}

public select_players_handler(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenu)
		set_task(0.3, "selectPlayers", id + TASK_SELECTPLAYERS)
		return
	}

	new  szData[6], szItemName[64]
	new _access, item_callback
	menu_item_getinfo(iMenu, iItem, _access, szData,charsmax(szData), szItemName, charsmax(szItemName), item_callback)
	
	new iTarget = find_player("a", szItemName)
	if(!iTarget)
	{
		set_task(0.3, "selectPlayers", id + TASK_SELECTPLAYERS)
		CC_SendMatched(id, RED,"Este jogador nao esta mais no servidor, selecione outro!")
		InvalidSound(id)
		return
	}	

	g_dUserData[iTarget][bIsSelected] = true

	if(!g_bBooleans[bPlayerTRSelected])
	{
		g_bBooleans[bPlayerTRSelected] = true
		g_iNums[iCaptainTR] = iTarget

		setUserJoin(iTarget, "1")

		CC_SendMatched(0, RED,"Admin^x04 %s^x01 selecionou o^x04 %s^x01 para tirar nos^x03 Terroristas.", g_dUserData[id][szName], g_dUserData[iTarget][szName])	
		checkSelect(id)
		return
	}

	if(!g_bBooleans[bPlayerCTSelected])
	{
		g_bBooleans[bPlayerCTSelected] = true
		g_iNums[iCaptainCT] = iTarget

		setUserJoin(iTarget, "2")

		CC_SendMatched(0, BLUE,"Admin^x04 %s^x01 selecionou o^x04 %s^x01 para tirar nos^x03 Contra-Terroristas.", g_dUserData[id][szName], g_dUserData[iTarget][szName])	
		checkSelect(id)
	}
}

checkSelect(id)
{
	if(g_bBooleans[bPlayerCTSelected] && g_bBooleans[bPlayerTRSelected])
	{
		CC_SendMatched(0, RED,"Jogadores selecionados, iniciando o^x04 Round Deagle.")
		set_task(2.0, "SetMode", 1)
		showNames()
		
	}
	else
	{
		set_task(1.3, "selectPlayers", id + TASK_SELECTPLAYERS)
	}
}

setUserJoin(id, szTeam[2])
{
	engclient_cmd(id, "jointeam", szTeam)
	engclient_cmd(id, "joinclass", "5")
}

public showAce()
{	
	set_hudmessage(220, 80, 0, -1.0, 0.33, 0, 0.1, 4.0)
	ShowSyncHudMsg(0, g_hHuds[hHudAce], "============= ACE =============^n%s matou toda a equipe dos %s^n============= ACE =============", g_dUserData[g_iNums[iOwnerID]][szName], (g_CurTeam[g_iNums[iOwnerID]] == CS_TEAM_T) ? "CTs": "TRs")
	
	message_begin(MSG_ALL, g_mMessageScreenShake)
	write_short(255 << 15)
	write_short(255 << 15)
	write_short(255 << 15)
	message_end()
	
	client_cmd(0, "spk %s",g_szAceSounds[random_num(0,2)])
	
	g_iNums[iOwnerID] = 0
}


public HudSpec()
{
	set_hudmessage(0, 255, 0, -1.0, -1.0, 0, 6.0, 5.0)
	show_hudmessage(0, "[ ALL SPEC ]")
	CC_SendMatched(0, RED,"Todos para spectador. O mix vai iniciar.")
}

public SwapTeams()
{
	new iPlayers[MAX_PLAYERS], iNum, id
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV)
	for(new i; i < iNum;i++)
	{
		id = iPlayers[i]
		
		if(isTeam(id))
		{
			cs_set_user_team(id, (cs_get_user_team(id) == CS_TEAM_T) ? CS_TEAM_CT : CS_TEAM_T)
			set_task(1.5, "DeadOnResp")
		}
	}
	
	if(!g_bBooleans[iOvT])
	{
		g_iNums[iTempo]++
		
		if(g_bBooleans[g_HasMd3])
		{
			if(g_iNums[iTempo] == 2)
			{
				if((g_iNums[iTRsPlacar] >= 11) || (g_iNums[iCTsPlacar] >= 11))
				{
					CC_SendMatched(0, RED, "O time^x04 %s^x01 fez mais de 11 pontos, iniciando o^x04 live.", (g_iNums[iSwapPlacar] >= 11) ? "contra-terrorista": "terrorista")
					new iScore = g_iNums[iCTsPlacar]
					g_iNums[iCTsPlacar] = g_iNums[iTRsPlacar]
					g_iNums[iTRsPlacar] = iScore
				}
				else
				{
					g_bBooleans[bMD3]= true
					CC_SendMatched(0, RED, "Nenhum time fez mais de^x04 11 pontos^x01, iniciando o^x04 md3.")
					g_iNums[iTRsPlacar] = 0
					g_iNums[iCTsPlacar] = 0
				}
			}
		}
		else if(!g_bBooleans[g_SwapFF])
		{	
			new iScore = g_iNums[iCTsPlacar]
			g_iNums[iCTsPlacar] = g_iNums[iTRsPlacar]
			g_iNums[iTRsPlacar] = iScore
			CC_SendMatched(0, TEAM_COLOR, "Nao teve^x04 md3^x01 no^x04 1 ^x01tempo, iniciando o^x04 live.")
		}
		
		if(g_bBooleans[g_SwapFF])
		{
			CC_SendMatched(0, RED, "O jogo comecou, boa sorte.")
			
			g_bBooleans[g_SwapFF] = false		
			g_iNums[iTempo]--
			g_iNums[iTRsPlacar] = 0
			g_iNums[iCTsPlacar] = 0
		}
	}
	else
	{

		if(g_iNums[iTempo] == 2)
		{
			g_iNums[iCTsPlacar] = (g_iNums[iTRsPlacar] + g_iNums[iTRsPlacarOT])
			g_iNums[iTRsPlacar] = (g_iNums[iCTsPlacar])
				
			g_iNums[iTempo] = 1
			g_iNums[iTRsPlacarOT] = g_iNums[iCTsPlacarOT] = 01
		}
		else
		{
			new iScore = g_iNums[iCTsPlacarOT]
			g_iNums[iCTsPlacarOT] = g_iNums[iTRsPlacarOT]
			g_iNums[iTRsPlacarOT] = iScore
				
			g_iNums[iTempo]++
		}
	}
	g_iNums[iRounds] = 1
	
	client_cmd(0, "speak transportation")
	
	restartRound(1)
}

public Contador()
{
	new szMessage[2][40]
	
	if(g_bBooleans[bReady])
	{
		if(getAdminsNum())
		{
			formatex(szMessage[0], charsmax(szMessage[]), "Administrador%s no servidor!", (getAdminsNum() > 1) ? "es": "")
		}

		if(getReadyNum())
		{
			formatex(szMessage[1], charsmax(szMessage[]), "%d Jogador%s pronto%s - digite .ready", getReadyNum(), (getReadyNum() > 1) ? "es": "", (getReadyNum() > 1) ? "s": "")
		}
		else
		{
			formatex(szMessage[1], charsmax(szMessage[]), "Nenhum jogador pronto - digite .ready")
		}
	}
	else
	{		
		if(getAdminsNum())
		{
			formatex(szMessage[1], charsmax(szMessage[]), "Administrador%s no servidor!", (getAdminsNum() > 1) ? "es": "")
		}	
	}
	
	set_hudmessage(random(256), random(256), random(256), 0.02, 0.85, 0, 1.0, 1.0)
	ShowSyncHudMsg(0, g_hHuds[hContador], "%s^n%s", szMessage[0], szMessage[1])
}

public Placar()
{	
	static szModo[20]
	get_pugmode(szModo, charsmax(szModo))

	set_hudmessage(random(256), random(256), random(256), 0.01, 0.23, 0, 1.0, 1.0)
	ShowSyncHudMsg(0, g_hHuds[hPlacar], "ep1c girls Brasil^n^n[Modo: %s]^n[%dT - Round: %d]^n[CTs: %d TRs: %d]", szModo, g_iNums[iTempo], g_iNums[iRounds], (g_iNums[iCTsPlacar] + g_iNums[iCTsPlacarOT]), (g_iNums[iTRsPlacar] + g_iNums[iTRsPlacarOT]))

	new szAviso[MAX_PLAYERS]
	
	if(g_bBooleans[iOvT])
	{
		if((g_iNums[iCTsPlacarOT] == 3) || (g_iNums[iTRsPlacarOT] == 3) && g_iNums[iRounds] != 4)
				formatex(szAviso, charsmax(szAviso), "MATCH POINT dos %s", (g_iNums[iTRsPlacarOT] == 3) ? "TRs": "CTs")	
	}
	else
	{
		if((g_iNums[iCTsPlacar] == 15) || (g_iNums[iTRsPlacar] == 15) && g_iNums[iRounds] != 15)
			formatex(szAviso, charsmax(szAviso), "MATCH POINT dos %s", (g_iNums[iTRsPlacar] == 15) ? "TRs": "CTs")		
	}	
	if(g_bBooleans[iOvT])
	{
		if(g_iNums[iRounds] == 3)
			formatex(szAviso, charsmax(szAviso), "ULTIMO ROUND")	
	}
	else
	{
		//if(g_iNums[iRounds] == 15)
		  if((g_iNums[iCTsPlacar] + g_iNums[iTRsPlacar]) == 14)
			formatex(szAviso, charsmax(szAviso), "ULTIMO ROUND")	
			
	}	
	if(szAviso[0])
	{
		set_hudmessage(255, 0, 0, 0.01, 0.33, 0, 1.0, 1.0)
		ShowSyncHudMsg(0, g_hHuds[hAviso], szAviso)
	}
}

get_pugmode(szBuffer[], iLen)
{
	if(g_bBooleans[iLive] && !g_bBooleans[iOvT])
		formatex(szBuffer, iLen, "Live")
		
	else if(g_bBooleans[iOvT])	
		formatex(szBuffer, iLen, "OverTime")
		
	if((g_iNums[iCTsPlacar] == 15) || (g_iNums[iTRsPlacar] == 15) && g_iNums[iRounds] != 15 && g_bBooleans[iLive])
		formatex(szBuffer, iLen, "GG <3")
	
	if(g_bBooleans[iKnife])
		formatex(szBuffer, iLen, "KnifeItUp")
	
	if(g_bBooleans[iFun])
		formatex(szBuffer, iLen, "Pre-Game")
	
	if(g_bBooleans[iEagle])
		formatex(szBuffer, iLen, "Round Deagle")
	
	if(g_bBooleans[bMD3])	
		formatex(szBuffer, iLen, "MD3")
	
	if(get_pcvar_num(VarEagleAkc))
		formatex(szBuffer, iLen, "Pre-Game So Eagle")
}

restartRound(iNum, id = 0)
{
	server_cmd("sv_restart %d", iNum)
	
	if(id)
		client_cmd(0, "speak deeoo")
	
}

getAdminsNum()
{
	new iPlayers[MAX_PLAYERS], iNum
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)

	new iAdminsNum = 0

	for(new i; i < iNum; i++)
	{
		if(isAdmin(iPlayers[i]))
			iAdminsNum++
	}
	return iAdminsNum
}

public CS_OnBuy(id, item)
{	
	if(g_bBooleans[iLive] || g_bBooleans[iOvT])
		return PLUGIN_CONTINUE
		
	if(!get_pcvar_num(VarLockBombs))
		return PLUGIN_CONTINUE


	if(!isBlocked(item))



		return PLUGIN_CONTINUE



		
	CC_SendMatched(id, RED, "Granadas e escudo estao bloqueados no modo ^x04pre-game.")
	InvalidSound(id)
	return PLUGIN_HANDLED
}

bool:isBlocked(item)
{
	switch(item)
	{
		case CSW_HEGRENADE, CSW_FLASHBANG, CSW_SMOKEGRENADE, CSI_SHIELD, CSI_SHIELDGUN:	return true
	}
	return false
}

TRWins()
{
	set_hudmessage(220, 0, 0, -1.0, 0.3, 1, 1.0, 3.5)
	ShowSyncHudMsg(0, g_hHuds[hTRWins], "O TIME TR VENCEU^nVOTEMAP SERA INICIADO EM BREVE")

	client_cmd(0, "spk ^"doop.team one victor^"")
	CC_SendMatched(0, RED, "Os TRs venceram a partida por^x04 %d^x01 a^x04 %d.", (g_iNums[iTRsPlacar] + g_iNums[iTRsPlacarOT]), (g_iNums[iCTsPlacar] + g_iNums[iCTsPlacarOT]))

	g_iNums[iBestFragSecH] = getFragger()
	g_iNums[iSecHalfKill] = get_user_frags(g_iNums[iBestFragSecH])
	CC_SendMatched(0, RED, "Melhor jogador do^x04 1^x01 tempo foi^x04 %s^x01 com^x04 %d^x01 frags.", g_dUserData[g_iNums[iBestFragFirstH]][szName],g_iNums[iFirstHalfKill])
	CC_SendMatched(0, RED, "Melhor jogador do^x04 2^x01 tempo foi^x04 %s^x01 com^x04 %d^x01 frags.", g_dUserData[g_iNums[iBestFragSecH]][szName],g_iNums[iSecHalfKill])

	if(get_pcvar_num(VarBestPlayers))
		set_task(2.0, "showBestFraggers")
}

CTWins()
{
	set_hudmessage(0, 70, 255, -1.0, 0.3, 1, 1.0, 3.5)
	ShowSyncHudMsg(0, g_hHuds[hTRWins], "O TIME CT VENCEU^nVOTEMAP SERA INICIADO EM BREVE")

	client_cmd(0, "spk ^"doop.team two victor^"")
	CC_SendMatched(0, RED, "Os CTs venceram a partida por^x04 %d^x01 a^x04 %d.", (g_iNums[iCTsPlacar] + g_iNums[iCTsPlacarOT]), (g_iNums[iTRsPlacar] + g_iNums[iTRsPlacarOT]))

	g_iNums[iBestFragSecH] = getFragger()
	g_iNums[iSecHalfKill] = get_user_frags(g_iNums[iBestFragSecH])
	CC_SendMatched(0, RED, "Melhor jogador do^x04 1^x01 tempo foi^x04 %s^x01 com^x04 %d^x01 frags.", g_dUserData[g_iNums[iBestFragFirstH]][szName],g_iNums[iFirstHalfKill])
	CC_SendMatched(0, RED, "Melhor jogador do^x04 2^x01 tempo foi^x04 %s^x01 com^x04 %d^x01 frags.", g_dUserData[g_iNums[iBestFragSecH]][szName],g_iNums[iSecHalfKill])
	
	if(get_pcvar_num(VarBestPlayers))
		set_task(2.0, "showBestFraggers")
}

public showBestFraggers()
{
	switch(get_pcvar_num(VarBestPlayers))
	{
		case 1:
		{
				
			static motd[1501], len
				
			len = format(motd, 1500,"<body style='background:#FFF;'>")
			len += format(motd[len], 1500-len,"<html><title>[ Melhores Jogadores ]</title>")
			len += format(motd[len], 1500-len,"<font style='font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 13px; line-height: 20px; font-weight: normal; color: rgb(102, 102, 102);'>")
			len += format(motd[len], 1500-len,"<center><p><hr><h4>* Melhor jogador do primeiro tempo *</h4>")
			len += format(motd[len], 1500-len,"<font color='#36A7BE' face='Verdana' size='2'><br><strong>%s</strong></font><br>",g_dUserData[g_iNums[iBestFragFirstH]][szName])
			len += format(motd[len], 1500-len,"Foi o melhor jogador do primeiro tempo com %d Frags<hr>",g_iNums[iFirstHalfKill])
			len += format(motd[len], 1500-len,"<hr><h4>* Melhor jogador do segundo tempo *</h4>")
			len += format(motd[len], 1500-len,"<font color='#36A7BE' face='Verdana' size='2'><br><strong>%s</strong></font><br>",g_dUserData[g_iNums[iBestFragSecH]][szName])
			len += format(motd[len], 1500-len,"Foi o melhor jogador do segundo tempo com %d Frags<hr></center><br><br>",g_iNums[iSecHalfKill])
			len += format(motd[len], 1500-len,"<font color='#FF0000' face='Verdana' size='2'>&gt;&gt;<strong> Acesse nosso instagram:</strong></font>")
			len += format(motd[len], 1500-len,"<font color='#0066ff' face='Palatino Linotype' size='3'><strong>@ep1cgamingbr</strong></font><br>")
			len += format(motd[len], 1500-len,"<font color='#FF0000' face='Verdana' size='2'>&gt;&gt;<strong> ep1c gaming Brasil</strong></font>")
			len += format(motd[len], 1500-len,"<br><br><center>")
			len += format(motd[len], 1500-len,"<font color='#0066ff' face='Palatino Linotype' size='3'><strong>Obrigado por utiliza-lo</strong></font><br>")
				
			show_motd(0, motd, "@ep1cgamingbr - Melhores Jogadores.")
		}
		case 2:
		{
			set_hudmessage(20, 200, 25, -1.0, 0.3, 1, 1.0, 6.0)
			ShowSyncHudMsg(0, g_hHuds[hBestFraggers], "%s foi o melhor do primeiro tempo com %d frags^nEnquanto o %s foi o melhor do segundo com %d frags.", g_dUserData[g_iNums[iBestFragFirstH]][szName], g_iNums[iFirstHalfKill], g_dUserData[g_iNums[iBestFragSecH]][szName], g_iNums[iSecHalfKill])
		}
	}
}

public CountDownRestore()
{
	new Left = floatround(g_Time - get_gametime())
		
	if(Left > 0)
	{
		new Text[64]
		get_time_length(0,Left,timeunit_seconds,Text,charsmax(Text))
       
		set_hudmessage(0,255,0,-1.0,0.01,0,0.0,0.6,0.0,0.0,1);
		ShowSyncHudMsg(0,g_hHuds[hHudCounter],"Mix faltando jogadores, tempo restante ate o 4fun: %s",Text)
	}
	else
	{
		CC_SendMatched(0, RED,"Mix cancelado por falta de jogadore(s)")
		remove_task(TASK_MIADO)
		client_cmd(0, "spk ambience/cat1")
		set_task(2.0, "SetMode", 3)
			
		new szMap[ 9 ]
		get_mapname( szMap , charsmax( szMap ) )
		    
		if (!equal(szMap,"de_dust2"))
			set_task(3.0, "changeToD2")
	}
}

public Say_Cmmds(id)
{
	new szMessage[36] 
	read_args(szMessage, charsmax(szMessage)) 
	remove_quotes(szMessage)
    
	if(equali(szMessage,".menu") || equali(szMessage,"/menu"))
	{
		PUG_AdminMenu(id)
		return PLUGIN_HANDLED
	}
	else if(equali(szMessage, "/mute") || equali(szMessage, ".mute"))
	{
		cmdMute(id)
		return PLUGIN_HANDLED
	}
	else if(equali(szMessage,".ready") || equali(szMessage,"/ready"))
	{
		ReadyCMD(id)
		return PLUGIN_HANDLED
	}
	else if(equali(szMessage, ".donate") || equali(szMessage, "/donate"))
	{
		if(g_bBooleans[iLive] || g_bBooleans[iOvT])
		{
			if(isTeam(id))
			{
				if(g_dUserData[id][g_iTimeDonated] >= get_pcvar_num(VarMaxDonate))
				{
					CC_SendMatched(id, TEAM_COLOR, "Você ja doou^x04 %i vez%s^x01 neste round.", get_pcvar_num(VarMaxDonate), (get_pcvar_num(VarMaxDonate) > 1) ? "es" : "")
					client_cmd(id,"spk buttons/blip2")
					return PLUGIN_HANDLED	
				}
				else
				{
					DonateCmd(id)
					return PLUGIN_HANDLED
				} 
			}
			CC_SendMatched(id, TEAM_COLOR, "Spectador nao pode doar.")
			client_cmd(id,"spk buttons/blip2")
			return PLUGIN_HANDLED
		}
		CC_SendMatched(id, TEAM_COLOR, "Você so pode doar dinheiro no^x04 live!")
		client_cmd(id,"spk buttons/blip2")
		return PLUGIN_HANDLED		
	}
	else if(equali(szMessage, ".surrender") || equali(szMessage, "/surrender"))
	{
		SurrenderCmd(id)
		return PLUGIN_HANDLED
	}
	else if(equali(szMessage,".rr") || equali(szMessage,"/rr"))
	{
		if(g_bBooleans[iFun])
		{
			if(isTeam(id))
			{
				if(is_user_connected(id))
				{
					if(cs_get_user_deaths(id) == 0 && get_user_frags(id) == 0)
					{
						CC_SendMatched(id, TEAM_COLOR, "Seu frag ja esta^x04 resetado.")
						client_cmd(id,"spk buttons/blip2")
						return PLUGIN_HANDLED
					}
					else
					{
						set_user_frags(id, 0)
						cs_set_user_deaths(id, 0)
				
						CC_SendMatched(id,TEAM_COLOR,"Seu^x04 frag^x01 foi resetado com sucesso!")
						CC_SendMatched(0,TEAM_COLOR,"O jogador^x04 %s^x01 resetou seu^x04 frag!", g_dUserData[id][szName])
						return PLUGIN_HANDLED
					}
				}
			}
			else
			{
				CC_SendMatched(id, TEAM_COLOR, "Quer resetar o que? Ta doidao spec?")
				client_cmd(id,"spk buttons/blip2")
				return PLUGIN_HANDLED
			}
		}
		CC_SendMatched(id, TEAM_COLOR, "Você so pode resetar seu frag no^x04 aquecimento!")
		client_cmd(id,"spk buttons/blip2")
		return PLUGIN_HANDLED	
	}
	else
	{
		if(g_bBooleans[bChat])
		{
			CC_SendMatched(id, RED, "Say^x03 desativado^x01, você nao pode utiliza-lo.")
			InvalidSound(id)
			return PLUGIN_HANDLED_MAIN
		}
	}
	return CheckValidMap(id, szMessage)
}

SurrenderCmd(id)
{
	new iNeededPlayers = get_pcvar_num(VarSurrender)
	
	if(!isTeam(id))
	{
		CC_SendMatched(id, RED, "Você precisa estar em um time para se render.")
		client_cmd(id, "spk buttons/blip2")
		return PLUGIN_HANDLED
	}
	else if(get_pcvar_num(VarLockSurrender))
	{
		CC_SendMatched(id, RED, "O comando .surrender esta desativado.")
		client_cmd(id, "spk buttons/blip2")
		return PLUGIN_HANDLED
	}
	else if(!g_bBooleans[iLive] || !g_bBooleans[iOvT])
	{
		CC_SendMatched(id, RED, "Você so pode pedir surrender no^x04 live.")
		client_cmd(id, "spk buttons/blip2")
		return PLUGIN_HANDLED
	}
	else if(g_dUserData[id][bSurrender])
	{
		CC_SendMatched(id, RED, "Você ja pediu surrender, mais^x04 %d jogadores^x01 do seu time para iniciar votacao.",
		(g_CurTeam[id] == CS_TEAM_T) ? (iNeededPlayers - GetSurrender(CS_TEAM_T)) : (iNeededPlayers - GetSurrender(CS_TEAM_CT)))
		client_cmd(id, "spk buttons/blip2")
		return PLUGIN_HANDLED
	}
	else if(g_bBooleans[g_SurrenderOnMap])
	{
		CC_SendMatched(id, RED, "Ja houve uma votacao de surrender nesse mapa, funcao bloqueada.")
		client_cmd(id, "spk buttons/blip2")
		return PLUGIN_HANDLED
	}
	else if(g_bBooleans[g_Surrender])
	{
		CC_SendMatched(id, RED, "Surrender ja esta sendo votado!")
		client_cmd(id, "spk buttons/blip2")
		return PLUGIN_HANDLED
	}
	g_dUserData[id][bSurrender] = true
	new CsTeams:Team = cs_get_user_team(id)

	switch(Team) 
	{
		case CS_TEAM_T: CC_SendMatched(0, TEAM_COLOR, "Um jogador pediu surrender. Falta%s^x04 %d jogador%s^x01 do time TR para iniciar a votacao.", 
			((iNeededPlayers - GetSurrender(CS_TEAM_T)) > 1) ? "m": "", (iNeededPlayers - GetSurrender(CS_TEAM_T)), ((iNeededPlayers - GetSurrender(CS_TEAM_T)) > 1) ? "es": "")
		
		case CS_TEAM_CT: CC_SendMatched(0, TEAM_COLOR, "Um jogador pediu surrender. Falta%s^x04 %d jogador%s^x01 do time CT para iniciar a votacao.", 
			((iNeededPlayers - GetSurrender(CS_TEAM_CT)) > 1) ? "m": "", (iNeededPlayers - GetSurrender(CS_TEAM_CT)), ((iNeededPlayers - GetSurrender(CS_TEAM_CT)) > 1) ? "es": "")			
	}
	if(GetSurrender(CS_TEAM_CT) >= iNeededPlayers || GetSurrender(CS_TEAM_T) >= iNeededPlayers)
	{
		CC_SendMatched(0, TEAM_COLOR, "Os jogadores do time^x04 %s^x01 pediram surrender, a votacao sera iniciada no proximo round.", (GetSurrender(CS_TEAM_T) >= iNeededPlayers) ? "terrorista": "contra-terrorista")
		g_bBooleans[g_Surrender] = true
	}		
	return PLUGIN_HANDLED
}

GetSurrender(CsTeams:Team)
{
	new iPlayers[32],iNum
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots | GetPlayers_MatchTeam ,(Team == CS_TEAM_T) ? "TERRORIST" : "CT")

	new Count = 0

	for(new i = 0;i < iNum;i++)
	{
		if(g_dUserData[iPlayers[i]][bSurrender])
		{
			Count++
		}
	}

	return Count
}
public mapsmenu_handler(id, menu, item)
{
	if(item == MENU_EXIT)
		return PLUGIN_HANDLED
	
	new _access, item_data[1], item_name[MAX_PLAYERS], callback
	menu_item_getinfo(menu, item, _access, item_data, charsmax(item_data), item_name, charsmax(item_name), callback)
	CheckValidMap(id, item_name)
	return PLUGIN_HANDLED
}

CheckValidMap(id, map[])
{
	static i
	if(_is_map_blocked(map))
	{
		CC_SendMatched(id, RED,"Este mapa eh muito^x04 recente!")
		client_cmd(id,"spk buttons/blip2")
		return PLUGIN_HANDLED
	}
	else if(_is_map_nominated(map))
	{
		CC_SendMatched(id, RED, "Este^x04 mapa^x03 ja foi^x04 escolhido!")
		client_cmd(id,"spk buttons/blip2")
		return PLUGIN_HANDLED
	}
	else if((i = _is_map_loaded(map)) != -1)
	{
		if(g_iCountNom == MAX_NOMINATE)
		{
			CC_SendMatched(id, RED,"O limite de nomeacoes foi atingido!")
			client_cmd(id,"spk buttons/blip2")
			return PLUGIN_HANDLED
		}
		else if(g_iNomMap[id] >= MAX_USER_NOMINATE)
		{
			CC_SendMatched(id, RED,"Você ja atingiu o limite maximo de nomeacoes de^x04 mapas!")
			client_cmd(id,"spk buttons/blip2")
			return PLUGIN_HANDLED
		}
		else
		{
			g_iIdMapNom[g_iCountNom] = i
			copy(g_sNomMap[g_iCountNom], charsmax(g_sNomMap[]), map)
			g_iNomMap[id]++ 
			g_iCountNom++
			
			get_user_name(id, g_dUserData[id][szName], charsmax(g_dUserData[]))
			CC_SendMatched(0, RED,"%s^x01 Nomeou o seguinte mapa:^x04 %s",g_dUserData[id][szName], map)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}

public VoteMap() server_cmd("amx_rtv")

public voteNextMap()
{
	static szMenu[256], iLen, iKeys, a, iMaxMaps
	set_task(1.0, "VotesHud", .flags = "a", .repeat = 10)

	iMaxMaps = (g_iMapCount - 1 < SELECTMAPS) ? g_iMapCount - 1 : SELECTMAPS

	iLen = formatex(szMenu, charsmax(szMenu), "\y[ \wPugMod - \rEscolha um mapa: \y]^n^n")	
	g_iVoteMapNum = iKeys = 0
	while(g_iVoteMapNum < iMaxMaps)
	{
		if(g_iVoteMapNum < g_iCountNom)
		{
			g_iMapInMenu[g_iVoteMapNum] = g_iIdMapNom[g_iVoteMapNum]
			copy(g_sVoteMap[g_iVoteMapNum], charsmax(g_sVoteMap[]), g_sMap[g_iIdMapNom[g_iVoteMapNum]])
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r%d\w. %s^n", g_iVoteMapNum+1, g_sVoteMap[g_iVoteMapNum])
			iKeys |= (1<<g_iVoteMapNum++)
			continue
		}
		do a = random(g_iMapCount - 1)
		while(_is_map_in_menu(a))
		g_iMapInMenu[g_iVoteMapNum] = a		
		copy(g_sVoteMap[g_iVoteMapNum], charsmax(g_sVoteMap[]), g_sMap[a])
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r%d\w. %s^n", g_iVoteMapNum+1, g_sVoteMap[g_iVoteMapNum])
		iKeys |= (1<<g_iVoteMapNum++)
	}
	show_menu(0, iKeys, szMenu, 10, "MapChoose")
	set_task(10.0, "checkVotes")
	client_cmd(0, "spk Gman/Gman_Choose2")
	set_pcvar_num(VarLockReady, 1)						   
	return PLUGIN_HANDLED
}

public votemenu_handler(id, iKey)
{
	get_user_name(id, g_dUserData[id][szName], charsmax(g_dUserData[]))

	CC_SendMatched(0,RED, "Jogador:^x04 %s^x01 Escolheu o mapa: ^x04%s^x01.",g_dUserData[id][szName], g_sVoteMap[iKey])
	client_cmd(0,"spk buttons/button3")
	return g_iVoteCount[iKey]++
	
}

public checkVotes()
{
	new b
	for(new a; a < SELECTMAPS+1; a++)
		if(g_iVoteCount[b] < g_iVoteCount[a])		
			b = a		
	
	if(!g_iVoteCount[b])
	{
		new map = random(g_iVoteMapNum-1)
		CC_SendMatched(0,TEAM_COLOR, "Votacao^x04 terminada!^x01 Proximo mapa:^x04 %s",g_sVoteMap[map])
		copy(g_NextMap, charsmax(g_NextMap), g_sVoteMap[map])
		ChangeLevel()
	}
	else
	{		
		CC_SendMatched(0,TEAM_COLOR,"Votacao^x04 terminada!^x01 Proximo mapa:^x04 %s",g_sVoteMap[b])
		copy(g_NextMap, charsmax(g_NextMap), g_sVoteMap[b]) 
		ChangeLevel()		
	}
}

LoadBlockMaps()
{
	copy(g_sLastMap[0], charsmax(g_sLastMap[]), g_sCurMap)
	if(file_exists(FILE_BLOCKEDMAPS))
	{
		new buff[256]
		new fp = fopen(FILE_BLOCKEDMAPS, "rt")
		while(g_iLastMap < BLOCK_MAPS && !feof(fp))
		{
			fgets(fp, buff, charsmax(buff))
			if(buff[0] != ';' && parse(buff, g_sLastMap[g_iLastMap], charsmax(g_sLastMap[])))
				g_iLastMap++
		}
		fclose(fp)
		unlink(FILE_BLOCKEDMAPS)
	}
	if(write_file(FILE_BLOCKEDMAPS, "; Arquivo gerado pelo PugPerfect. Nao modifique!"))
		return
		
	for(new i; i < g_iLastMap; i++)
		write_file(FILE_BLOCKEDMAPS, g_sLastMap[i])
}

LoadMaps()
{
	new buff[256]
	new fp = fopen("addons/amxmodx/configs/maps.ini", "rt")
	
	if(!fp) 
		set_fail_state("Arquivo ^"addons/amxmodx/configs/maps.ini^"nao encontrado!")	

	while(!feof(fp) && g_iMapCount < MAX_MAPS)
	{
		fgets(fp, buff, charsmax(buff))
		trim(buff) 
		remove_quotes(buff)
			
		if(!buff[0] || buff[0] == ';') 
			continue
		
		if(parse(buff, g_sMap[g_iMapCount], charsmax(g_sMap[])))
		{
			if(!is_map_valid(g_sMap[g_iMapCount]) || _is_map_blocked(g_sMap[g_iMapCount]) || !strcmp(g_sMap[g_iMapCount], g_sCurMap)) 
				continue
				
			menu_additem(g_iMapsMenu, g_sMap[g_iMapCount])
			g_iMapCount++			
		}
	}
	fclose(fp) 
	
	if(!g_iMapCount) 
		set_fail_state("[PUGMOD] Nenhum mapa foi carregado! Plugin pausado!")
	
	else if(g_iMapCount == 1)
		set_fail_state("[PUGMOD] Poucos mapas foram carregados! Adicione mais em ^"addons/amxmodx/configs/maps.ini^". Plugin pausado!")	
	
	else if(g_iMapCount < SELECTMAPS)
		log_to_file(WARNMAPS, "[PugMod]: PERIGO! Menos de mapas necessarios foram carregados! [Carregado(s): %d / Minimo: %d]", g_iMapCount, SELECTMAPS)
}

public VotesHud()
{
	set_hudmessage(0, 255, 0, 0.23, 0.02, 0, 0.0, 1.0)
	ShowSyncHudMsg(0, g_hHuds[hVotemapResult], "Resultado da votacao:")

	new iPlayers[MAX_PLAYERS], iNum
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
					
	new sMaps[256]				
	for(new x;x < sizeof g_iVoteCount;++x)
	{
		if(g_iVoteCount[x])
		{
			formatex(sMaps, charsmax(sMaps),"%s%s - %d%%%%^n",sMaps, g_sVoteMap[x], (100 * g_iVoteCount[x] / iNum))
		}
	}
					
	set_hudmessage(255, 255, 255, 0.23, 0.05, 0, 0.0, 1.0)
	ShowSyncHudMsg(0, g_hHuds[hMapsVote], sMaps)
}

public showVotemapHud()
{
	static iTimer
	if(!iTimer)
		iTimer = 4

	new const szVoteMapSounds[][] =
	{
		"",
		"one",
		"two",
		"three"
	}

	client_cmd(0, "spk fvox/%s", szVoteMapSounds[--iTimer])

	message_begin(MSG_ALL, g_mMessageScreenFade)
	write_short(5600)
	write_short(0)
	write_short(0)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(110)
	message_end()

	set_hudmessage(0, 255, 0, -1.0, 0.3, 0, 1.0, 1.0)
	ShowSyncHudMsg(0, g_hHuds[hVotemapCountdown], "Votemap vai iniciar em %d segundo%s", iTimer, (iTimer > 1) ? "s": "")
}

ChangeLevel()
{
	message_begin(MSG_ALL, SVC_INTERMISSION)
	message_end()

	set_task(5.0, "NextMap")
}

public NextMap()
	server_cmd("changelevel %s", g_NextMap)
	
bool:_is_map_in_menu(MapId)
{
	for(new i; i < g_iVoteMapNum; i++)
		if(g_iMapInMenu[i] == MapId)
			return true

	return false
}

bool:_is_map_blocked(map[])
{
	for(new i; i < g_iLastMap; i++)
		if(!strcmp(g_sLastMap[i], map))
			return true

	return false	
}
bool:_is_map_nominated(map[])
{
	for(new i; i < g_iCountNom; i++)
		if(!strcmp(g_sNomMap[i], map))
			return true

	return false
}

_is_map_loaded(map[])
{
	for(new i; i < g_iMapCount; i++)
		if(!strcmp(g_sMap[i], map)) 
			return i	

	return -1	
}

execCfg(iConfig)
{
	static szDir[94], szConfig[64]
	
	switch(iConfig)
	{
		case 0 , 1, 2, 4:	szConfig = "live.cfg"
		case 3:			szConfig = "4fun.cfg"
		default:		szConfig = "pug_configuracoes.cfg"
	}
	
	get_configsdir(szDir, charsmax(szDir))
	formatex(szDir, charsmax(szDir), "%s/%s/%s", szDir, FOLDER, szConfig)

	if(!file_exists(szDir))
	{
		static szFailState[85]
		formatex(szFailState, charsmax(szFailState), "Arquivo ^"%s^"nao encontrado.", szDir)
		set_fail_state(szFailState)
	}
	else
	{
		server_cmd("exec ^"%s^"", szDir)
		restartRound(1)
		
	}
}

PugRemoveC4(bool:bRemove)
{
	new iEnt = -1

	while((iEnt = engfunc(EngFunc_FindEntityByString,iEnt,"classname",bRemove ? "func_bomb_target": "_func_bomb_target")) > 0)
	{
		set_pev(iEnt,pev_classname,bRemove ? "_func_bomb_target": "func_bomb_target")
	}

	while((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", bRemove ? "info_bomb_target": "_info_bomb_target")) > 0)
	{
		set_pev(iEnt,pev_classname,bRemove ? "_info_bomb_target": "info_bomb_target")
	}
}

UnRegisterWarmCmds()
{
	DisableHamForward(g_iSetModel)
	g_iMic = register_forward(FM_Voice_SetClientListening, "Forward_SetClientListening")
	if(g_iMsgMoney)
		unregister_message(gMsgMoney,g_iMsgMoney)
}

RegisterWarmCmds()
{
	EnableHamForward(g_iSetModel)
	unregister_forward(FM_Voice_SetClientListening, g_iMic)
	g_iMsgMoney = register_message(gMsgMoney,"PugMessageMoney")
}

public cmdMute(id)
{
	new szTittle[60]
	formatex(szTittle, charsmax(szTittle), "\y[\w%s\d - \rMenu de mute \y ]", Pug_MenuPrefix)
	new iMenu = menu_create(szTittle, "mute_menu_handler")
	
	new iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "e", (get_user_team(id) == 1) ? "TERRORIST" : "CT")
	for(new i, szTempid[10], szItem[50], iPlayer;i < iNum;i++)
	{
		iPlayer = iPlayers[i]

		if(iPlayer != id)
		{
			num_to_str(iPlayer, szTempid, charsmax(szTempid))
		
			formatex(szItem, charsmax(szItem), "%s%s", g_bPlayerMuted[id][iPlayer] ? "\d" : "\w", g_dUserData[iPlayer][szName])
			menu_additem(iMenu, szItem, szTempid)
		}
	}
	menu_display(id, iMenu)
	return PLUGIN_HANDLED
}

public mute_menu_handler(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenu)
		return PLUGIN_HANDLED
	}
	new iData[6], szItemName[MAX_PLAYERS * 2], iAccess, iCallback
	menu_item_getinfo(iMenu, iItem, iAccess, iData, charsmax(iData), szItemName, charsmax(szItemName), iCallback)
	
	new iPlayer = str_to_num(iData)
	if(!iPlayer)
	{
		CC_SendMatched(id, RED, "Este jogador nao existe")
		menu_display(id, iMenu)
		return PLUGIN_HANDLED
	}
	
	g_bPlayerMuted[id][iPlayer] = !g_bPlayerMuted[id][iPlayer]
	CC_SendMatched(id, RED, "Você %smutou o^x04 %s.", g_bPlayerMuted[id][iPlayer] ? "": "des", g_dUserData[iPlayer][szName])
	return PLUGIN_HANDLED
}

public SayTeam_Hook(id)
{
	if(!g_bBooleans[iLive] || !g_bBooleans[iOvT])
		return PLUGIN_CONTINUE

	if(!get_pcvar_num(VarDeadMic))
		return PLUGIN_CONTINUE

	new szMessage[192], iUserTeam = get_user_team(id)
	read_argv(1, szMessage, charsmax(szMessage))
	remove_quotes(szMessage)
	
	switch(szMessage[0])
	{
		case '/', '@', '.', '!', EOS: 
			return PLUGIN_HANDLED
	}
	
	new iPlayers[MAX_PLAYERS], iNum
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
	for(new i, iPlayer; i < iNum;i++)
	{
		iPlayer = iPlayers[i]

		if(iUserTeam == get_user_team(iPlayer))
		{
			CC_RemovePrefix
			CC_SendMatched(iPlayer, TEAM_COLOR, "(%s)%s^x04 %s^x01 :^x03 %s", (iUserTeam == 1) ? "Terroristas": "Contra-Terroristas", !is_user_alive(id) ? "*MORTO*": "",g_dUserData[id][szName], szMessage)
			CC_SetPrefix(Pug_TagPrefix)
		}
	}
	return PLUGIN_HANDLED
}

getFragger()
{
	new iPlayers[MAX_PLAYERS], iNum
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
	SortCustom1D(iPlayers, iNum, "getBestFragger")
	return iPlayers[0]
}

public getBestFragger(id1, id2)
{
	if(get_user_frags(id1) > get_user_frags(id2))
	{
		return -1
	}
	else if(get_user_frags(id1) < get_user_frags(id2))
	{
		return 1
	}
	return 0
}

showNames()
{
	new iPlayersTR[MAX_PLAYERS], iPlayersCT[MAX_PLAYERS], iNum[CsTeams]
	get_players_ex(iPlayersCT, iNum[CS_TEAM_CT], GetPlayers_ExcludeHLTV | GetPlayers_MatchTeam, "CT")
	get_players_ex(iPlayersTR, iNum[CS_TEAM_T], GetPlayers_ExcludeHLTV | GetPlayers_MatchTeam, "TERRORIST")
	
	set_hudmessage(0, 255, 0, -1.0, 0.3, 0, 1.0, 4.0)
	ShowSyncHudMsg(0, g_hHuds[hRoundDeagleNames], "--- Round deagle ---^n%s vs. %s", g_dUserData[iPlayersTR[0]][szName], g_dUserData[iPlayersCT[0]][szName])
	CC_SendMatched(0, TEAM_COLOR, "Round deagle -^x04 %s^x01 vs.^x04 %s.", g_dUserData[iPlayersTR[0]][szName], g_dUserData[iPlayersCT[0]][szName])
}

public PugMessageMoney(iMsg,iDest,id)
{
	if(g_bBooleans[iFun] && get_pcvar_num(VarEagleAkc) == 0 && get_pcvar_num(VarDisable) == 0)
	{
		if(isPlayer(id))
		{
			if(is_user_alive(id))
			{
				cs_set_user_money(id, get_pcvar_num(VarMoney), 0)
			}
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public SurrenderVote()
{
	static szTittle[60]
	formatex(szTittle, charsmax(szTittle), "\y[\w%s\d - \rAceitar o surrender inimigo? \y]", Pug_MenuPrefix)
	 
	new iMenu = menu_create(szTittle, "surrender_vote_handler")
	   
	menu_additem(iMenu,"\ySim")
	menu_additem(iMenu,"\rNao")
	 
	new iPlayers[MAX_PLAYERS],iNum, id
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots | GetPlayers_MatchTeam, GetSurrender(CS_TEAM_T) >= get_pcvar_num(VarSurrender) ? "CT": "TERRORIST")
	 
	for(new i; i < iNum;i++)
	{
		id = iPlayers[i]
		
		if(isTeam(id))
		{
			client_cmd(id, "spk Gman/Gman_Choose2")
			menu_display(id, iMenu)
		}
	}
	menu_setprop(iMenu,MPROP_EXIT,MEXIT_NEVER)
	   
	set_task(10.0,"Surrender_Finalizada")
	g_bBooleans[g_bVoteRunning] = true
}


public surrender_vote_handler(id,menu,iItem)
{
	client_cmd(0,"spk buttons/button3")

	switch(iItem)
	{
		case 0: g_iVote[vSurrender][0]++
		case 1: g_iVote[vSurrender][1]++
	}
	
	CC_SendMatched(0, TEAM_COLOR, "Jogador^x03 %s^x01 %saceitou o^x04 surrender.", g_dUserData[id][szName], (iItem == 0) ? "": "nao ")
}

public Surrender_Finalizada()
{
	show_menu(0, 0, "^n", 1)
	
	if(g_iVote[vSurrender][0] > g_iVote[vSurrender][1])
	{
		CC_SendMatched(0, TEAM_COLOR, "Aceitar o^x04 surrender^x01 venceu com^x04�%i^x01 voto%s a favor e^x04 %i^x01 voto%s contra.", g_iVote[vSurrender][0], (g_iVote[vSurrender][0] > 1) ? "s" : "", g_iVote[vSurrender][1], (g_iVote[vSurrender][1] > 1) ? "s" : "")
		g_bBooleans[g_Surrender] = false
		CC_SendMatched(0, TEAM_COLOR, "Iniciando o^x04 votemap.")
		set_task(3.0, "SetMode", 3)
		set_task(1.0, "showVotemapHud", .flags = "a", .repeat = 3)
		set_task(4.0,"voteNextMap")
	}
	else if(g_iVote[vSurrender][1] > g_iVote[vSurrender][0])
	{
		CC_SendMatched(0, TEAM_COLOR, "O^x04 surrender foi recusado, com^x04�%i^x01 voto%s a favor e^x04 %i^x01 voto%s contra.", g_iVote[vSurrender][1], (g_iVote[vSurrender][1] > 1) ? "s" : "", g_iVote[vSurrender][0], (g_iVote[vSurrender][0] > 1) ? "s" : "")
		g_bBooleans[g_Surrender] = false
		g_bBooleans[g_SurrenderOnMap] = true
	}
	else
	{
		CC_SendMatched(0, RED,"Os votos empataram. Surrender foi^x04 recusado.")
		g_bBooleans[g_Surrender] = false
		g_bBooleans[g_SurrenderOnMap] = true
	}
	g_iVote[vSurrender][0] = g_iVote[vSurrender][1] = 0
	
	new iPlayers[MAX_PLAYERS], iNum, id
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
	for(new i; i < iNum;i++)
	{
		id = iPlayers[i]
			
		g_dUserData[id][bSurrender] = false
	}
}

public SetMoney()
{
	new iPlayers[MAX_PLAYERS],iNum, id
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots | GetPlayers_MatchTeam, g_bBooleans[g_MoneyTrWinner] ? "TERRORIST": "CT")
	
	for(new i; i < iNum;i++)
	{
		id = iPlayers[i]
						
		cs_set_user_money(id, 1400)
	}
	
}

public KnifeWinner()
{
	static szTittle[60]
	formatex(szTittle, charsmax(szTittle), "\y[\w%s\d - \rSeu time ganhou o Round Faca! \y]", Pug_MenuPrefix)
	new iMenu = menu_create(szTittle, "Knife_vote_handler")
	
	menu_additem(iMenu, "\yContinuar nesse lado.")
	menu_additem(iMenu, "\rTrocar de lado.")
	
	new iPlayers[MAX_PLAYERS],iNum, id
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots | GetPlayers_MatchTeam, g_bBooleans[g_KnifeTrWinner] ? "TERRORIST": "CT")
	
	for(new i; i < iNum;i++)
	{
		id = iPlayers[i]
		
		if(isTeam(id))
		{
			client_cmd(id, "spk Gman/Gman_Choose2")
			menu_display(id, iMenu)
		}
	}
	menu_setprop(iMenu, MPROP_EXIT, MEXIT_NEVER)
	
	set_task(10.0, "Knife_Finalizada")
	g_bBooleans[g_bVoteRunning] = true
}

public Knife_vote_handler(id,menu,iItem)
{
	client_cmd(0,"spk buttons/button3")

	switch(iItem)
	{
		case 0: 
		{
			g_iVote[vKnife][0]++
			CC_SendMatched(0, TEAM_COLOR, "Jogador^x03 %s^x01 escolheu^x04 comecar na vantagem.", g_dUserData[id][szName])
		}
		case 1:
		{
			g_iVote[vKnife][1]++
			CC_SendMatched(0, TEAM_COLOR, "Jogador^x03 %s^x01 escolheu^x04 comecar no outro time.", g_dUserData[id][szName])
		}
	}
}

public Knife_Finalizada()
{
	show_menu(0, 0, "^n", 1)
	
	if(g_iVote[vKnife][0] > g_iVote[vKnife][1])
	{
		CC_SendMatched(0, TEAM_COLOR, "Comecar na^x04 vantagem venceu, com^x04 %i^x01 voto%s a favor e^x04 %i^x01 voto%s contra..", g_iVote[vKnife][0], (g_iVote[vKnife][0] > 1) ? "s" : "", g_iVote[vKnife][1], (g_iVote[vKnife][1] > 1) ? "s" : "")
		g_bBooleans[iLive] = true
		g_bBooleans[bMD3] = false
		g_bBooleans[g_MoneyMaker] = true
		set_task(0.1, "SetMode", 0)
	}
	else if(g_iVote[vKnife][1] > g_iVote[vKnife][0])
	{
		CC_SendMatched(0, TEAM_COLOR, "Trocar de^x04 lado venceu, com^x04 %i^x01 voto%s a favor e^x04 %i^x01 voto%s contra.", g_iVote[vKnife][1], (g_iVote[vKnife][1] > 1) ? "s" : "", g_iVote[vKnife][0], (g_iVote[vKnife][0] > 1) ? "s" : "")
		set_task(0.5, "SwapTeams")
		g_bBooleans[iLive] = true
		g_bBooleans[bMD3] = false
		set_task(0.1, "SetMode", 0)
		g_bBooleans[g_SwapFF] = true
	}
	else
		CC_SendMatched(0, RED,"Os votos empataram. Administrador, resolva como comecar!.")
	
	g_iVote[vKnife][0] = g_iVote[vKnife][1] = 0
}

public CurWeapon(id)
{
	if(g_bBooleans[iLive] || g_bBooleans[iOvT])
		return
	
	new iWeapon = get_user_weapon(id)
			
	if(iWeapon == CSW_C4) 
		cs_set_user_plant(id,0,0)
			
	if(WeaponSlots[iWeapon] == SLOT_PRIMARY || WeaponSlots[iWeapon] == SLOT_SECONDARY)
	{
		new iAmmo = cs_get_user_bpammo(id,iWeapon)
				
		if(iAmmo < MaxBPAmmo[iWeapon]) 
			cs_set_user_bpammo(id,iWeapon,MaxBPAmmo[iWeapon])
	}
}

public TeamInfo()
{
	new id , szTeam[2]
	
	id = read_data(1)
	read_data(2, szTeam, charsmax(szTeam))
	
	if (g_iCurTeam[id] != szTeam[0])
	{
		g_iCurTeam[id] = szTeam[0]
		
		switch(szTeam[0])
		{
			case 'T': g_CurTeam[id] = CS_TEAM_T
			case 'C': g_CurTeam[id] = CS_TEAM_CT
			case 'S': g_CurTeam[id] = CS_TEAM_SPECTATOR
		}
	}
}

public resetFrag(id)
{
	new iPlayers[MAX_PLAYERS], iNum, id
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV | GetPlayers_ExcludeBots)
	for(new i; i < iNum;i++)
	{
		id = iPlayers[i]
		
		g_dUserData[id][iKills] = g_dUserData[id][iHsKills] = 0
		g_iNums[iOwnerID] = g_iNums[iOwnerIDHS] = 0
	}
}

public removeMoneySprites() 
{ 
	new iPlayers[32], iNum
	get_players(iPlayers, iNum, "ah")
	
	for(new i; i < iNum; i++) 
	{ 
		removeMoneySprite(iPlayers[i])
	} 
} 

removeMoneySprite(id)
{
	for(new i; i < sizeof g_iUserSprites[]; i++) 
	{     
		if(g_iUserSprites[id][i] > 0) 
			remove_entity(g_iUserSprites[id][i])
			
		g_iUserSprites[id][i] = 0
	} 
}

setMoneySprite(id)
{
	new iEnts[sizeof g_szMoneySprites]
	for(new i;i < sizeof iEnts;i++)
	{
		iEnts[i] = create_entity("env_sprite")
		createMoneySprite(id, (g_iUserSprites[id][i] = iEnts[i]), g_szMoneySprites[i][szSpriteName], g_szMoneySprites[i][iSpriteID])
	} 
}

createMoneySprite(id, iEnt, szSprite[], iSprID)
{
	set_pev(iEnt, pev_classname, g_szMoneySpriteClassName) 
	engfunc(EngFunc_SetModel, iEnt, szSprite)
	set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
	set_pev(iEnt, pev_movetype, MOVETYPE_NOCLIP)
	set_pev(iEnt, pev_owner, id)
	set_pev(iEnt, pev_iuser1, iSprID)
	set_pev(iEnt, pev_scale, 0.2)

	set_rendering(iEnt, kRenderFxNone, 0, 255, 0, kRenderTransAdd, 200) 
}

public sprite_Think(iEnt) 
{
	if(g_bBooleans[iFun])
		return

	static Float:fOrigin[3]
	static iOwner; iOwner = pev(iEnt, pev_owner)
	static iSprID; iSprID = pev(iEnt, pev_iuser1)
	
	pev(iOwner, pev_origin, fOrigin) 
	fOrigin[2] += 40.0
	set_pev(iEnt, pev_origin, fOrigin)
	
	if(iSprID == 5) 
	{ 
		set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
		return
	} 
	
	static szMoney[6], szValue[2]
	arrayset(szMoney, 0, sizeof szMoney)
	num_to_str(cs_get_user_money(iOwner), szMoney, charsmax(szMoney))
	
	if(szMoney[iSprID] == 0) 
	{ 
		set_rendering(iEnt, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0) 
		set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
		return
	} 
	
	szValue[0] = szMoney[iSprID]
	szValue[1] = 0

	set_rendering(iEnt, kRenderFxNone, 0, 255, 0, kRenderTransAdd, 200)
 
	set_pev(iEnt, pev_frame, floatstr(szValue)) 
	set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
}

public showMoney(TaskId)
{
	new id = TaskId - TASK_SHOWMONEY
	
	new iPlayers[MAX_PLAYERS], iNum, bool:bIsTerror = bool:(get_user_team(id) == 1), szMessage[192]
	get_players(iPlayers, iNum, "e", bIsTerror ? "TERRORIST" : "CT")
	for(new i, iPlayer;i < iNum;i++)
	{
		iPlayer = iPlayers[i]
		
		if(iPlayer != id)
		{
			formatex(szMessage, charsmax(szMessage), "%s%s - %d$^n", szMessage, g_dUserData[iPlayer][szName], cs_get_user_money(iPlayer))
		}
	}
	
	set_dhudmessage(0, 255, 0, 0.75, 0.1, 0, 1.0, 1.0)
	show_dhudmessage(id, "%s", bIsTerror ? "HUD TR" : "HUD CT")

	set_dhudmessage(255, 255, 255, 0.75, 0.14, 0, 1.0, 1.0)
	show_dhudmessage(id, szMessage)
}

public DonateCmd(id)
{
	new szTittle[60]
	formatex(szTittle, charsmax(szTittle), "\y[\w%s\d - \rMenu de doação \y ]", Pug_MenuPrefix)
	new iMenu = menu_create(szTittle, "donate_handler")
	
	new iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum, "e", (g_CurTeam[id] == CS_TEAM_T) ? "TERRORIST" : "CT")
	for(new i, szTempid[10], szItem[50], iPlayer;i < iNum;i++)
	{
		iPlayer = iPlayers[i]

		if(iPlayer != id)
		{
			num_to_str(iPlayer, szTempid, charsmax(szTempid))
			new iMoney = cs_get_user_money(iPlayer);

			formatex(szItem, charsmax(szItem), "\y$%5d \d- \w%s", iMoney, g_dUserData[iPlayer][szName])
			menu_additem(iMenu, szItem, szTempid)
		}
	}
	menu_display(id, iMenu)
	return PLUGIN_HANDLED
}


public VALORCmd(id)
{
	if (!is_user_connected(id))
	{
		return PLUGIN_HANDLED;
	}

	new iReceiver = donateReceiver[id]
	donateReceiver[id] = 0;

	if (!is_user_connected(iReceiver))
	{
		return PLUGIN_HANDLED;
	}

	new szMoney[64];
  	read_args(szMoney, charsmax(szMoney));

  	trim(szMoney);
  	remove_quotes(szMoney);

	new iMoneyDonated = str_to_num(szMoney)

	if (!strlen(szMoney) || !iMoneyDonated)
	{
		return PLUGIN_HANDLED;
	}

	new iPlayerMoney = cs_get_user_money(id)
	// new iMoneyDonated = get_pcvar_num(VarDonateMoney)

	if( iPlayerMoney < iMoneyDonated)
	{
		iMoneyDonated = iPlayerMoney;
	}

	cs_set_user_money( iReceiver, cs_get_user_money(iReceiver) + iMoneyDonated)
	cs_set_user_money( id, cs_get_user_money(id) - iMoneyDonated)

	new szNameGiver[MAX_PLAYERS]
	get_user_name( id, szNameGiver, charsmax( szNameGiver))

	new szNameReceiver[MAX_PLAYERS]
	get_user_name(iReceiver, szNameReceiver, charsmax(szNameReceiver))

	CC_SendMatched(id, TEAM_COLOR, "Você doou ^4$%i^1 para ^3%s!", iMoneyDonated, szNameReceiver)
	CC_SendMatched(iReceiver, TEAM_COLOR, "^3%s^1 doou ^4$%i^1 para você!", szNameGiver, iMoneyDonated)
	client_cmd(iReceiver, "spk ^"items/9mmclip1.wav^"")
	client_cmd(id, "spk ^"items/9mmclip1.wav^"")

	g_dUserData[id][g_iTimeDonated]++

	return PLUGIN_HANDLED
}


public donate_handler(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenu)
		return PLUGIN_HANDLED
	}
	new iData[6], szItemName[MAX_PLAYERS * 2], iAccess, iCallback
	menu_item_getinfo(iMenu, iItem, iAccess, iData, charsmax(iData), szItemName, charsmax(szItemName), iCallback)
	
	new iPlayer = str_to_num(iData)
	if(!iPlayer)
	{
		CC_SendMatched(id, RED, "Este jogador nao existe")
		menu_display(id, iMenu)
		return PLUGIN_HANDLED
	}

	donateReceiver[id] = iPlayer
	client_cmd(id, "messagemode VALOR")
	
	menu_destroy(iMenu)
	return PLUGIN_CONTINUE	
}

RestoreDonate()
{
	new iPlayers[MAX_PLAYERS], iNum, id
	get_players_ex(iPlayers, iNum)

	for(new i;i < iNum; i++)
	{
		id = iPlayers[i]

		if(isTeam(id))
		{
			g_dUserData[id][g_iTimeDonated] = 0
		}
	}
}

public vote_grab(id)
{
	if (getAdminsNum() >= 1 && get_pcvar_num(VarAllowVote) == 0)
	{
		CC_SendMatched(id, TEAM_COLOR, "Tem ADM^x04 online,^x01 votacoes bloqueadas.")
		return PLUGIN_HANDLED_MAIN
	}
	return PLUGIN_CONTINUE
}

public Function()
{
	
}
