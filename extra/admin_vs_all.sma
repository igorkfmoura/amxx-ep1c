#include <amxmodx>
#include <amxmisc>
#include <cstrike>

new const PLUGIN_TITLE[] = "Admins Vs All"
new const PLUGIN_VERSION[] = "1.4"
new const PLUGIN_AUTHOR[] = "Starsailor"

#define ACCESS_LEVEL     ADMIN_BAN

new  g_enable, g_teamadmin, g_teamothers, g_maxplayers, g_limitteamspointer, g_autoteambalancepointer
new iPcvarsValues[2]

public plugin_init()
{
	register_plugin(PLUGIN_TITLE, PLUGIN_VERSION,PLUGIN_AUTHOR)
	register_cvar("ava_version",PLUGIN_VERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	g_enable = register_cvar("ava_enable","1")
	g_teamadmin = register_cvar("ava_adminteam","T")
	g_teamothers = register_cvar("ava_othersteam","CT")
	
	g_limitteamspointer = get_cvar_pointer("mp_limitteams")
	g_autoteambalancepointer = get_cvar_pointer("mp_autoteambalance")
	
	iPcvarsValues[0] = get_pcvar_num(g_limitteamspointer)
	iPcvarsValues[1] = get_pcvar_num(g_autoteambalancepointer)
	
	g_maxplayers = get_maxplayers()
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
}



public event_round_start()
{
	if(get_pcvar_num(g_enable))
	{
		new szTeamAdmin[16],szTeamOthers[16]
		
		set_pcvar_num(g_limitteamspointer,0)
		set_pcvar_num(g_autoteambalancepointer,0)
		
		get_pcvar_string(g_teamadmin,szTeamAdmin,15)
		get_pcvar_string(g_teamothers,szTeamOthers,15)
		
		for(new id = 1; id <= g_maxplayers; id++)
		{
			if(!is_user_connected(id) || is_user_hltv(id))
			{
				continue
			}
			
			if(get_user_flags(id) & ACCESS_LEVEL)
			{	
				switch(szTeamAdmin[0])
				{
					case 'C': 
					{
						cs_set_user_team(id,CS_TEAM_CT)
					}
					case 'T':
					{
						cs_set_user_team(id,CS_TEAM_T)
					}
				}
				
			}	
			else
			{
				switch(szTeamOthers[0])
				{
					case 'C':
					{
						cs_set_user_team(id,CS_TEAM_CT)
						
					}
					case 'T':
					{
						cs_set_user_team(id,CS_TEAM_T)
						
					}
				}
			}
			client_print(0,print_chat,"** Checking Teams **")
			
		}
	}
	
	else
	{
		set_pcvar_num(g_limitteamspointer,iPcvarsValues[0])
		set_pcvar_num(g_autoteambalancepointer,iPcvarsValues[1])
		
	}
	
}


