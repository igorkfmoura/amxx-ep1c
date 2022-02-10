#include <amxmodx>
#include <engine>
#include <hamsandwich>


#define PLUGIN  "StopBots"
#define VERSION "0.1"
#define AUTHOR  "lonewolf"

new bool:bots_stopped = false;

public plugin_init()
{
  register_plugin(PLUGIN, VERSION, AUTHOR)
  
  register_clcmd("say /stopbots", "cmd_stopbots", ADMIN_CVAR);
  register_clcmd("stopbots",      "cmd_stopbots", ADMIN_CVAR);

  RegisterHam(Ham_Spawn, "player", "Ham_PlayerSpawn_Post", true)
}

public client_connected(id)
{
  if (bots_stopped && is_user_bot(id))
  {
    new flags = entity_get_int(id, EV_INT_flags); 
    entity_set_int(id, EV_INT_flags, flags | FL_FROZEN);
  }
}

public cmd_stopbots(id)
{
  bots_stopped = !bots_stopped;
  client_print(id, print_center, "%s %s!", PLUGIN, bots_stopped ? "Enabled" : "Disabled");

  if (bots_stopped)
  {
    for (new bot = 1; bot <= MaxClients; ++bot)
    {
      if (!is_user_bot(bot))
      {
        continue;
      }
      new flags = entity_get_int(bot, EV_INT_flags);
      flags = bots_stopped ? (flags | FL_FROZEN) : (flags & ~FL_FROZEN);
      entity_set_int(bot, EV_INT_flags, flags);
    }
  }
}


public Ham_PlayerSpawn_Post(id)
{
  if (bots_stopped && is_user_connected(id) && is_user_bot(id))
  {
    new flags = entity_get_int(id, EV_INT_flags);
    flags |= FL_FROZEN;
    entity_set_int(id, EV_INT_flags, flags);
  }
}


public client_cmdStart(id)
{
  return (bots_stopped && is_user_bot(id)) ? PLUGIN_HANDLED : PLUGIN_CONTINUE;
}

public client_PostThink(id)
{
  if (bots_stopped && is_user_bot(id))
  {
    new flags = entity_get_int(id, EV_INT_flags); 
    entity_set_int(id, EV_INT_button, flags & ~(FL_DUCKING));
    entity_set_int(id, EV_INT_bInDuck, 0);
  }

  return PLUGIN_CONTINUE;  
}