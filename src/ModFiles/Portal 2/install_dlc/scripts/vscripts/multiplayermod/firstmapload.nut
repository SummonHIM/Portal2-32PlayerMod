//---------------------------------------------------
//         *****!Do not edit this file!*****
//---------------------------------------------------
// Purpose: Only runs on first map load of session
//---------------------------------------------------

// Reset dev level
// Developer needs to stay enabled for VScript Debugging to work
if (Config_DevMode || Config_VScriptDebug) {
    EntFire("p2mm_servercommand", "command", "developer 1")
}
else {
    EntFire("p2mm_servercommand", "command", "clear; developer 0")
}

if (!PluginLoaded) {
    // Remove Portal Gun (Map transition will sound less abrupt)
    // Can't use UTIL_Team.Spawn_PortalGun(false) since the .nut file has not been loaded
    Entities.CreateByClassname("info_target").__KeyValueFromString("targetname", "supress_blue_portalgun_spawn")
    Entities.CreateByClassname("info_target").__KeyValueFromString("targetname", "supress_orange_portalgun_spawn")

    EntFire("p2mm_servercommand", "command", "script printl(\"(P2:MM VSCRIPT): Attempting to load the P2:MM plugin...\")", 0.03)
    EntFire("p2mm_servercommand", "command", "plugin_load p2mm", 0.05) // This should never fail the first time through addons... try loading it from root DLC path
} else {
    printlP2MM("Plugin has already been loaded! Not attempting to load it...")
}

if (Config_GameMode == 1) {
    EntFire("p2mm_servercommand", "command", "p2mm_set_preset \"speedrun\"", 0.50) // Set the p2mm plugin to use the speedrun preset for the mod
} else {
    EntFire("p2mm_servercommand", "command", "p2mm_set_preset \"normal\"", 0.50) // Set the p2mm plugin to use the normal preset for the mod
}

EntFire("p2mm_servercommand", "command", "stopvideos; changelevel " + GetMapName(), 1) // Must be delayed. We use changelevel to restart the map because restart_level is locked by the plugin by default
