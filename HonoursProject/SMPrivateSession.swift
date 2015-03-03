//
//  SMPrivateSession.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-01-12.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class SMPrivateSession: NSObject, MCSessionDelegate, SMMessageHandlerDelegate {
    
    var session : MCSession
    var peer : MCPeerID?
    var posts : [SMPost]
    var timer : NSTimer?
    var isActive : Bool
    
    override init(){
        session = MCSession(peer: SMUser.shared.peerId)
        posts = []
        isActive = true
        super.init()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("sendHeartbeat"), userInfo: nil, repeats: true)
        session.delegate = self
    }
   
    convenience init(p: MCPeerID){
        self.init()
        peer = p
    }
    
    //MARK: SMPrivateSession Methods
    
    func sendTextToPeer(text : String){
        
    }
    
    func sendResourceToPeer(){
        
    }
    
    func startStreamingCamera(){

    }
    
    func stopStreamingCamera(){
     
    }
    
    func sendHeartbeat(){
        
    }
    
    //MARK: SMMessageHandlerDelegate
    
    func didReceivePost(post: SMPost) {
        posts.append(post);
    }
    
    func didReceiveHeartbeat() {
        isActive = true
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
            break
        case MCSessionState.NotConnected:
            println("\(peerID) is not connected to private session.")
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
       
    }
    
    // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!){
       
    }
}
