#include <amxmodx>
#include <fakemeta>

#define PLUGIN     "ep1c: Mute Menu"
#define VERSION "1.0"
#define AUTHOR     "Destro"

new g_mute[33][33], g_voiceoff[33][2]

new g_item[64]

new g_callback
new cvar_alltalk, cvar_voiceenable
new g_maxplayers

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

    register_clcmd("say /mute", "show_menu_mute")

    register_forward(FM_Voice_SetClientListening, "fwd_voice_setclientlistening")
    
    g_callback = menu_makecallback( "callback_menu")
    
    cvar_alltalk = get_cvar_pointer("sv_alltalk")
    cvar_voiceenable = get_cvar_pointer("sv_voiceenable")
    g_maxplayers = get_maxplayers()
}

public client_putinserver(id)
{
    for(new i = 1; i <= g_maxplayers; i++)
    {
        g_mute[id][i] = 0
        g_mute[i][id] = 0
    }
}


public fwd_voice_setclientlistening(receiver, sender, listen) 
{
    if(receiver == sender)
        return FMRES_IGNORED
        
    if((g_voiceoff[receiver][0] || g_voiceoff[sender][0]) ||
    !player_audible(receiver, sender) || g_mute[receiver][sender])
    {
        engfunc(EngFunc_SetClientListening, receiver, sender, 0)
        return FMRES_SUPERCEDE
    }

    return FMRES_IGNORED
}

public show_menu_mute(id)
{
    if(!get_pcvar_num(cvar_voiceenable))
    {
        chat_color(id, "Uso do microfone: Desativado.")
        return
    }

    new menu = menu_create("Ignorar um player:", "menu_mute")
    
    menu_additem(menu, "Mutar/Desmutar um player.", "1", 0, g_callback)
    
    formatex(g_item, charsmax(g_item), "Microfone: %s.", g_voiceoff[id][0]?"(Desativado)":"(Ativados")
    menu_additem(menu, g_item, "2", 0, g_callback)
    
    menu_additem(menu, "Visualizar quem mutou voc�.", "3", 0, g_callback)
    
    formatex(g_item, charsmax(g_item), "Alltalk: %s.^n", (g_voiceoff[id][1] || !get_pcvar_num(cvar_alltalk))?"(Desativado)":"(Ativado)")
    menu_additem(menu, g_item, "4", 0, g_callback)
    
    menu_setprop(menu, MPROP_EXITNAME, "Sair")
    menu_display(id, menu, 0) 
}

public callback_menu(id, menu, item)
{
    new data[3], null[2]
    menu_item_getinfo(menu, item, null[0], data, 2, null, 1, null[0])
    switch(str_to_num(data))
    {
        case 1: if(g_voiceoff[id][0]) return ITEM_DISABLED
        case 3: if(g_voiceoff[id][0]) return ITEM_DISABLED
        case 4: if(g_voiceoff[id][0] || !get_pcvar_num(cvar_alltalk)) return ITEM_DISABLED
    }
    return ITEM_ENABLED
}

public menu_mute(id, menu, item)
{
    if(item == MENU_EXIT || !get_pcvar_num(cvar_voiceenable))
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }
    new data[3], null[2]
    menu_item_getinfo(menu, item, null[0], data, 2, null, 1, null[0])
    
    switch(str_to_num(data))
    {
        case 1: show_menu_muteaplayer(id)
        case 2: {
            g_voiceoff[id][0] = !(g_voiceoff[id][0])
            show_menu_mute(id)
        }
        case 3: show_menu_mutelist(id)
        case 4: {
            g_voiceoff[id][1] = !(g_voiceoff[id][1])
            show_menu_mute(id)
        }
    }

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public show_menu_muteaplayer(id)
{
    new name[32], data[11]
    new menu = menu_create("Ignorar um player:", "menu_muteaplayer")

    for(new i = 1; i <= g_maxplayers; i++)
    {
        if(!is_user_connected(i) || id == i) continue
        
        if((!get_pcvar_num(cvar_alltalk) || g_voiceoff[id][1]) && get_user_team(id) != 3) continue
            
        get_user_name(i, name, 31)
        
        formatex(data, 10, "%d %d", i, get_user_userid(i))
        
        if(g_mute[id][i])
        {
            formatex(g_item, charsmax(g_item), "%s: (Ignorado)", name)
            menu_additem(menu, g_item, data)
        }
        else menu_additem(menu, name, data)
    }
    menu_setprop(menu, MPROP_EXITNAME, "Sair")
    menu_display(id, menu, 0)
}


public menu_muteaplayer(id, menu, item)
{
    if(item == MENU_EXIT || !get_pcvar_num(cvar_voiceenable))
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }
    new data[11], null[2]
    menu_item_getinfo(menu, item, null[0], data, 10, null, 1, null[0])
    
    new player
    if(!check_player_menu(data, player))
    {
        show_menu_muteaplayer(id)
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }
    
    g_mute[id][player] = !(g_mute[id][player])
    
    static name[32]
    get_user_name(player, name, 31)
    
    if(g_mute[id][player])
    {
        formatex(g_item, charsmax(g_item), "%s: (Ignorado)", name)
        menu_item_setname(menu, item, g_item)
    }
    else menu_item_setname(menu, item, name)

    player_menu_info(id, null[0], null[0], null[1])
    menu_display(id, menu, null[1])
    return PLUGIN_HANDLED
}
//---------------------------------
public show_menu_mutelist(id)
{
    new name[32]
    new menu = menu_create("Te ignora:", "menu_mutelist")

    for(new i = 1; i <= g_maxplayers; i++)
    {
        if(!is_user_connected(i) || id == i || !g_mute[i][id]) continue
        
        if((!get_pcvar_num(cvar_alltalk) || g_voiceoff[i][1]) && get_user_team(id) != 3
        && get_user_team(id) != get_user_team(i)) continue
            
        get_user_name(i, name, 31)
        menu_additem(menu, name, "0")
    }
    menu_setprop(menu, MPROP_EXITNAME, "Sair")
    menu_display(id, menu, 0)
}

public menu_mutelist(id, menu, item)
{
    menu_destroy(menu)
    return PLUGIN_HANDLED
}
//----------------------------------
stock check_player_menu(data[], &return_player)
{
    static strid[6], struserid[8]
    parse(data, strid, 5, struserid, 7)
    
    return_player = str_to_num(strid)
    if(is_user_connected(return_player) && get_user_userid(return_player) == str_to_num(struserid))
        return 1
        
    return 0
}

stock player_audible(receiver, sender)
{
    if(!get_pcvar_num(cvar_alltalk))
        return 1
        
    if(!g_voiceoff[receiver][1])
        return 1
    
    if(is_user_alive(receiver))
    {
        if(!is_user_alive(sender))
            return 0
        if(get_user_team(receiver) == get_user_team(sender))
            return 1
        return 0
    }
    return 1
}

stock chat_color(const id, const input[], any:...)
{
    new count = 1, players[32], i
    static msg[191]

    if(numargs() == 2) copy(msg, 190, input)
    else vformat(msg, 190, input, 3)
    
    replace_all(msg, 190, "!g", "^4")
    replace_all(msg, 190, "!y", "^1")
    replace_all(msg, 190, "!t", "^3")
    
    if(id) players[0] = id; else get_players(players, count, "ch")

    static SayText;if(!SayText) SayText = get_user_msgid("SayText")
    for(i = 0; i < count; i++) {
        if(is_user_connected(players[i])) {
            message_begin(MSG_ONE_UNRELIABLE, SayText, _, players[i])
            write_byte(players[i])
            write_string(msg)
            message_end()
        }
    }
} 
