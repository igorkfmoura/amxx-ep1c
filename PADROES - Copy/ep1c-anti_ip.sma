#include <amxmodx>
#include <regex>
#include <fakemeta>

#define PLUGIN "ep1c: Anti IP"
#define VERSION "1.1"
#define AUTHOR "Wilian M."

#define PATTERN_IP "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
#define PREFIXCHAT "^3[^4ep1c gaming Brasil^3]"

new Regex:xResult, xReturnValue, xError[64], xArgs[192]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say", "xSay")
	register_clcmd("say_team", "xSay")
	
	register_forward(FM_ClientUserInfoChanged, "xClientUserInfoChanged", false)
}

public xSay(id)
{
	trim(xArgs)
	read_args(xArgs, charsmax(xArgs))
	
	xResult = regex_match(xArgs, PATTERN_IP, xReturnValue, xError, charsmax(xError))
	
	if(xResult)
	{
		client_print_color(0, print_team_default, "%s ^3Jogador ^1%n ^3foi banido por divulgar ^4IP's ^3no servidor.", PREFIXCHAT, id)
		server_cmd("amx_ban ^"#%d^" ^"15^" ^"Divulgando IP's^"", get_user_userid(id))
				
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public xClientUserInfoChanged(id)
{
	if(!is_user_connected(id))
		return FMRES_IGNORED

	static xUserName[32]
	pev(id, pev_netname, xUserName, charsmax(xUserName))

	if(xUserName[0])
	{
		static name[] = "name"
		static xUserNewName[32]
		get_user_info(id, name, xUserNewName, charsmax(xUserNewName))

		if(!equal(xUserName, xUserNewName))
		{
			xResult = regex_match(xUserNewName, PATTERN_IP, xReturnValue, xError, charsmax(xError))
		
			if(xResult)
			{
				set_user_info(id, name, "Anti-IP :)")
					
				return FMRES_HANDLED
			}
		}
	}
	
	return FMRES_IGNORED
}
