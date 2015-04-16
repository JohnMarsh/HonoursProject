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
    func startedAdvertisingSelf()
    func stoppedAdvertisingSelf()
    func startedBroswingForPeers()
    func stoppedBrowsingForPeers()
}

protocol SMManagerPeerDelegate{
    func foundNewPeer(peer : SMPeer)
    func lostPeer(peer : SMPeer)
    func didReceivePrivateInvitationFromPeer(user : SMPeer!, invitationHandler: ((Bool) -> Void)!)
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
        self.publicAdvertiser = MCNearbyServiceAdvertiser(peer: SMUser.shared.peerId, discoveryInfo: nil, serviceType: publicServiceType)
        self.privateAdvertiser = MCNearbyServiceAdvertiser(peer: SMUser.shared.peerId, discoveryInfo: nil, serviceType: privateServiceType)
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
        self.timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("startPublicBrowsing"), userInfo: nil, repeats: false)
        self.startPrivateAdvertising()
        self.startPrivateBrowsing()
        self.startPublicAdvertising()
    }
    
    //MARK: SMManager Private Methods
    
    func startPublicBrowsing(){
        ~{
            println("Started browsing for peers.")
            self.publicBrowser.startBrowsingForPeers()
         //   self.connectionDelegate?.startedBroswingForPeers()
        }
    }
    
    private func stopPublicBrowsing(){
        ~{
            println("Stopped public browsing")
            self.publicBrowser.stopBrowsingForPeers()
         //   self.connectionDelegate?.stoppedBrowsingForPeers()
        }
    }
    
    private func startPublicAdvertising(){
        ~{
            println("Started public advertising")
            self.publicAdvertiser.startAdvertisingPeer()
            //self.connectionDelegate?.startedAdvertisingSelf()
        }
    }
    
    private func stopPublicAdvertising(){
        ~{
            println("Stopped public advertising")
            self.publicAdvertiser.stopAdvertisingPeer()
           // self.connectionDelegate?.stoppedAdvertisingSelf()
        }
    }
    
    func startPrivateBrowsing(){
        ~{
            println("Started browsing for peers.")
            self.privateBrowser.startBrowsingForPeers()
           // self.connectionDelegate?.startedBroswingForPeers()
        }
    }
    
    private func stopPrivateBrowsing(){
        ~{
            println("Stopped public browsing")
            self.privateBrowser.stopBrowsingForPeers()
           // self.connectionDelegate?.stoppedBrowsingForPeers()
        }
    }
    
    private func startPrivateAdvertising(){
        ~{
            println("Started public advertising")
            self.privateAdvertiser.startAdvertisingPeer()
          //  self.connectionDelegate?.startedAdvertisingSelf()
        }
    }
    
    private func stopPrivateAdvertising(){
        ~{
            println("Stopped private advertising")
            self.privateAdvertiser.stopAdvertisingPeer()
          //  self.connectionDelegate?.stoppedAdvertisingSelf()
        }
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
                let smPeer : SMPeer = SMPersistenceManager.createNewPeer(peerID)
                publicPeerDict[peerID.displayName] = smPeer
                publicPeerList = [SMPeer](publicPeerDict.values)
                peerDeleagte?.foundNewPeer(smPeer)
            }
            println("Accepting invitation to public board from \(peerID)")
            invitationHandler(true, publicBoard.session)
            timer!.invalidate()
            //Now that we've joined a session we want to find other peers to join
            self.startPublicBrowsing()
            break
        case privateAdvertiser:
            if let somePeer = privatePeerDict[peerID.displayName]{
                //we already have this peer
            } else{
                let smPeer : SMPeer = SMPersistenceManager.createNewPeer(peerID)
                privatePeerDict[peerID.displayName] = smPeer
                privatePeerList = [SMPeer](publicPeerDict.values)
                peerDeleagte?.foundNewPeer(smPeer)
            }
            let privateSession : SMPrivateSession = SMPersistenceManager.createNewPrivateSessionWithPeer(self.privatePeerDict[peerID.displayName]!)
            if(privateSession.isActive){
                privateSession.connectedPeer = self.privatePeerDict[peerID.displayName]
                self.privateSessions[self.privatePeerDict[peerID.displayName]!] = privateSession
                invitationHandler(true, privateSession.session)
            }else{
                peerDeleagte?.didReceivePrivateInvitationFromPeer(privatePeerDict[peerID.displayName], invitationHandler: { (didAccept : Bool) -> Void in
                    if(didAccept){
                        privateSession.isActive = true
                        privateSession.connectedPeer = self.privatePeerDict[peerID.displayName]
                        self.privateSessions[self.privatePeerDict[peerID.displayName]!] = privateSession
                        invitationHandler(true, privateSession.session)
                    }else{
                        invitationHandler(false, nil)
                    }
                })
            }
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
                let smPeer : SMPeer =  SMPersistenceManager.createNewPeer(peerID)
                println("adding public peer with display name \(peerID.displayName) and guid \(smPeer.guid)")
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
                let smPeer : SMPeer =  SMPersistenceManager.createNewPeer(peerID)
                println("adding private peer with display name \(peerID.displayName) and guid \(smPeer.guid)")
                privatePeerDict[peerID.displayName] = smPeer
                privatePeerList = [SMPeer](privatePeerDict.values)
                peerDeleagte?.foundNewPeer(smPeer)
                let privateSession : SMPrivateSession = SMPersistenceManager.createNewPrivateSessionWithPeer(smPeer)
                if(privateSession.isActive){
                   invitePeerToPrivateSession(smPeer)
                }
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
                publicPeerDict[peerID.displayName] = nil
                publicPeerList = [SMPeer](publicPeerDict.values)
                peerDeleagte?.lostPeer(somePeer)
            } else{
                //we did not have this peer in our list anyways
            }
            break
        case privateBrowser:
            println("lost private peer : \(peerID.displayName).")
            if let somePeer = privatePeerDict[peerID.displayName]{
                privatePeerDict[peerID.displayName] = nil
                privatePeerList = [SMPeer](privatePeerDict.values)
                peerDeleagte?.lostPeer(somePeer)
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
        let privateSession : SMPrivateSession = SMPersistenceManager.createNewPrivateSessionWithPeer(peer)
        println("private session with connectedPeer \(privateSession.connectedPeer?.guid)")
        privateSessions[peer] = privateSession
        privateSession.connectedPeer = peer
        privateSession.isActive = true
        privateBrowser.invitePeer(peer.peerID, toSession: privateSession.session, withContext: nil, timeout: 60)
    }

    
}
