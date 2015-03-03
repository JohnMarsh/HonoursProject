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
        var message : SMMessage = SMMessage(type: SMMessageType.Text, sender: SMUser.shared.profile.username)
        message.addValue(text, forKey: "text")
        return message
    }
    

    

}
