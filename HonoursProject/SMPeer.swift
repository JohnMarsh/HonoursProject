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


class SMPeer: NSManagedObject {
    
    var peerID : MCPeerID?
    @NSManaged var guid : NSString!
    @NSManaged var username : NSString!
    @NSManaged var blocked : NSNumber
    @NSManaged var alwaysConnect : NSNumber
    @NSManaged var profile : SMUserProfile?
    
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
    
    override func awakeFromInsert() {
        isAlwaysConnect = false
        isBlocked = false
        profile = nil
    }
   
}
