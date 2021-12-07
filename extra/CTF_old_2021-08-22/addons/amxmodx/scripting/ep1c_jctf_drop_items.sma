#include <amxmodx>
#include <engine>
#include <hamsandwich>
#include <jctf>
#include <fun>
#include <cstrike>

#define PLUGIN  "ep1c-jctf-drop-items"
#define VERSION "0.1"
#define AUTHOR  "lonewolf"

new const ITEM_CLASSNAME[] = "ctf_item";

new const bool:ITEM_DROP_MEDKIT     = true;
new const bool:ITEM_DROP_ADRENALINE = true;

new const ITEM_MODEL_MEDKIT[]     = "models/w_medkit.mdl";
new const ITEM_MODEL_ADRENALINE[] = "models/can.mdl";

new const SND_GETMEDKIT[]         = "items/smallmedkit1.wav"
new const SND_GETADRENALINE[]     = "items/medshot4.wav";

new const Float:ITEM_HULL_MIN[3] = {-1.0, -1.0, 0.0};
new const Float:ITEM_HULL_MAX[3] = {1.0, 1.0, 10.0};

const ITEM_MEDKIT     = 1;
const ITEM_ADRENALINE = 2;

const ITEM_MEDKIT_GIVE     = 25;
const ITEM_ADRENALINE_GIVE = 5;

new pCvar_ctf_itempercent;
new pCvar_ctf_weaponstay;
new pCvar_ctf_glows;

enum
{
    x,
    y,
    z
};

enum 
{ 
    pitch, 
    yaw, 
    roll 
};

public plugin_precache()
{
    precache_model(ITEM_MODEL_ADRENALINE);
    precache_model(ITEM_MODEL_MEDKIT);

    precache_sound(SND_GETMEDKIT);
    precache_sound(SND_GETADRENALINE);
}


public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    RegisterHam(Ham_Killed, "player", "player_killed", 1);
    RegisterHam(Ham_Spawn, "weaponbox", "weapon_spawn", 1);

    register_touch(ITEM_CLASSNAME, "player", "item_touch");

    pCvar_ctf_itempercent = register_cvar("ctf_itempercent", "30");
    pCvar_ctf_weaponstay  = register_cvar("ctf_weaponstay", "6");
    pCvar_ctf_glows       = register_cvar("ctf_glow", "1");
}


public player_killed(id, killer)
{
    if (is_user_connected(id))
    {
        player_spawnItem(id);
    }
}

player_spawnItem(id)
{
    if(!ITEM_DROP_MEDKIT && !ITEM_DROP_ADRENALINE)
    {
        return;
    }

    if(random_num(1, 100) > get_pcvar_float(pCvar_ctf_itempercent))
    {
        return;
    }

    new ent = create_entity("info_target");

    if(!ent)
    {
        return;
    }

    new iType;
    new Float:fOrigin[3];
    new Float:fAngles[3];
    new Float:fVelocity[3];

    entity_get_vector(id, EV_VEC_origin, fOrigin);

    fVelocity[x] = random_float(-100.0, 100.0);
    fVelocity[y] = random_float(-100.0, 100.0);
    fVelocity[z] = 50.0;

    fAngles[yaw] = random_float(0.0, 360.0);

    while((iType = random_num(1, 2)))
    {
        switch(iType)
        {
            case ITEM_MEDKIT:
            {
                if(ITEM_DROP_MEDKIT)
                {
                    client_print(id, print_chat, "iType: %d, model: %s", iType, ITEM_MODEL_MEDKIT);
                    entity_set_model(ent, ITEM_MODEL_MEDKIT);
                    break;
                }
            }
            case ITEM_ADRENALINE:
            {
                if(ITEM_DROP_ADRENALINE)
                {
                    client_print(id, print_chat, "iType: %d, model: %s", iType, ITEM_MODEL_ADRENALINE);
                    entity_set_model(ent, ITEM_MODEL_ADRENALINE);
                    entity_set_int(ent, EV_INT_skin, random_num(0, 5));
                    break;
                }
            }
        }
    }

    entity_set_string(ent, EV_SZ_classname, ITEM_CLASSNAME);
    DispatchSpawn(ent);
    entity_set_size(ent, ITEM_HULL_MIN, ITEM_HULL_MAX);
    entity_set_origin(ent, fOrigin);
    entity_set_vector(ent, EV_VEC_angles, fAngles);
    entity_set_vector(ent, EV_VEC_velocity, fVelocity);
    entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
    entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER);
    entity_set_int(ent, EV_INT_iuser2, iType);
    
    client_print(id, print_chat, "iType: %d", iType);

    remove_task(ent);
    set_task(get_pcvar_float(pCvar_ctf_weaponstay), "weapon_startFade", ent);
}

public weapon_spawn(ent)
{
    if(!is_valid_ent(ent))
    {
        return;
    }

    new Float:fWeaponStay = get_pcvar_float(pCvar_ctf_weaponstay);

    if(fWeaponStay > 0)
    {
        remove_task(ent);
        set_task(fWeaponStay, "weapon_startFade", ent);
    }
}

public weapon_startFade(ent)
{
    if(!is_valid_ent(ent))
    {
        return;
    }

    new szClass[32];

    entity_get_string(ent, EV_SZ_classname, szClass, charsmax(szClass));

    if(!equal(szClass, "weaponbox") && !equal(szClass, ITEM_CLASSNAME))
    {
        return;
    }

    entity_set_int(ent, EV_INT_movetype, MOVETYPE_FLY);
    entity_set_int(ent, EV_INT_rendermode, kRenderTransAlpha);

    if(get_pcvar_num(pCvar_ctf_glows))
    {
        entity_set_int(ent, EV_INT_renderfx, kRenderFxGlowShell);
    }

    entity_set_float(ent, EV_FL_renderamt, 255.0);
    entity_set_vector(ent, EV_VEC_rendercolor, Float:{255.0, 255.0, 0.0});
    entity_set_vector(ent, EV_VEC_velocity, Float:{0.0, 0.0, 20.0});

    weapon_fadeOut(ent, 255.0);
}


public weapon_fadeOut(ent, Float:fStart)
{
    if(!is_valid_ent(ent))
    {
        remove_task(ent);
        return;
    }

    static Float:fFadeAmount[4096];

    if(fStart)
    {
        remove_task(ent);
        fFadeAmount[ent] = fStart;
    }

    fFadeAmount[ent] -= 25.5;

    if(fFadeAmount[ent] > 0.0)
    {
        entity_set_float(ent, EV_FL_renderamt, fFadeAmount[ent]);

        set_task(0.1, "weapon_fadeOut", ent);
    }
    else
    {
        new szClass[32];

        entity_get_string(ent, EV_SZ_classname, szClass, charsmax(szClass));

        if(equal(szClass, "weaponbox"))
        {
            call_think(ent);
        }
        else
        {
            remove_entity(ent);
        }
    }
}


public item_touch(ent, id)
{
    if(is_user_alive(id) && is_valid_ent(ent) && entity_get_int(ent, EV_INT_flags) & FL_ONGROUND)
    {
        new iType = entity_get_int(ent, EV_INT_iuser2);

        switch(iType)
        {
            case ITEM_MEDKIT:
            {
                new iHealth = get_user_health(id);

                if(iHealth >= 100)
                {
                    return PLUGIN_HANDLED;
                }

                set_user_health(id, clamp(iHealth + ITEM_MEDKIT_GIVE, 0, 100));

                client_print(id, print_center, "Pegou +%d de vida!", ITEM_MEDKIT_GIVE);

                emit_sound(id, CHAN_ITEM, SND_GETMEDKIT, VOL_NORM, ATTN_NORM, 0, 110);
            }
            case ITEM_ADRENALINE:
            {
                new iAdrenaline = get_user_adrenaline(id);

                if(iAdrenaline >= 100)
                {
                    return PLUGIN_HANDLED;
                }

                iAdrenaline = clamp(iAdrenaline + ITEM_ADRENALINE_GIVE, 0, 100);
                set_user_adrenaline(id, iAdrenaline);

                client_print(id, print_center, "Pegou +%d de adrenalina!", ITEM_ADRENALINE_GIVE);

                emit_sound(id, CHAN_ITEM, SND_GETADRENALINE, VOL_NORM, ATTN_NORM, 0, 140);
            }

        }

        remove_task(ent);
        remove_entity(ent);
    }

    return PLUGIN_CONTINUE;
}