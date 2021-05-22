#include <amxmodx>
#include <engine>
#include <xs>

#define PLUGIN  "ep1c-menu-n"
#define VERSION "0.1"
#define AUTHOR  "lonewolf"

#define PREFIX_CHAT "^4[ep1c gaming Brasil]^1"
#define PREFIX_MENU "\yep1c gaming Brasil"

public plugin_init()
{
  register_plugin(PLUGIN, VERSION, AUTHOR)
  
  register_clcmd("say /menu", "cmd_menu");
  register_clcmd("say .menu", "cmd_menu");
  register_clcmd("say_team /menu", "cmd_menu");
  register_clcmd("say_team .menu", "cmd_menu");

  register_clcmd("nightvision", "cmd_menu");
}


public cmd_menu(id)
{
  if (is_user_connected(id))
  {
    menu_n(id);
  }

  return PLUGIN_HANDLED;
}


public menu_n(id)
{
  new menu = menu_create(fmt("%s - Menu Principal", PREFIX_MENU), "menu_n_handler");

  menu_additem(menu, "Menu de Armas \d(say /armas)");
  menu_additem(menu, "Menu de Adrenalina \d(say /adrenaline)");
  menu_additem(menu, "Destruir Dispenser \d(say /destroy)");
  menu_additem(menu, "Dropar bandeira \d(say /dropflag)");
  menu_additem(menu, "Ver Top 15 \d(say /top15)");
  menu_addblank2(menu);
  menu_additem(menu, "\rMenu de admin \d(say /admin)", _, ADMIN_CFG);

  menu_display(id, menu);
}


public menu_n_handler(id, menu, item)
{
  if (!is_user_connected(id) || item == MENU_EXIT)
  {
    menu_destroy(menu);
    return PLUGIN_HANDLED;
  }

  switch (item)
  {
    case 0: client_cmd(id, "say /armas");
    case 1: client_cmd(id, "say /adrenaline");
    case 2: client_cmd(id, "say /destroy");
    case 3: client_cmd(id, "say /dropflag");
    case 4: client_cmd(id, "say /top15");
    case 5: client_cmd(id, "say /admin");
  }

  return PLUGIN_HANDLED;
}
