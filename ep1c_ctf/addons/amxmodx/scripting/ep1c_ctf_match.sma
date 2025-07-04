#include <amxmodx>
#include <reapi>
#include <jctf>
#include <map_manager>
#include <bestplayer>

#define PLUGIN  "ep1c_ctf_match"
#define VERSION "0.7.1"
#define AUTHOR  "lonewolf"

#define TASKID_CLIENT_CMD 9352

new const CHAT_PREFIX[] = "^4[ep1c CTF Match]^1";

enum _:Clans
{
  TIME,
	RELA_BANDEIRA,
	CONFIA,
	ARMSTRONG,
	BOLSOLULA,
	SERIAL_KILLER,
	TRIKAS
};

new const clans[Clans][32] =
{
  "TIME",
	"RELA BANDEIRA",
	"CONFIA",
	"ARMSTRONG",
	"BOLSOLULA",
	"SERIAL KILLER",
	"TRIKAS"
};

enum _:FlagEvent
{
  FLAG_STOLEN = 0,
  FLAG_PICKED,
  FLAG_DROPPED,
  FLAG_MANUALDROP,
  FLAG_RETURNED,
  FLAG_CAPTURED,
  FLAG_AUTORETURN,
  FLAG_ADMINRETURN
};

enum _:CTFMatchConfig
{
  CTF_FREEZETIME, //float
  CTF_ROUNDTIME, //float
  CTF_MAXPOINTS,
  CTF_HAS_KNIFEROUND,
  CTF_ROUNDTIME_KNIFE, //float
  CTF_FORCERESPAWN,
  CTF_ALLTALK,
  CTF_KNIFE,
  CTF_VOTEMAP,
  CTF_DEMO
};
new cvars[CTFMatchConfig];
new config_bak[CTFMatchConfig];

enum _:CTFMatch
{
  CTF_STARTED,
  CTF_KNIFEROUND,
  TeamName:CTF_KNIFEROUND_WINNER,
  CTF_IS_1STHALF,
  CTF_IS_2NDHALF,
  CTF_TEAM_A_POINTS,
  CTF_TEAM_B_POINTS,
};
new match[CTFMatch];

new cfg_folder[32]    = "ctf"
new cfg_on_start[128] = "ctf_on_start.cfg";
new cfg_on_half[128]  = "ctf_on_half.cfg";
new cfg_on_end[128]   = "ctf_on_end.cfg";

new countdown_ent;
new countdown;

new motd_buffer[1024];

new msg_TeamScore;
new msg_ScoreInfo;
// new msg_CurWeapon; 

new kills[MAX_PLAYERS + 1];
new deaths[MAX_PLAYERS + 1];
new wins[TeamName];


// public plugin_cfg()
// {
//   new path[96];
//   get_configsdir(path, charsmax(path));
//   format(path, charsmax(path), "%s/%s", path, cfg_folder);

//   if (!dir_exists(path))
//   {
//     mkdir(path);
//   }

//   format(cfg_on_start, charsmax(cfg_on_start), "%s/%s", path, cfg_on_start);
//   format(cfg_on_half,  charsmax(cfg_on_half),  "%s/%s", path, cfg_on_half);
//   format(cfg_on_end,   charsmax(cfg_on_end),   "%s/%s", path, cfg_on_end);

//   if (!file_exists(cfg_on_start))
//   {
//     set_fail_state("ERROR: Config file not found or created: ^"%s^"", cfg_on_start);
//   }

//   if (!file_exists(cfg_on_half))
//   {
//     set_fail_state("ERROR: Config file not found or created: ^"%s^"", cfg_on_half);
//   }

//   if (!file_exists(cfg_on_end))
//   {
//     set_fail_state("ERROR: Config file not found or created: ^"%s^"", cfg_on_end);
//   }
// }


public plugin_init()
{
  register_plugin(PLUGIN, VERSION, AUTHOR);

  register_clcmd("say /ctf",          "cmd_test", ADMIN_CVAR);
  register_clcmd("say /ctfmenu",      "cmd_test", ADMIN_CVAR);
  register_clcmd("say_team /ctf",     "cmd_test", ADMIN_CVAR);
  register_clcmd("say_team /ctfmenu", "cmd_test", ADMIN_CVAR);

  cvars[CTF_FREEZETIME]   = create_cvar("ctf_match_freezetime",   "15.0");
  cvars[CTF_ROUNDTIME]    = create_cvar("ctf_match_roundtime",    "15.0");
  cvars[CTF_MAXPOINTS]    = create_cvar("ctf_match_maxpoints",    "10");
  cvars[CTF_FORCERESPAWN] = create_cvar("ctf_match_forcerespawn", "5");
  cvars[CTF_ALLTALK]      = create_cvar("ctf_match_alltalk",      "2");
  cvars[CTF_KNIFE]        = create_cvar("ctf_match_knife",        "0");
  cvars[CTF_VOTEMAP]      = create_cvar("ctf_match_votemap",      "1");
  cvars[CTF_DEMO]         = create_cvar("ctf_match_demo",         "1");

  register_concmd("ctf_match_start", "match_start", ADMIN_CVAR);
  register_concmd("ctf_match_end",   "match_end", ADMIN_CVAR);

  RegisterHookChain(RG_CSGameRules_OnRoundFreezeEnd, "event_OnRoundFreezeEnd");
  RegisterHookChain(RG_CSGameRules_RestartRound, "event_RestartRound");
  RegisterHookChain(RG_RoundEnd, "event_RoundEnd");

  register_event("CurWeapon", "event_CurWeapon", "b", "1=1", "2!29"); // todo: unregister hook
  
  msg_ScoreInfo = get_user_msgid("ScoreInfo");
  msg_TeamScore = get_user_msgid("TeamScore");
}


public event_CurWeapon(id)
{
  if (is_user_alive(id) && match[CTF_KNIFEROUND])
  {
      engclient_cmd(id, "weapon_knife");
  }
}


public cmd_test(id)
{
  if (is_user_connected(id))
  {
    menu_ctf(id);
  }

  return PLUGIN_HANDLED;
}


public menu_ctf(id)
{
  new menu = menu_create("CTF Menu", "menu_ctf_handler");

  menu_additem(menu, match[CTF_STARTED] ? "\rFinalizar partida" : "Iniciar partida");
  menu_additem(menu, "\dConfigurar partida");
  menu_additem(menu, (get_cvar_num("mp_freezetime") == 1337) ? "\rDestravar times" : "Travar times na base");
  menu_additem(menu, (match[CTF_KNIFEROUND] == 0) ? "Iniciar Round Faca" : "\rFinalizar Round Faca");
  menu_additem(menu, "Insta Restart round");
  // formatex(item, charsmax(item), "Complete Reset: %s", onoff[complete_reset]);
  // menu_additem(menu, item);
  menu_addblank2(menu);

  menu_additem(menu, "Inverter times");
  menu_additem(menu, "Forçar fim de round");
  
  menu_display(id, menu);
}


public menu_ctf_handler(id, menu, item)
{
  if (item == MENU_EXIT || !is_user_connected(id))
  {
    menu_destroy(menu);
    return PLUGIN_HANDLED;
  }

  // client_print_color(id, id, "^4[menu_ctf_handler]^1 item: %d", item);

  switch (item)
  {
    case 0:
    {
      if (match[CTF_STARTED])
      {
        match_end();
      }
      else
      {
        match_start();
      }
    }
    case 1:
    {

    }
    case 2:
    {
      set_hudmessage(255, 255, 255, -1.0, 0.29, 1, 6.0, 6.0);

      if (get_cvar_num("mp_freezetime") == 1337)
      {
        set_cvar_num("mp_freezetime", config_bak[CTF_FREEZETIME]);
        show_hudmessage(0, "TIMES DESTRAVADOS");
      }
      else
      {
        config_bak[CTF_FREEZETIME] = get_cvar_num("mp_freezetime");
        set_cvar_num("mp_freezetime", 1337);
        show_hudmessage(0, "TIMES TRAVADOS NA BASE");
      }

      // rg_restart_round();
      // elog_message("World triggered ^"Round_End^"^n");
      server_cmd("sv_restart 1");
      client_cmd(0, "spk deeoo");

    }
    case 3:
    {
      if (get_pcvar_num(cvars[CTF_KNIFE]) == 0)
      {
        match_knife_start();
      }
      else
      {
        match_knife_end();
      }
    }
    case 4:
    {
      server_cmd("sv_restart 1");
      client_cmd(0, "spk deeoo");
    }
    case 5:
    {
    }
    case 6:
    {
      rg_swap_all_players();
      proper_swap_config();
    }
    case 7:
    {
      countdown = 0;
      if (get_member_game(m_bFreezePeriod))
      {
        event_countdown(countdown_ent);
      }
    }
  }

  menu_destroy(menu);
  menu_ctf(id);
  return PLUGIN_HANDLED;
}



public match_knife_start()
{
  set_cvar_float("mp_freezetime", get_pcvar_float(cvars[CTF_FREEZETIME]));
  set_cvar_num("mp_forcerespawn", 0);
  set_cvar_num("ctf_respawntime", 0);
  set_cvar_num("dispenser_enabled", 0);
  set_cvar_string("mp_round_infinite", "bcdeghijk");
  set_cvar_num("amx_knife_rr", 0);

  match[CTF_KNIFEROUND] = 1;
  
  server_cmd("sv_restart 1");
  client_cmd(0, "spk deeoo");
  
  set_hudmessage(255, 255, 255, -1.0, 0.29, 1, 6.0, 6.0);
  show_hudmessage(0, "ROUND FACA SEM RESPAWN");
}


public match_knife_end()
{
  set_cvar_num("mp_freezetime", 1337);
  set_cvar_num("mp_forcerespawn", get_pcvar_num(cvars[CTF_FORCERESPAWN]) + 1);
  set_cvar_num("ctf_respawntime", get_pcvar_num(cvars[CTF_FORCERESPAWN]));
  
  set_cvar_num("dispenser_enabled", 1);
  set_cvar_string("mp_round_infinite", "bcdefghijk");
  set_cvar_num("amx_knife_rr", 1);
  
  match[CTF_KNIFEROUND] = 0;
  
  server_cmd("sv_restart 1");
  client_cmd(0, "spk deeoo");

  set_hudmessage(255, 255, 255, -1.0, 0.29, 1, 6.0, 6.0);
  show_hudmessage(0, "FIM DO ROUND FACA");
}


public task_freezetime_delayed(id)
{
  set_cvar_num("mp_freezetime", 1337);
}


public jctf_flag(event, id, flagteam, bool:is_assist)
{
  if (event != FLAG_CAPTURED || !match[CTF_STARTED])
  {
    return;
  }
  
  if ((flagteam != _:TEAM_TERRORIST) && (flagteam != _:TEAM_CT))
  {
    return;
  }

  new max = get_pcvar_num(cvars[CTF_MAXPOINTS]);
  new points;
  new t;

  if (flagteam == _:TEAM_CT)
  {
    points = get_member_game(m_iNumTerroristWins) + 1;
    max += wins[TEAM_TERRORIST];
    t = get_cvar_num("ctf_team_b");
  }
  else
  {
    points = get_member_game(m_iNumCTWins) + 1;
    max += wins[TEAM_CT];
    t = get_cvar_num("ctf_team_a");
  }
  
  if (points >= max)
  {
    client_print_color(0, (flagteam == _:TEAM_CT) ? print_team_red : print_team_blue, "%s Time ^3%s^1 capturou ^4%d^1 bandeiras!", CHAT_PREFIX, clans[t], points);
    countdown = 0;
  }

  // client_print(0, print_chat, "[jctf_flag] flagteam: %d, clan: %s, points: %d, max: %d", flagteam, clans[t], points, max)
}

public event_OnRoundFreezeEnd(id)
{
  if (match[CTF_KNIFEROUND] == 1)
  {
    new Float:freezetime = float(get_cvar_num("mp_freezetime"));
    set_task(freezetime + 1.0, "task_freezetime_delayed");

    match[CTF_KNIFEROUND] = 2;
  }

  if (!match[CTF_STARTED])
  {
    return HC_CONTINUE;
  }

  new Float:now = get_gametime();
  new roundtime = get_member_game(m_iRoundTime);

  new systime = get_systime();
  new timestr[64];

  format_time(timestr, charsmax(timestr), "^4%Y/%m/%d^1 - ^4%H:%M:%S^1", systime);
  client_print_color(0, print_team_red, "%s Partida começou! %s", CHAT_PREFIX, timestr);
  format_time(timestr, charsmax(timestr), "^3%Y/%m/%d^1 - ^3%H:%M:%S^1", systime + roundtime - 1);
  client_print_color(0, print_team_red, "%s Troca de lado em: %s", CHAT_PREFIX, timestr);

  if (!countdown_ent)
  {
    countdown_ent = rg_create_entity("info_target");
    SetThink(countdown_ent, "event_countdown");
    set_entvar(countdown_ent, var_classname, "ctf_countdown");
  }

  countdown = roundtime - 1;
  set_entvar(countdown_ent, var_iuser1, countdown);
  set_entvar(countdown_ent, var_nextthink, now + 1.0);
  
  set_cvar_num("bpm_ignore_restart", 0);

  return HC_CONTINUE;
}


public event_countdown(ent)
{
  if (!match[CTF_STARTED])
  {
    return HC_CONTINUE;
  }

  countdown--;
  set_entvar(countdown_ent, var_iuser1, countdown);

  static text[64];
  num_to_word(countdown, text, charsmax(text));

  if ((countdown <= 10) && countdown > 0)
  {
    client_cmd(0, "spk %s", text)
  }

  if (countdown <= 0)
  {
    if (match[CTF_IS_1STHALF])
    {
      
      new startmoney = get_cvar_num("mp_startmoney");

      for (new id = 1; id <= MaxClients; ++id)
      {
        if (!is_user_connected(id))
        {
          continue;
        }

        new TeamName:team = get_member(id, m_iTeam);
        if (team == TEAM_TERRORIST || team == TEAM_CT)
        {
          kills[id]  = floatround(get_entvar(id, var_frags));
          deaths[id] = get_member(id, m_iDeaths);
        
          set_user_adrenaline(id, 0);
          rg_add_account(id, startmoney, AS_SET);
        }
      }

      rg_swap_all_players();

      wins[TEAM_TERRORIST] = get_member_game(m_iNumTerroristWins);
      wins[TEAM_CT]        = get_member_game(m_iNumCTWins);

      proper_swap_config();

      client_cmd(0, "spk deeoo")

      set_hudmessage(255, 255, 255, -1.0, 0.29, 1, 6.0, 6.0);
      show_hudmessage(0, "TROCA DE LADO, VALENDO!");

      set_cvar_num("bpm_ignore_restart", 1);
      server_cmd("sv_restart 1");

      match[CTF_IS_1STHALF] = 0;
      match[CTF_IS_2NDHALF] = 1;
      
      return HC_CONTINUE;
    }

    if (match[CTF_IS_2NDHALF])
    {
      match_end();

      return HC_CONTINUE;
    }
  }
  
  new Float:now = get_gametime();
  set_entvar(countdown_ent, var_nextthink, now + 1.0);

  return HC_CONTINUE;
}


public proper_swap_config()
{
  new a = get_cvar_num("ctf_team_a");
  new b = get_cvar_num("ctf_team_b");
  new placedmodels_a[12];
  new placedmodels_b[12];
  new count_a = 0;
  new count_b = 0;
  new ent = MaxClients + 1;

  // while ((ent = rg_find_ent_by_class(ent, "NiceDispenser:D")))
  // {
  //   if (is_entity(ent))
  //   {
  //     set_entvar(ent, var_flags, get_entvar(ent, var_flags) | FL_KILLME);
  //   }
  // }
  ent = MaxClients + 1;
  while ((ent = rg_find_ent_by_class(ent, "placedmodel")))
  {
    if (!is_entity(ent))
    {
      continue;
    }
    new skin = get_entvar(ent, var_skin);
    if (skin == a)
    {
      placedmodels_a[count_a++] = ent;
    }
    else if (skin == b)
    {
      placedmodels_b[count_b++] = ent;
    }
  }
  new i;
  for (i = 0; i < count_a; ++i)
  {
    if (is_entity(placedmodels_a[i]))
    {
      set_entvar(placedmodels_a[i], var_skin, b);
    }
  }
  for (i = 0; i < count_b; ++i)
  {
    if (is_entity(placedmodels_b[i]))
    {
      set_entvar(placedmodels_b[i], var_skin, a);
    }
  }

  set_cvar_num("ctf_team_a", b);
  set_cvar_num("ctf_team_b", a);
  server_cmd("ctf_update");

  // set_cvar_num("mp_freezetime", get_pcvar_float(cvars[CTF_FREEZETIME]));
  // set_cvar_num("mp_roundtime", get_pcvar_float(cvars[CTF_FREEZETIME]));
}
public event_RestartRound(id)
{
  // client_print_color(0, 0, "^4[event_RestartRound]^1 triggered");

  if (!match[CTF_STARTED])
  {
    return HC_CONTINUE;
  }

  
  else if (match[CTF_IS_2NDHALF])
  {
    set_task(1.0, "task_updatescores_delayed");
  }
  return HC_CONTINUE;
}


public event_RoundEnd()
{
  if (match[CTF_KNIFEROUND] == 2)
  {
    match[CTF_KNIFEROUND] = 0;
    
    match_knife_end();
  }
}


public task_updatescores_delayed()
{
  // client_print(0, print_chat, "[event_RestartRound] match[CTF_IS_2NDHALF]")

  set_member_game(m_iNumTerroristWins, wins[TEAM_TERRORIST]);
  set_member_game(m_iNumCTWins, wins[TEAM_CT]);

  for (new id = 1; id <= MaxClients; ++id)
  {
    if (!is_user_connected(id))
    {
      continue;
    }
    new TeamName:team = get_member(id, m_iTeam);
    if (team == TEAM_TERRORIST || team == TEAM_CT)
    {
      set_entvar(id, var_frags, float(kills[id]));
      set_member(id, m_iDeaths, deaths[id]);
      
      message_begin(MSG_BROADCAST, msg_ScoreInfo);
      write_byte(id);
      write_short(kills[id]);
      write_short(deaths[id]);
      write_short(0);
      write_short(_:team);
      message_end();
    }
  }

  emessage_begin(MSG_BROADCAST, msg_TeamScore);
  ewrite_string("TERRORIST");
  ewrite_short(wins[TEAM_TERRORIST]);
  emessage_end();

  emessage_begin(MSG_BROADCAST, msg_TeamScore);
  ewrite_string("CT");
  ewrite_short(wins[TEAM_CT]);
  emessage_end();
}


public match_start()
{
  if (match[CTF_STARTED])
  {
    return;
  }

  config_bak[CTF_FREEZETIME]   = get_cvar_num("mp_freezetime");
  config_bak[CTF_ROUNDTIME]    = get_cvar_num("mp_roundtime");
  config_bak[CTF_FORCERESPAWN] = get_cvar_num("mp_forcerespawn");
  config_bak[CTF_ALLTALK]      = get_cvar_num("sv_alltalk");

  set_cvar_float("mp_freezetime", get_pcvar_float(cvars[CTF_FREEZETIME]));
  set_cvar_num("sv_alltalk", get_pcvar_num(cvars[CTF_ALLTALK]));
  set_cvar_num("amx_knife_rr", 1);
  set_cvar_num("amx_maxjumps", 1);
  set_cvar_num("ctf_menuarmas", 1);

  match[CTF_STARTED]    = true;
  // match[CTF_KNIFEROUND] = get_pcvar_num(cvars[CTF_HAS_KNIFEROUND]);
  match[CTF_KNIFEROUND_WINNER] = TEAM_UNASSIGNED;
  match[CTF_IS_1STHALF] = false;
  match[CTF_IS_2NDHALF] = false;

  wins[TEAM_TERRORIST] = 0;
  wins[TEAM_CT] = 0;

  if (0 /*&& match[CTF_KNIFEROUND]*/)
  {
    set_cvar_float("mp_roundtime",  get_pcvar_float(cvars[CTF_ROUNDTIME_KNIFE]));

    set_hudmessage(255, 255, 255, -1.0, 0.29, 1, 6.0, 6.0);
    show_hudmessage(0, "ROUND FACA! SEM RESPAWN!");

    set_cvar_string("mp_round_infinite", "bcdeghijk"); // Can end by team death;
    set_cvar_num("mp_forcerespawn", 0);
    set_cvar_num("ctf_respawntime", 0);
  }
  else
  {
    set_cvar_float("mp_roundtime",  get_pcvar_float(cvars[CTF_ROUNDTIME]));
    set_cvar_string("mp_round_infinite", "bcdefghijk");
    set_cvar_num("mp_forcerespawn", get_pcvar_num(cvars[CTF_FORCERESPAWN]) + 1);
    set_cvar_num("ctf_respawntime", get_pcvar_num(cvars[CTF_FORCERESPAWN]));

    match[CTF_IS_1STHALF] = true;
  }

  if (get_pcvar_num(cvars[CTF_DEMO]))
  {
    set_cvar_num("amx_demo_auto",   1);
    set_cvar_num("amx_demo_time",   1);
    set_cvar_num("amx_demo_map",    1);
    set_cvar_num("amx_demo_steam",  0);
    set_cvar_num("amx_demo_nick",   1);
    set_cvar_num("amx_demo_notify", 1);
  
    server_cmd("amx_demoall");
  } 

  set_cvar_num("sv_restart", 1)
  client_cmd(0, "spk deeoo");
}


public match_end()
{
  if (!match[CTF_STARTED])
  {
    return;
  }

  //client_cmd(0, "mp3 play ^"media/Half-Life08.mp3^"");

  match[CTF_STARTED]    = false;
  match[CTF_KNIFEROUND] = false;
  match[CTF_IS_1STHALF] = false;
  match[CTF_IS_2NDHALF] = false;
  
  generate_motd();
  bpm_force_intermission()

  client_cmd(0, "spk deeoo");
  set_cvar_num("sv_restart", 1)

  if (get_cvar_num("amx_warmup"))
  {
    set_cvar_num("ctf_menuarmas", 0);
    server_cmd("amx_warmup_start");
  }

  // set_cvar_float("mp_freezetime", float(config_bak[CTF_FREEZETIME]));
  set_cvar_float("mp_freezetime", 0.0);
  
  set_cvar_float("mp_roundtime",  float(config_bak[CTF_ROUNDTIME]));
  set_cvar_num("sv_alltalk",      config_bak[CTF_ALLTALK]);

  if (get_pcvar_num(cvars[CTF_VOTEMAP]))
  {
    set_cvar_num("ctf_menuarmas", 0);
    mapm_start_vote(VOTE_BY_CMD);
  }
  
  // emessage_begin(MSG_ALL, SVC_INTERMISSION);
  // emessage_end();
  // show_motd(0, motd_buffer);
}


// public mapm_vote_finished(const map[], type, total_votes)
// {
  // client_print(0, print_chat, "map: %s, type: %d, total_votes: %d", map, type, total_votes);

  
  // new mapname[64];

  // get_mapname(mapname, charsmax(mapname));

  // if (equal(mapname, map))
  // {
  //   //engine_changelevel(map);
  //   server_cmd("amx_warmup_start");
  // }
// }


public generate_motd()
{
  static buffer[128];

  wins[TEAM_TERRORIST] = get_member_game(m_iNumTerroristWins);
  wins[TEAM_CT]        = get_member_game(m_iNumCTWins);
  
  // invertido mesmo, no camp a bandeira do time adversário é a "sua"
  new a = get_cvar_num("ctf_team_a");
  new b = get_cvar_num("ctf_team_b");

  format(motd_buffer, charsmax(motd_buffer), "[%s] %d x %d [%s]<br>", clans[a], wins[TEAM_TERRORIST], wins[TEAM_CT], clans[b]);

  if (wins[TEAM_TERRORIST] > wins[TEAM_CT])
  {
    add(motd_buffer, charsmax(motd_buffer), "Time A venceu o Time B");
  }
  else if (wins[TEAM_TERRORIST] < wins[TEAM_CT])
  {
    add(motd_buffer, charsmax(motd_buffer), "Time B venceu o Time A!");
  }
  else
  {
    add(motd_buffer, charsmax(motd_buffer), "Time A e B empataram!");
  }

  add(motd_buffer, charsmax(motd_buffer), "<br>");

  client_print(0, print_console, "^n-----------------");
  client_print(0, print_console, "FIM DA PARTIDA!");
  client_print(0, print_console, "-----------------^n");
  client_print(0, print_console, "[%s] %d x %d [%s]^n^nScores:", clans[a], wins[TEAM_TERRORIST], wins[TEAM_CT], clans[b]);

  for (new id = 1; id <= MaxClients; id++)
  {
    if (!is_user_connected(id))
    {
      continue;
    }

    new TeamName:team = get_member(id, m_iTeam);
    if (team == TEAM_TERRORIST || team == TEAM_CT)
    {
      kills[id]  = floatround(get_entvar(id, var_frags));
      deaths[id] = get_member(id, m_iDeaths);

      get_user_name(id, buffer, charsmax(buffer));
      format(buffer, charsmax(buffer), "[%s] %s: %d/%d", clans[(team == TEAM_CT) ? b : a], buffer, kills[id], deaths[id])

      client_print(0, print_console, buffer);

      add(motd_buffer, charsmax(motd_buffer), "<br>");
      add(motd_buffer, charsmax(motd_buffer), buffer);
    }
  }

  static timestr[64];
  format_time(timestr, charsmax(timestr), "^4%Y/%m/%d^1 - ^4%H:%M:%S^1");

  client_print(0, print_console, "^nA comissão da ep1c gaming Brasil agradece a participação!");
  client_print(0, print_console, "Fim do jogo: %s", timestr);
  client_print(0, print_console, "^n-----------------^n");
}
