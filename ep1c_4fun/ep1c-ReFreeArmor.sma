#include <amxmodx>
#include <reapi>

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
    rg_set_user_armor(id, 100, ARMOR_VESTHELM);
  }
}
