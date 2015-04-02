//
//  SMMessageFactory.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-03-02.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation

class SMMessageFactory: NSObject {
    
    
    class func createTextMessageWithString(text : String) -> SMMessage{
        var message : SMMessage = SMMessage(type: SMMessageType.Text, sender: SMUser.shared.guid)
        message.addValue(text, forKey: "text")
        return message
    }
    
    class func createHeartBeatMessage() -> SMMessage{
        var message : SMMessage = SMMessage(type: SMMessageType.Heartbeat, sender: SMUser.shared.guid)
        return message
    }
    
    class func createTypingDidStartMessage() -> SMMessage{
        var message : SMMessage = SMMessage(type: SMMessageType.Typing, sender: SMUser.shared.guid)
        message.addValue("true", forKey: "isTyping")
        return message
    }
    
    class func createTypingDidStopMessage() -> SMMessage{
        var message : SMMessage = SMMessage(type: SMMessageType.Typing, sender: SMUser.shared.guid)
        message.addValue("false", forKey: "isTyping")
        return message
    }
    

    

}
