//
//  SMPrivateSession.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-01-12.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import CoreData

@objc protocol SMPrivateSessionDelagate{
    func receivedNewPost(post : SMPost)
    func peerHasConnected()
    func peerHasDisconnected()
    func peerDidStartTyping()
    func peerDidStopTyping()
}

class SMPrivateSession: NSManagedObject, MCSessionDelegate, SMMessageHandlerDelegate {
    
   @NSManaged var session : MCSession?
   @NSManaged  var connectedPeer : SMPeer?
   @NSManaged var posts : NSMutableOrderedSet
    var timer : NSTimer?
   @NSManaged var active : NSNumber
    var delegate : SMPrivateSessionDelagate?
    
    var isActive: Bool {
        get {
            return Bool(active)
        }
        set {
            active = NSNumber(bool: newValue)
        }
    }
    
    
    override func awakeFromInsert() {
        session = MCSession(peer: SMUser.shared.peerId)
        session!.delegate = self
        posts = NSMutableOrderedSet()
        isActive = false
    }
    
    override func awakeFromFetch() {
        session = MCSession(peer: SMUser.shared.peerId)
        session!.delegate = self
    }
   
   
    //MARK: SMPrivateSession Methods
    
    func sendTextToPeer(text : String){
        var error : NSErrorPointer = NSErrorPointer()
        let message : SMMessage = SMMessageFactory.createTextMessageWithString(text)
        let post = SMTextHandler.createSelfTextPost(message)
        post.session = self
        posts.addObject(post)
        SMPersistenceManager.saveContext()
        session!.sendData(message.messageToJSONData(), toPeers: session!.connectedPeers, withMode:  MCSessionSendDataMode.Reliable, error: error)
    }
    
    func sendResourceAtUrl(url : NSURL, completionHandler: ()->Void!){
        session!.sendResourceAtURL(url, withName: url.absoluteString, toPeer: session!.connectedPeers[0] as! MCPeerID, withCompletionHandler:  {(error : NSError!) -> Void in
            if(error != nil){
                println("Resource failed to send with error: \(error).")
                
            }else{
                println("Resource sent with no errors.")
                SMResourceManager.deleteTempPicture()
            }
            completionHandler()
        })
    }

    func sendImageToPeer(image : UIImage){
        ~{
            var newUrl : NSURL
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
            let date = NSDate()
            let fileName = "\(SMUser.shared.guid)+\(date.timeIntervalSince1970)"
            let fullFileName  = documentsPath.stringByAppendingPathComponent(fileName)
            println("saving and sending file with filename \(fileName)")
            let data : NSData = UIImageJPEGRepresentation(image, 1.0)
            data.writeToFile(fullFileName, atomically: true)
            newUrl = NSURL(fileURLWithPath: fullFileName)!
            self.sendResourceAtUrl(newUrl){
                SMImageHandler.createSelfImagePost(date, url: newUrl){  (post)->Void in
                    self.posts.addObject(post)
                    self.delegate?.receivedNewPost(post)
                    post.session = self
                    SMPersistenceManager.saveContext()
                }
            }
        }
        
    }
    
    func sendHeartbeat(){
        var error : NSErrorPointer = NSErrorPointer()
        session!.sendData(SMMessageFactory.createHeartBeatMessage().messageToJSONData(), toPeers: session!.connectedPeers, withMode:  MCSessionSendDataMode.Reliable, error: error)
    }
    
    func userDidStartTyping(){
        var error : NSErrorPointer = NSErrorPointer()
        session!.sendData(SMMessageFactory.createTypingDidStartMessage().messageToJSONData(), toPeers: session!.connectedPeers, withMode:  MCSessionSendDataMode.Reliable, error: error)
    }
    
    func userDidStopTyping(){
        var error : NSErrorPointer = NSErrorPointer()
        session!.sendData(SMMessageFactory.createTypingDidStopMessage().messageToJSONData(), toPeers: session!.connectedPeers, withMode:  MCSessionSendDataMode.Reliable, error: error)
    }
    
    //MARK: SMMessageHandlerDelegate
    
    func didReceivePost(post: SMPost) {
        posts.addObject(post);
        delegate?.receivedNewPost(post)
        post.session = self
        SMPersistenceManager.saveContext()
    }
    
    func didReceiveHeartbeat() {
        //isActive = true
    }
    
    func peerDidStartTyping() {
        delegate?.peerDidStartTyping()
    }
    
    func peerDidStopStyping() {
        delegate?.peerDidStopTyping()
    }
    
    //MARK: MCSessionDelegate Methods
    
    // Remote peer changed state
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState){
        switch (state) {
        case MCSessionState.Connecting:
            println("\(peerID) is connecting to private session.")
            break
        case MCSessionState.Connected:
            println("\(peerID) has connected to private session.")
            //user accepted invitation
            isActive = true
            connectedPeer = SMManager.shared.privatePeerDict[peerID.displayName]!
            delegate?.peerHasConnected()
            SMPersistenceManager.saveContext()
            break
        case MCSessionState.NotConnected:
            println("\(peerID) is not connected to private session.")
            //user chose not to connect or did not respond to invitation in time
            delegate?.peerHasDisconnected()
            SMPersistenceManager.saveContext()
        default:
            break
        }
    }
    
    // Received data from remote peer
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!){
        SMMessageHandlerDispatch.shared.dispatch(SMMessage(fromJSONData: data), forDelegate: self)
    }
    
    // Received a byte stream from remote peer
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!){
        
    }
    
    // Start receiving a resource from remote peer
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!){
       println("Receiving resource \(progress.fractionCompleted*100)%")
    }
    
    // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!){
        println("Received resource")
        let peer : SMPeer = SMManager.shared.privatePeerDict[peerID.displayName]!
        let timestamp : NSDate = NSDate()
        SMImageHandler.handleImageAndReturnPost(peer, timestamp: timestamp, url: localURL){ (post)->Void in
            self.posts.addObject(post)
            self.delegate?.receivedNewPost(post)
            SMPersistenceManager.saveContext()
        }
    }
    
    func endSession(){
        session?.disconnect()
        isActive = false
    }
}
