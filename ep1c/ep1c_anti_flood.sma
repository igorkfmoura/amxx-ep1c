#include <amxmodx>

#define PLUGIN  "ep1c_anti_flood"
#define VERSION "0.2"
#define AUTHOR  "lonewolf"

new Float:next_say_time[MAX_PLAYERS + 1];
new flood_count[MAX_PLAYERS + 1];

new Float:flood_time;
new Float:flood_max;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_clcmd("say",      "say_check_flood");
    register_clcmd("say_team", "say_check_flood");

    bind_pcvar_float(create_cvar("amx_flood_time", "1.0"), flood_time);
    bind_pcvar_float(create_cvar("amx_flood_max",  "5.0"), flood_max);
}

public say_check_flood(id)
{
    new message[4];
    read_args(message, charsmax(message));
    remove_quotes(message)

    new Float:gametime = get_gametime()
    
    if (message[0] && (message[0] != '/') && (next_say_time[id] > gametime))
    {
        // flood_count[id] = min(flood_count[id] + 1, MAX_FLOOD_COUNT);
        flood_count[id]++;

        new Float:wait_time = floatmin(flood_time * flood_count[id], flood_max);
        next_say_time[id] = gametime + wait_time;

        client_print_color(id, print_team_red, "^3[ep1c gaming Brasil]^1 Cuidado com o spam! Espere ^4%.1f^1 segundo%spara usar o chat.", wait_time, (wait_time == 1.0) ? " " : "s ");
        
        return PLUGIN_HANDLED;
    }
    
    // flood_count[id] = max(0, flood_count[id] - 1);
    flood_count[id] = 1;

    new Float:wait_time = (flood_time * flood_count[id]);
    next_say_time[id] = gametime + wait_time;

    return PLUGIN_CONTINUE;
}