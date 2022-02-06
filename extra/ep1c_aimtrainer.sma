#include <amxmodx>
#include <hamsandwich>
#include <reapi>

#define PLUGIN  "ep1c_aimtrainer"
#define VERSION "0.1"
#define AUTHOR  "lonewolf"
#define URL     "github.com/igorkelvin"

new Float:nextattack;
new enabled[MAX_PLAYERS];
new enabled2[MAX_PLAYERS];

public plugin_init()
{
  register_plugin(PLUGIN, VERSION, AUTHOR, URL);

  bind_pcvar_float(create_cvar("aim_nextattack", "0.095"), nextattack);

  RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "AK47_PrimaryAttack_Pre");
  RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "AK47_PrimaryAttack_Post", .Post=1);
  RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1", "AK47_PrimaryAttack_Pre");
  RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1", "AK47_PrimaryAttack_Post", .Post=1);

  register_clcmd("say /spray", "cmd_spray");
  register_clcmd("say /spray2", "cmd_spray2");
}

public cmd_spray(id)
{
  enabled[id] = !enabled[id];
  client_print_color(id, print_team_red, "^4[%s]^1 spray control: %s.", PLUGIN, enabled[id] ? "^3ON^1" : "^4OFF^1");

  return PLUGIN_HANDLED;
}

public cmd_spray2(id)
{
  enabled2[id] = !enabled2[id];
  client_print_color(id, print_team_red, "^4[%s]^1 spray control2: %s.", PLUGIN, enabled2[id] ? "^3ON^1" : "^4OFF^1");

  return PLUGIN_HANDLED;
}

public client_disconnected(id)
{
  enabled[id] = 0;
}

new Float:flAccuracy;
public AK47_PrimaryAttack_Pre(weapon)
{
  new owner = get_entvar(weapon, var_owner);
  if (!enabled[owner] || !is_user_connected(owner))
  {
    flAccuracy = get_member(weapon, m_Weapon_flAccuracy);
    return;
  }

  new iShotsFired = get_member(weapon, m_Weapon_iShotsFired);
  new Float:flDecreaseShotsFired =  get_member(weapon, m_Weapon_flDecreaseShotsFired); 
  new Float:gametime = get_gametime();

  if (iShotsFired > 0 && flDecreaseShotsFired < gametime)
  {
    flDecreaseShotsFired = gametime + 0.0225;
    set_member(weapon, m_Weapon_flDecreaseShotsFired, flDecreaseShotsFired);

    iShotsFired = 0;
    set_member(weapon, m_Weapon_iShotsFired, iShotsFired);
  }

  flAccuracy = get_member(weapon, m_Weapon_flAccuracy);
}

public AK47_PrimaryAttack_Post(weapon)
{
  new owner = get_entvar(weapon, var_owner);

  if (!enabled[owner] || !is_user_connected(owner))
  {
    return;
  }

  new Float:nextflAccuracy = get_member(weapon, m_Weapon_flAccuracy);
  new iShotsFired = get_member(weapon, m_Weapon_iShotsFired);
  new Float:_nextattack = nextattack;

  // if (!enabled[owner] && is_user_connected(owner))
  // {
  //   _nextattack = get_member(weapon, m_Weapon_flNextPrimaryAttack);
  //   client_print_color(owner, owner, "^4[%s]^1 (%02d), accuracy: ^4%.2f^1, next shot in ^4%.3fs^1 & with accuracy: ^4%.2f^1.", PLUGIN, iShotsFired, flAccuracy, _nextattack, nextflAccuracy);
  //   return;
  // }

  if (iShotsFired >= 5)
  {
    _nextattack = 0.4 + iShotsFired * 0.0225;
    set_member(weapon, m_Weapon_flNextPrimaryAttack, _nextattack);
  }

  if (enabled2[owner])
  {
    set_member(weapon, m_Weapon_flNextPrimaryAttack, _nextattack);
  }

  if (is_user_connected(owner))
  {
    _nextattack = get_member(weapon, m_Weapon_flNextPrimaryAttack);
    client_print_color(owner, owner, "^4[%s]^1 (%02d), accuracy: ^4%.2f^1, next shot in ^4%.3fs^1 & with accuracy: ^4%.2f^1.", PLUGIN, iShotsFired, flAccuracy, _nextattack, nextflAccuracy);
  }

  new bDelayFire = get_member(weapon, m_Weapon_bDelayFire);
  new Float:flDecreaseShotsFired =  get_member(weapon, m_Weapon_flDecreaseShotsFired); 
  new Float:gametime = get_gametime();
  if (bDelayFire)
  {
    set_member(weapon, m_Weapon_bDelayFire, false);

    if (iShotsFired > 15)
    {
      iShotsFired = 15;
      set_member(weapon, m_Weapon_iShotsFired, iShotsFired);
    }

    flDecreaseShotsFired = gametime + 0.4;
    set_member(weapon, m_Weapon_flDecreaseShotsFired, flDecreaseShotsFired);
  }
}