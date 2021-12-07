#include <amxmodx>
#include <project-x/project-x_query>
#include <regex>

new const ServersFile[] = "serverlist.txt";
new const ServerTag[] = "^4[ep1c gaming Brasil]^1";
new const ServerTagMenu[] = "[ep1c gaming Brasil]";

const MAX_SERVERS = 25;
const Float:HUD_POS_X = -1.0;
const Float:HUD_POS_Y = 0.0;
const HUD_COLOR_R = 0;
const HUD_COLOR_G = 100;
const HUD_COLOR_B = 255;

new gServerIp[MAX_SERVERS][40], gResponse[MAX_SERVERS], 
gMap[MAX_SERVERS][64], gPlayers[MAX_SERVERS],
gMPlayers[MAX_SERVERS], gServerName[MAX_SERVERS][40],
gserver_count = 0, gSub[33], gLastRedirect, cvar_msg, cvar_time, cvar_ad, own_Server[40], gSync;

/* Commands */
new const Commands[][] = { "say /servers", "say /server", "say .server", "say .servers", "say_team /server", "say_team /servers"};
new const Commands2[][] = { "say /redirect", "say /follow", "say /seguir" };

public plugin_init()
{
	register_plugin( "\r[PX] \wAdvanced Server List", "1.0", "BhK-" );

	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");

	cvar_msg = register_cvar("amx_message", "1"); // 0 Desativado // 1 ShowMessage
	cvar_time = register_cvar("amx_time", "100.0"); // Tempo para aparecer as mensagens
	cvar_ad = register_cvar("amx_ad_type", "1"); // 0 Desativado // 1 PrintChat

	get_user_ip(0, own_Server, 39);

	new i;
	for(i = 0; i < sizeof Commands ; ++i)
		register_clcmd(Commands[i], "clcmdMenu");

	for(i = 0; i < sizeof Commands2 ; ++i)
		register_clcmd(Commands2[i], "RedirectFunc");

	LoadServers();

	gLastRedirect = -1;
	gSync = CreateHudSyncObj();

	set_task(get_pcvar_float(cvar_time), "Message");
	set_task(120.0, "Creator_Plugin", 100, _, _, "b")
}

public Creator_Plugin()
{	
	if(get_pcvar_num(cvar_ad) == 0)
		return;

	else if(get_pcvar_num(cvar_ad) >= 1) 
	client_print_color(0, print_team_default, "^4%s^1 Digite ^4/server ^1para ver nossa lista de servidores",ServerTag)
}

public Message()
{
	if(get_pcvar_num(cvar_msg) != 1)
		return;

	new szMsg[512], i, len = 0;
	
	for(i = 0 ; i < gserver_count ; ++i)
	{
		if(!gResponse[i] || !gServerName[i][0]) continue;

		len += formatex(szMsg[len], charsmax(szMsg)-len, "%s [%s] (%d/%d)^n", gServerName[i], gMap[i], gPlayers[i], gMPlayers[i]);
	}
	
	set_hudmessage(HUD_COLOR_R, HUD_COLOR_G, HUD_COLOR_B, HUD_POS_X, HUD_POS_Y);
	for (new id = 1; id <= 32; ++id)
	{
		if (is_user_connected(id) && !is_user_alive(id))
		{
			ShowSyncHudMsg(id, gSync, szMsg);
		}
	}

	set_task(get_pcvar_float(cvar_time), "Message");
}

public event_round_start() UpdateServersData();

public RedirectFunc(index)
{
	if(gLastRedirect == -1)
	{
		client_print_color(index, print_team_default, "%s ^1Ninguém foi redirecionado ainda portanto este comando está desabilitado^4.", ServerTag);
		return PLUGIN_HANDLED;
	}

	new name[32]; get_user_name(index, name, 31);

	client_cmd(index, "wait;wait;wait;wait;wait;^"connect^" %s", gServerIp[gLastRedirect]);

	client_print_color(0, print_team_default, "%s ^1O jogador ^4%s ^1foi redirecionado para^4:", ServerTag, name);
	client_print_color(0, print_team_default, "%s ^3%s", ServerTag, gServerName[gLastRedirect]);
	client_print_color(0, print_team_default, "%s ^1Para seguir escreva: ^4/seguir ^1ou ^4/follow", ServerTag);
	return PLUGIN_HANDLED;
}

UpdateServersData()
{
	static i;
	for(i = 0; i < gserver_count; i++)
		ServerInfo(gServerIp[i], "getServerInfo");
}

public clcmdMenu(index)
{
	if(!gServerIp[0][0])
	{
		client_print_color(index, print_team_default, "%s ^1Aparentemente não há servidores ativos^4.", ServerTag);
		return PLUGIN_HANDLED;
	}

	static szBuffer[128], menu, i, szNum[4], p, mp; p = mp = 0;

	for(i = 0 ; i < gserver_count; ++i)
	{
		if(!gResponse[i] || !gServerName[i][0]) continue;
		
		p += gPlayers[i];
		mp += gMPlayers[i];
	}

	formatex(szBuffer, 127, "\r%s \yLista de servidores: ^n\y• \dJogadores na comunidade: \r%d / %d \y", ServerTagMenu, p, mp);
	menu = menu_create(szBuffer, "menu_server");

	for(i = 0 ; i < gserver_count; ++i)
	{
		if(!gResponse[i] || !gServerName[i][0] ) formatex(szBuffer, 127, "\rOFFLINE");
		else formatex(szBuffer, 127, "\%s%s \r[%d\w/\r%d]", equal(gServerIp[i], own_Server) ? "d":"w", gServerName[i], gPlayers[i], gMPlayers[i]);

		num_to_str(i, szNum, 3);
		menu_additem(menu, szBuffer, szNum);		
	}

	if(!menu_items(menu))
	{
		if(get_user_flags(index) & ADMIN_RCON)
		{
			for( i=0;i<gserver_count;++i)
				client_print(index, print_console, gServerName[i]);
		}

		client_print_color(index, print_team_default, "%s ^1Aparentemente não há servidores ativos^4.", ServerTag);
		return PLUGIN_HANDLED;
	}

	menu_display(index, menu);
	return PLUGIN_HANDLED;
}

public menu_server(index, menu, item)
{
	if(item != MENU_EXIT)
	{		
		new item_access, item_callback, szData[4], iServer;
		menu_item_getinfo(menu, item, item_access, szData, charsmax( szData ), _, _, item_callback);
		iServer = str_to_num(szData);

		if(!gResponse[iServer] || !gServerName[iServer][0])
			return PLUGIN_HANDLED;

		gSub[index] = iServer;
		show_sub_server(index);
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

show_sub_server(index)
{
	new menu, szBuffer[256];
	formatex(szBuffer, 255, "\r%s^n\dMapa: \y%s^n\dJogadores: \y%d \d/ \y%d", gServerName[gSub[index]], gMap[gSub[index]], gPlayers[gSub[index]], gMPlayers[gSub[index]]);
	menu = menu_create( szBuffer, "menu_sub" );

	menu_additem(menu, "\rEntrar!!!", "");
	menu_additem(menu, "Voltar a lista de \yservidores", "");

	menu_display(index, menu);
}

public menu_sub(index, menu, item)
{
	if(item != MENU_EXIT)
	{
		if(!item)
		{
			new name[32]; get_user_name(index, name, charsmax(name));
			gLastRedirect = gSub[index];			
			client_cmd(index, "wait;wait;wait;wait;wait;^"connect^" %s", gServerIp[gSub[index]])		

			client_print_color(0, print_team_default, "%s ^1O jogador ^4%s ^1foi redirecionado para^4:", ServerTag, name);
			client_print_color(0, print_team_default, "%s ^3%s", ServerTag, gServerName[gLastRedirect]);
			client_print_color(0, print_team_default, "%s ^1Para seguir escreva: ^4/follow ^1ou ^4/seguir", ServerTag);
		}
		else
			clcmdMenu(index);
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

LoadServers()
{
	new szPath[128];get_configsdir(szPath, charsmax(szPath));	
	formatex(szPath, charsmax(szPath), "%s/%s", szPath, ServersFile);

	if(file_exists(szPath))
	{
		new szLineData[33], file = fopen(szPath, "rt");
        
		if(!file)
		{
        	log_amx("%s Ocorreu um erro ao abrir o arquivo [fopen()]", ServerTagMenu);
        	return;
		}

		new ret, error[128];
		new Regex:regex = regex_compile("^^(?=\d+\.\d+\.\d+\.\d+\:[0-9]{1,5}$)(?:(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\.?){4}\:[0-9]{1,5}$", ret, error, charsmax(error));

		while (!feof(file))
		{
			fgets(file, szLineData, charsmax(szLineData));
			replace(szLineData, charsmax(szLineData), "^n", "");

			if (szLineData[0] == ';' || !szLineData[0] || equal(szLineData, " ")) continue;

			if(gserver_count >= MAX_SERVERS)
			{
				log_amx("%s O número máximo de servidores foi excedido [#MAX_SERVERS]", ServerTagMenu);
				continue;
			}

			if(regex_match_c(szLineData, regex, ret) > 0)
			{
				formatex(gServerIp[gserver_count], 39, szLineData);
				log_amx("%s Adicionado: %s (%d)", ServerTagMenu, szLineData, gserver_count);
				++gserver_count;
			}
		}

		regex_free(regex);

		log_amx("%s Foram carregados %d servidores", ServerTagMenu, gserver_count);
		fclose(file);
		UpdateServersData();
	}
	else 
		log_amx("%s Aparentemente o arquivo %s não existe", ServerTagMenu, ServersFile);
}

public getServerInfo(const szServer[], _A2A_TYPE, const Response[], len, success, latency)
{		
	new i, serverId = -1;
	for(i = 0; i < gserver_count; i++)
	{
		if(equal(gServerIp[i], szServer))
		{
			serverId = i;
			break;
		}
	}
	
	if(serverId == -1 || !success)
	{
		gResponse[serverId] = 0;
		return PLUGIN_HANDLED;
	}

	gResponse[serverId] = 1;
	
	new szName[256], szMap[64], szDirectory[64], szDescription[64];
	new iPlayers = 0;
	new iMaxPlayers = 0;

	ServerResponseParseInfo(Response, szName, charsmax(szName), szMap, charsmax(szMap), szDirectory, charsmax(szDirectory), szDescription, charsmax(szDescription), iPlayers, iMaxPlayers);
	
	copy(gServerName[serverId], 63, szName);
	copy(gMap[serverId], 63, szMap);
	gPlayers[serverId] = iPlayers;
	gMPlayers[serverId] = iMaxPlayers;

	return PLUGIN_HANDLED;
}
