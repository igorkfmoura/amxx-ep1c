#pragma semicolon 1

#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fun>

#define PLUGIN  "ep1c: Menu de Armas"
#define VERSION "1.2"
#define AUTHOR  "SHERMAN + lonewolf"

#define TASK_BUYMENU 1096
#define TASK_BUYTIME 7359

new const PREFIX_MENUS[] = "\r[ep1c gaming Brasil]\w";
new const PREFIX_CHAT[]  = "^4[ep1c gaming Brasil]^1";
new const PREFIX_CHAT_ERROR[]  = "^3[ep1c gaming Brasil]^1";

new remember_buy[MAX_PLAYERS + 1];
new item_saved[MAX_PLAYERS + 1];
new bought_this_round[MAX_PLAYERS + 1];
new do_not_open[MAX_PLAYERS + 1];

new Float:buytime;
new bool:in_buytime = true;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	bind_pcvar_float(get_cvar_pointer("mp_buytime"), buytime);

	RegisterHam(Ham_Spawn, "player", "player_spawn", true);

	register_event("HLTV", "event_new_round", "a", "1=0", "2=0");
	register_say("armas", "menu_guns");
}


public client_connected(id)
{
	remember_buy[id] = false;
	item_saved[id] = false;
	do_not_open[id] = false;
	bought_this_round[id] = false;
}


public client_disconnected(id)
{
	remember_buy[id] = false;
	item_saved[id] = false;
	do_not_open[id] = false;
	bought_this_round[id] = false;
}


public event_new_round(id)
{
	remove_task(TASK_BUYTIME);

	in_buytime = true;
	set_task((buytime * 60) - 1.0, "task_buytime", TASK_BUYTIME); // sim tô comendo 1s mas por uma boa causa
}


public task_buytime(id)
{
	for (new i = 1; i <= MaxClients; ++i)
	{
		if (is_user_alive(i) && !bought_this_round[i] && cs_get_user_buyzone(i))
		{
			// todo: check activity?
			client_print_color(i, print_team_default, "%s Compra automática pois acabou o tempo de compra!", PREFIX_CHAT);
			_menu_guns(i, 0, item_saved[i]);
		}
	}
	
	in_buytime = false;
}


public player_spawn(id)
{
	if(is_user_alive(id) && in_buytime)
	{
		bought_this_round[id] = false;
		set_task(0.5, "task_giveitems", TASK_BUYMENU + id);
	}
}


public task_giveitems(id)
{
	id -= TASK_BUYMENU;

	if(!is_user_connected(id))
	{
		return;
	}

	if (do_not_open[id])
	{
		client_print_color(id, print_team_default, "%s Para reabrir o menu de armas digite ^4/armas^1 no chat!", PREFIX_CHAT);
		return;
	}
	
	if(remember_buy[id])
	{
		_menu_guns(id, 0, item_saved[id]);
	}
	else 
	{
		menu_guns(id);
	}
}


public menu_guns(id)
{
	if(!is_user_connected(id))
	{
		return PLUGIN_HANDLED;
	}
	
	static xFmtx[512];
	formatex(xFmtx, charsmax(xFmtx), "%s \wMenu de armas", PREFIX_MENUS);

	new xMenu = menu_create(xFmtx, "_menu_guns");

	new xTeam = get_user_team(id);
	if(xTeam == 1)
	{
		menu_additem(xMenu, "Kit \d[\yAK47 + Desert\d]");
		menu_additem(xMenu, "Kit \d[\yAK47 + USP\d]");
		menu_additem(xMenu, "Kit \d[\yAWP + Desert\d]");
		menu_additem(xMenu, "Kit \d[\yGALIL + Desert\d]^n");
	}
	else
	{
		menu_additem(xMenu, "Kit \d[\yM4A1 + Desert\d]");
		menu_additem(xMenu, "Kit \d[\yM4A1 + USP\d]");
		menu_additem(xMenu, "Kit \d[\yAWP + Desert\d]");
		menu_additem(xMenu, "Kit \d[\yFAMAS + Desert\d]^n");
	}
	
	menu_additem(xMenu, "Kit \d[\rV.I.P\d]^n");
	menu_additem(xMenu, fmt("\yRelembrar seleção? %s", remember_buy[id] ? "\y[Habilitado]" : "\r[Desabilitado]"));
	menu_additem(xMenu, fmt("%s", do_not_open[id] ? "\yQuero o menu de volta no respawn" : "\rNão quero mais o menu no respawn"));
	
	menu_setprop(xMenu, MPROP_EXITNAME, "Sair");
	menu_display(id, xMenu);

	return PLUGIN_HANDLED;
}


public _menu_guns(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	if (menu)
	{
		menu_destroy(menu);
	}

	switch (item)
	{
		case 5:
		{
			remember_buy[id] = !remember_buy[id];
			menu_guns(id);
			
			return PLUGIN_HANDLED;
		}
		case 6:
		{
			do_not_open[id] = !do_not_open[id];
			menu_guns(id);
			
			return PLUGIN_HANDLED;
		}
	}
		
	new bak = item_saved[id];
	item_saved[id] = item;

	if (!is_user_alive(id))
	{
		client_print_color(id, print_team_red, "%s Armas apenas para vivos!", PREFIX_CHAT_ERROR);
		client_cmd(id, "spk fvox/fuzz");

		return PLUGIN_HANDLED;
	}

	if (!cs_get_user_buyzone(id))
	{
		client_print_color(id, print_team_red, "%s Menu de armas disponível apenas na zona de compra!", PREFIX_CHAT_ERROR);
		client_cmd(id, "spk fvox/fuzz");

		return PLUGIN_HANDLED;
	}
	else if (!in_buytime)
	{
		client_print_color(id, print_team_red, "%s Acabou o tempo de compra!", PREFIX_CHAT_ERROR);
		client_cmd(id, "spk fvox/fuzz");

		return PLUGIN_HANDLED;
	}

	new xTeam = get_user_team(id);
	bought_this_round[id] = true;

	switch(item)
	{
		case 0:
		{

			if(xTeam == 1)
			{
				client_cmd(id, "vesthelm;ak47;deagle;secammo;primammo;hegren;flash;flash");
				client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[AK47 + Desert]^1!", PREFIX_CHAT);
			}
			else 
			{
				client_cmd(id, "defuser;vesthelm;m4a1;deagle;secammo;primammo;hegren;flash;flash");
				client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[M4A1 + Desert]^1!", PREFIX_CHAT);
			}
		}
		case 1:
		{
			if(xTeam == 1)
			{
				client_cmd(id, "vesthelm;ak47;usp;secammo;primammo;hegren;flash;flash");
				client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[AK47 + USP]^1!", PREFIX_CHAT);
			}
			else 
			{
				client_cmd(id, "defuser;vesthelm;m4a1;usp;secammo;primammo;hegren;flash;flash");
				client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[M4A1 + USP]^1!", PREFIX_CHAT);
			}
		}
		case 2:
		{
			if(xTeam == 1)
			{
				client_cmd(id, "vesthelm;awp;deagle;secammo;primammo;hegren;flash;flash");
				client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[AWP + Deagle]^1!", PREFIX_CHAT);
			}
			else 
			{
				client_cmd(id, "defuser;vesthelm;awp;deagle;secammo;primammo;hegren;flash;flash");
				client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[AWP + Desert]^1!", PREFIX_CHAT);
			}
		}
		case 3:
		{
			if(xTeam == 1)
			{
				client_cmd(id, "vesthelm;galil;deagle;secammo;primammo;hegren;flash;flash");
				client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[GALIL + Desert]^1!", PREFIX_CHAT);
			}
			else 
			{
				client_cmd(id, "defuser;vesthelm;famas;deagle;secammo;primammo;hegren;flash;flash");
				client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[Famas + Desert]^1!", PREFIX_CHAT);
			}
		}
		case 4:
		{
			if(!(get_user_flags(id) & ADMIN_CFG))
			{
				item_saved[id] = bak;

				client_print_color(id, print_team_red, "%s ^1Acesso ^4Negado^1.", PREFIX_CHAT_ERROR);
				client_cmd(id, "spk fvox/fuzz");

				return PLUGIN_HANDLED;
			}
			else
			{
				if(xTeam == 1)
				{
					give_item(id, "weapon_m4a1");
					cs_set_user_bpammo(id, get_weaponid("weapon_m4a1" ), 90);
					client_cmd(id,"vesthelm;deagle;secammo;primammo;hegren;flash;flash");
					client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[M4A1 + Desert]^1!", PREFIX_CHAT);
				}

				else
				{
					give_item(id, "weapon_ak47");
					cs_set_user_bpammo(id, get_weaponid( "weapon_ak47" ), 90);
					client_cmd(id,"defuser;vesthelm;deagle;secammo;primammo;hegren;flash;flash");
					client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[AK47 + Desert]^1!", PREFIX_CHAT);
				}
			}
		}
	}

	bought_this_round[id] = true;
	return PLUGIN_HANDLED;
}


stock register_say(szsay[], szfunction[])
{
	register_clcmd(fmt("say /%s", szsay), szfunction);
	register_clcmd(fmt("say .%s", szsay), szfunction);
	register_clcmd(fmt("say_team /%s", szsay), szfunction);
	register_clcmd(fmt("say_team .%s", szsay), szfunction);
}
