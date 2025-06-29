#include <amxmodx>
#include <jctf>

#define MAX_ITEM 10

enum _:ITEMS
{
	ITEM_NAME[32],
	ITEM_COST,
	ITEM_FORWARD
}

new g_szItem[MAX_ITEM][ITEMS], g_TotalItems

public plugin_init()
{
	register_plugin("Shop Natives", "1.2", "Sugisaki")
	
	register_clcmd("say /adrenaline", "pfn_shop_adrenaline")
	register_clcmd("say_team /adrenaline", "pfn_shop_adrenaline")
	
	register_dictionary("jctf.txt")
}

public plugin_natives()
{
	register_native("shop_add_item", "_native_add_item")
	register_native("display_shop", "pfn_shop_adrenaline", 1)
}

public _native_add_item(pid, par)
{
	if(g_TotalItems >= MAX_ITEM)
	{
		log_amx("Maximo de items (%i) alcanzado, Modifica el plugin de la tienda.",  MAX_ITEM)
		return PLUGIN_HANDLED
	}
	
	if(get_param(2) > 100)
	{
		log_amx("El item #%d sobrepaso el valor de 100 de adrenalina.", g_TotalItems)
		return PLUGIN_HANDLED
	}
	new FWD[32]
	g_szItem[g_TotalItems][ITEM_COST] = get_param(2)
	get_string(1, g_szItem[g_TotalItems][ITEM_NAME], 31)
	get_string(3, FWD, charsmax(FWD))
	if(get_func_id(FWD, pid) == -1)
	{
		new pluginfilename[32]
		get_plugin(pid, pluginfilename, charsmax(pluginfilename));
		log_amx("[%s]Funcion %s Inexistente", pluginfilename, FWD);
		return PLUGIN_HANDLED
	}
	if((g_szItem[g_TotalItems][ITEM_FORWARD] = CreateOneForward(pid, FWD, FP_CELL, FP_STRING)) == -1)
	{
		log_amx("Ocurrio un error al crear la funcion %s", FWD)
		return PLUGIN_HANDLED
	}
	g_TotalItems++
	return PLUGIN_CONTINUE
}

public pfn_shop_adrenaline(id)
{
	new temp[5], menu
	menu = menu_create(fmt("\rjCTF \w%L", id, "MENU_SPITEMS_HEADER", get_user_adrenaline(id), 100), "buymenu_handled")
	
	for(new i = 0; i < g_TotalItems; i++)
	{
		num_to_str(i, temp, charsmax(temp))
		menu_additem(menu, fmt("\d[\y%d\d] \w%s", g_szItem[i][ITEM_COST], g_szItem[i][ITEM_NAME]), temp)
	}
	
	menu_setprop(menu, MPROP_BACKNAME, fmt("%L", id, "MENU_BACK"))
	menu_setprop(menu, MPROP_NEXTNAME, fmt("%L", id, "MENU_NEXT"))
	menu_setprop(menu, MPROP_EXITNAME, fmt("%L", id, "MENU_EXIT"))
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
	
	return PLUGIN_HANDLED
}

public buymenu_handled(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	new cost = get_user_adrenaline(id)
	if(g_szItem[item][ITEM_COST] > cost)
	{
		client_print_color(id, print_team_default, "^1[^4CTF^1] %L.", id, "PRINT_ADR_LOW")
		return PLUGIN_HANDLED
	}
	
	new ret//, g_forward
	//g_forward = CreateMultiForward(g_szItem[item][ITEM_FORWARD], ET_STOP, FP_CELL, FP_STRING)
	ExecuteForward(g_szItem[item][ITEM_FORWARD], ret, id, g_szItem[item][ITEM_NAME]);
	if(ret == PLUGIN_HANDLED)
	{
		return PLUGIN_HANDLED
	}
	set_user_adrenaline(id, cost - g_szItem[item][ITEM_COST])
	return PLUGIN_CONTINUE
}
