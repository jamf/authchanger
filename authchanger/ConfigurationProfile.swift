//
//  ConfigurationProfile.swift
//  authchanger
//
//  Created by Joel Rennich on 2/9/19.
//  Copyright © 2019 Orchard & Grove. All rights reserved.
//

import Foundation

fileprivate let kConfigDomain = "menu.nomad.authchanger"
fileprivate let kConfigKey = "rules"
fileprivate let kConfigCommand = "command"

func getConfigurationFromProfile(delay: Int?) -> ([String]?, [String:Any]?){
    
    var configuration: [String:Any]?
    var command: [String]?
    
    let defaults = UserDefaults.init(suiteName: kConfigDomain)
    
    let now = Date()
    
    while configuration == nil && command == nil && now.timeIntervalSinceNow < delay ?? 0 {
        configuration = defaults?.object(forKey: kConfigKey) as? [String:Any]
        command = defaults?.object(forKey: kConfigCommand) as? [String]
        // run the clock
        RunLoop.current.run(mode: RunLoop.Mode.default, before: Date.distantFuture)
    }
    
    return configuration
}
