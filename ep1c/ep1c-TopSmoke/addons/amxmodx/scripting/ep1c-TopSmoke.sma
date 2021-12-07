#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <hamsandwich>
#include <fun>
#include <csx>
#include <fakemeta>

#define PLUGIN          "ep1c: Tops ganham smoke"
#define VERSION         "1.0"
#define AUTHOR          "iceeedR"

#define ClanTag         "^3[^4ep1c gaming Brasil^3]^1 "

public plugin_init()
{
        register_plugin
        (
                PLUGIN,
                VERSION,
                AUTHOR
        )

        if(!(get_map_objectives() & MapObjective_Bomb))
                pause("a")

        register_event("HLTV","EventNewRnd", "a", "1=0", "2=0")
}

public EventNewRnd()
{
        set_task_ex(1.0, "GetHighestScore")
}

// Code from Bugsy modified by me for my purposes
// https://forums.alliedmods.net/showpost.php?p=996494&postcount=4
public GetHighestScore()
{
        new iPlayers[MAX_PLAYERS], iNum, id, id2, iFrags, CsTeams:iTeam
        new T_Frags[MAX_PLAYERS + 1][2]
        new CT_Frags[MAX_PLAYERS + 1][2]

        get_players(iPlayers , iNum)

        for (new i = 0; i < iNum ;i++)
        {
                id = iPlayers[i]

                iFrags = get_user_frags(id)
                iTeam = cs_get_user_team(id)

                switch (iTeam)
                {
                        case CS_TEAM_T:
                        {
                                T_Frags[id][0] = id
                                T_Frags[id][1] = iFrags
                        }
                        case CS_TEAM_CT:
                        {
                                CT_Frags[id][0] = id
                                CT_Frags[id][1] = iFrags
                        }
                }
        }

        SortCustom2D(T_Frags , sizeof(T_Frags) , "StatsCompare" );
        SortCustom2D(CT_Frags , sizeof(CT_Frags) , "StatsCompare" );

        for (new p = 0; p < 2 ;p++)
        {
                id = T_Frags[p][0]
                id2 = CT_Frags[p][ 0]

                if (id)
                {
                        ham_strip_user_weapon(id, CSW_SMOKEGRENADE, 4)
                        give_item(id, "weapon_smokegrenade")
                        client_print_color( 0 , print_team_default , "%s^4%n^1 ganhou uma smoke nesse round." , ClanTag, id)
                }
                if(id2)
                {
                        ham_strip_user_weapon(id, CSW_SMOKEGRENADE, 4)
                        give_item(id2, "weapon_smokegrenade")
                        client_print_color( 0 , print_team_default , "%s^4%n^1 ganhou uma smoke nesse round." , ClanTag, id2)
                }
                else
                        break
        }
}

public StatsCompare( elem1[] , elem2[] )
{
        if( elem1[1] > elem2[1] )
                return -1
        else if( elem1[1] < elem2[1] )
                return 1

        return 0
}

#define m_pActiveItem 373
#define m_iId 43
new const m_rgpPlayerItems_CBasePlayer[6] = { 367 , 368 , ... }
stock const XO_CBASEPLAYERITEM = 4
stock const m_pNext = 42

stock ham_strip_user_weapon(id, iCswId, iSlot = 0, bool:bSwitchIfActive = true)
{
        new iWeapon;

        iWeapon = get_pdata_cbase(id, m_rgpPlayerItems_CBasePlayer[iSlot]);

        while( iWeapon > 0 )
        {
                if( get_pdata_int(iWeapon, m_iId, XO_CBASEPLAYERITEM) == iCswId )
                {
                        break;
                }

                iWeapon = get_pdata_cbase(iWeapon, m_pNext, XO_CBASEPLAYERITEM);
        }

        if( iWeapon > 0 )
        {
                if( bSwitchIfActive && get_pdata_cbase(id, m_pActiveItem) == iWeapon )
                {
                        ExecuteHamB(Ham_Weapon_RetireWeapon, iWeapon);
                }

                if( ExecuteHamB(Ham_RemovePlayerItem, id, iWeapon) )
                {
                        user_has_weapon(id, iCswId, 0);
                        ExecuteHamB(Ham_Item_Kill, iWeapon);
                        return 1;
                }
        }
        return 0;
}
