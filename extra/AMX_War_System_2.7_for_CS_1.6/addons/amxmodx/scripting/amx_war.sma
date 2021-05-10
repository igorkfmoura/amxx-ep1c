/*	AMX Clanwar system 1.4b5 by Grisbilen, Niro edition (2.7)
2.7	-Исправлена ошибка с неперекидыванием за нужную сторону после кнайф раунда
	-Изменено меню выбора стороны после кнайфа, 1. Terrorists, 2. Counter-terrorists

2.6	-Исправлена ошибка зависания сервера под Linux при вызове awmenu, 
	 спасибо max_rip за то, чот нашел ошибку, Seazon за тестирование
	-Добавлено остановление демки перед началом записи на хлтв

2.5	-Исправлена ошибка: если в имени игрока содержиться точка то POV демка пишеться без .dem
	-Плагин сам узнает какой нужен hltv_rec_delay
	-При вызове меню анализируются ники игроков с клантагами в clans.ini, при совпадении, клантаг вставляется в меню
	 удобно, когда много клантагов не нужно по 10 раз щелкать по кнопкам 1 и 2 в поисках нужного
	-Добавлено в меню настроек Only kill frags
	-Исправлена ошибка с отображением в меню настроек 2х последних переменных
	-Исправлена ошибка с ready во второй половине матча

2.4	-Исправлена ошибка: матч не запускался со всеми параметрами из-за переполнение массива
	 увеличен размер массива для парсинга парамтров
	-HLTV говорит свое реальное состояние, например Recording initialized или Already recording initialized for ....
	-Исправлена ошибка: некорретно работало восстановление матча

2.3:	-awrestart делает рестарт карты
	-awrestart2 делает рестарт текущей половинки
	
2.2:	-Исправлена функция перекидывания игрока за другую команду, использован код из плагина amx match deluxe
	-За разминирование бомбы или за взрыв не добавляются фраги если aw_onlykillfrags 1
	-Изменен формат имен клиентских демок: team1-vs-team2-map-YearMonsDay_Hour-Min_POV(name)

2.1:
	-Вылетевшим игрокам восстанавливается оружие,патроны в оружии, патроны в запасных обоймах, гранаты и щипцы
	 Если матч обрывается из-за падения сервера, после восстановления матча игрокам возвращается абсолютно всё,
	 что у них было в начале раунда(фраги,смерти,броня,деньги,оружие,патроны,гранаты,щипцы), на котором сервер упал
	-В меню настроек добавлен пункт сохранить amxwar.cfg
	-Добавлена клиентская команда say captain, набрав которую игрок становится капитаном команды
	-Параметр aw_restart задает колличество и время рестартов
	 например aw_restart "1 1 2 2 3 4 5" сделает 7 рестартов: 1сек-1сек-2сек-2сек-3сек-4сек-5секунд
	 по дефолту стоит aw_restart "1 2 3"
	 
2.0:
	-Конфиги плагина перенесены в amxmodx/configs/amxwar
	-Все переменные awc_ переименованы в aw_
	-Полностью отключена поддержка SQL
	-Убрано отключение тактического щита плагином, прописывайте в конфигах amx_restrict on shield
	-Исправлена ошибка: HLTV не всегда инициализируется
	-Исправлена ошибка: при вызове awmenu виснет сервак на линухе
	-В меню добавлена возможность изменять aw_ot_rounds и aw_warmup_timelimit
	-Матч можно запускать, указывая опциональные параметры в любом порядке, 
	 например aw team1 team2 cfg=cpl.cfg 2
	 В данном случае запустится матч с параметром minready=2
	 Конфиги можно указывать без .cfg
	-Запрещен доступ к aw пока демка на хлтв не допишеться
	-в strings.ini теперь можно указывать координаты и цвет сообщений
	-Автостарт матча, если вармап длиться дольше чем прописано в aw_warmup_timelimit
	-Добавлен кнайф раунд, aw_assign_mode отвечает за режим выбора сторон, 0 оставить как есть, 1 бросить монетку, 2 кнайф
	 Матч запускается как обычно командой aw, после победы 1й из команд, игроку команды с наименьшим id показывается меню
	 с выбором стороны, цт или тер.
	-После каждого раунда в файл записывается статистика по игрокам(фраги,смерти,деньги)
	 Если сервер "упадет", то после его запуска, начнеться оборванный матч с тем счетом на котором он оборвался
	 Всем игрокам после 3 рестартов вернуться фраги,смерти и деньги
	 Пример: Если на 7м раунде сервак падает при счете 2-4, то после включения автоматически запускается матч 
	 со счетом 2-4, запускается вармап чтобы дождаться готовности всех игроков для продолжения матча
	 Режим игры Timelimit не поддерживается

1.6.1:
	-Исправлена ошибка: Не убиралась надпись CT: и TERRORIST: когда все готовые писали notready
	-В строке готовых заголовок CT и TERRORIST заменены на CTs и TERs
	-Исправлена ошибка: Не убирался ник игрока написавшего реди при его дисконекте

1.6:
	-Когда делается аборт матча, запись демки останавливается сразу же
	-Исправлена ошибка: На Вармапе список готовых игроков теперь не сбивает надпись сверху о состаянии матча
	-Исправлена ошибка: не очищается список написавших ready перед вторым вармапом
	-Исправлена ошибка: нет задержки перед смены команд местами
	-Исправлена ошибка: после броска монетки (cointoss 1) игроков перекидывало за неправильную сторону
	-Переделана функция смены команд местами. Модели игроков всегда соответсвуют выбранному! Модель можно снова выбирать.
	-Если aw_clantagcheck 1, то список написавших реди состоит только из ников без клантагов.
	Разделителем обязательно должен быть символ | или пробел
	-Клантаг разрешается использовать в начале или конце имени
	-Cointoss вродебы теперь работает корректно

1.5.4b7
Изменения:
	-Возвратившемуся игроку на сервер во время матча возвращаются фраги и смерти

1.5.4b6
Изменения:
	-Отображается список игроков, написавших ready

1.5.4b5
Изменения:
	-Исправлена ошибка с конфигом овертайма
	-Исправлена ошибка с неверными моделями при смене сторон (Всем игрокам cl_minmodels 1, модель выбирать нельзя)
	-Добавлена задержка в 3 секунды перед принудительной сменой команд местами после 1й половины

1.5.4b4
Изменения:
	-Управлением HLTV теперь занимается модуль sockets, про udp.dll (udp.so) можно забыть

1.5.4b3
Изменения:
	-Исправлена ошибка, вармап запускался 2 раза
	-Уменьшена пауза, после старта команды aw или amxwar, вармап начинается практически сразу после команды
	-Для команд aw, amxwar, awstart, awabort, awhltv запускаемых из консоли сервера показываются подсказки при неправильном вводе параметров, как это сделано на клиенте
	-Введена переменная aw_ot_rounds задающая колличество раундов в овертайме

1.5.3b8 - 1.5.4b2 not worked!!!

1.5.3b7
Изменения:
	-параметр "aw_warmup_cfg" указывает имя конфига, который будет извлекаться в начале warmup'a
	-теперь матч можно запускать без обязательного указания параметров minready и gametype, например: amxwar SK Virtus.pro, в этом случае вместо minready подставиться значение из aw_minready_default, вместо gametype - aw_gametype_default
	-exec amxwar/amxwar.cfg после каждого матча, теперь для обновления настроек не требуется перезагрузка плагина
	-"aw_minready_default" и "aw_gametype_default" также определяют начальные значения в awmenu

1.5.3b6
Изменения:
	-В меню опций (awmenu 4) теперь можно изменять переменные: aw_hltv_rec_delay, aw_check_ip, aw_check_name, aw_return_money_by, aw_swapteams

1.5.3b5
Изменения:
	-Исправлена ошибка: после броска монеты за выбор сторон за которые команды начнут играть, 
	переменные не сбрасывались на дефолтные значения, поэтому запуская следущий матч без броска монеты 
	команды распределялись по результату последнего броска. Поэтому иногда запуская amxwar team1 team2 5 mr15 de_dust2, 
	ожидая увидеть team1 на месте counter-terrorist'ов видим на самом деле team2
	-amxwar теперь можно запускать без параметра map1 в этом случае матч начнется на текущей карте

1.5.3b4
Изменения:
	-Добавлено aw_swapteams (0=не менять команды местами, 1=менять)
	-return_money_by переименовано в aw_return_money_by
	-Компилиться под любой версией AMX Mod X
	-addons\plugins\amxwar перенесена в amxwar, для совместимости плагина с любым AMXModX. AMXModX 0.16=addons\amxx, AMXModX 0.20=addons\amxmodx
	-Устранена ошибка: awmenu запускало amxwar с лишним параметром, матч не начинался
	-aw_autoteam теперь работает

1.5.3b3
Изменения:
	-aw_hltw_rec_delay заменена на awс_hltv_rec_delay =)
	-Исправлена ошибка: функции amxwar, aw, awabort, awhltv, awstart не отображаются в amx_help в консоле сервера
	-Исправлена ошибка: awmenu не отображет один из кланов, невозвожно начать матч. Ошибка исправлена за счет отключения автоопределения кланов, сможете начать матч только с теми командами которые прописаны в clans.ini, автоматически новые таги кланов добавляться туда не будут

1.5.3b2
Изменения:
	-aw_check_ip (1=проверять, 0=нет). Если игрок вылетает с сервера, проверять ли присоединяющегося юзера на соответсвие его IP адреса с IP адресом вылетевшего игрока?
	-aw_check_name (1=проверять, 0=нет). Аналогично только проверка по имени
	-Вылетевшему игроку во время матча, снова зашедшему на сервер возвращаются деньги которые были перед дисконнектом
	-Исправлена ошибка с незаписью hltv демо если в имени однго из играющих кланов присутсвует пробел

1.5.3b1:
Изменения:
	-Добавлена задержка записи hltv demo: aw_hltv_rec_delay
	-Демки записываются в отдельный каталог cstrike\Demos
	-Исправлена ошибка с неверным расширением файла демки записывающейся на клиенте
	-В OverTime загружается конфиг addons\amxmodx\plugins\amxwar\otcfg\default.cfg
	-Добавлен автоматический запуск плагина restmenu.amx на случай его незапуска перед выполнением команды запрета тактического щита
	-aw_screenshot (0-не делать скриншот,1-принудительный скриншот без согласия клиента,2-клиент решает сам)
*/

#define HLTV_SUPPORT
//#define DEBUG

#include <amxmodx>
#include <amxmisc>
#include <float>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <engine>

#if defined HLTV_SUPPORT
#include <sockets>
#endif

#define MENU_MIN_TAGLENGTH 2 // Minimum tag length (equal letters) for a clan to be autodetected
#define MENU_MIN_TAGNUMBER 2 // Minimum number of players sharing a tag required to autodetect a clan

new AW_VERSION[] = "2.7"

new rounds, totrounds, gametype, wichmap, map2[32], map1[32]
new war_live, warauto, half_active, period_number, war_password[64], war_config[64]
new war_countdowntimer,tl_start
new t1startside = 0, t2startside = 1 // team1 as ct & team2 as t by default
new p_ready[2],minready
new t_name[2][32],t_score[2][3],pl_rec[32],pl_recnum = 0
new readyplayers[32][2],readyplayersnum
new logfile[64], statsfile[64], matchcfgfile[64], client_demoname[128], cfgdir[128]

new disc_pl_ip[32][16], disc_pl_name[32][64], disc_pl_count=0
new disc_pl_deaths[32], disc_pl_frags[32], disc_pl_money[32]
new disc_pl_armor[32][2], disc_pl_defuse[32], disc_pl_Weapons[32][32], disc_pl_numWeapons[32]
new disc_pl_clip[32][32], disc_pl_ammo[32][32], returned_players_num=0, returned_players[32][2]
new sm_page=0	

// Infotext hack, pretty lame but i'm lazy
new mi[3][] = { "match", "1st map", "2nd map" }
new mi2[3][] = { "One", "1st", "2nd" }
new hi[6][] = { "", "1st", "1st", "2nd", "2nd", "" }
new nm[3][] = { "One map", "Two map", "Two map" }
new gt[6][] = { "Maxrounds", "Maxrounds", "Maxrounds", "Timelimit", "Timelimit", "Winlimit" }
new whosready[2][256]

// HLTV
new hltv_address = -1
#if defined HLTV_SUPPORT
new hltv_id,hltv_ip[16],hltv_port,hltv_pass[32],hltv_recording, hltv_rec_delay = 30
#endif

// Menu
new clans[64][32],num_clans,maps[32][32],num_maps,menu_maxrounds = 15,menu_minready = 5
new clan1_toshow = 0,clan2_toshow = 1,map1_toshow = 1,map2_toshow = 0,menu_gametype[6] = "mr"
new cfgs[64][32],num_cfgs = 0,cfg_toshow = 0

//Match Staus
new knife_active, captain_id[2] = {0, 0}, match_restored = 0, assigned = 0
new cplayer
// ============================================================================
// ============================= MISC FUNCTIONS ===============================
// ============================================================================

// formats strings from strings.ini, result will be in textblock string, returns time from strings.ini
public war_parsestrini(tofind[],textblock[1024],mode,&r,&g,&b,&Float:x, &Float:y,&eff){
	new inifile[64]
	format(inifile,63,"%s/strings.ini",cfgdir)
	if (!file_exists(inifile)) return -1
	new text[1024], len, end, timetmp[8], pos = 0, tmp[32], i, j
	while(read_file(inifile,pos++,text,1023,len)) {
		if (contain(text,tofind) == 0) {
			len = contain(text,"=")
			if(len == -1) return -1
  		        for(i=len+1;i<strlen(text);i++) textblock[i-len-1] = text[i];textblock[i-len-1]=0
			
			if(mode==0)
			{
				len = contain(text,"(")
				end = contain(text,")")
				if((end > len+4) || (end <= len+1)) return -1
				for(i=len+1;i<end;i++) timetmp[i-(len+1)] = text[i]
				if(str_to_num(timetmp) == 0) return 0
			}
			else
			{
			      len = contain(text,"[")
			      for(i=len+1;text[i]!=',';i++) tmp[i-len-1] = text[i]; tmp[i-len]=0; r = str_to_num(tmp)
			      for(i=i+1,j=0;text[i]!=',';i++,j++) tmp[j] = text[i]; tmp[j]=0; g = str_to_num(tmp)
			      for(i=i+1,j=0;text[i]!=',';i++,j++) tmp[j] = text[i]; tmp[j]=0; b = str_to_num(tmp)
			      for(i=i+1,j=0;text[i]!=',';i++,j++) tmp[j] = text[i]; tmp[j]=0; x = floatstr(tmp)
			      for(i=i+1,j=0;text[i]!=',';i++,j++) tmp[j] = text[i]; tmp[j]=0; y = floatstr(tmp)
			      for(i=i+1,j=0;text[i]!=',';i++,j++) tmp[j] = text[i]; tmp[j]=0; eff = str_to_num(tmp)
			      for(i=i+1,j=0;text[i]!=']';i++,j++) timetmp[j] = text[i]; timetmp[j]=0
			      if(str_to_num(timetmp) == 0) return 0				
			}
			// tag replacing begins here
			while(contain(textblock,"[lbrk]") != -1) replace(textblock,1023,"[lbrk]","^n")
			while(contain(textblock,"[team1]") != -1) replace(textblock,1023,"[team1]",t_name[0])
			while(contain(textblock,"[team2]") != -1) replace(textblock,1023,"[team2]",t_name[1])
			while(contain(textblock,"[nummaps]") != -1) replace(textblock,1023,"[nummaps]",nm[wichmap])
			while(contain(textblock,"[players1]") != -1) { new tmp[4]; num_to_str(minready,tmp,3); replace(textblock,1023,"[players1]",tmp); }
			while(contain(textblock,"[players2]") != -1) { new tmp[8]; format(tmp,7,"%ivs%i",minready,minready); replace(textblock,1023,"[players2]",tmp); }
			while(contain(textblock,"[myname]") != -1) replace(textblock,1023,"[myname]","Admin")
			while(contain(textblock,"[gametype]") != -1) replace(textblock,1023,"[gametype]",gt[gametype])
			while(contain(textblock,"[maxrounds1]") != -1) { new tmp[4]; num_to_str(rounds,tmp,3); replace(textblock,1023,"[maxrounds1]",tmp); }
			while(contain(textblock,"[maxrounds2]") != -1) { new tmp[16]; format(tmp,15,"%i%s",rounds,((gametype == 3) || (gametype == 4)) ? " min" : ""); replace(textblock,1023,"[maxrounds2]",tmp); }
			while(contain(textblock,"[matchmaps]") != -1) {
				new tmp[64], curmap[32]
				get_mapname(curmap,32)
				format(tmp,63,"%s%s%s",curmap,(wichmap == 1) ? ", " : "",(wichmap == 1) ? map2 : "")
				replace(textblock,1023,"[matchmaps]",tmp)
			}
			while(contain(textblock,"[startcountdown]") != -1) { new tmp[4]; num_to_str(war_countdowntimer,tmp,3); replace(textblock,1023,"[startcountdown]",tmp); }
			while(contain(textblock,"[timer]") != -1) {
				new tl[8] = " "
				if((gametype == 3) || (gametype == 4))
					if(half_active) { new tl_rem = (floatround(get_gametime())-(tl_start+rounds*60))*(-1); format(tl,7,"%i%s%i",(tl_rem-(tl_rem%60))/60,(tl_rem%60 < 10) ? ":0" : ":",tl_rem%60); }
					else format(tl,7,"%i:00",rounds)
				replace(textblock,1023,"[timer]",tl)
			}
			while(contain(textblock,"[playedmap]") != -1) replace(textblock,1023,"[playedmap]",mi[wichmap])
			while(contain(textblock,"[playedmap2]") != -1) replace(textblock,1023,"[playedmap2]",mi2[wichmap])
 			while(contain(textblock,"[playedhalf]") != -1) replace(textblock,1023,"[playedhalf]",hi[war_live])
			while(contain(textblock,"[team1rdy]") != -1) { new tmp[4]; num_to_str(p_ready[0],tmp,3); replace(textblock,1023,"[team1rdy]",tmp); }
			while(contain(textblock,"[team2rdy]") != -1) { new tmp[4]; num_to_str(p_ready[1],tmp,3); replace(textblock,1023,"[team2rdy]",tmp); }
			while(contain(textblock,"[team1score]") != -1) { new tmp[4]; num_to_str(t_score[0][0],tmp,3); replace(textblock,1023,"[team1score]",tmp); }
			while(contain(textblock,"[team2score]") != -1) { new tmp[4]; num_to_str(t_score[1][0],tmp,3); replace(textblock,1023,"[team2score]",tmp); }
			while(contain(textblock,"[team1mapscore]") != -1) { new tmp[4]; num_to_str(t_score[0][1]+t_score[0][2],tmp,3); replace(textblock,1023,"[team1mapscore]",tmp); }
			while(contain(textblock,"[team2mapscore]") != -1) { new tmp[4]; num_to_str(t_score[1][1]+t_score[1][2],tmp,3); replace(textblock,1023,"[team2mapscore]",tmp); }
			while(contain(textblock,"[team1halfscore]") != -1) { new tmp[4]; if(war_live < 3) num_to_str(t_score[0][1],tmp,3); else num_to_str(t_score[0][2],tmp,3); replace(textblock,1023,"[team1halfscore]",tmp); }
			while(contain(textblock,"[team2halfscore]") != -1) { new tmp[4]; if(war_live < 3) num_to_str(t_score[1][1],tmp,3); else num_to_str(t_score[1][2],tmp,3); replace(textblock,1023,"[team2halfscore]",tmp); }
			while(contain(textblock,"[team1side]") != -1) { if(war_live > 2) replace(textblock,1023,"[team1side]",(t1startside == 0) ? "Terrorist" : "Counter-Terrorist"); else replace(textblock,1023,"[team1side]",(t1startside == 1) ? "Terrorist" : "Counter-Terrorist"); }
			while(contain(textblock,"[team2side]") != -1) { if(war_live > 2) replace(textblock,1023,"[team2side]",(t2startside == 0) ? "Terrorist" : "Counter-Terrorist"); else replace(textblock,1023,"[team2side]",(t2startside == 1) ? "Terrorist" : "Counter-Terrorist"); }
			while(contain(textblock,"[periodinfo]") != -1) {
				new tmp[32]
				if(period_number > 0) format(tmp,31," OT %i ",period_number)
				else format(tmp,31," ",period_number)
				replace(textblock,1023,"[periodinfo]",tmp)
			}
			while(contain(textblock,"[begininfo]") != -1) { if((war_live == 1) && (period_number == 0) && (wichmap < 2)) replace(textblock,1023,"[begininfo]","begin"); else replace(textblock,1023,"[begininfo]","continue"); }
			while(contain(textblock,"[pointsleft]") != -1) { new tmp[4] = ""; if((half_active == 1) && (gametype != 5)) num_to_str(rounds-(t_score[0][war_live/2]+t_score[1][war_live/2]),tmp,3); replace(textblock,1023,"[pointsleft]",tmp); }
			while(contain(textblock,"[pointsleft2]") != -1) { 
				new tmp[4] = ""
				if(gametype < 3) {
					if(wichmap == 0) i = (rounds * 2) - (t_score[0][0]+t_score[1][0])
					else i = (rounds * 4) - (t_score[0][0]+t_score[1][0])
					num_to_str(i,tmp,3)
				}
				replace(textblock,1023,"[pointsleft2]",tmp)
			}
			while(contain(textblock,"[winningteam]") != -1) {
				if(t_score[0][0] >= t_score[1][0]) replace(textblock,1023,"[winningteam]",t_name[0])
				else replace(textblock,1023,"[winningteam]",t_name[1])
			}
			while(contain(textblock,"[losingteam]") != -1) {
				if(t_score[0][0] >= t_score[1][0]) replace(textblock,1023,"[losingteam]",t_name[1])
				else replace(textblock,1023,"[losingteam]",t_name[0])
			}
			while(contain(textblock,"[round1]") != -1) { new tmp[4]; num_to_str(t_score[0][0]+t_score[1][0]+1,tmp,3); replace(textblock,1023,"[round1]",tmp); }
			while(contain(textblock,"[round2]") != -1) { new tmp[4]; num_to_str(t_score[0][war_live/2]+t_score[1][war_live/2]+1,tmp,3); replace(textblock,1023,"[round2]",tmp); }
			while(contain(textblock,"[round3]") != -1) { new tmp[4]; num_to_str(t_score[0][1]+t_score[1][1]+t_score[0][2]+t_score[1][2]+1,tmp,3); replace(textblock,1023,"[round3]",tmp); }
			// and ends here

			return str_to_num(timetmp)
		}
	}
	return -1
}

//displays text on hud
public war_hudtext(id,tofind[],maxtime,mintime,screen){
	new textblock[1024]
	new r,g,b,eff, Float:x, Float:y
	new time = war_parsestrini(tofind,textblock,1,r,g,b,x,y,eff)
#if defined DEBUG
	if(time>1) server_print("%s",textblock)
#endif
	if(time == 0) return mintime //string disabled in strings.ini
	else if(time == -1) { log_to_file(logfile,"strings.ini error, infostring ^"%s^" not shown, check if string exist in strings.ini",tofind); return mintime; } //string not found
	else if(time == 1) time = 2
	else if((time < mintime) || (time > maxtime)) { log_to_file(logfile,"strings.ini error, infostring ^"%s^" not shown, check stringtime in strings.ini",tofind); return mintime; } //string time is wrong
	set_hudmessage(r,g,b,x,y, eff, 6.0, float(time), 0.2, 0.2, screen)
	show_hudmessage(id,textblock)
	return time
}

//displays text on client
public war_clienttext(textstring[],id){
	new textblock[1024], tmp[4], Float: tmp_f[2]
	new x = war_parsestrini(textstring,textblock,0,tmp[0],tmp[1],tmp[2],tmp_f[0],tmp_f[1],tmp[3])
#if defined DEBUG
	server_print("%s",textblock)
#endif
	if(x == -1) log_to_file(logfile,"strings.ini error, clientstring ^"%s^" not shown",textstring)
	else if(x == 1) client_print(id,print_chat,textblock)
	else if(x == 2) client_print(id,print_console,textblock)
	return PLUGIN_CONTINUE
}

//displays text on server											
public war_servertext(textstring[]){
	new textblock[1024], tmp[6], Float: tmp_f[2]
	new x = war_parsestrini(textstring,textblock,0,tmp[0],tmp[1],tmp[2],tmp_f[0],tmp_f[1],tmp[3])
	if(x == -1) log_to_file(logfile,"strings.ini error, clientstring ^"%s^" not shown",textstring)
	else if(x == 1) server_print(textblock)
	else if(x == 2) server_print(textblock)
	return PLUGIN_CONTINUE
}

// restarts round in time
public r_r(time[]){
#if defined DEBUG
	server_print("* r_r(%s)",time)
#endif
	set_cvar_num("sv_restartround", str_to_num(time))
	return PLUGIN_CONTINUE
}

// takes scoreboard screenshot on clients
public war_ss2(id[]) client_cmd(id[0],"snapshot")
public war_ss3(id[]) client_cmd(id[0],"-showscores")

public war_ss(){	
#if defined DEBUG
	server_print("* war_ss()")
#endif
	war_fixcvar("aw_screenshots",0,2)						
	if(get_cvar_num("aw_screenshots") == 0) return PLUGIN_CONTINUE			
	new menu_body[512]
	new keys = (1<<0)|(1<<1)
	format(menu_body,511,"\yScreenshot^n\dDo you wish to take a scoreboard^nscreenshot?^n^n\w1. Yes^n2. No")
	new players[32],num_players,i

	get_players(players,num_players,"ce", "CT")
	for(i=0;i<num_players;i++)
	{
		if(get_cvar_num("aw_screenshots") == 1) war_ss_action(players[i],0)
		else show_menu(players[i],keys,menu_body)
	}

	get_players(players,num_players,"ce", "TERRORIST")
	for(i=0;i<num_players;i++) 
	{
		if(get_cvar_num("aw_screenshots") == 1) war_ss_action(players[i],0)
		else show_menu(players[i],keys,menu_body)
	}
	return PLUGIN_CONTINUE
}

public war_ss_action(id,key){
#if defined DEBUG
	server_print("* war_ss_action(%d, id)",id, key)
#endif
	new params[1]
	params[0] = id
	switch(key) 
	 {
		case 0: 
		 {
			client_cmd(id,"+showscores")
			
			set_task(0.3,"war_ss2",0,params,1)
			set_task(0.6,"war_ss3",0,params,1)
		 }
	}
	if(war_live == 5) {
		war_demo_off()
	}
	return PLUGIN_HANDLED
}

public war_demo(){
#if defined DEBUG
	server_print("* war_demo()")
#endif
	war_fixcvar("aw_demos",0,2)
	if(get_cvar_num("aw_demos") == 0) return PLUGIN_HANDLED
	new menu_body[512],curmap[32],time_date[32],players[32],num_players,i,playerteam[16],name[64]
	new keys = (1<<0)|(1<<1)

	get_mapname(curmap,32) 
	get_time("%Y%m%d_%H-%M",time_date,32) 
	format(client_demoname,256,"%s-vs-%s_%s_%s",t_name[0],t_name[1],curmap,time_date) 
	while(replace(client_demoname,64,"/","-")) {}
	while(replace(client_demoname,64,"\","-")) {}
	while(replace(client_demoname,64,":","-")) {}
	while(replace(client_demoname,64,"*","-")) {}
	while(replace(client_demoname,64,"?","-")) {}
	while(replace(client_demoname,64,">","-")) {}
	while(replace(client_demoname,64,"<","-")) {}
	while(replace(client_demoname,64,"|","-")) {}
	while(replace(client_demoname,64,".","-")) {}

	get_players(players,num_players,"c")
	for(i=0;i<num_players;i++) {
		get_user_team(players[i],playerteam,15)
		if((equal(playerteam,"CT")) || (equal(playerteam,"TERRORIST"))) {
			get_user_name(players[i],name,63)
			while(replace(name,64,"/","-")) {}
			while(replace(name,64,"\","-")) {}
			while(replace(name,64,":","-")) {}
			while(replace(name,64,"*","-")) {}
			while(replace(name,64,"?","-")) {}
			while(replace(name,64,">","-")) {}
			while(replace(name,64,"<","-")) {}
			while(replace(name,64,"|","-")) {}
			while(replace(name,64,".","-")) {}
			
			if(get_cvar_num("aw_demos") == 2)
			{
				format(menu_body,511,"\yRecord Demo^n\dDo you wish to record a demo of this game to:^n%s_POV(%s).dem?^n^n\w1. Yes^n2. No",client_demoname,name)
				show_menu(players[i],keys,menu_body) //ask if client wants to record demo
			}
			else if(get_cvar_num("aw_demos") == 1) //autorecord
			{
				client_cmd(players[i],"stop;record ^"%s_POV(%s)^"",client_demoname,name)
				pl_rec[pl_recnum] = players[i]
				pl_recnum++
			}
		}
	}
	return PLUGIN_HANDLED
}

public war_demo_action(id,key){
#if defined DEBUG
	server_print("* war_demo_action(%d, %d)",id,key)
#endif
	if(key == 0) {
		new name[64]
		get_user_name(id,name,63)
		while(replace(name,64,"/","-")) {}
		while(replace(name,64,"\","-")) {}
		while(replace(name,64,":","-")) {}
		while(replace(name,64,"*","-")) {}
		while(replace(name,64,"?","-")) {}
		while(replace(name,64,">","-")) {}
		while(replace(name,64,"<","-")) {}
		while(replace(name,64,"|","-")) {}
		client_cmd(id,"stop;record ^"%s_POV(%s)^"",client_demoname,name)
		pl_rec[pl_recnum] = id
		pl_recnum++
	}
	return PLUGIN_HANDLED
}

public war_demo_off(){
#if defined DEBUG
	server_print("* war_demo_off()")
#endif
	war_fixcvar("aw_demos",0,2)
	new menu_body[512]
	new keys = (1<<0)|(1<<1)
	format(menu_body,511,"\yStop Recording^n\dDo you wish to stop demorecording now?^n^n\w1. Yes^n2. No")
	for(new i=0;i<pl_recnum;i++) {
		if(get_cvar_num("aw_demos") == 2) show_menu(pl_rec[i],keys,menu_body) //ask to stop recording
		else if(get_cvar_num("aw_demos") == 1) client_cmd(pl_rec[i],"stop") //autostop
	}
	pl_recnum = 0
	return PLUGIN_HANDLED
}

public war_demo_off_action(id,key){
#if defined DEBUG
	server_print("* war_demo_off_action(%d, key)",id,key)
#endif
	switch(key) {
		case 0: client_cmd(id,"stop")
	}
	return PLUGIN_HANDLED
}


// transfers players to the correct team ()
public war_teamplayers(){
#if defined DEBUG
	server_print("* war_teamplayers()")
#endif
	if ((war_live != 1) && (war_live != 3)) return PLUGIN_CONTINUE

	new name[64], i, players[32], num_players

	get_players(players,num_players,"e", "CT")
	for(i=0;i<num_players;i++) 
	 {
		get_user_name(players[i], name, 63)
		if(war_live==1)
		 {
		   if((t1startside==0)&&(containi(name,t_name[1])!=-1)) swap(players[i], 1)
		   if((t1startside==1)&&(containi(name,t_name[0])!=-1)) swap(players[i], 1)
		 }
		else if(war_live==3)
		 {
		    if((t1startside==0)&&(containi(name,t_name[0])!=-1)) swap(players[i], 1)
		    if((t1startside==1)&&(containi(name,t_name[1])!=-1)) swap(players[i], 1)
		 }
	 }
	get_players(players,num_players,"e", "TERRORIST")
	for(i=0;i<num_players;i++) 
	 {
		get_user_name(players[i], name, 63)
		if(war_live==1)
		 {
		   if((t1startside==1)&&(containi(name,t_name[1])!=-1)) swap(players[i], 0)
		   if((t1startside==0)&&(containi(name,t_name[0])!=-1)) swap(players[i], 0)
		 }
		else if(war_live==3)
		 {
		    if((t1startside==1)&&(containi(name,t_name[0])!=-1)) swap(players[i], 0)
		    if((t1startside==0)&&(containi(name,t_name[1])!=-1)) swap(players[i], 0)
		 }
	 }
	return PLUGIN_CONTINUE
}





public swap(id,team) {
#if defined DEBUG
	server_print("* swap(%d, %d)",id, team)
#endif

	new vgui[10];

	get_user_info(id,"_vgui_menus",vgui,9)

	user_kill(id,1)
	client_cmd(id,"setinfo _vgui_menus 0;wait;wait;wait;chooseteam;wait;wait;wait;menuselect %d;wait;wait;wait;menuselect 5;wait;wait;wait;menuselect 0;wait;wait;wait;menuselect 5",(team == 1) ? 1 : 2)
	client_cmd(id,"wait; wait; wait; wait; wait; wait; slot10; wait; wait; wait; wait; wait; slot10;")
	if ( str_to_num(vgui) == 1 )
	{
		client_cmd(id,"setinfo _vgui_menus 1");
	}
	return PLUGIN_CONTINUE
}

public swap_teams(){
#if defined DEBUG
	server_print("* swap_teams()")
#endif
	new playersCT[32]
	new playersT[32]
	new nbrCT,nbrT
	get_players(playersCT,nbrCT,"e","CT")
	get_players(playersT,nbrT,"e","TERRORIST")
	r_r("1")
	for(new i = 0; i < nbrCT; i++) {
			swap(playersCT[i], 1)
	}

	for(new i = 0; i < nbrT; i++) {
			swap(playersT[i], 0)
	}
	//r_r("1")

	return PLUGIN_CONTINUE
}

// this will ensure that cvar is between val_min and val_max, cvar is numerical
public war_fixcvar(cvar[],val_min,val_max){
#if defined DEBUG
	server_print("* war_fixcvar(%s, %d, %d)",cvar,val_min,val_max)
#endif
	if(get_cvar_num(cvar) < val_min) set_cvar_num(cvar,val_min)
	if(get_cvar_num(cvar) > val_max) set_cvar_num(cvar,val_max)
	return PLUGIN_CONTINUE
}

public war_swapnames(id){
	if(war_live == 0)
	{
		if(id!=0) war_clienttext("clt_abort",id); else war_servertext("clt_abort")
		return PLUGIN_HANDLED
	}
	if (id && !((get_user_flags(id) & ADMIN_LEVEL_A))) { 
		war_clienttext("clt_noaccess",id)
		war_servertext("clt_noaccess")
		return PLUGIN_HANDLED
	}
	new tmp[32]
	format(tmp, 31, "%s", t_name[0])
	format(t_name[0], 31, "%s", t_name[1])
	format(t_name[1], 31, "%s", tmp)
	return PLUGIN_HANDLED
}

// ============================================================================
// =================================== INIT ===================================
// ============================================================================

// fills rounds, totrounds & gametype with correct values according to inpstr
public war_formatgtype(inpstr[]){
#if defined DEBUG
	server_print("* war_formatgtype(%s)",inpstr)
#endif
	new tmp1[4],tmp2[4],i
	for(i=0;i<strlen(inpstr);i++)
		if(i<2) tmp1[i] = inpstr[i]
		else tmp2[i-2] = inpstr[i]
	rounds = str_to_num(tmp2)
	if(rounds < 2) return 0 //match must be at least 2 rounds/minutes
	totrounds = rounds
	if(equali(tmp1,"mr")) gametype = 0
	else if(equali(tmp1,"mx")) gametype = 1
	else if(equali(tmp1,"mz")) gametype = 2
	else if(equali(tmp1,"tl")) gametype = 3
	else if(equali(tmp1,"tx")) gametype = 4
	else if(equali(tmp1,"wl")) gametype = 5
	else return 0 // wrong gametype
	return 1
}

// this function gets called if amxwar changes map
public war_startmapchange(){
#if defined DEBUG
	server_print("* war_startmapchange()")
#endif
	new tmp_t1name[32],tmp_t2name[32],tmp_gametype[8],tmp_score1,tmp_score2,strtmp[32]
	new pos=0, text[1024], len, i

	server_cmd("exec %s", matchcfgfile)

	get_vaultdata("aws_team1",tmp_t1name,31)
	get_vaultdata("aws_team2",tmp_t2name,31)
	get_vaultdata("aws_map1",map1,31)
	if(vaultdata_exists("aws_map2")) get_vaultdata("aws_map2",map2,31)
	if(vaultdata_exists("aws_team1score")) {
		get_vaultdata("aws_team1score",strtmp,9)
		tmp_score1 = str_to_num(strtmp)
	}
	else tmp_score1 = -1
	if(vaultdata_exists("aws_team2score")) {
		get_vaultdata("aws_team2score",strtmp,9)
		tmp_score2 = str_to_num(strtmp)
	}
	else tmp_score2 = -1

	get_vaultdata("aws_currentmap",strtmp,9)
	wichmap = str_to_num(strtmp)

	get_vaultdata("aws_team1side",strtmp,9)
	if(wichmap == 2) { // 2nd map, team1 should start on the opposite side of map1
		t2startside = str_to_num(strtmp)
		if(t2startside == 1) t1startside = 0
		else t1startside = 1
	}
	else {
		t1startside = str_to_num(strtmp)
		if(t1startside == 1) t2startside = 0
		else t2startside = 1
	}

	get_vaultdata("aws_players",strtmp,9)
	minready = str_to_num(strtmp)

	get_vaultdata("aws_gametype",tmp_gametype,7)
	if(war_formatgtype(tmp_gametype) == 0) war_end(0)
	if(vaultdata_exists("aws_password")) get_vaultdata("aws_password",war_password)
	else format(war_password,63,"NOTHING")
#if defined DEBUG
	server_print("war_password = %s", war_password)
#endif
	get_vaultdata("aws_config",war_config)

	new hostname[64]
	get_cvar_string("hostname",hostname,63) 

   	if(file_exists(statsfile))
	 {
	    tmp_score1=0;tmp_score2=0
	    match_restored = 1
	    while(read_file(statsfile,pos++,text,1023,len)) 
	     if(strlen(text)>1)
	      {
		if (contain(text,"war_live=") == 0) 
		 {
		   replace(text,1023,"war_live=","")
		   for(i=0;i<strlen(text);i++) strtmp[i]=text[i]
		   strtmp[i]=0
		   if(str_to_num(strtmp)==4)
		    {
		      if(t1startside == 0) {t1startside = 1;t2startside = 0;}
		      else {t1startside = 0;t2startside = 1;}
		    }
		   war_live = str_to_num(strtmp) - 1
		 }
		else if(contain(text,"t1score=") == 0)
		 {
		   replace(text,1023,"t1score=","")
		   for(i=0;i<strlen(text);i++) strtmp[i]=text[i]
		   strtmp[i]=0
		   t_score[t1startside][0] = str_to_num(strtmp)
		 }
		else if(contain(text,"t1score1=") == 0)
		 {
		   replace(text,1023,"t1score1=","")
		   for(i=0;i<strlen(text);i++) strtmp[i]=text[i]
		   strtmp[i]=0
		   t_score[t1startside][1] = str_to_num(strtmp)
		 }
		else if(contain(text,"t1score2=") == 0)
		 {
		   replace(text,1023,"t1score2=","")
		   for(i=0;i<strlen(text);i++) strtmp[i]=text[i]
		   strtmp[i]=0
		   t_score[t1startside][2] = str_to_num(strtmp)
		 }
		else if(contain(text,"t2score=") == 0)
		 {
		   replace(text,1023,"t2score=","")
		   for(i=0;i<strlen(text);i++) strtmp[i]=text[i]
		   strtmp[i]=0
		   t_score[t2startside][0] = str_to_num(strtmp)
		 }
		else if(contain(text,"t2score1=") == 0)
		 {
		   replace(text,1023,"t2score1=","")
		   for(i=0;i<strlen(text);i++) strtmp[i]=text[i]
		   strtmp[i]=0
		   t_score[t2startside][1] = str_to_num(strtmp)
		 }
		else if(contain(text,"t2score2=") == 0)
		 {
		   replace(text,1023,"t2score2=","")
		   for(i=0;i<strlen(text);i++) strtmp[i]=text[i]
		   strtmp[i]=0
		   t_score[t2startside][2] = str_to_num(strtmp)
		 }
		else if(contain(text,"wichmap=") == 0)
		 {
		   replace(text,1023,"wichmap=","")
		   for(i=0;i<strlen(text);i++) strtmp[i]=text[i]
		   strtmp[i]=0
		   wichmap = str_to_num(strtmp)
		 }
		else if(contain(text,"period_number=") == 0)
		 {
		   replace(text,1023,"period_number=","")
		   for(i=0;i<strlen(text);i++) strtmp[i]=text[i]
		   strtmp[i]=0
		   period_number = str_to_num(strtmp)
		 }
	      }	
	 }
	war_init(hostname,tmp_t1name,tmp_t2name,tmp_score1,tmp_score2)
	return PLUGIN_CONTINUE
}

//clears vaultdata since weird problems could arise if server crashed while war was active
public war_clearvault(){
#if defined DEBUG
	server_print("* war_clearvault()")
#endif
	if(vaultdata_exists("aws_initialized")) remove_vaultdata("aws_initialized")
	if(vaultdata_exists("aws_map1")) remove_vaultdata("aws_map1")
	if(vaultdata_exists("aws_map2")) remove_vaultdata("aws_map2")
	if(vaultdata_exists("aws_team1")) remove_vaultdata("aws_team1")
	if(vaultdata_exists("aws_team2")) remove_vaultdata("aws_team2")
	if(vaultdata_exists("aws_team1score")) remove_vaultdata("aws_team1score")
	if(vaultdata_exists("aws_team2score")) remove_vaultdata("aws_team2score")
	if(vaultdata_exists("aws_gametype")) remove_vaultdata("aws_gametype")
	if(vaultdata_exists("aws_players")) remove_vaultdata("aws_players")
	if(vaultdata_exists("aws_config")) remove_vaultdata("aws_config")
	if(vaultdata_exists("aws_password")) remove_vaultdata("aws_password")
	if(vaultdata_exists("aws_team1side")) remove_vaultdata("aws_team1side")
	if(vaultdata_exists("aws_currentmap")) remove_vaultdata("aws_currentmap")
	//if(vaultdata_exists("aws_warmup_timelimit")) remove_vaultdata("aws_warmup_timelimit")
	//if(vaultdata_exists("aws_assign_mode")) remove_vaultdata("aws_assign_mode")
	//if(vaultdata_exists("aws_warmup_cfg")) remove_vaultdata("aws_warmup_cfg")
	//if(vaultdata_exists("aws_overtime_cfg")) remove_vaultdata("aws_overtime_cfg")
	//if(vaultdata_exists("aws_knife_cfg")) remove_vaultdata("aws_knife_cfg")
	//if(vaultdata_exists("aws_hltv_passw")) remove_vaultdata("aws_hltv_passw")

	return PLUGIN_CONTINUE
}

// command line intepreter
public war_begin(id){
#if defined DEBUG
	server_print("* war_begin(%d)", id)
#endif
  if (id && !((get_user_flags(id) & ADMIN_LEVEL_A))) { war_clienttext("clt_noaccess",id); return PLUGIN_HANDLED; }
#if defined HLTV_SUPPORT
  if(hltv_recording)
   { 
     (id==0) ? war_servertext("clt_info6") : war_clienttext("clt_info6",id)
     return PLUGIN_HANDLED
   }
#endif
  new adminname[32]
  new gttmp[6][] = { "mr", "mx", "mz", "tl", "tx", "wl" }
  get_user_name(id,adminname,31)
  if(war_live == 0) 
   {
     new tmp_t1name[32],tmp_t2name[32],tmp_minready[4],tmp_gametype[8],tmp_map1[32]
     new passw[32],config[32],curmap[32],strtmp[10]
     new tmp[8][32], i
     new argc = read_argc()-1

     if(argc > 1) 
      { 
        read_argv(1,tmp_t1name,31)
        read_argv(2,tmp_t2name,31)
        if(argc>2) read_argv(3,tmp[0],31)
        if(argc>3) read_argv(4,tmp[1],31)
        if(argc>4) read_argv(5,tmp[2],31)
        if(argc>5) read_argv(6,tmp[3],31)
        if(argc>6) read_argv(7,tmp[4],31)
        if(argc>7) read_argv(8,tmp[5],31)
	get_cvar_string("aw_minready_default",tmp_minready,3)
        get_cvar_string("aw_gametype_default",tmp_gametype,7)
        get_mapname(tmp_map1,31)		
        map2[0] = 0
        format(war_password,63,"NOTHING")
        format(war_config,63,"NOTHING")

        for(i=0;i<argc-2;i++)
         {
           if(containi(tmp[i],"map=")==0)
	    {
              format(tmp_map1,31,"%s",tmp[i])
              replace(tmp_map1,31,"map=","")
	    }
           else if(containi(tmp[i],"map2=")==0)
	    {
              format(map2,31,"%s",tmp[i])
              replace(map2,31,"map2=","")
	    }
           else if(containi(tmp[i],"pw=")==0)
	    {
              format(passw,31,"%s",tmp[i])
              replace(passw,31,"pw=","")
              format(war_password,31,"%s",passw)
	    }
           else if(containi(tmp[i],"cfg=")==0)
	    {
              format(config,31,"%s",tmp[i])
              replace(config,31,"cfg=","")
              format(war_config,31,"%s",config)
	    }
           else if((containi(tmp[i],"mr")==0)||(containi(tmp[i],"mx")==0)||(containi(tmp[i],"tl")==0)||(containi(tmp[i],"tl")==0)||(containi(tmp[i],"tx")==0)||(containi(tmp[i],"wl")==0))
	    {
	       format(tmp_gametype,6,"%s",tmp[i])
	    }
           else format(tmp_minready,3,"%s",tmp[i])  
         }
#if defined DEBUG
	 server_print("t1=%s t2=%s min=%s gt=%s map1=%s map2=%s pw=%s cfg=%s",tmp_t1name,tmp_t2name,tmp_minready,tmp_gametype,tmp_map1,map2,war_password,war_config)
#endif
        if(!is_map_valid(tmp_map1)) { war_clienttext("clt_init1a",id); return PLUGIN_CONTINUE; }
        war_checkininames(tmp_map1,2)
        if(war_formatgtype(tmp_gametype) == 0) { war_clienttext("clt_init2",id); return PLUGIN_HANDLED; }
        minready = str_to_num(tmp_minready)
        if((minready < 1) || (minready > 10)) { war_clienttext("clt_init3",id); return PLUGIN_HANDLED; }

        set_cvar_string("aw_maps", "1")
        wichmap = 0
        if((strlen(map2) > 0) && (gametype != 5)) 
         {
           if(!is_map_valid(map2)) { war_clienttext("clt_init1b",id); return PLUGIN_CONTINUE; }
           war_checkininames(map2,2)
           format(tmp_gametype,7,"%s%i",gttmp[gametype],rounds)
           set_cvar_string("aw_maps", "2")
           wichmap = 1
         }
        set_vaultdata("aws_initialized","1")
        set_vaultdata("aws_team1",tmp_t1name)
        set_vaultdata("aws_team2",tmp_t2name)
        num_to_str(minready,strtmp,3)
        set_vaultdata("aws_players",strtmp)
        set_vaultdata("aws_gametype",tmp_gametype)
        set_vaultdata("aws_map1",tmp_map1)
        if(strlen(map2) != 0) set_vaultdata("aws_map2",map2)
        set_vaultdata("aws_config",war_config)
        num_to_str(t1startside,strtmp,3)
        set_vaultdata("aws_team1side",strtmp)
        if(!equal(war_password,"NOTHING")) set_vaultdata("aws_password",war_password)
        if(wichmap == 1) set_vaultdata("aws_currentmap","1")
        else set_vaultdata("aws_currentmap","0")

//	num_to_str(get_cvar_num("aw_warmup_timelimit"),tmp[0],5)
//	set_vaultdata("aws_warmup_timelimit",tmp[0])

//	get_cvar_string("aw_hltv_passw",tmp[0],31)
//	set_vaultdata("aws_hltv_passw",tmp[0])

//      num_to_str(get_cvar_num("aw_assign_mode"),tmp[0],5)
//      set_vaultdata("aws_assign_mode",tmp[0])

//	get_cvar_string("aw_warmup_cfg",tmp[0],31)
//      set_vaultdata("aws_warmup_cfg",tmp[0])
//	get_cvar_string("aw_overtime_cfg",tmp[0],31)
//      set_vaultdata("aws_overtime_cfg",tmp[0])
//	get_cvar_string("aw_knife_cfg",tmp[0],31)
//      set_vaultdata("aws_knife_cfg",tmp[0])

        war_checkininames(tmp_t1name,1)
        war_checkininames(tmp_t2name,1)
        get_mapname(curmap,31)
        if(equali(tmp_map1,curmap)) war_init(adminname,tmp_t1name,tmp_t2name,-1,-1)
        else server_cmd("changelevel %s",tmp_map1)
      }
     else 
      {
        (id==0) ? war_servertext("clt_info5a") : war_clienttext("clt_info5a",id)
        return PLUGIN_HANDLED; 
      }
   }
  else (id==0) ? war_servertext("clt_init4") : war_clienttext("clt_init4",id)
  return PLUGIN_HANDLED
}

//if submitted string is not in clans.ini or maps.ini, add it there
public war_checkininames(tocheck[32],toedit){
#if defined DEBUG
	server_print("* war_checkininames(%s,%d)",tocheck,toedit)
#endif
	new inifile[256]
	if(toedit == 1) format(inifile,255,"%s/clans.ini", cfgdir)
	else if(toedit == 2) format(inifile,255,"%s/maps.ini", cfgdir)
	if (!file_exists(inifile)) return 0
	new text[256],tag[32],len,pos=0,i=0,x=0
	while(read_file(inifile,pos++,text,255,len)) {
		if ( text[0] != ';') {
			parse(text,tag,32)
			if(equali(tag,tocheck)) i = 1
			x++
		}
	}
	if((i==0) && (((toedit == 1) && (x < 64)) || ((toedit == 2) && (x < 32)))) {
		if(toedit == 2) format(tag,31,"%s",tocheck)
		else format(tag,31,"^"%s^"",tocheck)
		write_file(inifile,tag)
	}
	return PLUGIN_CONTINUE
}

// this starts the game/*	if(war_live == 0) {*/
public war_init(adminname[],cmd_team1[],cmd_team2[],cmd_team1score,cmd_team2score){
	format(t_name[0],31,"%s",cmd_team1)
	format(t_name[1],31,"%s",cmd_team2)
#if defined DEBUG
	server_print("* war_init(%s,%s,%s,%d,%d)", adminname,cmd_team1,cmd_team2,cmd_team1score,cmd_team2score)
#endif
	if(war_live == 0)
	 {
	    war_live++
	    period_number = 0
	    half_active = 0
	    t_score[0] = {0,0,0}
	    t_score[1] = {0,0,0}
	    if(((cmd_team1score != -1) && (cmd_team2score != -1)) && ((cmd_team1score+cmd_team2score == rounds*2) || ((gametype == 3) || (gametype == 4)))) // about to start second map
	     {
	        if((gametype == 0) || (gametype == 3)) totrounds = rounds // score should be 0 for both teams if gametype is 0 (mr) or 3 (tl)
	        else 
		{ // enter startscore if gametype is 1 (mx), 2 (mz) or 4 (tx)
		  t_score[0][0] = cmd_team1score
		  t_score[1][0] = cmd_team2score
		  totrounds = rounds*2
		}
	     }
	 }
#if defined DEBUG
	server_print("t_score[t1]={%d,%d,%d},t_score[t2]={%d,%d,%d}", t_score[t1startside][0],t_score[t1startside][1],t_score[t1startside][2],t_score[t2startside][0],t_score[t2startside][1],t_score[t2startside][2])
#endif
	new tmp[256]
	war_clienttext("clt_init5",0)

	get_cvar_string("aw_pdiscfg",tmp,255)
	server_cmd("exec ^"%s/%s^"",cfgdir,tmp)
	if(!equal(war_password,"NOTHING"))
	 {
	   server_cmd("sv_password %s",war_password)
	   format(tmp, 255, "serverpassword ^"%s^"", war_password)
	   hltv_rcon(tmp)
	   read_HLTV(0)
	 }
	new curmap[32]
	new x = 3
	get_mapname(curmap,32)
	if(wichmap != 2) log_to_file(logfile,"********************************************************************************************")
	log_to_file(logfile,"%s started by %s, Team1: %s Team2: %s %s: %i Startscore: %i-%i^nMap: %s Config: %s PW: %s",(t_score[0][0]+t_score[1][0] > 0) ? "2nd map" : "Clanmatch",adminname,t_name[0],t_name[1],gt[gametype],rounds,t_score[0][0],t_score[1][0],curmap,tmp,war_password)
	if((get_cvar_num("aw_assign_mode") == 1) && (wichmap < 2) && !match_restored && !assigned) // cointoss only on first map
	 {
	   new x = war_hudtext(0,"hud_start9",60,5,10)
	   if(wichmap == 2) set_task(float(x+10),"war_ctinit",876111)
	   else set_task(float(x),"war_ctinit",876111)
	 }
	else 
	 {
	   if((get_cvar_num("aw_assign_mode") == 0) && !match_restored && !assigned)
	    {
	      if(get_cvar_num("aw_autoteam") == 1) x = war_hudtext(0,"hud_start1a",60,5,10)
	      else x = war_hudtext(0,"hud_start1b",60,5,10)
	    }
	   if(wichmap == 2) set_task(float(x+10),"war_warmup",876110)
	   else set_task(float(x-3),"war_warmup",876110)
	 }
	return PLUGIN_CONTINUE
}

// cointoss/*	}*/
public war_ctinit(){
#if defined DEBUG
	server_print("* war_ctinit()")
#endif
	new x  = random_num(1,2) - 1
	t1startside = x
	if(t1startside == 1) t2startside = 0; else t2startside = 1;
#if defined DEBUG
	server_print("t1startside is %d, t2startside is %d", t1startside, t2startside)
#endif
	if(get_cvar_num("aw_autoteam") == 1) x = war_hudtext(0,"hud_start10a",60,5,10)
	else  x = war_hudtext(0,"hud_start10b",60,5,10)
	set_task(float(x-1),"war_warmup",876110)
	assigned = 1
	return PLUGIN_CONTINUE
}

// ============================================================================
// ================================== WARMUP ==================================
// ============================================================================

// displayed at top during warmup
public war_hud_msg(){
	if((war_live%2 > 0)  && (war_live != 5)) 
	{
		if((war_live==1) && (get_cvar_num("aw_assign_mode")==2) && (period_number == 0) && !match_restored && !assigned) war_hudtext(0,"hud_start2k",2,2,10)
		else war_hudtext(0,"hud_start2",2,2,10)
		new textblock[256]
		format(textblock,255,"%s^n%s",whosready[0],whosready[1])
		if(strlen(textblock)>1)
		{
			set_hudmessage(200, 100, 0, 0.001, 0.21, 0, 6.0,  2.0, 0.2, 0.2, 4)
			show_hudmessage(0,textblock)
		}
	}
	return PLUGIN_CONTINUE
}

public war_starthud(){
	remove_task(876102)
	set_task(1.0,"war_hud_msg",876102,"",0,"b")
	return PLUGIN_CONTINUE
}

// inits warmup session
public war_warmup(){
#if defined DEBUG
	server_print("* war_warmup()")
#endif
	new tmp [256], time

	get_cvar_string("aw_warmup_cfg",tmp,255)
	format(tmp,255,"%s/wmcfg/%s",cfgdir,tmp)
	if(!file_exists(tmp)) format(tmp,256,"%s/wmcfg/default.cfg",cfgdir) // use default if nonexisting cfg is submitted
	if((get_cvar_num("aw_autoteam") == 1) && (get_cvar_num("aw_assign_mode") != 2)) war_teamplayers()

	server_cmd("exec ^"%s^"",tmp)			
	war_clearready()
	half_active = 0
	returned_players_num = 0
	disc_pl_count = 0
	set_task(1.0,"war_starthud",876109)
	set_task(2.0,"war_warmup_info",876104)
	get_cvar_string("aw_warmup_timelimit",tmp,255)
	time = str_to_num(tmp)
	if((time > 0) && !match_restored) set_task(float(time*60),"war_forcestart",876112)
	return PLUGIN_CONTINUE
}

// some info for clients during warmup
public war_warmup_info(){
#if defined DEBUG
	server_print("* war_warmup_info()")
#endif
	war_clienttext("clt_warmup1a",0)
	war_clienttext("clt_warmup1b",0)
	war_clienttext("clt_warmup1c",0)
	return PLUGIN_CONTINUE
}

// ============================================================================
// =============================== READY SYSTEM ===============================
// ============================================================================

// what team is client in? first half: CT = 0, second half: CT = 1
public war_teaminfo(id){
#if defined DEBUG
	server_print("* war_teaminfo(%d)",id)
#endif
	new myteam[32]
	get_user_team(id,myteam,31)
	if((war_live == 1) || (war_live == 2)) {
		if(equal(myteam,"CT")) return t1startside
		else if(equal(myteam,"TERRORIST")) return t2startside
	}
	else if((war_live == 3) || (war_live == 4)) {
		if(equal(myteam,"CT")) return t2startside
		else if(equal(myteam,"TERRORIST")) return t1startside
	}
	return -1
}

//if client say captain
public teamcaptain(id){	
#if defined DEBUG
	server_print("* teamcaptain(%d)",id)
#endif
    if(war_live==0) return PLUGIN_HANDLED
    new team[32], tmp
    get_user_team(id, team, 31)
    if(equal(team,"CT")) {if(war_live<=2) tmp=t1startside;else tmp=t2startside;}
    else if(equal(team,"TERRORIST")) {if(war_live<=2) tmp=t2startside;else tmp=t1startside;}
    if(((war_live==1) && (period_number == 0)) || (captain_id[tmp] == 0))
     {
	if(captain_id[tmp]!=id)
	 { 
		captain_id[tmp]=id
		war_clienttext("clt_captain",id)
		war_hudtext(id,"hud_captain",10,0,12)
	 }
	else {war_clienttext("clt_allreadycap",id);war_hudtext(id,"hud_allreadycap",10,0,12);}
     }
    return PLUGIN_CONTINUE
}

// if client say ready
public war_readycheck(id){
#if defined DEBUG
	server_print("* war_readycheck(%d)", id)
#endif
  new tmp = war_teaminfo(id)
  if ((tmp == -1) || (war_live == 0) || (war_live == 5)) return PLUGIN_HANDLED

  if(!half_active) 
   {
     new i,playername[64]
     get_user_name(id,playername,63)
     if(get_cvar_num("aw_clantagcheck") == 1)
     if((containi(playername,t_name[tmp]) == -1) || ((containi(playername,t_name[tmp]) > 0) && (containi(playername,t_name[tmp]) < strlen(playername)-strlen(t_name[tmp])))) return PLUGIN_HANDLED
     for(i=0;i<32;i++) 
      {
         if(readyplayers[i][0] == id)//client is already good to go
          {
	    war_clienttext("clt_warmup2b",id)
	    return PLUGIN_HANDLED
          }
      }
     readyplayers[readyplayersnum][1] = tmp
     readyplayers[readyplayersnum][0] = id
     readyplayersnum++

     if(get_cvar_num("aw_clantagcheck") == 1)
      {
	replace(playername, 63, t_name[tmp], "")
	replace(playername, 63,"|","")
	trim(playername)

	if(strlen(whosready[tmp])==0) format(whosready[tmp],255,"%s: %s", t_name[tmp], playername)
	else format(whosready[tmp],255,"%s, %s", whosready[tmp], playername)
      }
     else
      {
	new myteam[32]
	get_user_team(id,myteam,31)

	if(strlen(whosready[tmp])==0) format(whosready[tmp],255,equal(myteam,"CT") ? "CTs: %s" : "TERs: %s", playername)
	else format(whosready[tmp],255,"%s, %s", whosready[tmp], playername)
      }

     war_clienttext("clt_warmup2a",id)
     client_print(0,print_chat,"%s is ready!",playername)
     p_ready = {0,0}
     for(i=0;i<32;i++) if(readyplayers[i][0] && (p_ready[readyplayers[i][1]] < minready)) p_ready[readyplayers[i][1]]++
     war_starthud()
   }
  if((war_countdowntimer == 0) && (war_live%2 > 0))
  if(p_ready[0]+p_ready[1] >= minready*2) { remove_task(876102); war_prestart(); }

  return PLUGIN_HANDLED
}

// if client say notready
public war_notreadycheck(id){
#if defined DEBUG
	server_print("* war_notreadycheck(%d)", id)
#endif
	if ((war_live == 0) || (war_live == 5)) return PLUGIN_HANDLED

	if(!half_active) 
	{
		new playername[64],tmp2[32][2],i,j
		new x = readyplayersnum
		get_user_name(id,playername,63)
	
		new tmp = war_teaminfo(id)
#if defined DEBUG
		server_print("%s, %d",whosready[tmp],strlen(whosready[tmp]))
#endif
		if(get_cvar_num("aw_clantagcheck") == 1)
		{
		 	replace(playername, 63, t_name[tmp], "")
			replace(playername, 63,"|","")
			trim(playername)
		}
		new str[256]
		format(str,255,", %s",playername)

		if(replace(whosready[tmp], 255, str, "")==0)
		{
			format(str,255,"%s, ",playername)
			if(replace(whosready[tmp], 255, str, "")==0)
				replace(whosready[tmp], 255, playername, "")	
		}	
#if defined DEBUG
		server_print("%s, %d",whosready[tmp],strlen(whosready[tmp]))
#endif
		if(get_cvar_num("aw_clantagcheck") == 1)
		{
			if(strlen(whosready[tmp])-2<=strlen(t_name[tmp])) format(whosready[tmp],255,"") 
		}
		else if((strlen(whosready[tmp])<8)&&((contain(whosready[tmp],"TERs")>=0)||(contain(whosready[tmp],"CTs")>=0)))
			format(whosready[tmp],255,"")

		for(i=0;i<32;i++) {
			if(readyplayers[i][0] != id) {
				tmp2[j][0] = readyplayers[i][0]
				tmp2[j][1] = readyplayers[i][1]
				j++
			}
			else {
				readyplayersnum--
				war_clienttext("clt_warmup3a",id)
			}
		}
		readyplayers = tmp2

		if(x == readyplayersnum) {
			war_clienttext("clt_warmup3b",id)
			return PLUGIN_HANDLED
		}
		else {
			p_ready[0] = 0
			p_ready[1] = 0
			for(i=0;i<readyplayersnum;i++) if(readyplayers[i][0]) p_ready[readyplayers[i][1]]++
		}

		if((war_countdowntimer != 0) && (p_ready[0]+p_ready[1] < minready*2)) {
			remove_task(876103)
			war_hudtext(0,"hud_start6",6,6,10)
			log_to_file(logfile,"Countdown aborted by %s",playername)
			war_countdowntimer = 0
		}
		remove_task(876101)
		war_starthud()
	}

	return PLUGIN_HANDLED
}

// if client is ready and get disconnected, make him notready
public client_disconnect(id){
#if defined DEBUG
	server_print("* client_disconnect(%d)",id)
#endif
	if(id == captain_id[0]) captain_id[0]=0
	if(id == captain_id[1]) captain_id[1]=0
	if(!is_user_hltv(id) && !is_user_bot(id) && war_live > 1)						
	{											
#if defined DEBUG
		server_print("* clients disconnected: %d",disc_pl_count+1)
#endif		
		get_user_ip(id,disc_pl_ip[disc_pl_count],16,1)
		get_user_name(id,disc_pl_name[disc_pl_count],64)
		disc_pl_deaths[disc_pl_count]=get_user_deaths(id)
		disc_pl_frags[disc_pl_count]=get_user_frags(id)
		disc_pl_money[disc_pl_count]=cs_get_user_money(id)
		if(is_user_alive(id))
		 {
		    disc_pl_armor[disc_pl_count][0]=get_user_armor(id)
		    disc_pl_armor[disc_pl_count][1]=get_pdata_int(id,112)
		    disc_pl_defuse[disc_pl_count]=cs_get_user_defuse(id)
		    get_user_weapons(id, disc_pl_Weapons[disc_pl_count], disc_pl_numWeapons[disc_pl_count])
		    for (new j=0; j<disc_pl_numWeapons[disc_pl_count]; j++) get_user_ammo(id, disc_pl_Weapons[disc_pl_count][j], disc_pl_clip[disc_pl_count][j], disc_pl_ammo[disc_pl_count][j])
		 }
#if defined DEBUG
		server_print("%s (%s), frags=%d, deaths=%d, money=%d, armor=%d-%d defuse=%d",disc_pl_name[disc_pl_count],disc_pl_ip[disc_pl_count],disc_pl_frags[disc_pl_count],disc_pl_deaths[disc_pl_count],disc_pl_money[disc_pl_count],disc_pl_armor[disc_pl_count][0],disc_pl_armor[disc_pl_count][1],disc_pl_defuse[disc_pl_count])
		for (new j=0; j<disc_pl_numWeapons[disc_pl_count]; j++)
		{
			new weapname[32]
			get_weaponname(disc_pl_Weapons[disc_pl_count][j],weapname,31)
			server_print("Weap ID: %i, Weap name: %s, Clip: %d, Ammo: %i",disc_pl_Weapons[disc_pl_count][j],weapname,disc_pl_clip[disc_pl_count][j], disc_pl_ammo[disc_pl_count][j])
		}
#endif		
		disc_pl_count++
	}											

#if defined HLTV_SUPPORT
	if (is_user_hltv(id)) { 
		log_to_file(logfile,"HLTV proxy disconnected")
		server_print("[AMX WAR] HLTV proxy disconnected")
		client_print(0,print_chat,"[AMX WAR] HLTV proxy disconnected")
		hltv_id = 0 
		hltv_address = -1
	}
#endif
	if((war_live%2 > 0) && (war_live != 5)) {
		new tmp2[32][2],i,j
		for(i=0;i<32;i++) {
			if(readyplayers[i][0] != id) {
				tmp2[j][0] = readyplayers[i][0]
				tmp2[j][1] = readyplayers[i][1]
				j++
			}
			else 
			{
				readyplayersnum--

				new playername[64]
				get_user_name(id,playername,63)
				new tmp = war_teaminfo(id)
			
				if(get_cvar_num("aw_clantagcheck") == 1)
				{
				 	replace(playername, 63, t_name[tmp], "")
					replace(playername, 63,"|","")
					trim(playername)
				}
				new str[256]
				format(str,255,", %s",playername)

				if(replace(whosready[tmp], 255, str, "")==0)
				{
					format(str,255,"%s, ",playername)
					if(replace(whosready[tmp], 255, str, "")==0)
						replace(whosready[tmp], 255, playername, "")	
				}	
#if defined DEBUG
				server_print("%s, %d",whosready[tmp],strlen(whosready[tmp]))
#endif			

				if(get_cvar_num("aw_clantagcheck") == 1)
				{
					if(strlen(whosready[tmp])-2<=strlen(t_name[tmp])) format(whosready[tmp],255,"") 
				}
				else if((strlen(whosready[tmp])<8)&&((contain(whosready[tmp],"TERs")>=0)||(contain(whosready[tmp],"CTs")>=0)))
					format(whosready[tmp],255,"")
			}
		}
		readyplayers = tmp2
		p_ready[0] = 0
		p_ready[1] = 0
		for(i=0;i<readyplayersnum;i++) if(readyplayers[i][0]) p_ready[readyplayers[i][1]]++

		if(p_ready[0]+p_ready[1] < minready*2) {
			if(war_countdowntimer != 0) {
				remove_task(876103)
				war_hudtext(0,"hud_start6",6,6,10)
				log_to_file(logfile,"id:%i got disconnected during countdown",id)
				war_countdowntimer = 0
			}
			remove_task(876101)
			war_starthud()
		}
	}
	return PLUGIN_CONTINUE
}

public client_connect(id){
#if defined DEBUG
	server_print("* client_connect(%d)", id)
#endif
	new usname[64],usip[16]
	get_user_ip(id,usip,16,1)
	get_user_name(id,usname,64)

	if(get_cvar_num("aw_check_ip")==1 && disc_pl_count > 0 && war_live > 1)
	{
		for(new i=0;i<disc_pl_count;i++) if(equal(usip,disc_pl_ip[i])) return PLUGIN_CONTINUE
		client_print(0,print_chat,"[AMX WAR] Kick %s (%s) due slot reservation for disconnected player",usname,usip)
		server_cmd("kick #%d Sorry, your IP not equal with disconnected player",get_user_userid(id))
		return PLUGIN_CONTINUE
	}
	if(get_cvar_num("aw_check_name")==1 && disc_pl_count > 0 && war_live > 1)						
	{															
		for(new i=0;i<disc_pl_count;i++) if(equal(usname,disc_pl_name[i])) return PLUGIN_CONTINUE
		client_print(0,print_chat,"[AMX WAR] Kick %s (%s) due slot reservation for disconnected player",usname,usip)
		server_cmd("kick #%d Sorry, your name not equal with disconnected player",get_user_userid(id))
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE													
}																

public read_HLTV(mode) {
#if defined DEBUG
	server_print("* read_HLTV(%d)",mode)
#endif
	if (socket_change(hltv_address , 100)) {
		new buf[512]
		socket_recv(hltv_address , buf, 511)
#if defined DEBUG
		server_print("%s",buf[5])
#endif
		if(mode==1){
			hltv_rec_delay = str_to_num(buf[56])
			#if defined DEBUG
				server_print("hltv_rec_delay = %d",hltv_rec_delay)
			#endif
		}
		if(mode>1){
			format(buf,511,"say %s",buf[5])
			socket_close(hltv_address)
			hltv_rcon(buf)
		}
		if(mode==2) hltv_recording = 1
		if(mode==3) hltv_recording = 0
	}
	else if(mode>0)
	{
		server_print("HLTV: Invalid rcon password")
		client_print(0,print_chat,"HLTV: Invalid rcon password")
		if(mode==2) hltv_recording = 0
		if(mode==3) hltv_recording = 0
	}
	socket_close(hltv_address)
	return PLUGIN_CONTINUE
}

public hltv_init(id){
#if defined DEBUG
	server_print("* hltv_init(%d)", id)
#endif
	get_cvar_string("aw_hltv_passw", hltv_pass, 31)
	if ((hltv_address == -1) && (strlen(hltv_pass) > 0)) 
	 {
		hltv_id = id
		new tmp[32], tmp2[16]

		get_user_ip(hltv_id,tmp,31)
		new pos = copyc(hltv_ip,15,tmp,':') + 1
		format(tmp2,15,"%s",tmp[pos])
		hltv_port = str_to_num(tmp2)
#if defined DEBUG
		server_print("hltv ip is %s, port %d", hltv_ip, hltv_port)
#endif
    		hltv_rcon("say HLTV initialized")
		read_HLTV(0)
    		hltv_rcon("delay")
		set_task(0.5,"read_HLTV",1)
	 }
	return PLUGIN_CONTINUE	
}

public waitforalive(){
#if defined DEBUG
	server_print("* waitforalive()")
#endif
	new id, dp_id, i, j, k
	new weapname[32]
	if(returned_players_num == 0) {remove_task(876113);return PLUGIN_HANDLED;}
	if(returned_players_num>0)
 	  if(is_user_alive(returned_players[i][0]))
	   {
		id=returned_players[i][0]
		dp_id=returned_players[i][1]
#if defined DEBUG
		server_print("returned player %d now is ALIVE!!! %d", id, dp_id)
#endif
		strip_user_weapons(id)
		set_user_frags(id, disc_pl_frags[dp_id])
	     	cs_set_user_deaths(id, disc_pl_deaths[dp_id])
		if(disc_pl_defuse[dp_id]) cs_set_user_defuse(id)
	     	if(disc_pl_armor[dp_id][0]>0)
		 {
			switch(disc_pl_armor[dp_id][1])
			{
				case 1: give_item(id, "item_kevlar")
				case 2: give_item(id, "item_assaultsuit")
			}
			set_user_armor(id, disc_pl_armor[dp_id][0])
		 }
		for(j=0;j<disc_pl_numWeapons[dp_id];j++)
		 {
			get_weaponname(disc_pl_Weapons[dp_id][j],weapname,31)
			if(disc_pl_Weapons[dp_id][j]!=6) //Weapon is no bomb
			{
			  give_item(id, weapname)
			  if(disc_pl_Weapons[dp_id][j]!=29) //Weapon is not knife
			   {
			     cs_set_user_bpammo(id, disc_pl_Weapons[dp_id][j], disc_pl_ammo[dp_id][j])
			     if((disc_pl_Weapons[dp_id][j]!=4)&&(disc_pl_Weapons[dp_id][j]!=9)&&(disc_pl_Weapons[dp_id][j]!=25)) //weapons is not grenades
			      {
			        new iWPNidx = -1
			        while ((iWPNidx = find_ent_by_class(iWPNidx, weapname)) != 0)
				   if (id == entity_get_edict(iWPNidx, EV_ENT_owner))
				      cs_set_weapon_ammo(iWPNidx, disc_pl_clip[dp_id][j])
			      }
			   }
			}
		 }
		//Удаляем из дисконнектившихся информацию о игроке
		for(j=dp_id;j<disc_pl_count;j++)
		{
			format(disc_pl_ip[j],16,"%s",disc_pl_ip[j+1])
			format(disc_pl_name[j],64,"%s",disc_pl_name[j+1])
			disc_pl_frags[j]=disc_pl_frags[j+1]
			disc_pl_deaths[j]=disc_pl_deaths[j+1]
			disc_pl_money[j]=disc_pl_money[j+1]
			disc_pl_armor[j][0]=disc_pl_armor[j+1][0]
			disc_pl_armor[j][1]=disc_pl_armor[j+1][1]
			disc_pl_defuse[j]=disc_pl_defuse[j+1]
			for(k=0;k<disc_pl_numWeapons[j+1];k++)
			 {
			 	disc_pl_Weapons[j][k]=disc_pl_Weapons[j+1][k]
				disc_pl_clip[j][k]=disc_pl_clip[j+1][k]
				disc_pl_ammo[j][k]=disc_pl_ammo[j+1][k]
			 }
			disc_pl_numWeapons[j]=disc_pl_numWeapons[j+1]
		}
		//Исправляем ссылки (очередь сдвинулась влево на 1)
		for(k=0;k<returned_players_num;k++) if(returned_players[k][1]>dp_id) returned_players[k][1]--
		//Сдвигаем очередь вернувшихся влево
		for(k=0;k<returned_players_num-1;k++){
			returned_players[k][0] = returned_players[k+1][0]
			returned_players[k][1] = returned_players[k+1][1]
		}
		returned_players_num--
		disc_pl_count--
	   }
	set_task(1.0,"waitforalive",876113)
	return PLUGIN_HANDLED
}


public client_putinserver(id){
#if defined DEBUG
	server_print("* client_putinserver(%d)",id)
#endif

#if defined HLTV_SUPPORT
	if(is_user_hltv(id)) set_task(1.0, "hltv_init", id)
#endif

	if(((war_live==2)||(war_live==4))  && disc_pl_count > 0 && !is_user_hltv(id))
	{
		new usname[64],usip[16]
		get_user_ip(id,usip,16,1)
		get_user_name(id,usname,64)

		for(new i=0;i<disc_pl_count;i++)
		{
			if(equal(usip,disc_pl_ip[i]) || equal(usname,disc_pl_name[i]))
			{
				returned_players[returned_players_num][0]=id
				returned_players[returned_players_num][1]=i
				returned_players_num++
				remove_task(876113)
				set_task(0.0,"waitforalive",876113)
#if defined DEBUG
				client_print(0,print_chat,"[AMX WAR] %s (%s) comeback",usname,usip)
				server_print("[AMX WAR] %s (%s) comeback",usname,usip)
#endif
				if(get_cvar_num("aw_return_money_by")==1) cs_set_user_money(id, disc_pl_money[i],0)
				if(get_cvar_num("aw_return_money_by")==2)
					if(equal(usip,disc_pl_ip[i]))
						cs_set_user_money(id, disc_pl_money[i],0)
				if(get_cvar_num("aw_return_money_by")==3)
					if(equal(usname,disc_pl_name[i]))
						cs_set_user_money(id, disc_pl_money[i],0)
				if(get_cvar_num("aw_return_money_by")==4)
					if(equal(usip,disc_pl_ip[i]) && equal(usname,disc_pl_name[i]))
						cs_set_user_money(id, disc_pl_money[i],0)
				return PLUGIN_CONTINUE										
			}													
		}														
	}															
	return PLUGIN_CONTINUE
}

// makes all clients notready
public war_clearready(){
#if defined DEBUG
	server_print("* war_clearready()")
#endif
	for (new i=0;i<32;i++) readyplayers[i] = {0,0}
	p_ready = {0,0}
	readyplayersnum = 0
	format(whosready[0],255,"")
	format(whosready[1],255,"")
	
	return PLUGIN_CONTINUE
}

// makes all valid (correct clantag & correct team) clients ready
public war_makeallready(){
#if defined DEBUG
	server_print("* war_makeallready()")
#endif
	new players[32],playername[64]
	new num_players,i
	get_players(players,num_players,"")

	for(i = 0;i<num_players;i++) {
		new tmp = war_teaminfo(players[i])
		get_user_name(players[i],playername,63)
		if(tmp > -1) {
			if ((containi(playername,t_name[tmp]) != -1) && (containi(playername,t_name[tmp]) < 3)) {
				readyplayers[readyplayersnum][1] = tmp
				readyplayers[readyplayersnum][0] = players[i]
				readyplayersnum++
			}
		}
	}
	for(i=0;i<32;i++) if(readyplayers[i][0]) p_ready[readyplayers[i][1]]++
	return PLUGIN_CONTINUE
}

// ============================================================================
// ============================= MATCH START ==================================
// ============================================================================
public log_settings(file[]){
#if defined DEBUG
	server_print("* log_settings(%s)",file)
#endif
  new str[64]
  get_cvar_string("aw_tie", str, 63)
  format(str,63,"aw_tie %s", str)
  delete_file(file)
  write_file (file, str)

  get_cvar_string("aw_countdowntime", str, 63)
  format(str,63,"aw_countdowntime %s", str)
  write_file (file, str)

  get_cvar_string("aw_assign_mode", str, 63)
  format(str,63,"aw_assign_mode %s", str)
  write_file (file, str)

  get_cvar_string("aw_autoteam", str, 63)
  format(str,63,"aw_autoteam %s", str)
  write_file (file, str)

  get_cvar_string("aw_clantagcheck", str, 63)
  format(str,63,"aw_clantagcheck %s", str)
  write_file (file, str)

  get_cvar_string("aw_screenshots", str, 63)
  format(str,63,"aw_screenshots %s", str)
  write_file (file, str)

  get_cvar_string("aw_demos", str, 63)
  format(str,63,"aw_demos %s", str)
  write_file (file, str)

  get_cvar_string("aw_hltv_passw", str, 63)
  format(str,63,"aw_hltv_passw %s", str)
  write_file (file, str)

  get_cvar_string("aw_check_ip", str, 63)
  format(str,63,"aw_check_ip %s", str)
  write_file (file, str)

  get_cvar_string("aw_check_name", str, 63)
  format(str,63,"aw_check_name %s", str)
  write_file (file, str)

  get_cvar_string("aw_return_money_by", str, 63)
  format(str,63,"aw_return_money_by %s", str)
  write_file (file, str)

  get_cvar_string("aw_swapteams", str, 63)
  format(str,63,"aw_swapteams %s", str)
  write_file (file, str)

  get_cvar_string("aw_ot_rounds", str, 63)
  format(str,63,"aw_ot_rounds %s", str)
  write_file (file, str)

  get_cvar_string("aw_warmup_timelimit", str, 63)
  format(str,63,"aw_warmup_timelimit %s", str)
  write_file (file, str)

  get_cvar_string("aw_restarts", str, 63)
  format(str,63,"aw_restarts ^"%s^"", str)
  write_file (file, str)

  format(str,63,"aw_onlykillfrags %d", get_cvar_num("aw_onlykillfrags"))
  write_file (file, str)
  
  get_cvar_string("aw_minready_default", str, 63)
  format(str,63,"aw_minready_default %s", str)
  write_file (file, str)

  get_cvar_string("aw_gametype_default", str, 63)
  format(str,63,"aw_gametype_default %s", str)
  write_file (file, str)

  get_cvar_string("aw_warmup_cfg", str, 63)
  format(str,63,"aw_warmup_cfg ^"%s^"", str)
  write_file (file, str)

  get_cvar_string("aw_overtime_cfg", str, 63)
  format(str,63,"aw_overtime_cfg ^"%s^"", str)
  write_file (file, str)

  get_cvar_string("aw_knife_cfg", str, 63)
  format(str,63,"aw_knife_cfg ^"%s^"", str)
  write_file (file, str)

  get_cvar_string("aw_pubcfg", str, 63)
  format(str,63,"aw_pubcfg ^"%s^"", str)
  write_file (file, str)

  get_cvar_string("aw_pdiscfg", str, 63)
  format(str,63,"aw_pdiscfg ^"%s^"", str)
  write_file (file, str)

  get_cvar_string("aw_penacfg", str, 63)
  format(str,63,"aw_penacfg ^"%s^"", str)
  write_file (file, str)

  return PLUGIN_CONTINUE
}

public war_knife_msg(){
#if defined DEBUG
	server_print("* war_knife_msg()")
#endif
	war_hudtext(0,"hud_start4k",15,2,10)
	war_clienttext("clt_start1ka",0)
	war_clienttext("clt_start1kb",0)
	war_clienttext("clt_start1kc",0)
	log_to_file(logfile,"Knife round started")
	knife_active = 1
	return PLUGIN_CONTINUE
}

// shows live message and sets game active, scoring can now begin
public war_live_msg(){
#if defined DEBUG
	server_print("* war_live_msg()")
#endif
	war_hudtext(0,"hud_start4",15,2,10)
	war_clienttext("clt_start1a",0)
	war_clienttext("clt_start1b",0)
	war_clienttext("clt_start1c",0)
	log_to_file(logfile,"%s Round %i %s half started",mi[wichmap],period_number,(war_live <= 2) ? "1st" : "2nd")
	half_active = 1
	if((gametype == 3) || (gametype == 4)) {
		tl_start = floatround(get_gametime())
		set_task(float(rounds*60),"war_timelimit",876105)
	}
	return PLUGIN_CONTINUE
}

public onlyknife(){
#if defined DEBUG
	server_print("* onlyknife()")
#endif
    new players[32], weapname[32]
    new num_players, i
    get_weaponname(29,weapname,31)
    get_players(players,num_players,"e", "CT")
    for(i=0;i<num_players;i++)
     {
	strip_user_weapons(players[i])
	give_item(players[i], weapname)
     }
    get_players(players,num_players,"e", "TERRORIST")
    for(i=0;i<num_players;i++)
     {
	strip_user_weapons(players[i])
	give_item(players[i], weapname)
     }
}

// starts knife round
public war_start_knife(){
#if defined DEBUG
	server_print("* war_start_knife()")
#endif
  remove_task(876103) // no more countdown
  remove_task(876112) // no more autostart by warmup timer
  war_clearready()
  war_clienttext("clt_start2k",0)
  new x = war_hudtext(0,"hud_start3k",10,2,10)

  new str[64], tmp[10], i
  get_cvar_string("aw_restarts", str, 63)
  while(strlen(str) > 0)
   {
	for(i=0;i<10;i++) 
	 {
	    if(str[i]==' '){tmp[i]=0;break;}
	    tmp[i]=str[i]
	 }
	replace(str,63,tmp,"")
	replace(str,63," ","")
	set_task(float(x),"r_r",0,tmp,1)
	x+=str_to_num(tmp)
   }
  set_task(float(x+1),"onlyknife")
  set_task(float(x+1),"war_knife_msg")
  return PLUGIN_CONTINUE
}

public bomb_events(){
#if defined DEBUG
	server_print("* bomb_events()")
#endif
	new arg0[64], action[64], name[33], userid; 

	// Read the log data that we need 
	read_logargv(0,arg0,63) 
	read_logargv(2,action,63) 

	// Find the id of the player that triggered the log 
	parse_loguser(arg0,name,32,userid) 
	cplayer = find_player("k",userid) 

	return PLUGIN_HANDLED
}

public bomb_drop(){
#if defined DEBUG
	server_print("* bomb_drop()")
#endif
	client_cmd(cplayer,"use weapon_c4")
	client_cmd(cplayer,"drop")
	return PLUGIN_HANDLED
}

public restore_players_stats(){ 
#if defined DEBUG
	server_print("* restore_players_stats()")
#endif
  new ip[16], name[64], frags, deaths, money, armor, atype, defuse
  new tmp_ip[16], tmp_name[64] ,strtmp[10]
  new i, j, pos=0, text[1024], len, players[32], num_players
  new Weapons[32], clip[32], ammo[32], num_weapons, weapname[32]
  match_restored = 0
  while(read_file(statsfile,pos++,text,1023,len)) 
   if(contain(text,"ip=") == 0){ 
	replace(text,1023,"ip=","")
	for(i=0;(i<16)&&(text[i]!=',');i++) ip[i]=text[i]
	ip[i]=0
	replace(text,1023,ip,"")
	replace(text,1023,",name=^"","")
	for(i=0;i<64;i++)
	 {
	   if(text[i]=='"') {name[i]=0;break;}
	   name[i]=text[i]
	 }
	replace(text,1023,name,"")
	replace(text,1023,"^",deaths=","")
	for(i=0;i<4;i++)
	 {
	   if(text[i]==',') {strtmp[i]=0;break;}
	   strtmp[i]=text[i]
	 }
	deaths = str_to_num(strtmp)
	replace(text,1023,strtmp,"")
	replace(text,1023,",frags=","")
	for(i=0;i<4;i++)
	 {
	   if(text[i]==',') {strtmp[i]=0;break;}
	   strtmp[i]=text[i]
	 }
	frags = str_to_num(strtmp)
	replace(text,1023,strtmp,"")
	replace(text,1023,",money=","")
	for(i=0;i<6;i++)
	 {
	   if(text[i]==',') {strtmp[i]=0;break;}
	   strtmp[i]=text[i]
	 }
	money = str_to_num(strtmp)
	replace(text,1023,strtmp,"")
	replace(text,1023,",armor=","")
	for(i=0;i<4;i++)
	 {
	   if(text[i]=='-') {strtmp[i]=0;break;}
	   strtmp[i]=text[i]
	 }
	armor = str_to_num(strtmp)
	replace(text,1023,strtmp,"")
	replace(text,1023,"-","")
	strtmp[0]=text[0]
	strtmp[1]=0
	atype = str_to_num(strtmp)
	replace(text,1023,strtmp,"")
	replace(text,1023,",defuse=","")
	strtmp[0]=text[0]
	strtmp[1]=0
	defuse = str_to_num(strtmp)
	replace(text,1023,strtmp,"")
	replace(text,1023,",","")
	
	for(j=0;strlen(text)>3;j++)
	{
		server_print("%s",text)
		for(i=0;i<4;i++)
		{
			if(text[i]==':'){strtmp[i]=0;break;}
			strtmp[i]=text[i]
		}	
		Weapons[j] = str_to_num(strtmp)
		replace(text,1023,strtmp,"")
		replace(text,1023,":","")
		server_print("%s",text)
		for(i=0;i<4;i++)
		{
			if(text[i]==':'){strtmp[i]=0;break;}
			strtmp[i]=text[i]
		}	
		clip[j] = str_to_num(strtmp)
		replace(text,1023,strtmp,"")
		replace(text,1023,":","")
		server_print("%s",text)
		for(i=0;i<strlen(text);i++)
		{
			if(text[i]==' '){strtmp[i]=0;break;}
			strtmp[i]=text[i]
		}	
		ammo[j] = str_to_num(strtmp)
		replace(text,1023,strtmp,"")
		replace(text,1023," ","")
		num_weapons = j
	}
#if defined DEBUG
	len = format(text,1023,"ip=%s,name=^"%s^",deaths=%d,frags=%d,money=%d,armor=%d-%d,defuse=%d,", ip, name, deaths, frags, money ,armor, atype, defuse)
	for(i=0;i<=num_weapons;i++) len += format(text[len],1023-len,"%d:%d:%d ", Weapons[i],clip[i],ammo[i])
	server_print("%s",text)
#endif
	get_players(players,num_players,"ach") //return alive players, skip bots and hltv
	for(i=0;i<num_players;i++){
	   server_print("i=%d", i)
	   get_user_ip(players[i],tmp_ip,16,1)
	   get_user_name(players[i],tmp_name,63)
	   server_print("ip=%s,name=^"%s^"", tmp_ip, tmp_name)
	   if(equal(ip, tmp_ip) && equal(name,tmp_name))
	    {
		strip_user_weapons(players[i])
		get_weaponname(29,weapname,31)
		give_item(players[i], weapname)
		server_print("weapname=%s", weapname)

		set_user_frags(players[i], frags)								
	     	cs_set_user_deaths(players[i], deaths)
	     	cs_set_user_money(players[i], money, 0)
		if(defuse==1) cs_set_user_defuse(players[i])
	     	if(armor>0){
			switch(atype)
			{
				case 1: give_item(players[i], "item_kevlar")
				case 2: give_item(players[i], "item_assaultsuit")
			}
			set_user_armor(players[i], armor)
		 }
		for(j=0;j<=num_weapons;j++){
			server_print("j=%d, weapon[j]=%d", j, Weapons[j])
			get_weaponname(Weapons[j],weapname,31)
			server_print("weapname=%s", weapname)
			give_item(players[i], weapname)
			cs_set_user_bpammo(players[i], Weapons[j], ammo[j])
			if((Weapons[j]!=4)&&(Weapons[j]!=9)&&(Weapons[j]!=25)) //weapons is not grenades
			{
				new iWPNidx = -1
				while ((iWPNidx = find_ent_by_class(iWPNidx, weapname)) != 0) if (players[i] == entity_get_edict(iWPNidx, EV_ENT_owner)) cs_set_weapon_ammo(iWPNidx, clip[j])
			}
		 }
#if defined DEBUG
		server_print("ip=%s,name=^"%s^", stats restored", ip, name)
		//server_print("Armor=%d, Atype is %d",get_user_armor(players[i]),get_pdata_int(players[i],112))
		//server_print("deaths=%d",cs_get_user_deaths(players[i]))
		//server_print("frags=%d",get_user_frags(players[i]))
		//server_print("money=%d",cs_get_user_money(players[i]))
		//new Wps[32][32], nWps[32], k, wpname[32], cl, am

		//get_user_weapons(players[i], Wps[i], nWps[i])
		//for (k=0; k<nWps[i]; k++)
		//{
		//	get_user_ammo(players[i], Wps[i][k], cl, am)
		//	get_weaponname(Wps[i][k],wpname,31)
		//	server_print("Weap ID: %i, Weap name: %s, Clip: %d, Ammo: %i",Wps[i][k],wpname,cl,am)
		//}
#endif
		break;
	    }
          }
    }
  return PLUGIN_CONTINUE
}

// starts the match
public war_start(){
#if defined DEBUG
	server_print("* war_start()")
#endif
  remove_task(876103) // no more countdown
  remove_task(876112) // no more autostart by warmup timer
  war_clearready()
  war_clienttext("clt_start2",0)
  if((war_live == 1) && (period_number == 0)) 
   {
      #if defined HLTV_SUPPORT
        war_hltvrecord()
      #endif
      war_demo()
   }
  war_live++
#if defined DEBUG
  server_print("*** war_live = %d, match_restored = %d", war_live, match_restored)
#endif
  if(match_restored == 0)
   {
     t_score[0][war_live/2] = 0
     t_score[1][war_live/2] = 0
#if defined DEBUG
     server_print("*** reset half scores ***")
#endif
   }
  new x = war_hudtext(0,"hud_start3",10,2,10)

  new str[64], tmp[10], i
  get_cvar_string("aw_restarts", str, 63)
  while(strlen(str) > 0)
   {
#if defined DEBUG
	server_print("aw_restarts = %s", str)
#endif
	for(i=0;i<10;i++) 
	 {
	    if(str[i]==' '){tmp[i]=0;break;}
	    tmp[i]=str[i]
	 }
	replace(str,63,tmp,"")
	replace(str,63," ","")
	set_task(float(x),"r_r",0,tmp,1)
	x+=str_to_num(tmp)
   }
  if(match_restored)
  {
	set_task(float(x)+1.1,"bomb_drop")
	set_task(float(x)+1.5,"restore_players_stats")
  }else log_settings(matchcfgfile)
  set_task(float(x+1),"war_live_msg")
  return PLUGIN_CONTINUE
} 

// starts counter down to match start
public war_prestart(){
#if defined DEBUG
	server_print("* war_prestart()")
#endif
	new x, tmp[256]
	
	if((war_live==1) && (get_cvar_num("aw_assign_mode")==2) && (period_number == 0) && !knife_active && !match_restored && !assigned)
	 {
		get_cvar_string("aw_knife_cfg",tmp,255)
		replace(tmp,63,".cfg","")
		format(tmp,255,"%s/knifecfg/%s.cfg",cfgdir,tmp)
		if(!file_exists(tmp)) format(tmp,256,"%s/knifecfg/default.cfg",cfgdir) // use default if nonexisting cfg is submitted
	 }
	else if(period_number==0)
	 {
		if(equal(war_config,"NOTHING")) format(tmp,255,"%s/cfg/default.cfg",cfgdir)
		else {
			replace(war_config,63,".cfg","")
			format(tmp,255,"%s/cfg/%s.cfg",cfgdir,war_config)
			if(!file_exists(tmp)) format(tmp,255,"%s/cfg/default.cfg",cfgdir) // use default if nonexisting cfg is submitted
		     }
	 }
        else	//If overtime
  	 {
		get_cvar_string("aw_overtime_cfg",tmp,255)
		replace(tmp,255,".cfg","")
		format(tmp,255,"%s/otcfg/%s.cfg",cfgdir,tmp)
		if(!file_exists(tmp)) format(tmp,255,"%s/otcfg/default.cfg",cfgdir) // use default if nonexisting cfg is submitted
	 }
	server_cmd("exec ^"%s^"",tmp)
	server_print("cfg is %s", tmp)
	
	if((war_live==1) && (get_cvar_num("aw_assign_mode")==2) && (period_number == 0) && !knife_active && !match_restored && !assigned)
	 {
		if(warauto) { x = war_hudtext(0,"hud_start7kb",20,2,10); warauto = 0; }
		else x = war_hudtext(0,"hud_start7ka",20,2,10)
	 }
	else if(!knife_active && (!assigned&&war_live==1))
	 {
		if(warauto) { x = war_hudtext(0,"hud_start7b",20,2,10); warauto = 0; }
		else x = war_hudtext(0,"hud_start7a",20,2,10)
	 }

	war_countdowntimer = get_cvar_num("aw_countdowntime")
	if((war_live==1) && (get_cvar_num("aw_assign_mode")==2) && (period_number == 0) && !knife_active && !match_restored && !assigned) log_to_file(logfile,"Prestarting knife round....")
	else log_to_file(logfile,"Prestarting %s round %i %s half",mi[wichmap],period_number,hi[war_live])
	
	remove_task(876102)
	set_task(float(x-2),"war_countdown",876103)

	if((war_live==1) && (get_cvar_num("aw_assign_mode")==2) && (period_number == 0) && !knife_active && !match_restored && !assigned)
	 {
		set_task(float(get_cvar_num("aw_countdowntime")+(x-1)),"war_start_knife")
		new players[32],num_players
		if(captain_id[0]==0)
		 {
			get_players(players,num_players,"ce", "CT")
			captain_id[0] = players[0]
			war_clienttext("clt_captain",players[0])
			war_hudtext(players[0],"hud_captain",10,0,12)
		 }
		if(captain_id[1]==0)
		 {
			get_players(players,num_players,"ce", "TERRORIST")
			captain_id[1] = players[0]
			war_clienttext("clt_captain",players[0])
			war_hudtext(players[0],"hud_captain",10,0,12)
		 }
		server_print("CT Captain id=%d, TER Captain id=%d", captain_id[0], captain_id[1])
	 }
	else set_task(float(get_cvar_num("aw_countdowntime")+(x-1)),"war_start",876101)
	
	if(knife_active) knife_active = 0
	return PLUGIN_CONTINUE
}

//Restart map
public war_restart(id){
#if defined DEBUG
	server_print("* war_restart(%d)",id)
#endif
	if(war_live == 0)
	{
		if(id!=0) war_clienttext("clt_abort",id); else war_servertext("clt_abort")
		return PLUGIN_HANDLED
	}
	if (id && !((get_user_flags(id) & ADMIN_LEVEL_A))) { 
		war_clienttext("clt_noaccess",id)
		war_servertext("clt_noaccess")
		return PLUGIN_HANDLED
	}
	war_countdowntimer = 0
	returned_players_num = 0
	war_clearready()
	remove_task(876101) // abort all tasks, just in case
	remove_task(876102)
	remove_task(876103)
	remove_task(876104)
	remove_task(876105)
	remove_task(876106)
	remove_task(876107)
	remove_task(876108)
	remove_task(876109)
	remove_task(876110)
	remove_task(876111) 
	remove_task(876112) 
	#if defined HLTV_SUPPORT
		war_hltvstop()
	#endif
	disc_pl_count=0										

	r_r("1")
	war_live = 0
	new tmp_name1[64], tmp_name2[64]
	format(tmp_name1,63,"%s",t_name[t1startside])
	format(tmp_name2,63,"%s",t_name[t2startside])
	war_init("war_restart",tmp_name1,tmp_name2,-1,-1)
	return PLUGIN_HANDLED
}

public war_restart2(id){
#if defined DEBUG
	server_print("* war_restart2(%d)",id)
#endif
	if(war_live == 0)
	{
		if(id!=0) war_clienttext("clt_abort",id); else war_servertext("clt_abort")
		return PLUGIN_HANDLED
	}
	if (id && !((get_user_flags(id) & ADMIN_LEVEL_A))) { 
		war_clienttext("clt_noaccess",id)
		war_servertext("clt_noaccess")
		return PLUGIN_HANDLED
	}
	if(war_live<3){ war_restart(id); return PLUGIN_HANDLED; }
	war_countdowntimer = 0
	returned_players_num = 0
	war_clearready()
	remove_task(876101) // abort all tasks, just in case
	remove_task(876102)
	remove_task(876103)
	remove_task(876104)
	remove_task(876105)
	remove_task(876106)
	remove_task(876107)
	remove_task(876108)
	remove_task(876109)
	remove_task(876110)
	remove_task(876111) 
	remove_task(876112) 
	disc_pl_count=0										

	r_r("1")
	war_live = 3
	t_score[0][0] = t_score[0][0] - t_score[0][2]
	t_score[0][2] = 0
	t_score[1][0] = t_score[1][0] - t_score[1][2]
	t_score[1][2] = 0
	set_task(float(1),"war_warmup",876110)
	return PLUGIN_HANDLED
}

// counts down get_cvar_num("aw_countdowntime") seconds to match start
public war_countdown(){
#if defined DEBUG
	server_print("* war_countdown()")
#endif
	if(war_countdowntimer > 0) {
		war_hudtext(0,"hud_start5",2,2,14)
		war_countdowntimer--
		set_task(1.0,"war_countdown",876103)
	}
	//else
	 //{
	//	if((war_live==1) && (get_cvar_num("aw_assign_mode")==2) && (period_number == 0)) war_hudtext(0,"hud_start3k",10,2,10)
	//	else war_hudtext(0,"hud_start3",10,2,10)
	 //}
	return PLUGIN_CONTINUE
}

// starts a match regardless of ready players
public war_forcestart(id){
#if defined DEBUG
	server_print("* war_forcestart(%d)",id)
#endif
	new tmp = 0
	if (id == 876112) {id = 0;tmp=1;}
	if (id && !((get_user_flags(id) & ADMIN_LEVEL_A))) { 
		war_clienttext("clt_noaccess",id)
		war_servertext("clt_noaccess")
		return PLUGIN_HANDLED
	}
	if((war_live%2 > 0) && (war_live != 5)) {
		if((p_ready[0]+p_ready[1] < minready*2) && (war_countdowntimer == 0)) {
			new adminname[32]
			get_user_name(id,adminname,31)
			if(tmp)
			 {
 			   war_hudtext(0,"hud_start8a",6,6,10)
			   remove_task(876112)
	      		   log_to_file(logfile,"Clanmatch autostarted by warmup timer")
			 }
			else
			 {
			   war_hudtext(0,"hud_start8",6,6,10)
			   log_to_file(logfile,"Clanmatch autostarted by %s",adminname)
			 }
			remove_task(876102)
			war_clearready()
			war_makeallready()
			warauto = 1
			set_task(2.0,"war_prestart")
			war_clienttext("clt_start3a",0)
		}
		else
		{
		 	if(id!=0) war_clienttext("clt_start3b",0)
			else war_servertext("clt_start3b")
		}
	}
	if(war_live==0) if (id!=0) war_clienttext("clt_abort",id); else war_servertext("clt_abort")
	return PLUGIN_HANDLED
}

// ================================= SCORE ====================================
// ============================================================================
public  bomb_explode (planter, defuser){
#if defined DEBUG
	server_print("* bomb_explode(%d, %d)", planter, defuser)
#endif
	if((war_live > 0) && (get_cvar_num("aw_onlykillfrags")==1))
	{
		new name[32]
		get_user_name(planter, name, 31)
		set_user_frags(planter, get_user_frags(planter)-3)
	}
	return PLUGIN_CONTINUE
}

public bomb_defused ( defuser ){
#if defined DEBUG
	server_print("* bomb_defused(%d)",defuser)
#endif
	if((war_live > 0) && (get_cvar_num("aw_onlykillfrags")==1))
	{
		new name[32]
		get_user_name(defuser, name, 31)
		set_user_frags(defuser, get_user_frags(defuser)-3)
	}
	return PLUGIN_CONTINUE
}
public log_stats(mode[]){
#if defined DEBUG
	server_print("* log_stats(%s)", mode)
#endif
	new players[32],num_players,i,str[256],weapstr[64], len
	new ip[17], name[64]
	new live = war_live
	new Weapons[32], numWeapons = 0, clip, ammo, j
	if(war_live%2!=0) live++
	
	format(str,127,"war_live=%d^nperiod_number=%d^nwichmap=%d^nt1score=%d^nt1score1=%d^nt1score2=%d^nt2score=%d^nt2score1=%d^nt2score2=%d^n",live,period_number,wichmap,t_score[t1startside][0],t_score[t1startside][1],t_score[t1startside][2],t_score[t2startside][0],t_score[t2startside][1],t_score[t2startside][2])
	delete_file(statsfile)
	write_file(statsfile, str)
#if defined DEBUG
	server_print("%s^nmode=%s",str, mode)
#endif    
	if(str_to_num(mode) == 1)
	 {
	   get_players(players,num_players,"ah")
	   for(i=0;i<num_players;i++)
	    {
	   	get_user_ip(players[i],ip,16,1)
	  	get_user_name(players[i],name,63)
		get_user_weapons(players[i], Weapons, numWeapons)
		len = 0
		for (j=0; j<numWeapons; j++) if((Weapons[j]!=6)&&(Weapons[j]!=29)) //Weapon is not bomb or knife
		{
			get_user_ammo(players[i], Weapons[j], clip, ammo)
			len += format(weapstr[len],63-len,"%d:%d:%d ", Weapons[j], clip, ammo)
			Weapons[j] = 0
		}
		numWeapons = 0 
	  	format(str,255,"ip=%s,name=^"%s^",deaths=%d,frags=%d,money=%d,armor=%d-%d,defuse=%d,%s", ip, name, get_user_deaths(players[i]), get_user_frags(players[i]), cs_get_user_money(players[i]), get_user_armor(players[i]),get_pdata_int(players[i],112),cs_get_user_defuse(players[i]),weapstr)
		#if defined DEBUG
			server_print("%s",str)
		#endif
	   	write_file (statsfile, str)
	    } 
	   format(str,127,"")
	   write_file (statsfile, str)
	 }
	return PLUGIN_CONTINUE
}

// displays match score if client say_team score
public war_get_score(id) {
#if defined DEBUG
	server_print("* war_get_score(%d)", id)
#endif
	if(war_live == 0) return PLUGIN_HANDLED
	if((gametype == 3) || (gametype == 4)) war_clienttext("clt_info3a",id)
	else if(gametype == 5) war_clienttext("clt_info3c",id)
	else war_clienttext("clt_info3b",id)
	war_clienttext("clt_info3d",id)
	return PLUGIN_HANDLED
}

// displays time remaining in match to client
public war_gettime(id) {
#if defined DEBUG
	server_print("* war_gettime(%d)", id)
#endif
	if(((gametype == 3) || (gametype == 4)) && (war_live > 0)) war_clienttext("clt_info1",id)
	else return PLUGIN_CONTINUE
	return PLUGIN_HANDLED
}
// if timelimit has been reached
public war_timelimit() {
#if defined DEBUG
	server_print("* war_timelimit()")
#endif
	if(war_live == 2) { // 1st half finished
		war_live = 3
		new x
		if(get_cvar_num("aw_autoteam") == 1) x = war_hudtext(0,"hud_stop1a",20,2,10)
		else x = war_hudtext(0,"hud_stop1b",20,2,10)
		log_to_file(logfile,"%s Round %i halftime, score: %s %i - %s %i",mi[wichmap],period_number,t_name[0],t_score[0][0],t_name[1],t_score[1][0])
		half_active = 0
		war_ss()
		server_cmd("sv_restartround 1")
		if(get_cvar_num("aw_swapteams") == 1) set_task(float(x),"swap_teams")
		set_task(float(x-2),"war_warmup")
	} // ENDIF 1st half finished
	if(war_live == 4) { // 2nd half finished
		if(gametype == 3) {
			if(wichmap == 1) {
				if(t_score[0][0] > t_score[1][0]) { wichmap = 0; war_scoremsg(); } // first team won
				else if(t_score[0][0] == t_score[1][0]) war_tied() // first map in tl can't be tied, overtime
				else war_scoremsg() // second team won, moving on to next map
			}
			else if(wichmap == 2) {
				if(t_score[0][0] == t_score[1][0]) war_tied() // can't be tied
				else war_scoremsg() // either team won
			}
			else {
				if(t_score[0][0] == t_score[1][0]) { if(get_cvar_num("aw_tie") == 0) war_tied(); else war_tiedend(); } // tie
				else war_scoremsg() // either team won
			}
		}
		else if(gametype == 4) {
			if(wichmap == 1) war_scoremsg() // moving on to next map
			else if(wichmap == 2) {
				if(t_score[0][0] == t_score[1][0]) { if(get_cvar_num("aw_tie") == 0) war_tied(); else war_tiedend(); } // tie
				else war_scoremsg() // either team won
			}
			else {
				if(t_score[0][0] == t_score[1][0]) { if(get_cvar_num("aw_tie") == 0) war_tied(); else war_tiedend(); } // tie
				else war_scoremsg() // either team won
			}
		}
	} // ENDIF 2nd half finished				
	return PLUGIN_CONTINUE
}

// the terrorists scored
public war_score_t() {
#if defined DEBUG
	server_print("* war_score_t()")
#endif
	if(knife_active)
	 {
		if(captain_id[1]!=0) war_show_sts(captain_id[1])
	 }
	else if(half_active == 1) 
	 {
		if(war_live == 2) war_score_check(t2startside,1)
		else if(war_live == 4) war_score_check(t1startside,2)
	 }
	else if((war_live%2 > 0) && (war_live != 5) && !knife_active) set_task(5.0,"war_warmup_info",876104)
	return PLUGIN_CONTINUE
}

// the counter-terrorists scored
public war_score_ct() {
#if defined DEBUG
	server_print("* war_score_ct()")
#endif
	if(knife_active)
	 {
		if(captain_id[0]!=0) war_show_sts(captain_id[0])
	 }
	if(half_active == 1) {
		if(war_live == 2) war_score_check(t1startside,1)
		else if(war_live == 4) war_score_check(t2startside,2)
	}
	else if((war_live%2 > 0) && (war_live != 5) && !knife_active) set_task(5.0,"war_warmup_info",876104)
	return PLUGIN_CONTINUE
}

// displays important messages at beginning of round
public war_scoreinfo() {
#if defined DEBUG
	server_print("* war_scoreinfo()")
#endif
	if(half_active == 1)
		if((gametype == 3) || (gametype == 4)) war_hudtext(0,"hud_play1b",20,2,10)
		else war_hudtext(0,"hud_play1a",20,2,10)
	return PLUGIN_CONTINUE
}

// checks to see if halftime or game end have been reaced, this function is a bastard with about a million if's
public war_score_check(scoringteam,scoringhalf) {
#if defined DEBUG
	server_print("* war_score_check(%d, %d)",scoringteam,scoringhalf)
#endif
  t_score[scoringteam][scoringhalf]++
  t_score[scoringteam][0]++
#if defined DEBUG  
  server_print("wichmap=%d,gametype=%d,rounds=%d,totrounds=%d,war_live=%d",wichmap,gametype,rounds,totrounds,war_live)
  server_print("t_score[t1]={%d,%d,%d},t_score[t2]={%d,%d,%d}", t_score[0][0],t_score[0][1],t_score[0][2],t_score[1][0],t_score[1][1],t_score[1][2])
  server_print("aw_tie=%d",get_cvar_num("aw_tie"))
#endif  
  new sides[2][3] = { "CT", "T" }
  log_to_file(logfile,"Team %s playing as %s scored in %s round %i %s half, %i-%i",t_name[scoringteam],(scoringteam == scoringhalf-1) ? sides[t1startside] : sides[t2startside],mi[wichmap],period_number,(war_live <= 2) ? "1st" : "2nd",t_score[0][0],t_score[1][0])
  set_task(6.0,"war_scoreinfo",876106)
  if((gametype != 3) && (gametype != 4)) // game played is not timelimit
   {
     if(war_live == 2) // 1st half
      {	
	if((gametype == 2) && (wichmap == 2) && ((t_score[0][0] > totrounds) || (t_score[1][0] > totrounds))) war_scoremsg() // one team won
	else  // go to 2nd half
	 {
	   if(((gametype != 5) && (t_score[0][1]+t_score[1][1] == rounds)) || ((gametype == 5) && ((t_score[0][1] == rounds) || (t_score[1][1] == rounds)))) // all rounds in 1st half played
	     {
	       war_live = 3
	       war_ss()
	       set_task(5.0,"log_stats",0,"0",1)
	       if(get_cvar_num("aw_swapteams") == 1) set_task(1.0,"swap_teams")
	       log_to_file(logfile,"Round %i halftime, score: %s %i - %s %i",period_number,t_name[0],t_score[0][0],t_name[1],t_score[1][0])
	       set_task(1.0,"war_warmup",876110)
	     } // ENDIF all rounds in 1st half played
	    else set_task(5.0,"log_stats",0,"1",1)
	 } // ENDIF go to 2nd half
      } // ENDIF 1st half
     if(war_live == 4) // 2nd half
      {
        if(wichmap == 0) // only one map in the game
         {
	  if(gametype == 0) // maxrounds+1 (mr)
	   {
	     if((t_score[0][1]+t_score[0][2]<rounds+1)&&(t_score[1][1]+t_score[1][2]<rounds+1)&&(t_score[0][2]+t_score[1][2]<rounds)) set_task(5.0,"log_stats",0,"1",1)
	     if((t_score[0][0] == t_score[1][0]) && (t_score[0][2]+t_score[1][2] == rounds))
	      { 
	        if(get_cvar_num("aw_tie") == 0) war_tied()
	        else war_tiedend()
	      } // game is tied
	     else if((t_score[0][0]>totrounds)||(t_score[1][0]>totrounds)) war_scoremsg()
	   } // ENDIF maxrounds+1 (mr)
	  if((gametype == 1) || (gametype == 2)) // maxrounds*2 (mx,mz)
	   {
	     if(t_score[0][2]+t_score[1][2] == rounds)
	      {
	        if((t_score[0][0] == t_score[1][0])) // game is tied
	         { 
	           if(get_cvar_num("aw_tie") == 0) war_tied()
	           else war_tiedend()
	         }
	        else war_scoremsg()
	      }
	     else set_task(5.0,"log_stats",0,"1",1)
	   } // ENDIF maxrounds*2 (mx,mz)
	  if(gametype == 5) // winlimit (wl)
   	   {
	     if((t_score[0][2] == rounds) || (t_score[1][2] == rounds))
	      {
	        if(t_score[0][0] == t_score[1][0]) 
	         {
	           if(get_cvar_num("aw_tie") == 0) war_tied()
	           else war_tiedend()
	         }
	        else war_scoremsg()
	      }
	     else set_task(5.0,"log_stats",0,"1",1)
	   } // ENDIF winlimit (wl)
         } // ENDIF only one map in the game
        else if(wichmap == 1)// 2 maps, first map
	{
	  if(gametype == 0) // two individual maps (mr)
	   {	
	     if((t_score[0][1]+t_score[0][2]<rounds+1)&&(t_score[1][1]+t_score[1][2]<rounds+1)&&(t_score[0][2]+t_score[1][2]<rounds)) set_task(5.0,"log_stats",0,"1",1)
	     if((t_score[0][0] == t_score[1][0]) && (t_score[0][2]+t_score[1][2] == rounds)) war_tied() // first map in mr games cannot be tied
	     else if(t_score[0][0] > totrounds) { wichmap = 0; war_scoremsg(); } // if team1 wins first it's over
	     else if(t_score[1][0] > totrounds) { war_scoremsg(); }
	   } // ENDIF two individual maps (mr)
	  else if((gametype == 1) || (gametype == 2))
	   {
	     if(t_score[0][2]+t_score[1][2] == rounds) war_scoremsg() // two maps (mx,mz)
	     else set_task(5.0,"log_stats",0,"1",1)
	   }
	} // ENDIF 2 maps, first map
        else if(wichmap == 2)// 2 maps, second map
	{
	  if(gametype == 0)// two individual maps (mr)
	   {
	     if((t_score[0][1]+t_score[0][2]<rounds+1)&&(t_score[1][1]+t_score[1][2]<rounds+1)&&(t_score[0][2]+t_score[1][2]<rounds)) set_task(5.0,"log_stats",0,"1",1)
	     if((t_score[0][0] == t_score[1][0]) && (t_score[0][2]+t_score[1][2] == rounds)) war_tied() // second map in mr games cannot be tied
	     else if((t_score[0][0] > totrounds) || (t_score[1][0] > totrounds)) war_scoremsg()
	   } // ENDIF two individual maps (mr)
	  else if(gametype == 1) // two maps (mx)
	   {
	     if(t_score[0][2]+t_score[1][2] == rounds)
	      {
	        if(t_score[0][0] == t_score[1][0])
		{	
		  if(get_cvar_num("aw_tie") == 0) war_tied()
		  else war_tiedend()
		} // game is tied
	        else war_scoremsg() // one team won
	      }
	     else set_task(5.0,"log_stats",0,"1",1)
	   } // ENDIF two maps (mx)
	  else if(gametype == 2)
	   {
	     if(t_score[0][2]+t_score[1][2] < rounds) set_task(5.0,"log_stats",0,"1",1)
	     if((t_score[0][0] == t_score[1][0]) && (t_score[0][2]+t_score[1][2] == rounds)) 
	      { 
	        if(get_cvar_num("aw_tie") == 0) war_tied()
	        else war_tiedend()
	      }
	     else if((t_score[0][0] > totrounds) || (t_score[1][0] > totrounds)) war_scoremsg() // one team won
	   }
	} // ENDIF 2 maps, second map
      } // ENDIF 2nd half
   } // ENDIF game played is not timelimit
  return PLUGIN_CONTINUE
}

// if war is tied, enter overtime
public war_tied() {
#if defined DEBUG
	server_print("* war_tied()")
#endif
	half_active = 0
	war_live = 1
	if(period_number == 0) rounds = get_cvar_num("aw_ot_rounds")
	totrounds += rounds
	period_number++
	set_task(5.0,"log_stats",0,"0",1)
	new x
	if(get_cvar_num("aw_swapteams") == 1) x = war_hudtext(0,"hud_stop2a",20,2,6)
	else x = war_hudtext(0,"hud_stop2b",20,2,6)
	if(gametype < 3) gametype = 0 // mr overtime games should only go to mr+1
	log_to_file(logfile,"Clanmatch tied after %s round %i, score: %s %i - %s %i",mi[wichmap],period_number,t_name[0],t_score[0][0],t_name[1],t_score[1][0])
	set_task(float(x+1),"war_warmup",876110)
	war_ss()
	set_task(float(x),"swap_teams")
	return PLUGIN_CONTINUE
}

// if game is tied and get_cvar_num("aw_tie") == 1, match end here
public war_tiedend() {
#if defined DEBUG
	server_print("* war_tiedend()")
#endif
	half_active = 0
	new x = war_hudtext(0,"hud_stop5",60,2,10)
	log_to_file(logfile,"Clanmatch finished, it's a tie^nFinal score: %s %i - %s %i",t_name[0],t_score[0][0],t_name[1],t_score[1][0])
	set_task(float(x),"war_end",0,"0")
}

// changes to second map
public war_to2ndmap() {
#if defined DEBUG
	server_print("* war_to2ndmap()")
#endif
	war_live = 0
	server_cmd("changelevel %s", map2)
	return PLUGIN_CONTINUE
}

// endscore
public war_scoremsg() {
#if defined DEBUG
	server_print("* war_scoremsg()")
#endif
	remove_task(876106)
	new x
	half_active = 0
	war_live = 5
	if(wichmap == 1) { // will start second map
		x = war_hudtext(0,"hud_stop3",30,2,10)
		log_to_file(logfile,"1st map finished, score: %s %i - %s %i",t_name[0],t_score[0][0],t_name[1],t_score[1][0])
		wichmap = 2
		set_vaultdata("aws_currentmap", "2")
		war_clearready()
		new tmp[4]
		if((gametype == 0) || (gametype == 3)) {
			set_vaultdata("aws_team1score","-1")
			set_vaultdata("aws_team2score","-1")
		}
		else {
			num_to_str(t_score[0][0],tmp,3)
			set_vaultdata("aws_team1score",tmp)
			num_to_str(t_score[1][0],tmp,3)
			set_vaultdata("aws_team2score",tmp)
		}

#if defined HLTV_SUPPORT
		set_task(float(hltv_rec_delay),"war_hltvstop")	
#endif
		set_task(float(x),"war_to2ndmap",876108)
		war_countdowntimer = x
		set_task(1.0,"war_levelcountdown",876107,"",0,"b")
	}
	else { // match ended
		//war_endhack()
		set_task(5.0,"war_endhack")
		log_to_file(logfile,"Clanmatch finished, final score: %s %i - %s %i",t_name[0],t_score[0][0],t_name[1],t_score[1][0])
		set_task(10.0,"war_end",0,"0")
	}
	war_ss()
	return PLUGIN_CONTINUE
}

// LAME!!!!
public war_endhack() war_hudtext(0,"hud_stop4",60,2,10)
// counts down to map change
public war_levelcountdown() {
#if defined DEBUG
	server_print("* war_levelcountdown()")
#endif
	war_hudtext(0,"hud_stop7",2,2,14)
	if(war_countdowntimer > 0) war_countdowntimer--
	else remove_task(876107)
	return PLUGIN_CONTINUE
}

// ============================================================================
// =============================== END MATCH ==================================
// ============================================================================

// called when match end
public war_end(abort){
#if defined DEBUG
	server_print("* war_end(%d)", abort)
#endif
	war_clearvault()
	wichmap = 0
	war_live = 0
	war_countdowntimer = 0
	match_restored = 0
	knife_active = 0
	assigned = 0
	returned_players_num = 0
	war_clearready()
	remove_task(876101) // abort all tasks, just in case
	remove_task(876102)
	remove_task(876103)
	remove_task(876104)
	remove_task(876105)
	remove_task(876106)
	remove_task(876107)
	remove_task(876108)
	remove_task(876109)
	remove_task(876110)
	remove_task(876111) 
	remove_task(876112) 
	#if defined HLTV_SUPPORT
		if(abort) war_hltvstop()
		else if(hltv_address != -1) set_task(float(hltv_rec_delay),"war_hltvstop")
	#endif
	disc_pl_count=0										
	t1startside = 0										
	t2startside = 1										
	format(whosready[0],255,"")
	format(whosready[1],255,"")

	new tmp[64]
	get_cvar_string("aw_penacfg",tmp,63)

	server_cmd("exec ^"%s/%s^"",cfgdir,tmp)

	get_cvar_string("aw_pubcfg",tmp,63)
	server_cmd("exec ^"%s^"",tmp)
	if(!equal(war_password,"NOTHING")) server_cmd("sv_password ^"^"")
	if(hltv_address == -1) 
	 {	
		log_to_file(logfile,"End AMX WAR plugin, goodbye")
		log_to_file(logfile,"********************************************************************************************")
	 }
	delete_file(statsfile)
	delete_file(matchcfgfile)
	captain_id[0] = 0
	captain_id[1] = 0
	return PLUGIN_HANDLED
}

// used to abort a match immediately
public war_abort(id) {
#if defined DEBUG
	server_print("* war_abort(%d)",id)
#endif
	if (id && !((get_user_flags(id) & ADMIN_LEVEL_A))) { 
		war_clienttext("clt_noaccess",id)
		return PLUGIN_HANDLED
	}
	if(war_live == 0)
	{
		if(id!=0) war_clienttext("clt_abort",id); else war_servertext("clt_abort")
		return PLUGIN_HANDLED
	}
	new adminname[32]
	get_user_name(id,adminname,31)
	war_hudtext(0,"hud_stop6",20,2,6)
	war_clienttext("clt_start4",id)
	log_to_file(logfile,"Clanmatch aborted by %s",adminname)
	war_end(1)
	return PLUGIN_HANDLED
}

// ============================================================================
// ================================ HLTV ======================================
// ============================================================================

#if defined HLTV_SUPPORT

// start recording of hltv demo
public war_hltvrecord() {
#if defined DEBUG
	server_print("* war_hltvrecord()")
#endif
	if(hltv_address == -1) return PLUGIN_CONTINUE

	new demoname[128]
	format(demoname,127,"%s-vs-%s-hltv",t_name[0],t_name[1]) 

	// Remove bad strings before recording 
	while(replace(demoname,256,"/","-")) {}    
	while(replace(demoname,256,"\","-")) {} 
	while(replace(demoname,256,":","-")) {} 
	while(replace(demoname,256,"*","-")) {} 
	while(replace(demoname,256,"?","-")) {} 
	while(replace(demoname,256,">","-")) {} 
	while(replace(demoname,256,"<","-")) {} 
	while(replace(demoname,256,"|","-")) {} 

	log_to_file(logfile,"Started recording HLTV demo to %s",demoname)
	format(demoname,127,"record ^"demos\%s^"",demoname)
	hltv_rcon("stoprecording")
	read_HLTV(0)

	hltv_rcon(demoname)
	set_task(0.5,"read_HLTV",2)
	return PLUGIN_CONTINUE
}    

// stop recording of hltv demo
public war_hltvstop() { 
#if defined DEBUG
	server_print("* war_hltvstop()")
#endif
	if(hltv_address == -1) return PLUGIN_CONTINUE
	hltv_rcon("stoprecording")
	set_task(0.5,"read_HLTV",3)
	hltv_recording=0
	log_to_file(logfile,"Stopped recording HLTV demo")
	if(wichmap != 2) {
		log_to_file(logfile,"End AMX WAR plugin, goodbye")
		log_to_file(logfile,"********************************************************************************************")
	}
	return PLUGIN_CONTINUE
}

// send rcon command to hltv server
public hltv_rcon(cmd[]) {
#if defined DEBUG
	server_print("* hltv_rcon(%s)",cmd)
#endif
	new error
	new rconid[13] 
	new rcv[256],snd[256] 

	// Connect to HLTV Proxy 
	hltv_address = socket_open(hltv_ip, hltv_port, SOCKET_UDP, error) 
	if (error != 0) { 
		server_print("HLTV Proxy Connection Failed - error %i",error) 
		return PLUGIN_CONTINUE 
	}

	//send challenge rcon and receive response 
	setc(snd,4,0xff) 
	format(snd[4],255,"challenge rcon") 
	setc(snd[18],1,'^n') 
	socket_send(hltv_address,snd,255) 
	socket_recv(hltv_address,rcv,255) 

	// get hltv rcon challenge number from response 
	format(rconid,12,"%s",rcv[19]) 
	replace(rconid,255,"^n","") 
     
	// send rcon command and close socket 
	setc(snd,255,0x00) 
	setc(snd,4,0xff) 
	format(snd[4],255,"rcon %s ^"%s^" %s^n",rconid,hltv_pass,cmd) 
	socket_send(hltv_address,snd,255)
	return PLUGIN_CONTINUE
}
#endif

// ============================================================================
// ================================= MENU =====================================
// ============================================================================

public war_action_mm(id,key) {
#if defined DEBUG
	server_print("* war_action_mm(%d,%d)",id,key)
#endif
	switch(key){
		case 0:
			if((war_live == 0) && (war_live != 5)) war_show_wm(id)
		case 1:
			if(war_live > 0) war_abort(id)
		case 2:
			if((war_live != 0) && (war_live%2 > 0) && (war_live != 5)) war_forcestart(id)
		case 3:
			war_show_sm(id)
	}
	return PLUGIN_HANDLED
}

public war_show_mm(id) {
#if defined DEBUG
	server_print("* war_show_mm(%d)",id)
#endif
	if (id && !((get_user_flags(id) & ADMIN_LEVEL_A))) { 
		war_clienttext("clt_noaccess",id)
		return PLUGIN_HANDLED
	}
	new menu_body[512]
	new keys = (1<<9)|(1<<3)
	new len = format(menu_body,511,"\yAMX War System^n^n")

	if(war_live > 0) {
		len += format(menu_body[len],511-len,"\d1. Start a Match^n\w2. Abort current match^n")
		keys |= (1<<1)
	}
	else {
		len += format(menu_body[len],511-len,"\w1. Start a Match^n\d2. Abort current match^n")
		keys |= (1<<0)
	}

	if((war_live > 0) && (war_live%2 > 0) && (war_live != 5)) {
		len += format(menu_body[len],511-len,"\w3. Autostart current match^n")
		keys |= (1<<2)
	}
	else len += format(menu_body[len],511-len,"\d3. Autostart current match^n")

	format(menu_body[len],511-len,"\w4. Settings^n^n0. Exit")

	war_loadini()
	war_findtags()
	show_menu(id,keys,menu_body)
	return PLUGIN_HANDLED
}

public war_action_sm(id,key) {
#if defined DEBUG
	server_print("* war_action_sm(%d,%d)",id,key)
#endif
	new x
	new filename[128]
	format(filename,127,"%s/amxwar.cfg",cfgdir)
	if(sm_page==0)
	{
		switch(key) 
		{
			case 0: {
				x = get_cvar_num("aw_tie")+1
				if(x > 1) x = 0
				set_cvar_num("aw_tie",x)
				war_show_sm(id)
			}
			case 1: {
				x = get_cvar_num("aw_countdowntime");if(x%5==0) x+=5;else while(x %5 !=0) x++
				if(x > 30) x = 0
				set_cvar_num("aw_countdowntime",x)
				war_show_sm(id)
			}
			case 2: {
				x = get_cvar_num("aw_warmup_timelimit");if(x%5==0) x+=5;else while(x %5 !=0) x++
				if(x > 30) x = 0
				set_cvar_num("aw_warmup_timelimit",x)
				war_show_sm(id)
			}
			case 3: {
				x = get_cvar_num("aw_assign_mode")+1
				if(x > 2) x = 0
				set_cvar_num("aw_assign_mode",x)
				war_show_sm(id)
			}
			case 4: {
				x = get_cvar_num("aw_autoteam")+1
				if(x > 1) x = 0
				set_cvar_num("aw_autoteam",x)
				war_show_sm(id)
			}
			case 5: {
				x = get_cvar_num("aw_demos")+1
				if(x > 2) x = 0
				set_cvar_num("aw_demos",x)
				war_show_sm(id)
			}
			case 6: {
				x = get_cvar_num("aw_screenshots")+1
				if(x > 2) x = 0
				set_cvar_num("aw_screenshots",x)
				war_show_sm(id)
			}
			case 7: {
				delete_file(filename)
				log_settings(filename)
				war_show_sm(id)
			}
			case 8: {
				sm_page++
				war_show_sm(id)
			}
			case 9: war_show_mm(id)
		}
	}else
	if(sm_page==1)
	{
		switch(key) 
		{
			case 0: {
				x = get_cvar_num("aw_onlykillfrags")+1
				if(x > 1) x = 0
				set_cvar_num("aw_onlykillfrags",x)
				war_show_sm(id)
			}
			case 1: {
				x = get_cvar_num("aw_check_ip")+1
				if(x > 1) x = 0
				set_cvar_num("aw_check_ip",x)
				war_show_sm(id)
			}
			case 2: {
				x = get_cvar_num("aw_check_name")+1
				if(x > 1) x = 0
				set_cvar_num("aw_check_name",x)
				war_show_sm(id)
			}
			case 3: {
				x = get_cvar_num("aw_return_money_by")
				if(x < 4) x++
				else x = 0 
				set_cvar_num("aw_return_money_by",x)
				war_show_sm(id)
			}
			case 4: {
				x = get_cvar_num("aw_swapteams")+1
				if(x > 1) x=0
				set_cvar_num("aw_swapteams",x)
				war_show_sm(id)
			}
			case 5: {
				x = get_cvar_num("aw_ot_rounds")+1
				if(x > 15) x=2
				set_cvar_num("aw_ot_rounds",x)
				war_show_sm(id)
			}
			case 6: {
				x = get_cvar_num("aw_clantagcheck")+1
				if(x > 1) x = 0
				set_cvar_num("aw_clantagcheck",x)
				war_show_sm(id)
			}
			case 7: {
				delete_file(filename)
				log_settings(filename)
				war_show_sm(id)
			}
			case 8: {
				sm_page--
				war_show_sm(id)
			}
			case 9: war_show_mm(id)
		}
	}
	return PLUGIN_HANDLED
}

public war_show_sm(id) {
#if defined DEBUG
	server_print("* war_show_sm(%d)",id)
#endif
	new menu_body[512]
	new keys
	new len = format(menu_body,511,"\yAMX War Settings: Page %d^n\dIf two maps are being played and gametype is either mr or tl,^ntied games switch has no effect^nCointoss will randomly choose wich team begins as CT^n^n",sm_page)
	new q_format[11][20] = { "No", "Ye s", "A sk", "D  isab  le", "N am e or  IP", "IP", "N am e", "N am e and  IP", "O ff", "Co in to ss", "Kn ife"}
	war_fixcvar("aw_tie",0,1)
	war_fixcvar("aw_assign_mode",0,2)
	war_fixcvar("aw_autoteam",0,1)
	war_fixcvar("aw_clantagcheck",0,1)
	war_fixcvar("aw_demos",0,2)
	war_fixcvar("aw_screenshots",0,2)
	if(sm_page==0)
	{
		if((war_live != 0) && (war_live != 5)) {
			len += format(menu_body[len],511-len,  "\w1. Tied games\R\y%s",q_format[get_cvar_num("aw_tie")])
			len += format(menu_body[len],511-len,"^n\d2. Countdown Timer\R\d%d",get_cvar_num("aw_countdowntime"))
			len += format(menu_body[len],511-len,"^n\w3. Warmup timelimit\R\y%d",get_cvar_num("aw_warmup_timelimit"))
			len += format(menu_body[len],511-len,"^n\d4. Assign Team mode\R\d%s",q_format[get_cvar_num("aw_assign_mode")+8])
			len += format(menu_body[len],511-len,"^n\w5. Autoassign teams\R\y%s",q_format[get_cvar_num("aw_autoteam")])
			len += format(menu_body[len],511-len,"^n\d6. Record client demos\R\d%s",q_format[get_cvar_num("aw_demos")])
			len += format(menu_body[len],511-len,"^n\w7. Take client screenshots\R\y%s^n",q_format[get_cvar_num("aw_screenshots")])

			len += format(menu_body[len],511-len,"^n\y8. Save amxwar.cfg")
			len += format(menu_body[len],511-len,"^n\y9. More")
			len += format(menu_body[len],511-len,"^n\y0. Back")
			keys = (1<<0|1<<2|1<<4|1<<6|1<<7|1<<8|1<<9)
		}
		else {
			len += format(menu_body[len],511-len,    "\w1. Tied games\R\y%s",q_format[get_cvar_num("aw_tie")])
			len += format(menu_body[len],511-len,  "^n\w2. Countdown Timer\R\y%d",get_cvar_num("aw_countdowntime"))
			len += format(menu_body[len],511-len,  "^n\w3. Warmup timelimit\R\y%d",get_cvar_num("aw_warmup_timelimit"))
			len += format(menu_body[len],511-len,  "^n\w4. Assign Team mode\R\y%s",q_format[get_cvar_num("aw_assign_mode")+8])
			len += format(menu_body[len],511-len,  "^n\w5. Autoassign teams\R\y%s",q_format[get_cvar_num("aw_autoteam")])
			len += format(menu_body[len],511-len,  "^n\w6. Record client demos\R\y%s",q_format[get_cvar_num("aw_demos")])
			len += format(menu_body[len],511-len,  "^n\w7. Take client screenshots\R\y%s^n",q_format[get_cvar_num("aw_screenshots")])

			len += format(menu_body[len],511-len,  "^n\y8. Save amxwar.cfg")
			len += format(menu_body[len],511-len,  "^n\y9. More")
			len += format(menu_body[len],511-len,  "^n\y0. Exit")
			keys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
		}
	}
	if(sm_page==1)
	{
		len += format(menu_body[len],511-len,  "\w1. Only kill frags\R\y%s", q_format[get_cvar_num("aw_onlykillfrags")])
		len += format(menu_body[len],511-len,"^n\w2. Check player ip\R\y%s", q_format[get_cvar_num("aw_check_ip")])
		len += format(menu_body[len],511-len,"^n\w3. Check player name\R\y%s", q_format[get_cvar_num("aw_check_name")])
		len += format(menu_body[len],511-len,"^n\w4. Return money by\R\y%s", q_format[get_cvar_num("aw_return_money_by")+3])
		len += format(menu_body[len],511-len,"^n\w5. Swap teams\R\y%s",q_format[get_cvar_num("aw_swapteams")])

		if(period_number==0) len += format(menu_body[len],511-len,"^n\w")
		else len += format(menu_body[len],511-len,"^n\d")
		len += format(menu_body[len],511-len,"6. Overtime rounds\R\y%d",get_cvar_num("aw_ot_rounds"))

		if(war_live != 0) len += format(menu_body[len],511-len,"^n\d")
		else len += format(menu_body[len],511-len,"^n\w")
		len += format(menu_body[len],511-len,"7. Require clantags\R\y%s",q_format[get_cvar_num("aw_clantagcheck")])

		len += format(menu_body[len],511-len,"^n^n\y8. Save amxwar.cfg")
		len += format(menu_body[len],511-len,"^n\y9. Back")
		len += format(menu_body[len],511-len,"^n\y0. Exit")
		keys = (1<<0|1<<1|1<<2|1<<3|1<<4)
		if(period_number==0) keys += (1<<5)
		if(war_live==0) keys += (1<<6)
		keys += (1<<7|1<<8|1<<9)
	}

	show_menu(id,keys,menu_body)
	return PLUGIN_HANDLED
}

public war_action_wm(id,key){
#if defined DEBUG
	server_print("* war_action_wm(%d,%d)",id,key)
#endif
	switch(key) {
		case 8: {
			new curmap[32],ctmp1[32],ctmp2[32]
			get_mapname(curmap,31)
			if(contain(clans[clan1_toshow],"(AUTO)") != -1)
				format(ctmp1,strlen(clans[clan1_toshow])-6,"%s",clans[clan1_toshow])
			else format(ctmp1,31,"%s",clans[clan1_toshow])

			if(contain(clans[clan2_toshow],"(AUTO)") != -1)
				format(ctmp2,strlen(clans[clan2_toshow])-6,"%s",clans[clan2_toshow])
			else format(ctmp2,31,"%s",clans[clan2_toshow])
			new tmpp[4]
			format(tmpp,4,"%s",menu_gametype)
			client_cmd(id,"aw %s %s %i %s%i map=%s %s%s cfg=%s",ctmp1,ctmp2,menu_minready,menu_gametype,menu_maxrounds,(map1_toshow == 1) ? curmap : maps[map1_toshow],(map2_toshow != 0) ? "map2=":"", (map2_toshow != 0) ? maps[map2_toshow] : "",cfgs[cfg_toshow])
			client_cmd(id,"echo %s %s %i %s%i map=%s %s%s cfg=%s",ctmp1,ctmp2,menu_minready,menu_gametype,menu_maxrounds,(map1_toshow == 1) ? curmap : maps[map1_toshow],(map2_toshow != 0) ? "map2=":"", (map2_toshow != 0) ? maps[map2_toshow] : "",cfgs[cfg_toshow])
		}
		case 9:
			war_show_mm(id)
		case 0: {
			if(clan1_toshow == num_clans-1) clan1_toshow = 0
			else clan1_toshow++
			if(clan1_toshow == clan2_toshow)
				if(clan1_toshow >= num_clans-1) clan1_toshow = 0
				else clan1_toshow++
			war_show_wm(id)
		}
		case 1: {
			if(clan2_toshow == num_clans-1) clan2_toshow = 0
			else clan2_toshow++
			if(clan2_toshow == clan1_toshow)
				if(clan2_toshow >= num_clans-1) clan2_toshow = 0
				else clan2_toshow++
			war_show_wm(id)
		}
		case 2: {
			if(menu_minready >= 10) menu_minready = 1
			else menu_minready++
			war_show_wm(id)
		}
		case 3: {
			if(menu_maxrounds >= 120) menu_maxrounds = 2
			else if(menu_maxrounds >= 60) menu_maxrounds += 10
			else if(menu_maxrounds >= 20) menu_maxrounds += 5
			else menu_maxrounds++
			war_show_wm(id)
		}
		case 4: {
			if(equal(menu_gametype,"mr")) format(menu_gametype,2,"mx")
			else if(equal(menu_gametype,"mx")) format(menu_gametype,2,"mz")
			else if(equal(menu_gametype,"mz")) format(menu_gametype,2,"tl")
			else if(equal(menu_gametype,"tl")) format(menu_gametype,2,"tx")
			else if(equal(menu_gametype,"tx")) format(menu_gametype,2,"wl")
			else if(equal(menu_gametype,"wl")) format(menu_gametype,2,"mr")
			war_show_wm(id)
		}
		case 5: {
			if(map1_toshow >= num_maps-1) map1_toshow = 1
			else map1_toshow++
			war_show_wm(id)
		}
		case 6: {
			if(map2_toshow >= num_maps-1) map2_toshow = 0
			else if(map2_toshow == 0) map2_toshow = 2
			else map2_toshow++
			war_show_wm(id)
		}
		case 7: {
			if(cfg_toshow >= num_cfgs-1) cfg_toshow = 0
			else cfg_toshow++
			war_show_wm(id)
		}
	}
	return PLUGIN_HANDLED
}

public war_show_wm(id) {
#if defined DEBUG
	server_print("* war_show_wm(%d)",id)
#endif
	new menu_body[512],tmp1[4],tmp2[4]
	num_to_str(menu_minready,tmp1,4)
	num_to_str(menu_maxrounds,tmp2,4)
	new keys = (1<<9)|(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)
	new len = format(menu_body,511,"\yAMX War Start^n^n")
	len += format(menu_body[len],511-len,"\w1. Team 1: \y%s^n",clans[clan1_toshow])
	len += format(menu_body[len],511-len,"\w2. Team 2: \y%s^n",clans[clan2_toshow])
	len += format(menu_body[len],511-len,"\w3. Players on each team: \y%s^n",tmp1)
	if((equal(menu_gametype,"tl")) || (equal(menu_gametype,"tx"))) len += format(menu_body[len],511-len,"\w4. Timelimit")
	else if(equal(menu_gametype,"wl")) len += format(menu_body[len],511-len,"\w4. Winlimit")
	else len += format(menu_body[len],511-len,"\w4. Maxrounds")
	len += format(menu_body[len],511-len,": \y%s^n",tmp2)
	len += format(menu_body[len],511-len,"\w5. Gametype: \y%s^n",menu_gametype)
	len += format(menu_body[len],511-len,"\w6. Map 1: \y%s^n",maps[map1_toshow])
	len += format(menu_body[len],511-len,"\w7. Map 2: \y%s^n",maps[map2_toshow])
	len += format(menu_body[len],511-len,"\w8. Configfile: \y%s^n^n",cfgs[cfg_toshow])
	len += format(menu_body[len],511-len,"\y9. Start War^n")
	format(menu_body[len],511-len,"\y0. Back")
	show_menu(id,keys,menu_body)
	return PLUGIN_HANDLED
}

public war_action_sts(id,key){
#if defined DEBUG
	server_print("* war_action_sts(%d,%d)",id,key)
#endif
	new myteam[32], tmp
	get_user_team(id,myteam,31)
	if(equal(myteam,"CT")) tmp = 0; else tmp = 1

	switch(key) 
	 {
		case 0: {
			   	if(tmp==0) //Win team1
				 {
					set_task(1.0,"swap_teams")
					t1startside = 1
					t2startside = 0
				 }
				r_r("1")
				set_task(6.0,"war_prestart")
			}
		case 1: {
			   	if(tmp==1) //Win team2
				 {
					set_task(1.0,"swap_teams")
					t1startside = 1
					t2startside = 0
				 }
				r_r("1")
				set_task(6.0,"war_prestart")
			}
 	 }
	half_active = 1
	assigned = 1

	return PLUGIN_CONTINUE
}

public war_show_sts(id){
#if defined DEBUG
	server_print("* war_show_sts(%d)",id)
#endif
	new menu_body[512], len
	new keys = (1<<0)|(1<<1)

	len  = format(menu_body,255,"\ySELECT START SIDE:") 
	len += format(menu_body[len],255 - len,"^n\w 1. Terrorists")
	len += format(menu_body[len],255 - len,"^n\w 2. Counter-terrorists")

	show_menu(id,keys,menu_body)
	return PLUGIN_HANDLED
}

public war_loadini() {
#if defined DEBUG
	server_print("* war_loadini()")
#endif
	new inifile[64]
	format(inifile,63,"%s/clans.ini", cfgdir)
	if (!file_exists(inifile)) return 0
	new text[128], tag[32], len, pos = 0
	num_clans = 0
	while(read_file(inifile,pos++,text,127,len)) {
		if ((text[0] != ';') && (strlen(text) > 1) && (num_clans < 64)) { // ; = comment
			format(clans[num_clans],31,"%s",text)
			num_clans++
		}
	}

	format(inifile,63,"%s/maps.ini", cfgdir)
	if (!file_exists(inifile)) return 0
	pos = 0
	num_maps = 2
	maps[0] = "None"
	maps[1] = "Current"
	while(read_file(inifile,pos++,text,127,len)) {
		if ((text[0] != ';') && (strlen(text) > 1) && (num_maps < 32)) {
			format(maps[num_maps],31,"%s",text)
			num_maps++
		}
	}

	format(cfgs[num_cfgs],31,"default")
	num_cfgs = 1
	new tmp[128]
	format(tmp,127,"%s/cfg",cfgdir)

	new DirH = open_dir(tmp,tag,31); 
	while(next_file(DirH,tag,31)) {  
#if defined DEBUG
		server_print("====>>> %s <<<====", tag)
#endif
		if(contain(tag,".cfg") != -1) {
			if(!equali(tag,"default.cfg")) {
				copyc(cfgs[num_cfgs],31,tag,'.') 
				num_cfgs++
				if(num_cfgs==64) break;
			}
		}       
	}
	close_dir(DirH)
	
	return PLUGIN_CONTINUE
}

public war_findtags(){
#if defined DEBUG
	server_print("* war_findtags()")
#endif
	new players[32],playername[64],num_players, i, j, tmp[64]
	get_players(players,num_players,"e","CT")
	for(i=0;i<num_players;i++)
	{
		get_user_name(players[i], playername, 63)
		#if defined DEBUG
			server_print("%s",playername)
		#endif
		for(j=0;j<num_clans;j++){
			format(tmp,63,"%s",clans[j][1])
			tmp[strlen(tmp)-1]=0
			#if defined DEBUG
				server_print("====>>> %s",tmp)
			#endif
			if(containi(playername, tmp)==0){
				#if defined DEBUG
					server_print("found %s - %d",tmp, j)
				#endif
				clan1_toshow = j;
				break;
			}
		}
	}
	get_players(players,num_players,"e","TERRORIST")
	for(i=0;i<num_players;i++)
	{
		get_user_name(players[i], playername, 63)
		#if defined DEBUG
			server_print("%s",playername)
		#endif
		for(j=0;j<num_clans;j++) if(clan1_toshow!=j) {
			format(tmp,63,"%s",clans[j][1])
			tmp[strlen(tmp)-1]=0
			#if defined DEBUG
				server_print("====>>> %s",tmp)
			#endif
			if(containi(playername, tmp)==0){
				#if defined DEBUG
					server_print("found %s - %d",tmp, j)
				#endif
				clan2_toshow = j;
				break;
			}
		}
	}
	return PLUGIN_CONTINUE
}

// ============================================================================
// ================================= INIT =====================================
// ============================================================================

public setlogfilename(){
#if defined DEBUG
	server_print("* setlogfilename()")
#endif
	new hostname[64]
	get_cvar_string("hostname",hostname,63) 
	while(replace(hostname,64,"/","-")) {}
	while(replace(hostname,64,"\","-")) {}
	while(replace(hostname,64,":","-")) {}
	while(replace(hostname,64,"*","-")) {}
	while(replace(hostname,64,"?","-")) {}
	while(replace(hostname,64,">","-")) {}
	while(replace(hostname,64,"<","-")) {}
	while(replace(hostname,64,"|","-")) {}
	while(replace(hostname,64," ","-")) {}
	format(logfile,255,"amxwar-%s-",hostname)
	get_time("%m%d.log",hostname,63)
	add(logfile,255,hostname)
}

public init(){
#if defined DEBUG
	server_print("* init()")
#endif
	new m_mr[8], m_gt[8], i, tmp[4]
	menu_minready = get_cvar_num("aw_minready_default")			
	get_cvar_string("aw_gametype_default", m_gt, 7)			
	for(i=2;i<strlen(m_gt);i++) m_mr[i-2]=m_gt[i]				
	menu_maxrounds = str_to_num(m_mr)
	menu_gametype[0]=m_gt[0];menu_gametype[1]=m_gt[1];menu_gametype[2]=0
#if defined DEBUG
	server_print("menu_minready = %d, menu_gametype = %s, menu_maxrounds = %d",menu_minready,menu_gametype,menu_maxrounds)
#endif
	get_basedir(cfgdir,63)
	format(cfgdir,63,"%s/configs/amxwar",cfgdir)
	format(statsfile,127,"%s/roundstats.log",cfgdir)
	format(matchcfgfile,127,"%s/match.cfg",cfgdir)
	
	server_cmd("exec %s/amxwar.cfg",cfgdir)
	
	set_task(3.0,"setlogfilename")
	get_vaultdata("aws_initialized",tmp,3)
	if(str_to_num(tmp) == 1) war_startmapchange()
	
	return PLUGIN_CONTINUE
}

public plugin_init() {
#if defined DEBUG
	server_print("* plugin_init()")
#endif
	register_plugin("AMX War System", AW_VERSION, "Grisbilen")

	register_cvar("aw_countdowntime", "5")
	register_cvar("aw_tie", "1")
	register_cvar("aw_assign_mode", "0")
	register_cvar("aw_autoteam", "1")
	register_cvar("aw_clantagcheck", "0")
	register_cvar("aw_screenshots", "0")
	register_cvar("aw_demos", "2")
	register_cvar("aw_hltv_passw", "")
	register_cvar("aw_check_ip", "0")
	register_cvar("aw_check_name", "1")
	register_cvar("aw_return_money_by", "1")
	register_cvar("aw_swapteams", "1")
	register_cvar("aw_ot_rounds", "5")
	register_cvar("aw_warmup_timelimit", "10")
	register_cvar("aw_restarts", "1 2 3")
	register_cvar("aw_onlykillfrags", "1")
		
	register_cvar("aw_minready_default", "5")
	register_cvar("aw_gametype_default", "mr15")
	register_cvar("aw_warmup_cfg", "default.cfg")
	register_cvar("aw_overtime_cfg", "default.cfg")
	register_cvar("aw_knife_cfg", "default.cfg")

	register_cvar("aw_pubcfg", "server.cfg")
	register_cvar("aw_pdiscfg", "pd.cfg")
	register_cvar("aw_penacfg", "pe.cfg")

	register_event("SendAudio","war_score_t","a","2=%!MRAD_terwin") // terrorists wins
	register_event("SendAudio","war_score_ct","a","2=%!MRAD_ctwin") // ct wins
	register_logevent("bomb_events", 3, "2=Spawned_With_The_Bomb")


	register_concmd("aw","war_begin",ADMIN_LEVEL_A,"- Starts a clanmatch")
	register_concmd("awabort","war_abort",ADMIN_LEVEL_A,"- Aborts a clanmatch immediately")
	register_concmd("awstart","war_forcestart",ADMIN_LEVEL_A,"- Starts a warround immediately")
	register_concmd("awrestart","war_restart",ADMIN_LEVEL_A,"- Restarts map")
	register_concmd("awrestart2","war_restart2",ADMIN_LEVEL_A,"- Restarts current half")
	register_concmd("swap","war_swapnames",ADMIN_LEVEL_A,"- Swap teams names")

	register_clcmd("say ready","war_readycheck")
	register_clcmd("say notready","war_notreadycheck")
	register_clcmd("say_team score","war_get_score")
	register_clcmd("say_team timeleft","war_gettime")
	register_clcmd("say timeleft","war_gettime")
	register_clcmd("say captain","teamcaptain")
	register_clcmd("timeleft","war_gettime")
	
	// Menu
	register_menucmd(register_menuid("\yAMX War Settings"),1023,"war_action_sm")
	register_menucmd(register_menuid("\yAMX War Start"),1023,"war_action_wm")
	register_menucmd(register_menuid("\yAMX War System"),1023,"war_action_mm")

	register_menucmd(register_menuid("\ySELECT START SIDE:"), 1023, "war_action_sts" )

	register_clcmd("awmenu","war_show_mm",ADMIN_LEVEL_A,"- displays war system menu")

	register_menucmd(register_menuid("\yScreenshot"),1023,"war_ss_action")
	register_menucmd(register_menuid("\yRecord Demo"),1023,"war_demo_action")
	register_menucmd(register_menuid("\yStop Recording"),1023,"war_demo_off_action")

	
	set_task(0.0,"init")
	
	return PLUGIN_CONTINUE
}

/*
Task list:
876101	war start
876102	warmup hudmsg
876103	countdown
876104	warmup info
876105	timelimit
876106	scoreinfo
876107	level countdown
876108	change map
876109	starthud
876110	warmup
876111	cointoss init
876112  warmup timelimit autostart
876113  wait for alive
*/
