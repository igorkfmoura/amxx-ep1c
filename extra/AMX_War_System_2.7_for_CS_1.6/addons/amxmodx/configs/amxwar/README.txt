******************************************************************************
amxwar.cfg:
******************************************************************************
// can games be tied? 0 = off, 1 = on 
// ����� �� ���� �����? 0 = ���, ������ Overtime, 1 = ��
// maxrounds: if two map games then secondmaprules must be 3 or this has no effect
// timelimit: if two map games then secondmaprules must be >1 or this has no effect
aw_tie 0

// ������� ������ ����� ����������� ������� �� ������ �����, ����� ��� �������� ready ��� ����� ������ autostart
aw_countdowntime 0

//����� ������ ��������� ������ (0=Team1 CT, Team2 TER;1=Cointoss;2=Knife round)
aw_assign_mode 0

//������������ ������� �� ������ ������� (CT, TER) �������������? 1 = ��, 0 = ���
aw_autoteam 1

//��������� ������ ready ������ ������� � ���������
aw_clantagcheck 0

//��� ������ ��������� �� ��������: 0 = �� ����������, 1 = �� ����������, ������� �������������, 2 = �������� ��������
aw_screenshots 0

//��� ���������� ����� �� ��������: 0 = �� ����������, 1 = �� ����������, ���������� �������������, 2 = �������� ��������
aw_demos 0

// ��������� hltv, -1 ��� ���������� ������ hltv ��� adminpassword �� hltv.cfg ��� �������� ������ hltv
aw_hltv_passw 123

//���� ����� �������� � �������, ��������� �� ����������������� ����� �� ����������� ��� IP ������ � IP ������� ����������� ������? 1=��, 0=���
//���� ����� 1, �� �� ������ ����� �� ������ �����, ����� ���������� �������
aw_check_ip 0

//���� ����� �������� � �������, ��������� �� ����������������� ����� �� ����������� ��� ����� � ������ ����������� ������? 1=��, 0=���
//���� ����� 1, �� �� ������ ����� �� ������ �����, ����� ���������� �������
aw_check_name 0

//���������� ����������� ������ �� ����� ����� ��� ����������� �� ������ �����.
//��������� ������ �� (0=�� ���������� �����, 1=������ ���������� ����� ��� �� ������, 2=��, 3=�����, 4=��������� ���������� � ����� � ��)

aw_return_money_by 1
//������ ������� ������� �������������? 0=���, 1=��
aw_swapteams 1

//����������� ������� � ���������
//Set's how many rounds in overtime session (1 half)
aw_ot_rounds 3

//����������� �� �������� � ������� (��� 0 ����� �� ������ ������������)
aw_warmup_timelimit 1

//����������� � ����� ���������
aw_restarts "1 1 2"

//�� ��������� ����� �� ����������\��������������� ����� ?
aw_onlykillfrags 1

//���-�� ������� � ������� ������� ����� �������������� �� ��������� ��� ������ ����� ��� ����������, � ��� �� ��������� �������� ��� awmenu
aw_minready_default 5

//��� ���� ������� ����� �������������� �� ��������� ��� ������ ����� ��� ����������, � ��� �� ��������� �������� ��� awmenu
aw_gametype_default mr15

//������ ��� warmup ������, ������ ������ � ����� configs/amxwar/wmcfg/
aw_warmup_cfg "default.cfg"

//������ ��� ��������� ������, ������ ������ � ����� configs/amxwar/otcfg/
aw_overtime_cfg "default.cfg"

//������ ��� knife ������, ������ ������ � ����� configs/amxwar/knifecfg/
aw_knife_cfg "default.cfg"

//������ �������, ������� ����������� ����� �����
aw_pubcfg "server.cfg"

//������ �� ������� ��������, ������� ����� ��������� �� ����� �����
aw_pdiscfg "pd.cfg"

//������ �� ������� ��������, ������� ����� �������� ����� �����
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

