//
//  main.swift
//  authchanger
//
//  Created by Joel Rennich on 12/15/17.
//  Copyright © 2017 Joel Rennich. All rights reserved.
//

import Foundation
import Security.AuthorizationDB

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

var rights : CFDictionary? = nil
var err = OSStatus.init(0)
var authRef : AuthorizationRef? = nil
var mechs = [String]()
var mechChange = false

// Arguments

var printMechs = false
var writePath = ""
var preLogin : [String]?
var preAuth : [String]?
var postAuth : [String]?
var AD = false
var Okta = false
var Azure = false
var Ping = false
var deMobilize = false
var setup = false
var stashPath : String?

// Index keys

var loginIndex : Int?
var authIndex : Int?

///MARK: helper functions

func getLogin() {
    // find the loginwindow UI index
    
    loginIndex = mechs.index(of: kloginwindow_ui)
    
    if loginIndex == nil {
        // try for AD
        loginIndex = mechs.index(of: kLACheckAD)
    }
    
    if loginIndex == nil {
        loginIndex = mechs.index(of: kLOCheckOkta)
    }
}

err = AuthorizationRightGet(kSPNetwork, &rights)

var tempRights = rights as! Dictionary<String,AnyObject>

print(tempRights)

// check for a help arg

if CommandLine.arguments.contains("-h") || CommandLine.arguments.contains("-help") {
    
    // print help statement
    
    let help = """
authchanger is a utility to help you manage the authorization database used by macOS to determine how the login process progresses.

version: \(version)

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
    exit(0)
}

// get all of the CLI args, and parse them

let args = CommandLine.arguments

for i in 0...(args.count - 2) {
    
    if args[i] == "-preLogin" {
        preLogin = args[i + 1].components(separatedBy: ", ")
    } else if args[i] == "-preAuth" {
        preAuth = args[i + 1].components(separatedBy: ", ")
    } else if args[i] == "-postAuth" {
        postAuth = args[i + 1].components(separatedBy: ", ")
    } else if args[i] == "-stash" {
        stashPath = args[i + 1]
    }
}

if args.contains("-AD") {
    AD = true
} else if args.contains("-Okta") {
    Okta = true
} else if args.contains("-setup") {
    setup = true
} else if args.contains("-Azure") {
    Azure = true
} else if args.contains("-Ping") {
    Ping = true
} else if args.contains("-demobilize") {
    deMobilize = true
}

// print version and quit if asked

if args.contains("-version") {
    print(version)
    exit(0)
}

// get an authorization context to save this back
// need to be root, if we are this should return clean

err = AuthorizationCreate(nil, nil, AuthorizationFlags(rawValue: 0), &authRef)

// get the current rights for system.login.console

err = AuthorizationRightGet(kSystemRightConsole, &rights)

// Now to iterate through the list and add what we need

var rightsDict = rights as! Dictionary<String,AnyObject>
mechs = rightsDict[kmechanisms] as! Array<String>

if stashPath != nil {
    
    try? String(describing: mechs).write(to: URL.init(fileURLWithPath: stashPath!), atomically: true, encoding: String.Encoding.utf8)
}

// reset the settings if asked

if CommandLine.arguments.contains("-reset") {
    mechs.removeAll()
    mechs = defaultMechs
}

getLogin()

// if asked print the mechs

if CommandLine.arguments.contains("-print") {
    for mech in mechs {
        print("\t\(mech)")
    }
}

if AD {
    if loginIndex != nil {
        mechs[loginIndex!] = kLACheckAD
        mechs.insert(kLAPowerControl, at: loginIndex! + 1)
        mechs.insert(kLAEULA, at: loginIndex! + 2)
        mechs.insert(kLACreateUser, at: loginIndex! + 3)
        mechs.insert(kLADeMobilize, at: loginIndex! + 4)
        
        //mechs.insert("NoMADLogin:Notify", at: index! - 1)
        
        // add EnableFDE at the end
        
        mechs.append(kLAEnableFDE)
        mechs.append(kLASierraFixes)
        mechs.append(kLAKeychainAdd)
    } else {
        print("Unable to get the login mechanism")
    }
    
} else if Okta {
    
    if loginIndex != nil {
        mechs[loginIndex!] = kLOCheckOkta
        mechs.insert(kLOPowerControl, at: loginIndex! + 1)
        mechs.insert(kLOCreateUser, at: loginIndex! + 2)
        mechs.insert(kLODeMobilize, at: loginIndex! + 3)
        
        // add EnableFDE at the end
        
        mechs.append(kLOEnableFDE)
        mechs.append(kLOSierraFixes)
        mechs.append(kLOKeychainAdd)
    } else {
        print("Unable to get the login mechanism")
    }
} else if Azure {
    if loginIndex != nil {
        mechs[loginIndex!] = kLAzCheckAzure
        mechs.insert(kLAzPowerControl, at: loginIndex! + 1)
        mechs.insert(kLAzCreateUser, at: loginIndex! + 2)
        mechs.insert(kLAzDeMobilize, at: loginIndex! + 3)
        
        // add EnableFDE at the end
        
        mechs.append(kLAzEnableFDE)
        mechs.append(kLAzSierraFixes)
        mechs.append(kLAzKeychainAdd)
    } else {
        print("Unable to get the login mechanism")
    }
} else if setup {
    if loginIndex != nil {
        mechs[loginIndex!] = kLSSetup
        mechs.insert(kLSRunScript, at: loginIndex! + 1)
        mechs.insert(kLSNotify, at: loginIndex! + 2)
                
    } else {
        print("Unable to get the login mechanism")
    }
} else if Ping {
    if loginIndex != nil {
        mechs[loginIndex!] = kLPCheckPing
        mechs.insert(kLPPowerControl, at: loginIndex! + 1)
        mechs.insert(kLPCreateUser, at: loginIndex! + 2)
        mechs.insert(kLPDeMobilize, at: loginIndex! + 3)
        
        // add EnableFDE at the end
        
        mechs.append(kLPEnableFDE)
        mechs.append(kLPSierraFixes)
        mechs.append(kLPKeychainAdd)
    } else {
        print("Unable to get the login mechanism")
    }
} else if deMobilize {
    if loginIndex != nil {
        mechs.insert(kLADeMobilize, at: loginIndex! + 1)
    } else {
        print("Unable to get the login mechanism")
    }
}

if preLogin != nil || preAuth != nil || postAuth != nil {
    
    var newMechs = [String]()
    
    if preLogin != nil {
        newMechs = preLogin!
    }
    
    newMechs.append(contentsOf: mechs)
    
    // get the login mech
    
    getLogin()
    
    if loginIndex != nil {
        
        if preAuth != nil {
            for i in 0...(preAuth!.count - 1) {
                newMechs.insert(preAuth![i], at: loginIndex! + ( i + 1 ))
            }
        }
        
        if postAuth != nil {
            newMechs.append(contentsOf: postAuth!)
        }
    }
    
    if newMechs != mechs {
        // swap new set in for old set
        mechs = newMechs
        mechChange = true
    }
}

if CommandLine.arguments.contains("-debug") {
    print("*** Mech List ***")
    for mech in mechs {
        print("\t\(mech)")
    }
} else {

rightsDict[kmechanisms] = mechs as AnyObject

    if mechChange && NSUserName() == "root" {
        err = AuthorizationRightSet(authRef!, kSystemRightConsole, rightsDict as CFTypeRef, nil, nil, nil)
    } else if mechChange && NSUserName() != "root" {
        print("Not root, unable to change mechanisms.")
    } else if !mechChange {
        print("No change to current mechansims.")
    }
}

if CommandLine.arguments.contains("-SysPrefs") {
    if NSUserName() == "root" {
        err = AuthorizationRightSet(authRef!, kSPNetworkConfiguration, azureRule as CFTypeRef, nil, nil, nil)
    
        err = AuthorizationRightSet(authRef!, kSPNetwork, azureRule as CFTypeRef, nil, nil, nil)
    } else {
        print("Not root, unable to make changes")
    }
}

if CommandLine.arguments.contains("-SysPrefsReset") {
    if NSUserName() == "root" {

        err = AuthorizationRightSet(authRef!, kSPNetworkConfiguration, defaultRule as CFTypeRef, nil, nil, nil)
    
        err = AuthorizationRightSet(authRef!, kSPNetwork, defaultRule as CFTypeRef, nil, nil, nil)
    } else {
        print("Not root, unable to make changes")

    }
}

if CommandLine.arguments.contains("-AddDefaultJCRight") {
    if NSUserName() == "root" {
        
        err = AuthorizationRightSet(authRef!, kSPsudoSAML, azureRule as CFTypeRef, nil, nil, nil)
    } else {
        print("Not root, unable to make changes")
        
    }
}
