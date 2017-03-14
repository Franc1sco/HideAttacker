/*  SM Hide Attacker
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "b1.5"

new Handle:HideAttackerTs = INVALID_HANDLE;
new Handle:HideAttackerCt = INVALID_HANDLE;

new bool:hide_cts;
new bool:hide_ts;

public Plugin:myinfo =
{
	name = "SM Hide Attacker",
	author = "Franc1sco Steam: franug",
	description = "Hide attackers",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/id/franug"
};

public OnPluginStart()
{

	CreateConVar("sm_hideattacker_version", PLUGIN_VERSION, "version", FCVAR_SPONLY|FCVAR_NOTIFY);

	HideAttackerTs = CreateConVar("sm_hideattacker_ts", "1", "hide Ts attackers");

	HideAttackerCt = CreateConVar("sm_hideattacker_ct", "0", "hide CTs attackers");
	
	HookEvent("player_death", event_Death, EventHookMode_Pre);

	HookConVarChange(HideAttackerCt, OnCVarChange);
	HookConVarChange(HideAttackerTs, OnCVarChange);

}

public OnCVarChange(Handle:convar_hndl, const String:oldValue[], const String:newValue[])
{
	GetCVars();
}

public OnConfigsExecuted()
{
	GetCVars();
}

// Get new values of cvars if they has being changed
public GetCVars()
{
	hide_cts = GetConVarBool(HideAttackerCt);
	hide_ts = GetConVarBool(HideAttackerTs);

}


public Action:event_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!dontBroadcast)
	{
		new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		new userid = GetEventInt(event, "userid");
		new client = GetClientOfUserId(userid);

		if (!attacker || attacker == client)
			return Plugin_Continue;

		new iTeam = GetClientTeam(attacker);
		if ((iTeam == 2 && hide_ts) || (iTeam == 3 && hide_cts))  
		{

			decl String:Weapon[32];
			GetEventString(event, "weapon", Weapon, sizeof(Weapon));

			new Handle:newEvent = CreateEvent("player_death", true);
			SetEventInt(newEvent, "userid", userid);
			SetEventInt(newEvent, "attacker", userid);
			SetEventString(newEvent, "weapon", Weapon);
			SetEventBool(newEvent, "headshot", GetEventBool(event, "headshot"));
			SetEventInt(newEvent, "dominated", GetEventInt(event, "dominated"));
			SetEventInt(newEvent, "revenge", GetEventInt(event, "revenge"));

			FireEvent(newEvent, false); // normal event but without attacker ;)

			dontBroadcast = true;
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}