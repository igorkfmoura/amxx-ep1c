// #define DEBUG_C4 1

#include <amxmodx>
#include <reapi>

#pragma semicolon 1;

#define PLUGIN  "ep1c_4fun_c4_manager"
#define VERSION "0.1.2"
#define AUTHOR  "lonewolf"

#define TASK_STOPC4 79822

new terrorist_list[MAX_PLAYERS + 1];
new terrorist_count;

new bool:first_receive = true;
new bomb_only_steam;


public plugin_init()
{
  register_plugin(PLUGIN, VERSION, AUTHOR);

  bind_pcvar_num(create_cvar("amx_bomb_only_steam", "1"), bomb_only_steam);

  register_logevent("event_spawn_c4", 3, "2=Spawned_With_The_Bomb");

  RegisterHookChain(RG_CSGameRules_RestartRound, "event_restartround");

}


public event_restartround()
{
  first_receive = true;

  return HC_CONTINUE;
}


public event_spawn_c4()
{
  new id = get_log_user();

  if (!is_user_connected(id) || !is_user_alive(id))
  {
    return PLUGIN_CONTINUE;
  }

  if (first_receive)
  {
    first_receive = false;
    rg_transfer_c4(id); // randomize

    return PLUGIN_CONTINUE;
  }

  if (bomb_only_steam && is_user_alive(id) && !is_user_steam(id))
  {
    terrorist_count = 0;
    for (new i = 1; i <= MaxClients; ++i)
    {
      if (is_user_connected(i) && (get_member(i, m_iTeam) == TEAM_TERRORIST) && is_user_steam(i))
      {
        terrorist_list[terrorist_count] = i;
        terrorist_count++;
      }
    }

    terrorist_list[terrorist_count] = 0;

    if (!terrorist_count)
    {
      return PLUGIN_CONTINUE;
    }

    new receiver = terrorist_list[random_num(0, (terrorist_count - 1))];

    if (id != receiver && is_user_alive(receiver))
    {
      rg_transfer_c4(id, receiver);
    }
  }

  return PLUGIN_CONTINUE;
}


public get_log_user()
{
	new log[80], name[MAX_NAME_LENGTH];
	
	read_logargv(0, log, charsmax(log));
	parse_loguser(log, name, charsmax(name));
	
	return get_user_index(name);
}