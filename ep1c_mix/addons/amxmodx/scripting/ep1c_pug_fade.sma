#include <amxmodx>

#define PLUGIN  "ep1c_fade_dead"
#define VERSION "0.1"
#define AUTHOR  "lonewolf"

new MSG_ID_SCREENFADE;
new fade_dead;
// new hudsync1;

public plugin_init()
{
  register_plugin(PLUGIN, VERSION, AUTHOR);

  MSG_ID_SCREENFADE = get_user_msgid("ScreenFade");
  register_message(MSG_ID_SCREENFADE, "msg_ScreenFade");

  bind_pcvar_num(create_cvar("amx_fade_dead", "1"), fade_dead);
}


public msg_ScreenFade(msgid, msgdest, msgent)
{
  if (!fade_dead || !is_user_connected(msgent) || is_user_alive(msgent))
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
  
  if (get_user_team(msgent) != _:CS_TEAM_SPECTATOR)
  {
    return PLUGIN_CONTINUE;
  }

  new r = get_msg_arg_int(4);
  new g = get_msg_arg_int(5);
  new b = get_msg_arg_int(5);

  if ((r == g) && (g == b) && (b == 0))
  {
      set_msg_arg_int(7, ARG_BYTE, 0);
  }
  
  return PLUGIN_CONTINUE;
}