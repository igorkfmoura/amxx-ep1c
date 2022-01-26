#include <amxmodx>
#include <reapi>
#include <xs>


#define PLUGIN	"ep1c: AFK Manager"
#define VERSION	"1.2"
#define AUTHOR	"Xramer"

#define TASK_AFK_CHECK 139734
#define BIT_VALID(%1,%2) (%1 & (1 << (%2 & 31)))
#define BIT_ADD(%1,%2) %1 |= (1 << (%2 & 31))
#define BIT_SUB(%1,%2) %1 &= ~(1 << (%2 & 31))

new const g_szConfigName[] = "ep1c_afk_manager";

new g_szFlag[32], Float:g_iTimeCheck, g_iMaxWarning, g_iMaxSpect, Float:g_iTimeCheckSpect
new g_iTrnsferBomb, g_iNoticeSpec, g_iNoticeKick, g_iNoticeTransfer
new Float:g_fOldOrigin[MAX_CLIENTS+1][3], Float:g_fOldAngles[MAX_CLIENTS+1][3];
new g_iBitClientValid, g_iWarning[MAX_CLIENTS+1];
new g_iMaxPlayers;			
		


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_dictionary("ep1c-afk_manager2.txt");

	bind_pcvar_string(create_cvar(
		"afk_immunity_flag", 
		"c", .description = "Flag of immunity from plugin actions"), 
		g_szFlag, 
		charsmax(g_szFlag))

	bind_pcvar_float(create_cvar(
		"afk_time_check", 
		"10.0", 
		.description = "Time to check"), 
		g_iTimeCheck)

	bind_pcvar_num(create_cvar(
		"afk_max_warning", 
		"3", 
		.description = "The maximum number of warnings after which the player will be kicked"), 
		g_iMaxWarning)

	bind_pcvar_num(create_cvar(
		"afk_num_check_spec", 
		"32",
		.description = "The number of players at which it will kick, and not translate for spectators."),
		g_iMaxSpect)

	bind_pcvar_float(create_cvar(
		"afk_time_check_spec", 
		"60.0", 
		.description = " Time to сheck spectators."), 
		g_iTimeCheckSpect)

	bind_pcvar_num(create_cvar(
		"afk_transfer_bomb", 
		"1", 
		.description = "Transfer bomb to allies."),
		g_iTrnsferBomb)

	bind_pcvar_num(create_cvar(
		"afk_notice_spec", 
		"1", 
		.description = "Enable notification in the chat about the player transfer for spectators."), 
		g_iNoticeSpec)

	bind_pcvar_num(create_cvar(
		"afk_notice_kick",
		"1",
		.description = "Enable notification in chat about player kick."),
		g_iNoticeKick)

	bind_pcvar_num(create_cvar(
		"afk_notice_transfer", 
		"1", 
		.description = "Enable notification in chat about transfer bomb."),
		g_iNoticeTransfer)

	AutoExecConfig(true, g_szConfigName)

	RegisterHookChain(RG_CBasePlayer_Spawn, "CBasePlayer_Spawn", true);
	RegisterHookChain(RG_CBasePlayer_Killed, "CBasePlayer_Killed", true);
	set_task(g_iTimeCheckSpect, "SpectatorCheck", .flags = "b");
	g_iMaxPlayers = MaxClients;
	
}	


public client_putinserver(id)
{
	if(is_user_bot(id) || is_user_hltv(id)) return;
	BIT_ADD(g_iBitClientValid, id);
}


public client_disconnected(id)
{
	if(task_exists(id+TASK_AFK_CHECK)) remove_task(id+TASK_AFK_CHECK);
	BIT_SUB(g_iBitClientValid, id);
}	

public CBasePlayer_Killed(id) remove_task(id+TASK_AFK_CHECK);

public CBasePlayer_Spawn(const id) 
{
	if(!is_user_alive(id)) return;
		
	g_iWarning[id] = 0;
	
	get_entvar(id, var_origin, g_fOldOrigin[id]);
	get_entvar(id, var_angles, g_fOldAngles[id]);
	
	if(task_exists(id+TASK_AFK_CHECK)) remove_task(id+TASK_AFK_CHECK);
	set_task(g_iTimeCheck, "AfkCheck", id+TASK_AFK_CHECK, _, _, "b");
	
}


public AfkCheck(id)
{	
	id -= TASK_AFK_CHECK;
	new Float:fNewOrigin[3], Float:fNewAngles[3];
	
	get_entvar(id, var_origin, fNewOrigin);
	get_entvar(id, var_angles, fNewAngles);	
	
	if(xs_vec_equal(g_fOldOrigin[id], fNewOrigin) && xs_vec_equal(g_fOldAngles[id], fNewAngles))
	{		
		
		if(++g_iWarning[id] >= g_iMaxWarning)
		{	
			user_kill(id,1) 
			rg_join_team(id, TEAM_SPECTATOR);
			set_member(id, m_iTeam, TEAM_SPECTATOR);
			if(g_iNoticeSpec){
				client_print_color(0, print_team_red, "%l %l", "AFK_PREFIX", "AFK_ALL_TRANSFER_SPECTATOR", id);
			}
			
		}
		else
		{
			client_print_color(id, print_team_red, "%l %l", "AFK_PREFIX", "AFK_ID_WARNING", g_iWarning[id], g_iMaxWarning);
		}
		if(get_entvar(id, var_weapons) & (1<<CSW_C4))
		{	
			if(g_iTrnsferBomb){
				for(new i = 1; i <= g_iMaxPlayers; i++)
				{
					if(i != id && is_user_alive(i) && (get_member(i, m_iTeam) == TEAM_TERRORIST)){
						rg_transfer_c4(id,i)
						if(g_iNoticeTransfer){
							client_print_color(0, print_team_red,"%l %l", "AFK_PREFIX", "AFK_BOMB_TRANSFER", id, i);
						}
						break;
					}
					
					
				}	
			}
			else
			{
				rg_drop_item(id, "weapon_c4");
				if(g_iNoticeTransfer){
					client_print_color(0, print_team_red, "%l %l", "AFK_PREFIX", "AFK_BOMB_DROP", id);
				}
			}				
		}
	
	}	
	else
	{
		if(g_iWarning[id]) g_iWarning[id] = 0;
		xs_vec_copy(fNewOrigin, g_fOldOrigin[id]);
		xs_vec_copy(fNewAngles, g_fOldAngles[id]);
	}
}


public SpectatorCheck()
{
	if(get_playersnum() < g_iMaxSpect) return;	
	for(new i=1; i <= g_iMaxPlayers; i++){
		if(BIT_VALID(g_iBitClientValid, i)){
			if(get_user_flags(i) & read_flags(g_szFlag)) continue;
					
			if(get_member(i, m_iTeam) == TEAM_SPECTATOR){
				AfkPunishment(i);
				break;
			}

		}	
	}
}

public AfkPunishment(i)
{
	if(g_iNoticeKick){
		client_print_color(0, print_team_red, "%l %l", "AFK_PREFIX", "AFK_ALL_KICK_SPECTATOR", i);
	}
	server_cmd("kick #%d ^"%l^"", get_user_userid(i), "AFK_ID_KICK_SPECTATOR");
}	
