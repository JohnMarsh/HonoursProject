//
//  SMPersistenceManager.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-03-24.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation
import CoreData
import MultipeerConnectivity

class SMPersistenceManager: NSObject {
    
    class func createNewUser() -> SMUser{
        
        if let existingObject = getExistingUser() {
            return existingObject
        }
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let entity =  NSEntityDescription.insertNewObjectForEntityForName("SMUser",
        inManagedObjectContext:
        managedContext) as SMUser
        
        return entity
    }
    
    class func getExistingUser() -> SMUser?{
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!

        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("SMUser",
            inManagedObjectContext: managedContext)
        fetchRequest.entity = entity
        var error : NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error)
        if let results = fetchedResults  {
            if(results.count > 0){
                return results[0] as? SMUser
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
    
    class func createNewPeer(peerID : MCPeerID) ->SMPeer{
        
        if let existingObject = getExistingPeer(peerID) {
            existingObject.peerID = peerID
            return existingObject
        }
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let entity =  NSEntityDescription.entityForName("SMPeer",
            inManagedObjectContext:
            managedContext)
        
        let peer = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext) as SMPeer
        
        peer.guid = peerID.displayName
        peer.peerID = peerID
        return peer
    }
    
    class func getExistingPeer(peerID : MCPeerID) -> SMPeer?{
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("SMPeer",
            inManagedObjectContext: managedContext)
        fetchRequest.entity = entity
        let resultPredicate = NSPredicate(format: "guid == %@", peerID.displayName)
        fetchRequest.predicate = resultPredicate
        var error : NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error)
        if let results = fetchedResults{
            if(results.count > 0){
                return results[0] as? SMPeer
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
    
    class func createNewPrivateSessionWithPeer(peer : SMPeer) -> SMPrivateSession{
        
        if let existingObject = getExistingPrivateSessionWithPeer(peer) {
            return existingObject
        }
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!

        
        let entity =  NSEntityDescription.entityForName("SMPrivateSession",
            inManagedObjectContext:
            managedContext)
        
        
        let session = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext) as SMPrivateSession

        return session
    }
    
    class func getExistingPrivateSessionWithPeer(peer : SMPeer) -> SMPrivateSession?{
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("SMPrivateSession",
            inManagedObjectContext: managedContext)
        fetchRequest.entity = entity
        let resultPredicate = NSPredicate(format: "connectedPeer.guid == %@", peer.guid)
        fetchRequest.predicate = resultPredicate
        var error : NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error)
        if let results = fetchedResults{
            if(results.count > 0){
                return results[0] as? SMPrivateSession
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
    
    class func createNewPost() -> SMPost{
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let entity =  NSEntityDescription.insertNewObjectForEntityForName("SMPost",
            inManagedObjectContext:
            managedContext) as SMPost
        
        return entity
    }
    
    class func createNewProfile() -> SMUserProfile{
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let entity =  NSEntityDescription.insertNewObjectForEntityForName("SMUserProfile",
            inManagedObjectContext:
            managedContext) as SMUserProfile
        
        return entity

    }
    
    class func saveContext(){
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
    
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
    }

}
