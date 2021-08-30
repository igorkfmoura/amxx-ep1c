/* Sublime AMXX Editor v2.2 */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <nvault>
#pragma dynamic 32768

#define PLUGIN  "ep1c ' ModBoi_Knife"
#define VERSION "1.0"
#define AUTHOR  "SH7"

#define OX_HEAD "models/player/viking.mdl"
#define ClanTag "[ep1c gaming Brasil]"

new g_Vault
new iModelHead[MAX_PLAYERS + 1]
new szAuthid[MAX_PLAYERS + 1][MAX_AUTHID_LENGTH]
new bool:AlreadyOX[MAX_PLAYERS + 1]

enum ( <<=1 )
{
        OxHead = 1
}

new g_Options[MAX_PLAYERS + 1]

#define HasHEAD(%1,%2)    g_Options[%1]&%2
#define AddHEAD(%1,%2)    g_Options[%1]|=%2
#define RemoveHEAD(%1,%2)    g_Options[%1]&=~%2

new const VaultName[] = "OX_INDEX"

public plugin_init()
{
        register_plugin(PLUGIN, VERSION, AUTHOR)

        register_event("DeathMsg", "DeathMsg", "a", "4=knife")
        RegisterHamPlayer(Ham_Spawn, "PlayerSpawn", true)

        if ((g_Vault = nvault_open( VaultName )) == INVALID_HANDLE)
        {
                set_fail_state( "Failed to open vault" );
        }
}

public plugin_precache()
{
        precache_model(OX_HEAD)
}

public PlayerSpawn(id)
{
        if(is_user_alive(id))
        {
                if(HasHEAD(id, OxHead))
                {
                        make_character(id)
                }
        }
}

public DeathMsg()
{
        static Attacker, Victim

        Attacker = read_data(1)
        Victim = read_data(2)

        if(!is_user_connected(Attacker) || !is_user_connected(Victim) || Attacker == Victim)
                return PLUGIN_HANDLED

        make_character(Victim)

        if(HasHEAD(Attacker, OxHead))
        {
                reset_character(Attacker)
                client_print_color(Attacker, print_team_default, "^4%s^1 Voce matou^4 %n^1 na faca e não é mais um boi HAHAHA.", ClanTag, Victim)
        }

        return PLUGIN_HANDLED
}

make_character(id)
{
        if(!AlreadyOX[id])
        {
                iModelHead[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))

                set_pev(iModelHead[id], pev_movetype, MOVETYPE_FOLLOW)
                set_pev(iModelHead[id], pev_aiment, id)
                set_pev(iModelHead[id], pev_rendermode, kRenderNormal)
                engfunc(EngFunc_SetModel, iModelHead[id], OX_HEAD)
                set_pev(iModelHead[id], pev_body, 0)
                set_pev(iModelHead[id], pev_sequence, 0)
                set_pev(iModelHead[id], pev_animtime, get_gametime())
                set_pev(iModelHead[id], pev_framerate, 1.0)
                AddHEAD(id, OxHead)
                AlreadyOX[id] = true

                set_dhudmessage(0, 255, 0, -1.0, 0.3, .effects = 0, .fxtime = 0.0, .holdtime = 3.0, .fadeintime = 0.1, .fadeouttime = 0.2)
                show_dhudmessage(0, "%n morreu na faca e agora é um boi HAHAHA", id)
        }
}

public client_authorized(id)
{
        get_user_authid(id, szAuthid[id], charsmax(szAuthid[]))
        RemoveHEAD(id, OxHead)
        AlreadyOX[id] = false
        iModelHead[id] = 0
        LoadOX(id)
}

reset_character(id)
{
        set_pev(iModelHead[id], pev_effects, pev(iModelHead[id], pev_effects) | EF_NODRAW)
        iModelHead[id] = 0
        RemoveHEAD(id, OxHead)
        AlreadyOX[id] = false
}

public client_disconnected(id, bool:drop, message[], maxlen)
{
        saveOX(id)
        RemoveHEAD(id, OxHead)
        AlreadyOX[id] = false
        iModelHead[id] = 0
}

public LoadOX(id)
{
        g_Options[id] = nvault_get(g_Vault , szAuthid[id])
        server_print("Ele e %s", HasHEAD(id, OxHead) ? "BOI" : "coitado")
}

public saveOX(id)
{
        new szData[15]
        num_to_str(g_Options[id] , szData , charsmax(szData))
        nvault_set(g_Vault, szAuthid[id] , szData)
}

public plugin_end()
{
        nvault_close(g_Vault)
}
