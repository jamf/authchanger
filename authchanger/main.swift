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

// New Hotness - Johan

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
             "-DEMOBILIZE",
             "-PRELOGIN",
             "-PREAUTH",
             "-POSTAUTH":
            for domain in preferences.AD["impactedEntries"] as! [String]{
                impactedEntries.appendIfNotContains(domain)
            }
        case "-SYSPREFS",
             "-SYSPREFSRESET" :
            for domain in preferences.SysPrefs["impactedEntries"] as! [String]{
                impactedEntries.appendIfNotContains(domain)
            }
        case "-DEFAULTJCRIGHT" :
            for domain in preferences.DefaultJCRight["impactedEntries"] as! [String]{
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
        case "-CUSTOMRULE":
            let argArrayCap = (CommandLine.arguments).map{$0.uppercased()}
            let argIndex = argArrayCap.firstIndex(of: "-CUSTOMRULE")
            impactedEntries.appendIfNotContains((CommandLine.arguments)[argIndex! + 1])
        default:
            break
        }
    }
    return impactedEntries
}

// default mechanism addition function to avoid the code replication in the initial version

func defaultMechanismAddition(editingConfiguration: [String: [String: AnyObject]], mechDict: [String: [String]], notify: Bool = false) -> [String: [String: AnyObject]]{

    var tmpEditingConfiguration = editingConfiguration
    
    for impactedMech in (mechDict["impactedEntries"] as! [String]){
        
        var tmpEditingConfigurationMech = editingConfiguration[impactedMech]
        var editingMech = tmpEditingConfigurationMech?["mechanisms"] as! [String]
        
        // adding the increment for demobilize only setting
        var increment = 1
        if((mechDict["frontMechs"] as! [String])[0].contains("DeMobilize")){
            increment = 2
        } else {
            // removing the loginwindow mechanism if not only demobilize
            editingMech.remove(at: 1)
        }
        
        // adding the front mechanisms
        var frontMechs = (mechDict["frontMechs"] as! [String]).reversed()
        for addingMech in frontMechs {
            editingMech.insert(addingMech, at: increment)
        }
        
        // adding the notify mechanism if specified
        if notify {
            let additionIndex = editingMech.firstIndex(of: "builtin:login-begin") as! Int
            for addingMech in (mechDict["notifyMech"] as! [String]).reversed() {
                editingMech.insert(addingMech, at: additionIndex)
            }
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
        
        for EntryPropertyKey in (authDBConfiguration[authDBEntryKey]?.keys)! {
            
            if EntryPropertyKey == "mechanisms" {
                let entryMechs = entryProperty?[EntryPropertyKey]
                print("   mechanisms:")
                for mechName in entryMechs as! [String]{
                    print("      \(mechName)")
                }
            } else {
                print("   " + EntryPropertyKey + " : \(entryProperty![EntryPropertyKey]!)")
            }
        }
        print()
    }
}

// Getting the current configuration of the machine for the preferences necessary
let currentConfiguration = authdb.getBatch(getArray: getImpactedEntries(arguments: CommandLine.arguments))

// Making a copy of the configuraiton to edit
var editingConfiguration = currentConfiguration as [String: [String: AnyObject]]

if argString.contains("-RESET") {
    var tmpEditingConfigurationMech = editingConfiguration[((preferences.Reset)["impactedEntries"] as! [String])[0]]
    tmpEditingConfigurationMech?["mechanisms"] = (preferences.Reset)["defaultMechs"] as AnyObject
    editingConfiguration[((preferences.Reset)["impactedEntries"] as! [String])[0]] = tmpEditingConfigurationMech
}

var notifyMechAdd: Bool = false
if argString.contains("-NOTIFY"){
    notifyMechAdd = true
}

if argString.contains("-AD") {
    editingConfiguration = defaultMechanismAddition(editingConfiguration: editingConfiguration, mechDict: preferences.AD, notify: notifyMechAdd)
} else if argString.contains("-AZURE") {
    editingConfiguration = defaultMechanismAddition(editingConfiguration: editingConfiguration, mechDict: preferences.Azure, notify: notifyMechAdd)
} else if argString.contains("-OKTA") {
    editingConfiguration = defaultMechanismAddition(editingConfiguration: editingConfiguration, mechDict: preferences.Okta, notify: notifyMechAdd)
} else if argString.contains("-SETUP") {
    editingConfiguration = defaultMechanismAddition(editingConfiguration: editingConfiguration, mechDict: preferences.Setup, notify: notifyMechAdd)
} else if argString.contains("-PING") {
    editingConfiguration = defaultMechanismAddition(editingConfiguration: editingConfiguration, mechDict: preferences.Ping)
} else if argString.contains("-DEMOBILIZE") {
    editingConfiguration = defaultMechanismAddition(editingConfiguration: editingConfiguration, mechDict: preferences.Demobilze)
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

if argString.contains("-DEFAULTJCRIGHT") {
    for impactedEntry in (preferences.DefaultJCRight)["impactedEntries"] as! [String]{
        editingConfiguration[impactedEntry] = (preferences.DefaultJCRight)["rule"] as! [String : AnyObject]
    }
}

// getting all mechanisms from the parameters given in
// this code is dirty..... -Johan
var preLoginMechs:[String] = [], preAuthMechs:[String] = [], postAuthMechs:[String] = [], customRuleMechs:[String] = []
if argString.contains("-PRELOGIN") || argString.contains("-PREAUTH") || argString.contains("-POSTAUTH") || argString.contains("-CUSTOMRULE"){
    let argArrayCap = (CommandLine.arguments).map{$0.uppercased()}
    var i = 1
    while i < argArrayCap.count {
        if argArrayCap[i] == "-PRELOGIN" {
            i += 1
            if i >= argArrayCap.count{break}
            while !(argArrayCap[i]).hasPrefix("-"){
                preLoginMechs.append((CommandLine.arguments)[i])
                i += 1
                if i >= argArrayCap.count{break}
            }
            i -= 1
        }
        if argArrayCap[i] == "-PREAUTH" {
            i += 1
            if i >= argArrayCap.count{break}
            while !(argArrayCap[i]).hasPrefix("-"){
                preAuthMechs.append((CommandLine.arguments)[i])
                i += 1
                if i >= argArrayCap.count{break}
            }
            i -= 1
        }
        if argArrayCap[i] == "-POSTAUTH" {
            i += 1
            if i >= argArrayCap.count{break}
            while !(argArrayCap[i]).hasPrefix("-"){
                postAuthMechs.append((CommandLine.arguments)[i])
                i += 1
                if i >= argArrayCap.count{break}
            }
            i -= 1
        }
        if argArrayCap[i] == "-CUSTOMRULE" {
            i += 1
            if i >= argArrayCap.count{break}
            while !(argArrayCap[i]).hasPrefix("-"){
                customRuleMechs.append((CommandLine.arguments)[i])
                i += 1
                if i >= argArrayCap.count{break}
            }
            i -= 1
        }
        i += 1
    }
}

// reversing the pre and post mech lists for addition
preLoginMechs.reverse()
preAuthMechs.reverse()
postAuthMechs.reverse()


if argString.contains("-PRELOGIN") {
    var tmpEditingConfigurationMech = editingConfiguration["system.login.console"]
    var editingMech = tmpEditingConfigurationMech?["mechanisms"] as! [String]
    for mech in preLoginMechs {
        editingMech.insert(mech, at: 1)
    }
    tmpEditingConfigurationMech?["mechanisms"] = editingMech as AnyObject
    editingConfiguration["system.login.console"] = tmpEditingConfigurationMech
}

if argString.contains("-PREAUTH") {
    var tmpEditingConfigurationMech = editingConfiguration["system.login.console"]
    var editingMech = tmpEditingConfigurationMech?["mechanisms"] as! [String]
    let additionIndex = editingMech.firstIndex(of: "builtin:login-begin") as! Int
    for mech in preAuthMechs {
        editingMech.insert(mech, at: additionIndex)
    }
    tmpEditingConfigurationMech?["mechanisms"] = editingMech as AnyObject
    editingConfiguration["system.login.console"] = tmpEditingConfigurationMech
}

if argString.contains("-POSTAUTH") {
    var tmpEditingConfigurationMech = editingConfiguration["system.login.console"]
    var editingMech = tmpEditingConfigurationMech?["mechanisms"] as! [String]
    for mech in postAuthMechs {
        editingMech.append(mech)
    }
    tmpEditingConfigurationMech?["mechanisms"] = editingMech as AnyObject
    editingConfiguration["system.login.console"] = tmpEditingConfigurationMech
}

if argString.contains("-CUSTOMRULE") {
    
    let customRuleName = customRuleMechs.remove(at: 0)
    var tmpEditingConfigurationMech = editingConfiguration[customRuleName]
    
    if argString.contains("-PRINT"){
        authorizationDBPrettyPrint(authDBConfiguration: [customRuleName: (currentConfiguration[customRuleName] ?? nil)!])
        exit(0)
    } else if !argString.contains("-DEBUG"){
        print("Previous Rule for reference:\n")
        authorizationDBPrettyPrint(authDBConfiguration: currentConfiguration)
    }
    if (tmpEditingConfigurationMech?["class"] as! String) != "evaluate-mechanisms" {
        print("WARNING: This rule is not set to evaluate mechanisms")
    }
    tmpEditingConfigurationMech?["mechanisms"] = customRuleMechs as AnyObject
    editingConfiguration[customRuleName] = tmpEditingConfigurationMech
}


// print version and quit if asked
if argString.contains("-PRINT") {
    authorizationDBPrettyPrint(authDBConfiguration: currentConfiguration)
    exit(0)
}

if argString.contains("-DEBUG") {
    authorizationDBPrettyPrint(authDBConfiguration: editingConfiguration)
    exit(0)
} else {
    // writing everything back
    authdb.setBatch(setArray: editingConfiguration)
}
