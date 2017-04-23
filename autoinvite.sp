#include <sourcemod>
#include <steamcore>

new Handle:cvarGroupID;

public Plugin myinfo = 
{
	name = "Auto Inviter",
	author = "Czar",
	description = "Auto Invite New Players To Steam Group",
	version = "1.00",
	url = ""
};

public void OnPluginStart()
{
	CreateConVar("sm_autoinvite_version", "1.00", "", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_CHEAT|FCVAR_DONTRECORD);
	cvarGroupID = CreateConVar("sm_groupid", "", "ID64 of steam group");
	AutoExecConfig(true, "autoinvite");
}

public void OnClientPutInServer(int client)
{
	CreateTimer(15.0, NewTimer, client);
}
 public Action:NewTimer(Handle:timer, any:client)
{
	if (IsClientInGame(client) && IsSteamCoreBusy()==false)
	{
		invite(client);
	}else if (IsClientConnected(client))
	{
		CreateTimer(10.0, NewTimer, client);
	}
}
public void invite(client)
{
	char steamgroup[60];
	GetConVarString(cvarGroupID, steamgroup, sizeof(steamgroup));
	char steamID64[32];
	GetClientAuthId(client, AuthId_SteamID64, steamID64, sizeof steamID64);
	SteamGroupInvite(client, steamID64, steamgroup, callback);
}
public callback(client, bool:success, error, any:data)
{
	char steamid[32];
	char doit[150];
	GetClientAuthId(client, AuthId_Steam2, steamid, 32, true);
	Format(doit, sizeof(doit), "Client %s sent invite to group", steamid);
	if (success) PrintToServer(doit);
	else
	{
		switch(error)
		{
			case 0x01:	PrintToServer( "Server is busy with another task at this time, try again in a few seconds.");
			case 0x02:	PrintToServer( "There was a timeout in your request, try again.");
			case 0x23:	PrintToServer( "Session expired, retry to reconnect.");
			case 0x27:	PrintToServer( "Target has already received an invite or is already on the group.");
			default:	PrintToServer( "There was an error x%02x while sending your invite :(", error);
		}
	}
}