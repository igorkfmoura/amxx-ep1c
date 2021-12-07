#include <amxmodx>

#define PLUGIN  "ep1c: Melhor jogador do round"
#define VERSION "1.0"
#define AUTHOR  "Wilian M."

new g_ihs[33], g_ikills[33], xPlayerName[32]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_logevent("xRoundEnd", 2, "1=Round_End")
	register_event("DeathMsg", "xDeathMsg", "a")
}

public client_disconnect(id)
{
	g_ihs[id] = 0
	g_ikills[id] = 0
}

public xDeathMsg()
{
	new killer = read_data(1)
	new victim = read_data(2)
	new hs = read_data(3)

	if(killer != victim && is_user_connected(killer) && is_user_connected(victim))
	{
		g_ikills[killer] ++

		if(hs)
			g_ihs[killer] ++
	}
}

public xRoundEnd()
{
	new ibestplayer = xGetBestPlayer()
	
	if(g_ikills[ibestplayer] <= 0)
		return
	
	get_user_name(ibestplayer, xPlayerName, 31)

	set_dhudmessage(255, 255, 255, -1.0, -1.0, 0, 3.0, 6.0, 0.1, 0.2)
	show_dhudmessage(0, "Melhor do round: %s!^nMatou: %d jogador%s (%d HS).", xPlayerName, g_ikills[ibestplayer], g_ikills[ibestplayer] <= 1 ? "" : "es", g_ihs[ibestplayer])

	xClientPrintColor(0, "!tMelhor do round: !y%s!t! Matou: !y%d !tjogador%s (!y%d !tHS).", xPlayerName, g_ikills[ibestplayer], g_ikills[ibestplayer] <= 1 ? "" : "es", g_ihs[ibestplayer])

	for(new id = 1; id <= get_maxplayers(); id++)
	{
		g_ihs[id] = 0
		g_ikills[id] = 0
	}
}

public xSortBestPlayer(id1, id2)
{
	if(g_ikills[id1] > g_ikills[id2])
	{
		return -1
	}
	else if(g_ikills[id1] < g_ikills[id2])
	{
		return 1
	}
	
	return 0
}

stock xGetBestPlayer()
{
	new players[32], num

	get_players(players, num)
	SortCustom1D(players, num, "xSortBestPlayer")

	return players[0]
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
