//---------------------------------------------------
//         *****!Do not edit this file!*****
//---------------------------------------------------
//    ___              __  _       
//   / __| ___  _ _   / _|(_) __ _ 
//  | (__ / _ \| ' \ |  _|| |/ _` |
//   \___|\___/|_||_||_|  |_|\__, |
//    ___  _              _  |___/ 
//   / __|| |_   ___  __ | |__(_)  
//  | (__ | ' \ / -_)/ _|| / / _   
//   \___||_||_|\___|\__||_\_\(_)  
//---------------------------------------------------
// Purpose: Verifies valid options in config.nut
//           and compensates for each variable.
//---------------------------------------------------

// Can't create a function to redefine existing
// variables, so we just do it one by one :D

function ConfigValueError(invalidorundefined, command) {
    printl("(P2:MM): " + invalidorundefined + " value provided for " + command + "! Treating as default value. Verify valid options for this in config.nut")
}

try {
    if (typeof(Config_DevMode) != "bool") {
        Config_DevMode <- false
        ConfigValueError("Invalid", "Config_DevMode")
    }
} catch (exception) {
    Config_DevMode <- false
    ConfigValueError("Undefined", "Config_DevMode")
}

try {
    if (typeof(Config_VisualDebug) != "bool") {
        Config_VisualDebug <- false
        ConfigValueError("Invalid", "Config_VisualDebug")
    }
} catch (exception) {
    Config_VisualDebug <- false
    ConfigValueError("Undefined", "Config_VisualDebug")
}

try {
    if (typeof(Config_GameMode) != "integer") {
        Config_GameMode <- 0
        ConfigValueError("Invalid", "Config_GameMode")
    }
} catch (exception) {
    Config_GameMode <- 0
    ConfigValueError("Undefined", "Config_GameMode")
}

try {
    if (typeof(Config_RandomTurrets) != "bool") {
        Config_RandomTurrets <- false
        ConfigValueError("Invalid", "Config_RandomTurrets")
    }
} catch (exception) {
    Config_RandomTurrets <- false
    ConfigValueError("Undefined", "Config_RandomTurrets")
}

try {
    if (typeof(Config_RandomPortalSize) != "bool") {
        Config_RandomPortalSize <- false
        ConfigValueError("Invalid", "Config_RandomPortalSize")
    }
} catch (exception) {
    Config_RandomPortalSize <- false
    ConfigValueError("Undefined", "Config_RandomPortalSize")
}

try {
    if (typeof(Config_UseColorIndicator) != "bool") {
        Config_UseColorIndicator <- true
        ConfigValueError("Invalid", "Config_UseColorIndicator")
    }
} catch (exception) {
    Config_UseColorIndicator <- true
    ConfigValueError("Undefined", "Config_UseColorIndicator")
}

try {
    if (typeof(Config_UseJoinIndicator) != "bool") {
        Config_UseJoinIndicator <- true
        ConfigValueError("Invalid", "Config_UseJoinIndicator")
    }
} catch (exception) {
    Config_UseJoinIndicator <- true
    ConfigValueError("Undefined", "Config_UseJoinIndicator")
}

try {
    if (typeof(Config_SafeGuard) != "bool") {
        Config_SafeGuard <- false
        ConfigValueError("Invalid", "Config_SafeGuard")
    }
} catch (exception) {
    Config_SafeGuard <- false
    ConfigValueError("Undefined", "Config_SafeGuard")
}

try {
    if (typeof(Config_UseChatCommands) != "bool") {
        Config_UseChatCommands <- true
        ConfigValueError("Invalid", "Config_UseChatCommands")
    }
} catch (exception) {
    Config_UseChatCommands <- true
    ConfigValueError("Undefined", "Config_UseChatCommands")
}

function DefaultAdminList() {
    Admins <- [
        "[400]182933216", // kyleraykbs
        "[400]75927374", // Wolƒe Strider Shoσter
        "[400]290760494", // Nanoman2525
        "[400]1106347501", // vista
        "[400]181670710", // Bumpy
        "[400]72399433", // cabiste
        "[400]242453954", // sear
    ]
}

try {
    if (typeof(Admins) != "array") {
        DefaultAdminList()
        ConfigValueError("Invalid", "Admins")
    } else {
        foreach (admin in Admins) {
            local level = split(admin, "[]")[0]
            local SteamID = split(admin, "]")[1]

            if (typeof(level.tointeger()) != "integer" || typeof(SteamID.tointeger()) != "integer") {
                DefaultAdminList()
                ConfigValueError("Invalid", "Admins")
                return
            } 
        }
    }
} catch (exception) {
    DefaultAdminList()
    ConfigValueError("Undefined", "Admins")
}
