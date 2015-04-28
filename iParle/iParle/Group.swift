//
//  Group.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit
import CoreData

class Group: PFObject, PFSubclassing {
    
    
    // Properties that ManagedConvo class uses during conversion
    var pfId: String {
        return self.objectId!
    }
    
    var parentGroupId: String {
        
        get {
            return self.objectForKey("parentGroupId") as! String
        }
        set {
            self.setObject(newValue, forKey: "name")
        }
    }
    
    var name: String {
        get {
            return self.objectForKey("name") as! String
        }
        set {
            self.setObject(newValue, forKey: "name")
        }
    }
    
    
    var subGroups: [Group] = []
    var subConvos: [Convo] = []
    
    var parentId: String?
    
    // MARK: - Initialization
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    override init() {
        super.init()
    }
    
    init(name: String) {
        super.init()
        
        self.name = name

    }
    
    init(name: String, parentId: String) {
        super.init()
        
        self.name = name
        self.parentId = parentId

    }
    
    class func parseClassName() -> String {
        return "Group"
    }
    
//    func getSubGroups() -> [Group] {
//        
//        var query = Group.query()
//        query!.fromLocalDatastore()
//        
//        query!.whereKey(PARENT_GROUP_KEY, equalTo: self)
//        var subGroups: [Group] = query!.findObjects() as! [Group]
//        println("\(subGroups.count) groups in the selected group")
//        
//        return subGroups
//    }
//    
//    func getSubConvos() -> [Convo] {
//        
//        var query = Convo.query()
//        query!.fromLocalDatastore()
//        
//        query.whereKey(GROUP_KEY, equalTo: self)
//        var subConvos: [Convo] = query.findObjects() as! [Convo]
//        println("\(subConvos.count) convos in the selected group")
//        
//        
//        return subConvos
//    }
    
    // MARK: - Networking
    
//    func saveToNetwork() {
//        
//        var groupObject = PFObject(className: "Group")
//        groupObject["name"] = self.name
//        groupObject["parent"] = self.parentId
//        groupObject.saveInBackgroundWithBlock {
//            (success: Bool, error: NSError!) -> Void in
//            if (success) {
//                NSLog("Saved new group to the network")
//            }
//            else {
//                NSLog("Failed to save new group: %@", error.description)
//            }
//        }
//    }
//    
//    // MARK: - Core Data
//    
//    func saveToCore() {
//        
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        
//        let managedContext = appDelegate.managedObjectContext!
//        
//        let entity = NSEntityDescription.entityForName("Group", inManagedObjectContext: managedContext)
//        
//        let mgdGroup = ManagedGroup(entity: entity!, insertIntoManagedObjectContext: managedContext)
//        
//        self.assignValuesToManagedObject(mgdGroup)
//                
//        var error: NSError?
//        if !managedContext.save(&error) {
//            println("Could not save \(error), \(error?.userInfo)")
//        }
//    }
//    
//    func assignValuesToManagedObject(mgdGroup: ManagedGroup) {
//        mgdGroup.pfId = self.objectId
//        mgdGroup.name = self[NAME_KEY] as! String
//        
//        // TODO: parentGroup, childBlurbs
//    }
//    
//    class func groupsFromNSManagedObjects(objects: [NSManagedObject]) -> [Group] {
//        
//        var groups: [Group] = []
//        
//        for obj in objects {
//            var group = Group()
//
//            group.setValue(obj.valueForKey(NAME_KEY), forKey: NAME_KEY)
//            
//            // TODO: parent group
//            
//            groups.append(group)
//        }
//        
//        return groups
//    }
//    
}
