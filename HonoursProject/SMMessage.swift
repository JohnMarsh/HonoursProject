//
//  SMMessage.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-01-27.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum SMMessageType : String {
    case Text = "Text"
    case Profile = "Profile"
    case Heartbeat = "Heartbeat"
    case Image = "Image"
}

class SMMessage: NSObject {
    
    var messageType : SMMessageType!
    var sender : String!
    var content : NSMutableDictionary!
    
    
    convenience init(fromJSONData data: NSData!){
        var msg : SMMessage = SMMessage()
        var error : NSError?
        let msgDic = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as NSDictionary
        
        self.init()
        
        for (key, value) in msgDic {
            let keyName = key as String
            let keyValue: String = value as String
            if (self.respondsToSelector(NSSelectorFromString(keyName))) {
                self.setValue(keyValue, forKey: keyName)
            }
        }
    }
    
    
    func messageToJSONData() -> NSData!{
        var error : NSError?
        var msg : NSMutableDictionary = NSMutableDictionary()
        msg.setObject(self.messageType.rawValue, forKey: "messageType")
        msg.setObject(self.sender, forKey: "sender")
        msg.setObject(self.content, forKey: "content")
        let data : NSData = NSJSONSerialization.dataWithJSONObject(msg, options: NSJSONWritingOptions.allZeros, error: &error)!
        return data
    }
    
    
   
}
