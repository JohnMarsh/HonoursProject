//
//  SMManager.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-01-12.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol SMManagerDelegate{
    func didReceivePrivateInvitationFromPeer(user : SMPeer!, invitationHandler: ((Bool) -> Void)!)
}

class SMManager: NSObject, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    let publicServiceType = "sm-public"
    let privateServiceType = "sm-private"
    var publicBoard : SMPublicBoard!
    var privateSessions : NSMutableDictionary!
    var delegate : SMManagerDelegate?
    var publicBrowser : MCNearbyServiceBrowser!
    var privateBrowser : MCNearbyServiceBrowser!
    var publicAdvertiser : MCNearbyServiceAdvertiser!
    var privateAdvertiser : MCNearbyServiceAdvertiser!
    var peerList : NSMutableDictionary!
    var timer : NSTimer!
    
    override init(){
        self.publicBoard = SMPublicBoard()
        self.privateSessions = NSMutableDictionary()
        
        self.publicBrowser = MCNearbyServiceBrowser(peer: SMUser.sharedInstance().peerId, serviceType: publicServiceType)
        self.privateBrowser = MCNearbyServiceBrowser(peer: SMUser.sharedInstance().peerId, serviceType: privateServiceType)
        
        self.publicAdvertiser = MCNearbyServiceAdvertiser(peer: SMUser.sharedInstance().peerId, discoveryInfo: nil, serviceType: publicServiceType)
        self.privateAdvertiser = MCNearbyServiceAdvertiser(peer: SMUser.sharedInstance().peerId, discoveryInfo: nil, serviceType: privateServiceType)
        
        self.peerList = NSMutableDictionary()
        
        super.init()
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("beginBrowsing"), userInfo: nil, repeats: false)
        
        self.publicBrowser.delegate = self
        //privateBrowser.delegate = self
        self.publicAdvertiser.delegate = self
        //privateAdvertiser.delegate = self
        
        //we won't start browsing yet we would rather join an existing network first
        println("Began advertsising peer.")
        self.publicAdvertiser.startAdvertisingPeer()
    }
    
    convenience init(delegate: SMManagerDelegate){
        self.init()
        self.delegate = delegate
    }
    
    func beginBrowsing(){
        println("Began broswsing for peers.")
        publicBrowser.stopBrowsingForPeers()
    }
    
    // Incoming invitation request.  Call the invitationHandler block with YES and a valid session to connect the inviting peer to the session.
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!){
        
        println("Received invitation from \(peerID)")

        //if this peer isn't in our list then add them
        if(peerList.objectForKey(peerList) == nil){
            peerList.setObject(SMPeer(peerID: peerID), forKey: peerID)
        }
        
        switch advertiser {
        case publicAdvertiser:
            println("Accepting invitation to public board from \(peerID)")
            invitationHandler(true, publicBoard.session)
            timer.invalidate()
            //publicAdvertiser.stopAdvertisingPeer()
            publicBrowser.stopBrowsingForPeers()
            break
        case privateAdvertiser:
            delegate?.didReceivePrivateInvitationFromPeer(peerList.objectForKey(peerID) as SMPeer, invitationHandler: { (didAccept : Bool) -> Void in
                if(didAccept){
                    let privateSession : SMPrivateSession = SMPrivateSession(s: MCSession(peer:SMUser.sharedInstance().peerId))
                    self.privateSessions.setObject(privateSession, forKey: peerID)
                    invitationHandler(true, privateSession.session)
                }else{
                    invitationHandler(false, nil)
                }
            })
            break
        default:
            break
        }
    }
    
    
    // Advertising did not start due to an error
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!){
          println("Could not advertise peer.")
    }
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!){
        //add this peer to our list no matter what
        println("Found peer : \(peerID).")
        peerList.setObject(SMPeer(peerID: peerID), forKey: peerID)
        switch browser{
        case publicBrowser:
            println("Inviting peer : \(peerID).")
            browser.invitePeer(peerID, toSession: publicBoard.session, withContext: nil, timeout: 30)
            break
        case privateBrowser:
            break
        default:
            break
        }
    }
    
    // A nearby peer has stopped advertising
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!){
        peerList.removeObjectForKey(peerID)
    }
    
    // Browsing did not start due to an error
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!){
         println("Could not browse for peers.")
    }
}
