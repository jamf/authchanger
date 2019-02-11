//
//  ConfigurationProfile.swift
//  authchanger
//
//  Created by Joel Rennich on 2/9/19.
//  Copyright © 2019 Orchard & Grove. All rights reserved.
//

import Foundation

fileprivate let kConfigDomain = "menu.nomad.authchanger"
fileprivate let kConfigKey = "mechanisms"
fileprivate let kConfigCommand = "command"

func getConfigurationFromProfile(delay: Int?) -> [String]? {
    
    var configuration: [String:[String:AnyObject]]?
    var command: [String]?
    
    let defaults = UserDefaults.init(suiteName: kConfigDomain)
    
    let now = Date()
    
    var forever = false
    
    if delay ?? 0 < 0 {
        forever = true
    }

    while configuration == nil && command == nil && ( Int(now.timeIntervalSinceNow) > ((delay ?? 1) * -1 ) || forever ) {
        
        configuration = defaults?.object(forKey: kConfigKey) as? [String:[String:AnyObject]]
        command = defaults?.object(forKey: kConfigCommand) as? [String]
        
        // run the clock
        RunLoop.current.run(until: now.addingTimeInterval(1))
    }
    
    if configuration != nil {
        let authdb = authorizationdb.init()
        authdb.setBatch(setArray: configuration!)
        
        exit(0)
    }
    
    if command != nil {
        // need to add a first entry to replicate the original args
        return ["authchanger"] + command!
    }
    
    // if we got here 
    return nil
}
