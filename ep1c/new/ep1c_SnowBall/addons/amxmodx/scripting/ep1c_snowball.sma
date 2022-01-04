/* Update v1.1 Replaced CurWeapon on Ham_Item_Deploy */

#include <amxmodx>
#include <engine>
#include <hamsandwich>
#include <fun>
#include <fakemeta>
#include <cstrike>

#define m_flNextAttack  83

#define PLUGIN "ep1c: Snowball Mod"
#define VERSION "1.1"
#define AUTHOR "spree"

new VIEW_MODEL[] = "models/sbmode/v_snowball.mdl"
new PLAYER_MODEL[] = "models/sbmode/p_snowball.mdl"
new WORLD_MODEL[] = "models/sbmode/w_snowball.mdl"
new SBMODE, MCFLASH, BLOOD, SB_WATER, TRAIL, TRAIL_SPRITE, TRAIL_COLOR, SBCVAR, DEATH_EFFECT, SB_GIVEOUT
new SB_COUNT[33]
new Float:SBDMG

new sounds[][] =
{
	"items/gunpickup2.wav",
	"items/9mmclip1.wav",
	"player/die1.wav",
	"player/die2.wav",
	"player/die3.wav",
	"player/death6.wav"
}

new entities[][] =
{
	"game_player_equip",
	"armoury_entity"
}

new sbhit[][] =
{
	"scientist/sci_pain1.wav",
	"scientist/sci_pain2.wav",
	"scientist/sci_pain3.wav",
	"scientist/sci_pain5.wav",
	"scientist/sci_pain6.wav",
	"scientist/sci_pain7.wav",
	"scientist/sci_pain8.wav",
	"scientist/sci_pain9.wav",
	"scientist/sci_pain10.wav"		
}

new HamHook:fwd_id_ham_deploy;
new HamHook:fwd_id_ham_spawn;
new HamHook:fwd_id_ham_killed;
new fwd_id_fake_emit_sound;
new fwd_id_touch_grenade;
new fwd_id_msg_textmsg;
new fwd_id_msg_sendaudio;
new fwd_id_msg_weappickup;

new snowball_enabled;

public plugin_precache() 
{
		
	bind_pcvar_num(register_cvar("amx_sbmode", "1"), SBMODE);

	// if(SBMODE)
	// {
	// 	new imp
	// 	imp = create_entity("info_map_parameters")
	// 	DispatchKeyValue(imp, "buying", "3")
	// 	DispatchSpawn(imp)
	// 	server_cmd("sv_restart 1")
	// }

	precache_model(VIEW_MODEL)
	precache_model(PLAYER_MODEL)
	precache_model(WORLD_MODEL)
	precache_sound ("sbmode/sbthrow.wav")
	precache_sound ("sbmode/sbhit.wav")
	precache_sound ("sbmode/balls.wav")
	precache_sound ("bullchicken/bc_acid2.wav")
	precache_sound ("scientist/sci_pain1.wav")
	precache_sound ("scientist/sci_pain2.wav")
	precache_sound ("scientist/sci_pain3.wav")
	precache_sound ("scientist/sci_pain4.wav")
	precache_sound ("scientist/sci_pain5.wav")
	precache_sound ("scientist/sci_pain6.wav")
	precache_sound ("scientist/sci_pain7.wav")
	precache_sound ("scientist/sci_pain8.wav")
	precache_sound ("scientist/sci_pain9.wav")
	precache_sound ("scientist/sci_pain10.wav")
	BLOOD = precache_model("sprites/blood.spr")
	MCFLASH = precache_model("sprites/sbmode/mcflash.spr")
	TRAIL_SPRITE = precache_model("sprites/white.spr")
	SB_WATER = precache_model("sprites/smokepuff.spr")
}


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	bind_pcvar_num(create_cvar("amx_sbgo", "1"), SB_GIVEOUT);
	bind_pcvar_num(create_cvar("amx_deffect", "1"), DEATH_EFFECT);
	bind_pcvar_num(create_cvar("amx_sbtrail", "1"), TRAIL);
	bind_pcvar_num(create_cvar("amx_sbcolor", "1"), TRAIL_COLOR);
	bind_pcvar_float(create_cvar("amx_sbdmg", "50.0"), SBDMG);

	fwd_id_ham_deploy = RegisterHam(Ham_Item_Deploy, "weapon_smokegrenade", "Item_Deploy_Post", 1);
	fwd_id_ham_spawn  = RegisterHam(Ham_Spawn, "player", "player_respawn", 1);
	fwd_id_ham_killed = RegisterHam(Ham_Killed, "player", "ham_player_kill");

	DisableHamForward(fwd_id_ham_deploy);
	DisableHamForward(fwd_id_ham_spawn);
	DisableHamForward(fwd_id_ham_killed);

	register_concmd("amx_snowball_enable",  "snowball_enable",  ADMIN_CVAR);
	register_concmd("amx_snowball_disable", "snowball_disable", ADMIN_CVAR);
	
	snowball_enable(0);

	// if (SBMODE)
	// {
	// 	for(new i; i < sizeof entities; i++)
	// 	{
	// 		new pEnt = -1
	// 		while((pEnt = engfunc(EngFunc_FindEntityByString, pEnt, "classname", entities[i])))
	// 		{
	// 			engfunc(EngFunc_RemoveEntity, pEnt);
	// 		}
	// 	}
	// }
}


public snowball_enable(id)
{
	EnableHamForward(fwd_id_ham_deploy);
	EnableHamForward(fwd_id_ham_spawn);
	EnableHamForward(fwd_id_ham_killed);
	
	fwd_id_fake_emit_sound = register_forward(FM_EmitSound, "fw_EmitSound");
	fwd_id_touch_grenade   = register_touch("grenade", "*", "FwdTouch");

	fwd_id_msg_textmsg    = register_message(get_user_msgid("TextMsg"),    "block_message");
	fwd_id_msg_sendaudio  = register_message(get_user_msgid("SendAudio"),  "block_audio");
	fwd_id_msg_weappickup = register_message(get_user_msgid("WeapPickup"), "block_message_wpu");

	snowball_enabled = true;
}


public snowball_disable(id)
{
	DisableHamForward(fwd_id_ham_deploy);
	DisableHamForward(fwd_id_ham_spawn);
	DisableHamForward(fwd_id_ham_killed);
	
	unregister_forward(FM_EmitSound, fwd_id_fake_emit_sound);
	unregister_touch(fwd_id_touch_grenade);

	unregister_message(get_user_msgid("TextMsg"),    fwd_id_msg_textmsg);
	unregister_message(get_user_msgid("SendAudio"),  fwd_id_msg_sendaudio);
	unregister_message(get_user_msgid("WeapPickup"), fwd_id_msg_weappickup);

	snowball_enabled = false;
}


public Item_Deploy_Post(weapon)
{
	if (!snowball_enabled) return HAM_IGNORED;

	new id = get_pdata_cbase(weapon, 41, 4)
	entity_set_string(id, EV_SZ_viewmodel, VIEW_MODEL)
	entity_set_string(id, EV_SZ_weaponmodel, PLAYER_MODEL)
	return HAM_IGNORED
}

public player_respawn(id)
{
	if (!is_user_alive(id) || !snowball_enabled) return HAM_IGNORED;
	
	set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);

	if (SBMODE) {
		strip_user_weapons(id);
		give_item(id,"weapon_smokegrenade");
	}
	else if (SB_GIVEOUT)
	{
		give_item(id,"weapon_smokegrenade");
		SB_COUNT[id] = SB_GIVEOUT;
	}
	return FMRES_IGNORED;
}

public ham_player_kill(victim, attacker, corpse)
{
	if (is_user_connected(victim) && DEATH_EFFECT && snowball_enabled)
	{
		static pOrigin[3]
		get_user_origin(victim, pOrigin)

		emit_sound(victim, CHAN_STATIC, "sbmode/balls.wav", 0.5, ATTN_NORM, 0, PITCH_NORM)

		set_user_rendering(victim, kRenderFxGlowShell, random_num(0,255), random_num(0,255), random_num(0,255), kRenderNormal,20)

		message_begin(MSG_ALL, SVC_TEMPENTITY) 
		write_byte(TE_SPRITETRAIL)
		write_coord(pOrigin[0])
		write_coord(pOrigin[1])
		write_coord(pOrigin[2]+20)
		write_coord(pOrigin[0])
		write_coord(pOrigin[1])
		write_coord(pOrigin[2]+80)
		write_short(MCFLASH)
		write_byte(15)
		write_byte(30)
		write_byte(1)
		write_byte(30)
		write_byte(1)
		message_end()
	}
}

public grenade_throw(id, iGrenade, iGrenadeType)
{
	if (snowball_enabled && is_user_connected(id) && pev_valid(iGrenade) && iGrenadeType == CSW_SMOKEGRENADE)
	{
		set_pev(iGrenade, pev_gravity, 0.4);

		new Float:mul = 2.0;

		new Float:velocity[3];
		entity_get_vector(iGrenade, EV_VEC_velocity, velocity);
		
		velocity[0] *= mul;
		velocity[1] *= mul;
		velocity[2] *= mul;

		entity_set_vector(iGrenade, EV_VEC_velocity, velocity);

		if (TRAIL)
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_BEAMFOLLOW);
			write_short(iGrenade);
			write_short(TRAIL_SPRITE);
			write_byte(10);
			write_byte(2);

			if (TRAIL_COLOR)
			{
				write_byte(random_num(0,255));
				write_byte(random_num(0,255));
				write_byte(random_num(0,255));
			}
			else
			{
				write_byte(20);
				write_byte(20);
				write_byte(20);
			}

			write_byte(255);
			message_end();
		}

		if (SBMODE)
		{
			cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 2)
			set_pdata_float(id, m_flNextAttack, 0.25, 5)
		}
		else if (SB_GIVEOUT > 1 && SB_COUNT[id] > 1)
		{
			cs_set_user_bpammo (id, CSW_SMOKEGRENADE, 2)
			set_pdata_float(id, m_flNextAttack, 0.25, 5)
			SB_COUNT[id]--
		}

		entity_set_model(iGrenade, WORLD_MODEL)
		emit_sound(id, CHAN_STATIC, "sbmode/sbthrow.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		set_pev(iGrenade, pev_nextthink, get_gametime() + 10000)

		message_begin(MSG_ALL, SVC_TEMPENTITY)
		write_byte(TE_KILLPLAYERATTACHMENTS)
		write_byte(id)
		message_end()
	}
}

public FwdTouch(ent, player)
{
	if (!pev_valid(ent) || !snowball_enabled) return
	
	static grenade_model[32]
	entity_get_string(ent, EV_SZ_model, grenade_model, charsmax(grenade_model))
	if (!equal(WORLD_MODEL, grenade_model)) return
	
	static id
	id = pev(ent, pev_owner)
	
	static origin[3]
	pev(ent, pev_origin, origin)
	
	if (entity_get_int(ent, EV_INT_watertype) == -3)
	{
		pev(ent, pev_origin, origin)
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_GLOWSPRITE)
		engfunc(EngFunc_WriteCoord, origin[0])
		engfunc(EngFunc_WriteCoord, origin[1])
		engfunc(EngFunc_WriteCoord, origin[2])
		write_short(SB_WATER)
		write_byte(5)
		write_byte(7)
		write_byte(150)
		message_end()
		emit_sound(ent, CHAN_STATIC, "bullchicken/bc_acid2.wav", 0.4, ATTN_NORM, 0, PITCH_NORM)
		engfunc(EngFunc_RemoveEntity, ent)
		return
	}

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(BLOOD)
	write_short(BLOOD)
	write_byte(13)
	write_byte(10)
	message_end()
	
	if (ExecuteHam(Ham_IsPlayer, player))
	{
		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, player)
		write_short(1<<12)
		write_short(1000<<1)
		write_short(1<<20)
		write_byte(255)
		write_byte(255)
		write_byte(255)
		write_byte(100)
		message_end()

		static Float:fVec[3]
		fVec[0] = random_float(-20.0 , 20.0)
		fVec[1] = random_float(-20.0 , 30.0)
		fVec[2] = random_float(-20.0 , 20.0)
		entity_set_vector(player , EV_VEC_punchangle , fVec)

		ExecuteHamB(Ham_TakeDamage, player, 0, id, SBDMG, (1<<1))

		if(is_user_alive(player))
			emit_sound(player, CHAN_VOICE, sbhit[random_num(0,8)], 0.4, ATTN_NORM, 0, PITCH_NORM)
		else
			emit_sound(player, CHAN_VOICE, "scientist/sci_pain4.wav", 0.4, ATTN_NORM, 0, PITCH_NORM)
	}
	
	emit_sound(ent, CHAN_STATIC, "sbmode/sbhit.wav", 0.4, ATTN_NORM, 0, PITCH_NORM)	
	engfunc(EngFunc_RemoveEntity, ent)
}

public fw_EmitSound(id, channel, const sample[], Float:Volume, Float:attn, flags, pitch)
{
	if (!snowball_enabled) return FMRES_IGNORED;

	for (new i; i < sizeof sounds; i++)
	{
		if (SBMODE && equal(sample, sounds[i]))
			return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

public block_message_wpu()
{
	if(SBMODE && snowball_enabled) 
		return PLUGIN_HANDLED

	return PLUGIN_CONTINUE
}

public block_message(msg_id, msg_dest, entity)
{
	if(snowball_enabled && get_msg_args() == 5 && SBMODE)
	{
		if(get_msg_argtype(5) == ARG_STRING)
		{
		new value5[64]
		get_msg_arg_string(5 ,value5 ,63)
		if(equal(value5, "#Fire_in_the_hole"))
		{
			return PLUGIN_HANDLED
			}
		}
	}
	return PLUGIN_CONTINUE
}

public block_audio(msg_id, msg_dest, entity)
{
	if(snowball_enabled && get_msg_args() == 3 && SBMODE)
	{
		if(get_msg_argtype(2) == ARG_STRING)
		{
			new value2[64]
			get_msg_arg_string(2 ,value2 ,63)
			if(equal(value2 ,"%!MRAD_FIREINHOLE"))
			{
			return PLUGIN_HANDLED
			}
		}
	}
	return PLUGIN_CONTINUE
}
