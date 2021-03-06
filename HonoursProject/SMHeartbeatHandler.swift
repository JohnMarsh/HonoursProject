//
//  SMHeartbeatHandler.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-02-25.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import UIKit

class SMHeartbeatHandler: SMMessageHandlerProtocol {
    
    func handlerType() -> String {
      return   SMMessageType.Heartbeat.rawValue
    }
    
    func handleMessage(message: SMMessage, forDelegate delegate : SMMessageHandlerDelegate) {
        println("Handling Heartbeat")
    }
    
}
