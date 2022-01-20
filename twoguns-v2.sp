#include <sdktools> 
 
#define ANTIFLOOD 0.45
 
public Plugin:myinfo = 
{
        name = "TwoGuns",
        author = "Scarface_slv",
        version = "2.2",
        url = "http://xz.ru/"
};
 
new bool:g_bReload[MAXPLAYERS+1], g_iAmmoClient[MAXPLAYERS+1][2][2], g_iReservClient[MAXPLAYERS+1][2][2];
new Handle:g_hArray[MAXPLAYERS+1][2], Handle:g_hTrie;
new g_iFlag, g_iSlot;
new Float:g_iFloodClient[MAXPLAYERS+1][2], bool:g_bAdminOn[MAXPLAYERS+1];
 
public OnPluginStart() 
{
        RegConsoleCmd("twoguns", UzyjFunkcji);
 
        HookEvent("player_hurt", Event_PlayerHurt);
        HookConVarChange(FindConVar("mp_restartgame"), OnConVarRestart);                
        decl String:sFlag[22]; 
        new Handle:g_hCvar = CreateConVar("sm_twoguns_adminflag", "", "flaga z admins simple");
        GetConVarString(g_hCvar, sFlag, sizeof(sFlag)); 
        g_iFlag = ReadFlagString(sFlag);  
        HookConVarChange(g_hCvar, OnConVarChange);      
        g_hCvar = CreateConVar("sm_twoguns_slot", "0", "1 - karabiny, 2 - pistolety, 0 - i to i to", 0, true, 0.0, true, 2.0);
        g_iSlot = GetConVarInt(g_hCvar);
        HookConVarChange(g_hCvar, OnConVarChangeSlot);          
        CloseHandle(g_hCvar);
        g_hTrie = CreateTrie();
}
 
public OnConVarRestart(Handle:convar, const String:oldValue[], const String:newValue[]) 
{
        for(new i = 1; i <= MaxClients; i++)
        {
                if(IsClientInGame(i))
                {
                        ClearArray(g_hArray[i][0]); 
                        ClearArray(g_hArray[i][1]);
                }
        }
}
 
public OnConVarChange(Handle:convar, const String:oldValue[], const String:newValue[]) g_iFlag = ReadFlagString(newValue);  
 
public OnConVarChangeSlot(Handle:convar, const String:oldValue[], const String:newValue[]) LoadTrieValue(StringToInt(newValue));  
 
LoadTrieValue(iSlot)
{
        if(g_hTrie != INVALID_HANDLE) ClearTrie(g_hTrie);
        switch(iSlot)
        {
                case 1: SetWeapon(0);
                case 2: SetWeapon(1);
                default: 
                {
                        SetWeapon(1);
                        SetWeapon(0);
                }
        }
}
 
SetWeapon(iSlot)
{
        switch(iSlot)
        {
                case 0:
                {
                        SetTrieValue(g_hTrie,   "m3", 0);
                        SetTrieValue(g_hTrie,   "xm1014", 0);
                        SetTrieValue(g_hTrie,   "mac10",        0);
                        SetTrieValue(g_hTrie,   "tmp", 0);
                        SetTrieValue(g_hTrie,   "mp5navy", 0);
                        SetTrieValue(g_hTrie,   "ump45", 0);
                        SetTrieValue(g_hTrie,   "p90", 0);
                        SetTrieValue(g_hTrie,   "galil", 0);
                        SetTrieValue(g_hTrie,   "famas", 0);
                        SetTrieValue(g_hTrie,   "ak47", 0);
                        SetTrieValue(g_hTrie,   "m4a1", 0);
                        SetTrieValue(g_hTrie,   "scout", 0);
                        SetTrieValue(g_hTrie,   "sg550", 0);
                        SetTrieValue(g_hTrie,   "aug", 0);
                        SetTrieValue(g_hTrie,   "awp", 0);
                        SetTrieValue(g_hTrie,   "g3sg1", 0);
                        SetTrieValue(g_hTrie,   "sg552", 0);
                        SetTrieValue(g_hTrie,   "m249", 0);
                }
                case 1:
                {
                        SetTrieValue(g_hTrie,   "glock",        1);
                        SetTrieValue(g_hTrie,   "usp",  1);
                        SetTrieValue(g_hTrie,   "p228", 1);
                        SetTrieValue(g_hTrie,   "deagle",1);
                        SetTrieValue(g_hTrie,   "elite",        1);
                        SetTrieValue(g_hTrie,   "fiveseven", 1);
                }
        }
}
 
public OnMapStart()
{
        LoadTrieValue(g_iSlot);
        for(new i = 1; i <= MaxClients; i++) 
        {
                if(g_hArray[i][0] != INVALID_HANDLE && g_hArray[i][1] != INVALID_HANDLE) 
                {
                        ClearArray(g_hArray[i][0]); 
                        ClearArray(g_hArray[i][1]);
                }
                else 
                {
                        g_hArray[i][0] = CreateArray(8); 
                        g_hArray[i][1] = CreateArray(10); 
                }
        }
}
 
public OnClientPostAdminCheck(client) 
{
        g_bAdminOn[client] = CheckCommandAccess(client, "TwoGuns", g_iFlag);
}
 
public Event_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast) 
{ 
        if(GetEventInt(event, "health") < 1) OnClientDisconnect(GetClientOfUserId(GetEventInt(event, "userid")));
}
 
public Action:CS_OnBuyCommand(client, const String:weapon[]) 
{
        if(!g_bAdminOn[client]) return Plugin_Continue; 
        decl iSlot; 
        if (!GetTrieValue(g_hTrie, weapon, iSlot) || GetPlayerWeaponSlot(client, iSlot) == -1) return Plugin_Continue; 
        switch(GetArraySize(g_hArray[client][iSlot]))
        {
                case 0: PushArrayString(g_hArray[client][iSlot], weapon); 
                case 2: PushArrayString(g_hArray[client][iSlot], weapon); 
        }
        return Plugin_Continue; 
}
 
public Action:CS_OnCSWeaponDrop(client, weapon) 
{ 
        if(!g_bAdminOn[client]) return Plugin_Continue; 
        decl String:sWeapon[20], iSlot; 
        GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
        if (!GetTrieValue(g_hTrie, sWeapon[7], iSlot)) return Plugin_Continue; 
        switch(GetArraySize(g_hArray[client][iSlot]))
        {
                case 1: 
                {
                        PushArrayString(g_hArray[client][iSlot], sWeapon[7]); 
                        SwapArrayItems(g_hArray[client][iSlot], 0, 1);
                        DeleteWeaponClient(client, weapon, iSlot, false);
                }
                case 2:
                {
                        RemoveFromArray(g_hArray[client][iSlot], 1); 
                        decl String:sClientWeapon[20] = "weapon_"; 
                        GetArrayString(g_hArray[client][iSlot], 0, sClientWeapon[7], 20); 
                        RemoveFromArray(g_hArray[client][iSlot], 0);
                        GivePlayerItem(client, sClientWeapon);
                }
                case 3: RemoveFromArray(g_hArray[client][iSlot], 1);
        }
        return Plugin_Continue; 
}
 
public OnClientDisconnect(client) 
{
        ClearArray(g_hArray[client][0]); 
        ClearArray(g_hArray[client][1]); 
}
 
public Action:UzyjFunkcji(client, args)
{
        if(g_bAdminOn[client] && IsClientInGame(client) && IsPlayerAlive(client))
        {
                static iWeapon; 
                if(!g_bReload[client] && CheckFloodClient(client) && (iWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon")) != -1)
                {
                        static String:sClientWeapon[20], iSlot; 
                        GetEdictClassname(iWeapon, sClientWeapon, sizeof(sClientWeapon));
                        if (!GetTrieValue(g_hTrie, sClientWeapon[7], iSlot)) g_bReload[client] = true;
                        else if(GetArraySize(g_hArray[client][iSlot]) == 2) 
                        {
                                static String:sWeapon[20] = "weapon_";
                                DeleteWeaponClient(client, iWeapon, iSlot, true);
                                GetArrayString(g_hArray[client][iSlot], 0, sWeapon[7], 20); 
                                SwapArrayItems(g_hArray[client][iSlot], 0, 1);
                                SetAmmoClient(client, GivePlayerItem(client, sWeapon), iSlot);
                        }
                        else g_bReload[client] = true;
                }
        }
        else g_bReload[client] = false;

        return Plugin_Continue;
}

DeleteWeaponClient(client, weapon, slot, bool:reload)  
{
        if(IsClientInGame(client) && IsPlayerAlive(client))
        {
                if(reload)
                {
                        g_iAmmoClient[client][slot][0] = g_iReservClient[client][slot][0];
                        g_iAmmoClient [client][slot][1]= g_iReservClient[client][slot][1];
                }
                new PrimaryAmmoType = -1;
                if((PrimaryAmmoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType")) != -1) 
                {
                        g_iReservClient[client][slot][1] = GetEntProp(client, Prop_Data, "m_iAmmo", 4, PrimaryAmmoType);
                        g_iReservClient[client][slot][0] = GetEntProp(weapon, Prop_Send, "m_iClip1");
                }
                if(RemovePlayerItem(client, weapon)) AcceptEntityInput(weapon, "Kill");
        }
}
 
SetAmmoClient(client, weapon, iSlot)
{
        new PrimaryAmmoType = -1;
        if((PrimaryAmmoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType")) != -1) 
        {
                SetEntProp(client, Prop_Send, "m_iAmmo", g_iAmmoClient[client][iSlot][1], _, PrimaryAmmoType);
                SetEntProp(weapon, Prop_Send, "m_iClip1", g_iAmmoClient[client][iSlot][0]);
        }
}
 
bool:CheckFloodClient(client)
{
        new Float:fCurTime = GetGameTime();
        new Float:fNewTime = fCurTime + 0.45;
        if (g_iFloodClient[client][0] > fCurTime)
        {
                if(g_iFloodClient[client][1] > ANTIFLOOD) 
                {
                        g_iFloodClient[client][0] = fNewTime;
                        return false;
                }
                g_iFloodClient[client][1]++;
        }
        else if (g_iFloodClient[client][1] > 0) g_iFloodClient[client][1]--;
        g_iFloodClient[client][0] = fNewTime;
        return true;
}
