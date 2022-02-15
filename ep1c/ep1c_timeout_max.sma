#include <amxmodx>

#define PLUGIN	"ep1c_max_timeout"
#define VERSION	"0.1"
#define AUTHOR	"lonewolf"

// Contexto do plugin: algum admin (t1ringa) tá com alguma bind de "destravar" que bota o timeout pra 99999 depois.

new pcvar_timeout;
new pcvar_timeout_max;

public plugin_init()
{
  register_plugin(PLUGIN, VERSION, AUTHOR);

  pcvar_timeout     = get_cvar_pointer("sv_timeout");
  pcvar_timeout_max = create_cvar("sv_timeout_max", "65.0", _, _, true, 1.0, true, 65.0);

  new Float:max = get_pcvar_float(pcvar_timeout_max);
  set_pcvar_bounds(pcvar_timeout, CvarBound_Upper, true, max);
  
  hook_cvar_change(pcvar_timeout_max, "on_change");
}

public on_change(pcvar, old_value[], new_value[])
{
  new Float:max = str_to_float(new_value);
  set_pcvar_bounds(pcvar_timeout, CvarBound_Upper, true, max);
}