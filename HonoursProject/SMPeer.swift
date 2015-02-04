//
//  SMPeer.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-01-31.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class SMPeer: NSObject {
    
    var peerID : MCPeerID!
    
    convenience init(peerID : MCPeerID!){
        self.init()
        self.peerID = peerID;
    }
   
}
