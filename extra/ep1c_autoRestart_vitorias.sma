#include < amxmodx >

#define PLUGIN   "ep1c AutoRestart"
#define VERSION  "0.2"
#define AUTHOR   "Developer + lonewolf"

#define PREFIX   "^1[^4ep1c gaming Brasil^1]^3:^1"

/*
enum CsTeams
{
	CS_TEAM_UNASSIGNED = 0,
	CS_TEAM_T          = 1,
	CS_TEAM_CT         = 2,
	CS_TEAM_SPECTATOR  = 3,
};
*/
new team_scores[CsTeams];

enum Cvars
{
    SWAPTEAMS,
    SWAPROUNDS,
    MAXWINS
}
new cvars[Cvars];

public plugin_init()
{
    register_plugin("Auto Restart", "0.0.1", "Developer");

    // Register: EVENT
    register_event("TeamScore", "event_update_score", "a");
    register_event("TextMsg",   "event_restarted",    "a", "2=#Game_will_restart_in");

    register_logevent("roundStart", 2, "1=Round_Start");

    // Register CVAR's
    cvars[SWAPTEAMS]  = create_cvar("amx_match_swapteams",  "1",   _, "<0-1> Enable auto team swapping.");
    cvars[SWAPROUNDS] = create_cvar("amx_match_swaprounds", "15",  _, "<number> Rounds before swapping.");
    cvars[MAXWINS]   = create_cvar("amx_match_maxwins",    "16",  _, "<number> Rounds needed to victory.");
}

public event_restarted()
{
    team_scores[CS_TEAM_T]  = 0;
    team_scores[CS_TEAM_CT] = 0;
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
    new match_point       = get_pcvar_num(cvars[MAX_WINS])   - 1;
    new round_before_swap = get_pcvar_num(cvars[SWAPROUNDS]) - 1;
    new max_wins = get_pcvar_num(cvars[MAXWINS]);

    if (team_scores[CS_TEAM_CT] == match_point)
    {
        client_print_color(0, print_team_blue, "%s Match-Point ^3CT^1.", PREFIX);
    }
    
    if (team_scores[CS_TEAM_T] == match_point)
    {
        client_print_color(0, print_team_red, "%s Match-Point ^3TR^1.", PREFIX);
    }

    if(team_scores[CS_TEAM_T] == max_wins)
    {
        set_task(5.0, "restart_game");

        set_hudmessage(0, 0, 225, -1.0, 0.29, 1, 6.0, 12.0);
        show_hudmessage(0, "VITÓRIA DA EQUIPE CONTRA-TERRORISTA!");

        client_print_color(0, print_team_blue, "%s Vitória ^3Contra-Terrorista^1.");
        client_print_color(0, print_team_blue, "%s Auto Restart:^3 %d Round's^1.", PREFIX, max_wins);
    }
    else if(team_scores[CS_TEAM_CT] == max_wins)
    {
        set_task(5.0, "restart_game");

        set_hudmessage(255, 0, 0, -1.0, 0.29, 1, 6.0, 12.0);
        show_hudmessage(0, "VITÓRIA DA EQUIPE TERRORISTA!");

        client_print_color(0, print_team_red, "%s Vitória ^4Terrorista^1.", PREFIX);
        client_print_color(0, print_team_red, "%s Auto Restart:^4 %d Round's^1.", PREFIX, max_wins);
    }
}

public restart_game()
{
    server_cmd("sv_restart ^"1^"");

    server_cmd("sv_timeout ^"1^"");
    server_cmd("wait; wait; wait");
    server_cmd("sv_timeout ^"99999^"");

    client_cmd(0, "spk deeoo");

    team_scores[CS_TEAM_T]  = 0;
    team_scores[CS_TEAM_CT] = 0;
}
