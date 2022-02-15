//  Smoke Mastergamescs.net
//  Criado Por: mayhem

//  ***Requires FakeMeta & Engine Modules***

//	sv_smoke 1 Extra Smoke Puffs
//	sv_smoke 2 Spread the Smoke
//	sv_smoke 3 Both 1 & 2

//  Setting any of the delays to 0 will skip that smoke puff
//	sv_smoke_delay1 Delay of first  smoke puff (sv_smoke 1 & 3) 
//	sv_smoke_delay2 Delay of second smoke puff (sv_smoke 1 & 3)
//	sv_smoke_delay3 Delay of third  smoke puff (sv_smoke 1 & 3)

// Default sv_smoke 1
//				 sv_smoke_delay1 2

#include <amxmodx>
#include <engine>
#include <fakemeta>

public plugin_init() {
	register_plugin("Smoke", "2.0", "nato")
	register_forward(FM_PlaybackEvent, "smokeEvent") 
	
	register_cvar("sv_smoke","1",FCVAR_SERVER)
	register_cvar("sv_smoke_delay1","0.1",FCVAR_SERVER)
	register_cvar("sv_smoke_delay2","0.1",FCVAR_SERVER)
	register_cvar("sv_smoke_delay3","0.1",FCVAR_SERVER)
	
}
public smokeEvent( flags, id, eventid, Float:delay, Float:Origin[3], Float:Angles[3], Float:fparam1, Float:fparam2, iparam1, iparam2,bparam1, bparam2 ) 
{
	if((eventid == 26) && (fparam1 == 0.0) && (fparam2 == 0.0) && (iparam2 == 1))
	{
		new smokeEnt = -1;
		while(smokeEnt = find_ent_by_class(smokeEnt,"grenade"))
		{ 			
			new model[32]
			entity_get_string(smokeEnt, EV_SZ_model, model, 31)
			if(equal(model, "models/w_smokegrenade.mdl"))
			{			
				new Float:smoke_origin[3]
				entity_get_vector ( smokeEnt, EV_VEC_origin, smoke_origin ) 

				if((smoke_origin[0] == Origin[0]) && (smoke_origin[0] == Origin[0]) && (smoke_origin[0] == Origin[0]))
				{
					if(get_cvar_num("sv_smoke") == 1)
					{
						// Adicionar ou Remover - Fuma com base nos Cvars
						if(get_cvar_float("sv_smoke_delay1") > 0)
							set_task(get_cvar_float("sv_smoke_delay1"), "playSmokeEvent", smokeEnt)
						if(get_cvar_float("sv_smoke_delay2") > 0)
							set_task(get_cvar_float("sv_smoke_delay2"), "playSmokeEvent", smokeEnt)
						if(get_cvar_float("sv_smoke_delay3") > 0)
							set_task(get_cvar_float("sv_smoke_delay3"), "playSmokeEvent", smokeEnt)
					}					
					else if(get_cvar_num("sv_smoke") == 2)
					{
						// Tente espalhar a fumaça em torno da origem
						set_task(0.1, "spreadSmokeEvent", smokeEnt)
					}
					else if(get_cvar_num("sv_smoke") == 3)
					{
					
						// Adicionar ou Remover - Fuma com base nos Cvars
						if(get_cvar_float("sv_smoke_delay1") > 0)
							set_task(get_cvar_float("sv_smoke_delay1"), "playSmokeEvent", smokeEnt)
						if(get_cvar_float("sv_smoke_delay2") > 0)
							set_task(get_cvar_float("sv_smoke_delay2"), "playSmokeEvent", smokeEnt)
						if(get_cvar_float("sv_smoke_delay3") > 0)
							set_task(get_cvar_float("sv_smoke_delay3"), "playSmokeEvent", smokeEnt)
						
						set_task(0.1, "spreadSmokeEvent", smokeEnt)
					}
				}
			}			
    }
	}
	return FMRES_IGNORED
}

public playSmokeEvent(gid) {
	new Float:angle[3]
	new Float:smoke_origin[3]
	
	entity_get_vector ( gid, EV_VEC_origin, smoke_origin ) 
	
	angle[0] = 0.0
	angle[1] = 0.0
	angle[2] = 0.0
	
	playback_event ( 0, gid, 26, 0.0 , smoke_origin, angle, 0.0, 0.0, 0, 1, 0, 0)
	
	return PLUGIN_HANDLED
}