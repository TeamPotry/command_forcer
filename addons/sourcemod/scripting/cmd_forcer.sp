#include <sourcemod>

#include "cmd_forcer/config.sp"

CFKeyValues g_KeyValue;
StringMap g_PluginStringMap;
StringMap g_StringMap;

public Plugin:myinfo =
{
    name = "Command Forcer",
    author = "Nopied◎",
    description = "Sourcemod Plugin Command Forcer",
    version = "1.0",
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
    if(g_PluginStringMap != null)
        delete g_PluginStringMap;
    g_PluginStringMap = new StringMap();

    if(g_StringMap != null)
        delete g_StringMap;
    g_StringMap = new StringMap();

    if(g_KeyValue != null)
        delete g_KeyValue;
    g_KeyValue = new CFKeyValues();

    RegisterPlugins();
}

void RegisterPlugins()
{
    Handle iter = GetPluginIterator(), plugin = null;
    char pluginName[PLATFORM_MAX_PATH];

    while(MorePlugins(iter))
    {
        plugin = ReadPlugin(iter);
        GetPluginFilename(plugin, pluginName, PLATFORM_MAX_PATH);

        g_PluginStringMap.SetValue(pluginName, plugin, true);
    }

    delete iter;
}

public Action PlayerSay_Listener(int client, const char[] command, int argc)
{
    if(!IsValidClient(client)) return Plugin_Continue;

    char strChat[128], temp[2][64];
    char pluginName[PLATFORM_MAX_PATH], functionName[128];
    Handle plugin = null;
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
    if(g_KeyValue.JumpToKey(temp[0]))
    {
        /*
            if(temp[1][0] != '\0')
            {
            return slient ? Plugin_Handled : Plugin_Continue;
            }
        */
        g_KeyValue.GetString("plugin", pluginName, sizeof(pluginName));
        g_KeyValue.GetString("function", functionName, sizeof(functionName));
        if(g_PluginStringMap.GetValue(pluginName, plugin))
        {
            Function func = GetFunctionByName(plugin, functionName);
            if(func != INVALID_FUNCTION)
            {
                Call_StartFunction(plugin, func);
                Call_PushCell(client);
                Call_PushCell(0); // TODO; ARG 전달
                Call_Finish();

                return slient ? Plugin_Handled : Plugin_Continue;
            }
        }
    }

    return Plugin_Continue;
}

stock bool IsValidClient(client)
{
	return (0 < client && client < MaxClients && IsClientInGame(client));
}
