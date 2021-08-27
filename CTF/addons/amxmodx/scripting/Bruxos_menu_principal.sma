#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN  "Bruxo_Menu"
#define VERSION "2.0"
#define AUTHOR  "Fbaixista"

new keys = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0
new keys3 = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0
new keys4 = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0
new keys5 = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0

public plugin_init()
{

    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_menu("Menu 1", keys, "func_menu") 
    register_menu("Menu 3", keys3, "func_menu3")
    register_menu("Menu 4", keys4, "func_menu4")
    register_menu("Menu 5", keys4, "func_menu5")
    register_concmd("menu", "Server_Menu")
    register_clcmd("nightvision", "Server_Menu")
    register_clcmd("say /menu", "Server_Menu")	

}

public client_authorized(id)
{
	xsetbind(id);
}

public client_putinserver(id)
{
	xsetbind(id)
}

public xsetbind(id)
{
	client_cmd2(id, "bind ^"v^" ^"say /buy^"")
	client_cmd2(id, "bind ^"n^" ^"say /menu^"")
}

public Server_Menu(id)
{
    static menu[650], iLen
    iLen = 0
    iLen = formatex(menu[iLen], charsmax(menu) - iLen, "\y[ \rRECRUTA \y] \d~ \wMenu Principal^n^n")
    
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r1\r. \r» \w|\yVer adrenalina\w| \r~ \dLoja CTF^n")
    keys |= MENU_KEY_1
    
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r2\r. \r» \w|\yTOP10 Bandeira\w| \r~ \dVer seu Rank e TOP10 Bandeira^n")
    keys |= MENU_KEY_2

    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r3\r. \r» \w|\yGranada de Gelo\w| \r~ \dComprar Granada de GELO^n")
    keys |= MENU_KEY_3 
     
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r4\r. \r» \w|\yDestruir Dispenser\w| \r~ \dDestruir seu dispenser^n")
    keys |= MENU_KEY_5

    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r5\r. \r» \w|\yOpções anti-lag\w| \r~ \dDesativar Itens^n")
    keys |= MENU_KEY_6
    
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r6\r. \r» \w|\ySua Estatística\w| \r~ \dVer seu Rank/Top15/Patente^n")
    keys |= MENU_KEY_7
    
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r7\r. \r» \w|\rADMINS\w| \r~ \dMenu apenas para ADMIN's^n^n")
    keys |= MENU_KEY_8    
        
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r0\r. \r» \wSair")
    keys |= MENU_KEY_0

    show_menu(id, keys, menu, -1, "Menu 1")
    return PLUGIN_HANDLED
}

public func_menu(id, key)
{
    switch(key)
    {
        case 0: client_cmd(id, "say /adrenaline") 
        case 1:
	   {
          client_cmd(id, "say /pbtop") 
    	   }
        case 2:
        {
	   	client_cmd(id, "sgren")
        }         
	   case 3:
        {
          client_cmd(id, "say /destroy")
        } 
        case 4: Server_Menu4(id) 
        case 5: Server_Menu5(id) 	   	    
        case 6: Server_Menu3(id)
        case 7: client_cmd(id, "build_dispenser") 

    }
    return PLUGIN_HANDLED
}

public Server_Menu3(id)
{
     
     if(!(get_user_flags(id) & ADMIN_KICK))
     {
        //client_print(id, print_center, "VOCÊ NÂO É ADMIN")
        xClientPrintColor(id, "!y[!gRECRUTA!y]!g: !yAcesso !gNegado!")
        client_cmd (id, "speak events/friend_died" );
        return PLUGIN_HANDLED
     }
     
    static menu[650], iLen
    iLen = 0
    iLen = formatex(menu[iLen], charsmax(menu) - iLen, "\y[ \rRECRUTA \y] \d~ \wMenu de Administração^n^n")
    
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r1\r. \r» \r|\wVOTE MAPAS\r| \r~ \dFazer votação para trocar de mapas^n")
    keys |= MENU_KEY_1

    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r2\r. \r» \r|\w\wKICKS\r| \r~ \dKickar jogadores^n")
    keys |= MENU_KEY_2

    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r3\r. \r» \r|\wTirar SS\r| \r~ \dTirar Screen SS de um Player^n")
    keys |= MENU_KEY_3

    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r4\r. \r» \r|\wBANS\r| \r~ \dBanir Jogadores^n")
    keys |= MENU_KEY_4
    
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\y5\r. \r» \r|\yDESBUG\r| \r~ \dDesbugar o servidor^n")
    keys |= MENU_KEY_5
    
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\y6\r. \r» \r|\yMUTAR\r| \r~ \dMutar Player^n")
    keys |= MENU_KEY_6
    
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\y7\r. \r» \r|\yDEMO\r| \r~ \dGravar DEMO de um Player^n^n")
    keys |= MENU_KEY_7

    //iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r|\y6\r| \r» \r|\yMUTAR\r| \r~ \dMutar Player^n^n")
    //keys |= MENU_KEY_7

    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r0\r. \r» \wSair")
    keys |= MENU_KEY_0

    show_menu(id, keys, menu, -1, "Menu 3")
    return PLUGIN_HANDLED
}
 public func_menu3(id, key)
{
     switch(key)
     {
        case 0: client_cmd(id, "amx_votemapmenu")
        case 1: client_cmd(id, "amx_kickmenu")  
        case 2: client_cmd(id, "say /ss")
        case 3: client_cmd(id, "amx_banmenu") 
        case 4: {
            client_cmd(id, "speak buttons/button1" );
            client_cmd(id, "amx_rcon sv_timeout 1;wait;wait;wait;wait;wait;amx_rcon sv_timeout 99999;amx_rcon sv_timeout 99999^"")
            xClientPrintColor(0, "!y[!gRECRUTA!y]!t: !y[!gDesbugando!y] - !y[!gDesbugando!y]")
            return PLUGIN_HANDLED
        }
        case 5: client_cmd(id, "amx_gagmenu")
        case 6: client_cmd(id, "say /demo")
        case 7: client_cmd(id, "build_dispenser")
     }
     return PLUGIN_HANDLED
}

public Server_Menu4(id)
{
    static menu[650], iLen
    iLen = 0
    iLen = formatex(menu[iLen], charsmax(menu) - iLen, "\y[ \rRECRUTA \y] \d~ \wOpções anti-lag^n^n")
    
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r» \w|\ySounds Eventos\w| \r~ \dDesativar sounds Headshot,Multikill.^n")
    keys |= MENU_KEY_1
    
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r» \w|\ySkins de Admin\w| \r~ \dDesativar Skins Admins^n")
    keys |= MENU_KEY_2

    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r» \w|\ySkins de Armas\w| \r~ \dDesativar Skins Armas^n")
    keys |= MENU_KEY_3 
     
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r» \w|\yLuz da bandeira\w| \r~ \dDeixa a luz da bandeira desligada^n")
    keys |= MENU_KEY_4

    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r» \w|\yDropa a Bandeira\w| \r~ \dDropa a sua bandeira pra outro Player^n^n")
    keys |= MENU_KEY_5  
        
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r0\r. \r» \wSair")
    keys |= MENU_KEY_0

    show_menu(id, keys, menu, -1, "Menu 4")
    return PLUGIN_HANDLED
}

public func_menu4(id, key)
{
    switch(key)
    {
        case 0: client_cmd(id, "say sounds")
        case 1: client_cmd(id, "cl_minmodels 1")  
        case 2: client_cmd(id, "cl_minmodels 1")
        case 3: client_cmd(id, "say /lights off") 
        case 4: client_cmd(id, "say /dropflag") 
        case 5: client_cmd(id, "build_dispenser")  	   	    

    }
    return PLUGIN_HANDLED
}

public Server_Menu5(id)
{
    static menu[650], iLen
    iLen = 0
    iLen = formatex(menu[iLen], charsmax(menu) - iLen, "\y[ \rRECRUTA \y] \d~ \wSua Estatística^n^n")
    
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r» \w|\yTOP FACA\w| \r~ \dVer Top10 Faca^n")
    keys |= MENU_KEY_1
    
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r» \w|\yTOP Bandeira\w| \r~ \dVer Top10 Bandeira^n")
    keys |= MENU_KEY_2

    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r» \w|\yRANK\w| \r~ \dVer seu Rank no Server^n")
    keys |= MENU_KEY_3 
     
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r» \w|\yTOP15\w| \r~ \dVer seu Top15 no server^n")
    keys |= MENU_KEY_4

    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r» \w|\yPATENTE\w| \r~ \dVer sua Patente/Rank^n")
    keys |= MENU_KEY_5  
    
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r» \w|\yAtivar VIP\w| \r~ \dTop10 Ganha Vip /ativar^n^n")
    keys |= MENU_KEY_6    
        
    iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r0\r. \r» \wSair")
    keys |= MENU_KEY_0

    show_menu(id, keys, menu, -1, "Menu 5")
    return PLUGIN_HANDLED
}

public func_menu5(id, key)
{
    switch(key)
    {
        case 0: client_cmd(id, "say /topf")
        case 1: client_cmd(id, "say /pbtop")  
        case 2: client_cmd(id, "say /rank")
        case 3: client_cmd(id, "say /top15") 
        case 4: client_cmd(id, "say .xp") 
        case 5: client_cmd(id, "say /ativar")
        case 6: client_cmd(id, "build_dispenser")  	   	    

    }
    return PLUGIN_HANDLED
}

stock client_cmd2(id, cmd[])
{
	message_begin(MSG_ONE, 51, _, id )
	write_byte(strlen(cmd) + 2)
	write_byte(10)
	write_string(cmd)
	message_end()
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
	
	if (id) players[0] = id; 
    	else get_players(players, count, "ch")
	
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
