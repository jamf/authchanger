//
//  main.swift
//  authchanger
//
//  Created by Joel Rennich on 12/15/17.
//  Copyright © 2017 Joel Rennich. All rights reserved.
//

import Foundation
import Security.AuthorizationDB

let preferences = Preferences()
let authdb = authorizationdb()

var err = OSStatus.init(0)

// New Hotness


// print help and quit if asked
if CommandLine.arguments.contains("-h") || CommandLine.arguments.contains("-help") {
    Preferences.help(Preferences())()
    exit(0)
}

// print version and quit if asked

if CommandLine.arguments.contains("-version") {
    print(preferences.version)
    exit(0)
}

extension Array where Element: Equatable {
    @discardableResult
    mutating func appendIfNotContains(_ element: Element) -> (appended: Bool, memberAfterAppend: Element) {
        if !contains(element) {
            append(element)
            return (true, element)
        }
        return (false, element)
    }
}

func getImpactedEntries(arguments: [String]) -> [String]{
    var impactedEntries: [String] = []
    for arg in arguments[1...] {
        
        switch(arg.uppercased()){
            
        // All of these parameters edit the same entry
        case "-AZURE",
             "-AD",
             "-OKTA",
             "-SETUP",
             "-PING",
             "-DEMOBALIZE":
            for domain in preferences.AD["impactedEntries"] as! [String]{
                impactedEntries.appendIfNotContains(domain)
            }
        case "-SYSPREFS",
             "-SYSPREFSRESET" :
            for domain in preferences.SysPrefs["impactedEntries"] as! [String]{
                impactedEntries.appendIfNotContains(domain)
            }
        case "-RESET" :
            for domain in preferences.SysPrefs["impactedEntries"] as! [String]{
                impactedEntries.appendIfNotContains(domain)
            }
            for domain in preferences.AD["impactedEntries"] as! [String]{
                impactedEntries.appendIfNotContains(domain)
            }
        default:
            print() //need something better here
        }
    }
    return impactedEntries
}

func defaultMechanismAddition(editingConfiguration: Dictionary<String,CFDictionary>, mechDict: Dictionary<String, Any>) -> Dictionary<String,CFDictionary>{
    
    //TODO: Everything this function does
    
    return [:]
}

// Getting the current configuration of the machine for the preferences necessary
let currentConfiguration = authdb.getBatch(getArray: getImpactedEntries(arguments: CommandLine.arguments))

// Making a copy of the configuraiton to edit
var editingConfiguration = currentConfiguration



// Old and busted
/*

var rights : CFDictionary? = nil
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

// check for a help arg



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

// get an authorization context to save this back
// need to be root, if we are this should return clean

err = AuthorizationCreate(nil, nil, AuthorizationFlags(rawValue: 0), &authRef)

// get the current rights for system.login.console

err = AuthorizationRightGet(preferences.kSystemRightConsole, &rights)

// Now to iterate through the list and add what we need

var rightsDict = rights as! Dictionary<String,AnyObject>
mechs = rightsDict[preferences.kmechanisms] as! Array<String>

if stashPath != nil {
    
    try? String(describing: mechs).write(to: URL.init(fileURLWithPath: stashPath!), atomically: true, encoding: String.Encoding.utf8)
}

// reset the settings if asked

if CommandLine.arguments.contains("-reset") {
    mechs.removeAll()
    mechs = preferences.defaultMechs
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
        mechs[loginIndex!] = preferences.kLACheckAD
        mechs.insert(preferences.kLAPowerControl, at: loginIndex! + 1)
        mechs.insert(preferences.kLAEULA, at: loginIndex! + 2)
        mechs.insert(preferences.kLACreateUser, at: loginIndex! + 3)
        mechs.insert(preferences.kLADeMobilize, at: loginIndex! + 4)
        
        //mechs.insert("NoMADLogin:Notify", at: index! - 1)
        
        // add EnableFDE at the end
        
        mechs.append(preferences.kLAEnableFDE)
        mechs.append(preferences.kLASierraFixes)
        mechs.append(preferences.kLAKeychainAdd)
    } else {
        print("Unable to get the login mechanism")
    }
    
} else if Okta {
    
    if loginIndex != nil {
        mechs[loginIndex!] = preferences.kLOCheckOkta
        mechs.insert(preferences.kLOPowerControl, at: loginIndex! + 1)
        mechs.insert(preferences.kLOCreateUser, at: loginIndex! + 2)
        mechs.insert(preferences.kLODeMobilize, at: loginIndex! + 3)
        
        // add EnableFDE at the end
        
        mechs.append(preferences.kLOEnableFDE)
        mechs.append(preferences.kLOSierraFixes)
        mechs.append(preferences.kLOKeychainAdd)
    } else {
        print("Unable to get the login mechanism")
    }
} else if Azure {
    if loginIndex != nil {
        mechs[loginIndex!] = preferences.kLAzCheckAzure
        mechs.insert(preferences.kLAzPowerControl, at: loginIndex! + 1)
        mechs.insert(preferences.kLAzCreateUser, at: loginIndex! + 2)
        mechs.insert(preferences.kLAzDeMobilize, at: loginIndex! + 3)
        
        // add EnableFDE at the end
        
        mechs.append(preferences.kLAzEnableFDE)
        mechs.append(preferences.kLAzSierraFixes)
        mechs.append(preferences.kLAzKeychainAdd)
    } else {
        print("Unable to get the login mechanism")
    }
} else if setup {
    if loginIndex != nil {
        mechs[loginIndex!] = preferences.kLSSetup
        mechs.insert(preferences.kLSRunScript, at: loginIndex! + 1)
        mechs.insert(preferences.kLSNotify, at: loginIndex! + 2)
                
    } else {
        print("Unable to get the login mechanism")
    }
} else if Ping {
    if loginIndex != nil {
        mechs[loginIndex!] = preferences.kLPCheckPing
        mechs.insert(preferences.kLPPowerControl, at: loginIndex! + 1)
        mechs.insert(preferences.kLPCreateUser, at: loginIndex! + 2)
        mechs.insert(preferences.kLPDeMobilize, at: loginIndex! + 3)
        
        // add EnableFDE at the end
        
        mechs.append(preferences.kLPEnableFDE)
        mechs.append(preferences.kLPSierraFixes)
        mechs.append(preferences.kLPKeychainAdd)
    } else {
        print("Unable to get the login mechanism")
    }
} else if deMobilize {
    if loginIndex != nil {
        mechs.insert(preferences.kLADeMobilize, at: loginIndex! + 1)
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

rightsDict[preferences.kmechanisms] = mechs as AnyObject

    if mechChange && NSUserName() == "root" {
        err = AuthorizationRightSet(authRef!, preferences.kSystemRightConsole, rightsDict as CFTypeRef, nil, nil, nil)
    } else if mechChange && NSUserName() != "root" {
        print("Not root, unable to change mechanisms.")
    } else if !mechChange {
        print("No change to current mechansims.")
    }
}

if CommandLine.arguments.contains("-SysPrefs") {
    if NSUserName() == "root" {
        err = AuthorizationRightSet(authRef!, preferences.kSPNetworkConfiguration, preferences.SysPrefs["rule"] as CFTypeRef, nil, nil, nil)
    
        err = AuthorizationRightSet(authRef!, preferences.kSPNetwork, preferences.SysPrefs["rule"] as CFTypeRef, nil, nil, nil)
    } else {
        print("Not root, unable to make changes")
    }
}

if CommandLine.arguments.contains("-SysPrefsReset") {
    if NSUserName() == "root" {

        err = AuthorizationRightSet(authRef!, preferences.kSPNetworkConfiguration, preferences.SysPrefsReset["rule"] as CFTypeRef, nil, nil, nil)
    
        err = AuthorizationRightSet(authRef!, preferences.kSPNetwork, preferences.SysPrefsReset["rule"] as CFTypeRef, nil, nil, nil)
    } else {
        print("Not root, unable to make changes")

    }
}

if CommandLine.arguments.contains("-AddDefaultJCRight") {
    if NSUserName() == "root" {
        
        err = AuthorizationRightSet(authRef!, preferences.kSPsudoSAML, preferences.SysPrefs["rule"] as CFTypeRef, nil, nil, nil)
    } else {
        print("Not root, unable to make changes")
        
    }
}
*/
