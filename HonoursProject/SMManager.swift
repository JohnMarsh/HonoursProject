//
//  SMManager.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-01-12.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol SMManagerConnectionDelegate{
    func didReceivePrivateInvitationFromPeer(user : SMPeer!, invitationHandler: ((Bool) -> Void)!)
    func startedAdvertisingSelf()
    func stoppedAdvertisingSelf()
    func startedBroswingForPeers()
    func stoppedBrowsingForPeers()
}

protocol SMManagerPeerDelegate{
    func foundNewPeer(peer : SMPeer)
    func lostPeer(peer : SMPeer)
}

class SMManager: NSObject, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    let publicServiceType = "sm-public"
    let privateServiceType = "sm-private"
    var publicBoard : SMPublicBoard
    var privateSessions : [SMPeer : SMPrivateSession]
    var connectionDelegate : SMManagerConnectionDelegate?
    var peerDeleagte : SMManagerPeerDelegate?
    var publicBrowser : MCNearbyServiceBrowser
    var privateBrowser : MCNearbyServiceBrowser
    var publicAdvertiser : MCNearbyServiceAdvertiser
    var privateAdvertiser : MCNearbyServiceAdvertiser
    var publicPeerDict : [String : SMPeer]
    var publicPeerList : [SMPeer]
    var privatePeerDict : [String : SMPeer]
    var privatePeerList : [SMPeer]
    var timer : NSTimer?
    
    override init(){
        self.publicBoard = SMPublicBoard()
        self.privateSessions = [:]
        self.publicBrowser = MCNearbyServiceBrowser(peer: SMUser.shared.peerId, serviceType: publicServiceType)
        self.privateBrowser = MCNearbyServiceBrowser(peer: SMUser.shared.peerId, serviceType: privateServiceType)
        self.publicAdvertiser = MCNearbyServiceAdvertiser(peer: SMUser.shared.peerId, discoveryInfo: SMUser.shared.discoveryInfo, serviceType: publicServiceType)
        self.privateAdvertiser = MCNearbyServiceAdvertiser(peer: SMUser.shared.peerId, discoveryInfo: SMUser.shared.discoveryInfo, serviceType: privateServiceType)
        self.publicPeerDict = [:]
        self.publicPeerList = [SMPeer]()
        self.privatePeerDict = [:]
        self.privatePeerList = [SMPeer]()
        super.init()
        self.publicBrowser.delegate = self
        self.privateBrowser.delegate = self
        self.publicAdvertiser.delegate = self
        self.privateAdvertiser.delegate = self
        SMMessageHandlerDispatch.shared
    }
    
    class var shared : SMManager {
        
        struct Static {
            static let instance : SMManager = SMManager()
        }
        
        return Static.instance
    }
    
    //MARK: SMManager Public Methods
    
    func start(){
        self.timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("beginPublicBrowsing"), userInfo: nil, repeats: false)
        privateAdvertiser.startAdvertisingPeer();
        privateBrowser.startBrowsingForPeers();
        self.beginPublicAdvertising()
    }
    
    //MARK: SMManager Private Methods
    
    func beginPublicBrowsing(){
        println("Started browsing for peers.")
      //  self.stopPublicAdvertising()
        publicBrowser.startBrowsingForPeers()
        connectionDelegate?.startedBroswingForPeers()
    }
    
    private func stopPublicBrowsing(){
        println("Stopped public browsing")
        publicBrowser.stopBrowsingForPeers()
        connectionDelegate?.stoppedBrowsingForPeers()
    }
    
    private func beginPublicAdvertising(){
        println("Started public advertising")
        self.publicAdvertiser.startAdvertisingPeer()
        connectionDelegate?.startedAdvertisingSelf()
    }
    
    private func stopPublicAdvertising(){
        println("Stopped public advertising")
        self.publicAdvertiser.startAdvertisingPeer()
        connectionDelegate?.stoppedAdvertisingSelf()
    }
    
    
    //MARK: MCNearbyServiceAdvertiserDelegate Methods
    
    // Incoming invitation request.  Call the invitationHandler block with true and a valid session to connect the inviting peer to the session.
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!){
        println("Received invitation from \(peerID)")
        switch advertiser {
        case publicAdvertiser:
            //if we haven't discovered this user on our own yet then add it to the list
            if let somePeer = publicPeerDict[peerID.displayName]{
                //we already have this peer
            } else{
                let smPeer : SMPeer = SMPeer(peerID: peerID)
                publicPeerDict[peerID.displayName] = smPeer
                publicPeerList = [SMPeer](publicPeerDict.values)
                peerDeleagte?.foundNewPeer(smPeer)
            }
            println("Accepting invitation to public board from \(peerID)")
            invitationHandler(true, publicBoard.session)
            timer!.invalidate()
            //Now that we've joined a session we want to find other peers to join
            self.beginPublicBrowsing()
            break
        case privateAdvertiser:
            connectionDelegate?.didReceivePrivateInvitationFromPeer(privatePeerDict[peerID.displayName], invitationHandler: { (didAccept : Bool) -> Void in
                if(didAccept){
                    let privateSession : SMPrivateSession = SMPrivateSession()
                    privateSession.connectedPeer = peerID
                    privateSession.isActive = true
                    self.privateSessions[self.privatePeerDict[peerID.displayName]!] = privateSession
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
     
        switch browser{
        case publicBrowser:
            println("Found public peer : \(peerID.displayName) .")

            if let somePeer = publicPeerDict[peerID.displayName]{
                //we already have this peer
            } else{
                let smPeer : SMPeer = SMPeer(peerID: peerID)
                publicPeerDict[peerID.displayName] = smPeer
                publicPeerList = [SMPeer](publicPeerDict.values)
            }
            println("Inviting peer : \(peerID).")
            publicBrowser.invitePeer(peerID, toSession: publicBoard.session, withContext: nil, timeout: 30)
            break
        case privateBrowser:
            println("Found private peer : \(peerID.displayName).")
            if let somePeer = privatePeerDict[peerID.displayName]{
                //we already have this peer
            } else{
                let smPeer : SMPeer = SMPeer(peerID: peerID)
                privatePeerDict[peerID.displayName] = smPeer
                privatePeerList = [SMPeer](privatePeerDict.values)
                peerDeleagte?.foundNewPeer(smPeer)
            }
            break
        default:
            break
        }
    }
    
    // A nearby peer has stopped advertising
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!){
        
        switch browser{
        case publicBrowser:
            println("lost public peer : \(peerID.displayName).")
            if let somePeer = publicPeerDict[peerID.displayName]{
                peerDeleagte?.lostPeer(somePeer)
                publicPeerDict[peerID.displayName] = nil
                publicPeerList = [SMPeer](publicPeerDict.values)
            } else{
                //we did not have this peer in our list anyways
            }
            break
        case privateBrowser:
            println("lost private peer : \(peerID.displayName).")
            if let somePeer = privatePeerDict[peerID.displayName]{
                peerDeleagte?.lostPeer(somePeer)
                privatePeerDict[peerID.displayName] = nil
                privatePeerList = [SMPeer](privatePeerDict.values)
            } else{
                //we did not have this peer in our list anyways
            }

            break
        default:
            break
        }
        
        
       
    }
    
    // Browsing did not start due to an error
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!){
         println("Could not browse for peers.")
    }
    
    func invitePeerToPrivateSession(peer : SMPeer){
        let privateSession : SMPrivateSession = SMPrivateSession()
        privateSessions[peer] = privateSession
        privateBrowser.invitePeer(peer.peerID, toSession: privateSession.session, withContext: nil, timeout: 60)
    }

    
}
