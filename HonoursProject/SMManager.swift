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
    
}

class SMManager: NSObject, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    let publicServiceType = "xxSocialMesh-Public-Service";
    let privateServiceType = "xxSocialMesh-Private-Service";
    
    var user : SMUser;
    var publicBoard : SMPublicBoard;
    var privateSessions : NSMutableDictionary;
    var delegate : SMManagerDelegate?;
    
    var publicBrowser : MCNearbyServiceBrowser;
    var privateBrowser : MCNearbyServiceBrowser;
    
    var publicAdvertiser : MCNearbyServiceAdvertiser;
    var privateAdvertiser : MCNearbyServiceAdvertiser;
    
    override init(){
        publicBoard = SMPublicBoard();
        privateSessions = NSMutableDictionary();
        
        user = SMUser();
        
        publicBrowser = MCNearbyServiceBrowser(peer: user.peerId, serviceType: publicServiceType);
        privateBrowser = MCNearbyServiceBrowser(peer: user.peerId, serviceType: privateServiceType);
        
        publicAdvertiser = MCNearbyServiceAdvertiser(peer: user.peerId, discoveryInfo: nil, serviceType: publicServiceType);
        privateAdvertiser = MCNearbyServiceAdvertiser(peer: user.peerId, discoveryInfo: nil, serviceType: privateServiceType);
        
        publicBrowser.startBrowsingForPeers();
        publicAdvertiser.startAdvertisingPeer();
        
    }
    
    convenience init(delegate: SMManagerDelegate){
        self.init();
        self.delegate = delegate;
    }
    
    // Incoming invitation request.  Call the invitationHandler block with YES and a valid session to connect the inviting peer to the session.
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!){
        
    }
    
    // Advertising did not start due to an error
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!){
    }
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!){
        
    }
    
    // A nearby peer has stopped advertising
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!){
        
    }
    
    // Browsing did not start due to an error
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!){
        
    }
}
