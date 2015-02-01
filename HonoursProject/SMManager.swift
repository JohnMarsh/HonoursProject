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
    
    let publicServiceType = "xxSocialMesh-Public-Service"
    let privateServiceType = "xxSocialMesh-Private-Service"
    var publicBoard : SMPublicBoard
    var privateSessions : NSMutableDictionary
    var delegate : SMManagerDelegate?
    var publicBrowser : MCNearbyServiceBrowser
    var privateBrowser : MCNearbyServiceBrowser
    var publicAdvertiser : MCNearbyServiceAdvertiser
    var privateAdvertiser : MCNearbyServiceAdvertiser
    var peerList : NSMutableDictionary!
    
    override init(){
        publicBoard = SMPublicBoard()
        privateSessions = NSMutableDictionary()
        publicBrowser = MCNearbyServiceBrowser(peer: SMUser.sharedInstance().peerId, serviceType: publicServiceType)
        privateBrowser = MCNearbyServiceBrowser(peer:  SMUser.sharedInstance().peerId, serviceType: privateServiceType)
        publicAdvertiser = MCNearbyServiceAdvertiser(peer:  SMUser.sharedInstance().peerId, discoveryInfo: nil, serviceType: publicServiceType)
        privateAdvertiser = MCNearbyServiceAdvertiser(peer:  SMUser.sharedInstance().peerId, discoveryInfo: nil, serviceType: privateServiceType)
        peerList = NSMutableDictionary()
        super.init()
        publicBrowser.delegate = self
        privateBrowser.delegate = self
        publicAdvertiser.delegate = self
        privateAdvertiser.delegate = self
        //we won't start browsing yet we would rather join an existing network first
        publicBrowser.startBrowsingForPeers()
        publicAdvertiser.startAdvertisingPeer()
    }
    
    convenience init(delegate: SMManagerDelegate){
        self.init()
        self.delegate = delegate
    }
    
    // Incoming invitation request.  Call the invitationHandler block with YES and a valid session to connect the inviting peer to the session.
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!){
        
        //if this peer isn't in our list then add them
        if(peerList.objectForKey(peerList) == nil){
            peerList.setObject(SMPeer(peerID: peerID), forKey: peerID)
        }
        
        switch advertiser {
        case publicAdvertiser:
            println("Accepting invitation to public board")
            invitationHandler(true, publicBoard.session)
            publicAdvertiser.stopAdvertisingPeer()
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
    }
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!){
        //add this peer to our list no matter what
        peerList.setObject(SMPeer(peerID: peerID), forKey: peerID)
        switch browser{
        case publicBrowser:
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
        
    }
}
