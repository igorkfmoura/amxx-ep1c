#include <amxmodx>
#include <engine>

new last_spray_ids[5];
new Float:last_spray_time[5];

public plugin_init()
{
    register_plugin("ep1c_last_sprays", "0.1", "lonewolf");
    register_impulse(201, "logo");

    register_clcmd("say /spray", "cmd_spray");
}


public logo(id)
{
    last_spray_ids[4] = last_spray_ids[3];
    last_spray_ids[3] = last_spray_ids[2];
    last_spray_ids[2] = last_spray_ids[1];
    last_spray_ids[1] = last_spray_ids[0];
    last_spray_ids[0] = id;

    last_spray_time[4] = last_spray_time[3];
    last_spray_time[3] = last_spray_time[2];
    last_spray_time[2] = last_spray_time[1];
    last_spray_time[1] = last_spray_time[0];
    last_spray_time[0] = get_gametime();
}


public cmd_spray(id)
{
    new menu = menu_create("Menu sprays", "menu_spray_handler");
    new Float:gametime = get_gametime();

    for (new i = 0; i < 5; ++i)
    {
        new _id = last_spray_ids[i];
        if (!is_user_connected(_id))
        {
            continue;
        }

        new text[48];
        get_user_name(_id, text, charsmax(text));
        
        format(text, charsmax(text), "\y[%3.1f]\w %s", last_spray_time[i] - gametime, text);
        
        menu_additem(menu, text);
    }

    menu_display(id, menu);

    return PLUGIN_CONTINUE;
}


public menu_spray_handler(id, menu, item)
{
    menu_destroy(menu);

    return PLUGIN_CONTINUE;
}