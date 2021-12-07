#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
 
#define PLUGIN "ep1c: Dinheiro Infinito"
#define VERSION "1.0"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, "Wilian M.")
	
	RegisterHam(Ham_Spawn, "player", "xHam_Spawn", 1)
}

public xHam_Spawn(id)
{
	if(is_user_connected(id) && is_user_alive(id))
	{
		if(cs_get_user_money(id) < 16000)
			cs_set_user_money(id, 16000)
	}
}
