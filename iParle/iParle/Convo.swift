//
//  Convo.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let kPFObjectAllKeys = "___PFObjectAllKeys"
let kPFObjectClassName = "___PFObjectClassName"
let kPFObjectObjectId = "___PFObjectId"
let kPFACLPermissions = "permissionsById"

class Convo: PFObject, PFSubclassing {
    
    // Properties that ManagedConvo class uses during conversion
    var pfId: String {
        return self.objectId!
    }
    var parentGroupId: String {
        return self.objectForKey("parentGroupId") as! String
    }
    var name: String {
        return self.objectForKey("name") as! String
    }
    
    
    
    class func parseClassName() -> String {
        return CONVO_CLASS
    }
    
    override init() {
        super.init()
    }
    
    func encodeWithCoder(encoder: NSCoder)  {
        encoder.encodeObject(self.parseClassName, forKey: kPFObjectClassName)
        encoder.encodeObject(self.objectId, forKey:kPFObjectObjectId)
        encoder.encodeObject(self.allKeys(), forKey:kPFObjectAllKeys)
        for key in self.allKeys() as! [String]{
            encoder.encodeObject(self[key], forKey:key)
        }
    }
    
    func initWithCoder(aDecoder: NSCoder!) -> Convo {
        
        // Decode the className and objectId
        var aClassName = aDecoder.decodeObjectForKey(kPFObjectClassName) as! String
        var anObjectId = aDecoder.decodeObjectForKey(kPFObjectObjectId) as! String
        
        var convo = PFObject(withoutDataWithClassName: aClassName, objectId: anObjectId) as! Convo
        
        var allKeys = aDecoder.decodeObjectForKey(kPFObjectAllKeys) as! [String]
        for key in allKeys {
            if let obj: AnyObject = aDecoder.decodeObjectForKey(key) {
                convo[key] = obj
            }
            
        }
        
        return convo
    }
    
    func getChannelName() -> String! {
        
        let objectId = self.objectId
        var channel = "channel" + objectId!
        return channel
    }
    
    func saveToCore() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Convo", inManagedObjectContext: managedContext)
        
        let mgdConvo = ManagedConvo(entity: entity!, insertIntoManagedObjectContext: managedContext)

        self.assignValuesToManagedObject(mgdConvo)

        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    func assignValuesToManagedObject(mgdConvo: ManagedConvo) {
        mgdConvo.pfId = self.objectId
        mgdConvo.name = self[NAME_KEY] as! String

        // TODO: parent group
    }
    
    class func convosFromNSManagedObjects(objects: [NSManagedObject]) -> [Convo] {
        
        var convos: [Convo] = []
        
        for obj in objects {
            var convo = Convo()
//            convo.setValue(obj.valueForKey("pfId"), forKey: OBJECT_ID_KEY)
            convo.setValue(obj.valueForKey(NAME_KEY), forKey: NAME_KEY)
            
            
            // TODO: parent group
            // TODO: users
            
            convos.append(convo)
        }
        
        return convos
    }
    
}


