#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "ep1c: C4 DROP"
#define VERSION "1.0"
#define AUTHOR "iceeedR"

#define C4_CLASSNAME_SPRITE     "spritebox"
#define C4Sprite                "sprites/test-carerira.spr"

new SpriteEnt = FM_NULLENT
new HamHook:_CBaseEntity_Think

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR, "@ep1cgamingbr", "Coloca uma sprite acima da c4 dropada.")

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
        set_pev(iEnt, pev_rendermode, kRenderTransAdd)
        set_pev(iEnt, pev_renderamt, 255.0)
        set_pev(iEnt, pev_scale, 0.3)
        set_pev(iEnt, pev_iuser1, ent)

        SpriteEnt = iEnt

        return iEnt
}
