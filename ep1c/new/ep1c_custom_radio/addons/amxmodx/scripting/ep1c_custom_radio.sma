/* AMX Mod X script.
*
*	Custom Radio TH
*
* This program is free software; you can redistribute it and/or modify it
* under the terms of the GNU General Public License as published by the
* Free Software Foundation; either version 2 of the License, or (at
* your option) any later version.
*
* This program is distributed in the hope that it will be useful, but
* WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software Foundation,
* Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*
* In addition, as a special exception, the author gives permission to
* link the code of this program with the Half-Life Game Engine ("HL
* Engine") and Modified Game Libraries ("MODs") developed by Valve,
* L.L.C ("Valve"). You must obey the GNU General Public License in all
* respects for all of the code used other than the HL Engine and MODs
* from Valve. If you modify this file, you may extend this exception
* to your version of the file, but you are not obligated to do so. If
* you do not wish to do so, delete this exception statement from your
* version.
*/

/*
 *	Localization.
 *
 *	Values:
 *	"server" - server language (amx_language).
 *	"player" - player's language (setinfo "lang").
 *	Specific language in ISO 639-1 format ("en", "ru", etc).
 *
 *	Default: "ru"
 */
#define CRM_LANG_CVAR			"crm_lang"
#define CRM_LANG				"bp"

/*
 *	Pitch shift to imitate different voices.
 *
 *	Values:
 *	"AnyNumber"		- Pitch shift.
 *	"NumMin-NumMax"	- Random value in range.
 *	"0"				- Disable pitch shifting.
 *
 *	Default: "85-120"
 */
#define CRM_PITCH_CVAR			"crm_pitch"
#define CRM_PITCH				"85-120"

/*
 *	Set in seconds how fast players can use radio messages
 *	(radio-flood protection).
 */
#define CRM_FLOODTIME_CVAR		"crm_floodtime"
#define CRM_FLOODTIME			"2.0"

/*
 *	Required access flags for messages marked with the "admin_only" flag.
 *
 *	Default: "c" (ADMIN_KICK)
 */
#define CRM_ADMIN_FLAGS_CVAR	"crm_adminflags"
#define CRM_ADMIN_FLAGS			"c"


#include <amxmodx>
#include <amxmisc>
#include <json>
#include <reapi>
#include <bspfile>


enum Radio
{
	radio1,
	radio2,
	radio3,
	radio4
};

enum _:RadioMsg
{
	text[MAX_FMT_LENGTH],
	Array:sounds,
	flags
};

enum _:Flags (<<= 1)
{
	none = 0,
	t_only = 1,
	ct_only,
	admin_only,
	notadmin_only,
	bomber_only,
	bomb_planted,
	map_with_a,
	map_with_ab,
	map_with_abc,
	map_with_hostages
};

enum _:PlayerData
{
	TeamName:team,
	bool:has_bomb,
	bool:has_admin_access
};

new g_pcvPitch;
new g_pcvLanguage;
new g_pcvFloodTime;
new g_pcvAdminFlags;

new g_iDisableMenuItem;
new g_bitsCurMapFlags = none;
new g_playerData[MAX_PLAYERS + 1][PlayerData];

new g_aRadioTitle[4][96];
new Array:g_arrRadio1 = Invalid_Array;
new Array:g_arrRadio2 = Invalid_Array;
new Array:g_arrRadio3 = Invalid_Array;
new Array:g_arrRadio4 = Invalid_Array;

#define is_player(%1) (0 < %1 <= MaxClients)


public plugin_init()
{
	register_plugin("Custom Radio TH", "1.0.2", "the_hunter");
	register_dictionary("common.txt");
	register_dictionary("custom_radio.txt");

	register_clcmd("radio1", "cmd_radio_a");
	register_clcmd("radio2", "cmd_radio_b");
	register_clcmd("radio3", "cmd_radio_c");
	register_clcmd("radio4", "cmd_radio_d");

	g_iDisableMenuItem = menu_makecallback("disable_menuitem");
	g_pcvLanguage = create_cvar(CRM_LANG_CVAR, CRM_LANG);
	g_pcvPitch = create_cvar(CRM_PITCH_CVAR, CRM_PITCH);
	g_pcvFloodTime = create_cvar(CRM_FLOODTIME_CVAR, CRM_FLOODTIME);
	g_pcvAdminFlags = create_cvar(CRM_ADMIN_FLAGS_CVAR, CRM_ADMIN_FLAGS);

	return PLUGIN_CONTINUE;
}


public plugin_precache()
{
	new szCurMap[MAX_NAME_LENGTH];
	rh_get_mapname(szCurMap, MAX_NAME_LENGTH - 1, MNT_TRUE);

	new szCurBspPath[42];
	bsp_get_path(szCurMap, szCurBspPath, charsmax(szCurBspPath));
	get_map_flags(szCurBspPath, g_bitsCurMapFlags);

	new szConfigsDir[96], szConfigFile[128];
	get_localinfo("amxx_configsdir", szConfigsDir, charsmax(szConfigsDir));

	formatex(szConfigFile, charsmax(szConfigFile), "%s/custom_radio/radio1.json", szConfigsDir);
	read_config(szConfigFile, radio1);

	formatex(szConfigFile, charsmax(szConfigFile), "%s/custom_radio/radio2.json", szConfigsDir);
	read_config(szConfigFile, radio2);

	formatex(szConfigFile, charsmax(szConfigFile), "%s/custom_radio/radio3.json", szConfigsDir);
	read_config(szConfigFile, radio3);

	formatex(szConfigFile, charsmax(szConfigFile), "%s/custom_radio/radio4.json", szConfigsDir);
	read_config(szConfigFile, radio4);

	precache_radio_sounds(g_arrRadio1);
	precache_radio_sounds(g_arrRadio2);
	precache_radio_sounds(g_arrRadio3);
	precache_radio_sounds(g_arrRadio4);

	return PLUGIN_CONTINUE;
}


precache_radio_sounds(Array:arrRadio)
{
	if (arrRadio == Invalid_Array)
		return;

	new iSize = ArraySize(arrRadio);
	if (iSize == 0)
		return;

	new iSoundsNum;
	new radioMsg[RadioMsg];
	new szSound[MAX_RESOURCE_PATH_LENGTH];

	for (new i = 0, Array:arrSounds; i < iSize; i++)
	{
		ArrayGetArray(arrRadio, i, radioMsg, RadioMsg);

		arrSounds = radioMsg[sounds];
		iSoundsNum = ArraySize(arrSounds);

		for (new j = 0; j < iSoundsNum; j++)
		{
			ArrayGetString(arrSounds, j, szSound, charsmax(szSound));
			szSound[0] != '%' && precache_sound(szSound);
		}
	}
}


public cmd_radio_a(iPlayer)
{
	if (g_arrRadio1 != Invalid_Array && is_player(iPlayer))
	{
		menu_radio(iPlayer, radio1, g_arrRadio1);
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}


public cmd_radio_b(iPlayer)
{
	if (g_arrRadio2 != Invalid_Array && is_player(iPlayer))
	{
		menu_radio(iPlayer, radio2, g_arrRadio2);
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}


public cmd_radio_c(iPlayer)
{
	if (g_arrRadio3 != Invalid_Array && is_player(iPlayer))
	{
		menu_radio(iPlayer, radio3, g_arrRadio3);
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}


public cmd_radio_d(iPlayer)
{
	if (g_arrRadio4 != Invalid_Array && is_player(iPlayer))
	{
		menu_radio(iPlayer, radio4, g_arrRadio4);
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}


public plugin_end()
{
	destroy_all_arrays(g_arrRadio1);
	destroy_all_arrays(g_arrRadio2);
	destroy_all_arrays(g_arrRadio3);
	destroy_all_arrays(g_arrRadio4);

	return PLUGIN_CONTINUE;
}


destroy_all_arrays(Array:arrRadio)
{
	if (arrRadio == Invalid_Array)
		return;

	new radioMsg[RadioMsg];
	new iSize = ArraySize(arrRadio);

	for (new i = 0, Array:arrSounds; i < iSize; i++)
	{
		ArrayGetArray(arrRadio, i, radioMsg, RadioMsg);
		arrSounds = radioMsg[sounds];

		if (arrSounds != Invalid_Array)
			ArrayDestroy(arrSounds);
	}

	ArrayDestroy(arrRadio);
}


get_map_flags(const szBspPath[], &bitsFlags = none)
{
	// We need to know if map has hostages or how many bomb sites.
	// But map entities is not initialized at this moment.
	// Let's reading this data directly from a map BSP file.
	// An #include <bspfile> will help us with that.

	bitsFlags = none;
	new szError[MAX_FMT_LENGTH];

	if (!bsp_open(szBspPath, szError, charsmax(szError)))
	{
		log_an_error(szError);
		return bitsFlags;
	}

	if (bsp_lump_ent_containi("^"hostage_entity^""))
	{
		bitsFlags = map_with_hostages;
	}
	else
	{
		switch (bsp_bombplace_get_count())
		{
			case 1:	bitsFlags = map_with_a;
			case 2: bitsFlags = map_with_ab;
			case 3: bitsFlags = map_with_abc;
		}
	}

	// Don't forget close bsp handle.
	bsp_close();

	return bitsFlags;
}


read_config(const szConfigFile[], Radio:radio)
{
	if (!file_exists(szConfigFile))
		return;

	new JSON:jRadio = json_parse(szConfigFile, true, true);

	if (jRadio == Invalid_JSON)
	{
		plugin_end();
		set_fail_state("Could not parse ^"%s^".", szConfigFile);
	}

	if (json_is_object(jRadio))
	{
		deserialize_radio(radio, jRadio);
	}
	else if (json_is_array(jRadio))
	{
		plugin_end();
		set_fail_state("%s^n^tConfiguration files format has changed.^n\
		^tSee details: https://dev-cs.ru/resources/716/extra", szConfigFile);
	}

	free_json_handle_safe(jRadio);
}


deserialize_radio(Radio:radio, const JSON:jRadio)
{
	new JSON:jMessage;
	new JSON:jArrayMessages = json_object_get_value(jRadio, "messages");
	new iElementsCount = json_array_get_count(jArrayMessages);
	new Array:arrRadio = ArrayCreate(RadioMsg, 9);

	for (new i = 0; i < iElementsCount; i++)
	{
		jMessage = json_array_get_value(jArrayMessages, i);

		if (json_is_object(jMessage))
			parse_radio_message(jMessage, arrRadio);

		free_json_handle_safe(jMessage);
	}

	free_json_handle_safe(jArrayMessages);

	if (ArraySize(arrRadio) < 1)
	{
		ArrayDestroy(arrRadio);
		return;
	}

	switch (radio)
	{
		case radio1: g_arrRadio1 = arrRadio;
		case radio2: g_arrRadio2 = arrRadio;
		case radio3: g_arrRadio3 = arrRadio;
		case radio4: g_arrRadio4 = arrRadio;
	}

	json_object_get_string(jRadio, "title",
		g_aRadioTitle[_:radio], charsmax(g_aRadioTitle[]));
}


parse_radio_message(const JSON:jMessage, const Array:arrRadio)
{
	// Fuck the read_flags() because this way is more user friendly.
	new bitsFlags;
	parse_radio_message_flags(jMessage, bitsFlags);

	if (bitsFlags != none)
	{
		if (g_bitsCurMapFlags == none && bitsFlags > bomb_planted)
			return;

		if (g_bitsCurMapFlags == map_with_a && ~bitsFlags & map_with_a)
			return;

		if (g_bitsCurMapFlags == map_with_ab && ~bitsFlags & map_with_ab)
			return;

		if (g_bitsCurMapFlags == map_with_abc && ~bitsFlags & map_with_abc)
			return;

		if (g_bitsCurMapFlags == map_with_hostages && ~bitsFlags & map_with_hostages)
			return;
	}

	new Array:arrSounds = Invalid_Array;
	parse_radio_message_sounds(jMessage, arrSounds);

	new radioMessage[RadioMsg];
	radioMessage[flags] = bitsFlags;
	radioMessage[sounds] = arrSounds;
	json_object_get_string(jMessage, "text", radioMessage[text], charsmax(radioMessage[text]));

	ArrayPushArray(arrRadio, radioMessage, RadioMsg);
}


parse_radio_message_flags(const JSON:jMessage, &bitsFlags)
{
	bitsFlags = none;
	new JSON:jArray = json_object_get_value(jMessage, "flags");

	if (!json_is_array(jArray))
	{
		free_json_handle_safe(jArray);
		return;
	}

	new szFlag[MAX_NAME_LENGTH];
	new iElementsCount = json_array_get_count(jArray);

	for (new i = 0; i < iElementsCount; i++)
	{
		if (!json_array_get_string(jArray, i, szFlag, charsmax(szFlag)))
			continue;

		if (equali("t_only", szFlag))
		{
			bitsFlags |= t_only;
		}
		else if (equali("ct_only", szFlag))
		{
			bitsFlags |= ct_only;
		}
		else if (equali("admin_only", szFlag))
		{
			bitsFlags |= admin_only;
		}
		else if (equali("notadmin_only", szFlag))
		{
			bitsFlags |= notadmin_only;
		}
		else if (equali("bomber_only", szFlag))
		{
			bitsFlags |= bomber_only;
		}
		else if (equali("bomb_planted", szFlag))
		{
			bitsFlags |= bomb_planted;
		}
		else if (equali("map_with_a", szFlag))
		{
			bitsFlags |= map_with_a;
		}
		else if (equali("map_with_ab", szFlag))
		{
			bitsFlags |= map_with_ab;
		}
		else if (equali("map_with_abc", szFlag))
		{
			bitsFlags |= map_with_abc;
		}
		else if (equali("map_with_hostages", szFlag))
		{
			bitsFlags |= map_with_hostages;
		}
	}

	free_json_handle_safe(jArray);
}


parse_radio_message_sounds(const JSON:jMessage, &Array:arrSounds)
{
	arrSounds = ArrayCreate(MAX_RESOURCE_PATH_LENGTH, 3);
	new JSON:jArray = json_object_get_value(jMessage, "sounds");

	if (!json_is_array(jArray))
	{
		free_json_handle_safe(jArray);
		return;
	}

	new szSound[MAX_RESOURCE_PATH_LENGTH];
	new iElementsCount = json_array_get_count(jArray);

	for (new i = 0; i < iElementsCount; i++)
	{
		if (json_array_get_string(jArray, i, szSound, charsmax(szSound)))
			ArrayPushString(arrSounds, szSound);
	}

	free_json_handle_safe(jArray);
}


free_json_handle_safe(JSON:jHandle)
{
	if (jHandle != Invalid_JSON && !json_free(jHandle))
	{
		plugin_end();
		set_fail_state("Could not freed JSON handle.");
	}
}


menu_radio(iPlayer, Radio:radio, Array:arrRadio)
{
	new szLang[8], szBuffer[MAX_FMT_LENGTH];
	get_language(iPlayer, szLang);
	update_player_data(iPlayer);

	radio_menuitem_get_name(szLang, g_aRadioTitle[_:radio], szBuffer, charsmax(szBuffer));
	new iMenu = menu_create(szBuffer, "menu_radio_handler");

	new iMenuItems = 0;
	new message[RadioMsg];
	new bool:bShouldDisable;
	new iMessagesNum = ArraySize(arrRadio);

	new szInfo[32];
	num_to_str(_:arrRadio, szInfo[1], charsmax(szInfo) - 1);

	for (new i = 0; i < iMessagesNum && iMenuItems < 9; i++)
	{
		ArrayGetArray(arrRadio, i, message, RadioMsg);

		if (radio_menuitem_should_skip(message, iPlayer))
			continue;

		szInfo[0] = i + 1; // �\(�_o)/� Fix me
		radio_menuitem_get_name(szLang, message[text], szBuffer, charsmax(szBuffer), true);
		bShouldDisable = radio_menuitem_should_disable(message, iPlayer);

		++iMenuItems;
		menu_additem(iMenu, szBuffer, szInfo, ADMIN_ALL, bShouldDisable ? g_iDisableMenuItem : -1);
	}

	if (iMenuItems == 0)
	{
		menu_destroy(iMenu);
		return;
	}

	while (iMenuItems++ < 9)
		menu_addblank2(iMenu);

	menu_setprop(iMenu, MPROP_PERPAGE, 0);
	menu_setprop(iMenu, MPROP_EXIT, MEXIT_FORCE);

	formatex(szBuffer, charsmax(szBuffer), "%L", szLang, "EXIT");
	menu_setprop(iMenu, MPROP_EXITNAME, szBuffer);

	menu_display(iPlayer, iMenu);
}


public menu_radio_handler(iPlayer, iMenu, iMenuItem)
{
	if (iMenuItem < 0 || !is_user_alive(iPlayer))
		goto DESTROY;

	new bitsAccess;
	new szInfo[32];

	if (!menu_item_getinfo(iMenu, iMenuItem, bitsAccess, szInfo, charsmax(szInfo)))
		goto DESTROY;

	new message[RadioMsg];
	ArrayGetArray(Array:str_to_num(szInfo[1]), szInfo[0] - 1, message, RadioMsg);
	update_player_data(iPlayer);

	if (radio_menuitem_should_skip(message, iPlayer) ||
		radio_menuitem_should_disable(message, iPlayer))
		goto DESTROY;

	new Array:arrSounds = message[sounds];
	new szSound[MAX_RESOURCE_PATH_LENGTH];
	new iRandomSound = (random(32767) / 2) % ArraySize(arrSounds);
	ArrayGetString(arrSounds, iRandomSound, szSound, charsmax(szSound));
	send_radio_message(iPlayer, message[text], szSound);

	DESTROY:
	menu_destroy(iMenu);

	return PLUGIN_HANDLED;
}


radio_menuitem_get_name(const szLang[8], const szSting[], szOutput[], iMaxLen, bool:bAddQuotes = false)
{
	if (bAddQuotes)
	{
		if (GetLangTransKey(szSting) == TransKey_Bad)
			return format(szOutput, iMaxLen, "^"%s^"", szSting);

		return formatex(szOutput, iMaxLen, "^"%L^"", szLang, szSting);
	}

	if (GetLangTransKey(szSting) == TransKey_Bad)
		return format(szOutput, iMaxLen, "%s", szSting);

	return formatex(szOutput, iMaxLen, "%L", szLang, szSting);
}


bool:radio_menuitem_should_skip(const message[RadioMsg], iPlayer)
{
	new bitsFlags = message[flags];
	new TeamName:playerTeam = g_playerData[iPlayer][team];

	if (bitsFlags & t_only && playerTeam != TEAM_TERRORIST)
		return true;

	if (bitsFlags & ct_only && playerTeam != TEAM_CT)
		return true;

	if (bitsFlags & admin_only && !g_playerData[iPlayer][has_admin_access])
		return true;

	if (bitsFlags & notadmin_only && g_playerData[iPlayer][has_admin_access])
		return true;

	return false;
}


bool:radio_menuitem_should_disable(const message[RadioMsg], iPlayer)
{
	new bitsFlags = message[flags];

	if (bitsFlags & bomber_only && !g_playerData[iPlayer][has_bomb])
		return true;

	if (bitsFlags & bomb_planted && !rg_is_bomb_planted())
		return true;

	return false;
}


public disable_menuitem(iPlayer, iMenu, iMenuItem)
{
	return ITEM_DISABLED;
}


send_radio_message(iSender, const szText[], const szSample[])
{
	new Float:flGameTime = get_gametime();
	new Float:flRadioTime = get_member(iSender, m_flRadioTime);
	new iRadioMessages = get_member(iSender, m_iRadioMessages);

	if (flRadioTime >= flGameTime || iRadioMessages <= 0)
		return;

	set_member(iSender, m_flRadioTime, flGameTime + get_pcvar_float(g_pcvFloodTime));
	set_member(iSender, m_iRadioMessages, --iRadioMessages);

	new aPlayers[MAX_PLAYERS], iNumPlayers;
	new TeamName:teamSender = g_playerData[iSender][team];
	get_players(aPlayers, iNumPlayers, "ceh", teamSender == TEAM_CT ? "CT" : "TERRORIST");

	new szSenderId[3];
	num_to_str(iSender, szSenderId, charsmax(szSenderId));

	new szSenderName[MAX_NAME_LENGTH];
	get_entvar(iSender, var_netname, szSenderName, charsmax(szSenderName));

	for (new i = 0, iRecipient, szTextMsg[190]; i < iNumPlayers; i++)
	{
		iRecipient = aPlayers[i];

		if (!is_user_alive(iRecipient))
		{
			new iSpecMode = get_entvar(iRecipient, var_iuser1);
			if (iSpecMode != OBS_CHASE_LOCKED &&
				iSpecMode != OBS_CHASE_FREE &&
				iSpecMode != OBS_IN_EYE)
				continue;

			new iObsTarget = get_entvar(iRecipient, var_iuser2);
			if (!is_player(iObsTarget) || get_member(iObsTarget, m_iTeam) != teamSender)
				continue;
		}

		if (!get_member(iRecipient, m_bIgnoreRadio))
		{
			send_msg_audio(iRecipient, iSender, szSample, get_pitch()); // rg_send_audio removes radar blinking.
			radio_menuitem_get_name(get_language(iRecipient), szText, szTextMsg, charsmax(szTextMsg));
			send_msg_text(iRecipient, print_radio, szSenderId, "#Game_radio", szSenderName, szTextMsg);
		}
	}
}


get_pitch()
{
	new iPitch;
	new szPitch[32];
	get_pcvar_string(g_pcvPitch, szPitch, charsmax(szPitch));

	new szPitchMin[4], szPitchMax[4];
	strtok2(szPitch, szPitchMin, 3, szPitchMax, 3, '-', true);

	if (szPitchMin[0] == EOS)
		return PITCH_NORM;

	if (szPitchMax[0] == EOS)
	{
		iPitch = str_to_num(szPitchMin);
	}
	else
	{
		iPitch = random_num(str_to_num(szPitchMin), str_to_num(szPitchMax));
	}

	return iPitch <= 0 ? PITCH_NORM : iPitch;
}


update_player_data(iPlayer)
{
	new szFlags[32];
	get_pcvar_string(g_pcvAdminFlags, szFlags, charsmax(szFlags));

	g_playerData[iPlayer][team] = get_member(iPlayer, m_iTeam);
	g_playerData[iPlayer][has_bomb] = get_member(iPlayer, m_bHasC4);
	g_playerData[iPlayer][has_admin_access] = !!has_all_flags(iPlayer, szFlags);
}


get_language(iPlayer, szLang[8] = "")
{
	get_pcvar_string(g_pcvLanguage, szLang, charsmax(szLang));

	if (equali(szLang, "player"))
	{
		szLang[0] = iPlayer == 0 ? LANG_PLAYER : iPlayer;
		szLang[1] = EOS;
	}
	else if (equali(szLang, "server"))
	{
		szLang[0] = LANG_SERVER;
		szLang[1] = EOS;
	}

	return szLang;
}


stock send_msg_text(iRecipient, iDest, const szMessage[], const szParam1[] = "", const szParam2[] = "", const szParam3[] = "")
{
	static iMsgId;

	if (iMsgId || (iMsgId = get_user_msgid("TextMsg")))
	{
		emessage_begin(iRecipient ? MSG_ONE : MSG_ALL, iMsgId, _, iRecipient);
		{
			ewrite_byte(iDest);
			ewrite_string(szMessage);
			if (szParam1[0]) ewrite_string(szParam1);
			if (szParam2[0]) ewrite_string(szParam2);
			if (szParam3[0]) ewrite_string(szParam3);
		}
		emessage_end();
	}
}


stock send_msg_audio(iRecipient, iSender, const szSample[], iPitch = PITCH_NORM)
{
	static iMsgId;

	if (iMsgId || (iMsgId = get_user_msgid("SendAudio")))
	{
		message_begin(iRecipient ? MSG_ONE : MSG_ALL, iMsgId, _, iRecipient);
		{
			write_byte(iSender);
			write_string(szSample);
			write_short(clamp(iPitch, 0, 255));
		}
		message_end();
	}
}


stock log_an_error(const szError[])
{
	new szLogDir[64];
	get_localinfo("amxx_logs", szLogDir, charsmax(szLogDir));

	if (!dir_exists(szLogDir))
		mkdir(szLogDir);

	new szDate[12];
	get_time("%Y%m%d", szDate, charsmax(szDate));
	log_to_file(fmt("%s/error_custom_radio_%s.log", szLogDir, szDate), szError);
}
