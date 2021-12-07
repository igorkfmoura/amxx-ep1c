#include <amxmodx>

#define PLUGIN "ep1c: Contagem de frag"
#define VERSION "1.0"
#define AUTHOR "Wilian M."

enum _:xMaxCvars
{
    CVAR_FC_COLOR_R,
    CVAR_FC_COLOR_G,
    CVAR_FC_COLOR_B
}

new xCvars[xMaxCvars], xMsgIdStatusIcon, xPlayerKills[33]

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

    register_event("DeathMsg", "xDeathMsg", "a")
    register_event("HLTV", "xNewRound", "a", "1=0", "2=0")

    xCvars[CVAR_FC_COLOR_R] = create_cvar("csr_fc_color_R", "0")
    xCvars[CVAR_FC_COLOR_G] = create_cvar("csr_fc_color_G", "255")
    xCvars[CVAR_FC_COLOR_B] = create_cvar("csr_fc_color_B", "0")

    xMsgIdStatusIcon = get_user_msgid("StatusIcon")
}

public client_disconnected(id)
{
    xPlayerKills[id] = false
}

public xNewRound()
{
	static i
	for(i = 1; i <= MaxClients; i++)
	{
		xPlayerKills[i] = false
    }
}

public xDeathMsg()
{
    static xAttacker, xVictim

    xAttacker = read_data(1)
    xVictim = read_data(2)

    if(!is_user_connected(xVictim) || !is_user_connected(xAttacker))
        return

    if(xAttacker != xVictim)
    {
        xSetFrag(xAttacker, 0)

        xPlayerKills[xAttacker]++

        if(xPlayerKills[xAttacker] >= 9)
            xPlayerKills[xAttacker] = 9

        xSetFrag(xAttacker, 1)

        if(xPlayerKills[xAttacker] >= 4)
            xSetFrag(xAttacker, 0), xSetFrag(xAttacker, 2);
    }

    xSetFrag(xVictim, 0), xPlayerKills[xVictim] = 0, xSetFrag(xVictim, 0);
}

public xSetFrag(id, status)
{
    new xFmtx[50]
    format(xFmtx, charsmax(xFmtx), "number_%d", xPlayerKills[id])

    message_begin(MSG_ONE, xMsgIdStatusIcon, _, id)
    write_byte(status)
    write_string(xFmtx)
    write_byte(get_pcvar_num(xCvars[CVAR_FC_COLOR_R]))
    write_byte(get_pcvar_num(xCvars[CVAR_FC_COLOR_G]))
    write_byte(get_pcvar_num(xCvars[CVAR_FC_COLOR_B]))
    message_end()
}
