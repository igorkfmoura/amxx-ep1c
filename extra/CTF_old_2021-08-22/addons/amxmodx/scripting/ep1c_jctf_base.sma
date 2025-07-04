#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <reapi>
#include <jctf>
#include <xs>

#define PLUGIN  "ep1c-jctf"
#define VERSION "1.32o.1"
#define AUTHOR  "Digi + lonewolf"

#define GAME_DESCRIPTION "[PEGA BANDEIRA.]"

#define DEBUG(%1) client_print(%1)

#define player_allowChangeTeam(%1) (get_ent_data((%1), "CBasePlayer", "m_bTeamChanged", false))

const ADMIN_RETURN     = ADMIN_RCON; // access required for admins to return flags (full list in includes/amxconst.inc)
const ADMIN_RETURNWAIT = 15;         // time the flag needs to stay dropped before it can be returned by command

new const Float:BASE_HEAL_DISTANCE = 96.0; // healing distance for flag

new const FLAG_SAVELOCATION[] = "maps/%s.ctf"; // you can change where .ctf files are saved/loaded from

new const INFO_TARGET[] = "info_target";

new const BASE_CLASSNAME[] = "ctf_flagbase";
new const Float:BASE_THINK = 0.25;

new const TASK_CLASSNAME[] = "ctf_think_task";
new const Float:TASK_THINK = 1.0;

new const FLAG_CLASSNAME[] = "ctf_flag"
new const FLAG_MODEL[]     = "models/ep1c/ctf_flag_ep1c_03.mdl"

const TASK_EQUIPAMENT  = 6451;
const LIMIT_ADRENALINE = 100;

new const Float:FLAG_THINK = 0.1;
const FLAG_SKIPTHINK = 20; /* FLAG_THINK * FLAG_SKIPTHINK = 2.0 seconds ! */

new const Float:FLAG_HULL_MIN[3]       = {-2.0, -2.0, 0.0};
new const Float:FLAG_HULL_MAX[3]       = {2.0, 2.0, 16.0};
new const Float:FLAG_SPAWN_VELOCITY[3] = {0.0, 0.0, -500.0};
new const Float:FLAG_SPAWN_ANGLES[3]   = {0.0, 0.0, 0.0};
new const Float:FLAG_DROP_VELOCITY[3]  = {0.0, 0.0, 50.0};
new const Float:FLAG_PICKUPDISTANCE    = 80.0;

const FLAG_ANI_DROPPED  = 0;
const FLAG_ANI_STAND    = 1;
const FLAG_ANI_BASE     = 2;
const FLAG_HOLD_BASE    = 33;
const FLAG_HOLD_DROPPED = 34;

new const CHAT_PREFIX[]    = "^4[ep1c gaming Brasil]^1 ";
new const CONSOLE_PREFIX[] = "[ep1c gaming Brasil] ";

#define HUD_HINT            255,  255, 255, 0.15,  -0.3, 0, 0.0, 10.0
#define HUD_HELP            255,  255, 0,   -1.0,  0.2,  2, 1.0, 1.5, .fadeintime=0.03
#define HUD_HELP2           255,  255, 0,   -1.0,  0.25, 2, 1.0, 1.5, .fadeintime=0.03
#define HUD_ANNOUNCE        -1.0, 0.3, 2,   1.0,   3.0, .fadeintime = 0.03
#define HUD_RESPAWN         0,    255, 0,   -1.0,  0.6,  2, 1.0, 0.8, .fadeintime=0.03
#define HUD_PROTECTION      255,  255, 0,   -1.0,  0.6,  2, 1.0, 0.8, .fadeintime=0.03
#define HUD_ADRENALINE      0,    255, 0,   0.03, 0.3,  0, 1.0, 1.0
#define HUD_ADRENALINE_FULL 0,    255, 0,   0.03, 0.3,  1, 1.0, 1.0

#define get_opTeam(%1) ((%1) == TEAM_BLUE ? TEAM_RED : ((%1) == TEAM_RED ? TEAM_BLUE : 0))

enum
{
    x,
    y,
    z
};

enum
{
    TEAM_NONE = 0,
    TEAM_RED,
    TEAM_BLUE,
    TEAM_SPEC
};

new const g_szCSTeams[][] =
{
    "",
    "TERRORIST",
    "CT",
    "SPECTATOR"
};

new const g_szTeamName[][] =
{
    "",
    "Red",
    "Blue",
    "Spectator"
};

new const g_szMLFlagTeam[][] =
{
    "",
    "FLAG_RED",
    "FLAG_BLUE",
    ""
};

enum
{
    REWARD_CAPTURED = 15,
    REWARD_RETURNED = 10,
    REWARD_STOLEN   = 100,
    REWARD_DROPPED  = 15,
    REWARD_FRAG     = 3
};

enum
{
    FLAG_STOLEN,
    FLAG_PICKED,
    FLAG_DROPPED,
    FLAG_MANUALDROP,
    FLAG_RETURNED,
    FLAG_CAPTURED,
    FLAG_AUTORETURN,
    FLAG_ADMINRETURN
};

enum
{
    EVENT_TAKEN,
    EVENT_DROPPED,
    EVENT_RETURNED,
    EVENT_SCORE,
};

new const g_szSounds[][][] =
{
    { "", "red_flag_taken",    "blue_flag_taken" },
    { "", "red_flag_dropped",  "blue_flag_dropped" },
    { "", "red_flag_returned", "blue_flag_returned" },
    { "", "red_team_scores",   "blue_team_scores" }
};

new const g_szRemoveEntities[][] =
{
    "armoury_entity",
    "func_bomb_target",
    "info_bomb_target",
    "hostage_entity",
    "monster_scientist",
    "func_hostage_rescue",
    "info_hostage_rescue",
    "info_vip_start",
    "func_vip_safetyzone",
    "func_escapezone",
    "info_map_parameters"
};

new g_iMaxPlayers;
new g_iScore[3];
new g_iSync[4];
new g_iFlagHolder[3];
new g_iFlagEntity[3];
new g_iBaseEntity[3];
new g_iTeam[33];
new Float:g_fFlagDropped[3];

new bool:g_bRestarting;
new bool:g_bAlive[33];
new bool:g_bAssisted[33][3];
new bool:g_bProtected[33];
new bool:g_bRespawned[33];
new g_bRespawn[33];
new g_bProtecting[33];
new g_bAdrenaline[33];
new g_bPlayerName[33][33];

new Float:g_fFlagBase[3][3];
new Float:g_fFlagLocation[3][3];
new Float:g_fLastDrop[33];

new pCvar_ctf_flagheal;
new pCvar_ctf_flagreturn;
new pCvar_ctf_respawntime;
new pCvar_ctf_protection;
new pCvar_ctf_blockkill;

new pCvar_ctf_sound[4];

new gMsg_RoundTime;
new gMsg_HostageK;
new gMsg_HostagePos;
new gMsg_TeamScore;

new gHook_EntSpawn;
new gSpr_regeneration;

new g_iForwardReturn;
new g_iFW_flag;
new g_iFW_adrenaline;

public plugin_precache()
{
    precache_model(FLAG_MODEL);
    
    gSpr_regeneration = precache_model("sprites/th_jctf_heal.spr");
    
    for(new i = 0; i < sizeof g_szSounds; i++)
    {
        for(new t = 1; t <= 2; t++)
        {
            precache_generic(fmt("sound/jctf/%s.mp3", g_szSounds[i][t]));
        }
    }
    gHook_EntSpawn = register_forward(FM_Spawn, "ent_spawn");
}

public ent_spawn(ent)
{
    if(!is_valid_ent(ent))
    {
        return FMRES_IGNORED;
    }
    
    new szClass[32]
    entity_get_string(ent, EV_SZ_classname, szClass, charsmax(szClass));
    
    for(new i = 0; i < sizeof g_szRemoveEntities; i++)
    {
        if(equal(szClass, g_szRemoveEntities[i]))
        {
            remove_entity(ent);
            return FMRES_SUPERCEDE;
        }
    }
    return FMRES_IGNORED;
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_cvar("jctf_version", VERSION, (FCVAR_SERVER|FCVAR_SPONLY));
    
    unregister_forward(FM_Spawn, gHook_EntSpawn);
    register_touch(FLAG_CLASSNAME, "player", "flag_touch");
    register_think(FLAG_CLASSNAME, "flag_think");
    register_think(BASE_CLASSNAME, "base_think");
    register_think(TASK_CLASSNAME, "task_think");
    
    new task = create_entity(INFO_TARGET)
    if(task)
    {
        entity_set_string(task, EV_SZ_classname, TASK_CLASSNAME);
        entity_set_float(task, EV_FL_nextthink, get_gametime() + TASK_THINK);
    }
    
    register_logevent("event_restartGame", 2, "1&Restart_Round", "1&Game_Commencing");
    
    register_event_ex("HLTV",     "event_roundStart",   RegisterEvent_Global, "1=0", "2=0");
    register_event_ex("DeathMsg", "event_playerKilled", RegisterEvent_Global);
    register_event_ex("TeamInfo", "player_joinTeam",    RegisterEvent_Global);
    
    RegisterHookChain(RG_HandleMenu_ChooseAppearance, "pfn_ChooseAppearance");
    RegisterHookChain(RG_CBasePlayer_Spawn,           "pfn_PlayerSpawn", true);
    RegisterHookChain(RG_CBasePlayer_TraceAttack,     "pfn_TraceAttack");
    
    register_clcmd("ctf_moveflag", "admin_cmd_moveFlag",   ADMIN_RCON, "<red/blue> - Moves team's flag base to your origin (for map management)");
    register_clcmd("ctf_save",     "admin_cmd_saveFlags",  ADMIN_RCON);
    register_clcmd("ctf_return",   "admin_cmd_returnFlag", ADMIN_RETURN);
    
    register_clcmd("say /dropflag", "player_cmd_dropFlag");
    
    register_clcmd("radio1", "player_hook_dropflag");
    register_clcmd("radio2", "player_hook_dropflag");
    register_clcmd("radio3", "player_hook_dropflag");
    
    gMsg_HostagePos = get_user_msgid("HostagePos");
    gMsg_HostageK   = get_user_msgid("HostageK");
    gMsg_RoundTime  = get_user_msgid("RoundTime");
    gMsg_TeamScore  = get_user_msgid("TeamScore");
    
    register_message(gMsg_RoundTime, "msg_roundTime");
    register_message(gMsg_TeamScore, "msg_teamScore");
    
    set_msg_block(get_user_msgid("ClCorpse"), BLOCK_SET);
    
    pCvar_ctf_flagheal    = register_cvar("ctf_flagheal", "1");
    pCvar_ctf_flagreturn  = register_cvar("ctf_flagreturn", "200");
    pCvar_ctf_respawntime = register_cvar("ctf_respawntime", "6");
    pCvar_ctf_protection  = register_cvar("ctf_protection", "5");
    pCvar_ctf_blockkill   = register_cvar("ctf_blockkill", "0");
    
    pCvar_ctf_sound[EVENT_TAKEN]    = register_cvar("ctf_sound_taken", "1");
    pCvar_ctf_sound[EVENT_DROPPED]  = register_cvar("ctf_sound_dropped", "1");
    pCvar_ctf_sound[EVENT_RETURNED] = register_cvar("ctf_sound_returned", "1");
    pCvar_ctf_sound[EVENT_SCORE]    = register_cvar("ctf_sound_score", "1");
    
    g_iFW_flag = CreateMultiForward("jctf_flag", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL);
    g_iFW_adrenaline = CreateMultiForward("jctf_adrenaline", ET_IGNORE, FP_CELL, FP_CELL);
    //ExecuteForward(g_iFW_flag, g_iForwardReturn, FLAG_RETURNED, id, iFlagTeam, false);

    g_iSync[0] = CreateHudSyncObj();
    g_iSync[1] = CreateHudSyncObj();
    g_iSync[2] = CreateHudSyncObj();
    g_iSync[3] = CreateHudSyncObj();
    
    g_iMaxPlayers = get_maxplayers();

    set_member_game(m_GameDesc, GAME_DESCRIPTION);
    register_dictionary("jctf.txt");
}

public plugin_cfg()
{
    new szFile[44], szMap[32];
    
    get_mapname(szMap, charsmax(szMap));
    formatex(szFile, charsmax(szFile), FLAG_SAVELOCATION, szMap);
    
    new hFile = fopen(szFile, "rt");
    if(hFile)
    {
        new iFlagTeam = TEAM_RED;
        new szData[24];
        new szOrigin[3][6];
        
        while(fgets(hFile, szData, charsmax(szData)))
        {
            if(iFlagTeam > TEAM_BLUE)
                break;
            
            trim(szData);
            parse(szData, szOrigin[x], charsmax(szOrigin[]), szOrigin[y], charsmax(szOrigin[]), szOrigin[z], charsmax(szOrigin[]));
            
            g_fFlagBase[iFlagTeam][x] = str_to_float(szOrigin[x]);
            g_fFlagBase[iFlagTeam][y] = str_to_float(szOrigin[y]);
            g_fFlagBase[iFlagTeam][z] = str_to_float(szOrigin[z]);
            
            iFlagTeam++;
        }
        fclose(hFile);
    }
    flag_spawn(TEAM_RED);
    flag_spawn(TEAM_BLUE);
    
    set_task(5.0, "plugin_cfg_post");
}

public plugin_cfg_post()
{
    set_cvar_num("mp_buytime", -1);
    set_cvar_num("mp_refill_bpammo_weapons", 2);
    set_cvar_num("mp_item_staytime", 15);
    set_cvar_string("mp_round_infinite", "f");
}

public plugin_natives()
{
    register_library("jctf");
    register_native("jctf_get_flagcarrier", "native_get_flagcarrier");
    
    register_native("get_user_adrenaline", "native_get_adrenaline");
    register_native("set_user_adrenaline", "native_set_adrenaline");
    register_native("add_user_adrenaline", "native_add_adrenaline");
}

public native_get_adrenaline(iPlugin, iParams)
{
    return g_bAdrenaline[get_param(1)];
}

public native_set_adrenaline(iPlugin, iParams)
{
    g_bAdrenaline[get_param(1)] = get_param(2);
}

public native_add_adrenaline(iPlugin, iParams)
{
    g_bAdrenaline[get_param(1)] += get_param(2);
}

public plugin_end()
{
    DestroyForward(g_iFW_flag);
    DestroyForward(g_iFW_adrenaline);
}

public native_get_flagcarrier(iPlugin, iParams)
{
    new id = get_param(1);
    return g_iFlagHolder[get_opTeam(g_iTeam[id])] == id;
}

public jctf_flag(iEvent, iPlayer, iFlagTeam, bool:bAssist)
{
    switch(iEvent)
    {
        case FLAG_CAPTURED: g_bAdrenaline[iPlayer] = clamp(g_bAdrenaline[iPlayer] + REWARD_CAPTURED, 0, LIMIT_ADRENALINE);
        case FLAG_RETURNED: g_bAdrenaline[iPlayer] = clamp(g_bAdrenaline[iPlayer] + REWARD_RETURNED, 0, LIMIT_ADRENALINE);
        case FLAG_STOLEN:   g_bAdrenaline[iPlayer] = clamp(g_bAdrenaline[iPlayer] + REWARD_STOLEN,   0, LIMIT_ADRENALINE);
        case FLAG_DROPPED:  g_bAdrenaline[iPlayer] = clamp(g_bAdrenaline[iPlayer] - REWARD_DROPPED,  0, LIMIT_ADRENALINE);
    } 
    return PLUGIN_HANDLED;
}

public client_kill(id)
{
    return get_pcvar_num(pCvar_ctf_blockkill) ? PLUGIN_HANDLED : PLUGIN_CONTINUE;
}

public flag_spawn(iFlagTeam)
{
    if(g_fFlagBase[iFlagTeam][x] == 0.0 && g_fFlagBase[iFlagTeam][y] == 0.0 && g_fFlagBase[iFlagTeam][z] == 0.0)
    {
        new iFindSpawn = find_ent_by_class(g_iMaxPlayers, iFlagTeam == TEAM_BLUE ? "info_player_start" : "info_player_deathmatch");

        if(iFindSpawn)
        {
            entity_get_vector(iFindSpawn, EV_VEC_origin, g_fFlagBase[iFlagTeam]);
            
            server_print("[CTF] %s flag origin not defined, set on player spawn.", g_szTeamName[iFlagTeam]);
            log_error(AMX_ERR_NOTFOUND, "[CTF] %s flag origin not defined, set on player spawn.", g_szTeamName[iFlagTeam]);
        }
        else
        {
            server_print("[CTF] WARNING: player spawn for ^"%s^" team does not exist !", g_szTeamName[iFlagTeam]);
            log_error(AMX_ERR_NOTFOUND, "[CTF] WARNING: player spawn for ^"%s^" team does not exist !", g_szTeamName[iFlagTeam]);
            set_fail_state("Player spawn unexistent!");
            
            return PLUGIN_CONTINUE;
        }
    }
    else
    {
        server_print("[CTF] %s flag and base spawned at: %.1f %.1f %.1f", g_szTeamName[iFlagTeam], g_fFlagBase[iFlagTeam][x], g_fFlagBase[iFlagTeam][y], g_fFlagBase[iFlagTeam][z]);
    }
    
    new ent;
    new Float:fGameTime = get_gametime();
    
    // the FLAG
    
    ent = create_entity(INFO_TARGET);
    
    if(!ent)
        return flag_spawn(iFlagTeam);
    
    entity_set_model(ent, FLAG_MODEL);
    entity_set_string(ent, EV_SZ_classname, FLAG_CLASSNAME);
    entity_set_int(ent, EV_INT_body, 1);
    entity_set_int(ent, EV_INT_skin, iFlagTeam == 1 ? 1 : 2);
    entity_set_int(ent, EV_INT_sequence, FLAG_ANI_STAND);
    DispatchSpawn(ent);
    entity_set_origin(ent, g_fFlagBase[iFlagTeam]);
    entity_set_size(ent, FLAG_HULL_MIN, FLAG_HULL_MAX);
    entity_set_vector(ent, EV_VEC_velocity, FLAG_SPAWN_VELOCITY);
    entity_set_vector(ent, EV_VEC_angles, FLAG_SPAWN_ANGLES);
    entity_set_edict(ent, EV_ENT_aiment, 0);
    entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
    entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER);
    entity_set_float(ent, EV_FL_framerate, 1.0);
    entity_set_float(ent, EV_FL_gravity, 2.0);
    entity_set_float(ent, EV_FL_nextthink, fGameTime + FLAG_THINK);
    
    g_iFlagEntity[iFlagTeam] = ent;
    g_iFlagHolder[iFlagTeam] = FLAG_HOLD_BASE;
    
    // flag BASE
    
    ent = create_entity(INFO_TARGET);
    
    if(!ent)
        return flag_spawn(iFlagTeam);
    
    entity_set_string(ent, EV_SZ_classname, BASE_CLASSNAME);
    entity_set_model(ent, FLAG_MODEL);
    entity_set_int(ent, EV_INT_body, 0);
    entity_set_int(ent, EV_INT_sequence, FLAG_ANI_BASE);
    DispatchSpawn(ent);
    entity_set_origin(ent, g_fFlagBase[iFlagTeam]);
    entity_set_vector(ent, EV_VEC_velocity, FLAG_SPAWN_VELOCITY);
    entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
    
    entity_set_float(ent, EV_FL_renderamt, 100.0);
    entity_set_float(ent, EV_FL_nextthink, fGameTime + BASE_THINK);
    
    g_iBaseEntity[iFlagTeam] = ent;
    return PLUGIN_CONTINUE;
}

public flag_think(ent)
{
    if(!is_valid_ent(ent))
        return;
    
    entity_set_float(ent, EV_FL_nextthink, get_gametime() + FLAG_THINK);
    
    static id;
    static iStatus;
    static iFlagTeam;
    static iSkip[3];
    static Float:fOrigin[3];
    static Float:fPlayerOrigin[3];

    iFlagTeam = (ent == g_iFlagEntity[TEAM_BLUE] ? TEAM_BLUE : TEAM_RED);

    if(g_iFlagHolder[iFlagTeam] == FLAG_HOLD_BASE)
        fOrigin = g_fFlagBase[iFlagTeam];
    else
        entity_get_vector(ent, EV_VEC_origin, fOrigin);

    g_fFlagLocation[iFlagTeam] = fOrigin;

    iStatus = 0;

    if(++iSkip[iFlagTeam] >= FLAG_SKIPTHINK)
    {
        iSkip[iFlagTeam] = 0;
        
        if(1 <= g_iFlagHolder[iFlagTeam] <= g_iMaxPlayers)
        {
            id = g_iFlagHolder[iFlagTeam];
            
            set_hudmessage(HUD_HELP);
            ShowSyncHudMsg(id, g_iSync[0], "%L", id, "HUD_YOUHAVEFLAG");
            
            iStatus = 1;
        }
        else if(g_iFlagHolder[iFlagTeam] == FLAG_HOLD_DROPPED)
        {
            iStatus = 2;
        }
        
        message_begin(MSG_BROADCAST, gMsg_HostagePos);
        write_byte(0);
        write_byte(iFlagTeam);
        engfunc(EngFunc_WriteCoord, fOrigin[x]);
        engfunc(EngFunc_WriteCoord, fOrigin[y]);
        engfunc(EngFunc_WriteCoord, fOrigin[z]);
        message_end();
        
        message_begin(MSG_BROADCAST, gMsg_HostageK);
        write_byte(iFlagTeam);
        message_end();
        
        static iStuck[3]
        
        if(g_iFlagHolder[iFlagTeam] >= FLAG_HOLD_BASE && !(entity_get_int(ent, EV_INT_flags) & FL_ONGROUND))
        {
            if(++iStuck[iFlagTeam] > 4)
            {
                flag_autoReturn(ent);
                log_message("^"%s^" flag is outside world, auto-returned.", g_szTeamName[iFlagTeam]);
                
                return;
            }
        }
        else
        {
            iStuck[iFlagTeam] = 0;
        }
    }

    for(id = 1; id <= g_iMaxPlayers; id++)
    {
        if(!is_user_connected(id) || g_iTeam[id] == TEAM_NONE)
            continue;
        
        /* Check flag proximity for pickup */
        if(g_iFlagHolder[iFlagTeam] >= FLAG_HOLD_BASE)
        {
            entity_get_vector(id, EV_VEC_origin, fPlayerOrigin);
            
            if(get_distance_f(fOrigin, fPlayerOrigin) <= FLAG_PICKUPDISTANCE)
                flag_touch(ent, id);
        }
        
        /* If iFlagTeam's flag is stolen or dropped, constantly warn team players */
        if(iStatus && g_iTeam[id] == iFlagTeam)
        {
            set_hudmessage(HUD_HELP2);
            ShowSyncHudMsg(id, g_iSync[0], "%L", id, (iStatus == 1 ? "HUD_ENEMYHASFLAG" : "HUD_RETURNYOURFLAG"));
        }
    }
}

public task_think(ent)
{
    if(!is_valid_ent(ent))
        return;
    
    static i;
    set_hudmessage(HUD_RESPAWN);
    for(i = 1; i <= g_iMaxPlayers; i++)
    {
        if (!is_user_connected(i) || (g_iTeam[i] != TEAM_RED && g_iTeam[i] != TEAM_BLUE))
        {
            continue;
        }

        DEBUG(i, print_chat, "(task_think) g_bAlive[%d]: %d, g_bRespawned[%d]: %d, g_bRespawn[%d]: %d", i, g_bAlive[i], i, g_bRespawned[i], i, g_bRespawn[i]);
        if(g_bAlive[i])
        {
            if (g_bProtected[i])
            {
                ShowSyncHudMsg(i, g_iSync[1], "%L", i, "PROTECTION_LEFT", g_bProtecting[i]);
        
                if(g_bProtecting[i] <= 0)
                {
                    player_removeProtection(i, "PROTECTION_EXPIRED");
                }
                g_bProtecting[i]--;
            }
            else
            {
                new iAdrenaline = g_bAdrenaline[i];
                if (iAdrenaline < 100)
                {
                    set_hudmessage(HUD_ADRENALINE);
                    ShowSyncHudMsg(i, g_iSync[1], "%L", i, "HUD_ADRENALINE", iAdrenaline, LIMIT_ADRENALINE);
                }
                else
                {
                    set_hudmessage(HUD_ADRENALINE_FULL);
                    ShowSyncHudMsg(i, g_iSync[1], "%L", i, "HUD_ADRENALINE_FULL");
                }
            }
        }
        else if(g_bRespawned[i])
        {
            DEBUG(i, print_chat, "(task_think) g_bRespawned[%d]: %d, g_bRespawn[%d]: %d", i, g_bRespawned[i], i, g_bRespawn[i]);
            ShowSyncHudMsg(i, g_iSync[1], "%L", i, "RESPAWNING_IN", g_bRespawn[i]);
            
            if(g_bRespawn[i] <= 0)
            {
                g_bRespawned[i] = false;
                rg_round_respawn(i);
            }
            g_bRespawn[i]--;
        }
    }
    entity_set_float(ent, EV_FL_nextthink, get_gametime() + TASK_THINK);
}

flag_sendHome(iFlagTeam)
{
    new ent = g_iFlagEntity[iFlagTeam];

    entity_set_edict(ent, EV_ENT_aiment, 0);
    entity_set_origin(ent, g_fFlagBase[iFlagTeam]);
    entity_set_int(ent, EV_INT_sequence, FLAG_ANI_STAND);
    entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
    entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER);
    entity_set_vector(ent, EV_VEC_velocity, FLAG_SPAWN_VELOCITY);
    entity_set_vector(ent, EV_VEC_angles, FLAG_SPAWN_ANGLES);

    g_iFlagHolder[iFlagTeam] = FLAG_HOLD_BASE;
}

flag_take(iFlagTeam, id)
{
    if(g_bProtected[id])
        player_removeProtection(id, "PROTECTION_TOUCHFLAG");
    
    new ent = g_iFlagEntity[iFlagTeam];
    
    entity_set_edict(ent, EV_ENT_aiment, id);
    entity_set_int(ent, EV_INT_movetype, MOVETYPE_FOLLOW);
    entity_set_int(ent, EV_INT_solid, SOLID_NOT);
    
    g_iFlagHolder[iFlagTeam] = id;
}

public flag_touch(ent, id)
{
    if(!g_bAlive[id])
        return;

    new iFlagTeam = (g_iFlagEntity[TEAM_BLUE] == ent ? TEAM_BLUE : TEAM_RED);

    if(1 <= g_iFlagHolder[iFlagTeam] <= g_iMaxPlayers) // if flag is carried we don't care
        return;

    new Float:fGameTime = get_gametime();
    
    if(g_fLastDrop[id] > fGameTime)
        return;
    
    new iTeam = g_iTeam[id];
    
    if(!(TEAM_RED <= iTeam <= TEAM_BLUE))
        return;
    
    new iFlagTeamOp = get_opTeam(iFlagTeam);
    
    if(iTeam == iFlagTeam) // If the PLAYER is on the same team as the FLAG
    {
        if(g_iFlagHolder[iFlagTeam] == FLAG_HOLD_DROPPED) // if the team's flag is dropped, return it to base
        {
            flag_sendHome(iFlagTeam);
            remove_task(ent);
            
            ExecuteForward(g_iFW_flag, g_iForwardReturn, FLAG_RETURNED, id, iFlagTeam, false);
            
            new iAssists = 0;
            for(new i = 1; i <= g_iMaxPlayers; i++)
            {
                if(is_user_connected(i) && i != id && g_bAssisted[i][iFlagTeam] && g_iTeam[i] == iFlagTeam)
                {
                    ExecuteForward(g_iFW_flag, g_iForwardReturn, FLAG_RETURNED, i, iFlagTeam, true);
                    
                    iAssists++;
                }
                g_bAssisted[i][iFlagTeam] = false;
            }
            
            if(1 <= g_iFlagHolder[iFlagTeamOp] <= g_iMaxPlayers)
                g_bAssisted[id][iFlagTeamOp] = true;
            
            if(iAssists)
                game_announce(EVENT_RETURNED, iFlagTeam, fmt("%s + %d assists", g_bPlayerName[id], iAssists));
            else
                game_announce(EVENT_RETURNED, iFlagTeam, g_bPlayerName[id]);
            
            log_message("<%s>%s returned the ^"%s^" flag.", g_szTeamName[iTeam], g_bPlayerName[id], g_szTeamName[iFlagTeam]);
            
            set_hudmessage(HUD_HELP);
            ShowSyncHudMsg(id, g_iSync[0], "%L", id, "HUD_RETURNEDFLAG");
            
            if(g_bProtected[id])
                player_removeProtection(id, "PROTECTION_TOUCHFLAG");
        }
        else if(g_iFlagHolder[iFlagTeam] == FLAG_HOLD_BASE && g_iFlagHolder[iFlagTeamOp] == id) // if the PLAYER has the ENEMY FLAG and the FLAG is in the BASE make SCORE
        {
            ExecuteForward(g_iFW_flag, g_iForwardReturn, FLAG_CAPTURED, id, iFlagTeamOp, false);
            
            new iAssists = 0;

            for(new i = 1; i <= g_iMaxPlayers; i++)
            {
                if(is_user_connected(i) && i != id && g_iTeam[i] == iTeam)
                {
                    if(g_bAssisted[i][iFlagTeamOp])
                    {
                        ExecuteForward(g_iFW_flag, g_iForwardReturn, FLAG_CAPTURED, i, iFlagTeamOp, true);
                        iAssists++;
                    }
                }
                g_bAssisted[i][iFlagTeamOp] = false;
            }

            set_hudmessage(HUD_HELP);
            ShowSyncHudMsg(id, g_iSync[0], "%L", id, "HUD_CAPTUREDFLAG");

            if(iAssists)
            {
                game_announce(EVENT_SCORE, iFlagTeam, fmt("%s + %d assists", g_bPlayerName[id], iAssists));
            }
            else
                game_announce(EVENT_SCORE, iFlagTeam, g_bPlayerName[id]);

            log_message("<%s>%s captured the ^"%s^" flag. (%d assists)", g_szTeamName[iTeam], g_bPlayerName[id], g_szTeamName[iFlagTeamOp], iAssists);

            emessage_begin(MSG_BROADCAST, gMsg_TeamScore);
            ewrite_string(g_szCSTeams[iFlagTeam]);
            ewrite_short(++g_iScore[iFlagTeam]);
            emessage_end();

            flag_sendHome(iFlagTeamOp);

            g_fLastDrop[id] = fGameTime + 3.0;

            if(g_bProtected[id])
                player_removeProtection(id, "PROTECTION_TOUCHFLAG");
        }
    }
    else
    {
        if(g_iFlagHolder[iFlagTeam] == FLAG_HOLD_BASE)
        {
            ExecuteForward(g_iFW_flag, g_iForwardReturn, FLAG_STOLEN, id, iFlagTeam, false);
            
            log_message("<%s>%s stole the ^"%s^" flag.", g_szTeamName[iTeam], g_bPlayerName[id], g_szTeamName[iFlagTeam]);
        }
        else
        {
            ExecuteForward(g_iFW_flag, g_iForwardReturn, FLAG_PICKED, id, iFlagTeam, false);
            
            log_message("<%s>%s picked up the ^"%s^" flag.", g_szTeamName[iTeam], g_bPlayerName[id], g_szTeamName[iFlagTeam]);
        }

        set_hudmessage(HUD_HELP);
        ShowSyncHudMsg(id, g_iSync[0], "%L", id, "HUD_YOUHAVEFLAG");

        flag_take(iFlagTeam, id);

        g_bAssisted[id][iFlagTeam] = true;

        remove_task(ent);

        if(g_bProtected[id])
            player_removeProtection(id, "PROTECTION_TOUCHFLAG");

        game_announce(EVENT_TAKEN, iFlagTeam, g_bPlayerName[id]);
    }
}

public flag_autoReturn(ent)
{
    remove_task(ent);
    
    new iFlagTeam = (g_iFlagEntity[TEAM_BLUE] == ent ? TEAM_BLUE : (g_iFlagEntity[TEAM_RED] == ent ? TEAM_RED : 0));
    
    if(!iFlagTeam)
        return;
    
    flag_sendHome(iFlagTeam);
    
    ExecuteForward(g_iFW_flag, g_iForwardReturn, FLAG_AUTORETURN, 0, iFlagTeam, false);
    
    game_announce(EVENT_RETURNED, iFlagTeam, "");
    
    log_message("^"%s^" flag returned automatically", g_szTeamName[iFlagTeam]);
}

public base_think(ent)
{
    if(!is_valid_ent(ent))
        return;
    
    if(!get_pcvar_num(pCvar_ctf_flagheal))
    {
        entity_set_float(ent, EV_FL_nextthink, get_gametime() + 10.0); /* recheck each 10s seconds */
        return;
    }
    
    entity_set_float(ent, EV_FL_nextthink, get_gametime() + BASE_THINK);
    
    new iFlagTeam = (g_iBaseEntity[TEAM_BLUE] == ent ? TEAM_BLUE : TEAM_RED);
    
    if(g_iFlagHolder[iFlagTeam] != FLAG_HOLD_BASE)
        return;
    
    static id;
    static Float:iHealth;
    
    id = -1;
    
    while((id = find_ent_in_sphere(id, g_fFlagBase[iFlagTeam], BASE_HEAL_DISTANCE)) != 0)
    {
        if(1 <= id <= g_iMaxPlayers && g_bAlive[id] && g_iTeam[id] == iFlagTeam)
        {
            iHealth = get_entvar(id, var_health);
            
            if(iHealth < 100.0)
            {
                set_entvar(id, var_health, iHealth + 1.0);
                player_healingEffect(id);
            }
        }
        
        if(id >= g_iMaxPlayers)
            break;
    }
}

public client_putinserver(id)
{
    get_user_name(id, g_bPlayerName[id], charsmax(g_bPlayerName[]));
    
    g_bAlive[id] = false;
    g_bProtected[id] = false;
    g_bRespawned[id] = false;
    g_bAdrenaline[id] = 0;
    
    g_iTeam[id] = TEAM_SPEC;
}

public client_disconnected(id)
{
    player_dropFlag(id);
    remove_task(id);
    
    g_iTeam[id]  = TEAM_NONE;
    g_bAlive[id] = false;
    g_bRespawned[id]  = false;
    g_bAdrenaline[id] = 0;
    g_bAssisted[id][TEAM_RED]  = false;
    g_bAssisted[id][TEAM_BLUE] = false;
}

public pfn_ChooseAppearance(id, slot)
{
    DEBUG(id, print_chat, "(pfn_ChooseAppearance) id: %d, slot: %d", id, slot);
    if((1 <= slot <= 4 || slot == 6) && !g_bAlive[id])
    {
        client_print(id, print_chat, "(pfn_ChooseAppearance) inside");
        g_bRespawned[id] = true;
        g_bRespawn[id]   = get_pcvar_num(pCvar_ctf_respawntime);
    }
}

public player_joinTeam()
{
    static szTeam[3];
    static id;
    
    id = read_data(1);
    read_data(2, szTeam, charsmax(szTeam));
    
    DEBUG(id, print_chat, "(player_joinTeam) id: %d, szTeam: %s", id, szTeam);

    player_allowChangeTeam(id);
    
    switch(szTeam[0])
    {
        case 'T': g_iTeam[id] = TEAM_RED;
        case 'C': g_iTeam[id] = TEAM_BLUE;
        case 'U': g_iTeam[id] = TEAM_NONE;
        default:
        {
            g_iTeam[id] = TEAM_SPEC;
        }
    }
    // g_bRespawned[id] = false;
}

public pfn_PlayerSpawn(id)
{
    g_bAlive[id] = is_user_alive(id) ? true : false;
    
    if(!g_bAlive[id])
        return;
    
    set_member(id, m_iRadioMessages, false);
    
    remove_task(id - TASK_EQUIPAMENT);
    // set_task(0.1, "player_spawnEquipament", id - TASK_EQUIPAMENT);
    
    g_bProtected[id] = true;
    g_bRespawned[id] = false;
    g_bProtecting[id] = get_pcvar_num(pCvar_ctf_protection);
    
    rg_set_user_rendering(id, kRenderFxNone, {0, 0, 0}, kRenderTransAdd, 100.0);
}

public player_removeProtection(id, szLang[])
{
    if(!(TEAM_RED <= g_iTeam[id] <= TEAM_BLUE))
        return;
    
    g_bProtected[id] = false;
    rg_set_user_rendering(id);
    
    set_hudmessage(HUD_PROTECTION);
    ShowSyncHudMsg(id, g_iSync[1], "%L", id, szLang);
}

public pfn_TraceAttack(const id, pevAttacker)
{
    if(1 <= pevAttacker <= g_iMaxPlayers)
    {
        if(g_bProtected[pevAttacker])
        {
            player_removeProtection(pevAttacker, "PROTECTION_WEAPONUSE");
        }
        
        if(g_bProtected[id])
        {
            return HC_SUPERCEDE;
        }
    }
    return HC_CONTINUE;
}

public event_playerKilled()
{
    static k; k = read_data(1);
    static v; v = read_data(2);
    
    g_bRespawned[v] = true;
    g_bAlive[v] = false;
    g_bAdrenaline[k] = clamp(g_bAdrenaline[k] + REWARD_FRAG, 0, LIMIT_ADRENALINE);
    
    remove_task(v - TASK_EQUIPAMENT);
    
    set_hudmessage(HUD_HINT);
    ShowSyncHudMsg(v, g_iSync[2], "%L: %L", v, "HINT", v, fmt("HINT_%d", random_num(1, 5)));
    
    if(1 <= k <= g_iMaxPlayers)
    {
        if(v == g_iFlagHolder[g_iTeam[k]])
        {
            g_bAssisted[k][g_iTeam[k]] = true;
        }
    }
    
    player_allowChangeTeam(v);
    g_bRespawn[v] = get_pcvar_num(pCvar_ctf_respawntime);
    player_dropFlag(v);
}

public player_hook_dropflag(id)
{
    player_cmd_dropFlag(id);
    return PLUGIN_HANDLED;
}

public player_cmd_dropFlag(id)
{
    if(!g_bAlive[id] || id != g_iFlagHolder[get_opTeam(g_iTeam[id])])
    {
        client_print_color(id, id, "%s%L", CHAT_PREFIX, id, "DROPFLAG_NOFLAG");
    }
    else
    {
        new iOpTeam = get_opTeam(g_iTeam[id]);
        
        player_dropFlag(id);
        
        ExecuteForward(g_iFW_flag, g_iForwardReturn, FLAG_MANUALDROP, id, iOpTeam, false);
        
        g_bAssisted[id][iOpTeam] = false;
    }
    return PLUGIN_HANDLED;
}

public player_dropFlag(id)
{
    new iOpTeam = get_opTeam(g_iTeam[id]);
    
    if(id != g_iFlagHolder[iOpTeam])
        return;
    
    new ent = g_iFlagEntity[iOpTeam];
    
    if(!is_valid_ent(ent))
        return;
    
    g_fLastDrop[id] = get_gametime() + 2.0;
    g_iFlagHolder[iOpTeam] = FLAG_HOLD_DROPPED;
    
    entity_set_edict(ent, EV_ENT_aiment, -1)
    entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
    entity_set_int(ent, EV_INT_sequence, FLAG_ANI_DROPPED);
    entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER);
    
    new Float:fReturn = get_pcvar_float(pCvar_ctf_flagreturn);
    
    if(fReturn > 0)
        set_task(fReturn, "flag_autoReturn", ent);
    
    if(!g_bAlive[id])
    {
        entity_set_vector(ent, EV_VEC_velocity, FLAG_DROP_VELOCITY);
        entity_set_origin(ent, g_fFlagLocation[iOpTeam]);
    }
    else
    {
        new Float:fVelocity[3];
        velocity_by_aim(id, 400, fVelocity);

        fVelocity[z] = 0.0;
        entity_set_vector(ent, EV_VEC_velocity, fVelocity);
    }
    
    game_announce(EVENT_DROPPED, iOpTeam, g_bPlayerName[id]);
    
    ExecuteForward(g_iFW_flag, g_iForwardReturn, FLAG_DROPPED, id, iOpTeam, false);
    
    g_fFlagDropped[iOpTeam] = get_gametime();
    
    log_message("<%s>%s dropped the ^"%s^" flag.", g_szTeamName[g_iTeam[id]], g_bPlayerName[id], g_szTeamName[iOpTeam]);
}

public admin_cmd_moveFlag(id, level, cid)
{
    if(~get_user_flags(id) & level)
    {
        return PLUGIN_HANDLED;
    }
    
    new szTeam[2];
    read_argv(1, szTeam, charsmax(szTeam));

    new iTeam = str_to_num(szTeam);
    
    if(!(TEAM_RED <= iTeam <= TEAM_BLUE))
    {
        switch(szTeam[0])
        {
            case 'r', 'R': iTeam = 1;
            case 'b', 'B': iTeam = 2;
        }
    }

    if(!(TEAM_RED <= iTeam <= TEAM_BLUE))
        return PLUGIN_HANDLED;
    
    entity_get_vector(id, EV_VEC_origin, g_fFlagBase[iTeam]);
    
    entity_set_origin(g_iBaseEntity[iTeam], g_fFlagBase[iTeam]);
    entity_set_vector(g_iBaseEntity[iTeam], EV_VEC_velocity, FLAG_SPAWN_VELOCITY);
    
    if(g_iFlagHolder[iTeam] == FLAG_HOLD_BASE)
    {
        entity_set_origin(g_iFlagEntity[iTeam], g_fFlagBase[iTeam]);
        entity_set_vector(g_iFlagEntity[iTeam], EV_VEC_velocity, FLAG_SPAWN_VELOCITY);
    }
    
    client_print(id, print_console, "%s%L", CONSOLE_PREFIX, id, "ADMIN_MOVEBASE_MOVED", id, g_szMLFlagTeam[iTeam]);
    
    return PLUGIN_HANDLED;
}

public admin_cmd_saveFlags(id, level, cid)
{
    if(~get_user_flags(id) & level)
    {
        return PLUGIN_HANDLED;
    }

    new iOrigin[3][3];
    new szFile[34];
    new szBuffer[34];
    new szMap[32];
    
    get_mapname(szMap, charsmax(szMap));
    FVecIVec(g_fFlagBase[TEAM_RED], iOrigin[TEAM_RED]);
    FVecIVec(g_fFlagBase[TEAM_BLUE], iOrigin[TEAM_BLUE]);

    formatex(szBuffer, charsmax(szBuffer), "%d %d %d^n%d %d %d", iOrigin[TEAM_RED][x], iOrigin[TEAM_RED][y], iOrigin[TEAM_RED][z], iOrigin[TEAM_BLUE][x], iOrigin[TEAM_BLUE][y], iOrigin[TEAM_BLUE][z]);
    formatex(szFile, charsmax(szFile), FLAG_SAVELOCATION, szMap);

    if(file_exists(szFile))
        delete_file(szFile);

    write_file(szFile, szBuffer);

    client_print(id, print_console, "%s%L %s", CONSOLE_PREFIX, id, "ADMIN_MOVEBASE_SAVED", szFile);

    return PLUGIN_HANDLED;
}

public admin_cmd_returnFlag(id, level, cid)
{
    if(~get_user_flags(id) & level)
    {
        return PLUGIN_HANDLED;
    }
    
    new iTeam = read_argv_int(1);
    
    if(!(TEAM_RED <= iTeam <= TEAM_BLUE))
        return PLUGIN_HANDLED;
    
    if(g_iFlagHolder[iTeam] != FLAG_HOLD_DROPPED)
    {
        client_print(id, print_console, "%s%L", CONSOLE_PREFIX, id, "ADMIN_RETURN_NOTDROPPED", id, g_szMLFlagTeam[iTeam])
    }
    else
    {
        if(g_fFlagDropped[iTeam] >= (get_gametime() - ADMIN_RETURNWAIT))
        {
            client_print(id, print_console, "%s%L", CONSOLE_PREFIX, id, "ADMIN_RETURN_WAIT", id, g_szMLFlagTeam[iTeam], ADMIN_RETURNWAIT);
        }
        else
        {
            new Float:fFlagOrigin[3];
            entity_get_vector(g_iFlagEntity[iTeam], EV_VEC_origin, fFlagOrigin);
            
            flag_sendHome(iTeam);

            ExecuteForward(g_iFW_flag, g_iForwardReturn, FLAG_ADMINRETURN, id, iTeam, false);
            
            game_announce(EVENT_RETURNED, iTeam, "");
            
            client_print(id, print_console, "%s%L", CONSOLE_PREFIX, id, "ADMIN_RETURN_DONE", id, g_szMLFlagTeam[iTeam]);
        }
    }
    
    return PLUGIN_HANDLED;
}

public event_restartGame()
{
    g_bRestarting = true;
}

public event_roundStart()
{
    for(new id = 1; id <= g_iMaxPlayers; id++)
    {
        if(!g_bAlive[id])
            continue;
        
        remove_task(id - TASK_EQUIPAMENT)
        if(g_bRestarting)
        {
            remove_task(id);
        }
    }
    
    for(new iFlagTeam = TEAM_RED; iFlagTeam <= TEAM_BLUE; iFlagTeam++)
    {
        flag_sendHome(iFlagTeam);
        remove_task(g_iFlagEntity[iFlagTeam]);
        
        log_message("%s, %s flag returned back to base.", (g_bRestarting ? "Game restarted" : "New round started"), g_szTeamName[iFlagTeam]);
    }
    
    if(g_bRestarting)
    {
        g_iScore = {0, 0, 0};
        g_bRestarting = false;
    }
}

public msg_teamScore()
{
    static szTeam[3];
    get_msg_arg_string(1, szTeam, charsmax(szTeam));
    switch(szTeam[0])
    {
        case 'T': set_msg_arg_int(2, ARG_SHORT, g_iScore[TEAM_RED]);
        case 'C': set_msg_arg_int(2, ARG_SHORT, g_iScore[TEAM_BLUE]);
    }
}

public msg_roundTime()
{
    set_msg_arg_int(1, ARG_SHORT, get_timeleft());
}

public player_healingEffect(id)
{
    new iOrigin[3];
    get_user_origin(id, iOrigin);
    
    message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin);
    write_byte(TE_PROJECTILE);
    write_coord(iOrigin[x] + random_num(-10, 10));
    write_coord(iOrigin[y] + random_num(-10, 10));
    write_coord(iOrigin[z] + random_num(0, 30));
    write_coord(0);
    write_coord(0);
    write_coord(15);
    write_short(gSpr_regeneration);
    write_byte(1);
    write_byte(id);
    message_end();
}

public game_announce(iEvent, iFlagTeam, szName[])
{
    new iColor = iFlagTeam;
    new szText[64];
    
    switch(iEvent)
    {
        case EVENT_TAKEN:
        {
            iColor = get_opTeam(iFlagTeam);
            formatex(szText, charsmax(szText), "%L", LANG_PLAYER, "ANNOUNCE_FLAGTAKEN", szName, LANG_PLAYER, g_szMLFlagTeam[iFlagTeam]);
        }
        case EVENT_DROPPED: 
        {
            formatex(szText, charsmax(szText), "%L", LANG_PLAYER, "ANNOUNCE_FLAGDROPPED", szName, LANG_PLAYER, g_szMLFlagTeam[iFlagTeam]);
        }
        case EVENT_RETURNED:
        {
            if(strlen(szName) != 0)
                formatex(szText, charsmax(szText), "%L", LANG_PLAYER, "ANNOUNCE_FLAGRETURNED", szName, LANG_PLAYER, g_szMLFlagTeam[iFlagTeam]);
            else
                formatex(szText, charsmax(szText), "%L", LANG_PLAYER, "ANNOUNCE_FLAGAUTORETURNED", LANG_PLAYER, g_szMLFlagTeam[iFlagTeam]);
        }
        case EVENT_SCORE:
        {
            formatex(szText, charsmax(szText), "%L", LANG_PLAYER, "ANNOUNCE_FLAGCAPTURED", szName, LANG_PLAYER, g_szMLFlagTeam[get_opTeam(iFlagTeam)]);
        }
    }
    
    set_hudmessage(iColor == TEAM_RED ? 255 : 0, iColor == TEAM_RED ? 0 : 255, iColor == TEAM_BLUE ? 255 : 0, HUD_ANNOUNCE);
    ShowSyncHudMsg(0, g_iSync[3], szText);
    
    if(get_pcvar_num(pCvar_ctf_sound[iEvent]))
    {
        client_cmd(0, "mp3 play ^"sound/jctf/%s.mp3^"", g_szSounds[iEvent][iFlagTeam]);
    }
}

stock rg_set_user_rendering(id, fx = kRenderFxNone, {Float,_}:color[3] = {0.0,0.0,0.0}, render = kRenderNormal, Float:amount = 0.0)
{
    set_entvar(id, var_renderfx, fx);
    set_entvar(id, var_rendercolor, color);
    set_entvar(id, var_rendermode, render);
    set_entvar(id, var_renderamt, amount);
}
