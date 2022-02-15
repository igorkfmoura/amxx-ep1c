#include <amxmodx>
#include <reapi>
#include <engine>

#define PLUGIN  "ReFreeArmor"
#define VERSION "0.1"
#define AUTHOR  "lonewolf"

public plugin_init()
{
  register_plugin(PLUGIN, VERSION, AUTHOR);

  RegisterHookChain(RG_CBasePlayer_Spawn, "event_CBasePlayer_Spawn", .post=true);
}


public event_CBasePlayer_Spawn(id)
{
  if (is_user_alive(id))
  {
    set_task(2.5, "player_updateRenderDelayed", id+7896)
  }
}


public player_updateRenderDelayed(id)
{
    id -= 7896;
    set_ent_rendering(id);
}
