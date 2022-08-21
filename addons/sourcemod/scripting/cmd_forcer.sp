#include <sourcemod>

#include "cmd_forcer/config.sp"

CFKeyValues g_KeyValue;

public Plugin:myinfo =
{
    name = "Command Forcer",
    author = "Nopied◎",
    description = "Sourcemod Plugin Command Forcer",
    version = "2.0",
    url = "https://steamcommunity.com/id/iuy0223/"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    // cmd_forcer/configs.sp
    KV_Native_Init();
}

public void OnPluginStart()
{
    AddCommandListener(PlayerSay_Listener, "say");
    AddCommandListener(PlayerSay_Listener, "say_team");
}

public void OnMapStart()
{
    if(g_KeyValue != null)
        delete g_KeyValue;

    g_KeyValue = new CFKeyValues();
}

public Action PlayerSay_Listener(int client, const char[] command, int argc)
{
    if(!IsValidClient(client)) return Plugin_Continue;

    char strChat[128], temp[2][64];
    char replaceCommand[128];
    GetCmdArgString(strChat, sizeof(strChat));

    int start;
    bool slient = false;

    if(strChat[start] == '"') start++;
    if(strChat[start] == '!' || strChat[start] == '/')
    {
        slient = strChat[start] == '/';
        start++;
    }
    strChat[strlen(strChat)-1] = '\0';
    ExplodeString(strChat[start], " ", temp, 2, 128, true);

    if(temp[0][0] == '\0' || temp[0][0] == ' ')
        return Plugin_Continue;

    g_KeyValue.Rewind();
    g_KeyValue.GetString(temp[0], replaceCommand, sizeof(replaceCommand));
    
    if(replaceCommand[0] != '\0')
    {
        SetCmdReplySource(SM_REPLY_TO_CHAT);
        FakeClientCommandEx(client, "%s %s", replaceCommand, temp[1]);
        // LogMessage("%s %s", replaceCommand, temp[1]);
        return slient ? Plugin_Handled : Plugin_Continue;
    }

    return Plugin_Continue;
}

stock bool IsValidClient(client)
{
	return (0 < client && client < MaxClients && IsClientInGame(client));
}
