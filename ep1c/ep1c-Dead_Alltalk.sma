#include <amxmodx>
#include <fakemeta>

new sv_alldeadtalk;

public plugin_init()
{
    register_plugin("ep1c: Dead Alltalk", "0.1", "Exolent");
    
    register_forward(FM_Voice_SetClientListening, "fwdSetVoice", 0);
    
    sv_alldeadtalk = register_cvar("sv_alldeadtalk", "1", 0, 0.0);
    
    return PLUGIN_CONTINUE;
}

public fwdSetVoice(receiver, sender, bool:bListen)
{
    if( !get_pcvar_num(sv_alldeadtalk)
    || receiver == sender
    || !is_user_connected(receiver) || !is_user_connected(sender) )
    {
        return FMRES_IGNORED;
    }
    
    if( !is_user_alive(receiver) && !is_user_alive(sender)
    && get_user_team(receiver) != get_user_team(sender) )
    {
        engfunc(EngFunc_SetClientListening, receiver, sender, 1);
        
        return FMRES_SUPERCEDE;
    }
    
    return FMRES_IGNORED;
} 
