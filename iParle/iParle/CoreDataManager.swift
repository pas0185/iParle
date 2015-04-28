//
//  CoreDataManager.swift
//  ProCom
//
//  Created by Patrick Sheehan on 4/20/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

private let _CoreDataManagerInstance = CoreDataManager()

class CoreDataManager: NSObject {

    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    class var sharedInstance: CoreDataManager {
        return _CoreDataManagerInstance
    }
    
    //MARK: - Convos
    func fetchConvos(forGroup group: ManagedGroup?, completion: (convos: [ManagedConvo]) -> Void) {
        // Return all Convos saved in Core Data
        
        var convos = [ManagedConvo]()
        
        var fetchRequest = NSFetchRequest(entityName: "Convo")
        if let groupId = group?.pfId {
            println("Convo predicate from core: parent group ID = \(groupId)")
            fetchRequest.predicate  = NSPredicate(format: "parentGroupId == %@", groupId)
            
            var error: NSError?
            
            // Send fetch request
            convos = managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as! [ManagedConvo]
            
            if error != nil {
                println(error!.localizedDescription)
            }
            
            // Notify the fetch is finished to the completion block
            completion(convos: convos)

        }
        else {
            println("CoreDataManager could not fetch any Convos for the given group:\(group)")
        }
    }
    
    func saveNewConvos(convos: [Convo], completion: (newMgdConvos: [ManagedConvo]) -> Void) {
        
        var mgdConvos = [ManagedConvo]()
        
        if let entity = NSEntityDescription.entityForName("Convo", inManagedObjectContext: self.managedObjectContext!) {

            for pfConvo in convos {
                var mgdConvo = ManagedConvo(entity: entity, insertIntoManagedObjectContext: self.managedObjectContext)
                
                mgdConvo.name = pfConvo.name
                mgdConvo.pfId = pfConvo.pfId
                mgdConvo.parentGroupId = pfConvo.parentGroupId
                
                mgdConvos.append(mgdConvo)
            }
            
            
            var error: NSError?
            self.managedObjectContext?.save(&error)
            
            if error != nil {
                println("Error saving Convos to Core Data: \(error?.localizedDescription)")
            }
        }
        
        
        completion(newMgdConvos: mgdConvos)
    }
    
    //MARK: - Groups
    func fetchGroups(forGroup group: ManagedGroup?, completion: (groups: [ManagedGroup]) -> Void) {
        // Return children Groups of the parameter Group
        //      if received nil group; fetch the 'home' one with an ID of 0
        
        var groups = [ManagedGroup]()
        
        var fetchRequest = NSFetchRequest(entityName: "Group")
        if let groupId = group?.pfId {
            // Was provided a valid group, get all Groups that have it as their parent
            println("Group predicate from core: parent group ID = \(groupId)")
            fetchRequest.predicate = NSPredicate(format: "parentGroupId == %@", groupId)
        }
        else {
            // Was not provided a valid group, get 'home' group
            fetchRequest.predicate  = NSPredicate(format: "parentGroupId == 0")
        }
        var error: NSError?
        
        // Send fetch request
        groups = managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as! [ManagedGroup]
        
        if error != nil {
            println(error!.localizedDescription)
        }
        
        // Notify the fetch is finished to the completion block
        completion(groups: groups)
    }
    
    func saveNewGroups(groups: [Group], completion: (newMgdGroups: [ManagedGroup]) -> Void) {
        
        var mgdGroups = [ManagedGroup]()
        
        if let entity = NSEntityDescription.entityForName("Group", inManagedObjectContext: self.managedObjectContext!) {
            
            for pfGroup in groups {
                var mgdGroup = ManagedGroup(entity: entity, insertIntoManagedObjectContext: self.managedObjectContext)
                
                mgdGroup.name = pfGroup.name
                mgdGroup.pfId = pfGroup.pfId
                mgdGroup.parentGroupId = pfGroup.parentGroupId
                
                mgdGroups.append(mgdGroup)
            }
            
            var error: NSError?
            self.managedObjectContext?.save(&error)
            
            if error != nil {
                println("Error saving Group to Core Data: \(error?.localizedDescription)")
            }
        }
        
        completion(newMgdGroups: mgdGroups)
    }
    
    //MARK: - Blurbs
    func fetchBlurbs(convoId: String, completion: (blurbs: [ManagedBlurb]) -> Void) {
        
        // Fetch Blurbs from Core Data
        
        var blurbs = [ManagedBlurb]()
        
        var fetchRequest = NSFetchRequest(entityName: "Blurb")
        println("Predicate for fetching Core Data Blurbs: convoID = \(convoId)")
        fetchRequest.predicate = NSPredicate(format: "convoId == %@", convoId)
        
        // Send fetch request
        var error: NSError?
        blurbs = managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as! [ManagedBlurb]
        
        if error != nil {
            println(error!.localizedDescription)
        }
        
        // Notify the fetch is finished to the completion block
        completion(blurbs: blurbs)
    }
    
    func saveNewBlurbs(blurbs: [Blurb], completion: (newMgdBlurbs: [ManagedBlurb]) -> Void) {
        // Save Blurbs to Core Data
        
        var mgdBlurbs = [ManagedBlurb]()
        
        if let entity = NSEntityDescription.entityForName("Blurb", inManagedObjectContext: self.managedObjectContext!) {
            
            for pfBlurb in blurbs {
                var mgdBlurb = ManagedBlurb(entity: entity, insertIntoManagedObjectContext: self.managedObjectContext)
                
                mgdBlurb.convoId = pfBlurb.convoId
                mgdBlurb.createdAt = pfBlurb.createdAt
                mgdBlurb.pfId = pfBlurb.pfId
                mgdBlurb.text = pfBlurb.text
                mgdBlurb.userId = pfBlurb.userId
                mgdBlurb.username = pfBlurb.username
                
                mgdBlurbs.append(mgdBlurb)
            }
            
            var error: NSError?
            self.managedObjectContext?.save(&error)
            
            if error != nil {
                println("Error saving Blurb to Core Data: \(error?.localizedDescription)")
            }
    }
        
        // Notify the save is finished to the completion block
        completion(newMgdBlurbs: mgdBlurbs)
    }
    
}
