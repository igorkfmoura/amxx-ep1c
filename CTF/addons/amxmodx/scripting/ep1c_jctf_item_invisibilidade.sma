#include <amxmodx>
#include <engine>
#include <jctf>

#define PLUGIN  "ep1c-item-invisibilidade"
#define VERSION "0.1"
#define AUTHOR  "lonewolf"

#define TASK_ID 3516

#define PREFIX "^4[ep1c gaming Brasil]^1"

new const SND_ADRENALINE[] = "ambience/des_wind3.wav";

new Float:endtime[MAX_PLAYERS+1];
new bool:bought[MAX_PLAYERS+1];

public plugin_precache()
{
    precache_generic(SND_ADRENALINE);
}

public plugin_init() 
{
    register_plugin("Item Invisibilidade", "1.0", "lonewolf");

    register_event_ex("DeathMsg", "event_player_killed", RegisterEvent_Global);
    shop_add_item("MENU_SPITEMS_OP_1", 100, "buy_invisibility");
    
    register_dictionary("jctf.txt");
}


public client_connected(id)
{
    bought[id] = false;
}


public client_disconnected(id)
{
    bought[id] = false;
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
    
    set_ent_rendering(id, kRenderFxNone, 15, 15, 15, kRenderFxGlowShell, 10);

    set_task(0.1, "handle_invisibility", TASK_ID + id);
    return PLUGIN_CONTINUE;
}


public handle_invisibility(id)
{
    id -= TASK_ID;

    new Float:remaining = endtime[id] - get_gametime();
    
    client_print(id, print_center, "%L", id, "PRINT_I_ITEM", remaining, (remaining > 1.9 ? "s" : ""));
    
    if(remaining >= 0.1)
    {
        set_task(0.1, "handle_invisibility", TASK_ID + id);
    }
    else
    {
        client_print_color(id, print_team_default, "%s %L.", id, "PRINT_ITEM_INVISIBILITY_END", PREFIX);
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
        remove_task(TASK_ID + victim);
    }
}
