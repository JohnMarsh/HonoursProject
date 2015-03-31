//
//  SMUser.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-01-12.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import CoreData

@objc(SMUser)
class SMUser: NSObject {
    
    var peerId : MCPeerID
    let peer : SMPeer
   @NSManaged var guid : String
    var discoveryInfo : NSMutableDictionary
   @NSManaged var profile : SMUserProfile
    
    class var shared : SMUser {
        
        struct Static {
            static let instance : SMUser = SMUser()
        }
        
        return Static.instance
    }
    
    override init() {
        peerId = MCPeerID(displayName: UIDevice.currentDevice().identifierForVendor.UUIDString)
        peer = SMPeer(peerID: peerId)
        discoveryInfo = NSMutableDictionary()
        super.init()
        guid = UIDevice.currentDevice().identifierForVendor.UUIDString
        profile = SMUserProfile()
        peer.profile = profile
    }
    
    func buildProfileMessage() -> SMMessage{
        var msg = SMMessage()
        msg.messageType = SMMessageType.Profile
        msg.sender = peerId.displayName
        msg.addValue(profile.username ?? UIDevice.currentDevice().name, forKey: "username")
        msg.addValue(profile.userDescription ?? "", forKey: "userDescription")
        return msg
    }
    

    
   
}
