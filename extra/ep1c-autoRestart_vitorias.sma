#include <amxmodx>
#include <reapi>

#define PLUGIN   "ep1c: AutoRestart"
#define VERSION  "0.3"
#define AUTHOR   "Developer + lonewolf + SHERMAN"

new const PREFIX = "^4[ep1c gaming Brasil]^1";

new team_scores[CsTeams];
new rounds;

enum ScreenFadeFlags
{
  ScreenFade_FadeIn,
  ScreenFade_FadeOut,
  ScreenFade_Modulate,
  ScreenFade_StayOut 
};

enum Cvars
{
    SWAP_TEAMS,
    SWAP_ROUNDS,
    MAX_WINS
}
new cvars[Cvars];

enum Sounds
{
    WIN
};
new sounds[Sounds][64] =
{
    "ep1c/ep1c_winmatch.wav"    
};

public plugin_precache()
{
    precache_sound(sounds[WIN]);
    // if(equal(szFile[strlen(szOutput)-4], ".mp3"))
    //     precache_generic(szOutput);   // Precache Sound (MP3)
  // else
    //     precache_sound(szFile);     // Precache Sound (WAVS)
}


public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    // Register: EVENT
    register_event("TeamScore", "event_update_score", "a");
    register_event("TextMsg",   "event_restarted",    "a", "2=#Game_will_restart_in");

    register_logevent("roundStart", 2, "1=Round_Start");
    register_logevent("roundEnd",   2, "1=Round_End");

    // Register CVAR's
    cvars[SWAP_TEAMS]  = create_cvar("amx_match_swapteams",  "1",   _, "<0-1> Enable auto team swapping.");
    cvars[SWAP_ROUNDS] = create_cvar("amx_match_swaprounds", "15",  _, "<number> Rounds before swapping.");
    cvars[MAX_WINS]    = create_cvar("amx_match_maxwins",    "16",  _, "<number> Rounds needed to victory.");
}


public event_restarted()
{
    team_scores[CS_TEAM_T]  = 0;
    team_scores[CS_TEAM_CT] = 0;
    rounds = 0;
}


public event_update_score()
{
    new team_name[4];
    read_data(1, team_name, charsmax(team_name));

    switch (team_name[0])
    {
        case 'T':
        {
            team_scores[CS_TEAM_T]  = read_data(2);
        }
        case 'C':
        {
            team_scores[CS_TEAM_CT] = read_data(2);
        }
    }   
}


public roundStart()
{
    new match_point = get_pcvar_num(cvars[MAX_WINS]) - 1;
    // new round_before_swap = get_pcvar_num(cvars[SWAP_ROUNDS]) - 1;
    new swap_rounds = get_pcvar_num (cvars[SWAP_ROUNDS])-1;
    if (rounds==swap_rounds)
    {
    set_dhudmessage(255, 255, 255, -1.0, 0.29, 2, 6.0, 6.0);
    show_dhudmessage(0, "PRÓXIMO ROUND AS EQUIPES TROCARÃO DE LADO");
    }
    if (team_scores[CS_TEAM_CT] == match_point)
    {
        client_print_color(0, print_team_blue, "%s Match-Point ^3CT^1.", PREFIX);
    }
    
    if (team_scores[CS_TEAM_T] == match_point)
    {
        client_print_color(0, print_team_red, "%s Match-Point ^3TR^1.", PREFIX);
    }
}

public task_swap_delayed(id)
{
    client_cmd(0, "spk ^"switch^"");

    rg_swap_all_players();
}

// public task_restart_delayed(id)
// {
//     rg_restart_round();
// }

public roundEnd()
{
    new max_wins = get_pcvar_num(cvars[MAX_WINS]);
    new swap_rounds = get_pcvar_num (cvars[SWAP_ROUNDS]);
    rounds += 1;
    if (rounds == swap_rounds)
    {
        set_dhudmessage(255, 255, 255, -1.0, 0.29, 2, 6.0, 6.0);
        show_dhudmessage(0, "TROCANDO LADOS!");

        client_cmd(0, "spk ^"team^"");
        set_task(0.5, "task_swap_delayed", 16089);

        for (new i = 1; i <= MaxClients; i++)
        {
            if (!is_user_connected(i))
            {
                continue;
            }

            new TeamName:team = get_member(i, m_iTeam);
            if (team == TEAM_CT)
            {
                client_print_color(i, print_team_red, "%s Trocando lados!", PREFIX);
                client_print_color(i, print_team_red, "%s Atenção! Você agora é ^3Terrorista^1!", PREFIX);
                fade_screen(i, 1.5, 1.5, _, 255, 0, 0);
            }
            else if (team == TEAM_TERRORIST)
            {
                client_print_color(i, print_team_red,  "%s Trocando lados!", PREFIX);
                client_print_color(i, print_team_blue, "%s Atenção! Você agora é ^3Contra-Terrorista^1!", PREFIX);
                fade_screen(i, 1.5, 1.5, _, 0, 0, 255);
            }
        }
    }
    else if(team_scores[CS_TEAM_CT] >= max_wins)
    {
        set_task(5.0, "restart_game");
        set_dhudmessage(255, 255, 255, -1.0, 0.29, 2, 6.0, 6.0);
        show_dhudmessage(0, "VITÓRIA DA EQUIPE CONTRA-TERRORISTA!");

        client_print_color(0, print_team_blue, "%s Vitória ^3Contra-Terrorista^1.", PREFIX);
        client_print_color(0, print_team_blue, "%s Auto Restart:^3 %d Round's^1.", PREFIX, max_wins);
        
        fade_screen(0, 3.0, 3.0);
        client_cmd(0, "spk ^"%s^"", sounds[WIN]);
        shake_screen(10.0, 8.0, 1.0);
    }
    else if(team_scores[CS_TEAM_T] >= max_wins)
    {
        set_task(5.0, "restart_game", 1235);

        set_dhudmessage(255, 255, 255, -1.0, 0.29, 2, 6.0, 6.0);
        show_dhudmessage(0, "VITÓRIA DA EQUIPE TERRORISTA!");

        client_print_color(0, print_team_red, "%s Vitória ^4Terrorista^1!", PREFIX);
        client_print_color(0, print_team_red, "%s Auto Restart:^4 %d Round's^1.", PREFIX, max_wins);

        fade_screen(0, 3.0, 3.0, _, 255, 0, 0);
        client_cmd(0, "spk ^"%s^"", sounds[WIN]);
        shake_screen(10.0, 8.0, 1.0);
    }
}


public restart_game()
{
    server_cmd("sv_restart ^"3^"");

    server_cmd("sv_timeout ^"1^"");
    server_cmd("wait; wait; wait");
    server_cmd("sv_timeout ^"99999^"");

    client_cmd(0, "spk deeoo");

    team_scores[CS_TEAM_T]  = 0;
    team_scores[CS_TEAM_CT] = 0;
}


stock shake_screen(Float:amplitude = 3.0, Float:duration = 3.0, Float:frequency = 1.0)
{
  static MSG_ScreenShake;

  if(!MSG_ScreenShake)
    MSG_ScreenShake = get_user_msgid("ScreenShake");

  message_begin(MSG_BROADCAST, MSG_ScreenShake);
  write_short(float_to_short(amplitude));
  write_short(float_to_short(duration));
  write_short(float_to_short(frequency));
  message_end();

  return 1;
}


stock fade_screen(id, Float:duration = 1.0, Float:fadetime = 1.0, ScreenFadeFlags:flags = ScreenFade_FadeIn, r = 0, g = 0, b = 255, a = 75)
{
  static MSG_ScreenFade;

  if(!MSG_ScreenFade)
    MSG_ScreenFade = get_user_msgid("ScreenFade");

  message_begin((id) ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, MSG_ScreenFade, _, id);
  write_short(float_to_short(fadetime));
  write_short(float_to_short(duration));
  write_short(_:flags);
  write_byte(r);
  write_byte(g);
  write_byte(b);
  write_byte(a);
  message_end();

  return 1;
}

stock float_to_short(Float:value)
  return clamp(floatround(value * (1<<12)), 0, 0xFFFF);

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1046\\ f0\\ fs16 \n\\ par }
*/
