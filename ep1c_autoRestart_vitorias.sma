#include < amxmodx >

/*
Placar:
** CT = 0
** TR = 1
*/
new scoredPlacar[ 2 ];

/*
CVAR's:
** ANNOUNCE = 0
** ALERTA (ROUND ANTERIOR) = 1
** ROUND RESTART = 2
*/
new CVAR[ 3 ];

public plugin_init( )
{
    register_plugin( "Auto Restart", "0.0.1", "Developer" );

    // Register: EVENT
    register_event( "TeamScore", "function_countRound", "a" );
    register_event( "TextMsg", "restartRound", "a", "2=#Game_will_restart_in" );

    register_logevent( "roundStart", 2, "1=Round_Start" );

    // Register CVAR's
    CVAR[ 0 ] = register_cvar( "cvar_announce", "0" );
    CVAR[ 1 ] = register_cvar( "cvar_min_rounds", "15" );
    CVAR[ 2 ] = register_cvar( "cvar_max_rounds", "16" );
}

public restartRound( )
{
    scoredPlacar[ 0 ] = 0;
    scoredPlacar[ 1 ] = 0;
}

public function_countRound( )
{
    new sz_team[ 32 ];
    read_data( 1, sz_team, 31 );

    if( equal( sz_team, "CT" ) )
        scoredPlacar[ 0 ] = read_data( 2 );

    else if( equal( sz_team, "TERRORIST" ) )
        scoredPlacar[ 1 ] = read_data( 2 );
}

public roundStart( )
{
    if( ( scoredPlacar[ 0 ] == get_pcvar_num( CVAR[ 1 ] ) ) )
        client_print_color( 0, 0, "^1[^4ep1c gaming Brasil^1]^3: ^1Match-Point CT^1." );

    if( ( scoredPlacar[ 1 ] == get_pcvar_num( CVAR[ 1 ] ) ) )
        client_print_color( 0, 0, "^1[^4ep1c gaming Brasil^1]^3: ^1Match-Point TR^1." );

    if( scoredPlacar[ 0 ] == get_pcvar_num( CVAR[ 2 ] ) )
    {
        set_task( 5.0, "restartGame" );

        set_hudmessage( 0, 0, 225, -1.0, 0.29, 1, 6.0, 12.0 );
        show_hudmessage( 0, "VITÓRIA DA EQUIPE CONTRA-TERRORISTA !"); 

        client_print_color( 0, 0, "^1[^4ep1c gaming Brasil^1]^3: ^1Vitória ^4Contra-Terrorista^1." );
        client_print_color( 0, 0, "^1[^4ep1c gaming Brasil^1]^3: ^1Auto Restart:^4 %d Round's^1.", get_pcvar_num( CVAR[ 2 ] ) );
    }

    else if( scoredPlacar[ 1 ] == get_pcvar_num( CVAR[ 2 ] ) )
    {
        set_task( 5.0, "restartGame" );

        set_hudmessage( 255, 0, 0, -1.0, 0.29, 1, 6.0, 12.0 );
        show_hudmessage( 0, "VITÓRIA DA EQUIPE TERRORISTA !"); 

        client_print_color( 0, 0, "^1[^4ep1c gaming Brasil^1]^3: ^1Vitória ^4Terrorista^1." );
        client_print_color( 0, 0, "^1[^4ep1c gaming Brasil^1]^3: ^1Auto Restart:^4 %d Round's^1.", get_pcvar_num( CVAR[ 2 ] ) );
    }
}

public restartGame( )
{
    server_cmd( "sv_restart ^"1^"" );

    server_cmd( "sv_timeout ^"1^"" );
    server_cmd( "wait; wait; wait" );
    server_cmd( "sv_timeout ^"99999^"" );

    client_cmd( 0, "spk deeoo" );

    scoredPlacar[ 0 ] = 0;
    scoredPlacar[ 1 ] = 0;
}
