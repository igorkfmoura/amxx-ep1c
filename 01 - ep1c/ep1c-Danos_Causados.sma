#include <amxmodx>

#define PLUGIN "ep1c: Danos causados"
#define VERSION "1.0"
#define AUTHOR "Wilian M."

new xMsgSync[2]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("Damage", "xOnDamage", "b", "2!0", "3=0", "4!0")	
	
	xMsgSync[0] = CreateHudSyncObj()	
	xMsgSync[1] = CreateHudSyncObj()
}

public xOnDamage(id)
{
	static xAttacker, xDamage
	
	xAttacker = get_user_attacker(id)
	xDamage = read_data(2)
	
	set_hudmessage(255, 0, 0, 0.45, 0.50, 0, 0.1, 3.0, 0.1, 0.1)
	ShowSyncHudMsg(id, xMsgSync[1], "%i", xDamage)	
	
	if(is_user_connected(xAttacker))
	{
		set_hudmessage(0, 100, 200, -1.0, 0.55, 0, 0.1, 3.0, 0.02, 0.02)
		ShowSyncHudMsg(xAttacker, xMsgSync[0], "%i", xDamage)		
	}
}
