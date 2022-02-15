/*

	VAC Ban Status
	      by bugsy

   Description: 
	This plugin will check if a steam account has ever been VAC banned. Checking an account can be done in 2
	ways; manually via console and auto. Auto checking will automatically check a player either when they  
	first connect to the server or when they join a team. To specify when a player is checked, set the cvar
	vbs_vaccheck to the appropriate value (default: 0 [on connect]). If a VAC ban is found on a players
	steam account then the selected punishment will be issued on player. There are 5 punishments to choose
	from (see below enum) which can be defined by cvar vbs_punishment (default: 0 [log only]). Punishments can
	be issued either when a VAC ban status is found or when the player reaches a specified kill\death ratio. 
	To make a punishment be issued when the player reaches a specified kill-death ratio, select the appropriate
	punishment below. Each punishment named KDRATIO will be issued once the player reaches the kill\death  
	ratio. To specify the kill-death ratio, set it in the cvar vbs_kdratio (default 3 [3:1]). You can also
	specify a minimum kills value for when the plugin will start to check a players kill\death ratio; to set
	this value set cvar vbs_kdminkills to the appropriate value (default: 15 [kills]). When auto-checking is
	enabled, the server will check the VAC ban status on the steam server and save the ban status value to the
	database. If the player is not banned, the database entry is added with a timestamp that will expire in the
	number of days defined in cvar vbs_expiredays (default: 15 [days]). This will prevent a plugin from having 
	to constantly re-check a player everytime they connect. When the entry expires, they will get re-checked on
	the steam server on their next connection. If a VAC ban is found on a steam account, the database is permanent 
	and will never expire. If a player connects that has a positive VAC ban status saved to the database, the 
	selected punishment will be issued. There is a whitelisting system that allows you to whitelist particular 
	players steam accounts. This will make the plugin not recognize them as being VAC banned and they will be 
	immune to the plugin until they are removed from the whitelist.
	
   Usage: 	
	[command]		[parameter]	[description]
	amx_vacban		<name\steamid>	Check a players VAC ban status
	amx_vacclearall				Clear all entries from database
	amx_vacclearnotbanned			Clear all non-VAC banned entries from database
	amx_vacremoveentry	<name\steamid>	Remove an entry from database
	amx_vacaddwhitelist	<name\steamid>	Add a player to whitelist. Player will be considered not banned.
	amx_vacremovewhitelist	<name\steamid>	Remove a player from whitelist. 
	amx_vacquery		<name\steamid>	Query the database for a players VAC ban status
	  
   Database Storage:
	[key]	[val]	[storage duration]	[description]
	STEAMID 1 	<timestamped>		Player not VAC banned
	STEAMID 2 	<permanent>		Player VAC banned
	STEAMID 3 	<permanent>		Player whitelisted with no VAC ban
	STEAMID 4 	<permanent>		Player whitelisted with VAC ban

ChangeLog:
	v0.3
	- Improved speed of checking by increasing incoming data buffer size to 4096. Defined by BUFFER_SIZE
	- I noticed at times particular steam id checks would not work. I found that depending on the size of 
	  the users steam community page, the incoming data was sometimes cut off in the middle of a string/phrase 
	  we are looking for. For example, if we are looking for "<vacBanned>1" for ban status. One packet would 
	  have "<vacB" and the following packet would start with "anned>1" causing the plugin to not notice the 
	  ban string. Now, when data is received it is added to the previously received data so the detection strings 
	  can be checked within the entire buffer. 
	- Fixed bug where if you try to manually check a SteamID and accidentally have a space on the end it would 
	  print out checking SteamID []. 
	- Replaced set_user_hitzones with fm_set_user_hitzones. Removed fun module, fakemeta is now required.
	- Revised\improved DeathMsg code for applying punishment based on kill\death ratio.
	- Changed punishment and notify admin flag selection to cvar.
	- Added cvar to specify the seconds used to consider a connection to steam server as timedout. The cvar that
	  specifies the time out is vbs_sockettimeout [default 5.0]
	- Added KICK_BAN_ID_KDRATIO and KICK_BAN_IP_KDRATIO, these were both accidentally not coded.
	- Added punishment function so all punishments are issued in one place instead of having them coded multiple 
	  times.
	- Added cvar to specify the time period to ban a player when a ban punishment is used. vbs_bantime [default: 0]
	- Added clear all command to clear the database of all entries (everything, including both VAC banned\unbanned status
	  and whitelist entries). Note: You cannot clear all whitelisted or all VAC banned without clearing the entire db. 
	- Added clear non VAC banned command to clear database of entires that are not VAC banned (VAC banned and whitelist 
	  entries will remain in database). Command: amx_vacclearall
	- Added whitelist system so you can whitelist a steamid\player. When whitelisted, the player will be treated as if 
	  they have no VAC ban and will not get checked. The whitelist entry is permanent and will not be cleared unless 
	  done so manually with the amx_vacremovewhitelist or amx_vacclearall command. 
	  Commands: amx_vacaddwhitelist , amx_vacremovewhitelist
	- Added query command so you can manually check a players entry in the db. Command: amx_vacquery
	- Added display of time that a manual VAC ban status check took with steam server.
	- Added cvar to set when a player is auto-checked vbs_vaccheck [default: 0] 0=on connect, 1=team join [T\CT only]
	- Switched back to regular sockets module as sockets_hz didn't solve the lag issue.
	- Added error checking when opening vault. Since almost every function of the plugin uses vault communication, if
	  the vault does not open properly then the plugin cannot function as it was designed to. If an error is found when
	  opening the nvault file, the plugin will fail and report an error in log.
	- Corrected AMXBan usage.
	- Added usage of config file (vacbanstatus.cfg)
	
	v0.2b
	- Changed get_gametime() to get_systime() for nvault pruning. 
	- Change socket module to sockets_hz to prevent the game from freezing slightly when a new player connects to
	  server.
        - Made few optimizations suggested by hawk552
*/


#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <sockets>
#include <nvault>

#define PLUGIN	"VAC Ban Status"
#define VERSION	"0.3"
#define AUTHOR	"bugsy" 

#pragma semicolon 1

#define VAULT		"vacbanstatus"
#define BUFFER_SIZE	4096

enum	//Check method
{
	AUTO_CHECK,
	MANUAL_NAME,
	MANUAL_STEAMID
}

enum	//Punishments
{
	LOG_ONLY,
	KICK_ONLY,
	KICK_BAN_ID,
	KICK_BAN_IP,
	KICK_AMXBAN,
	SHOOTBLANKS,
	KICK_KDRATIO,
	KICK_BAN_ID_KDRATIO,
	KICK_BAN_IP_KDRATIO,
	KICK_AMXBAN_KDRATIO,
	SHOOTBLANKS_KDRATIO
}

enum	//Database ban values
{
	NO_DB_ENTRY,
	NOT_BANNED,
	BANNED,
	NOT_BANNED_WHITELIST,
	BANNED_WHITELIST
}

//Global vars
new g_Socket[33];		//Socket handle
new g_VACBanned[33];		//1 if VAC banned
new g_Punished[33];		//1 when player punished
new g_ShootsBlanks[33];		//1 if player shoots blanks
new g_JoinedTeam[33];		//1 when joins a team (T or CT)
new g_IsBot[33];		//1 if player is bot
new g_NotifyFlag[33];		//1 if user has notify admin flag
new Float:g_fSocketWait[33];	//Socket timeout, used to determine if webserver does not respond
new Float:g_fRequestTime[33];	//Amount of time request took.
new g_FMTraceLine;		//FM traceline forward handle.
new g_NumShootsBlanks;		//# of players who shoot blanks.
new g_TimedOut;			//Number of times server did not respond with auto-checks
new g_Vault;			//nVault handle
new g_MaxPlayers;		//Max players server holds
new g_SteamName[33];		//1 if Steam community name has been retrieved
new g_szSteamName[33][65];	//Steam community name
new g_szFriendID[33][65];	//Steam community ID#
new g_szAuthID[33][35];		//Steam ID
new g_szName[33][33];		//Name
new g_BodyHits[33][33];		//For fm_set_user_hitzones

//Cvar pointers
new g_pAutoCheck;		//CVAR Enable\disable autocheck
new g_pVACCheck;		//CVAR Specifies when to check player (0=connect or 1=team join)
new g_pExpireDays;		//CVAR Days at which a saved VAC ban is removed
new g_pKDRatio;			//CVAR Kill\Death ratio used for kdratio punishments
new g_pKDMin;			//CVAR Min kills required before checking kdratios
new g_pPunishment;		//CVAR Type of punishment to issue
new g_pBanTime;			//CVAR Number of minutes a player is banned for ban punishments
new g_pNotifyFlag;		//CVAR Notify flag required for notifications
new g_pSocketTimeout;		//CVAR Time at which we consider socket timedout

public plugin_init()
{
	register_plugin( PLUGIN , VERSION , AUTHOR );
	register_cvar( PLUGIN , VERSION , FCVAR_SERVER , 0.0 );

	register_concmd( "amx_vacban" , "CommandHandler" , ADMIN_BAN , "<Player\SteamID> - Check if player\steamid is VAC banned." );
	register_concmd( "amx_vacquery" , "CommandHandler" , ADMIN_BAN , "<Player\SteamID>- Query a player\steamid database entry." );
	register_concmd( "amx_vacaddwhitelist" , "CommandHandler" , ADMIN_BAN , "<Player\SteamID>- Add player\steamid to whitelist." );
	register_concmd( "amx_vacremovewhitelist" , "CommandHandler" , ADMIN_BAN , "<Player\SteamID>- Remove player\steamid from whitelist." );
	register_concmd( "amx_vacremoveentry" , "CommandHandler" , ADMIN_BAN , "<Player\SteamID>- Remove VAC ban status from database." );
	register_concmd( "amx_vacclearall" , "CommandHandler" , ADMIN_BAN , "- Clear all database entries" );
	register_concmd( "amx_vacclearnotbanned" , "CommandHandler" , ADMIN_BAN , "- Clear database entries for players that are not VAC banned." );	
	
	g_pAutoCheck = register_cvar( "vbs_autocheck" , "1" );
	g_pVACCheck = register_cvar( "vbs_vaccheck" , "0" );
	g_pPunishment = register_cvar( "vbs_punishment" , "0" );
	g_pNotifyFlag = register_cvar( "vbs_notifyflag" , "d" );
	g_pSocketTimeout = register_cvar( "vbs_sockettimeout" , "5" );
	g_pKDRatio = register_cvar( "vbs_kdratio" , "3" );
	g_pKDMin = register_cvar( "vbs_kdminkills" , "15" );
	g_pExpireDays = register_cvar( "vbs_expiredays" , "15" );
	g_pBanTime = register_cvar( "vbs_bantime" , "0" );

	register_event( "DeathMsg" , "fwEvDeathMsg" , "a" );
	register_event( "TeamInfo" , "fwPlayerJoinedTeam" , "a" , "2=TERRORIST" , "2=CT" );

	g_MaxPlayers = get_maxplayers();
}

public plugin_cfg()
{
	new szConfigDir[64];
	get_configsdir( szConfigDir , 63 );
	server_cmd( "exec %s/vacbanstatus.cfg" , szConfigDir );
	server_exec();
	
	g_Vault = nvault_open( VAULT );
	
	if ( g_Vault == INVALID_HANDLE )
		set_fail_state( "Error opening nVault" );
	else
		nvault_prune( g_Vault , 0 , get_systime() - ( get_pcvar_num( g_pExpireDays ) * 86400 ) );
}

public plugin_end()
{
	nvault_close( g_Vault );
}

public client_connect( id )
{
	fm_hitzones_reset( id );
}

public client_putinserver( id )
{
	g_IsBot[id] = is_user_bot(id);

	if ( g_IsBot[id] )
		return PLUGIN_CONTINUE;
	
	//Get users name and steamid and store it in global variable so it will
	//not need to be retrieved again if needed later.
	get_user_name( id , g_szName[id] , 32 );
	get_user_authid( id , g_szAuthID[id], 34 );

	//For testing with a known banned steamid
	//if ( id == get_user_index("bugsy") )
	//	g_szAuthID[id] = "STEAM_0:0:100";
		
	//If auto-checking and check-on-connect are enabled, check player for VAC ban
	if ( get_pcvar_num( g_pAutoCheck ) && !get_pcvar_num( g_pVACCheck ) )
		AutoCheckPlayer(id);

	//An admin has connected, check if has the required admin flag needed for notification.
        //If so, notify him of any players that are connected that have a VAC ban on record.
	if ( is_user_admin( id ) )
	{
		new szFlag[2];
		get_pcvar_string( g_pNotifyFlag , szFlag , 1 );
		g_NotifyFlag[id] = ( get_user_flags( id ) & read_flags( szFlag ) );

		//If player has admin flag specified in cvar vbs_notifyflag
		if ( g_NotifyFlag[id] )
			set_task( 8.0 , "NotifyAdmin" , id );
	}
	
	return PLUGIN_CONTINUE;
}

public fwPlayerJoinedTeam()
{
	new id = read_data( 1 );
	
	if ( g_JoinedTeam[id] || g_IsBot[id] || !get_pcvar_num( g_pAutoCheck ) || !get_pcvar_num( g_pVACCheck ) )
		return PLUGIN_CONTINUE;

	g_JoinedTeam[id] = 1;

	AutoCheckPlayer(id);

	return PLUGIN_CONTINUE;
}

public fwEvDeathMsg()
{
	new iPunishment = get_pcvar_num( g_pPunishment );
	new iKiller = read_data(1);
	new iVictim = read_data(2);
	
	if( ( iPunishment < KICK_KDRATIO ) || !iKiller || !g_VACBanned[iKiller] || ( iKiller == iVictim ) || g_Punished[iKiller] )
		return PLUGIN_CONTINUE;
	
	new iKills = get_user_frags( iKiller );
	new iDeaths = get_user_deaths( iKiller );

	if ( ( iKills >= get_pcvar_num( g_pKDMin ) ) && ( ( float( iKills ) / get_pcvar_float( g_pKDRatio ) ) >= float( iDeaths ) ) )
	{
		iPunishment -= KICK_KDRATIO;
		PunishPlayer( iKiller , iPunishment );
	}

	return PLUGIN_CONTINUE;
}

public client_disconnect( id )
{
	if( g_IsBot[id] )
		return PLUGIN_CONTINUE;

	if ( g_Socket[id] )
		CloseSocket( id );
		
	if ( g_ShootsBlanks[id] )
		SetShootBlanks( id , 0 );

	//Clear all vars for player index
	g_SteamName[id] = 0;
	g_szSteamName[id][0] = 0;
	g_szFriendID[id][0] = 0;
	g_szAuthID[id][0] = 0;
	g_szName[id][0] = 0;
	g_VACBanned[id] = 0;
	g_JoinedTeam[id] = 0;
	g_NotifyFlag[id] = 0;
	g_Punished[id] = 0;

	return PLUGIN_CONTINUE;
}

public AutoCheckPlayer(id)
{
	new iBanVal = nvault_get( g_Vault , g_szAuthID[id] );
	
	//No entry exists in database for player, send VAC check request to steam server
	if ( iBanVal == NO_DB_ENTRY )
	{
		SendRequest( 0 , id , AUTO_CHECK );
	}
	//Entry found in database and player is VAC banned, punish and notify admins
	else if ( iBanVal == BANNED )
	{
		static szHUD[256];
		new iPlayers[32];
		new iPlayersNum;
		new iPlayer;
		
		g_VACBanned[id] = 1;
	
		get_players( iPlayers, iPlayersNum , "c" );

		formatex( szHUD , 255 , "[VAC Ban Status]^n^n%s has a VAC ban on record. [Database]^nSteamID: %s" , g_szName[id] , g_szAuthID[id] );
		set_hudmessage( 255 , 255 , 255 , 0.10 , 0.35 , 0 , 2.0 , 4.0 , 0.5 , 0.5 , 3 );
		 
		//Notify all connected admins that this player has connected and is banned
		for( new i = 0 ; i < iPlayersNum ; i++ )
		{
			iPlayer = iPlayers[i];
			if( g_NotifyFlag[iPlayer] )
			{
				show_hudmessage( iPlayer , szHUD );
				client_cmd( iPlayer , "spk buttons/blip1.wav" );
			}
		}
	
		//If punishment is not a kd-ratio punishment, issue punishment now.
		new iPunishment = get_pcvar_num( g_pPunishment );
		
		if ( iPunishment <= SHOOTBLANKS )
		{
			//VAC check done on client connect so we need a little pause to allow player to 
			//fully initialize into game or else some punishments will not work.
			if ( !get_pcvar_num( g_pVACCheck ) )
			{
				new params[2];
				params[0] = id;
				params[1] = iPunishment;
				set_task( 0.5 , "DelayPunishment" , _ , params , 2 );
			}
			else
			{
				PunishPlayer( id , iPunishment );
			}
		}
	}
}
	
public DelayPunishment( params[2] )
{
	PunishPlayer( params[0] , params[1] );
}

public CommandHandler( id , level , cid )
{
	if( !cmd_access( id , level , cid , 1 ) )
		return PLUGIN_HANDLED;

	//amx_vacban
	//amx_vacremoveentry
	//amx_vacaddwhitelist
	//amx_vacremovewhitelist
	//amx_vacquery
	//amx_vacclearall
	//amx_vacclearnotbanned

	new szCmd[23];

	read_argv( 0 , szCmd , 22 );
	
	if ( equal( szCmd , "amx_vacclearnotbanned" ) )
	{
		nvault_prune( g_Vault , 0 , get_systime() );
		console_print( id , "*[VAC BAN Status] All non VAC banned entries have been cleared." );

		return PLUGIN_HANDLED;
	}
	else if ( equal( szCmd , "amx_vacclearall" ) )
	{
		new szVaultFile[65];
		get_datadir( szVaultFile , 64 );
		format( szVaultFile , 64 , "%s/vault/%s.vault" , szVaultFile , VAULT );
		
		nvault_close( g_Vault );
	
		if ( delete_file( szVaultFile ) )
		{
			g_Vault = nvault_open( VAULT );
			
			if ( g_Vault != INVALID_HANDLE )
			{
				console_print( id , "*[VAC Ban Status] Database successfully cleared." );
				return PLUGIN_HANDLED;
			}
		}

		set_fail_state( "Error clearing nvault" );

		return PLUGIN_HANDLED;
	}

	new iPlayer;
	new szVal[2];
	new iBanVal;
	new iTimestamp;
	new szArgs[46];
	new iRequestType;
	
	read_args( szArgs , 45 );

	//The below commands all require a parameter (name\steamid) so we determine which is
	//being specified by the user.
	if( !equali( szArgs , "STEAM_0:" , 8 ) )
	{
		iPlayer = cmd_target( id , szArgs , 10 );
	
		if( !is_user_connected( iPlayer ) || g_IsBot[ iPlayer ] )
			return PLUGIN_HANDLED;
	}
	else
	{
		iPlayer = 0;

		trim( szArgs );
			
		copy( g_szAuthID[iPlayer] , 34 , szArgs[ strfind( szArgs , " " ) + 1 ] );
		
		strtoupper( g_szAuthID[iPlayer] );
		
		if ( ( strlen( g_szAuthID[iPlayer] ) <= 10 ) )
		{
			console_print( id , "*[VAC Ban Status] Invalid SteamID [%s]." , g_szAuthID[iPlayer] );
			return PLUGIN_HANDLED;
		}
		
		if ( g_szAuthID[iPlayer][10] == '0' )
			formatex( g_szAuthID[iPlayer][10] , 24 , "%d" , str_to_num( g_szAuthID[iPlayer][10] ) );
	}

	if ( nvault_lookup( g_Vault , g_szAuthID[iPlayer] , szVal , 1 , iTimestamp ) )
		iBanVal = str_to_num( szVal );

	if ( equal( szCmd , "amx_vacban" ) )
	{
		if( g_Socket[id] )
		{
			console_print( id , "*[VAC Ban Status] Previous check still in progress, try again when it completes." );
			return PLUGIN_HANDLED;
		}

		if ( iPlayer )
		{
			console_print( id , "*[VAC Ban Status] Checking %s [%s]." , g_szName[iPlayer] , g_szAuthID[iPlayer] );
			iRequestType = MANUAL_NAME;
		}
		else
		{
			console_print( id , "*[VAC Ban Status] Checking SteamID [%s]." , g_szAuthID[iPlayer] );
			iRequestType = MANUAL_STEAMID;
		}
			
		g_SteamName[iPlayer] = 0;
	
		SendRequest( id , iPlayer , iRequestType );

		return PLUGIN_HANDLED;
	}
	else if ( equal( szCmd , "amx_vacquery" ) )
	{
		switch ( iBanVal )
		{
			case NO_DB_ENTRY: console_print( id , "*[VAC Ban Status] Query: No entry exists in database for %s." , !iPlayer ? g_szAuthID[iPlayer] : g_szName[iPlayer] );
			case NOT_BANNED: 
			{
				new Float:fExpireDays = ( ( get_pcvar_float( g_pExpireDays ) * 86400.0 ) - ( float(get_systime()) - float(iTimestamp) ) ) / 86400.0;
				console_print( id , "*[VAC Ban Status] Query: %s is not VAC banned. Entry expires in %d days." , !iPlayer ? g_szAuthID[iPlayer] : g_szName[iPlayer] , floatround(fExpireDays) );
			}
			case BANNED: console_print( id , "*[VAC Ban Status] Query: %s has a VAC ban on record." , !iPlayer ? g_szAuthID[iPlayer] : g_szName[iPlayer] );
			case NOT_BANNED_WHITELIST: console_print( id , "*[VAC Ban Status] Query: %s is whitelisted with no VAC ban on record." , !iPlayer ? g_szAuthID[iPlayer] : g_szName[iPlayer] );
			case BANNED_WHITELIST: console_print( id , "*[VAC Ban Status] Query: %s is whitelisted with a VAC ban on record." , !iPlayer ? g_szAuthID[iPlayer] : g_szName[iPlayer] );
		}
		
		return PLUGIN_HANDLED;
	}
	else if ( equal( szCmd , "amx_vacaddwhitelist" ) )
	{
		if ( iBanVal <= BANNED )
		{	
			if ( !iBanVal ) 
				iBanVal = NOT_BANNED;
				
			szVal[0] = '0' + ( iBanVal + 2 );
			
			nvault_pset( g_Vault , g_szAuthID[iPlayer] , szVal );

			console_print( id , "*[VAC Ban Status] %s has been whitelisted." , !iPlayer ? g_szAuthID[iPlayer] : g_szName[iPlayer] );
		}
		else
		{
			console_print( id , "*[VAC Ban Status] %s is already on the whitelist." , !iPlayer ? g_szAuthID[iPlayer] : g_szName[iPlayer] );
		}
		
		return PLUGIN_HANDLED;
	}
	
	//The below commands involve removing existing entries so we verify that an entry exists first.
	if ( !iBanVal )
	{
		console_print( id , "*[VAC Ban Status] No database entry exists for %s." , !iPlayer ? g_szAuthID[iPlayer] : g_szName[iPlayer] );
		return PLUGIN_HANDLED;
	}
	
	if ( equal( szCmd , "amx_vacremoveentry" ) )
	{
		//Player has VAC status in db and is not whitelisted
		if ( iBanVal <= BANNED )
		{ 
			nvault_remove( g_Vault , g_szAuthID[iPlayer] );
			console_print( id , "*[VAC Ban Status] VAC ban database entry for %s was removed." , !iPlayer ? g_szAuthID[iPlayer] : g_szName[iPlayer] );
		}
		else 
		{
			console_print( id , "*[VAC Ban Status] %s is whitelisted, must use amx_vacremovewhitelist command." , !iPlayer ? g_szAuthID[iPlayer] : g_szName[iPlayer] );
		}
	}
	else if ( equal( szCmd , "amx_vacremovewhitelist" ) )
	{
		//Player is on whitelist, set appropriate ban status by subtracting 2 from whitelist status
		if ( iBanVal >= NOT_BANNED_WHITELIST )
		{
			szVal[0] = '0' + ( iBanVal - 2 );
			
			if ( iBanVal == NOT_BANNED_WHITELIST )
				nvault_set( g_Vault , g_szAuthID[iPlayer] , szVal );
			else
				nvault_pset( g_Vault , g_szAuthID[iPlayer] , szVal );
				
			console_print( id , "*[VAC Ban Status] %s was removed from the whitelist; player is%s VAC banned." , !iPlayer ? g_szAuthID[iPlayer] : g_szName[iPlayer] , ( iBanVal == NOT_BANNED_WHITELIST ) ? " not" : "" );
		}
		else
		{
			console_print( id , "*[VAC Ban Status] %s has an entry in the db but is not whitelisted. Use amx_vacremoveentry command" , !iPlayer ? g_szAuthID[iPlayer] : g_szName[iPlayer] );
		}
	}

	
	return PLUGIN_HANDLED;
}


public NotifyAdmin( id )
{
	static szNames[513];
	new iPlayers[32];
	new iPlayersNum;
	new iPlayer;
	new iPos;
	new iFound;
	
	iPos = formatex( szNames , 512 , "[VAC Ban Status]^nThe following players have^na VAC ban on record:^n^n" );

	get_players( iPlayers , iPlayersNum , "c" );

	//Cycle through all players and create a list of VAC banned players
	for( new i = 0 ; i < iPlayersNum ; i++ )
	{
		iPlayer = iPlayers[i];
		
		if( g_VACBanned[iPlayer] )
		{
			iFound++;
			iPos += formatex( szNames[iPos] , 512 - iPos , "%s^n" , g_szName[iPlayer] );
		}
	}

	//If we have found any, display to admin
	if( iFound )
	{
		set_hudmessage( 255 , 255 , 255 , 0.10 , 0.35 , 0 , 2.0 , 4.0 , 0.5 , 0.5 , 3 );
		show_hudmessage( id , szNames );
		client_cmd( id , "spk buttons/blip1.wav" );
	}
}

public SendRequest( id , idCheck , iRequestType )
{
	new iError;

	if( g_Socket[idCheck] ) 
		CloseSocket( idCheck );

	g_Socket[idCheck] = socket_open( "steamcommunity.com" , 80 , SOCKET_TCP , iError );

	if( ( g_Socket[idCheck] > 0 ) && !iError )
	{
		static szPacket[256];

		//Save current time to determine how long [manual] VAC ban check took
		if ( iRequestType )
			g_fRequestTime[idCheck] = get_gametime();

		if( !g_SteamName[idCheck] )
		{
			GetFriendID( g_szAuthID[idCheck] , g_szFriendID[idCheck] , 64 );
			formatex( szPacket , 255 , "GET /profiles/%s?xml=1 HTTP/1.1^r^nHost: steamcommunity.com^r^nConnection: close^r^n^r^n" , g_szFriendID[idCheck] );
		}
		else
		{
			formatex( szPacket , 255 , "GET /id/%s/ HTTP/1.1^r^nHost: steamcommunity.com^r^nConnection: close^r^n^r^n" , g_szSteamName[idCheck] );
		}
		
		socket_send( g_Socket[idCheck] , szPacket , strlen(szPacket) );
		
		g_fSocketWait[idCheck] = get_gametime();
	
		new param[3];
		param[0] = id;
		param[1] = idCheck;
		param[2] = iRequestType;

		if( !task_exists( 5511 + idCheck ) )
			set_task( 0.1 , "CheckRecv" , 5511 + idCheck , param , 3 , "b" );
	}
	else
	{
		set_fail_state( "Error loading socket" );
	}
	
	return PLUGIN_HANDLED;
}

public CheckRecv( param[3] )
{
	new id = param[0]; 
	new idCheck = param[1]; 
	new iRequestType = param[2]; 
	
	static szData[BUFFER_SIZE];
	static iPos;
	
	if ( socket_change( g_Socket[idCheck] , 1 ) )
	{
		//Append data to our receive buffer
		socket_recv( g_Socket[idCheck] , szData[iPos] , BUFFER_SIZE - iPos );
		
		//I noticed sometimes that socket_change was returning true even though no new data was waiting to be read.
		//This will verify if new data is actually received.
		if ( strlen ( szData[iPos] ) )
		{
			//Set buffer pos to end of received data so the next time we recv data it will be appended
			iPos = strlen( szData );
			
			//Set var to the time at which data last recvd
			g_fSocketWait[idCheck] = get_gametime();
			
			//Strings we are looking for to determine VAC ban status
			new iFoundPos =   containi( szData , "302 Found" );
			new iNotBanned1 = containi( szData , "<vacBanned>0" );
			new iNotBanned2 = containi( szData , "</html>" );
			new iNotBanned3 = containi( szData , "</profile>" );
			new iBansFound1 = containi( szData ,"ban(s) on record" );
			new iBansFound2 = containi( szData , "<vacBanned>1" );
			new szBanVal[2];
			
			if( iFoundPos > -1 )
			{	
				iPos = 0;
				
				new iNamePos =  strfind( szData, "/id/" , _ ,iFoundPos );
				new iEndNamePos = strfind( szData, "Content-Length" , _, (iNamePos + 4) );
			
				if ( ( iNamePos > -1 ) && ( iEndNamePos > -1 ) )
				{
					copy( g_szSteamName[idCheck], (iEndNamePos - (iNamePos + 7)), szData[iNamePos + 4] );
					g_SteamName[idCheck] = 1;
					
					CloseSocket( idCheck );
					
					SendRequest( id , idCheck , iRequestType );
				}
				
				return PLUGIN_HANDLED;
			}
			else if( (iBansFound1 > -1) || ( iBansFound2 > -1) )
			{
				iPos = 0;
				
				g_VACBanned[idCheck] = 1;
				
				switch( iRequestType )
				{
					case AUTO_CHECK:
					{
						szBanVal[0] = '0' + BANNED;
						nvault_pset( g_Vault , g_szAuthID[idCheck] , szBanVal );
						
						log_to_file( "vacstatus.log", "%s is VAC banned. [SteamID: %s] [CommunityName: %s] [CommunityID: %s]", g_szName[idCheck], g_szAuthID[idCheck] , 
																			g_SteamName[idCheck] ? g_szSteamName[idCheck] : "(none)" , g_szFriendID[idCheck] );
		
						static szHUD[479];
						new iPlayers[32];
						new iPlayersNum;
						new iPlayer;
						
						formatex( szHUD , 478 , "[VAC Ban Status]^n^n%s has a VAC ban on record.^nSteamID: %s^nSteamCommunity Name: %s" , g_szName[idCheck] , g_szAuthID[idCheck] , 
																				g_SteamName[idCheck] ? g_szSteamName[idCheck] : "(none)" );
						
						
						set_hudmessage( 255 , 255 , 255 , 0.10 , 0.35 , 0 , 2.0 , 4.0 , 0.5 , 0.5 , 3 );
		
						get_players( iPlayers, iPlayersNum , "c" );	
						
						for( new i = 0 ; i < iPlayersNum ; i++ )
						{	
							iPlayer = iPlayers[i];
							
							if( g_NotifyFlag[iPlayer] )
							{
								show_hudmessage( iPlayer , szHUD );
								client_cmd( iPlayer ,"spk buttons/blip1.wav" );
							}
						}	
					}
					case MANUAL_NAME: console_print( id , "*[VAC Ban Status] %s is VAC banned! [%0.3f seconds]" , g_szName[idCheck] , get_gametime() - g_fRequestTime[idCheck] );
					case MANUAL_STEAMID: console_print( id , "*[VAC Ban Status] SteamID [%s] is VAC banned! [%0.3f seconds]" , g_szAuthID[idCheck] , get_gametime() - g_fRequestTime[idCheck] );
				}
				
				//Issue punishment if non kill:death ratio punishment selected
				new iPunishment = get_pcvar_num( g_pPunishment );
				if ( iPunishment <= SHOOTBLANKS )
					PunishPlayer( idCheck , iPunishment );
	
				CloseSocket( idCheck );
				
				return PLUGIN_HANDLED;
			}
			else if( ( iNotBanned1 > -1 ) || ( iNotBanned2 > -1 ) || ( iNotBanned3 > -1 ) )
			{
				iPos = 0;
				
				g_VACBanned[idCheck] = 0;
				
				switch( iRequestType )
				{
					case AUTO_CHECK: 
					{
						szBanVal[0] = '0' + NOT_BANNED;
						nvault_set( g_Vault , g_szAuthID[idCheck] , szBanVal );

					}
					case MANUAL_NAME: console_print( id , "*[VAC Ban Status] %s is not VAC banned. [%0.3f seconds]" , g_szName[idCheck] , get_gametime() - g_fRequestTime[idCheck] );
					case MANUAL_STEAMID: console_print( id , "*[VAC Ban Status] SteamID [%s] is not VAC banned. [%0.3f seconds]" , g_szAuthID[idCheck] , get_gametime() - g_fRequestTime[idCheck] );
				}
				
				CloseSocket( idCheck );
				
				return PLUGIN_HANDLED;
			}
			
			new iFindPos = strfind_reverse( szData , "<" , 1 , 0 );
				
			if ( iFindPos > -1 )
				iPos = formatex( szData , BUFFER_SIZE  , "%s" , szData[iFindPos] );
		}
	}	
	
	if( ( get_gametime() - g_fSocketWait[idCheck] ) >= get_pcvar_float( g_pSocketTimeout ) )	
	{
		iPos = 0;
		
		if( iRequestType )
		{
			console_print( id , "*[VAC Ban Status] Server took too long to respond, please try again." );
		}
		else
		{
			if ( ++g_TimedOut >= 5 )
			{
				new iPlayers[32];
				new iPlayersNum;
				new iPlayer;
				
				get_players( iPlayers , iPlayersNum , "c" );
				
				g_TimedOut = 0;
				
				//Cycle through all players and create a list of VAC banned players
				for( new i = 0 ; i < iPlayersNum ; i++ )
				{
					iPlayer = iPlayers[i];
					if ( g_NotifyFlag[iPlayer] )
						client_print( iPlayer , print_chat , "*[VAC Ban Status] Steam server may be down; it has not responded to 5 auto-checks." );
				}
			}
		}
		
		CloseSocket( idCheck );
	}
	
	return PLUGIN_HANDLED;
}

public CloseSocket(id)
{
	remove_task( 5511 + id );
	socket_close( g_Socket[id] );
	g_Socket[id] = 0;
}


public PunishPlayer( id , iPunishment )
{
	new szMsg[30];

	g_Punished[id] = 1;

	switch ( iPunishment )
	{
		case LOG_ONLY: 
		{
			return PLUGIN_HANDLED;
		}
		case KICK_ONLY:
		{
			KickPlayer( id , "[VAC Ban Status]", "A VAC ban record was found on your steam account." , "You have been kicked" ) ;
			formatex( szMsg , 29 , "was kicked" );
		}
		case KICK_BAN_ID:
		{
			server_cmd("amx_ban ^"#%d^" ^"%d^" ^"VAC Banned^"" , get_user_userid(id) , get_pcvar_num( g_pBanTime ) );
			formatex( szMsg , 29 , "was kicked and banned" );
		}
		case KICK_BAN_IP:
		{
			server_cmd( "amx_banip ^"#%d^" ^"%d^" ^"VAC Banned^"" , get_user_userid(id) , get_pcvar_num( g_pBanTime ) );
			formatex( szMsg , 29 , "was kicked and banned" );
		}
		case KICK_AMXBAN:
		{
			server_cmd( "amx_ban %d %s VAC Banned", get_pcvar_num( g_pBanTime ) , g_szAuthID[id] );
			formatex( szMsg , 29 , "was kicked and banned" );	
		}
		case SHOOTBLANKS:
		{
			SetShootBlanks( id , 1 );
			formatex( szMsg , 29 , "will now shoot blanks" );
		}
	}
	
	new iPlayers[32];
	new iPlayersNum;
	new iPlayer;
	
	get_players( iPlayers, iPlayersNum , "c" );
	
	for ( new i = 0 ; i < iPlayersNum ; i++ )
	{
		iPlayer = iPlayers[i];
		
		if ( g_NotifyFlag[iPlayer] )
			client_print( iPlayer , print_chat , "[VAC Ban Status] %s %s for being VAC banned%s" , g_szName[id] , szMsg , ( get_pcvar_num( g_pPunishment ) >= 6 ) ? " with a high kill:death ratio." : "." );
	}
	
	return PLUGIN_HANDLED;
}

public SetShootBlanks(id, iVal)
{
	//iVal = 1 - Set shoot blanks on player and enable traceline forward if not yet enabled.
	//iVal = 0 - Remove shoot blanks for player id and disable forward if no other players shoot blanks.

	if ( iVal )
	{
		fm_set_user_hitzones( id , 0 , 0 );
		
		g_ShootsBlanks[id] = 1;
		g_NumShootsBlanks++;
		
		if ( !g_FMTraceLine )
			g_FMTraceLine = register_forward( FM_TraceLine , "fw_TraceLine" , 1 );
	}
	else
	{
		g_ShootsBlanks[id] = 0;
		g_NumShootsBlanks--;
		
		if ( !g_NumShootsBlanks && g_FMTraceLine )
		{
			unregister_forward( FM_TraceLine , g_FMTraceLine , 1 );
			g_FMTraceLine = 0;
		}
	}
}

//fm_set_user_hitzones
public fw_TraceLine(Float:v1[3], Float:v2[3], NoMonsters, shooter, ptr)
{
	if ( !(1 <= shooter <= g_MaxPlayers) )
		return FMRES_IGNORED;

	new iPlayerHit = get_tr2( ptr , TR_pHit );
	
	if ( !( 1 <= iPlayerHit <= g_MaxPlayers ) )
		 return FMRES_IGNORED;
		 
	new iHitzone = get_tr2( ptr , TR_iHitgroup );
		
	if ( !( g_BodyHits[ shooter ][ iPlayerHit ] & ( 1 << iHitzone ) ) )
		set_tr2( ptr , TR_flFraction , 1.0 );

	return FMRES_IGNORED;
}

public fm_set_user_hitzones(index, target, body)
{
	if ( !index && !target ) 
	{
		for ( new i = 1 ; i <= g_MaxPlayers ; i++ ) 
			for (new j = 1 ; j <= g_MaxPlayers ; j++ ) 
				g_BodyHits[i][j] = body;
	}
	else if ( !index && target )
	{
		for ( new i = 1 ; i <= g_MaxPlayers ; i++ ) 
			g_BodyHits[i][target] = body;
	}
	else if ( index && !target ) 
	{
		for ( new i = 1 ; i <= g_MaxPlayers ; i++ ) 
			g_BodyHits[index][i] = body;
	}
	else if ( index && target ) 
	{
		g_BodyHits[index][target] = body;
	}
}

public fm_hitzones_reset(index)
{
	for ( new i = 1 ; i <= g_MaxPlayers ; i++ )
	{
		g_BodyHits[index][i] = (1<<HIT_GENERIC) | (1<<HIT_HEAD) | (1<<HIT_CHEST) | 
				       (1<<HIT_STOMACH) | (1<<HIT_LEFTARM) | (1<<HIT_RIGHTARM)| 
				       (1<<HIT_LEFTLEG) | (1<<HIT_RIGHTLEG);
	}
				
}

// Credit to Teyut for multi-line kick message
public KickPlayer( target , szReason[] , szLine2[] , szLine3[] ) 
{
	static msg_content[1024];
	
	formatex(msg_content, 1023, "%s^n%s^n%s", szReason, szLine2, szLine3);
	message_begin(MSG_ONE_UNRELIABLE, 2 , _, target);
	write_string(msg_content);
	message_end() ;
}

// Credit to danielkza for the code below
public GetFriendID(const szAuthID[],szReturn[],iRetLen)
{
	static const szFriendsBaseNum[] = "76561197960265728";
	
	new szServer[2], szSteamID[64];
	
	new iServerPos = containi(szAuthID,":");
	if(iServerPos < 0)
		return 0;
	
	strtok(szAuthID[iServerPos+1],szServer,charsmax(szServer),szSteamID,charsmax(szSteamID),':',1);
	
	if(!is_str_num(szServer) || !is_str_num(szSteamID))
		return 0;
	
	// AuthID * 2
	NumString_Add(szSteamID,szSteamID,szSteamID,charsmax(szSteamID));

	// AuthID + Base Number + Server Number
	NumString_Add(szSteamID,szFriendsBaseNum,szSteamID,charsmax(szSteamID));
	NumString_Add(szSteamID,szServer,szSteamID,charsmax(szSteamID));
	
	return (copy(szReturn,iRetLen,szSteamID) > 0);
}
	
NumString_Add(const szString1[],const szString2[],szReturn[], iRetLen)
{	
	new iLen1 = strlen(szString1), iLen2=strlen(szString2);
	if(!iLen1 || !iLen2)
		return;
	
	static szTemp1[64];
	copy(szTemp1,iLen1,szString1);
	
	static szTemp2[64];
	copy(szTemp2,iLen2,szString2);
	
	static szTemp3[64];
	
	new iTempNum,iCarry;
	new iCharPos=0;

	do
	{
		iTempNum = 0;
		
		if(--iLen1 >= 0 && isdigit(szTemp1[iLen1]))
			iTempNum += char_to_num(szTemp1[iLen1]);
		if(--iLen2 >= 0 && isdigit(szTemp2[iLen2]))
			iTempNum += char_to_num(szTemp2[iLen2]);
		
		iTempNum += iCarry;
		iTempNum -= ((iCarry = iTempNum / 10) * 10);
		
		szTemp3[iCharPos++] = num_to_char(iTempNum);
	}
	while(iLen1 >= 0 || iLen2 >= 0);
	
	new bool:iNumStarted = false;
	new iLastChar = min(iRetLen, iCharPos),i;
	
	if(iLastChar)
	{
		while(--iCharPos >= 0 && i < iLastChar)
		{
			if(szTemp3[iCharPos] == '0' && !iNumStarted)
				continue;
			else
			{
				iNumStarted = true;
				szReturn[i++] = szTemp3[iCharPos];
			}
		}
	}
}

num_to_char(num)
{
	return ( (num < 0) || (num > 9) ) ? '^0' : '0' + num;
}

char_to_num(chr)
{
	return ( (chr < '0') || (chr > '9') ) ? 0 : (chr - '0');
}  

strfind_reverse( const szSource[] , const szFind[] , iIgnoreCase , iStartPos )
{
	new iSubLen = strlen( szFind );
	new iSourceLen = strlen( szSource );
	
	if ( !iSubLen || !iSourceLen || ( iSubLen > iSourceLen ) )
		return -1;
		
	if ( !iStartPos || (iStartPos >= iSourceLen) )
		iStartPos = iSourceLen - iSubLen;
	else
		iStartPos = clamp( iStartPos , 0 , iSourceLen - 1 );
		
	for ( new i = iStartPos ; i >= 0 ; i-- )
		if ( ( iIgnoreCase && equali( szSource[i] , szFind , iSubLen ) ) || ( !iIgnoreCase && equal( szSource[i] , szFind , iSubLen ) ) )
			return i;
	
	return -1;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
