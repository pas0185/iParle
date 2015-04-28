//
//  Message.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class Blurb: PFObject, PFSubclassing {

    
    // Computed properties
    var pfId: String {
        return self.objectId!
    }
    
    var convoId: String {
        return self["convoId"] as! String
    }
    
    var text: String {
        return self["text"] as! String
    }
    
    var userId: String {
        return self["userId"] as! String
    }
    
    var username: String {
        return self["username"] as! String
    }
    
    class func parseClassName() -> String {
        return "Blurb"
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    override init() {
        super.init()
    }
}