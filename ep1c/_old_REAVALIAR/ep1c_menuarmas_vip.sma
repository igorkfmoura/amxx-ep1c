#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fun>

#define PLUGIN  "ep1c: Menu de Armas"
#define VERSION "1.1"
#define AUTHOR  "S H E R M A N"

#define PREFIX_MENUS "\r[ep1c gaming Brasil]"
#define PREFIX_CHAT "^4[ep1c gaming Brasil]^1"

/*
Cores para o Chat:

^4 = verde
^3 = cor do time
^1 = cor normal (amarelo)
*/

new xmapname[32], xRemember[33], xSaveItem[33], xDoNotOpen[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Spawn, "player", "xHamSpawnPost", true)

	get_mapname(xmapname, charsmax(xmapname))

	if(equal(xmapname, "awp_", 4) || equal(xmapname, "aim_", 4) || equal(xmapname, "35hp_", 5) || equal(xmapname, "fy_", 3)
	|| equal(xmapname, "he_", 3))
	{
		pause("a")
	}

	xRegisterSay("armas", "xShowMenuGuns")
}

public xHamSpawnPost(id)
{
	if(is_user_alive(id))
	{
		set_task(0.5, "xGiveItems", id)
	}
}

public xGiveItems(id)
{
	if(!is_user_connected(id))
		return;

	if (xDoNotOpen[id])
	{
		client_print_color(id, print_team_default, "%s Para reabrir o menu de armas digite ^4/armas^1 no chat!", PREFIX_CHAT)
		return;
	}
	
	static xmenu2
	if(xRemember[id])
		_xShowMenuGuns(id, xmenu2, xSaveItem[id])
	else 
		xShowMenuGuns(id)
}

public client_connected(id)
{
	xRemember[id] = false
	xSaveItem[id] = false
	xDoNotOpen[id] = false
}

public client_disconnected(id)
{
	xRemember[id] = false
	xSaveItem[id] = false
	xDoNotOpen[id] = false
}

public xShowMenuGuns(id)
{
	if(is_user_connected(id))
	{	
		static xTeam
		xTeam = get_user_team(id)

		new xFmtx[512]

		formatex(xFmtx, charsmax(xFmtx), "%s \wMenu de armas", PREFIX_MENUS)

		new xMenu = menu_create(xFmtx, "_xShowMenuGuns")

		if(xTeam == 1)
		{
			menu_additem(xMenu, "Kit \d[\yAK47 + Desert\d]")
			menu_additem(xMenu, "Kit \d[\yAK47 + USP\d]")
			menu_additem(xMenu, "Kit \d[\yAWP + Desert\d]")
			menu_additem(xMenu, "Kit \d[\yGALIL + Desert\d]^n")
		}
		else
		{
			menu_additem(xMenu, "Kit \d[\yM4A1 + Desert\d]")
			menu_additem(xMenu, "Kit \d[\yM4A1 + USP\d]")
			menu_additem(xMenu, "Kit \d[\yAWP + Desert\d]")
			menu_additem(xMenu, "Kit \d[\yFAMAS + Desert\d]^n")
		}
		
		menu_additem(xMenu, "Kit \d[\rV.I.P\d]^n" )

		if(xRemember[id])
			menu_additem(xMenu, "\yRelembrar seleção? \y[Habilitado]")
		else 
			menu_additem(xMenu, "\yRelembrar seleção? \r[Desabilitado]")

		if(xDoNotOpen[id])
			menu_additem(xMenu, "\yQuero o menu de volta no respawn")
		else
			menu_additem(xMenu, "\rNão quero mais o menu no respawn")

		menu_setprop(xMenu, MPROP_EXITNAME, "Sair")
		menu_display(id, xMenu)
	}

	return PLUGIN_HANDLED;
}

public _xShowMenuGuns(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)

		client_print_color(id, print_team_default, "%s Para reabrir o menu de armas digite ^4/armas^1 no chat!", PREFIX_CHAT)
		return PLUGIN_HANDLED
	}

	static xTeam
	xTeam = get_user_team(id)

	switch(item)
	{
		case 0:
		{
			if(xTeam == 1)
			{
				client_cmd(id,"vesthelm;ak47;deagle;secammo;primammo;hegren;flash;flash")
				client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[AK47 + Desert]^1!", PREFIX_CHAT)
			}
			else 
			{
				client_cmd(id,"defuser;vesthelm;m4a1;deagle;secammo;primammo;hegren;flash;flash")
				client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[M4A1 + Desert]^1!", PREFIX_CHAT)
			}

			xSaveItem[id] = 0

			client_print_color(id, print_team_default, "%s Para reabrir o menu de armas digite ^4/armas^1 no chat!", PREFIX_CHAT)
		}

		case 1:
		{
			if(xTeam == 1)
			{
				client_cmd(id,"vesthelm;ak47;usp;secammo;primammo;hegren;flash;flash")
				client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[AK47 + USP]^1!", PREFIX_CHAT);
			}
			else 
			{
				client_cmd(id,"defuser;vesthelm;m4a1;usp;secammo;primammo;hegren;flash;flash")
				client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[M4A1 + USP]^1!", PREFIX_CHAT);
			}


			xSaveItem[id] = 1
			client_print_color(id, print_team_default, "%s Para reabrir o menu de armas digite ^4/armas^1 no chat!", PREFIX_CHAT)
		}

		case 2:
		{
			if(xTeam == 1)
			{
				client_cmd(id,"vesthelm;awp;deagle;secammo;primammo;hegren;flash;flash")
				client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[AWP + Deagle]^1!", PREFIX_CHAT);
			}
			else 
			{
				client_cmd(id,"defuser;vesthelm;awp;deagle;secammo;primammo;hegren;flash;flash")
				client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[AWP + Desert]^1!", PREFIX_CHAT);
			}

			xSaveItem[id] = 2
			client_print_color(id, print_team_default, "%s Para reabrir o menu de armas digite ^4/armas^1 no chat!", PREFIX_CHAT)
		}

		case 3:
		{
			if(xTeam == 1)
			{
				client_cmd(id,"vesthelm;galil;deagle;secammo;primammo;hegren;flash;flash")
				client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[GALIL + Desert]^1!", PREFIX_CHAT);
			}
			else 
			{
				client_cmd(id,"defuser;vesthelm;famas;deagle;secammo;primammo;hegren;flash;flash")
				client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[Famas + Desert]^1!", PREFIX_CHAT);
			}

			xSaveItem[id] = 3
			client_print_color(id, print_team_default, "%s Para reabrir o menu de armas digite ^4/armas^1 no chat!", PREFIX_CHAT)
		}

		case 4:
		{
			if( !( get_user_flags( id ) & ADMIN_CFG ) )
				client_print_color( id, id, "%s ^1Acesso ^4Negado^1.", PREFIX_CHAT);
			
			else
			{
				if(xTeam == 1)
				{
					give_item( id, "weapon_m4a1" );
					cs_set_user_bpammo( id, get_weaponid( "weapon_m4a1" ), 90 );
					client_cmd(id,"vesthelm;deagle;secammo;primammo;hegren;flash;flash")
					client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[M4A1 + Desert]^1!", PREFIX_CHAT);
				}

				else
				{
					give_item( id, "weapon_ak47" );
					cs_set_user_bpammo( id, get_weaponid( "weapon_ak47" ), 90 );
					client_cmd(id,"defuser;vesthelm;deagle;secammo;primammo;hegren;flash;flash")
					client_print_color(id, print_team_default, "%s Você recebeu o kit ^4[AK47 + Desert]^1!", PREFIX_CHAT);
				}
				
				xSaveItem[id] = 4
				client_print_color(id, print_team_default, "%s Para reabrir o menu de armas digite ^4/armas^1 no chat!", PREFIX_CHAT)
			}
		}

		case 5:
		{
			xRemember[id] = !xRemember[id];

			menu_destroy(menu);
			xShowMenuGuns(id)
		}
		case 6:
		{
			xDoNotOpen[id] = !xDoNotOpen[id];
			
			menu_destroy(menu)
			xShowMenuGuns(id)
		}
	}

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
