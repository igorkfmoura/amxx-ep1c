#include <amxmodx>
#include <reapi>
#include <fakemeta>

#define PLUGIN   "ep1c_ctf_warmup_novembro_azul"
#define VERSION  "0.3.1"
#define AUTHOR   "lonewolf"

new const PREFIX[] = "^4[ep1c gaming Brasil]^1";
static const g_szSound[] = "ep1c/ep1c_knife_rr.wav";

const TASK = 100;
new g_hookEventCurWeapon, HookChain:g_hookRoundRestart, HookChain:g_hookSpawn, HookChain:g_hookKilled;
new gCount;

new forcerespawn_bak;
new alltalk_bak;

enum _:Cvars
{
    ENABLED,
    TIME
};
new cvars[Cvars];

new v_knife_path[] = "models/ep1c/wpn/v_knife_NA2.mdl";
new w_knife_path[] = "models/ep1c/wpn/w_knife_NA.mdl";
new p_knife_path[] = "models/ep1c/wpn/p_knife_NA.mdl";

new id_FM_SetModel;
new id_CurWeapon_Knife;
new hudsyncobj;

public plugin_precache()
{
    precache_sound(g_szSound);
    precache_model(v_knife_path);
    precache_model(w_knife_path);
    precache_model(p_knife_path);
}


public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    cvars[ENABLED] = create_cvar("amx_warmup",      "1");
    cvars[TIME]    = create_cvar("amx_warmup_time", "45");

    register_concmd("amx_warmup_end",   "cmd_warmup_end",   ADMIN_CVAR);
    register_concmd("amx_warmup_start", "cmd_warmup_start", ADMIN_CVAR);

    g_hookEventCurWeapon = register_event("CurWeapon", "switchweapon", "be", "1=1", "2!29")
    disable_event(g_hookEventCurWeapon);
    
    g_hookSpawn        = RegisterHookChain(RG_CBasePlayer_Spawn, "CBasePlayer_Spawn_Post", true);
    g_hookRoundRestart = RegisterHookChain(RG_CSGameRules_RestartRound, "CSGameRules_RestartRound_Pre", false);
    g_hookKilled       = RegisterHookChain(RG_CBasePlayer_Killed, "CBasePlayer_Killed_Post", true);

    DisableHookChain(g_hookSpawn);
    DisableHookChain(g_hookKilled);

    hudsyncobj = CreateHudSyncObj();

    if (!get_pcvar_num(cvars[ENABLED]))
    {
        DisableHookChain(g_hookRoundRestart);
    }

    set_cvar_num("sv_restart", 6);
}

public FM_SetModel_Post(ent, model[])
{
    if (!pev_valid(ent))
    {
        return FMRES_IGNORED;
    }

    if (equali(model, "models/w_knife.mdl"))
    {
        engfunc(EngFunc_SetModel, ent, w_knife_path);
        return FMRES_SUPERCEDE;
    }
    
    return FMRES_IGNORED;
}


public CurWeapon_Knife(id)
{
    if(!is_user_alive(id))
    {
        return PLUGIN_CONTINUE;
    }
    
    new ret = PLUGIN_CONTINUE;

    static model[32]
    pev(id, pev_viewmodel2, model, charsmax(model))

    if (equali(model, "models/v_knife.mdl"))
    {
        set_pev(id,pev_viewmodel2, v_knife_path);
        ret = PLUGIN_HANDLED;
    }
    
    pev(id,pev_weaponmodel2, model, charsmax(model));
    if (equali(model, "models/p_knife.mdl"))
    {
        set_pev(id, pev_weaponmodel2, p_knife_path);
        ret = PLUGIN_HANDLED;
    }
    
    return ret;
}

public cmd_warmup_start(id)
{
    gCount = get_pcvar_num(cvars[TIME]);

    enable_event(g_hookEventCurWeapon);

    EnableHookChain(g_hookSpawn);
    // EnableHookChain(g_hookKilled);

    id_FM_SetModel = register_forward(FM_SetModel, "FM_SetModel_Hook", 1);
    id_CurWeapon_Knife = register_event("CurWeapon","CurWeapon_Knife","be","1=1");


    DisableHookChain(g_hookRoundRestart);
    
    server_cmd("sv_gravity 800");
    set_cvar_num("amx_maxjumps", 99999);
    set_cvar_num("ctf_menuarmas", 0);

    alltalk_bak = get_cvar_num("sv_alltalk");
    set_cvar_num("sv_alltalk", 1);
    forcerespawn_bak = get_cvar_num("mp_forcerespawn");
    set_cvar_num("mp_forcerespawn", 1);
  

    if (task_exists(TASK))
    {
        remove_task(TASK);
    }

    rg_restart_round();
    set_task(1.0, "DisableRR", TASK, .flags = "a", .repeat = gCount);

    return PLUGIN_HANDLED;
}

public cmd_warmup_end(id)
{
    DisableHookChain(g_hookSpawn);
    // DisableHookChain(g_hookKilled);
    DisableHookChain(g_hookRoundRestart);
    disable_event(g_hookEventCurWeapon);
    disable_event(id_CurWeapon_Knife);
    unregister_forward(FM_SetModel, id_FM_SetModel, 1);

    if (task_exists(TASK))
    {
        remove_task(TASK);
    }

    set_cvar_num("amx_maxjumps", 1);
    // set_cvar_num("mp_autoteambalance", 2);
    set_cvar_num("ctf_menuarmas", 1);
    set_cvar_num("sv_alltalk", alltalk_bak);
    set_cvar_num("mp_forcerespawn", forcerespawn_bak);
  
  
    client_cmd(0, "stopsound");
    
    client_print_color(0, print_team_red, "%s O clã ^4ep1c gaming Brasil^1 te deseja uma excelente partida!", PREFIX)
    client_print_color(0, print_team_red, "%s Bom jogos ^3lixeirinhas^1! rsrs", PREFIX)
    client_print_color(0, print_team_red, "%s ^3xunk^1 <51 98968-5679> & ^4SHERMAN^1 <11 98015-7379>", PREFIX);
    client_print_color(0, print_team_red, "%s Estamos no Instagram! ^3@ep1cgamingbr^1", PREFIX);

    set_cvar_num("sv_restart", 1)
    
    server_cmd("ctf_match_start");
    
    return PLUGIN_HANDLED;
}

public CSGameRules_RestartRound_Pre()
{
    if (get_member_game(m_bCompleteReset))
    {
        cmd_warmup_start(0);
    }
}

public CBasePlayer_Spawn_Post(const this)
{
    if(is_user_connected(this))
    {
        set_entvar(this, var_health, 24.0);
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
    {
        client_print(0, print_center, "Modo aquecimento: O jogo começará em %d segundo%c", gCount, (gCount == 1) ? ' ' : 's');

        new r = random_num(0, 255);
        new g = random_num(0, 255);
        new b = random_num(0, 255);

        set_dhudmessage(r, g, b, -1.0, 0.7+random_float(-0.05, 0.05), 1, 1.0, 1.0);
        // ShowSyncHudMsg(0, hudsyncobj, "All Talk ON", r, g, b, 0.03, 0.25, 0, 1.0, 1.0);
        show_dhudmessage(0, "All Talk ON");
    }
    else
    {
        client_print(0, print_center, "Modo aquecimento concluido!");
    }
    
    if (gCount == 10)
    {
        client_cmd(0, "spk sound/%s", g_szSound);
    }
    else if (gCount <= 0)
    {
        cmd_warmup_end(0);
    }
}
