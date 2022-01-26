#include <amxmodx>

#define PLUGIN  "ep1c - Auto Restart Round"
#define VERSION "1.0"
#define AUTHOR  "Wilian M."

new xCountRounds, xCvars[3]

#define PREFIXCHAT "!g[ep1c gaming Brasil]"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("HLTV", "xRoundStart", "a", "1=0", "2=0")
	register_event("TextMsg", "xTextMsg", "a", "2=#Game_will_restart_in")

	xCvars[0] = register_cvar("rounds_para_restart", "30") // Round que havera o restart
	xCvars[1] = register_cvar("rounds_para_aviso", "29") // Round que havera o aviso que vai ter restart
	xCvars[2] = register_cvar("rounds_tempo_rr", "2") // Tempo do restart
}

public xTextMsg() xCountRounds = 0

public xRoundStart()
{
	xCountRounds ++
	
	if(xCountRounds == get_pcvar_num(xCvars[1]))
	{
		set_hudmessage(255, 0, 0, -1.0, 0.40, 0, 6.0, 12.0, 0.1, 0.2)
		show_hudmessage(0, "ATENCAO!!")
		
		set_hudmessage(47, 50, 209, -1.0, 0.43, 0, 6.0, 12.0, 0.1, 0.2)
		show_hudmessage(0, "Proximo round havera um Restart Round.")
	
		xClientPrintColor(0, "%s !yATENCAO !! Estamos no round !t%d, !yProximo round havera um RR.", PREFIXCHAT, xCountRounds)
		xClientPrintColor(0, "%s !yATENCAO !! Estamos no round !t%d, !yProximo round havera um RR.", PREFIXCHAT, xCountRounds)
		xClientPrintColor(0, "%s !yATENCAO !! Estamos no round !t%d, !yProximo round havera um RR.", PREFIXCHAT, xCountRounds)
		
	}
	
	if(xCountRounds == get_pcvar_num(xCvars[0]))
	{
		client_print(0, print_center, "Round %d, Restarting.....", xCountRounds)
		set_task(1.0, "xRrRound")
	}
}

public xRrRound()
{
	server_cmd("sv_restart ^"%d^"", get_pcvar_num(xCvars[2]))

	xCountRounds = 0
}

stock xClientPrintColor(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!t", "^3")
	replace_all(msg, 190, "!t2", "^0")
	
	if (id) players[0] = id; else get_players(players, count, "ch")

	for (new i = 0; i < count; i++)
	{
		if (is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
			write_byte(players[i])
			write_string(msg)
			message_end()
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
