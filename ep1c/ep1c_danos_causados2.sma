#include <amxmodx>
#include <reapi>

#define PLUGIN  "ep1c_danos_causados"
#define VERSION "0.1"
#define AUTHOR  "lonewolf"

enum DamageType
{
	GIVEN,
	TAKEN
};
new hud[DamageType];

enum Cvars
{
	ENABLED,
	VISIBLE_ONLY,
	RADIAL
};
new cvars[Cvars];

new spectators[MAX_PLAYERS + 1];


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	RegisterHookChain(RG_CBasePlayer_TakeDamage, "CBasePlayer_TakeDamage");
	RegisterHookChain(RG_CBasePlayer_Observer_FindNextPlayer, "CBasePlayer_Observer_FindNextPlayer_Pre");
	RegisterHookChain(RG_CBasePlayer_Observer_FindNextPlayer, "CBasePlayer_Observer_FindNextPlayer_Post", .post=1);

	bind_pcvar_num(create_cvar("amx_damage_enabled",      "1"), cvars[ENABLED]);
	bind_pcvar_num(create_cvar("amx_damage_visible_only", "1"), cvars[VISIBLE_ONLY]);
	bind_pcvar_num(create_cvar("amx_damage_radial",       "1"), cvars[RADIAL]);

	register_concmd("debug_damage", "cmd_debug_damage");

	hud[GIVEN] = CreateHudSyncObj();
	hud[TAKEN] = CreateHudSyncObj();
}


public cmd_debug_damage(id)
{
	for (new i = 1; i <= 32; ++i)
	{
		new buffer[33];
		for (new j = 0; j < 32; ++j)
		{
			buffer[j] = spectators[i] & (1 << j) ? '1' : '0';
		}
		buffer[32] = '^0';

		console_print(id, "[%s] spectators[%d]: 0b%s", PLUGIN, i, buffer);
	}
}


public client_disconnected(id)
{
	for (new i = 1; i <= 32; ++i)
	{
		spectators[i] &= ~(1 << (id - 1));
	}
}


public CBasePlayer_Observer_FindNextPlayer_Pre(const id, bool:reverse, const name[])
{
	new target = get_member(id, m_hObserverTarget);
	if (is_user_connected(target))
	{
		spectators[target] &= ~(1 << (id - 1));
	}
}


public CBasePlayer_Observer_FindNextPlayer_Post(const id, bool:reverse, const name[])
{
	new target = get_member(id, m_hObserverTarget);
	if (is_user_alive(target))
	{
		spectators[target] |=  (1 << (id - 1));
	}
}

public CBasePlayer_TakeDamage(const victim, inflictor, const attacker, Float:damage)
{
	if (is_user_connected(victim))
	{
		set_hudmessage(255, 0, 0, 0.45, 0.50, 0, 0.1, 3.0, 0.1, 0.1)
		ShowSyncHudMsg(victim, hud[TAKEN], "%.0f", damage);

		for (new i = 1; i <= 32; ++i)
		{
			if ((spectators[victim] & (1 << (i - 1))) && is_user_connected(i))
			{
				ShowSyncHudMsg(i, hud[TAKEN], "%.0f", damage);
			}
		}
	}

	if (is_user_connected(attacker))
	{
		set_hudmessage(0, 100, 200, -1.0, 0.55, 0, 0.1, 3.0, 0.02, 0.02)
		ShowSyncHudMsg(attacker, hud[GIVEN], "%.0f", damage);
		for (new i = 1; i <= 32; ++i)
		{
			if ((spectators[attacker] & (1 << (i - 1))) && is_user_connected(i))
			{
				ShowSyncHudMsg(i, hud[GIVEN], "%.0f", damage);
			}
		}
	}
	
}