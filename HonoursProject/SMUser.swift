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


class SMUser: NSManagedObject {
    
   @NSManaged var peerId : MCPeerID?
   @NSManaged var peer : SMPeer
   @NSManaged var guid : String
    
    class var shared : SMUser {
        
        struct Static {
            static let instance : SMUser = SMPersistenceManager.createNewUser()
        }
        
        return Static.instance
    }
    
    
    override func awakeFromInsert() {
        guid = UIDevice.currentDevice().identifierForVendor.UUIDString
        peerId = MCPeerID(displayName: guid)
        peer = SMPersistenceManager.createNewPeer(peerId!)
        peer.profile = SMPersistenceManager.createNewProfile()
    }
    
    override func awakeFromFetch() {
        peerId = MCPeerID(displayName: guid)
        println("fecthing user with peer \(peer.guid)")
    }
    
    
    func buildProfileMessage() -> SMMessage{
        var msg = SMMessage()
        
        msg.messageType = SMMessageType.Profile
        msg.sender = peerId!.displayName
        msg.addValue(peer.profile!.username ?? UIDevice.currentDevice().name, forKey: "username")
        msg.addValue(peer.profile!.userDescription ?? "", forKey: "userDescription")
        return msg
    }
    

    
   
}
