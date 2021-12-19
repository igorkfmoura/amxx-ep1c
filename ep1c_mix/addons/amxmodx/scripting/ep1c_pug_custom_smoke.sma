#include < amxmodx >
#include < reapi >

#pragma semicolon 1

// Modified by mx?! at 18.01.2020, base version was 1.07
// Changes:
// Old AMXX versions support dropped (now plugin require 183+)
// Plugin ported to ReAPI (base version uses fakemeta & engine)
// Refactoring
// Added AMXX autoconfig option
// Added new cvar 'sv_smokestyle'
// Default 'sv_smokeduration' cvar value raised from 10.0 to 15.0
//
// Version 1.09 changes:
// Added 'fps friendly' mode, just set cvar 'sv_smokespritescount' to 0
#define VERSION "1.09"

/* -------------------- */

// Create config in 'configs/plugins', and execute it?
//#define AUTO_CFG

// Use reliable messages (guaranteed delivery, but can cause client overflow)
// Comment to use unreliable messages
#define USE_RELIABLE

// Path to custom smoke sprite
new const SMOKE_SPRITE[ ] = "sprites/gas_puff_gray_opaque.spr";

// Sprites count in 'fps friendly' mode
#define FPS_MODE_SPRITES_COUNT 100

/* -------------------- */

#if defined USE_RELIABLE
    #define MSG_TYPE MSG_ALL
#else
    #define MSG_TYPE MSG_BROADCAST
#endif

new const CUSTOM_CLASSNAME[ ] = "custom_smoke";

new g_iCvar_Enebled;
new Float:g_flCvar_Duration;
new g_iCvar_SpritesCount;
new g_iCvar_Style;
new g_iSmokeSpriteIndex;

public plugin_precache( )
{
    register_plugin( "[ReAPI] Custom Smoke", VERSION, "bionext" );

    if( !file_exists( SMOKE_SPRITE ) )
    {
        set_fail_state( "Can't find '%s'", SMOKE_SPRITE );
    }

    g_iSmokeSpriteIndex = precache_model( SMOKE_SPRITE );

    force_unmodified( force_exactfile, { 0, 0, 0 }, { 0, 0, 0 }, SMOKE_SPRITE );
}

public plugin_init( )
{
    func_RegCvars( );
    RegisterHookChain( RG_CGrenade_ExplodeSmokeGrenade, "OnExplodeSmokeGrenade_Pre" );
    RegisterHookChain( RG_CSGameRules_RestartRound, "OnRestartRound_Pre" );
}

public OnExplodeSmokeGrenade_Pre( pEnt )
{
    if( !g_iCvar_Enebled || !is_entity( pEnt ) )
    {
        return HC_CONTINUE;
    }

    new Float:vOrigin[ 3 ];
    get_entvar( pEnt, var_origin, vOrigin );

    emit_sound( pEnt, CHAN_WEAPON, "weapons/sg_explode.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
    
    // set_entvar( pEnt, var_flags, FL_KILLME );

    new pSmokeEnt = rg_create_entity( "info_target", .useHashTable = false );

    if( !pSmokeEnt )
    {
        return HC_CONTINUE;
    }

    set_entvar( pSmokeEnt, var_classname, CUSTOM_CLASSNAME );
    set_entvar( pSmokeEnt, var_nextthink, get_gametime( ) );
    set_entvar( pSmokeEnt, var_origin, vOrigin );
    set_entvar( pSmokeEnt, var_animtime, g_flCvar_Duration );
    SetThink( pSmokeEnt, "OnThink_Pre" );

    func_SendFireFieldMsg(vOrigin, 100, g_iCvar_SpritesCount ? g_iCvar_SpritesCount : FPS_MODE_SPRITES_COUNT, TEFIRE_FLAG_ALPHA, floatround(g_flCvar_Duration * 10, floatround_tozero));
    return HC_CONTINUE;
}

public OnThink_Pre( pEnt )
{
    if( !is_entity( pEnt ) )
        return;

    new Float:vOrigin[ 3 ];
    get_entvar( pEnt, var_origin, vOrigin );

    new Float:flTime = Float:get_entvar( pEnt, var_animtime ) - 1.0;
    if( flTime > 0.0 )
    {
        set_entvar( pEnt, var_nextthink, get_gametime( ) + 1.0 );
        set_entvar( pEnt, var_animtime, flTime );
    }
    else
    {
        set_entvar( pEnt, var_flags, FL_KILLME );
    }
}

func_SendFireFieldMsg( const Float:vOrigin[ 3 ], iRadius, iSpritesCount, iFlags, iDuration )
{
    if(g_iCvar_Style)
    {
        iFlags |= TEFIRE_FLAG_PLANAR;
    }

    message_begin( MSG_TYPE, SVC_TEMPENTITY );
    write_byte( TE_FIREFIELD );
    write_coord_f( vOrigin[ 0 ] );
    write_coord_f( vOrigin[ 1 ] );
    write_coord_f( vOrigin[ 2 ] );
    write_short( iRadius );
    write_short( g_iSmokeSpriteIndex );
    write_byte( iSpritesCount );
    write_byte( iFlags );
    write_byte( iDuration );
    message_end( );
}

public OnRestartRound_Pre( )
{
    new pEnt = MaxClients;

    while( ( pEnt = rg_find_ent_by_class( pEnt, CUSTOM_CLASSNAME, .useHashTable = false ) ) )
    {
        set_entvar( pEnt, var_flags, FL_KILLME );
    }
}

func_RegCvars( )
{
    bind_pcvar_num(
        create_cvar(
            "sv_customsmoke",
            "1",
            .description = "Enable custom smoke (1/0) ?" ),
        g_iCvar_Enebled
    );

    bind_pcvar_float(
        create_cvar(
            "sv_smokeduration",
            "15.0",
            .has_min = true, .min_val = 1.0,
            .description = "Smoke duration in seconds" ),
        g_flCvar_Duration
    );

    bind_pcvar_num(
        create_cvar(
            "sv_smokespritescount",
            "0",
            .has_min = true, .min_val = 0.0,
            .description = "Smoke sprites count (set to 0 to enable 'fps friendly' mode)" ),
        g_iCvar_SpritesCount
    );

    bind_pcvar_num(
        create_cvar(
            "sv_smokestyle",
            "0",
            .description = "Smoke style: 0 - default, 1 - compact" ),
        g_iCvar_Style
    );

#if defined AUTO_CFG
    AutoExecConfig( );
#endif
}
