//
//  main.swift
//  authchanger
//
//  Created by Joel Rennich on 12/15/17.
//  Copyright © 2017 Joel Rennich. All rights reserved.
//

//TODO fix AD settings

import Foundation
import Security.AuthorizationDB

let preferences = Preferences()
let authdb = authorizationdb()

var err = OSStatus.init(0)

// New Hotness

// full arguments list as single string
let argString = CommandLine.arguments.joined(separator: " ").uppercased()

// print help and quit if asked
if argString.contains("-H") || argString.contains("-HELP") {
    Preferences.help(Preferences())()
    exit(0)
}

// print version and quit if asked
if argString.contains("-VERSION") {
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
             "-DEMOBILIZE":
            for domain in preferences.AD["impactedEntries"] as! [String]{
                impactedEntries.appendIfNotContains(domain)
            }
        case "-SYSPREFS",
             "-SYSPREFSRESET" :
            for domain in preferences.SysPrefs["impactedEntries"] as! [String]{
                impactedEntries.appendIfNotContains(domain)
            }
        case "-ADDDEFAULTJCRIGHT" :
            for domain in preferences.AddDefaultJCRight["impactedEntries"] as! [String]{
                impactedEntries.appendIfNotContains(domain)
            }
        case "-RESET",
             "-PRINT":
            for domain in preferences.SysPrefs["impactedEntries"] as! [String]{
                impactedEntries.appendIfNotContains(domain)
            }
            for domain in preferences.AD["impactedEntries"] as! [String]{
                impactedEntries.appendIfNotContains(domain)
            }
        default:
            print() //need something better here - Johan
        }
    }
    return impactedEntries
}

// default mechanism addition function to avoid the code replication in the initial version

func defaultMechanismAddition(editingConfiguration: [String: [String: AnyObject]], mechDict: [String: [String]]) -> [String: [String: AnyObject]]{

    var tmpEditingConfiguration = editingConfiguration
    
    for impactedMech in (mechDict["impactedEntries"] as! [String]){
        
        var tmpEditingConfigurationMech = editingConfiguration[impactedMech]
        dump(tmpEditingConfigurationMech)
        var editingMech = tmpEditingConfigurationMech?["mechanisms"] as! [String]
        
        // adding the increment for demobilize only setting
        var increment = 1
        if((mechDict["frontMechs"] as! [String])[0].contains("DeMobilize")){ increment = 2 }
        
        // removing the loginwindow mechanism
        editingMech.remove(at: 1)
        
        // adding the front mechanisms
        var frontMechs = (mechDict["frontMechs"] as! [String]).reversed()
        for addingMech in frontMechs {
            editingMech.insert(addingMech, at: increment)
        }
        
        // appending the rear mechanisms
        for addingMech in mechDict["endMechs"] as! [String]{
            editingMech.append(addingMech)
        }
        
        // rebuilding the edited master authdb
        tmpEditingConfigurationMech?["mechanisms"] = editingMech as AnyObject
        tmpEditingConfiguration[impactedMech] = tmpEditingConfigurationMech
    }
    return tmpEditingConfiguration
}

func authorizationDBPrettyPrint(authDBConfiguration: [String: [String: AnyObject]]){
    for authDBEntryKey in authDBConfiguration.keys {
        print("Entry: " + authDBEntryKey)
        let entryProperty = authDBConfiguration[authDBEntryKey]
        
        if((authDBConfiguration[authDBEntryKey]?.keys)!.contains("mechanisms")){
            let entryMechs = entryProperty?["mechanisms"]
            print("   Mechanisms:")
            for mechName in entryMechs as! [String]{
                print("      \(mechName)")
            }
        } else {
            for EntryPropertyKey in (authDBConfiguration[authDBEntryKey]?.keys)! {
                print("   " + EntryPropertyKey + " : \(entryProperty![EntryPropertyKey]!)")
            }
        }
        print()
    }
}

// Getting the current configuration of the machine for the preferences necessary
let currentConfiguration = authdb.getBatch(getArray: getImpactedEntries(arguments: CommandLine.arguments))

// print version and quit if asked
if argString.contains("-PRINT") {
    authorizationDBPrettyPrint(authDBConfiguration: currentConfiguration)
    exit(0)
}

// Making a copy of the configuraiton to edit
var editingConfiguration = currentConfiguration as [String: [String: AnyObject]]

if argString.contains("-AD ") {
    editingConfiguration = defaultMechanismAddition(editingConfiguration: editingConfiguration, mechDict: preferences.AD)
} else if argString.contains("-AZURE") {
    editingConfiguration = defaultMechanismAddition(editingConfiguration: editingConfiguration, mechDict: preferences.Azure)
} else if argString.contains("-OKTA") {
    editingConfiguration = defaultMechanismAddition(editingConfiguration: editingConfiguration, mechDict: preferences.Okta)
} else if argString.contains("-SETUP") {
    editingConfiguration = defaultMechanismAddition(editingConfiguration: editingConfiguration, mechDict: preferences.Setup)
} else if argString.contains("-PING") {
    editingConfiguration = defaultMechanismAddition(editingConfiguration: editingConfiguration, mechDict: preferences.Ping)
} else if argString.contains("-DEMOBILIZE") {
    editingConfiguration = defaultMechanismAddition(editingConfiguration: editingConfiguration, mechDict: preferences.Demobilze)
}

if argString.contains("-RESET") {
    var tmpEditingConfigurationMech = editingConfiguration[((preferences.Reset)["impactedEntries"] as! [String])[0]]
    tmpEditingConfigurationMech?["mechanisms"] = (preferences.Reset)["defaultMechs"] as AnyObject
    editingConfiguration[((preferences.Reset)["impactedEntries"] as! [String])[0]] = tmpEditingConfigurationMech
}

// There is some more code minimization that can be done below

if argString.contains("-SYSPREFS") {
    for impactedEntry in (preferences.SysPrefs)["impactedEntries"] as! [String]{
        editingConfiguration[impactedEntry] = (preferences.SysPrefs)["rule"] as! [String : AnyObject]
    }
}

if argString.contains("-SYSPREFSRESET") {
    for impactedEntry in (preferences.SysPrefsReset)["impactedEntries"] as! [String]{
        editingConfiguration[impactedEntry] = (preferences.SysPrefsReset)["rule"] as! [String : AnyObject]
    }
}

if argString.contains("-ADDDEFAULTJCRIGHT") {
    for impactedEntry in (preferences.AddDefaultJCRight)["impactedEntries"] as! [String]{
        editingConfiguration[impactedEntry] = (preferences.AddDefaultJCRight)["rule"] as! [String : AnyObject]
    }
}


if argString.contains("-DEBUG") {
    authorizationDBPrettyPrint(authDBConfiguration: editingConfiguration)
    exit(0)
}




// Old and busted
/*

var preLogin : [String]?
var preAuth : [String]?
var postAuth : [String]?

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
 if deMobilize {
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

 if {}
else {

rightsDict[preferences.kmechanisms] = mechs as AnyObject

    if mechChange && NSUserName() == "root" {
        err = AuthorizationRightSet(authRef!, preferences.kSystemRightConsole, rightsDict as CFTypeRef, nil, nil, nil)
    } else if mechChange && NSUserName() != "root" {
        print("Not root, unable to change mechanisms.")
    } else if !mechChange {
        print("No change to current mechansims.")
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
