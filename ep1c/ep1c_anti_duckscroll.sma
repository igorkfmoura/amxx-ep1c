#include <amxmodx>
#include <reapi>

#define PLUGIN  "ep1c_anti_duckscroll" 
#define VERSION "0.1"
#define AUTHOR  "lonewolf"
#define URL     "https://github.com/igorkelvin/amxx-plugins"

#define PM_VEC_VIEW 17.0

new Float:delay;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR, URL);

    bind_pcvar_float(create_cvar("amx_dd_delay", "10"), delay);

    RegisterHookChain(RG_PM_Move, "event_pm_move");
}

public event_pm_move(id)
{
    if (!is_user_connected(id) || !is_user_alive(id))
    {
        return HC_CONTINUE;
    }

    // new Float:gametime = get_gametime();

    new button     = get_entvar(id, var_button);
    new oldbuttons = get_entvar(id, var_oldbuttons);

    new just_released = (oldbuttons ^ button) & oldbuttons;

    if ((~just_released & IN_DUCK) || (get_pmove(pm_onground) == -1))
    {
        // if (button & IN_DUCK)
        // {
        //     new Float:duck_time = get_pmove(pm_flDuckTime);
        //     client_print_color(id, print_team_red, "^3[%.2f]^1 duck_time: %s%.3f^1~", gametime, (duck_time >= (1000 - delay)) ? "^3" : "^4", duck_time);
        // }
        return HC_CONTINUE;
    }

    // new bool:duck_pressed = 0 != (get_entvar(id, var_button) & IN_DUCK);
    new bool:in_duck      = 0 != (get_entvar(id, var_bInDuck));
    new bool:is_ducking   = 0 != (get_entvar(id, var_flags) & FL_DUCKING);

    // client_print_color(id, id, "^4[PM_Duck]^1 duck_pressed: ^4%d^1, in_duck: ^4%d^1, is_ducking: ^4%d^1", duck_pressed, in_duck, is_ducking);

    if (in_duck && !is_ducking)
    {
        new Float:duck_time = get_pmove(pm_flDuckTime);
        // client_print_color(id, print_team_red, "^4[%.2f]^1 duck_time: %s%.3f^1", gametime, (duck_time >= (1000 - delay)) ? "^3" : "^4", duck_time);

        if (duck_time >= (1000 - delay))
        {

            set_pmove(pm_usehull, 0);
            set_pmove(pm_flDuckTime, 0);
            set_pmove(pm_bInDuck, false);

            new Float:tmp[3];
            get_pmove(pm_view_ofs, tmp);

            tmp[2] = PM_VEC_VIEW;
            set_pmove(pm_view_ofs, tmp);

            get_pmove(pm_velocity, tmp);
            tmp[0] *= 0.5;
            tmp[1] *= 0.5;

            set_pmove(pm_velocity, tmp);
        }
    }


    return HC_CONTINUE;
}