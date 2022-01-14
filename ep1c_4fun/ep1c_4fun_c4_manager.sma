// #define DEBUG_C4 1

#include <amxmodx>
#include <reapi>

#pragma semicolon 1;

#define PLUGIN  "ep1c_4fun_c4_manager"
#define VERSION "0.1"
#define AUTHOR  "lonewolf"

#define re_get_user_buyzone(%1) (get_member((%1), m_signals) & SIGNAL_BUY)

#define TASK_STOPC4 79822

// new const MAX_TRANSFERS = 5;
// new c4_transfers_in_round;

new terrorist_list[MAX_PLAYERS + 1];
new terrorist_count;
new bool:first_receive = true;

new authids[MAX_PLAYERS + 1][MAX_AUTHID_LENGTH];

new bomb_only_steam;

#if defined DEBUG_C4
new debug_authid[] = "STEAM_0:0:8354200";
new debug_id;
#endif

new bool:c4_handled = false;


public plugin_init()
{
  register_plugin(PLUGIN, VERSION, AUTHOR);

  bind_pcvar_num(create_cvar("amx_bomb_only_steam", "1"), bomb_only_steam);

  // register_event("WeapPickup", "event_receive_c4", "be", "1=6");
  // register_event("ScoreAttrib", "event_receive_c4", "bc", "2=2");
  register_logevent("event_spawn_c4", 3, "2=Spawned_With_The_Bomb");
  // RegisterHookChain(RG_CBasePlayer_Spawn, "player_spawn", .post=true);

  RegisterHookChain(RG_CSGameRules_GiveC4, "event_stop_c4", .post=true);
  RegisterHookChain(RG_CSGameRules_RestartRound, "event_restartround");

#if defined DEBUG_C4
  console_print(0, "[%s] Debug enabled", PLUGIN);
  register_concmd("debug_c4", "cmd_debug_c4");
#endif
}


#if defined DEBUG_C4
public cmd_debug_c4(id)
{
  console_print(id, "[%s] debug_authid: %s, debug_id: %d", PLUGIN, debug_authid, debug_id);
  console_print(id, "[%s] bomb_only_steam: %d, first_receive: %d", PLUGIN, bomb_only_steam, first_receive);

  new buf[64];
  
  if (!terrorist_count)
  {
    copy(buf, charsmax(buf), "No terrorists");
  }
  else
  {
    for (new i = 0; i < (terrorist_count - 1); ++i)
    {
      format(buf, charsmax(buf), "%s%d, ", buf, terrorist_list[i]);
    }
    format(buf, charsmax(buf), "%s%d", buf, terrorist_list[terrorist_count -1 ]);
  }
  console_print(id, "[%s] terrorist_count: %d, Valid TRs: {%s}", PLUGIN, terrorist_count, buf);

  return PLUGIN_HANDLED;
}
#endif

// thanks IceeedR
public client_authorized(id, const authid[])
{
  copy(authids[id], MAX_AUTHID_LENGTH, authid);

#if defined DEBUG_C4
  if (equal(authid, debug_authid))
  {
    debug_id = id;
  }
#endif
}


public client_disconnected(id)
{
  authids[id][0] = '^0';
  
#if defined DEBUG_C4
  if (id == debug_id)
  {
    debug_id = 0;
  }
#endif
}


public event_restartround()
{
  first_receive = true;
  c4_handled = false;

  terrorist_count = 0;
  for (new id = 1; id <= MaxClients; ++id)
  {
    if (is_user_connected(id) && (get_member(id, m_iTeam) == TEAM_TERRORIST) && is_user_steam(id))
    {
      terrorist_list[terrorist_count] = id;
      terrorist_count++;
// #if defined DEBUG_C4
//       client_print_color(debug_id, print_team_red, "^4[%s]^1 terrorist_list[%d]: %d, authids[%d]: %s, is_user_steam(%d): %d", PLUGIN, terrorist_count-1, terrorist_list[terrorist_count-1], id, authids[id], id, is_user_steam(id));
// #endif
    }
    
// #if defined DEBUG_C4
//     client_print_color(debug_id, print_team_red, "^4[%s]^1 {%02d} #1: %d, #2: %d, #3: %d", PLUGIN, id, is_user_connected(id), (get_member(id, m_iTeam) == TEAM_TERRORIST), is_user_steam(id));
// #endif
  }

  terrorist_list[terrorist_count] = 0;

#if defined DEBUG_C4
  if (debug_id)
  {
    new buf[64];
  
    if (!terrorist_count)
    {
      copy(buf, charsmax(buf), "No terrorists");
    }
    else
    {
      for (new i = 0; i < (terrorist_count - 1); ++i)
      {
        format(buf, charsmax(buf), "%s%d, ", buf, terrorist_list[i]);
      }
      format(buf, charsmax(buf), "%s%d", buf, terrorist_list[terrorist_count-1]);
    }

    client_print_color(debug_id, print_team_red, "^4[%s]^1 Valid TRs: ^3{%s}^1", PLUGIN, buf);
  }
#endif

  return HC_CONTINUE;
}


public event_spawn_c4()
{
  new id = GetLogUser();

  if (c4_handled || !is_user_alive(id))
  {
    return HC_CONTINUE;
  }


  if (first_receive)
  {
    first_receive = false;
    rg_transfer_c4(id); // randomize

#if defined DEBUG_C4
    if (debug_id)
    {
      new name1[MAX_NAME_LENGTH];
      get_user_name(id, name1, charsmax(name1));
      client_print_color(debug_id, print_team_red, "^4[%s]^1 First C4: ^3[%d] %s^1", PLUGIN, id, name1);
    }
#endif

    return HC_CONTINUE;
  }
#if defined DEBUG_C4
  if (debug_id)
  {
    new name1[MAX_NAME_LENGTH];
    get_user_name(id, name1, charsmax(name1));
    client_print_color(debug_id, print_team_red, "^4[%s]^1 is_user_alive(%d): %d, !is_user_steam(%d): %d", PLUGIN, id, is_user_alive(id), id, !is_user_steam(id));
    client_print_color(debug_id, print_team_red, "^4[%s]^1 re_get_user_buyzone(%d): %d, terrorist_count: %d", PLUGIN, id, re_get_user_buyzone(id), terrorist_count);
  }
#endif

  if (is_user_alive(id) && !is_user_steam(id) /*&& re_get_user_buyzone(id) */&& terrorist_count)
  {
    new receiver = terrorist_list[random_num(0, (terrorist_count - 1))];
#if defined DEBUG_C4
    if (debug_id)
    {
      client_print_color(debug_id, print_team_red, "^4[%s]^1 id: %d, receiver: %d", PLUGIN, id, receiver);
    }
#endif
    if (id != receiver && is_user_alive(receiver))
    {
      if (bomb_only_steam)
      {
        rg_transfer_c4(id, receiver);
      }

#if defined DEBUG_C4
      if (debug_id)
      {
        new name1[MAX_NAME_LENGTH];
        new name2[MAX_NAME_LENGTH];
        get_user_name(id, name1, charsmax(name1));
        get_user_name(receiver, name2, charsmax(name2));

        client_print_color(debug_id, print_team_red, "^4[%s]^1 Transfering: ^3%s^1 -> ^3%s^1.", PLUGIN, name1, name2);
      }
#endif
    }
  }

  return HC_CONTINUE;
}

public event_stop_c4()
{
  remove_task(TASK_STOPC4);
  set_task(1.0, "task_stop_c4", TASK_STOPC4);
}

public task_stop_c4(id)
{
  c4_handled = true;
#if defined DEBUG_C4
  if (debug_id)
  {
    client_print_color(debug_id, print_team_red, "^4[%s]^1 (task_stop_c4), c4_handled: %d", PLUGIN, c4_handled);
  }
#endif
}

GetLogUser( ) {
	new szLogUser[ 80 ], szName[ 32 ];
	
	read_logargv( 0, szLogUser, 79 );
	parse_loguser( szLogUser, szName, 31 );
	
	return get_user_index( szName );
}