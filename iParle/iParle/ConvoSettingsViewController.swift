//
//  ConvoSettingsViewController.swift
//  ProCom
//
//  Created by Meshach Joshua on 4/7/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class ConvoSettingsViewController: UIViewController {

    var userConvo: ManagedConvo?
    
    init(convo: ManagedConvo) {
        super.init(nibName: nil, bundle: nil)
        self.userConvo = convo
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let addUser = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        addUser.frame = CGRectMake(100, 100, 100, 100)
        addUser.center = self.view.center
        addUser.backgroundColor = UIColor.greenColor()
        addUser.setTitle("Add User", forState: UIControlState.Normal)
        addUser.addTarget(self, action: "addUserButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        self.view.addSubview(addUser)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addUserButtonClicked() {
        
        println("Add user button clicked")
        
        let alert = UIAlertController(title: "Add User to this Convo", message: "Enter your buddy's username", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler:{ (alertAction:UIAlertAction!) in
            let textField = alert.textFields![0] as! UITextField
            let username = textField.text
            println(username)
            
            if let convoId = self.userConvo?.pfId as String!{
                
                self.addUserToConvo(username, convoId: convoId)
            }
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    
    func addUserToConvo(username: String, convoId: String) {
        PFCloud.callFunctionInBackground("addUserToConvoByUsername", withParameters: ["username": username,
            "convoId": convoId]) {
                (result, error) -> Void in
                if error != nil {
                    println("Failed to add user" + error!.localizedDescription)

                }
                else {
                    println("Successfully added user!")
                }
        }
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
