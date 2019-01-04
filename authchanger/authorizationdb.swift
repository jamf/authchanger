//
//  authorizationdb.swift
//  authchanger
//
//  Created by Johan McGwire on 11/28/18.
//  Copyright © 2018 Orchard & Grove. All rights reserved.
//

import Foundation
import Security.AuthorizationDB

class authorizationdb {
    private func getAuth() -> AuthorizationRef{
        if NSUserName() != "root" {
            print("Not Running as root, please execute with sudo privilege to do this function")
            exit(1)
        }
        var authRef : AuthorizationRef? = nil
        err = AuthorizationCreate(nil, nil, AuthorizationFlags(rawValue: 0), &authRef)
        return authRef!
    }

    func getBatch(getArray: [String]) -> [String: [String: AnyObject]]{
        var returnArray: Dictionary<String,CFDictionary> = [:]
        for getEntry in getArray {
            err = AuthorizationRightGet(getEntry, &returnArray[getEntry])
        }
        return returnArray as! [String: [String: AnyObject]]
    }

    func setBatch(setArray: Dictionary<String,Dictionary<String,AnyObject>>){
        for setEntry in setArray {
            err = AuthorizationRightSet(getAuth(), setEntry.key, setEntry.value as CFTypeRef, nil, nil, nil)
        }
    }

    func removeBatch(removeArray: [String]) {
        for removeEntry in removeArray {
            err = AuthorizationRightRemove(getAuth(), removeEntry)
        }
    }
}
