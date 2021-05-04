#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fun>

#define PLUGIN  "ep1c gaming Brasil: Menu de Armas"
#define VERSION "1.0"
#define AUTHOR  "S H E R M A N"

#define PREFIX_MENUS "\r[ep1c gaming Brasil]"
#define PREFIX_CHAT "^4[ep1c gaming Brasil]"

/*
Cores para o Chat:

^4 = verde
^3 = cor do time
^1 = cor normal (amarelo)
*/

new xmapname[32], xRemeber[33], xSaveItem[33]

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
		set_task(0.5, "xGiveItems", id)
}

public xGiveItems(id)
{
	if(is_user_connected(id))
	{
		static xmenu2

		if(xRemeber[id])
			_xShowMenuGuns(id, xmenu2, xSaveItem[id])
		else xShowMenuGuns(id)
	}
}

public client_disconnected(id)
{
	xRemeber[id] = false
	xSaveItem[id] = false
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

		if(xRemeber[id])
			menu_additem(xMenu, "\yRelembrar seleção? \r[Sim]")
		else menu_additem(xMenu, "\yRelembrar seleção? \r[Não]")

		menu_setprop(xMenu, MPROP_EXITNAME, "Sair")
		menu_display(id, xMenu)
	}
}

public _xShowMenuGuns(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)

		return PLUGIN_HANDLED
	}

	static xTeam
	xTeam = get_user_team(id)

	switch(item)
	{
		case 0:
		{
			if(xTeam == 1) client_cmd(id,"vesthelm;ak47;deagle;secammo;primammo;hegren;flash;flash")
			else client_cmd(id,"defuser;vesthelm;m4a1;deagle;secammo;primammo;hegren;flash;flash")

			xSaveItem[id] = 0
		}

		case 1:
		{
			if(xTeam == 1) client_cmd(id,"vesthelm;ak47;usp;secammo;primammo;hegren;flash;flash")
			else client_cmd(id,"defuser;vesthelm;m4a1;usp;secammo;primammo;hegren;flash;flash")

			xSaveItem[id] = 1
		}

		case 2:
		{
			if(xTeam == 1) client_cmd(id,"vesthelm;awp;deagle;secammo;primammo;hegren;flash;flash")
			else client_cmd(id,"defuser;vesthelm;awp;deagle;secammo;primammo;hegren;flash;flash")

			xSaveItem[id] = 2
		}

		case 3:
		{
			if(xTeam == 1) client_cmd(id,"vesthelm;galil;deagle;secammo;primammo;hegren;flash;flash")
			else client_cmd(id,"defuser;vesthelm;famas;deagle;secammo;primammo;hegren;flash;flash")

			xSaveItem[id] = 3
		}

		case 4:
		{
			if( !( get_user_flags( id ) & ADMIN_CFG ) )
				client_print_color( id, id, "%s ^1Acesso ^4Negado^1.", PREFIX_CHAT );
			
			else
			{
				if(xTeam == 1)
				{
					give_item( id, "weapon_m4a1" );
					cs_set_user_bpammo( id, get_weaponid( "weapon_m4a1" ), 90 );
					client_cmd(id,"vesthelm;deagle;secammo;primammo;hegren;flash;flash")
				}

				else
				{
					give_item( id, "weapon_ak47" );
					cs_set_user_bpammo( id, get_weaponid( "weapon_ak47" ), 90 );
					client_cmd(id,"defuser;vesthelm;deagle;secammo;primammo;hegren;flash;flash")
				}
				xSaveItem[id] = 4
			}
		}

		case 5:
		{
			if(xRemeber[id])
				xRemeber[id] = false
			else xRemeber[id] = true

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
