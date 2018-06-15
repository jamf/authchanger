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

let version = "1.1"

// defaults - macOS 10.13

let defaultMechs = ["builtin:policy-banner", "loginwindow:login", "builtin:login-begin", "builtin:reset-password,privileged", "builtin:forward-login,privileged", "builtin:auto-login,privileged", "builtin:authenticate,privileged", "PKINITMechanism:auth,privileged", "builtin:login-success", "loginwindow:success", "loginwindow:FDESupport,privileged", "HomeDirMechanism:login,privileged", "HomeDirMechanism:status", "MCXMechanism:login", "CryptoTokenKit:login", "loginwindow:done"]

// AD mechanisms

let kLACheckAD = "NoMADLoginAD:CheckAD"
let kLAPowerControl = "NoMADLoginAD:PowerControl,privileged"
let kLACreateUser = "NoMADLoginAD:CreateUser,privileged"
let kLADeMobilize = "NoMADLoginAD:DeMobilize,privileged"
let kLAEnableFDE = "NoMADLoginAD:EnableFDE,privileged"
let kLASierraFixes = "NoMADLoginAD:SierraFixes,privileged"
let kLAKeychainAdd = "NoMADLoginAD:KeychainAdd,privileged"
let kLANotify = "NoMADLoginAD:Notify"


// Okta mechanisms

let kLOCheckOkta = "NoMADLoginOkta:CheckOkta"
let kLOPowerControl = "NoMADLoginOkta:PowerControl,privileged"
let kLOCreateUser = "NoMADLoginOkta:CreateUser,privileged"
let kLODeMobilize = "NoMADLoginOkta:DeMobilize,privileged"
let kLOEnableFDE = "NoMADLoginOkta:EnableFDE,privileged"
let kLOSierraFixes = "NoMADLoginOkta:SierraFixes,privileged"
let kLOKeychainAdd = "NoMADLoginOkta:KeychainAdd,privileged"
let kLONotify = "NoMADLoginOkta:Notify"

var rights : CFDictionary? = nil
var err = OSStatus.init(0)
var authRef : AuthorizationRef? = nil

// Arguments

var printMechs = false
var writePath = ""
var preLogin : [String]?
var preAuth : [String]?
var postAuth : [String]?
var AD = false
var Okta = false

// Index keys

var loginIndex : Int?
var authIndex : Int?

// get all of the CLI args, and parse them

let args = CommandLine.arguments

if args.contains("-AD") {
    AD = true
} else if args.contains("-Okta") {
    Okta = true
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
var mechs: Array = rightsDict[kmechanisms] as! Array<String>

// reset the settings if asked

if CommandLine.arguments.contains("-reset") {
    mechs.removeAll()
    mechs = defaultMechs
}

// find the loginwindow UI index

loginIndex = mechs.index(of: kloginwindow_ui)

if loginIndex == nil {
    // try for AD
    loginIndex = mechs.index(of: kLACheckAD)
}

if loginIndex == nil {
    loginIndex = mechs.index(of: kLOCheckOkta)
}

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
        mechs.insert(kLACreateUser, at: loginIndex! + 2)
        mechs.insert(kLADeMobilize, at: loginIndex! + 3)
        
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
        
        //mechs.insert("NoMADLogin:Notify", at: index! - 1)
        
        // add EnableFDE at the end
        
        mechs.append(kLOEnableFDE)
        mechs.append(kLOSierraFixes)
        mechs.append(kLOKeychainAdd)
    } else {
        print("Unable to get the login mechanism")
    }
}

rightsDict[kmechanisms] = mechs as AnyObject

err = AuthorizationRightSet(authRef!, kSystemRightConsole, rightsDict as CFTypeRef, "not sure why we need this" as CFString, nil, nil)

/*
 ///MARK: Factory functions
 
 func removeAndAdd(mech: String, index: Int) {
 if mechs.contains(mech) {
 // remove the mech first
 
 }
 }
 */
