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
    var attachment : NSData?
    
    
    convenience init(poster: SMPeer!, text: String?, attachment: NSData?){
        self.init()
        self.poster = poster
        self.textContent = text
        self.attachment = attachment
    }
    
    func hasAttachment() -> Bool{
        return attachment != nil
    }

}
