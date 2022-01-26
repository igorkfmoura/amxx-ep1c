#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new const TASK_ID = 7247;

new const MOTD_FLAG_ARG = 1;
new const MOTD_FLAG_END = 1;


new const MOTD_MODEL[] = "models/ep1c/motd_ep1c_teste.mdl";

enum IntroState
{
    INTRO_INIT,
    INTRO_PLAYING,
    INTRO_END,

}; 
new IntroState:g_iIntroState[MAX_PLAYERS + 1];

new bool:g_bSawMotd[33];

new motdmdl_skippable_intro;
new motdmdl_skip_motd;

public plugin_precache()
{
    register_plugin("MOTD Model + Skip", "1.1.0", "fl0wer/lonewolf"); // with Exolent code - https://forums.alliedmods.net/showthread.php?t=68673?t=68673

    precache_model(MOTD_MODEL);
}

public plugin_init()
{
    register_message(get_user_msgid("MOTD"), "message_MOTD");

    RegisterHookChain(RG_ShowVGUIMenu, "@ShowVGUIMenu_Pre", false);
    RegisterHookChain(RG_HandleMenu_ChooseTeam, "@HandleMenu_ChooseTeam_Pre", false);

    bind_pcvar_num(create_cvar("motdmdl_skippable_intro", "1", _, "Players can skip intro by menu keys^n0 - disabled^n1 - enabled", true, 0.0, true, 1.0), motdmdl_skippable_intro);
    bind_pcvar_num(create_cvar("motdmdl_skip_motd", "1", _, "Skip first motd^n0 - disabled^n1 - enabled", true, 0.0, true, 1.0), motdmdl_skip_motd);
}

public client_putinserver(id)
{
    g_iIntroState[id] = is_user_bot(id) ? INTRO_END : INTRO_INIT;
    g_bSawMotd[id] = false;
}


public client_disconnected(id)
{
    if (task_exists(TASK_ID + id))
    {
        remove_task(TASK_ID + id);
    }
}


public message_MOTD(msgid, dest, id)
{
    if(!g_bSawMotd[id])
    {
        if(get_msg_arg_int(MOTD_FLAG_ARG) == MOTD_FLAG_END)
        {
            g_bSawMotd[id] = true;
        }
        return PLUGIN_HANDLED;
    }
    return PLUGIN_CONTINUE;
}


@ShowVGUIMenu_Pre(id, VGUIMenu:menuType, bitsSlots, oldMenu[])
{
    if (menuType != VGUI_Menu_Team)
        return;

    if (g_iIntroState[id] == INTRO_END)
        return;

    if (get_member(id, m_iJoiningState) == JOINED)
        return;

    if (g_iIntroState[id] == INTRO_INIT)
    {
        g_iIntroState[id] = INTRO_PLAYING;

        set_entvar(id, var_viewmodel, MOTD_MODEL);
        set_task(3.65, "@Task_IntroEnd", TASK_ID + id);
    }

    set_member(id, m_bForceShowMenu, true);

    SetHookChainArg(3, ATYPE_INTEGER, 1023);
    SetHookChainArg(4, ATYPE_STRING, "\n");
}

@HandleMenu_ChooseTeam_Pre(id, key)
{
    if (g_iIntroState[id] == INTRO_END)
        return HC_CONTINUE;

    if (g_iIntroState[id] == INTRO_PLAYING && motdmdl_skippable_intro)
        StopIntro(id);

    SetHookChainReturn(ATYPE_INTEGER, false);
    return HC_SUPERCEDE;
}

@Task_IntroEnd(task)
{
    new id = task - TASK_ID;

    if (!is_user_connected(id))
        return;

    StopIntro(id);
    // engclient_cmd(id, "jointeam");
}

StopIntro(id)
{
    remove_task(id);

    g_iIntroState[id] = INTRO_END;

    set_entvar(id, var_viewmodel, "");
    engclient_cmd(id, "menuselect", "0");
}
