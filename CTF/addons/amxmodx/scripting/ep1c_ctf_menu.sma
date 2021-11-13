#include <amxmodx>
#include <engine>
#include <xs>

#define PLUGIN  "ep1c_ctf_menu"
#define VERSION "0.2"
#define AUTHOR  "lonewolf"

#define PREFIX_CHAT "^4[ep1c gaming Brasil]^1"
#define PREFIX_MENU "\yep1c gaming Brasil"

new sv_alltalk;

public plugin_init()
{
  register_plugin(PLUGIN, VERSION, AUTHOR)
  
  register_clcmd("say /menu", "cmd_menu");
  register_clcmd("say .menu", "cmd_menu");
  register_clcmd("say_team /menu", "cmd_menu");
  register_clcmd("say_team .menu", "cmd_menu");

  register_clcmd("nightvision", "cmd_menu");

  register_clcmd("say /admin", "cmd_admin");
  register_clcmd("say .admin", "cmd_admin");
  register_clcmd("say_team /admin", "cmd_admin");
  register_clcmd("say_team .admin", "cmd_admin");
  
  register_clcmd("say /rankmenu", "cmd_rankmenu");
  register_clcmd("say .rankmenu", "cmd_rankmenu");
  register_clcmd("say_team /rankmenu", "cmd_rankmenu");
  register_clcmd("say_team .rankmenu", "cmd_rankmenu");

  bind_pcvar_num(get_cvar_pointer("sv_alltalk"), sv_alltalk);
}


public cb_disabled(id, menu, item)
{
  return ITEM_DISABLED;
}


public cmd_menu(id)
{
  if (is_user_connected(id))
  {
    menu_main(id);
  }

  return PLUGIN_HANDLED;
}


public menu_main(id)
{
  new menu = menu_create(fmt("%s - Menu Principal", PREFIX_MENU), "menu_main_handler");

  menu_additem(menu, "Menu de Armas \d(say /armas)");
  menu_additem(menu, "Dropar bandeira \d(say /dropflag)");
  menu_additem(menu, "Destruir Dispenser \d(say /destroy)");
  menu_additem(menu, "Menu de Adrenalina \d(say /adrenaline)");
  menu_additem(menu, "Mutar jogador \d(say /mute)");
  menu_additem(menu, "Seu rank \d(say /rankmenu)");
  menu_additem(menu, "\rMenu de admin \d(say /admin)", _, ADMIN_CFG);

  menu_display(id, menu);
}


public menu_main_handler(id, menu, item)
{
  if (!is_user_connected(id) || item == MENU_EXIT)
  {
    menu_destroy(menu);
    return PLUGIN_HANDLED;
  }

  switch (item)
  {
    case 0: client_cmd(id, "say /armas");
    case 1: client_cmd(id, "say /dropflag");
    case 2: client_cmd(id, "say /destroy");
    case 3: client_cmd(id, "say /adrenaline");
    case 4: client_cmd(id, "say /mute");
    case 5: client_cmd(id, "say /rankmenu");
    case 6: client_cmd(id, "say /admin");
  }

  menu_destroy(menu);
  return PLUGIN_HANDLED;
}


public cmd_rankmenu(id)
{
  if (is_user_connected(id))
  {
    menu_rank(id);
  }

  return PLUGIN_HANDLED;
}


public menu_rank(id)
{
  new menu = menu_create(fmt("%s - Menu Ranks", PREFIX_MENU), "menu_rank_handler");

  menu_additem(menu, "Seu rank \d(say /rank)");
  menu_additem(menu, "Top15 \d(say /top15)");
  menu_additem(menu, "Seus stats \d(say /statsme)");
  menu_additem(menu, "Seu rank e stats \d(say /rankstats)");
  menu_additem(menu, "Top15 do mapa atual \d(say /maptop)");
  menu_additem(menu, "Top15 Facadas \d(say /topf)");
  
  menu_display(id, menu);
}


public menu_rank_handler(id, menu, item)
{
  if (!is_user_connected(id) || (item == MENU_EXIT))
  {
    menu_destroy(menu);
    return PLUGIN_HANDLED;
  }

  switch (item)
  {
    case 0: client_cmd(id, "say /rank");
    case 1: client_cmd(id, "say /top15");
    case 2: client_cmd(id, "say /statsme");
    case 3: client_cmd(id, "say /rankstats");
    case 4: client_cmd(id, "say /maptop");
    case 5: client_cmd(id, "say /topf");
  }

  menu_destroy(menu);
  menu_rank(id);
  return PLUGIN_HANDLED;
}


public cmd_admin(id)
{
  if (is_user_connected(id))
  {
    menu_admin(id);
  }

  return PLUGIN_HANDLED;
}


public menu_admin(id)
{
  new menu = menu_create(fmt("%s - Menu Admin", PREFIX_MENU), "menu_admin_handler");

  menu_additem(menu, "Restart \d(amx_cvar sv_restart 3)");
  menu_additem(menu, "Mudar de mapa \d(amx_mapmenu)");
  menu_additem(menu, "Kickar um jogador \d(amx_kickmenu)");
  menu_additem(menu, "Banir um jogador \d(amx_banmenu)");
  menu_additem(menu, "Menu CVARs \d(amx_cvarmenu)")
  menu_additem(menu, "Trocar times de lado \d(amx_swapteams)");
  menu_additem(menu, "Embaralhar times \d(amx_shuffleteams)");
  menu_additem(menu, "Vencimento de admin \d(say /vencimento)");
  menu_additem(menu, "Menu CTF Match \d(say /ctf)");
  
  menu_display(id, menu);
}


public menu_admin_handler(id, menu, item)
{
  if (!is_user_connected(id) || item == MENU_EXIT)
  {
    menu_destroy(menu);
    return PLUGIN_HANDLED;
  }

  menu_destroy(menu);
  menu_admin(id);
  
  switch (item)
  {
    case 0: server_cmd("sv_restart 3");
    case 1: client_cmd(id, "amx_mapmenu");
    case 2: client_cmd(id, "amx_kickmenu");
    case 3: client_cmd(id, "amx_banmenu");
    case 4: client_cmd(id, "amx_cvarmenu");
    case 5: client_cmd(id, "amx_swapteams");
    case 6: client_cmd(id, "amx_shuffleteams");
    case 7: client_cmd(id, "say /vencimento");
    case 8: client_cmd(id, "say /ctf");
  }

  return PLUGIN_HANDLED;
}
