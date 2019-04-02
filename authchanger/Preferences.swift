//
//  preferences.swift
//  authchanger
//
//  Created by Johan McGwire on 11/28/18.
//  Copyright © 2018 Orchard & Grove. All rights reserved.
//

import Foundation

class Preferences {
    
    // New Hotness -Johan
    
    let version = "2.0.4"
    
    let AD = [
        "impactedEntries": ["system.login.console"],
        "frontMechs": ["NoMADLoginAD:CheckAD", "NoMADLoginAD:PowerControl,privileged", "NoMADLoginAD:EULA", "NoMADLoginAD:CreateUser,privileged", "NoMADLoginAD:DeMobilize,privileged"],
        "endMechs": ["NoMADLoginAD:EnableFDE,privileged", "NoMADLoginAD:SierraFixes,privileged", "NoMADLoginAD:KeychainAdd,privileged"],
        "notifyMech": ["NoMADLoginAD:Notify"]
    ]
    
    let Okta = [
        "impactedEntries": ["system.login.console"],
        "frontMechs": ["JamfConnectLogin:CheckOkta", "JamfConnectLogin:PowerControl,privileged", "JamfConnectLogin:CreateUser,privileged", "JamfConnectLogin:DeMobilize,privileged"],
        "endMechs": ["JamfConnectLogin:EnableFDE,privileged", "JamfConnectLogin:SierraFixes,privileged", "JamfConnectLogin:KeychainAdd,privileged"],
        "notifyMech": ["JamfConnectLogin:Notify"]
    ]
    
    let OIDC = [
        "impactedEntries": ["system.login.console"],
        "frontMechs": ["JamfConnectLogin:CheckAzure", "JamfConnectLogin:CheckOIDC", "JamfConnectLogin:PowerControl,privileged", "JamfConnectLogin:CreateUser,privileged", "JamfConnectLogin:DeMobilize,privileged"],
        "endMechs": ["JamfConnectLogin:EnableFDE,privileged", "JamfConnectLogin:SierraFixes,privileged", "JamfConnectLogin:KeychainAdd,privileged"],
        "notifyMech": ["JamfConnectLogin:Notify"]
    ]
    
    let Setup = [
        "impactedEntries": ["system.login.console"],
        "frontMechs": ["NoMADLoginSetup:Setup", "NoMADLoginSetup:RunScript,privileged"],
        "notifyMech": ["NoMADLoginSetup:Notify"]
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
            "mechanisms" : [ "JamfConnectLogin:CheckOIDC" ] as [String],
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
    
    let DefaultJCRight: [String: Any] = [
        "impactedEntries": ["com.jamf.connect.sudosaml"],
        "rule": [
            "version" : 1 as Int,
            "comment" : "Rule to allow for Azure authentication" as String,
            "mechanisms" : [ "JamfConnectLogin:AuthUINoCache" ] as [String],
            "class" : "evaluate-mechanisms" as String,
            "shared" : true as Bool,
            "tries" : 10000 as Int
        ]
    ]
    
    func help(){
        let help = """
        authchanger is a utility to help you manage the authorization database used by macOS to determine how the login process progresses.
        
        version: \(self.version)
        
        Note: This utilty must be run as root, all parameters are case in-sensitive
        
        Some basic options:
        
        -Version        : prints the version number
        -Help | -h      : prints this help statement
        -Reset          : resets the login screen to the factory settings
        -Okta           : sets up NoMAD Login+Okta
        -OIDC           : sets up Jamf Connect Login for Open ID Connect auth
        -AD             : sets up NoMAD LoginAD
        -Demobilize     : sets up NoMAD LoginAD to only demobilze accounts
        -Notify         : adds the DEP Notify addition to the corresponding -AD, -Okta, -OIDC or -Setup argument
        -Print          : prints the current list of authorization mechanisms
        -Debug          : does a dry run of the changes and prints out what would have happened
        
        -CustomRule ["mechanisms" | "rules"] <Mechs/Rules seperated by spaces>
                        : allows the printout of any authorizationDB rule as well as setting of that rule to any custom mechanism/s
        
        Note: The -CustomRule parameter will change the class the rule from "rule" to "evaluate-mechanism" if necessary, and vice-versa
        
        Experimental options for working with Admin authorization:
        
        -SysPrefs       : enables Azure authentication for the Network Preference Pane
        -SysPrefsReset  : removes Azure authentication for the Network Preference Pane
        
        Experimental options for working with sudo authorization:
        
        -DefaultJCRight : adds the mechanism to be used with the sudosaml binary
        
        In addition to setting basic setups, you can also specify custom rules to be put in.
        
        -preLogin       : mechs to be used before the actual UI is shown
        -preAuth        : mechs to be used between the login UI and actual authentication
        -postAuth       : mechs to be used after system authentication
        
        Usage
        
            authchanger -reset
        
                Will ensure that the authdb is reset to factory defaults for the following entries:
                    system.login.console
                    system.services.systemconfiguration.network
                    system.preferences.network
        
            authchanger -print
        
                Will display the current authdb settings for the following entries:
                    system.login.console
                    system.services.systemconfiguration.network
                    system.preferences.network
        
            authchanger -CustomRule authenticate -print
        
                Will print out the current rule for authenticate in the authorization database
        
            authchanger -CustomRule authenticate mechanisms CustomMechanism:Something AnotherCustomMechanism:Notify -debug
        
                Will overwrite the authenticate rule mechanism list with the two defined mechanisms and print out the changes it would have made
        
            authchanger -CustomRule system.login.screensaver rules authenticate-session-owner-or-admin
        
                Overwrites the system.login.screensaver rule with the defined one. This will also print out the previously set rule for reference
        
            authchanger -debug -reset -Okta -Notify -preLogin CustomMechanism:Something AnotherCustomMechanism:Notify
        
                Will reset the authdb then add NoMAD Login+Okta settings as well as the Okta notify mechanism, followed by adding the two custom
                mechanisms before the login window open. The -debug flag will show you the resulting output without actually making the change.
        
        """
        print(help)
    }
}
