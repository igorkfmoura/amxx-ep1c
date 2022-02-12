#include <amxmodx>
#include <reapi>
#include <engine>
#include <xs>

#define PLUGIN  "ep1c_damage_indicator"
#define VERSION "0.2.1"
#define AUTHOR  "lonewolf"

new const PREFIX[] = "^4[ep1c gaming Brasil]^1";

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

new bool:disabled[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	RegisterHookChain(RG_CBasePlayer_TakeDamage,  "CBasePlayer_TakeDamage", .post=1);
	RegisterHookChain(RG_CBasePlayer_TraceAttack, "CBasePlayer_TraceAttack", .post=1);

	bind_pcvar_num(create_cvar("amx_damage_enabled",      "1"), cvars[ENABLED]);
	bind_pcvar_num(create_cvar("amx_damage_visible_only", "0"), cvars[VISIBLE_ONLY]);
	bind_pcvar_num(create_cvar("amx_damage_radial",       "1"), cvars[RADIAL]);

	register_concmd("debug_damage", "cmd_debug_damage");

	register_clcmd("say /damage",      "cmd_say_damage");
	register_clcmd("say /dano",        "cmd_say_damage");
	register_clcmd("say /dmg",         "cmd_say_damage");
	register_clcmd("say_team /damage", "cmd_say_damage");
	register_clcmd("say_team /dano",   "cmd_say_damage");
	register_clcmd("say_team /dmg",    "cmd_say_damage");

	hud[GIVEN] = CreateHudSyncObj();
	hud[TAKEN] = CreateHudSyncObj();
}


public cmd_say_damage(id)
{
	disabled[id] = !disabled[id]
	client_print_color(id, print_team_red, "%s Indicador de dano %s!", PREFIX, disabled[id] ? "^3desabilitado^1" : "^4habilitado^1");

	return PLUGIN_HANDLED;
}


public cmd_debug_damage(id)
{
	for (new i = 1; i <= 32; ++i)
	{
		if (!spectators[i])
		{
			continue;
		}

		new buffer[128] = "";
		for (new j = 31; j >= 0; --j)
		{
			if (!is_user_connected(j) || is_user_alive(j))
			{
				continue;
			}
			new target = get_member(j, m_hObserverTarget);
			if (target == i && is_user_alive(target))
			{
				format(buffer, charsmax(buffer), "%s %02d", buffer, j);
			}
		}
		console_print(id, "[%s] spectators[%02d]:%s", PLUGIN, i, buffer);
	}
}


public client_disconnected(id)
{
	disabled[id] = false;
	for (new i = 1; i <= 32; ++i)
	{
		spectators[i] &= ~(1 << (id - 1));
	}
}

new lasttrace = 0;

public CBasePlayer_TraceAttack(const victim, attacker, damage, vecdir, trace, damagetype)
{
	// new inflictor = attacker;
	// show_damage(victim, inflictor, attacker, Float:damage);

	lasttrace = trace;

	return HC_CONTINUE;
}


public CBasePlayer_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	// client_print_color(0, print_team_red, "^4[%s]^1 victim: ^4%d^1, inflictor: ^4%d^1, attacker: ^4%d^1, damage: ^4%.1f^1", PLUGIN, victim, inflictor, attacker, damage);

	if (!is_user_connected(victim) || !rg_is_player_can_takedamage(victim, attacker))
	{
		return HC_CONTINUE;
	}

	new Float:hudpos[2] = {0.45, 0.50};

	if (cvars[RADIAL])
	{
		if (is_valid_ent(inflictor))
		{
			new Float:tmp[3];
			new Float:eyes[3];
			new Float:v_right[3];

			get_entvar(victim, var_origin, eyes);
			get_entvar(victim, var_view_ofs, tmp);

			xs_vec_add(eyes, tmp, eyes);

			get_entvar(victim, var_v_angle, tmp);
			angle_vector(tmp, ANGLEVECTOR_RIGHT, v_right);

			new Float:eyes_to_inflictor[3];

			get_entvar(inflictor, var_origin, eyes_to_inflictor);
			xs_vec_sub(eyes_to_inflictor, eyes, eyes_to_inflictor);
			
			xs_vec_normalize(eyes_to_inflictor, eyes_to_inflictor);

			new Float:cos = xs_vec_dot(v_right, eyes_to_inflictor);
			new Float:sin = xs_sqrt(1 - cos * cos);

			new Float:mod = 1 / (cos*cos + sin*sin);

			cos *= mod;
			sin *= mod;

			sin *= ((v_right[0] * eyes_to_inflictor[1] - v_right[1] * eyes_to_inflictor[0]) < 0.0) ? 1.0 : -1.0;

			hudpos[0] = 0.5 + cos * 0.1;
			hudpos[1] = 0.5 + sin * 0.1;
		}
	}

	set_hudmessage(255, 0, 0, hudpos[0], hudpos[1], 1, 3.0, 3.0, 0.1, 0.1);

	if (!disabled[victim])
	{
		ShowSyncHudMsg(victim, hud[TAKEN], "%.0f", damage);
	}
	
	for (new i = 1; i <= 32; ++i)
	{
		if (!disabled[i] && is_user_connected(i) && !is_user_alive(i))
		{
			new target = get_member(i, m_hObserverTarget);
			if (target == victim)
			{
				ShowSyncHudMsg(i, hud[TAKEN], "%.0f", damage);
			}
		}
	}

	if (!is_user_connected(attacker))
	{
		return HC_CONTINUE;
	}

	new bool:can_show = true;

	if (cvars[VISIBLE_ONLY])
	{
		new Float:tmp[3];
		new Float:eyes[3];

		get_entvar(attacker, var_view_ofs, eyes);
		get_entvar(attacker, var_origin, tmp);

		eyes[0] += tmp[0];
		eyes[1] += tmp[1];
		eyes[2] += tmp[2];

		get_entvar(victim, var_origin, tmp);

		new Float:fraction;
		trace_line(-1, eyes, tmp, tmp);
 		traceresult(TR_Fraction, fraction);

		can_show = (fraction == 1.0);
	}

	if (!can_show)
	{
		return HC_CONTINUE;
	}
	
	hudpos[0] = random_float(0.495, 0.505);
	hudpos[1] = random_float(0.54, 0.56);

	set_hudmessage(0, 100, 200, hudpos[0], hudpos[1], 1, 3.0, 3.0, 0.02, 0.02);
	
	if (!disabled[attacker] && (victim != attacker))
	{
		ShowSyncHudMsg(attacker, hud[GIVEN], "%.0f", damage);
	}
	
	for (new i = 1; i <= 32; ++i)
	{
		if ((i != victim) && !disabled[i] && is_user_connected(i) && !is_user_alive(i))
		{
			new target = get_member(i, m_hObserverTarget);
			if (target == attacker && is_user_alive(target))
			{
				ShowSyncHudMsg(i, hud[GIVEN], "%.0f", damage);
			}
		}
	}

	lasttrace = 0;

	return HC_CONTINUE;
}