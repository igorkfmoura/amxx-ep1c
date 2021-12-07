#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <hamsandwich>
#include <reapi>

#define PLUGIN	"ep1c: OnlineSxe"
#define VERSION	"1.0"
#define AUTHOR	"IceeedR"

#define Tag "@ep1cgamingbr"

new gMsgStatusIcon, szAuthid[MAX_PLAYERS + 1][MAX_AUTHID_LENGTH]
new Contar[4]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_saycmd("sxe", "sXeMenu")

	gMsgStatusIcon = get_user_msgid("StatusIcon");
}

public client_authorized(id, const authid[])
{
	copy(szAuthid[id], charsmax(szAuthid[]), authid)
}

public sXeMenu(id)
{
        new iMenu = menu_create(fmt("^r\r/*\w------------------------------------------\r*/^n  \w    %s - \rsXe Players^n  \r/*\w-----------------------------------------\r*/", Tag), "handler")

	new iPlayers[MAX_PLAYERS], iNum, String[60], iPlayer
	get_players_ex(iPlayers, iNum, GetPlayers_ExcludeHLTV)
	for(new i = 0;i < iNum;i++)
	{
		iPlayer = iPlayers[i]

                GetNamesforMenu(iPlayer, String, charsmax(String))

		menu_additem(iMenu, fmt("%s", String))
	}

	if(cs_get_user_buyzone(id))
		BuyIcon(id, 0)

        client_print_color(id, print_team_default, "^3[^4%s^3]^1 Tem^4 %i^1 steam -^4 %i^1 no-steam -^4 %i^1 com sxe e^4 %i^1 bots.", Tag, Contar[2], Contar[1], Contar[0], Contar[3])
	menu_display(id, iMenu)
	return PLUGIN_HANDLED
}

public handler( id, iMenu, szItem )
{
	BuyIcon(id, 1)
	menu_destroy(iMenu)
        Contar[0] = Contar[1] = Contar[2] = Contar[3] = 0
	return PLUGIN_HANDLED
}

BuyIcon(id, iNum)
{
	message_begin(MSG_ONE_UNRELIABLE, gMsgStatusIcon, _, id);
	write_byte(iNum);
	write_string("buyzone");
	write_byte(0);
	write_byte(160);
	write_byte(0);
	message_end();
}

GetNamesforMenu(id, szBuffer[], iLen)
{
        new StrToFormat[2][60]

        if(is_user_sxe(id))
        {
                formatex(StrToFormat[0], charsmax(StrToFormat[]), "\y[sXe]")
                Contar[0]++
        }
        if(is_user_nosteam(id) && !is_user_bot(id))
        {
                formatex(StrToFormat[0], charsmax(StrToFormat[]), "\y[No-sXe]")
                Contar[1]++
        }
        else if(is_user_steam(id))
        {
                formatex(StrToFormat[0],charsmax(StrToFormat[]), "")
        }

        if(is_user_steam(id))
        {
                formatex(StrToFormat[1], charsmax(StrToFormat[]), "\r[Steam]")
                Contar[2]++
        }
        else if(is_user_nosteam(id) || is_user_sxe(id))
        {
                formatex(StrToFormat[1], charsmax(StrToFormat[]), "\r[No-Steam]")
        }
        if(is_user_bot(id))
        {
                formatex(StrToFormat[1], charsmax(StrToFormat[]), "\r[BOT]")
                Contar[3]++
        }

        formatex(szBuffer, iLen, "%n %s %s", id, StrToFormat[1],StrToFormat[0] )
        return 0
}

stock register_saycmd(const szSayCmd[], const szFunc[], iFlags = -1, const szInfo[] = "", FlagManager = -1, bool:bInfoML = false)
{
        new const szPrefix[][] = { "say /", "say_team /", "say .", "say_team ." };

        for(new i, szTemp[32]; i < sizeof(szPrefix); i++)
        {
                formatex(szTemp, charsmax(szTemp), "%s%s", szPrefix[i], szSayCmd);
                register_clcmd(szTemp, szFunc, iFlags, szInfo, FlagManager, bInfoML);
        }
}

stock bool:is_user_nosteam(id)
{
        if(REU_GetAuthtype(id) != CA_TYPE_STEAM)
        {
                if(REU_GetAuthtype(id) != CA_TYPE_SXEI)
                {
                        return true
                }
        }
        return false
}

stock bool:is_user_sxe(id)
{
        return REU_GetAuthtype(id) != CA_TYPE_SXEI ? false : true
}
