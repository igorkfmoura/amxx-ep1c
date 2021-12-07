#include <amxmodx>
#include <engine>
#include <reapi>
#include <fakemeta>
#include <cstrike>
#include <hamsandwich>
#include <jctf>

#define PLUGIN  "ep1c-jctf-adrenaline"
#define VERSION "0.1"
#define AUTHOR  "lonewolf"

#define TASK_INVISIBILITY 3516
#define TASK_HP           55443
#define TASK_AMMO         31032
#define TASK_DAMAGE       9813

#define PREFIX "^4[ep1c gaming Brasil]^1"

enum AmmoInfo
{
  WEAPONID,
  CLIP,
  BPAMMO
};

new weapons[][AmmoInfo] =
{
  {CSW_NONE,        0,   0},
  {CSW_P228,       13,  52},
  {CSW_NONE,        0,   0},
  {CSW_SCOUT,      10,  90},
  {CSW_NONE,        0,   0},
  {CSW_XM1014,      7,  32},
  {CSW_NONE,        0,   0},
  {CSW_MAC10,      30, 100},
  {CSW_AUG,        30,  90},
  {CSW_NONE,        0,   0},
  {CSW_ELITE,      30, 120},
  {CSW_FIVESEVEN,  20, 100},
  {CSW_UMP45,      25, 100},
  {CSW_SG550,      30,  90},
  {CSW_GALIL,      35,  90},
  {CSW_FAMAS,      25,  90},
  {CSW_USP,        12, 100},
  {CSW_GLOCK18,    20, 120},
  {CSW_AWP,        10,  30},
  {CSW_MP5NAVY,    30, 120},
  {CSW_M249,      100, 200},
  {CSW_M3,          8,  32},
  {CSW_M4A1,       30,  90},
  {CSW_TMP,        30, 120},
  {CSW_G3SG1,      20,  90},
  {CSW_NONE,        0,   0},
  {CSW_DEAGLE,      7,  35},
  {CSW_SG552,      30,  90},
  {CSW_AK47,       30,  90},
  {CSW_NONE,        0,   0},
  {CSW_P90,        50, 100},
  {CSW_NONE,        0,   0},
  {CSW_NONE,        0,   0},
  {CSW_NONE,        0,   0}
};

new const SND_ADRENALINE[] = "ambience/des_wind3.wav";

new const gDamageSounds[ ][ ] =
{
    "debris/metal1.wav",
    "debris/metal2.wav",
    "debris/metal3.wav"
};

new gSpr_regeneration;
new gSpr_blood1;
new gSpr_blood2;

new Float:endtime[MAX_PLAYERS+1];
new bool:bought[MAX_PLAYERS+1];
new bool:infinite_ammo[MAX_PLAYERS+1];
new bool:double_damage[MAX_PLAYERS+1];
new bool:regenerating[MAX_PLAYERS+1];

public plugin_precache()
{
    precache_generic(SND_ADRENALINE);
    gSpr_regeneration = precache_model("sprites/th_jctf_heal.spr");
    gSpr_blood1 = precache_model("sprites/blood.spr");
    gSpr_blood2 = precache_model("sprites/bloodspray.spr")

    new i;
    for( i = 0; i < sizeof gDamageSounds; i++ )
    {
        precache_sound( gDamageSounds[ i ] );
    }

}

public plugin_init() 
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_event_ex("DeathMsg", "event_player_killed", RegisterEvent_Global);

    shop_add_item("Regeneração",      0, "buy_regenerate");
    shop_add_item("Invisibilidade",   0, "buy_invisibility");
    shop_add_item("Munição Infinita", 0, "buy_ammo");
    shop_add_item("Dobro de Dano",    0, "buy_damage");


    RegisterHam(Ham_TakeDamage, "player", "player_damage");
    register_message(get_user_msgid("CurWeapon"), "message_CurWeapon");

    register_dictionary("jctf.txt");
}


public client_connected(id)
{
    bought[id] = false;
}


public client_disconnected(id)
{
    bought[id] = false;
    remove_task(TASK_INVISIBILITY + id);
    remove_task(TASK_HP + id);
}


public buy_regenerate(id)
{
    if(bought[id])
    {
        client_print_color(id, print_team_default, "%s Você já está usando sua ^3adrenalina^1!", PREFIX);
        return PLUGIN_HANDLED;
    }

    emit_sound(id, CHAN_ITEM, SND_ADRENALINE, VOL_NORM, ATTN_NORM, 0, 255);

    endtime[id] = get_gametime() + 10.0;
    bought[id] = true;
    regenerating[id] = true;

    client_print_color(id, print_team_default, "%s Você comprou ^3Regeneração^1 por ^3100^1 de adrenalina!", PREFIX);
    set_task(0.1, "task_hp", TASK_HP + id);

    return PLUGIN_CONTINUE;
}

public task_hp(id)
{
    id -= TASK_HP;
    new Float:remaining = endtime[id] - get_gametime();
    
    client_print(id, print_center, "%L", id, "Regenerando HP por %.1f %s", remaining, (remaining > 1.9 ? "s" : ""));
    
    if(remaining < 0.1)
    {
        remove_task(id+TASK_HP);
        client_print_color(id, print_team_default, "%s A ^3regeneração de HP^1 chegou ao fim.", PREFIX);
        bought[id] = false;
        regenerating[id] = false;

        return;
    }

    new Float:health = get_entvar(id, var_health)
    
    if(health < 150.0)
    {
        set_entvar(id, var_health, floatmin(health + 3.0, 120.0));
    }
    
    set_task(0.1, "task_hp", TASK_HP + id);

    player_healingEffect(id);
}



public buy_invisibility(id)
{
    if(bought[id])
    {
        client_print_color(id, print_team_default, "%s %L.", id, PREFIX, "PRINT_ITEM_USE");
        return PLUGIN_HANDLED;
    }
    
    emit_sound(id, CHAN_ITEM, SND_ADRENALINE, VOL_NORM, ATTN_NORM, 0, 255);

    endtime[id] = get_gametime() + 10.0;
    bought[id] = true;

    client_print_color(id, print_team_default, "%s %L.", id, PREFIX, "PRINT_ITEM_INVISIBILITY_BUY");
    
    set_ent_rendering(id, kRenderFxNone, 30, 30, 30, kRenderFxGlowShell, 10);

    set_task(0.1, "task_invisibility", TASK_INVISIBILITY + id);
    return PLUGIN_CONTINUE;
}


public task_invisibility(id)
{
    id -= TASK_INVISIBILITY;

    new Float:remaining = endtime[id] - get_gametime();
    
    client_print(id, print_center, "%L", id, "PRINT_I_ITEM", remaining, (remaining > 1.9 ? "s" : ""));
    
    if(remaining >= 0.1)
    {
        set_task(0.1, "task_invisibility", TASK_INVISIBILITY + id);
    }
    else
    {
        client_print_color(id, print_team_default, "%s %L.", id, PREFIX, "PRINT_ITEM_INVISIBILITY_END");
        bought[id] = false;
        set_ent_rendering(id);
    }

    
}

public event_player_killed()
{
    new victim = read_data(2);
    if(is_user_connected(victim))
    {
        bought[victim] = false;
        remove_task(TASK_INVISIBILITY + victim);
        remove_task(TASK_HP + victim);
        remove_task(TASK_AMMO + victim);
        remove_task(TASK_DAMAGE + victim);
    }
}

player_healingEffect(id)
{
    new iOrigin[3]
    get_user_origin(id, iOrigin)

    message_begin(MSG_PVS, SVC_TEMPENTITY, iOrigin)
    write_byte(TE_PROJECTILE)
    write_coord(iOrigin[0] + random_num(-10, 10))
    write_coord(iOrigin[1] + random_num(-10, 10))
    write_coord(iOrigin[2] + random_num(0, 30))
    write_coord(0)
    write_coord(0)
    write_coord(15)
    write_short(gSpr_regeneration)
    write_byte(1)
    write_byte(id)
    message_end()
}


public buy_ammo(id)
{
    if(bought[id])
    {
        client_print_color(id, print_team_default, "^1[^4CTF^1] %L.", id, "PRINT_ITEM_USE")
        return PLUGIN_HANDLED
    }
    
    bought[id] = true
    client_print_color(id, print_team_default, "^1[^4CTF^1] %L.", id, "PRINT_ITEM_BULLETS_BUY")
    
    if(task_exists(id+TASK_AMMO))
        remove_task(id+TASK_AMMO)
    
    infinite_ammo[id] = true;
    endtime[id] = get_gametime() + 20.0;
    set_task(0.1, "task_ammo", TASK_AMMO + id);
    
    return PLUGIN_CONTINUE;
}

public task_ammo(id)
{
    id -= TASK_AMMO;
    new Float:remaining = endtime[id] - get_gametime();
    
    client_print(id, print_center, "%L", id, "Bala infinita por %.1f %s", remaining, (remaining > 1.9 ? "s" : ""));
    
    if(remaining < 0.1)
    {
        remove_task(id+TASK_HP);
        client_print_color(id, print_team_default, "%s As ^3Munições infinitas^1 chegaram ao fim.", PREFIX);
        bought[id] = false;
        infinite_ammo[id] = false;

        return;
    }

    set_task(0.1, "task_ammo", TASK_AMMO + id);
}

public message_CurWeapon(msg_id, msg_dest, msg_entity)
{
    new id = msg_entity;

    if(!infinite_ammo[id])
        return
    
    if(!is_user_alive(id) || get_msg_arg_int(1) != 1)
        return;
    
    static weapon, clip;
    weapon = get_msg_arg_int(2);
    clip = get_msg_arg_int(3);
    
    if(weapons[weapon][CLIP] > 2)
    {        
        if(clip < 2)
        {
            for (new slot = CS_WEAPONSLOT_PRIMARY; slot <= CS_WEAPONSLOT_SECONDARY; ++slot)
            {
                new weapon_id = get_ent_data_entity(id, "CBasePlayer", "m_rgpPlayerItems", slot);
                if (is_valid_ent(weapon_id))
                {
                      new weapon_type = get_ent_data(weapon_id, "CBasePlayerItem", "m_iId");
                      if (weapon == weapon_type && weapon_type > 0 && weapon_type <= CSW_P90 && weapons[weapon_type][WEAPONID])
                      {
                          static weapon_name[32];
                          cs_get_item_alias(weapon_type, weapon_name, charsmax(weapon_name));

                          cs_set_weapon_ammo(weapon_id, weapons[weapon_type][CLIP]);
                          cs_set_user_bpammo(id, weapon_type, weapons[weapon_type][BPAMMO]);

                        //   client_print_color(id, id, "%s Refilling ^3%s^1 ammo...", PREFIX, weapon_name);

                          set_msg_arg_int(3, get_msg_argtype(3), weapons[weapon][CLIP])
                          break;
                      }
                }
            }
        }
    }
}


public buy_damage(id)
{
    if(bought[id])
    {
        client_print_color(id, print_team_default, "^1[^4CTF^1] %L.", id, "PRINT_ITEM_USE");
        return PLUGIN_HANDLED;
    }
    
    bought[id] = true;
    client_print_color(id, print_team_default, "%s DOBRO DE DANO", PREFIX);
    
    if(task_exists(id+TASK_DAMAGE))
        remove_task(id+TASK_DAMAGE)
    
    double_damage[id] = true;
    endtime[id] = get_gametime() + 20.0;
    set_task(0.1, "task_damage", TASK_DAMAGE + id);
    
    return PLUGIN_CONTINUE;
}


public task_damage(id)
{
    id -= TASK_DAMAGE;
    new Float:remaining = endtime[id] - get_gametime();
    
    client_print(id, print_center, "%L", id, "Dobro de dano por %.1f %s", remaining, (remaining > 1.9 ? "s" : ""));
    
    if(remaining < 0.1)
    {
        remove_task(id+TASK_HP);
        client_print_color(id, print_team_default, "%s O ^3Dobro de dano^1 chegou ao fim.", PREFIX);
        bought[id] = false;
        double_damage[id] = false;

        return;
    }

    set_task(0.1, "task_damage", TASK_DAMAGE + id);
}


public player_damage(id, weapon, attacker, Float:damage, type)
{
    if(is_user_connected(attacker) && is_user_connected(id) && get_user_team(attacker) != get_user_team(id))
    {
        if (regenerating[id])
        {
            damage *= 0.7;
            SetHamParamFloat(4, damage);
            emit_sound(id, CHAN_STATIC, gDamageSounds[random_num(0, charsmax(gDamageSounds))], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
        }

        if (double_damage[attacker])
        {
            damage *= 2.0;
            SetHamParamFloat(4, damage);

            new origin[3];
            get_user_origin(id, origin);

            message_begin(MSG_PVS, SVC_TEMPENTITY, origin);
            write_byte(TE_BLOODSPRITE);
            write_coord(origin[0] + random_num(-15, 15));
            write_coord(origin[1] + random_num(-15, 15));
            write_coord(origin[2] + random_num(-15, 15));
            write_short(gSpr_blood2);
            write_short(gSpr_blood1);
            write_byte(248);
            write_byte(18);
            message_end();
        }

        return HAM_OVERRIDE;
    }
    return HAM_IGNORED;
}