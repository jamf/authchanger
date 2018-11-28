//
//  preferences.swift
//  authchanger
//
//  Created by Johan McGwire on 11/28/18.
//  Copyright © 2018 Orchard & Grove. All rights reserved.
//

import Foundation

class Preferences {
    
    // New Hotness
    
    let Azure = [
        "impactedEntries": ["system.login.console"],
        "frontMechs": ["NoMADLoginAzure:CheckAzure", "NoMADLoginAzure:PowerControl,privileged", "NoMADLoginAzure:CreateUser,privileged", "NoMADLoginAD:DeMobilize,privileged" ],
        "endMechs": ["NoMADLoginAzure:EnableFDE,privileged", "NoMADLoginAzure:SierraFixes,privileged", "NoMADLoginAzure:KeychainAdd,privileged"]
    ]
    
    let AD = [
        "impactedEntries": ["system.login.console"],
        "frontMechs": ["NoMADLoginAD:CheckAD", "NoMADLoginAD:PowerControl,privileged", "NoMADLoginAD:EULA", "NoMADLoginAD:CreateUser,privileged", "NoMADLoginAzure:DeMobilize,privileged"],
        "endMechs": ["NoMADLoginAD:EnableFDE,privileged", "NoMADLoginAD:SierraFixes,privileged", "NoMADLoginAD:KeychainAdd,privileged"]
    ]
    
    let Okta = [
        "impactedEntries": ["system.login.console"],
        "frontMechs": ["NoMADLoginOkta:CheckOkta", "NoMADLoginOkta:PowerControl,privileged", "NoMADLoginOkta:CreateUser,privileged", "NoMADLoginOkta:DeMobilize,privileged"],
        "endMechs": ["NoMADLoginOkta:EnableFDE,privileged", "NoMADLoginOkta:SierraFixes,privileged", "NoMADLoginOkta:KeychainAdd,privileged"]
    ]
    
    let Setup = [
        "impactedEntries": ["system.login.console"],
        "frontMechs": ["NoMADLoginSetup:Setup", "NoMADLoginSetup:RunScript,privileged"]
    ]
    
    let Ping = [
        "impactedEntries": ["system.login.console"],
        "frontMechs": ["NoMADLoginPing:CheckPing", "NoMADLoginPing:PowerControl,privileged", "NoMADLoginPing:CreateUser,privileged", "NoMADLoginPing:DeMobilize,privileged"],
        "endMechs": ["NoMADLoginPing:EnableFDE,privileged", "NoMADLoginPing:SierraFixes,privileged", "NoMADLoginPing:KeychainAdd,privileged"]
    ]
    
    let Demobilze = [
        "impactedEntries": ["system.login.console"],
        "frontMechs": ["NoMADLoginAD:DeMobilize,privileged"],
        "endMechs": []
    ]
    
    let SysPrefs: [String : Any] = [
        "impactedEntries": ["system.services.systemconfiguration.network", "system.preferences.network"],
        "rule": [
            "version" : 1 as Int,
            "comment" : "Rule to allow for Azure authentication" as String,
            "mechanisms" : [ "NoMADLoginAzure:AuthUI" ] as [String],
            "class" : "evaluate-mechanisms" as String,
            "shared" : true as Bool,
            "tries" : 10000 as Int
        ]
    ]
    
    let SysPrefsReset: [String : Any] = [
        "impactedEntries": ["system.services.systemconfiguration.network", "system.preferences.network"],
        "rule": [
            "group": "admin",
            "timeout": 2147483647,
            "version": 0,
            "tries": 10000,
            "comment": "Checked by the Admin framework when making changes to the Network preference pane.",
            "modified": 555548986.9298199,
            "class": "user",
            "session-owner": 0,
            "authenticate-user": 1,
            "created": 555548986.9298199,
            "shared": 1,
            "allow-root": 1
        ]
    ]
    
    let Reset: [String: Any] = [
        "impactedEntries": ["system.login.console"],
        "defaultMechs" : ["builtin:policy-banner", "loginwindow:login", "builtin:login-begin", "builtin:reset-password,privileged", "builtin:forward-login,privileged", "builtin:auto-login,privileged", "builtin:authenticate,privileged", "PKINITMechanism:auth,privileged", "builtin:login-success", "loginwindow:success", "loginwindow:FDESupport,privileged", "HomeDirMechanism:login,privileged", "HomeDirMechanism:status", "MCXMechanism:login", "CryptoTokenKit:login", "loginwindow:done"]
    ]
    
    let AddDefaultJCRight: [String: Any] = [
        "impactedEntries": ["com.jamf.connect.sudosaml"],
        "rule": [
            "version" : 1 as Int,
            "comment" : "Rule to allow for Azure authentication" as String,
            "mechanisms" : [ "NoMADLoginAzure:AuthUI" ] as [String],
            "class" : "evaluate-mechanisms" as String,
            "shared" : true as Bool,
            "tries" : 10000 as Int
        ]
    ]
    
    func help(){
        let help = """
        authchanger is a utility to help you manage the authorization database used by macOS to determine how the login process progresses.
        
        version: \(self.version)
        
        Note: This utilty must be run as root.
        
        Some basic options:
        
        -version        : prints the version number
        -help | -h      : prints this help statement
        -reset          : resets the auth database to the factory settings
        -Okta           : sets up NoMAD Login+Okta
        -AD             : sets up NoMAD LoginAD
        -Azure          : sets up NoMAD Login Azure
        -demobilize     : sets up NoMAD LoginAD to only demobilze accounts
        -print          : prints the current list of authorization mechanisms
        -debug          : does a dry run of the changes and prints out what would have happened
        
        Experimental options for working with Admin authorization:
        
        -SysPrefs       : enables Azure authentication for the Network Preference Pane
        -SysPrefsReset  : removes Azure authentication for the Network Preference Pane
        
        In addition to setting basic setups, you can also specify custom rules to be put in.
        
        -preLogin       : mechs to be used before the actual UI is shown
        -preAuth        : mechs to be used between the login UI and actual authentication
        -postAuth       : mechs to be used after system authentication
        
        Useage
        
        authchanger -reset -AD
        
        Will ensure that the authdb is reset to factory defaults and then enable NoMAD LoginAD.
        
        authchanger -print
        
        Will display the current authdb settings.
        
        authchanger -debug -reset -Okta -preLogin "NoMADLoginOkta:RunScript,privileged, NoMADLoginOkta:Notify"
        
        Will reset the authdb then add NoMAD Login+Okta settings and and the RunScript and Notify mechanisms before the NoMAD Login+Okta UI is shown. The -debug flag will show you the resulting output without actually making the change.
        
        """
        print(help)
    }
    
    // Old and Busted
    
    let kSystemRightConsole = "system.login.console"
    let kloginwindow_ui = "loginwindow:login"
    let kloginwindow_success = "loginwindow:success"
    let klogindindow_home = "HomeDirMechanism:status"
    let kmechanisms = "mechanisms"
    
    let version = "1.2.1"
    
    // Notify mechanisms
    
    let kLANotify = "NoMADLoginAD:Notify"
    let kLAzNotify = "NoMADLoginAzure:Notify"
    let kLONotify = "NoMADLoginOkta:Notify"
    let kLSNotify = "NoMADLoginSetup:Notify"
    
}
