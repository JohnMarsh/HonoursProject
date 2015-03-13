//
//  SMPost.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-02-09.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation

class SMPost: NSObject {
    
    var poster : SMPeer!
    var textContent : String?
    var attachmentName : String?
    var timestamp : NSDate!
    
    
    convenience init(poster: SMPeer!, text: String?, attachment: String?, timestamp : NSDate!){
        self.init()
        self.timestamp = timestamp
        self.poster = poster
        self.textContent = text
        self.attachmentName = attachment
    }
    
    func hasAttachment() -> Bool{
        return attachmentName != nil
    }

}
