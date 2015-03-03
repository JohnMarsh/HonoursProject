//
//  SMManager.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-01-12.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol SMManagerDelegate{
    func didReceivePrivateInvitationFromPeer(user : SMPeer!, invitationHandler: ((Bool) -> Void)!)
    func startedAdvertisingSelf()
    func stoppedAdvertisingSelf()
    func startedBroswingForPeers()
    func stoppedBrowsingForPeers()
}

class SMManager: NSObject, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    let publicServiceType = "sm-public"
    let privateServiceType = "sm-private"
    var publicBoard : SMPublicBoard
    var privateSessions : NSMutableDictionary
    var delegate : SMManagerDelegate?
    var publicBrowser : MCNearbyServiceBrowser
    var privateBrowser : MCNearbyServiceBrowser
    var publicAdvertiser : MCNearbyServiceAdvertiser
    var privateAdvertiser : MCNearbyServiceAdvertiser
    var peerList : NSMutableDictionary
    var timer : NSTimer?
    
    override init(){
        self.publicBoard = SMPublicBoard()
        self.privateSessions = NSMutableDictionary()
        self.publicBrowser = MCNearbyServiceBrowser(peer: SMUser.shared.peerId, serviceType: publicServiceType)
        self.privateBrowser = MCNearbyServiceBrowser(peer: SMUser.shared.peerId, serviceType: privateServiceType)
        self.publicAdvertiser = MCNearbyServiceAdvertiser(peer: SMUser.shared.peerId, discoveryInfo: SMUser.shared.discoveryInfo, serviceType: publicServiceType)
        self.privateAdvertiser = MCNearbyServiceAdvertiser(peer: SMUser.shared.peerId, discoveryInfo: SMUser.shared.discoveryInfo, serviceType: privateServiceType)
        self.peerList = NSMutableDictionary()
        super.init()
        self.publicBrowser.delegate = self
        self.privateBrowser.delegate = self
        self.publicAdvertiser.delegate = self
        self.privateAdvertiser.delegate = self
        SMMessageHandlerDispatch()
    }
    
    convenience init(delegate: SMManagerDelegate){
        self.init()
        self.delegate = delegate
    }
    
    //MARK: SMManager Public Methods
    
    func start(){
        self.timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("beginPublicBrowsing"), userInfo: nil, repeats: false)
        self.beginPublicAdvertising()
    }
    
    //MARK: SMManager Private Methods
    
    func beginPublicBrowsing(){
        println("Stopped advertising and started browsing.")
        self.stopPublicAdvertising()
        publicBrowser.startBrowsingForPeers()
        delegate?.startedBroswingForPeers()
    }
    
    private func stopPublicBrowsing(){
        println("Stopped public browsing")
        publicBrowser.stopBrowsingForPeers()
        delegate?.stoppedBrowsingForPeers()
    }
    
    private func beginPublicAdvertising(){
        println("Started public advertising")
        self.publicAdvertiser.startAdvertisingPeer()
        delegate?.startedAdvertisingSelf()
    }
    
    private func stopPublicAdvertising(){
        println("Stopped public advertising")
        self.publicAdvertiser.startAdvertisingPeer()
        delegate?.stoppedAdvertisingSelf()
    }
    
    
    //MARK: MCNearbyServiceAdvertiserDelegate Methods
    
    // Incoming invitation request.  Call the invitationHandler block with true and a valid session to connect the inviting peer to the session.
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!){
        println("Received invitation from \(peerID)")
        switch advertiser {
        case publicAdvertiser:
            println("Accepting invitation to public board from \(peerID)")
            invitationHandler(true, publicBoard.session)
            timer!.invalidate()
            //Now that we've joined a session we want to find other peers to join
            self.beginPublicBrowsing()
            break
        case privateAdvertiser:
            delegate?.didReceivePrivateInvitationFromPeer(peerList.objectForKey(peerID) as SMPeer, invitationHandler: { (didAccept : Bool) -> Void in
                if(didAccept){
                    let privateSession : SMPrivateSession = SMPrivateSession(p: peerID)
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
    
    
    //MARK: MCNearbyServiceBrowser Methods
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        //add this peer to our list no matter what
        println("Found peer : \(peerID) with discovery info \(info as NSDictionary).")
        peerList.setObject(SMPeer(peerID: peerID, info: info), forKey: peerID)
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
