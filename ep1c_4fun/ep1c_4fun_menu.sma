#include <amxmodx>
#include <engine>
#include <xs>

#define PLUGIN  "ep1c_4fun_menu"
#define VERSION "0.1"
#define AUTHOR  "lonewolf"

#define PREFIX_CHAT "^4[ep1c gaming Brasil]^1"
#define PREFIX_MENU "\yep1c gaming Brasil"

new menu_cb_disabled;

new sv_alltalk;

public plugin_init()
{
  register_plugin(PLUGIN, VERSION, AUTHOR)
  
  register_clcmd("say /menu", "cmd_menu");
  register_clcmd("say .menu", "cmd_menu");
  register_clcmd("say_team /menu", "cmd_menu");
  register_clcmd("say_team .menu", "cmd_menu");

  register_clcmd("nightvision", "cmd_menu");

  register_clcmd("say /admin", "cmd_admin", ADMIN_KICK);
  register_clcmd("say .admin", "cmd_admin", ADMIN_KICK);
  register_clcmd("say_team /admin", "cmd_admin", ADMIN_KICK);
  register_clcmd("say_team .admin", "cmd_admin", ADMIN_KICK);
  
  register_clcmd("say /rankmenu", "cmd_rankmenu");
  register_clcmd("say .rankmenu", "cmd_rankmenu");
  register_clcmd("say_team /rankmenu", "cmd_rankmenu");
  register_clcmd("say_team .rankmenu", "cmd_rankmenu");

  menu_cb_disabled = menu_makecallback("cb_disabled");

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
  menu_additem(menu, "Mutar jogador \d(say /mute)");
  menu_additem(menu, "Seu rank \d(say /rankmenu)");
  menu_addblank2(menu);
  menu_additem(menu, "Menu ep1c \d(say /ep1c)", _, _, .callback=menu_cb_disabled);
  menu_additem(menu, "\rMenu de admin \d(say /admin)", _, ADMIN_KICK);

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
    case 1: client_cmd(id, "say /mute");
    case 2: client_cmd(id, "say /rankmenu");
    //case 3: 
    case 4: client_cmd(id, "say /ep1c");
    case 5: client_cmd(id, "say /admin");
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
  if (is_user_connected(id) && (get_user_flags(id) & ADMIN_KICK))
  {
    menu_admin(id);
  }

  return PLUGIN_HANDLED;
}


public menu_admin(id)
{
  new menu = menu_create(fmt("%s - Menu Admin", PREFIX_MENU), "menu_admin_handler");

  menu_additem(menu, "Restart \d(sv_restart 1)");
  menu_additem(menu, "Mudar de mapa \d(amx_mapmenu)");
  menu_additem(menu, "Kickar um jogador \d(amx_kickmenu)");
  menu_additem(menu, "Banir um jogador \d(amx_banmenu)");
  menu_additem(menu, sv_alltalk == 0 ? "\yLigar alltalk \d(sv_alltalk 1)" : "\rDesligar alltalk \d(sv_alltalk 0)")
  menu_additem(menu, "Trocar times de lado \d(amx_swapteams)");
  menu_additem(menu, "Embaralhar times \d(amx_shuffleteams)");
  menu_additem(menu, "Mudar time de um jogador \d(amx_teammenu)");
  menu_additem(menu, "Dar tapa ou matar um jogador \d(amx_slapmenu)");
  menu_additem(menu, "Iniciar votação de mapa \d(mapm_start_vote)");
  menu_additem(menu, "Vencimento de admin \d(say /vencimento)");
  
  menu_display(id, menu);
}


public menu_admin_handler(id, menu, item)
{
  if (!is_user_connected(id) || item == MENU_EXIT)
  {
    menu_destroy(menu);
    return PLUGIN_HANDLED;
  }

  new bool:redeploy = false;

  switch (item)
  {
    case 0:
    {
      redeploy = true;

      set_task(1.0, "restart_delayed");
      client_cmd(0, "spk ^"doop^"");
      client_cmd(id, "say @b Restarting...; say @y Restarting...; say @g Restarting...");
    }
    case 1: client_cmd(id, "amx_mapmenu");
    case 2: client_cmd(id, "amx_kickmenu");
    case 3: client_cmd(id, "amx_banmenu");
    case 4:
    {
      redeploy = true;
     
      new alltalk = !sv_alltalk;

      if (alltalk)
      {
        server_cmd("sv_alltalk 1");
        client_cmd(0, "spk ^"fvox/voice_on^"");
        client_cmd(id, "say @g AllTalk [ON]");
      }
      else
      {
        server_cmd("sv_alltalk 0");
        client_cmd(0, "spk ^"fvox/voice_off^"");
        client_cmd(id, "say @o AllTalk [OFF]");
      }
    }
    case 5:
    {
      redeploy = true;
      client_cmd(id, "amx_swapteams");
    }
    case 6: 
    {
      redeploy = true;
      client_cmd(id, "amx_shuffleteams");
    }
    case 7: client_cmd(id, "amx_teammenu");
    case 8: client_cmd(id, "amx_slapmenu");
    case 9:
    {
      redeploy = true;
      client_cmd(id, "mapm_start_vote");
    }
    case 10:
    {
      redeploy = true;
      client_cmd(id, "say /vencimento");
    }
  }

  menu_destroy(menu);

  if (redeploy)
  {
    set_task(0.1, "menu_admin_delayed", 1631 + id);
  }

  return PLUGIN_HANDLED;
}

public menu_admin_delayed(id)
{
  menu_admin(id - 1631);
}

public restart_delayed(id)
{
  server_cmd("sv_restart 1");
}