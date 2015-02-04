//
//  SMUser.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-01-12.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation
import MultipeerConnectivity

private let _instance = SMUser()

class SMUser: NSObject {
    
    let peerId : MCPeerID
    let guid : String
    var discoveryInfo : NSMutableDictionary
    
    class func sharedInstance() -> SMUser{
        return _instance
    }
    
    override init() {
        peerId = MCPeerID(displayName: UIDevice.currentDevice().name)
        guid = UIDevice.currentDevice().identifierForVendor.UUIDString
        discoveryInfo = NSMutableDictionary()
        discoveryInfo.setObject(guid, forKey: "guid")
        super.init()
    }
    
   
}
