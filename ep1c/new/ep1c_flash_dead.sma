#include <amxmodx>

#define PLUGIN  "ep1c_flash_dead"
#define VERSION "0.1"
#define AUTHOR  "lonewolf"

new MSG_ID_SCREENFADE;
new flash_dead;
new hudsync1;

public plugin_init()
{
  register_plugin(PLUGIN, VERSION, AUTHOR);

  MSG_ID_SCREENFADE = get_user_msgid("ScreenFade");
  register_message(MSG_ID_SCREENFADE, "msg_ScreenFade");

  bind_pcvar_num(create_cvar("amx_flash_dead", "1"), flash_dead);
  
  hudsync1 = CreateHudSyncObj();
}


public msg_ScreenFade(msgid, msgdest, msgent)
{
  if (!flash_dead || !is_user_connected(msgent) || is_user_alive(msgent))
  {
    return PLUGIN_CONTINUE;
  }
  
  new argc = get_msg_args();

  if (argc < 7)
  {
    return PLUGIN_CONTINUE;
  }

  new alpha = get_msg_arg_int(7);
  if (alpha != 255)
  {
    return PLUGIN_CONTINUE;
  }
  
  new duration  = get_msg_arg_int(1);
  new Float:tmp = duration / 4096.0 / 3.0;
  
  set_hudmessage(200, 50, 0, -1.0, -1.0, 1, tmp, tmp, 0.1, 0.1, -1);
  ShowSyncHudMsg(msgent, hudsync1, "[FLASHED]");
  
  set_msg_arg_int(7, ARG_BYTE, 180);

  return PLUGIN_CONTINUE;
}