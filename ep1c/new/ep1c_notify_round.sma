#include <amxmodx>
#include <reapi>

#define PLUGIN  "ep1c_notify_round"
#define VERSION "0.1"
#define AUTHOR  "lonewolf"

static const NOTIFY_FILE[] = "sound/ep1c/notify_alert.mp3";

new CMD_STRING[128];

new subscribed;

static const cmds[][12] =
{
    "notify",
    "alert",
    "alerta"
};

public plugin_precache()
{
    precache_generic(NOTIFY_FILE);
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    RegisterHookChain(RG_RoundEnd, "event_RG_RoundEnd");
    formatex(CMD_STRING, charsmax(CMD_STRING), "mp3 play ^"%s^"", NOTIFY_FILE);
    
    for (new i = 0; i < sizeof(cmds); ++i)
    {
        new tmp[24];
        format(tmp, charsmax(tmp), "say /%s", cmds[i]);
        register_clcmd(tmp, "cmd_notify");

        format(tmp, charsmax(tmp), "say .%s", cmds[i]);
        register_clcmd(tmp, "cmd_notify");

        format(tmp, charsmax(tmp), "say_team /%s", cmds[i]);
        register_clcmd(tmp, "cmd_notify");

        format(tmp, charsmax(tmp), "say_team /%s", cmds[i]);
        register_clcmd(tmp, "cmd_notify");
    }
    
    register_clcmd("debug_notify", "cmd_debug");
}


new debug_id = 0;

public cmd_debug(id)
{
    if (!is_user_connected(id))
    {
        return PLUGIN_CONTINUE;
    }

    client_print(id, print_console, "[debug] CMD_STRING: %s", CMD_STRING);
    client_print(id, print_console, "[debug] subscribed: %d", subscribed);
    
    return PLUGIN_CONTINUE;
}


public client_connect(id)
{
    subscribed &= ~(1 << id-1);
}

public cmd_notify(id)
{
    subscribed ^= (1 << id-1);
    
    new enabled = subscribed & (1 << id-1);
    client_print_color(id, print_team_red, "^4[ep1c gaming Brasil]^1 Notificação no fim do round %s.", enabled ? "^4ativada^1" : "^3desativada^1");
    
    if (enabled)
    {
        client_print_color(id, print_team_red, "^4[ep1c gaming Brasil]^1 Ajuste o volume no console com ^4MP3Volume^1.");
    }

    return PLUGIN_CONTINUE;
}

public client_disconnected(id)
{
    subscribed &= ~(1 << id-1);
}

public event_RG_RoundEnd()
{
    if (!subscribed)
    {
        return;
    }

    for (new id = 1; id <= 32; id++)
    {
        if (subscribed & (1 << id-1) && is_user_connected(id))
        {
            client_cmd(id, CMD_STRING);
            client_print_color(id, id, "^4[ep1c gaming Brasil]^1 Para desabilitar notificações de fim de round digite ^4/alerta^1.");
        }
    }
}