#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "ep1c: C4 DROP"
#define VERSION "1.1"
#define AUTHOR "iceeedR + lonewolf"

// lonewolf -> ajustes transparências, task animação

#define C4_CLASSNAME_SPRITE     "spritebox"
#define C4Sprite                "sprites/ep1c/ep1c-caveira-c4.spr"

new SpriteEnt = FM_NULLENT
new HamHook:_CBaseEntity_Think

public plugin_init()
{
	// register_plugin(PLUGIN, VERSION, AUTHOR, "@ep1cgamingbr", "Coloca uma sprite acima da c4 dropada.")
        register_plugin(PLUGIN, VERSION, AUTHOR)

        _CBaseEntity_Think = RegisterHam( Ham_Think, "weaponbox", "CBaseEntity_Think" )
        DisableHamForward( _CBaseEntity_Think )

        register_logevent( "LogEvent_BombCollected", 3, "2=Spawned_With_The_Bomb" )
        register_logevent( "LogEvent_BombCollected", 3, "2=Got_The_Bomb" )
        register_logevent( "LogEvent_BombDropped", 3, "2=Dropped_The_Bomb" )

        register_event("HLTV","EventNewRnd", "a", "1=0", "2=0")
        register_logevent("EventEndRnd", 2, "1=Round_End")
}

public plugin_precache()
{
	precache_model(C4Sprite)
}

public EventNewRnd()
{
        RemoveSprite()
}

public EventEndRnd()
{
        RemoveSprite()
}

public CBaseEntity_Think( iEnt )
{
        if(pev(iEnt, pev_flags) & FL_ONGROUND)
        {
                static szModel[MAX_NAME_LENGTH]

                if(!szModel[ 0 ])
                        pev( iEnt, pev_model, szModel, charsmax(szModel))

                if(!equal(szModel, "models/w_backpack.mdl" ))
                        return HAM_IGNORED;

                xCreateSprite(iEnt)

                DisableHamForward(_CBaseEntity_Think)
        }

        return HAM_IGNORED
}

public LogEvent_BombCollected()
{
        DisableHamForward(_CBaseEntity_Think)

        RemoveSprite()
}

public LogEvent_BombDropped()
{
        EnableHamForward(_CBaseEntity_Think)
}

public RemoveSprite()
{
        if(pev_valid(SpriteEnt) && SpriteEnt != FM_NULLENT)
        {
                remove_entity(SpriteEnt)
                SpriteEnt = FM_NULLENT
        }

        remove_task(SpriteEnt + 61151)
}

public xCreateSprite(ent)
{
        new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))

        if(!pev_valid(iEnt))
                return 0

        static Float:orig[3]

        pev(ent, pev_origin, orig)

        orig[2] += 30.0

        set_pev(iEnt, pev_classname, C4_CLASSNAME_SPRITE)
        engfunc(EngFunc_SetOrigin, iEnt, orig)
        engfunc(EngFunc_SetModel, iEnt, C4Sprite)
        set_pev(iEnt, pev_movetype, MOVETYPE_FLYMISSILE)
        set_pev(iEnt, pev_rendermode, kRenderTransTexture)
        set_pev(iEnt, pev_renderamt, 80.0)
        set_pev(iEnt, pev_scale, 0.15)
        set_pev(iEnt, pev_iuser1, ent)

        set_task(0.1, "taskUpdateSprite", iEnt + 61151, .flags = "b")

        SpriteEnt = iEnt

        return iEnt
}

public taskUpdateSprite(iEnt)
{
        iEnt -= 61151

        static Float:offset = 0.0
        static Float:dir = 0.2
        static Float:max = 3.0

        static Float:orig[3]
        if (!pev_valid(SpriteEnt))
        {
                return;
        }
        
        pev(SpriteEnt, pev_origin, orig)

        offset += dir
        orig[2] += dir

        if (offset > max)
        {
                dir *= -1.0
                offset = max + dir + dir
                orig[2] += dir
        }
        else if (offset < 0)
        {
                dir *= -1.0
                offset = dir + dir
                orig[2] += dir
        }
        
        // client_print_color(0, print_team_red, "ORIGIN: [^3%0.1f^1, ^3%0.1f^1, ^3%0.1f^1]", orig[0], orig[1], orig[2])
        engfunc(EngFunc_SetOrigin, SpriteEnt, orig)
}