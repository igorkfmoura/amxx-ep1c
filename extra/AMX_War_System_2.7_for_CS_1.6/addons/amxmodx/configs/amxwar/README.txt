******************************************************************************
amxwar.cfg:
******************************************************************************
// can games be tied? 0 = off, 1 = on 
// Может ли быть ничья? 0 = нет, играть Overtime, 1 = да
// maxrounds: if two map games then secondmaprules must be 3 or this has no effect
// timelimit: if two map games then secondmaprules must be >1 or this has no effect
aw_tie 0

// Сколько секунд будет отсчитывать счетчик до старта матча, когда все написали ready или админ сделал autostart
aw_countdowntime 0

//Режим выбора начальных сторон (0=Team1 CT, Team2 TER;1=Cointoss;2=Knife round)
aw_assign_mode 0

//Перекидывать игроков за нужную сторону (CT, TER) автоматически? 1 = да, 0 = нет
aw_autoteam 1

//Разрешать писать ready только игрокам с клантагом
aw_clantagcheck 0

//Как делать скриншоты на клиентах: 0 = не записывать, 1 = не спрашивать, снимать автоматически, 2 = спросить клиентов
aw_screenshots 0

//Как записывать демки на клиентах: 0 = не записывать, 1 = не спрашивать, записывать автоматически, 2 = спросить клиентов
aw_demos 0

// настройка hltv, -1 для отключения записи hltv или adminpassword из hltv.cfg для влючения записи hltv
aw_hltv_passw 123

//Если игрок вылетает с сервера, проверять ли присоединяющегося юзера на соответсвие его IP адреса с IP адресом вылетевшего игрока? 1=да, 0=нет
//Если стоит 1, то на сервер никто не сможет зайти, кроме вылетевших игроков
aw_check_ip 0

//Если игрок вылетает с сервера, проверять ли присоединяющегося юзера на соответсвие его имени с именем вылетевшего игрока? 1=да, 0=нет
//Если стоит 1, то на сервер никто не сможет зайти, кроме вылетевших игроков
aw_check_name 0

//Возвращать вылетевшему игроку во время матча при возвращении на сервер денги.
//Проверять игрока по (0=не возвращать денег, 1=любому совпадению имени или ИП адреса, 2=ИП, 3=имени, 4=требовать совпадения и имени и ИП)

aw_return_money_by 1
//Менять команды местами автоматически? 0=нет, 1=да
aw_swapteams 1

//Колличество раундов в овертайме
//Set's how many rounds in overtime session (1 half)
aw_ot_rounds 3

//Ограничение на разминку в минутах (При 0 время на вармап неограничено)
aw_warmup_timelimit 1

//Колличество и время рестартов
aw_restarts "1 1 2"

//Не добавлять фраги за взорванную\разминированную бомбу ?
aw_onlykillfrags 1

//Кол-во игроков в команде которое будет использоваться по умолчанию при старте матча без параметров, а так же начальный параметр для awmenu
aw_minready_default 5

//Тип игры который будет использоваться по умолчанию при старте матча без параметров, а так же начальный параметр для awmenu
aw_gametype_default mr15

//Конфиг для warmup сессии, должен лежать в папке configs/amxwar/wmcfg/
aw_warmup_cfg "default.cfg"

//Конфиг для овертайма сессии, должен лежать в папке configs/amxwar/otcfg/
aw_overtime_cfg "default.cfg"

//Конфиг для knife раунда, должен лежать в папке configs/amxwar/knifecfg/
aw_knife_cfg "default.cfg"

//Конфиг сервера, который запуститься после матча
aw_pubcfg "server.cfg"

//конфиг со списком плагинов, которые будут отключены на время матча
aw_pdiscfg "pd.cfg"

//конфиг со списком плагинов, которые будут включены после матча
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

