//
//  SMResourceManager.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-03-12.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation

class SMResourceManager {
    
    class func saveResourceFromTempUrl(url : NSURL, fromPeer peer : SMPeer, atTime timestamp:NSDate, completionHandler: (String!)->Void!){
        ~{
            var fullFileName : String
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            let fileName = "\(peer.guid)+\(timestamp.timeIntervalSince1970)"
            fullFileName  = documentsPath.stringByAppendingPathComponent(fileName)
            let data : NSData = NSData(contentsOfURL: url)!
            data.writeToFile(fullFileName, atomically: true)
            completionHandler(fullFileName)
        }
    }
    
    class func getImageForPost(post : SMPost) -> UIImage{
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let fileName = "\(post.poster.guid)+\(post.timestamp.timeIntervalSince1970)"
        println("getting file with filename \(fileName)")
        let fullFileName : String = documentsPath.stringByAppendingPathComponent(fileName)
        let data : NSData = NSData(contentsOfFile: fullFileName)!
        let image : UIImage = UIImage(data: data)!
        return image
    }
    
    class func tempSaveImageForSending(image : UIImage, completionHandler: ((NSURL!) -> Void)!){
        ~{
            SMResourceManager.deleteTempPicture()
            var newUrl : NSURL
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            let fileName = "temp.jpeg"
            let fullFileName  = documentsPath.stringByAppendingPathComponent(fileName)
            let data : NSData = UIImageJPEGRepresentation(image, 1.0)
            data.writeToFile(fullFileName, atomically: true)
            newUrl = NSURL(fileURLWithPath: fullFileName)!
            completionHandler(newUrl)
        }
    }
    
    class func deleteTempPicture(){
        ~{
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            let fileName = "temp.jpeg"
            let fullFileName  = documentsPath.stringByAppendingPathComponent(fileName)
            var error : NSErrorPointer = NSErrorPointer()
            NSFileManager.defaultManager().removeItemAtPath(fullFileName, error: error)
            if(error != nil){
                println("Failed to delete image with error: \(error.debugDescription)")
            }
        }
    }
    
}