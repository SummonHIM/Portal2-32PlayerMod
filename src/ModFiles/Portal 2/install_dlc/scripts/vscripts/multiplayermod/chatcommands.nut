//---------------------------------------------------
//         *****!Do not edit this file!*****
//---------------------------------------------------
//    ___  _           _
//   / __|| |_   __ _ | |_
//  | (__ | ' \ / _` ||  _|
//   \___||_||_|\__,_| \__|                  _      _
//   / __| ___  _ __   _ __   __ _  _ _   __| | ___(_)
//  | (__ / _ \| '  \ | '  \ / _` || ' \ / _` |(_-< _
//   \___|\___/|_|_|_||_|_|_|\__,_||_||_|\__,_|/__/(_)
//---------------------------------------------------
// Purpose: Enable commands through the chat box.
//---------------------------------------------------

// This can only be enabled when the plugin is loaded
if (PluginLoaded) {
    if (GetDeveloperLevel()) {
        printl("(P2:MM): Plugin loaded! Adding chat callback for chat commands.")
    }
    AddChatCallback("ChatCommands")
} else {
    if (GetDeveloperLevel()) {
        printl("(P2:MM): Cannot add chat commands since no plugin is loaded!")
        return
    }
}

// Chat command hooks provided by our plugin
function ChatCommands(ccuserid, ccmessage) {

    ///////////////////////////////////////////
    local Message = RemoveDangerousChars(ccmessage)
    ///////////////////////////////////////////

    //////////////////////////////////////////////
    if (ShouldIgnoreMessage(Message)) { return }
    //////////////////////////////////////////////

    //////////////////////////////////////////////
    local Player = GetPlayerFromUserID(ccuserid)
    local Inputs = SplitBetween(Message, "!@", true)
    local PlayerClass = FindPlayerClass(Player)
    local Username = PlayerClass.username
    local AdminLevel = GetAdminLevel(Player)
    //////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////
    function Rem(s) { return Replace(Replace(s, "!", ""), "@", "") }
    ////////////////////////////////////////////////////////////////

    ////////////////////////////////////////
    local Commands = []
    local Selectors = []

    foreach (Input in Inputs) {
        if (StartsWith(Input, "!")) {
            if (Message.slice(0, 1) == "!" && Message != "!" && Message.slice(0, 2) != "!!" && Message.slice(0, 2) != "! ") {
                Commands.push(Rem(Input))
            }
        } else if (StartsWith(Input, "@")) {
            if (Message.slice(0, 1) == "@"  && Message != "@" && Message.slice(0, 2) != "@@" && Message.slice(0, 2) != "@ ") {
                Selectors.push(Rem(Input))
            }
        }
    }
    ////////////////////////////////////////

    ////////////////////////////////////////////////////
    local Runners = []
    local UsedRunners = true

    foreach (Selector in Selectors) {
        if (Selector == "all" || Selector == "*" || Selector == "everyone") {
            Runners = []
            local p = null
            while (p = Entities.FindByClassname(p, "player")) {
                Runners.push(p)
            }
            break
        }
        local NewRunner = FindPlayerByName(Selector)

        if (NewRunner) {
            Runners.push(NewRunner)
        }
    }

    if (Runners.len() == 0) {
        Runners.push(Player)
        UsedRunners = false
    }
    ////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////
    foreach (Command in Commands) {
        Command = Strip(Command)

        // Does the exact command exist?
        if (!ValidateCommand(Command)) {
            return ErrorOutCommand(0)
        }

        // Split arguments
        local Args = SplitBetween(Command, " ", true)
        if (Args.len() > 0) {
            Args.remove(0)
        }

        // Do we have the correct admin level for this command?
        Command = GetCommandFromString(Command)
        if (!ValidateCommandAdminLevel(Command, AdminLevel)) {
            return ErrorOutCommand(1, Command)
        }

        // Another admin level check for selectors
        if (UsedRunners) {
            if (!ValidateAlowedRunners(Command, AdminLevel)) {
                return ErrorOutCommand(3, Command)
            }
        }

        // We met the criteria, run it
        foreach (CurPlayer in Runners) {
            RunChatCommand(Command, Args, CurPlayer)
        }
    }
    ///////////////////////////////////////////////////////////

}

//=====================================================================================

////////////////////////////////////////
////////////// CHAT COMMANDS ///////////

ChatCommandErrorList <- [
    "[ERROR] Command not found.",
    "[ERROR] Invalid syntax.",
    "[ERROR] You do not have permission to use this command.",
    "[ERROR] You cannot use selectors with this command since your admin level is too low.",
]

////////////////////////////////////////////////////////

CommandList <- []

////////////



/////////////////////////////////// NOCLIP
function NoclipCommand(plr, args) {
    local pclass = FindPlayerClass(plr)
    if (pclass.noclip) {
        EnableNoclip(false, plr)
    } else {
        EnableNoclip(true, plr)
    }
}

CommandList.push(class {
    name = "noclip"
    level = 4
    selectorlevel = 2
    func = NoclipCommand

    notfounderror = ChatCommandErrorList[0]
    syntaxerror = ChatCommandErrorList[1]
    permerror = ChatCommandErrorList[2]
    selectorpermerror = ChatCommandErrorList[3]
})
////////////////////////////////////////////

/////////////////////////////////////// KILL
function KillCommand(plr, args) {
    try {
        args[0] = Strip(args[0])

        if (args[0] != "all") {
            local q = FindPlayerByName(args[0])
            if (q != null) {
                EntFireByHandle(q, "sethealth", "-100", 0, q, q)
                SendChatMessage("Killed player.")
            } else {
                SendChatMessage("[ERROR] Player not found.")
            }
        } else {
            local p2 = null
            while (p2 = Entities.FindByClassname(p2, "player")) {
                EntFireByHandle(p2, "sethealth", "-100", 0, p2, p2)
            }
            SendChatMessage("Killed all players.")
        }
    } catch (exception) {
        EntFireByHandle(plr, "sethealth", "-100", 0, plr, plr)
    }
}

CommandList.push(class {
    name = "kill"
    level = 2
    selectorlevel = 1
    func = KillCommand

    notfounderror = ChatCommandErrorList[0]
    syntaxerror = ChatCommandErrorList[1]
    permerror = ChatCommandErrorList[2]
    selectorpermerror = ChatCommandErrorList[3]
})
////////////////////////////////////////////

//////////////////////////////// Change Team
function ChangeTeamCommand(p, args) {
    try {
        args[0] = Strip(args[0])

        if (args[0] == "0" || args[0] == "2" ||args[0] == "3" ) {

            local teams = {}
            teams[0] <- "Singleplayer"
            teams[1] <- "Spectator" // this is not used rn since it's heavily broken
            teams[2] <- "Red"
            teams[3] <- "Blue"

            if (p.GetTeam() == args[0].tointeger()) {
                return EntFireByHandle(p2mm_clientcommand, "Command", "say [ERROR] You are already on this team.", 0, p, p)
            } else {
                p.SetTeam(args[0].tointeger())
                return EntFireByHandle(p2mm_clientcommand, "Command", "say Team is now set to " + teams[args[0].tointeger()] + ".", 0, p, p)
            }
        }
        EntFireByHandle(p2mm_clientcommand, "Command", "say [ERROR] Enter a valid team number: 0, 2, or 3.", 0, p, p)
    } catch (exception) {
        if (args.len() == 0) {
            if (p.GetTeam() == 0) {
                p.SetTeam(2)
                EntFireByHandle(p2mm_clientcommand, "Command", "say Toggled to Red team.", 0, p, p)
            }
            else if (p.GetTeam() == 2) {
                p.SetTeam(3)
                EntFireByHandle(p2mm_clientcommand, "Command", "say Toggled to Blue team.", 0, p, p)
            }
            // if the player is in team 3 or above it will just reset them to team 0
            else {
                p.SetTeam(0)
                EntFireByHandle(p2mm_clientcommand, "Command", "say Toggled to Singleplayer team.", 0, p, p)
            }
        }
    }
}
CommandList.push(class {
    name = "changeteam"
    level = 0
    selectorlevel = 1
    func = ChangeTeamCommand

    notfounderror = ChatCommandErrorList[0]
    syntaxerror = ChatCommandErrorList[1]
    permerror = ChatCommandErrorList[2]
    selectorpermerror = ChatCommandErrorList[3]
})
////////////////////////////////////////////

////////////////////////////////// Set Speed
function ChangeSpeedCommand(p, args) {
    try {
        SetSpeed(p, args[0].tofloat())
    } catch (exception) {
        EntFireByHandle(p2mm_clientcommand, "Command", "say [ERROR] Input a number.", 0, p, p)
    }
}

CommandList.push(class {
    name = "speed"
    level = 4
    selectorlevel = 2
    func = ChangeSpeedCommand

    notfounderror = ChatCommandErrorList[0]
    syntaxerror = ChatCommandErrorList[1]
    permerror = ChatCommandErrorList[2]
    selectorpermerror = ChatCommandErrorList[3]
})
////////////////////////////////////////////

/////////////////////////////////// TELEPORT
function TeleportCommand(p, args) {
    if (args.len() != 0) {
        args[0] = Strip(args[0])
        local plr = FindPlayerByName(args[0])
        if (plr != null) {
            try {
                // See if there's a third argument
                args[1] = Strip(args[1])
                local plr2 = FindPlayerByName(args[1])
                if (args[1] == "all") {
                    // Third argument was "all"
                    local q = null
                    while (q = Entities.FindByClassname(q, "player")) {
                        // Don't modify the player we are teleporting to
                        if (q != plr) {
                            q.SetOrigin(plr.GetOrigin())
                            q.SetAngles(plr.GetAngles().x, plr.GetAngles().y, plr.GetAngles().z)
                        }
                    }
                    if (plr == p) {
                        SendChatMessage("Brought all players.")
                    } else {
                        SendChatMessage("Teleported all players.")
                    }
                }
                else if (plr2 != null) {
                    // We found a username in the third argument
                    if (plr2 != plr) {
                        plr2.SetOrigin(plr.GetOrigin())
                        plr2.SetAngles(plr.GetAngles().x, plr.GetAngles().y, plr.GetAngles().z)
                        if (plr2 == p) {
                            return SendChatMessage("Teleported to player.")
                        } else {
                            return SendChatMessage("Teleported player.")
                        }
                    }
                    if (plr == p || plr == plr2) {
                        return SendChatMessage("[ERROR] Can't teleport player to the same player.")
                    }
                } else {
                    SendChatMessage("[ERROR] Third argument is invalid! Use \"all\" or a player's username.")
                }
            } catch (exception) {
                // There was no third argument
                if (plr == p) {
                    SendChatMessage("[ERROR] You are already here lol.")
                } else {
                    p.SetOrigin(plr.GetOrigin())
                    p.SetAngles(plr.GetAngles().x, plr.GetAngles().y, plr.GetAngles().z)
                    SendChatMessage("Teleported to player.")
                }
            }
        } else {
            SendChatMessage("[ERROR] Player not found.")
        }
    } else {
        SendChatMessage("[ERROR] Input a player name.")
    }
}

CommandList.push(class {
    name = "teleport"
    level = 4
    selectorlevel = 2
    func = TeleportCommand

    notfounderror = ChatCommandErrorList[0]
    syntaxerror = ChatCommandErrorList[1]
    permerror = ChatCommandErrorList[2]
    selectorpermerror = ChatCommandErrorList[3]
})
////////////////////////////////////////////

/////////////////////////////////////// RCON
function RconCommand(p, args) {
    try {
        args[0] = Strip(args[0])
        local cmd = Join(args, "")
        SendToConsoleP232(cmd)
    } catch (exception) {
        EntFireByHandle(p2mm_clientcommand, "Command", "say [ERROR] Input a command.", 0, p, p)
    }
}

CommandList.push(class {
    name = "rcon"
    level = 6
    selectorlevel = 3
    func = RconCommand

    notfounderror = ChatCommandErrorList[0]
    syntaxerror = ChatCommandErrorList[1]
    permerror = ChatCommandErrorList[2]
    selectorpermerror = ChatCommandErrorList[3]
})
////////////////////////////////////////////

////////////////////////////// RESTART LEVEL
function RestartLevelCommand(p, args) {
    local p = null
    while (p = Entities.FindByClassname(p, "player")) {
        EntFireByHandle(p2mm_clientcommand, "Command", "playvideo_end_level_transition coop_bots_load", 0, p, p)
        EntFire("p2mm_servercommand", "command", "changelevel " + GetMapName(), 0.5, null)
    }
}

CommandList.push(class {
    name = "restartlevel"
    level = 5
    selectorlevel = 1
    func = RestartLevelCommand

    notfounderror = ChatCommandErrorList[0]
    syntaxerror = ChatCommandErrorList[1]
    permerror = ChatCommandErrorList[2]
    selectorpermerror = ChatCommandErrorList[3]
})
////////////////////////////////////////////

/////////////////////////////////////// HELP

function HelpCommand(p, args) {

    local commandtable = {}
    commandtable["help"] <- "List available commands or print a description of a specific one."
    commandtable["noclip"] <- "Toggles noclip mode."
    commandtable["kill"] <- "Kill yourself, others, or \"all\"."
    commandtable["changeteam"] <- "Changes your current team."
    commandtable["speed"] <- "Changes your player speed."
    commandtable["teleport"] <- "Teleports a specific player or \"all\" to you or another player."
    commandtable["rcon"] <- "Execute commands on the server console."
    commandtable["restartlevel"] <- "Reset the current map."
    commandtable["spchapter"] <- "Changes the level to the first level in a specified singleplayer chapter."
    commandtable["mpcourse"] <- "Changes the level to the first level in a specified cooperative course."
    commandtable["playercolor"] <- "Changes your model's color through valid RGB values."

    try {
        args[0] = Strip(args[0])
        if (commandtable.rawin(args[0])) {
            EntFireByHandle(p2mm_clientcommand, "Command", "say [HELP] " + args[0] + ": " + commandtable[args[0]], 0, p, p)
        }
        else {
            EntFireByHandle(p2mm_clientcommand, "Command", "say [HELP] Unknown chat command: " + args[0], 0, p, p)
        }
    } catch (exception) {
        SendChatMessage("[HELP] Your available commands:")
        foreach (command in CommandList) {
            if (command.level <= GetAdminLevel(p)) {
                SendChatMessage("[HELP] " + command.name)
            }
        }
        SendChatMessage("[HELP] This command can also print a description for another if supplied with it.")
    }
}

CommandList.push(class {
    name = "help"
    level = 0
    selectorlevel = 3
    func = HelpCommand

    notfounderror = ChatCommandErrorList[0]
    syntaxerror = ChatCommandErrorList[1]
    permerror = ChatCommandErrorList[2]
    selectorpermerror = ChatCommandErrorList[3]
})

////////////////////////////////////////////

///////////////////////////////// SP CHAPTER

function SPChapterCommand(p, args) {
    try{
        args[0] = args[0].tointeger()
    } catch (err){
        SendChatMessage("Type in a valid number from 1 to 9.")
        return
    }

    if (args[0].tointeger() < 1 || args[0].tointeger() > 9) {
        SendChatMessage("Type in a valid number from 1 to 9.")
        return
    }
    spmapnames <- [
        "sp_a1_intro1",
        "sp_a2_laser_intro",
        "sp_a2_sphere_peek",
        "sp_a2_column_blocker",
        "sp_a2_bts3",
        "sp_a3_00",
        "sp_a3_speed_ramp",
        "sp_a4_intro",
        "sp_a4_finale1"
    ]
    SendToConsoleP232("changelevel " + spmapnames[args[0]-1])
}

CommandList.push(class {
    name = "spchapter"
    level = 5
    selectorlevel = 3
    func = SPChapterCommand

    notfounderror = ChatCommandErrorList[0]
    syntaxerror = ChatCommandErrorList[1]
    permerror = ChatCommandErrorList[2]
    selectorpermerror = ChatCommandErrorList[3]
})
////////////////////////////////////////////

///////////////////////////////// MP COURSE

function MPCourseCommand(p, args) {
    try{
        args[0] = args[0].tointeger()
    } catch (err){
        SendChatMessage("Type in a valid number from 1 to 6.")
        return
    }

    local allp = Entities.FindByClassname(null, "player")

    if (args.len() == 0 || args[0].tointeger() < 1 || args[0].tointeger() > 6) {
        SendChatMessage("Type in a valid number from 1 to 6.")
        return
    }

    mpmapnames <- [
        "mp_coop_doors",
        "mp_coop_fling_3",
        "mp_coop_wall_intro",
        "mp_coop_tbeam_redirect",
        "mp_coop_paint_come_along",
        "mp_coop_separation_1",
    ]
    EntFireByHandle(p2mm_clientcommand, "Command", "playvideo_end_level_transition coop_bots_load", 0, allp, allp)
    EntFire("p2mm_servercommand", "command", "changelevel " + mpmapnames[args[0]-1], 0.25, null)
}

CommandList.push(class {
    name = "mpcourse"
    level = 5
    selectorlevel = 3
    func = MPCourseCommand

    notfounderror = ChatCommandErrorList[0]
    syntaxerror = ChatCommandErrorList[1]
    permerror = ChatCommandErrorList[2]
    selectorpermerror = ChatCommandErrorList[3]
})
////////////////////////////////////////////

////////////////////////////// PLAYER COLOR

function PlayerColorCommand(p, args) {

    function IsCustomColorIntegerValid(x) {
        // if x is a string it will throw an error so we'll set it to -1 so it returns false
        try {
            x = x.tointeger()
        } catch (err){
            x = -1
        }

        if (x >= 0 && x <= 255) {
            return true
        }
        return false
    }

    if (args.len() < 3) {
        return SendChatMessage("Type in three valid integers from 0 to 255 separated by a space.")
    }

    // make sure that all args are ints
    for (local i = 0; i < args.len() ; i += 1){
        if (IsCustomColorIntegerValid(args[i]) != true ){
            return SendChatMessage("Type in three valid integers from 0 to 255 separated by a space.")
        }
        args[i] = args[i].tointeger()
    }

    class pcolor {
        r = args[0]
        g = args[1]
        b = args[2]
        name = "custom color"
    }
    CreateGenericPlayerClass(p, pcolor)
    SendChatMessage("Successfully changed color.")

    SendChatMessage("Currently nonfunctional.")
}

CommandList.push(class {
    name = "playercolor"
    level = 1
    selectorlevel = 3
    func = PlayerColorCommand

    notfounderror = ChatCommandErrorList[0]
    syntaxerror = ChatCommandErrorList[1]
    permerror = ChatCommandErrorList[2]
    selectorpermerror = ChatCommandErrorList[3]
})
////////////////////////////////////////////

function SendChatMessage(message, delay = 0) {
    // SendToConsoleP232("say " + message)
    EntFire("p2mm_servercommand", "command", "say " + message, delay)
}

function RemoveDangerousChars(str) {
    str = Replace(str, "%n", "")
    return str
}

function ShouldIgnoreMessage(str) {
    if (StartsWith(str, "^")) { return true }

    return false
}

function GetCommandFromString(str) {
    foreach (cmd in CommandList) {
        if (StartsWith(str, cmd.name)) {
            return cmd
        }
    }
    return null
}

function ValidateCommand(str) {
    if (GetCommandFromString(str) != null) { return true }
    return false
}

function ValidateCommandAdminLevel(cmd, level) {
    if (cmd.level <= level) { return true }
    return false
}

function ErrorOutCommand(level, cmd = null) {
    if (cmd == null) {
        SendChatMessage(ChatCommandErrorList[0])
    } else if (level == 0) {
        SendChatMessage(cmd.notfounderror)
    } else if (level == 1) {
        SendChatMessage(cmd.permerror)
    } else if (level == 2) {
        SendChatMessage(cmd.syntaxerror)
    } else if (level == 3) {
        SendChatMessage(cmd.selectorpermerror)
    }
}

function ValidateAlowedRunners(cmd, lvl) {
    if (cmd.selectorlevel <= lvl) { return true }
    return false
}

function RunChatCommand(cmd, args, plr) {
    printl("(P2:MM): Running chat command: " + cmd.name)
    printl("(P2:MM): Player: " + plr)
    cmd.func(plr, args)
}

function GetAdminLevel(plr) {
    foreach (admin in Admins) {
        // Seperate the SteamID and the admin level
        local level = split(admin, "[]")[0]
        local SteamID = split(admin, "]")[1]

        if (SteamID == FindPlayerClass(plr).steamid.tostring()) {
            if (SteamID == GetSteamID(1).tostring()) {
                // Host always has max perms even if defined otherwise
                return 6
            } else {
                // Use defined value for others
                return level.tointeger()
            }
        }
    }

    // For people who were not defined, check if it's the host
    if (FindPlayerClass(plr).steamid.tostring() == GetSteamID(1).tostring()) {
        // It is, so we automatically give the host max perms
        Admins.push("[6]" + GetSteamID(1))
        SendChatMessage(GetPlayerName(1) + "'s Steam ID was not configured in the admins list! We added max permissions for you as server operator.")
        SendChatMessage("Verify valid options in config.nut")
        return 6
    } else {
        // Not in Admins array nor are they the host
        return 0
    }
}
///////////////////////////////////////