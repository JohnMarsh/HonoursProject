//
//  SMTextHandler.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-02-25.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class SMTextHandler: SMMessageHandlerProtocol {
    
    func handlerType() -> String {
        return   SMMessageType.Text.rawValue
    }
    
    func handleMessage(message: SMMessage, forDelegate delegate : SMMessageHandlerDelegate) {
        println("Handling text with value: ",message.content.objectForKey("text"))
        let text : String? = message.content.objectForKey("text") as? String
        let time : NSDate = message.timestamp
        let peer : SMPeer = SMManager.shared.publicPeerDict[message.sender] ?? SMManager.shared.privatePeerDict[message.sender]!
        let post : SMPost = SMPost(poster: peer, text: text, attachment: nil, timestamp: time)
        delegate.didReceivePost(post)
    }
    
    class func createSelfTextPost(message : SMMessage) -> SMPost{
        let text : String? = message.content.objectForKey("text") as? String
        let time : NSDate = message.timestamp
        let peer : SMPeer = SMUser.shared.peer
        let post : SMPost = SMPost(poster: peer, text: text, attachment: nil, timestamp: time)
        return post
    }
}
