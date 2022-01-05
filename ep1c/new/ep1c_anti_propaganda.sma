#include <amxmodx>
#include <regex>
#include <fakemeta>

#define PLUGIN "ep1c_anti_propaganda"
#define VERSION "0.1"
#define AUTHOR "lonewolf"

#define PATTERN "Acesse: www.csaddons.com.br"
#define PREFIXCHAT "^4[ep1c gaming Brasil]^1"

static const ads[][64] = 
{
  "qual o discord do clan",
  "alguem me passa as rates",
  "a ep1c tem instagram?",
  "como usa o paraquedas",
  "com quem eu falo pra comprar adm",
  "qual o ip daqui",
  "a ep1c tem sv de mix?",
  "alguém me passa o link do pega bandeira por favor"
};

public plugin_init()
{
  register_plugin(PLUGIN, VERSION, AUTHOR);
  
  register_clcmd("say", "on_say");
  register_clcmd("say_team", "on_say_team");
}

public on_say(id)
{
  return filter(id);
}

public on_say_team(id)
{
  return filter(id, true);
}


static filter(id, bool:say_team=false)
{
  // if (get_user_flags(id) & (ADMIN_CFG | ADMIN_RESERVATION))
  // {
  //   return PLUGIN_CONTINUE;
  // }

  static args[192];

  read_args(args, charsmax(args));
  trim(args);
  
  new Regex:match = regex_match(args, PATTERN);

  if(!match)
  {
    return PLUGIN_CONTINUE;
  }
  
  new rnd = random_num(0, sizeof(ads)-1);
  client_cmd(id, "%s %s", say_team ? "say_team" : "say", ads[rnd]);
  
  return PLUGIN_HANDLED;
  
}