//
//  SMMessage.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-01-27.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class SMMessage: NSObject {
    
    var messageType : SMMessageType!
    var sender : String!
    var content : NSMutableDictionary!
    var timestamp : NSDate
    
    override init(){
        content = NSMutableDictionary()
        timestamp = NSDate()
        super.init()
    }
    
    convenience init(type : SMMessageType, sender : String){
        self.init()
        self.messageType = type
        self.sender = sender
    }
    
    
    convenience init(fromJSONData data: NSData!){
        var msg : SMMessage = SMMessage()
        var error : NSError?
        let msgDic = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as! NSDictionary
        
        self.init()
        
        self.messageType = SMMessageType(rawValue:msgDic.objectForKey("messageType") as! String)
        self.sender = msgDic.objectForKey("sender")as! String
        self.timestamp = NSDate(timeIntervalSince1970: msgDic.objectForKey("timestamp")as! Double)
        self.content = msgDic.objectForKey("content") as! NSMutableDictionary
    }
    
    func addValue(value : String, forKey key: String){
        content.setObject(value, forKey: key)
    }
    
    
    func messageToJSONData() -> NSData!{
        var error : NSError?
        var msg : NSMutableDictionary = NSMutableDictionary()
        msg.setObject(self.messageType.rawValue, forKey: "messageType")
        msg.setObject(self.sender, forKey: "sender")
        msg.setObject(timestamp.timeIntervalSince1970, forKey: "timestamp")
        msg.setObject(self.content, forKey: "content")
        let data : NSData = NSJSONSerialization.dataWithJSONObject(msg, options: NSJSONWritingOptions.allZeros, error: &error)!
        return data
    }
    
    
   
}
