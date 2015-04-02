//
//  SMProfileHandler.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-02-25.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import UIKit

class SMProfileHandler: SMMessageHandlerProtocol {
    
    func handlerType() -> String {
        return   SMMessageType.Profile.rawValue
    }
    
    func handleMessage(message: SMMessage, forDelegate delegate : SMMessageHandlerDelegate) {
        let peer : SMPeer = SMManager.shared.publicPeerDict[message.sender] ?? SMManager.shared.privatePeerDict[message.sender]!
        peer.profile?.username =  message.content.objectForKey("username") as String
       //delegate.didReceiveProfile!()
    }
}
