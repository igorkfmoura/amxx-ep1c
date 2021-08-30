#include <amxmodx>
#include <cstrike>
#include <fun>
#include <hamsandwich>

#define PLUGIN "ep1c: Reset Score"
#define VERSION "1.1"
#define AUTHOR "S H E R M A N"

enum _:xMaxCvars
{
	CVAR_SHOW_MSG_ALL,
	CVAR_SOUND,
	CVAR_RESET_NEGATIVE,
	CVAR_AD_RESET_TIME
}

new xCvars[xMaxCvars], xMsgSync

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	xRegisterSay("resetscore", "xResetScore")
	xRegisterSay("rr", "xResetScore")
	xRegisterSay("rs", "xResetScore")
	xRegisterSay("frag", "xResetScore")

	xCvars[CVAR_SHOW_MSG_ALL] = create_cvar("csr_reset_show_msg_all", "1", .has_min = true, .min_val = 0.0, .has_max = true, .max_val = 1.0)
	xCvars[CVAR_SOUND] = create_cvar("csr_reset_sound", "1", .has_min = true, .min_val = 0.0, .has_max = true, .max_val = 1.0)
	xCvars[CVAR_RESET_NEGATIVE] = create_cvar("csr_reset_negative", "0", .has_min = true, .min_val = 0.0, .has_max = true, .max_val = 1.0)
	xCvars[CVAR_AD_RESET_TIME] = create_cvar("csr_ad_reset_time", "3")

	xMsgSync = CreateHudSyncObj()

	RegisterHam(Ham_Killed, "player", "xPlayerKilled", true)
}

public plugin_cfg()
{
	static xTimeAds; xTimeAds = get_pcvar_num(xCvars[CVAR_AD_RESET_TIME])

	if(xTimeAds)
	{
		xTimeAds *= 60
		set_task(float(xTimeAds), "xAdResetScore", _, _, _, "b")
	}
}

public xPlayerKilled(victim, id, shouldgib)
{
	if(!is_user_connected(id))
		return HAM_IGNORED

	if(get_user_frags(victim) < get_user_deaths(victim) && get_pcvar_num(xCvars[CVAR_RESET_NEGATIVE]))
		xResetScore(victim)
	
	return HAM_IGNORED
}

public xAdResetScore()
{
	set_hudmessage(150, 150, 0, -1.0, 0.35, 2, 0.3, 7.0, 0.01, 0.01)

	if(get_pcvar_num(xCvars[CVAR_RESET_NEGATIVE]))
		ShowSyncHudMsg(0, xMsgSync, "Digite /rr ou .rs para Resetar seu FRAG!^nObs: Jogadores negativo terão os FRAG resetado automaticamente.")
	else
		ShowSyncHudMsg(0, xMsgSync, "Digite /rr ou .rs para Resetar seu FRAG!")
}

public xResetScore(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED

	static xName[32]; get_user_name(id, xName, charsmax(xName))

	if(get_pcvar_num(xCvars[CVAR_SHOW_MSG_ALL]))
		client_print_color(0, print_team_default, "^1%s ^4zerou o score.", xName)
	else
		client_print_color(id, print_team_default, "^1Você ^4zerou seu score.")

	if(get_pcvar_num(xCvars[CVAR_SOUND]))
		client_cmd(id, "spk plats/elevbell1.wav")
	
	cs_set_user_deaths(id, 0)
	set_user_frags(id, 0)
	cs_set_user_deaths(id, 0)
	set_user_frags(id, 0)

	return PLUGIN_HANDLED
}

stock xRegisterSay(szsay[], szfunction[])
{
	new sztemp[64]
	formatex(sztemp, 63 , "say /%s", szsay)
	register_clcmd(sztemp, szfunction)
	
	formatex(sztemp, 63 , "say .%s", szsay)
	register_clcmd(sztemp, szfunction)
	
	formatex(sztemp, 63 , "say_team /%s", szsay)
	register_clcmd(sztemp, szfunction )
	
	formatex(sztemp, 63 , "say_team .%s", szsay)
	register_clcmd(sztemp, szfunction)
}
