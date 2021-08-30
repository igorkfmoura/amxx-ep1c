#include <amxmodx>
#include <reapi>

const WARMUP_TIME = 45;
static const g_szSound[] = "ep1cgaming/ep1c_knife_rr.wav";

const TASK = 100;
new g_hookEventCurWeapon, HookChain:g_hookRoundRestart, HookChain:g_hookSpawn, HookChain:g_hookKilled;
new gCount;

public plugin_precache()
{
	precache_sound(g_szSound);
}

public plugin_init()
{
	register_plugin("ep1c: Aquecimento 2.0", "0.1", "unnamed");
	
	disable_event((g_hookEventCurWeapon = register_event("CurWeapon", "switchweapon", "be", "1=1", "2!29")));
	g_hookRoundRestart = RegisterHookChain(RG_CSGameRules_RestartRound, "CSGameRules_RestartRound_Pre", false);
	DisableHookChain((g_hookSpawn = RegisterHookChain(RG_CBasePlayer_Spawn, "CBasePlayer_Spawn_Post", true)));
	DisableHookChain((g_hookKilled = RegisterHookChain(RG_CBasePlayer_Killed, "CBasePlayer_Killed_Post", true)));
}

public CSGameRules_RestartRound_Pre()
{
	if(get_member_game(m_bCompleteReset))
	{
		gCount = WARMUP_TIME;
		EnableHookChain(g_hookSpawn);
		EnableHookChain(g_hookKilled);
		DisableHookChain(g_hookRoundRestart);
		enable_event(g_hookEventCurWeapon);
		
		server_cmd("sv_gravity 800");
		if(task_exists(TASK)) remove_task(TASK);
		set_task(1.0, "DisableRR", TASK, .flags = "a", .repeat = WARMUP_TIME);
	}
}

public CBasePlayer_Spawn_Post(const this)
{
	if(is_user_connected(this))
	{
		set_entvar(this, var_health, 35.0);
	}
}

public CBasePlayer_Killed_Post(const this)
{
	set_task(1.0, "respawn_player", this);
}

public switchweapon(id)
{
	engclient_cmd(id, "weapon_knife");
}

public respawn_player(id)
{ 
	if(is_user_connected(id) && !is_user_alive(id) && TEAM_TERRORIST <= get_member(id, m_iTeam) <= TEAM_CT)
	{
		rg_round_respawn(id);
	} 
}

public DisableRR()
{
	if(--gCount > 0)
		client_print(0, print_center, "Modo aquecimento: O jogo começará em %d segundos", gCount);
	else	client_print(0, print_center, "Modo aquecimento concluido!");
	
	switch(gCount)
	{
		case 10: client_cmd(0, "spk sound/%s", g_szSound);
		case 0:  
		{
			DisableHookChain(g_hookSpawn);
			DisableHookChain(g_hookKilled);
			disable_event(g_hookEventCurWeapon);
		
			set_cvar_num("sv_restart", 2);
			server_cmd("sv_gravity 800");
		}
	}
}
