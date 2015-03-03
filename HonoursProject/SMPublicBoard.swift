//
//  SMPublicBoard.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-01-12.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation
import MultipeerConnectivity


class SMPublicBoard: NSObject, MCSessionDelegate, SMMessageHandlerDelegate {
    
    var session : MCSession
    var posts : [SMPost]
    
    
    override init(){
        session = MCSession(peer: SMUser.shared.peerId)
        posts = []
        super.init()
        session.delegate = self
    }
    
    
    // Remote peer changed state
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState){
        switch (state) {
        case MCSessionState.Connecting:
            println("\(peerID) is connecting to public board.")
            break
        case MCSessionState.Connected:
             println("\(peerID) has connected to public board.")
             var error : NSErrorPointer = NSErrorPointer()
             session.sendData(SMUser.shared.buildProfileMessage().messageToJSONData(), toPeers: [peerID], withMode: MCSessionSendDataMode.Reliable, error: error)
            break
        case MCSessionState.NotConnected:
             println("\(peerID) is not connected to public board.")
            break
        default:
            break
        }
    }
    
    //MARK: SMPublicBoard public methods
    
    func postTextToBoard(text : String){
        var error : NSErrorPointer = NSErrorPointer()
        session.sendData(SMMessageFactory.createTextMessageWithString(text).messageToJSONData(), toPeers: session.connectedPeers, withMode:  MCSessionSendDataMode.Reliable, error: error)
    }
    
    func postImageToBoard(){
       
    }
    
    //MARK: SMMessageHandlerDelegate 
    
    func didReceivePost(post: SMPost) {
        posts.append(post);
    }
    
    //MARK: MCSessionDelegate Methods
    
    // Received data from remote peer
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!){
        SMMessageHandlerDispatch.shared.dispatch(SMMessage(fromJSONData: data), forDelegate : self)
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
