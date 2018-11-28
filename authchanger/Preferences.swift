//
//  preferences.swift
//  authchanger
//
//  Created by Johan McGwire on 11/28/18.
//  Copyright © 2018 Orchard & Grove. All rights reserved.
//

import Foundation

class Preferences {
    let kSystemRightConsole = "system.login.console"
    let kloginwindow_ui = "loginwindow:login"
    let kloginwindow_success = "loginwindow:success"
    let klogindindow_home = "HomeDirMechanism:status"
    let kmechanisms = "mechanisms"
    
    let version = "1.2.1"
    
    // defaults - macOS 10.13
    
    let defaultMechs = ["builtin:policy-banner", "loginwindow:login", "builtin:login-begin", "builtin:reset-password,privileged", "builtin:forward-login,privileged", "builtin:auto-login,privileged", "builtin:authenticate,privileged", "PKINITMechanism:auth,privileged", "builtin:login-success", "loginwindow:success", "loginwindow:FDESupport,privileged", "HomeDirMechanism:login,privileged", "HomeDirMechanism:status", "MCXMechanism:login", "CryptoTokenKit:login", "loginwindow:done"]
    
    // AD mechanisms
    
    let kLACheckAD = "NoMADLoginAD:CheckAD"
    let kLAEULA = "NoMADLoginAD:EULA"
    let kLAPowerControl = "NoMADLoginAD:PowerControl,privileged"
    let kLACreateUser = "NoMADLoginAD:CreateUser,privileged"
    let kLADeMobilize = "NoMADLoginAD:DeMobilize,privileged"
    let kLAEnableFDE = "NoMADLoginAD:EnableFDE,privileged"
    let kLAKeychainAdd = "NoMADLoginAD:KeychainAdd,privileged"
    let kLASierraFixes = "NoMADLoginAD:SierraFixes,privileged"
    //let kLANotify = "NoMADLoginAD:Notify"
    
    // Okta mechanisms
    
    let kLOCheckOkta = "NoMADLoginOkta:CheckOkta"
    let kLOPowerControl = "NoMADLoginOkta:PowerControl,privileged"
    let kLOCreateUser = "NoMADLoginOkta:CreateUser,privileged"
    let kLODeMobilize = "NoMADLoginOkta:DeMobilize,privileged"
    let kLOEnableFDE = "NoMADLoginOkta:EnableFDE,privileged"
    let kLOSierraFixes = "NoMADLoginOkta:SierraFixes,privileged"
    let kLOKeychainAdd = "NoMADLoginOkta:KeychainAdd,privileged"
    let kLONotify = "NoMADLoginOkta:Notify"
    
    // Azure mechanisms
    
    let kLAzCheckAzure = "NoMADLoginAzure:CheckAzure"
    let kLAzPowerControl = "NoMADLoginAzure:PowerControl,privileged"
    let kLAzCreateUser = "NoMADLoginAzure:CreateUser,privileged"
    let kLAzDeMobilize = "NoMADLoginAzure:DeMobilize,privileged"
    let kLAzEnableFDE = "NoMADLoginAzure:EnableFDE,privileged"
    let kLAzSierraFixes = "NoMADLoginAzure:SierraFixes,privileged"
    let kLAzKeychainAdd = "NoMADLoginAzure:KeychainAdd,privileged"
    let kLAzNotify = "NoMADLoginAzure:Notify"
    
    // Ping mechanisms
    
    let kLPCheckPing = "NoMADLoginPing:CheckPing"
    let kLPPowerControl = "NoMADLoginPing:PowerControl,privileged"
    let kLPCreateUser = "NoMADLoginPing:CreateUser,privileged"
    let kLPDeMobilize = "NoMADLoginPing:DeMobilize,privileged"
    let kLPEnableFDE = "NoMADLoginPing:EnableFDE,privileged"
    let kLPSierraFixes = "NoMADLoginPing:SierraFixes,privileged"
    let kLPKeychainAdd = "NoMADLoginPing:KeychainAdd,privileged"
    let kLPNotify = "NoMADLoginPing:Notify"
    
    // Setup mechanisms
    
    let kLSSetup = "NoMADLoginSetup:Setup"
    let kLSRunScript = "NoMADLoginSetup:RunScript,privileged"
    let kLSNotify = "NoMADLoginSetup:Notify"
    
    // System Preferences
    
    let kSPNetwork = "system.preferences.network"
    let kSPNetworkConfiguration = "system.services.systemconfiguration.network"
    let kSPsudoSAML = "com.jamf.connect.sudosaml"
    
    let azureRule : [ String : Any ] = [
        "version" : 1 as Int,
        "comment" : "Rule to allow for Azure authentication" as String,
        "mechanisms" : [ "NoMADLoginAzure:AuthUI" ] as [String],
        "class" : "evaluate-mechanisms" as String,
        "shared" : true as Bool,
        "tries" : 10000 as Int
    ]
    
    let defaultRule : [ String : Any ] = [
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
    
    /*let help = """
    authchanger is a utility to help you manage the authorization database used by macOS to determine how the login process progresses.
    
    version: \(Self.version)
    
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
    
    -SysPrefs       : enables Azure auhentication for the Network Preference Pane
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
    
    """*/
    
    func help(){
        var help = """
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
        
        -SysPrefs       : enables Azure auhentication for the Network Preference Pane
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
}
