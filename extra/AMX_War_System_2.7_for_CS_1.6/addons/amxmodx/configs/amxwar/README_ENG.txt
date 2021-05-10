******************************************************************************
amxwar.cfg:
******************************************************************************
// can games be tied? 0 = off, 1 = on 
// Can be anyone's? there is no 0 =, to play Overtime, 1 = yes
// maxrounds: if two map games then secondmaprules must be 3 or this has no effect
// timelimit: if two map games then secondmaprules must be >1 or this has no effect
aw_tie 0

// How many seconds before the match starts, after all players say ready or admin chooses autostart
aw_countdowntime 0

//How initial sides are chosen (0=Team1 CT, Team2 TER; 1=Cointoss; 2=Knife round)
aw_assign_mode 0

//Automatically assign players to teams 1 = yes; 0 = no
aw_autoteam 1

//Only check players ready with clantag; 0 = no, 1 = yes
aw_clantagcheck 0

//Take screenshots: 0 = no, 1 = yes, 2 = ask client
aw_screenshots 0

//Take demos: 0 = no, 1 = yes, 2 = ask client
aw_demos 0

// Tuning hltv, -1 to turn off hltv recording or use admin password from hltv.cfg to record hltv
aw_hltv_passw 123

//If player leaves the server, check joining player by IP address? 1= yes, 0=nno 
//note if set at 1, then no one will be able to join the server, except players who have left
aw_check_ip 0

//If player leaves the server, check joining player by name 1= yes, 0=no 
//note if set at 1, then no one will be able to join the server, except players who have left
aw_check_name 0

//To return money to the departed player during the match on return to the server
//To check player by (0= do not return money, 1= by name or IP, 2= by IP, 3= by name, 4= Both name and IP
aw_return_money_by 1

//Automatically swa teams; 0= no, 1= yes
aw_swapteams 1

//Set's how many rounds in overtime session (1 half)
aw_ot_rounds 3

//Time limit for warmup session (0= no limit)
aw_warmup_timelimit 1

//How many and time of restarts
aw_restarts "1 1 2"

//Only count kills as frags ; 1= yes, = no
aw_onlykillfrags 1

//The number of players ready needed to start match and default parameter for awmenu
aw_minready_default 5

//Type of game to be used for match and default parameter for awmenu
aw_gametype_default mr15

//Config file for warmup session, must be in configs/amxwar/wmcfg/
aw_warmup_cfg "default.cfg"

//Config file for overtime session, must be in configs/amxwar/otcfg/
aw_overtime_cfg "default.cfg"

//Config file for knife round, must be in configs/amxwar/knifecfg/
aw_knife_cfg "default.cfg"

//Config file to be used after the match
aw_pubcfg "server.cfg"

//Config file to pause plugins for the duration of the match
aw_pdiscfg "pd.cfg"

//Config file to unpause plugins after the match
aw_penacfg "pe.cfg"

******************************************************************************
strings.ini tags:
******************************************************************************
Useable tags for string editing
some will format in english unfortunately, can be fixed in future versions

[nummaps]
"One map" or "Two map"

[players1] 
players on each team, formatted as value, ex. 5

[players2]
players on each team, formatted as ex. 5vs5

[gametype]
"Maxrounds", "Timelimit" or "Winlimit

[maxrounds1]
number of maxrounds, winlimit or timelimit, ex. 12

[maxrounds2]
same as 1, but will add "minutes" behind value if timelimit game

[matchmaps]
name of the maps played, separated by a comma

[team1]
name of team1

[team2]
name of team2

[team1rdy]
number between 0 and players on each team, for team1

[team2rdy]
number between 0 and players on each team, for team2

[team1score]
team1 total score

[team2score]
team2 total score

[team1halfscore]
team1 current half score

[team2halfscore]
team2 current half score

[team1mapscore]
team1 current map score
[team2mapscore]
team2 current map score

[periodinfo]
wich period we are in, each overtime adds one
if no overtime this formats as " " (one space),
else: " OT 3 " for example (note the spaces)

[team1side]
"Counter-Terrorist" or "Terrorist"

[team2side]
"Counter-Terrorist" or "Terrorist"

[playedmap]
"match" if only one map, else "1st map" or "2nd map"

[playedmap2]
"One", "1st" or "2nd"

[playedhalf]
"1st" or "2nd"

[lbrk]
Simple line break, don't use too many in one string, 4 lines is max

[begininfo]
"begin" if match starting first map, first round, first half
else "continue"

[startcountdown]
match start countdown timer, a number

[timer]
time remaining for timelimit games in format "mm:ss"
will format as " " (one space) for maxrounds and winlimit games

[pointsleft]
points left in round
ex. if in half1 of mr12 game and score is 7-2, there are 3 points left

[pointsleft2]
points left in match

[winningteam]
name of team that is winning

[losingteam]
name of team that is losing

[round1]
wich round of the game we are in

[round2]
wich round of the period

[round3]
wich round of the map

