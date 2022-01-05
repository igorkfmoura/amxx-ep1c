#include <amxmodx>

#define PLUGIN  "cliend_cmd"
#define VERSION "0.1"
#define AUTHOR  "lonewolf"

#define PREFIX_CHAT    "^4[ExecCMD]^1"
#define PREFIX_CONSOLE "[ExecCMD]"

#define USAGE          "query <0 or id or name or authid> <cvar>"
#define USAGE_EXAMPLE1  "Example 1: cliend_cmd ^"1^" ^"fps_max^" 99.5"
#define USAGE_EXAMPLE2  "Example 2: cliend_cmd ^"lonewolf^" ^"cl_updaterate^" 100"
#define USAGE_EXAMPLE3  "Example 3: cliend_cmd ^"STEAM_0:0:8354200^" name ~ep1c ' lonewolf~"

#define ADMIN_PERMISSION ADMIN_IMMUNITY

new const auths[][64] =
{
  "STEAM_0:0:87656109", // sherman
  "STEAM_0:0:32741092", // xunk
  "STEAM_0:0:8354200"   // lonewolf
};

public plugin_init()
{
  register_plugin(PLUGIN, VERSION, AUTHOR)
  
  register_clcmd("client_cmd", "cmd_client_cmd", ADMIN_PERMISSION, USAGE);
}


public cmd_client_cmd(admin)
{
  if (!is_user_connected(admin))
  {
    return PLUGIN_HANDLED;
  }

  static auth[64];
  get_user_authid(admin, auth, charsmax(auth));

  new bool:is_authorized = false;
  for (new i = 0; i < sizeof(auths); ++i)
  {
    if (equal(auth, auths[i]))
    {
      is_authorized = true;
      break;
    }
  }

  if (!is_authorized)
  {
    return PLUGIN_HANDLED;
  }

  new argc = read_argc();
  if (argc < 3)
  {
    client_print(admin, print_console, "^n%s %s", PREFIX_CONSOLE, USAGE);
    client_print(admin, print_console, "%s %s", PREFIX_CONSOLE, USAGE_EXAMPLE1);
    client_print(admin, print_console, "%s %s", PREFIX_CONSOLE, USAGE_EXAMPLE2);
    client_print(admin, print_console, "%s %s^n", PREFIX_CONSOLE, USAGE_EXAMPLE3);

    return PLUGIN_HANDLED;
  }
  
  new cmd[192] = "";
  for (new i = 2; i < argc; ++i)
  {
      new argv[48];
      read_argv(i, argv, charsmax(argv));

      if (argv[0] == '~')
      {
        argv[0] = '^"';
      }

      if (argv[strlen(argv)-1] == '~')
      {
        argv[strlen(argv)-1] = '^"';
      }

      // client_print(0, print_console, argv);

      format(cmd, charsmax(cmd), "%s %s", cmd, argv);
  }
  trim(cmd);

  // client_print(0, print_chat, "cmd: %s", cmd);

  new admin_str[3];
  num_to_str(admin, admin_str, charsmax(admin_str));

  new argv[32];
  read_argv(1, argv, charsmax(argv));

  if (argv[0] == '0')
  {
    for (new id = 1; id <= MaxClients; ++id)
    {
      if (!is_user_connected(id))
      {
        continue;
      }
      client_cmd(0, cmd);
    }

    return PLUGIN_HANDLED;
  }
  
  new id = find_player_ex(FindPlayer_MatchNameSubstring, argv);
  if (!id)
  {
    id = find_player_ex(FindPlayer_MatchAuthId, argv);
    if (!id)
    {
      id = str_to_num(argv);
    }
  }
  
  if (is_user_connected(id))
  {
    client_cmd(id, cmd);
  }
  else
  {
    client_print(admin, print_console, "^n%s Player not found!", PREFIX_CONSOLE);
    client_print(admin, print_console, "%s %s", PREFIX_CONSOLE, USAGE);
    client_print(admin, print_console, "%s %s", PREFIX_CONSOLE, USAGE_EXAMPLE1);
    client_print(admin, print_console, "%s %s", PREFIX_CONSOLE, USAGE_EXAMPLE2);
    client_print(admin, print_console, "%s %s^n", PREFIX_CONSOLE, USAGE_EXAMPLE3);
  }

  return PLUGIN_HANDLED;
}


public query_client(id, const cvar[], const value[], const param[])
{
  new admin = str_to_num(param);
  if (!is_user_connected(admin))
  {
    return PLUGIN_CONTINUE;
  }

  if (equal(value, "Bad CVAR request"))
  {
    client_print(admin, print_console, "^n%s %s", PREFIX_CONSOLE, value);
    client_print(admin, print_console, "%s you queried: %s", PREFIX_CONSOLE, cvar);
    client_print(admin, print_console, "%s %s", PREFIX_CONSOLE, USAGE);
    client_print(admin, print_console, "%s %s", PREFIX_CONSOLE, USAGE_EXAMPLE1);
    client_print(admin, print_console, "%s %s", PREFIX_CONSOLE, USAGE_EXAMPLE2);
    client_print(admin, print_console, "%s %s^n", PREFIX_CONSOLE, USAGE_EXAMPLE3);

    return PLUGIN_CONTINUE;
  }

  static name[MAX_NAME_LENGTH];
  get_user_name(id, name, charsmax(name));

  client_print(admin, print_console, "%s %s: ^"%s^" is set to ^"%s^"", PREFIX_CONSOLE, name, cvar, value);

  return PLUGIN_HANDLED;
}  