#include <amxmodx>
#include <reapi>

static const NOTIFY_FILE[] = "sound/ep1c/notify_alert.mp3";
// static const NOTIFY_FILE[] = "sound/ep1c/loading/ep1cbemvindoclaudinho.mp3";
new CMD_STRING[64];

new subscribed;

public plugin_precache()
{
    precache_generic(NOTIFY_FILE);
}

public plugin_init()
{
    RegisterHookChain(RG_RoundEnd, "event_RG_RoundEnd");

    formatex(CMD_STRING, charsmax(CMD_STRING), "mp3 play ^"%s^"", NOTIFY_FILE);
    register_clcmd("say /notify", "cmd_notify");
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
            client_print_color(id, id, "^4[ep1c gaming Brasil]^1 Para desabilitar notificações de fim de round digite ^4/notify^1.");
        }
    }
}