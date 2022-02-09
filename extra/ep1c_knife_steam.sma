#include <amxmodx>
#include <amxmisc>
#include <reapi>
#include <fakemeta>

#define PLUGIN   "ep1c_4fun_warmup_novembro_azul"
#define VERSION  "0.4"
#define AUTHOR   "lonewolf"

new v_knife_path[] = "models/ep1c/wpn/v_knife_NA2.mdl";
new w_knife_path[] = "models/ep1c/wpn/w_knife_NA.mdl";
new p_knife_path[] = "models/ep1c/wpn/p_knife_NA.mdl";

new authorizeds;

new steamids[][32] =
{
    // "STEAM_0:0:87656109",  // S H E R M A N
    // "STEAM_0:0:8354200",   // lonewolf
	"STEAM_0:0:32741092"      // xunk
};

public plugin_precache()
{
    precache_model(v_knife_path);
    precache_model(w_knife_path);
    precache_model(p_knife_path);
}


public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    register_event("CurWeapon","CurWeapon_Knife","be","1=1");
}

public client_authorized(id)
{
	static steamid[32];
	get_user_authid(id, steamid, 31);

	new len = sizeof(steamids);
	for (new i = 0; i < len; ++i)
	{
		if(equali(steamid, steamids[i]))
		{
			authorizeds |= (1 << (id-1));
			break;
		}
	}

	return PLUGIN_CONTINUE;
}

public client_disconnected(id)
{
	authorizeds &= ~(1 << (id-1));
}

public CurWeapon_Knife(id)
{
    if (!is_user_alive(id) || !(authorizeds & (1 << (id-1))))
    {
        return PLUGIN_CONTINUE;
    }
    
    new ret = PLUGIN_CONTINUE;

    static model[32]
    pev(id, pev_viewmodel2, model, charsmax(model))

    if (equali(model, "models/v_knife.mdl"))
    {
        set_pev(id,pev_viewmodel2, v_knife_path);
        ret = PLUGIN_HANDLED;
    }
    
    pev(id,pev_weaponmodel2, model, charsmax(model));
    if (equali(model, "models/p_knife.mdl"))
    {
        set_pev(id, pev_weaponmodel2, p_knife_path);
        ret = PLUGIN_HANDLED;
    }
    
    return ret;
}