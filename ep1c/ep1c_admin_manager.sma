#pragma semicolon 1

#include <amxmodx>
// #include <reapi>
#include <regex>

#define PLUGIN  "ep1c_admin_manager"
#define VERSION "0.1"
#define AUTHOR  "lonewolf"

#define TASK_RELOAD 9082
#define TASK_CHECK  6172

new user_default_flags[MAX_PLAYERS + 1];

//https://forums.alliedmods.net/showthread.php?t=187308
// new const pattern[] = "^^(ep1c ' )|";
new const pattern[] = "^^ep1c ' |^^In'Face \| ";
new Regex:regex = REGEX_PATTERN_FAIL;

new pcvar_amx_manager_flags;
new amx_manager_flags[33];
new admin_flags;


public amx_manager_flags_change()
{
  admin_flags = read_flags(amx_manager_flags);
}

public plugin_init()
{
  register_plugin(PLUGIN, VERSION, AUTHOR);

  pcvar_amx_manager_flags = create_cvar("amx_manager_flags", "abcdefghijklmnopqrstuvwy", FCVAR_PROTECTED | FCVAR_SPONLY | FCVAR_NOEXTRAWHITEPACE);
  bind_pcvar_string(pcvar_amx_manager_flags, amx_manager_flags, charsmax(amx_manager_flags));
  hook_cvar_change(pcvar_amx_manager_flags, "amx_manager_flags_change");

  // RegisterHookChain(RH_SV_WriteFullClientUpdate, "SV_WriteFullClientUpdate", false);

  register_concmd("debug_manager", "cmd_debug_manager", ADMIN_CVAR);
  register_concmd("debug_manager_toggle", "cmd_debug_manager_toggle", ADMIN_CVAR);

  register_concmd("amx_reloadadmins2", "cmd_reloadadmins", ADMIN_CVAR);

  new ret, error[128];
  regex = regex_compile(pattern, ret, error, charsmax(error));
  if (regex == REGEX_PATTERN_FAIL)
  {
    set_fail_state("[%s] Error regex, aborting (%d): %s", ret, error);
  }

  amx_manager_flags_change();
}


public plugin_end()
{
  regex_free(regex);
}


public client_authorized(id)
{
  user_default_flags[id] = get_user_flags(id);
  // set_task(5.0, "task_check_admin", TASK_CHECK + id);
  // check_admin(id);
}

public client_putinserver(id)
{
  check_admin(id);
}


public client_disconnected(id)
{
  user_default_flags[id] = ADMIN_ALL;
}


public cmd_debug_manager(id)
{
  if (!(get_user_flags(id) & ADMIN_CVAR))
  {
    return PLUGIN_HANDLED;
  }

  for (new i = 1; i <= MaxClients; ++i)
  {
    if (!is_user_connected(i))
    {
      continue;
    }

    new f = get_user_flags(i);

    static name[MAX_NAME_LENGTH];
    get_user_name(i, name, charsmax(name));

    static flags[33];
    get_flags(f, flags, charsmax(flags));

    new changed[48] = "";
    f ^= user_default_flags[i];

    if (f)
    {
      get_flags(f, changed, charsmax(changed));
      format(changed, charsmax(changed), " (changed: %s)", changed);
    }

    console_print(id, "[%s] (%d) %s: %s%s", PLUGIN, i, name, flags, changed);
  }

  return PLUGIN_HANDLED;
}


public cmd_debug_manager_toggle(id)
{
  if (!(get_user_flags(id) & ADMIN_CVAR))
  {
    return PLUGIN_HANDLED;
  }

  new argc = read_argc();
  if (argc != 3)
  {
    console_print(id, "[%s] argc != 3");
    return PLUGIN_HANDLED;
  }

  static argv[32];
  read_argv(1, argv, charsmax(argv));

  new target = str_to_num(argv);

  if (!is_user_connected(target))
  {
    console_print(id, "[%s] player id '%s' not connected", target);
    return PLUGIN_HANDLED;
  }

  read_argv(2, argv, charsmax(argv));
  if (is_str_num(argv))
  {
    new f = str_to_num(argv);
    
    new fold = get_user_flags(target);
    new fnew = fold ^ f;
    
    set_user_flags(target, f & fnew);
    remove_user_flags(target, f & fold);
  }
  else
  {
    new f = read_flags(argv);
    if (f)
    {
      new fold = get_user_flags(target);
      new fnew = fold ^ f;
      
      set_user_flags(target, f & fnew);
      remove_user_flags(target, f & fold);

    }
  }

  return PLUGIN_HANDLED;
}


public client_infochanged(id)
{
  if (!is_user_connected(id))
  {
    return PLUGIN_CONTINUE;
  }

  static name[MAX_NAME_LENGTH], oldname[MAX_NAME_LENGTH];

  get_user_name(id, oldname, charsmax(oldname));
  get_user_info(id, "name", name, charsmax(name));
  
  // client_print_color(id, id, "[client_infochanged] id: %d, name: %s, oldname: %s", id, name, oldname);

  if (!equal(name, oldname))
  {
    // set_task(1.0, "task_check_admin", TASK_CHECK + id);
    check_admin(id, name);
    return PLUGIN_CONTINUE;
  }

  return PLUGIN_CONTINUE;
}


public task_check_admin(id)
{
  id -= TASK_CHECK;
  check_admin(id);
}


stock check_admin(id, _name[] = "")
{
  static name[MAX_NAME_LENGTH];

  if (!is_user_connected(id))
  {
    return PLUGIN_CONTINUE;
  }

  if (_name[0])
  {
		copy(name, charsmax(name), _name);
  }
  else
  {
    get_user_name(id, name, charsmax(name));
  }

  // client_print_color(0, print_team_red, "[check_admin #1] id: %d, name: %s", id, name);

  if (regex_match_c(name, regex) > 0)
  {
    set_user_flags(id, user_default_flags[id]);
  }
  else
  {
    remove_user_flags(id, admin_flags);
    set_user_flags(id, ADMIN_USER);
    
    if (user_default_flags[id] != get_user_flags(id))
    {
      console_print(id, "[ep1c gaming Brasil] '%s', privilégios de ADMIN e VIP apenas com tag!!", name);
      client_print_color(id, print_team_red, "^3[ep1c gaming Brasil]^1 '%s', privilégios de ADMIN e VIP apenas com tag!!", name);
    }
  }

  return PLUGIN_CONTINUE;
}

public cmd_reloadadmins(id)
{
  if (!(get_user_flags(id) & ADMIN_CVAR))
  {
    return PLUGIN_HANDLED;
  }
  server_cmd("amx_reloadadmins");
  server_cmd("px_reload");
  server_exec();

  for (new i = 1; i <= MaxClients; ++i)
  {
    user_default_flags[i] = is_user_connected(i) ? get_user_flags(i) : ADMIN_ALL; // todo check get_user_flags for no-connecte
    check_admin(i);
  }

  console_print(id, "[%s] Admins reloaded", PLUGIN);
  
  return PLUGIN_HANDLED;
}