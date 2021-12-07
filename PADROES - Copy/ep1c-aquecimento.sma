#include < amxmodx >


#define WARMUP_TIME 50

public gmsgCurWeapon;


public plugin_init()
{
    register_plugin("ep1c: Aquecimento", "1.0.0", "AdamRichard21st");

    gmsgCurWeapon = register_event("CurWeapon", "CurWeapon", "b", "1=1", "2!29");

    CountDown(WARMUP_TIME);
}


public CountDown(seconds)
{
    set_hudmessage(random(256), random(256), random(256), .fxtime = 3.0, .holdtime = 6.0, .channel = 1);

    if ( !seconds )
    {
        show_hudmessage(0, "-- LIVE --");

        server_cmd("sv_restart 3");

        disable_event(gmsgCurWeapon);
        return;
    }

    show_hudmessage(0, ">> ep1c gaming Brasil - Aquecimento faca - %ds <<", seconds);

    set_task(1.0, "CountDown", --seconds);
}


public CurWeapon(id)
{
    if ( is_user_alive(id) )
    {
        engclient_cmd(id, "weapon_knife");
    }
}
