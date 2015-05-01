//
//  NetworkManager.swift
//  iParle
//
//  Created by Patrick Sheehan on 4/20/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

private let _NetworkManagerInstance = NetworkManager()

class NetworkManager: NSObject {
    
    class var sharedInstance: NetworkManager {
        return _NetworkManagerInstance
    }
    
    //MARK: - Installation
    func subscribeToConvoForNotifications(convo: Convo) {
        
        if let channelName = convo.getChannelName() {
            
            let currentInstallation = PFInstallation.currentInstallation()
            
            currentInstallation.addUniqueObject(channelName, forKey: "channels")
            
            currentInstallation.saveInBackgroundWithBlock {
                (succeeded, error) -> Void in
                
                if error == nil {
                    println("Successfully subscribed this installation to a Convo channel")
                }
                else {
                    println(error!.localizedDescription)
                }
            }
        }
    }
    
    //MARK: - Convos
    func fetchNewConvos(forGroup group: ManagedGroup?, existingConvoIds: [String], user: PFUser, completion: (newConvos: [Convo]) -> Void) {
        
        var convos = [Convo]()
        
        // Build Convo Query
        let convoQuery = Convo.query()
        convoQuery!.whereKey(USERS_KEY, equalTo: user)
        convoQuery!.whereKey(OBJECT_ID_KEY, notContainedIn: existingConvoIds)
        
        if let groupId = group?.pfId {
            println("Convo predicate from Network: parent group ID = \(groupId)")
            convoQuery!.whereKey("parentGroupId", equalTo: groupId)
        
            // Send the Convo query
            convoQuery!.findObjectsInBackgroundWithBlock({
                (objects, error) -> Void in
                
                if (error == nil) {
                    println("Fetched \(objects!.count) convos from Network")
                    
                    convos = objects as! [Convo]
                    completion(newConvos: convos)
                }
            })
        }
        else {
            println("Could not perform Convo Network fetch for empty groupId")
        }
    }
    
    func saveNewConvo(convo: Convo, completion: (convo: Convo) -> Void) {
        
        convo.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if (success) {
                println("Successfully saved new convo to Network: \(convo)")
                self.subscribeToConvoForNotifications(convo)
                completion(convo: convo)
            }
            else {
                println("Failed to save new convo to Network: \(convo)")
            }
        }
    }
    
    //MARK: - Groups
    func fetchNewGroups(groupId: String, existingGroupIds: [String], completion: (newGroups: [Group]) -> Void) {
        
        var groups = [Group]()
        
        // Build Group Query...
        let groupQuery = Group.query()
        groupQuery!.whereKey("parentGroupId", equalTo: groupId)
        groupQuery!.whereKey(OBJECT_ID_KEY, notContainedIn: existingGroupIds)
        
        // Send the query
        groupQuery!.findObjectsInBackgroundWithBlock({
            (objects, error) -> Void in
            
            if (error == nil) {
                println("Fetched \(objects!.count) new Groups from Network")
                
                groups = objects as! [Group]
                completion(newGroups: groups)
            }
            else {
                println(error!.localizedDescription)
            }
        })
    }
    
    func saveNewGroup(group: Group, completion: (group: Group) -> Void) {
        
        group.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if (success) {
                println("Successfully saved new group to Network: \(group)")
                completion(group: group)
            }
            else {
                println("Failed to save new group to Network: \(group)")
            }
        }
    }
    
    //MARK: - Blurbs
    func fetchNewBlurbs(convoId: String, existingBlurbIds: [String], completion: (newBlurbs: [Blurb]) -> Void) {
                
        // Fetch new Blurbs from the Network
        
        var blurbs = [Blurb]()

        // Build Parse query for Blurbs
        let blurbQuery = Blurb.query()
        blurbQuery!.includeKey("createdAt")
        blurbQuery!.whereKey("convoId", equalTo: convoId)
        blurbQuery!.whereKey("objectId", notContainedIn: existingBlurbIds)
        blurbQuery!.orderByAscending("createdAt")

        // Fetch all blurbs for this convo
        blurbQuery!.findObjectsInBackgroundWithBlock({
            (array, error) -> Void in

            if (error == nil) {
                println("Fetched \(array!.count) Blurbs from the Network")

                blurbs = array as! [Blurb]
                completion(newBlurbs: blurbs)
            }
            else {
                println(error!.localizedDescription)
            }
        })
    }
    
    func saveNewBlurb(text: String, convoId: String, completion: (blurb: Blurb) -> Void) {
        
        var blurb = Blurb()
        blurb["text"] = text
        blurb["convoId"] = convoId
        blurb["userId"] = PFUser.currentUser()!.objectId
        blurb["username"] = PFUser.currentUser()!.username
        
        // Save new Blurb to the Network
        blurb.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if (success) {
                println("Blurb successfully saved to network: \(blurb)")
                
                completion(blurb: blurb)
                
            } else {
                println("There was a problem sending the message")
            }
        }
        
    }
}
