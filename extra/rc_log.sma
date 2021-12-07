#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new g_File;

public plugin_init() {
	register_plugin("Rechecker Log", "0.1", "F@nt0M");
	RegisterHookChain(RC_CmdExec, "CmdExec", true);
}

public plugin_cfg() {
	new path[128];
	get_localinfo("amxx_logs", path, charsmax(path));
	add(path, charsmax(path), "/rc_log");
	if (!dir_exists(path)) {
		mkdir(path);
	}

	add(path, charsmax(path), "/L%Y%m%d.log");

	format_time(path, charsmax(path), path);

	g_File = fopen(path, "a");
	if (!g_File) {
		set_fail_state("Could not open %s for write", path);
	}
}

public plugin_end() {
	fclose(g_File);
}

public CmdExec(const client, const filename[], cmd[], const hash) {
	new hour, minute, second;
	time(hour, minute, second);

	new nick[32], authid[24], ip[15];
	get_user_name(client, nick, charsmax(nick));
	get_user_authid(client, authid, charsmax(authid));
	get_user_ip(client, ip, charsmax(ip), 1);

	trim(cmd);

	fprintf(
		g_File, 
		"%02d:%02d:%02d: <%s><%s><%s> found '%s' with hash %s.^n^tExecuteCMD: %s^n",
		hour, minute, second,
		nick, authid, ip,
		filename, Hash2Hex(hash), cmd
	);
	fflush(g_File);
}

Hash2Hex(hash) {
	new result[9];
	for(new i = 0, mask, bit, k; i < 32; i+= 4) {
		mask = (1 << i) | (1 << (i+1)) | (1 << (i+2)) | (1 << (i+3));
		bit = (hash & mask) >> i;
		if (bit < 0) {
			bit &= 0xF;
		}
		k = 7 - (i / 4);
		result[k] = bit <= 9 ? bit + 48 : bit + 55;
	}
	result[8] = EOS;
	return result;
}