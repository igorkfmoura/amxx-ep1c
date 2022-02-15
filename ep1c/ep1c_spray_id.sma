/******************************************************************************/
// If you change one of the following settings, do not forget to recompile
// the plugin and to install the new .amx file on your server.
// You can find the list of admin flags in the amx/examples/include/amxconst.inc file.

#define FLAG_AMX_SPRAY      ADMIN_KICK
#define FLAG_AMX_SPRAY_SHOW ADMIN_KICK

// Uncomment the following line to enable the AMX logs for this plugin.
//#define USE_LOGS

/******************************************************************************/

#include <amxmodx>
#include <amxmisc>

#define MAX_SPRAYID  32 // maximum number of sprays stored
#define SPRAY_TIME   180.0 // spray duration
#define MAX_DISTANCE 40 // aiming compare distance (for amx_spray_show cmd)

new const g_iColor[3] = {50, 255, 50} // hud message color (RGB format)

enum eSpray {
  bool:bAdmin,
  szName[32],
  szAuthIDIP[24]
}

new g_iSprayNum
new g_iSprayOrigins[MAX_SPRAYID+1][3]
new g_muSprayDataBase[MAX_SPRAYID+1][eSpray]

new g_cvarSprayIdHud

public plugin_init() {
  register_plugin("Spray ID", "1.1.3", "Cheesy Peteza")
  register_clcmd("amx_spray", "cmdMakeSpray", FLAG_AMX_SPRAY, "<name|#userid|authid> - makes the player's spray (tag")
  register_clcmd("amx_spray_show", "cmdShowSpray", FLAG_AMX_SPRAY_SHOW, "- displays infos about a player's spray you aiming")
  register_clcmd("say /spray", "cmdShowSpray", FLAG_AMX_SPRAY_SHOW, "- displays infos about a player's spray you aiming")
  g_cvarSprayIdHud = register_cvar("sprayid_hud", "1")
  register_event("23", "eventTempEntity", "a", "1=112")
}

public cmdMakeSpray(id, iLevel, iCommandId) {
  if(!cmd_access(id, iLevel, iCommandId, 2))
    return PLUGIN_HANDLED

  new szTarget[32]
  read_argv(1, szTarget, charsmax(szTarget))

  new iPlayer = cmd_target(id, szTarget, 3)
  if(!iPlayer)
    return PLUGIN_HANDLED

  new iOrigin[3]
  get_user_origin(id, iOrigin, 3)

  message_begin(MSG_ALL, SVC_TEMPENTITY)
  write_byte(TE_PLAYERDECAL)
  write_byte(iPlayer)
  write_coord(iOrigin[0])
  write_coord(iOrigin[1])
  write_coord(iOrigin[2])
  write_short(0)
  write_byte(1)
  message_end()

  NewAdminSpray(iPlayer, iOrigin)

  new szPlayerName[32]
  get_user_name(iPlayer, szPlayerName, charsmax(szPlayerName))

  console_print(id, "The spray of %s has been displayed where you aiming.", szPlayerName)

  #if defined USE_LOGS
  new iPlayerUserID, szPlayerAuthID[24], szPlayerIPAddress[24]
  iPlayerUserID = get_user_userid(iPlayer)
  get_user_authid(iPlayer, szPlayerAuthID, charsmax(szPlayerAuthID))
  get_user_ip(iPlayer, szPlayerIPAddress, charsmax(szPlayerIPAddress), 1)

  if(id > 0) {
    new iAdminUserID, szAdminName[32], szAdminAuthID[24], szAdminIPAddress[24]
    if(iPlayer != id) {
      iAdminUserID = get_user_userid(id)
      get_user_name(id, szAdminName, charsmax(szAdminName))
      get_user_authid(id, szAdminAuthID, charsmax(szAdminAuthID))
      get_user_ip(id, szAdminIPAddress, charsmax(szAdminIPAddress), 1)
    }
    else {
      iAdminUserID = iPlayerUserID
      szAdminName = szPlayerName
      szAdminAuthID = szPlayerAuthID
      szAdminIPAddress = szPlayerIPAddress
    }

    log_amx("Spray ID: ^"<%s><%d><%s><%s>^" make the spray (tag) of ^"<%s><%d><%s><%s>^".",
    szAdminName, iAdminUserID, szAdminAuthID, szAdminIPAddress,
    szPlayerName, iPlayerUserID, szPlayerAuthID, szPlayerIPAddress)
  }
  else {
    log_amx("Spray ID: <SERVER> make the spray (tag) of ^"<%s><%d><%s><%s>^".",
    szPlayerName, iPlayerUserID, szPlayerAuthID, szPlayerIPAddress)
  }
  #endif

  return PLUGIN_HANDLED
}

public cmdShowSpray(id, iLevel, iCommandId) {
  if(!cmd_access(id, iLevel, iCommandId, 1))
    return PLUGIN_HANDLED

  new iOrigin[3]
  get_user_origin(id, iOrigin, 3)
  new bool:bSprayFind = false

  for(new j = 0; j < g_iSprayNum; j++) {
    if(get_distance(iOrigin, g_iSprayOrigins[j]) <= MAX_DISTANCE) {
      if(!(g_iSprayOrigins[j][0] == 0 && g_iSprayOrigins[j][1] == 0 && g_iSprayOrigins[j][2] == 0)) {
        bSprayFind = true
        if(get_pcvar_num(g_cvarSprayIdHud)) {
          set_hudmessage(g_iColor[0], g_iColor[1], g_iColor[2], -1.0, 0.55, 0, 0.0, 5.0, 0.0, 0.0, -1)
          if(g_muSprayDataBase[j][bAdmin])
            show_hudmessage(id, "Admin created spray of^n%s^nAuthID/IP: %s", g_muSprayDataBase[j][szName], g_muSprayDataBase[j][szAuthIDIP])
          else
            show_hudmessage(id, "Spray of^n%s^nAuthID/IP: %s", g_muSprayDataBase[j][szName], g_muSprayDataBase[j][szAuthIDIP])
        }
	   else {
          if(g_muSprayDataBase[j][bAdmin])
            client_print(id, print_center, "Admin created spray of %s (AuthID/IP: %s)", g_muSprayDataBase[j][szName], g_muSprayDataBase[j][szAuthIDIP])
          else
            client_print(id, print_center, "Spray of %s (AuthID/IP: %s)", g_muSprayDataBase[j][szName], g_muSprayDataBase[j][szAuthIDIP])
        }
        break
      }
    }
  }

  if(bSprayFind == false) {
    //console_print(id, "No spray found.")
    client_print(id, print_chat, "No spray found.")
  }

  return PLUGIN_HANDLED
}

public eventTempEntity() {
  new iSprayId = read_data(2)
  new szAuthIDIPTemp[24]

  g_muSprayDataBase[g_iSprayNum][bAdmin] = false
  get_user_name(iSprayId, g_muSprayDataBase[g_iSprayNum][szName], charsmax(g_muSprayDataBase[][szName]))

  get_user_authid(iSprayId, szAuthIDIPTemp, charsmax(szAuthIDIPTemp))
  if(szAuthIDIPTemp[6] == 'I' && equal(szAuthIDIPTemp[6], "ID_LAN") || isdigit(szAuthIDIPTemp[0])) {
    get_user_ip(iSprayId, szAuthIDIPTemp, charsmax(szAuthIDIPTemp), 1)
  }

  g_muSprayDataBase[g_iSprayNum][szAuthIDIP] = szAuthIDIPTemp

  g_iSprayOrigins[g_iSprayNum][0] = read_data(3)
  g_iSprayOrigins[g_iSprayNum][1] = read_data(4)
  g_iSprayOrigins[g_iSprayNum][2] = read_data(5)

  set_task(SPRAY_TIME, "taskRemoveSprayId", g_iSprayNum)

  if(g_iSprayNum == MAX_SPRAYID - 1) g_iSprayNum = 0
  else g_iSprayNum++
}

public taskRemoveSprayId(iSprayNum) {
  g_iSprayOrigins[iSprayNum][0] = 0
  g_iSprayOrigins[iSprayNum][1] = 0
  g_iSprayOrigins[iSprayNum][2] = 0
}

NewAdminSpray(iSprayId, iOrigin[3]) {
  g_iSprayOrigins[g_iSprayNum][0] = iOrigin[0]
  g_iSprayOrigins[g_iSprayNum][1] = iOrigin[1]
  g_iSprayOrigins[g_iSprayNum][2] = iOrigin[2]

  g_muSprayDataBase[g_iSprayNum][bAdmin] = true
  get_user_name(iSprayId, g_muSprayDataBase[g_iSprayNum][szName], charsmax(g_muSprayDataBase[][szName]))
  get_user_authid(iSprayId, g_muSprayDataBase[g_iSprayNum][szAuthIDIP], charsmax(g_muSprayDataBase[][szAuthIDIP]))

  set_task(SPRAY_TIME, "taskRemoveSprayId", g_iSprayNum)

  if(g_iSprayNum == MAX_SPRAYID - 1) g_iSprayNum = 0
  else g_iSprayNum++
}
