#include <amxmodx>
#include <fakemeta>     // for fake name change
#include <hamsandwich>  // for player hooks

/* Settings */
    // Minimum kills need to show counter in name.
const MIN_KILLS = 2;
    // Enable CSDM FFA kills support.
// #define FFA_MODE
/*          */

new g_iComboKills[MAX_PLAYERS + 1] = { 0, ... };

public plugin_init()
{
    register_plugin("ep1c: Contagem de Kills", "0.0.2", "wopox1337");

    RegisterHam(Ham_Killed, "player", "CBasePlayer_Killed_Pre", .Post = false, .specialbot = true);
    RegisterHam(Ham_Killed, "player", "CBasePlayer_Killed", .Post = true, .specialbot = true);

    RegisterHam(Ham_Spawn, "player", "CBasePlayer_Spawn", .Post = true, .specialbot = true);
}

public CBasePlayer_Killed_Pre(pPlayer, pKiller)
{
    if(!IsValidKill(pPlayer, pKiller))
        return;
    
    if(++g_iComboKills[pKiller] < MIN_KILLS)
        return;
    
    static szKillerName[MAX_NAME_LENGTH];
    get_user_name(pKiller, szKillerName, charsmax(szKillerName));

// ' [+100]' = 7 + 1(nullterm) = 8chars; MAX_NAME_LENGTH - 8 = 24
    formatex(szKillerName, charsmax(szKillerName), "%.24s [+%i]",szKillerName, g_iComboKills[pKiller]);
    set_user_fake_name(pKiller, szKillerName);
}

public CBasePlayer_Killed(pPlayer, pKiller)
{
    if(g_iComboKills[pKiller] < MIN_KILLS)
        return;

    reset_user_info(pKiller);
}

public CBasePlayer_Spawn(pPlayer)
    g_iComboKills[pPlayer] = 0;

// From: https://dev-cs.ru/resources/189/ (cuz i need fastest usage)
stock set_user_fake_name(const id, const name[])
{
    for(new i = 1; i <= MaxClients; i++)
    {
        if(is_user_connected(i) && !is_user_hltv(i))
        {
            message_begin(MSG_ONE, SVC_UPDATEUSERINFO, _, i);
            write_byte(id - 1);
            write_long(get_user_userid(id));
            write_char('\');
            write_char('n');
            write_char('a');
            write_char('m');
            write_char('e');
            write_char('\');
            write_string(name);
            for(new i; i < 4; i++) write_long(0);
            message_end();
        }
    }
}

stock reset_user_info(id)
{
    static szUserInfo[256];
    copy_infokey_buffer(engfunc(EngFunc_GetInfoKeyBuffer, id), szUserInfo, charsmax(szUserInfo));

    for(new i = 1; i <= MaxClients; i++)
    {
        if(is_user_connected(i) && !is_user_hltv(i))
        {
            message_begin(MSG_ONE, SVC_UPDATEUSERINFO, _, i);
            write_byte(id - 1);
            write_long(get_user_userid(id));
            write_string(szUserInfo);
            for(new i; i < 4; i++) write_long(0);
            message_end();
        }
    }
}

stock bool: IsValidKill(pPlayer, pKiller)
{    
    if(pPlayer == pKiller)
        return false;

    if(!is_user_alive(pKiller))
        return false;

#if !defined FFA_MODE
    if(get_user_team(pPlayer) == get_user_team(pKiller))
        return false;
#endif

    return true;
}



/* API?! */
public plugin_natives()
{
    enum { oldstyle };
    register_native("combo_GetKills", "native__combo_GetKills", .style = oldstyle);
}

stock CHECK_PLAYER(id)
{
    if(id < 1 || id > MaxClients)
    {
        log_error(AMX_ERR_NATIVE, "Player out of range (%i)", id);
        return 0;
    } else return 1;
}

/**
* Set count of combo kills to player.
*
* @note Usage examples:
*       combo_SetKills(id, .count = 5);
*
* @param index  Client index
* @param count  Count combo kills.   
*
* @noreturn
*/
    // native combo_SetKills(id, count)
public native__combo_SetKills(plugin_id, argc)
{
    enum { arg_index = 1, arg_count };

    new index = get_param(arg_index);
    if(!CHECK_PLAYER(index)) return 0;

    new count = get_param(arg_count);
    g_iComboKills[index] = count;

    return 1;
}

/**
* Retrieves count of combo kills from player.
*
* @note Usage examples:
*       combo_GetKills(id);
*
* @param index  Client index
*
* @return Combo kills count from player. 
*/
    // native combo_GetKills(id)
public native__combo_GetKills(plugin_id, argc)
{
    enum { arg_index = 1 };

    new index = get_param(arg_index);
    if(!CHECK_PLAYER(index)) return 0;

    return g_iComboKills[index];
}
