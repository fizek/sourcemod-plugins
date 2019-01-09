#include <sourcemod>

public Plugin:myinfo = 
{
	name = "sniper-blocker",
	author = "fizek",
	description = "addons to weapon-restrict by Drifter321",
	version = "1.0",
	url = "fizek.pl",
};

new Handle:g_CvarOne = INVALID_HANDLE;

public OnPluginStart()
{
	HookEvent("round_start", Event_RoundStart);
	g_CvarOne = CreateConVar("sniper_blocker", "12", "How many players to unlock sniper-rifles");
	AutoExecConfig(true, "sniper_blocker_config");
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:broadcast) 
{
	new pl_count = GetPlayersCount();
	if (pl_count > 0)
	{
		if (pl_count >= GetConVarInt(g_CvarOne))
		{ 
			ServerCommand("sm_weapon_restrict_immunity 1");
			ServerCommand("sm_restrict_awp_ct 0");
			ServerCommand("sm_restrict_awp_t 0");
			ServerCommand("sm_restrict_g3sg1_ct -1");
			ServerCommand("sm_restrict_g3sg1_t -1");
			ServerCommand("sm_restrict_sg550_ct -1");
			ServerCommand("sm_restrict_sg550_t -1");
			ServerCommand("sm_restrict_scout_ct -1");
			ServerCommand("sm_restrict_scout_t -1");
			PrintToChatAll("\x01[\x04SM\x01]\x05 ### SNIPERS ALLOWED ###");
		}
		else if (pl_count < GetConVarInt(g_CvarOne))
		{ 
			ServerCommand("sm_weapon_restrict_immunity 0");
			ServerCommand("sm_restrict_awp_ct 0");
			ServerCommand("sm_restrict_awp_t 0");
			ServerCommand("sm_restrict_g3sg1_ct 0");
			ServerCommand("sm_restrict_g3sg1_t 0");
			ServerCommand("sm_restrict_sg550_ct 0");
			ServerCommand("sm_restrict_sg550_t 0");
			ServerCommand("sm_restrict_scout_ct 0");
			ServerCommand("sm_restrict_scout_t 0");
			PrintToChatAll("\x01[\x04SM\x01]\x05 ### SNIPERS BLOCKED ###");
		}
	}
	return Plugin_Stop;
} 

GetPlayersCount()
{
	new players;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && !IsClientObserver(i))
		{ players++; }
	}
	return players;
}
