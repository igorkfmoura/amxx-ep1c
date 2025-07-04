#include <amxmodx>
#include <reapi>
#include <jctf>

new bool:g_iBuy[MAX_PLAYERS]
new gSpr_regeneration

const TASK_HP = 55443

public plugin_precache()
{
	gSpr_regeneration = precache_model("sprites/th_jctf_heal.spr")
}

public plugin_init()
{
	shop_add_item("MENU_SPITEMS_OP_2", 100, "BuyRegenerateHp")
	register_event_ex("DeathMsg", "event_playerKilled", RegisterEvent_Global)
	
	register_dictionary("jctf.txt")
}

public client_putinserver(id)
{
	if(g_iBuy[id] || task_exists(id+TASK_HP))
	{
		remove_task(id+TASK_HP)
		g_iBuy[id] = false
	}
}

public BuyRegenerateHp(id)
{
	if(g_iBuy[id] || task_exists(id+TASK_HP))
	{
		client_print_color(id, print_team_default, "^1[^4CTF^1] %L.", id, "PRINT_ITEM_USE")
		return PLUGIN_HANDLED
	}
	
	g_iBuy[id] = true
	set_task(0.25, "player_AdrenalineDrain", id+TASK_HP, .flags="b")
	client_print_color(id, print_team_default, "^1[^4CTF^1] %L.", id, "PRINT_ITEM_HP_BUY")
	
	return PLUGIN_CONTINUE
}

public player_AdrenalineDrain(taskid)
{
	new id = taskid - TASK_HP
	new Float:iHealth = get_entvar(id, var_health)
	
	if(iHealth < 150)
	{
		set_entvar(id, var_health, iHealth + 1.0)
	}
	else
	{
		remove_task(id+TASK_HP)
		client_print_color(id, print_team_default, "^1[^4CTF^1] %L.", id, "PRINT_ITEM_HP_END")
		g_iBuy[id] = false
	}
	player_healingEffect(id)
}

public event_playerKilled()
{
	new v = read_data(2)
	if(g_iBuy[v] || task_exists(v+TASK_HP))
	{
		remove_task(v+TASK_HP)
		g_iBuy[v] = false
	}
}

player_healingEffect(id)
{
	new iOrigin[3]
	get_user_origin(id, iOrigin)

	message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin)
	write_byte(TE_PROJECTILE)
	write_coord(iOrigin[0] + random_num(-10, 10))
	write_coord(iOrigin[1] + random_num(-10, 10))
	write_coord(iOrigin[2] + random_num(0, 30))
	write_coord(0)
	write_coord(0)
	write_coord(15)
	write_short(gSpr_regeneration)
	write_byte(1)
	write_byte(id)
	message_end()
}
