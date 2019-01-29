#define CMD_CONFIG_NAME "cmd_forcer"

methodmap CFKeyValues < KeyValues {
    public CFKeyValues()
    {
        CFKeyValues kv = view_as<CFKeyValues>(LoadDataConfig());
        return kv;
    }

    // NOTE: @value, @buffer is only can use with KvData_String and KvData_Color. and In this case, successful return is always true.
    // And.. It returns String, Int, Float, Color. So, DO NOT set @datatype to anything else.
    // default value is always 0, or "".
    // If @subKey is empty, this will use current position. (Will good )
    public native any GetValue(const char[] subKey, const char[] key, KvDataTypes datatype, char[] value = "", int buffer = 0);

    // NOTE: If couldn't find keys, return false.
    // And MUST USE STRING.
    public native bool GotoKeys(any ...);
}

void KV_Native_Init()
{
    CreateNative("CFKeyValues.GetValue", Native_CFKeyValues_GetValue);
    CreateNative("CFKeyValues.GotoKeys", Native_CFKeyValues_GotoKeys);
}

public int Native_CFKeyValues_GetValue(Handle plugin, int numParams)
{
    CFKeyValues thisKv = GetNativeCell(1);

    char subKey[64], key[64], value[256];
    GetNativeString(2, subKey, sizeof(subKey));
    GetNativeString(3, key, sizeof(key));

    KvDataTypes datatype = GetNativeCell(4);
    int buffer = GetNativeCell(6);

    if(subKey[0] != '\0') {
        thisKv.Rewind();
        if(!thisKv.JumpToKey(subKey)) return -1;
    }

    switch(datatype)
    {
        case KvData_String, KvData_Color:
        {
            thisKv.GetString(key, value, buffer, "");
            SetNativeString(5, value, buffer);

            return 1;
        }
        case KvData_Int:
        {
            return thisKv.GetNum(key, 0);
        }
        case KvData_Float:
        {
            return view_as<int>(thisKv.GetFloat(key, 0.0));
        }
    }

    return -1;
}

public int Native_CFKeyValues_GotoKeys(Handle plugin, int numParams)
{
    CFKeyValues thisKv = GetNativeCell(1);

    char subKey[128];
    thisKv.Rewind();

    for(int loop = 1; loop <= numParams; loop++)
    {
        GetNativeString(loop, subKey, sizeof(subKey));
        if(!thisKv.JumpToKey(subKey))
            return false;
    }

    return true;
}

stock KeyValues LoadDataConfig()
{
    char dirPath[PLATFORM_MAX_PATH], config[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, dirPath, sizeof(dirPath), "configs/%s", CMD_CONFIG_NAME);
    FileType filetype;
    DirectoryListing dirListener = OpenDirectory(dirPath);
    KeyValues kv = new KeyValues(CMD_CONFIG_NAME);

    while(dirListener.GetNext(config, PLATFORM_MAX_PATH, filetype))
    {
        Format(config, PLATFORM_MAX_PATH, "%s/%s", dirPath, config);
        if(FileExists(config)) { // FIXME: THINKING
            kv.ImportFromFile(config);
            LogMessage("Added %s To KeyValues!", config);
        }
    }

    // 중복 아이디, 빈 아이디 체크
    char key[64];
    ArrayList array = new ArrayList(128, _);

    kv.Rewind();
    if(kv.GotoFirstSubKey())
    {
        do
        {
            kv.GetSectionName(key, sizeof(key));

            if(key[0] == '\0')    continue;
            else if(array.FindString(key) != -1) { // FIXME?
                LogError("command ''%s'' has same name in other!", key);
                continue;
            }

            array.PushString(key);
        }
        while(kv.GotoNextKey());
    }
    delete array;
    //

    return kv;
}
