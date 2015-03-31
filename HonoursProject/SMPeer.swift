//
//  SMPeer.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-01-31.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import CoreData

@objc(SMPeer)
class SMPeer: NSManagedObject {
    
    var peerID : MCPeerID?
    @NSManaged var guid : String!
    @NSManaged var blocked : NSNumber
    @NSManaged var alwaysConnect : NSNumber
    @NSManaged var profile : SMUserProfile
    
    var isBlocked: Bool {
        get {
            return Bool(blocked)
        }
        set {
            blocked = NSNumber(bool: newValue)
        }
    }
    
    var isAlwaysConnect: Bool {
        get {
            return Bool(alwaysConnect)
        }
        set {
            alwaysConnect = NSNumber(bool: newValue)
        }
    }
    
    convenience init(peerID : MCPeerID!){
        self.init()
        self.peerID = peerID
        self.guid = peerID.displayName;
        self.isBlocked = false
        self.isAlwaysConnect = false
    }
    
    override func awakeFromInsert() {
        peerID = MCPeerID(displayName: guid)
    }
   
}
