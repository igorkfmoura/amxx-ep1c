#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>

new const PLUGIN[]  = "KillReward"
new const VERSION[] = "0.2"
new const AUTHOR[]  = "lonewolf"

#define PREFIX "^4[ep1c gaming Brasil]^1"

enum Cvars
{
    ENABLED,
    KILL,
    HS,
    KNIFE,
    MAXHEALTH
};
new cvars[Cvars];

new messages[Cvars][48] =
{
    "",
    "pela eliminação!",
    "pela eliminação com ^4Headshot^1!",
    "por matar na faquinha!",
    ""
}
public plugin_init() 
{
   register_plugin(PLUGIN, VERSION, AUTHOR);
   register_event("DeathMsg" , "event_DeathMsg" , "a" ,  "1>0" , "2>0"); 

   cvars[ENABLED] = register_cvar("amx_kill_reward","1");
   cvars[KILL]    = register_cvar("amx_kill_reward_kill", "10"); 
   cvars[HS]      = register_cvar("amx_kill_reward_hs",   "20");
   cvars[KNIFE]   = register_cvar("amx_kill_reward_knife","50");

   cvars[MAXHEALTH] = register_cvar("amx_kill_reward_maxhealth","100");

}

public event_DeathMsg() 
{
    if(!get_pcvar_num(cvars[ENABLED]))
    {
       return PLUGIN_CONTINUE;
    }

    new killer = read_data(1);
    new victim = read_data(2);

    if (!is_user_connected(killer) || victim == killer)
    {
        return PLUGIN_CONTINUE;
    }

    new clip, ammo, weapon = get_user_weapon(killer, clip, ammo)

    new maxhealth = get_pcvar_num(cvars[MAXHEALTH]);
    new hp = get_user_health(killer);

    if (hp >= maxhealth)
    {
        return PLUGIN_CONTINUE;
    }

    new bool:is_headshot = bool:read_data(3);

    new Cvars:type;
    if (weapon == CSW_KNIFE)
    {
        type = KNIFE;
    }
    else if (is_headshot)
    {
        type = HS;
    }
    else
    {
        type = KILL;
    }

    
    new reward = get_pcvar_num(cvars[type]);
    
    set_user_health(killer , min(hp + reward, maxhealth));
    client_print_color(killer, print_team_red, "%s ^3+%d HP^1 %s", PREFIX, reward, messages[type]);

    return PLUGIN_CONTINUE;
}