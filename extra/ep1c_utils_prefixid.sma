#include <amxmodx>
#include <regex>

#pragma semicolon 1

#define PLUGIN  "ep1c_admin_manager"
#define VERSION "0.1"
#define AUTHOR  "lonewolf"

new Regex:regex = REGEX_PATTERN_FAIL;
new const pattern[] = "^^(\[[0-3]\d\])+";

public plugin_init()
{
  register_plugin(PLUGIN, VERSION, AUTHOR);

  new ret, error[128];
  regex = regex_compile(pattern, ret, error, charsmax(error));
  if (regex == REGEX_PATTERN_FAIL)
  {
    set_fail_state("[%s] Error regex, aborting (%d): %s", ret, error);
  }
}

public client_putinserver(id)
{
  check_name(id);
}

public client_infochanged(id)
{
  check_name(id, .check_oldname=1);
}

stock check_name(id, check_oldname=0)
{
  if (!is_user_connected(id))
  {
    return PLUGIN_CONTINUE;
  }

  static name[MAX_NAME_LENGTH], oldname[MAX_NAME_LENGTH];

  get_user_info(id, "name", name, charsmax(name));
  
  // client_print(0, print_chat, "name[%d][0]: %s", id, name);

  if (check_oldname)
  {
    get_user_name(id, oldname, charsmax(oldname));
    if (equal(name, oldname))
    {
      return PLUGIN_CONTINUE;
    }
  }

  while (regex_match_c(name, regex) > 0)
  {
    // new substr[64];

    // regex_substr(regex, 0, substr, charsmax(substr));
    // client_print(0, print_chat, "regex match: %s", substr);

    regex_replace(regex, name, charsmax(name), "");  
  }

  format(name, charsmax(name), "[%02d]%s", id, name);

  // client_print(0, print_chat, "name[%d][1]: %s", id, name);
  set_user_info(id, "name", name);

  return PLUGIN_CONTINUE;
}