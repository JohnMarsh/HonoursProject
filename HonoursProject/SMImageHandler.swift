//
//  SMImageHandler.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-02-25.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import UIKit

class SMImageHandler {
    
    func handlerType() -> String {
        return   SMMessageType.Image.rawValue
    }
    
    class func handleImageAndReturnPost(peer : SMPeer, timestamp : NSDate, url : NSURL, completionHandler: (SMPost!)->Void) {
        SMResourceManager.saveResourceFromTempUrl(url, fromPeer: peer, atTime: timestamp){ (name) ->Void in
            let post : SMPost = SMPersistenceManager.createNewPost()
            post.timestamp = timestamp
            post.poster = peer
            post.attachmentName = name
            completionHandler(post)
        }
    }
    
    class func createSelfImagePost(timestamp : NSDate,url : NSURL, completionHandler: (SMPost!)->Void) {
            let post : SMPost = SMPersistenceManager.createNewPost()
            post.timestamp = timestamp
            post.poster = SMUser.shared.peer
            post.attachmentName = url.absoluteString
            completionHandler(post)
    }
}
