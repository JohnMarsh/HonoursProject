//
//  SMTypingHandler.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-03-12.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation


class SMTypingHandler: SMMessageHandlerProtocol {
    
    func handlerType() -> String {
        return   SMMessageType.Typing.rawValue
    }
    
    func handleMessage(message: SMMessage, forDelegate delegate : SMMessageHandlerDelegate) {
        println("Handling Typing")
        var isTyping : String =  message.content.objectForKey("isTyping") as! String
        if(isTyping == "true"){
            delegate.peerDidStartTyping!()
        }else{
            delegate.peerDidStopStyping!()
        }
    }
}