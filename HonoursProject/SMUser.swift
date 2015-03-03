//
//  SMUser.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-01-12.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation
import MultipeerConnectivity



class SMUser: NSObject {
    
    let peerId : MCPeerID
    let guid : String
    var discoveryInfo : NSMutableDictionary
    var profile : SMUserProfile
    
    class var shared : SMUser {
        
        struct Static {
            static let instance : SMUser = SMUser()
        }
        
        return Static.instance
    }
    
    override init() {
        peerId = MCPeerID(displayName: UIDevice.currentDevice().name)
        guid = UIDevice.currentDevice().identifierForVendor.UUIDString
        discoveryInfo = NSMutableDictionary()
        discoveryInfo.setObject(guid, forKey: "guid")
        profile = SMUserProfile()
        profile.username = peerId.displayName
        super.init()
    }
    
    func buildProfileMessage() -> SMMessage{
        var msg = SMMessage()
        msg.messageType = SMMessageType.Profile
        msg.sender = profile.username ?? peerId.displayName
        msg.addValue(profile.username ?? peerId.displayName, forKey: "username")
        msg.addValue(profile.userDescription ?? "", forKey: "userDescription")
        return msg
    }
    

    
   
}
