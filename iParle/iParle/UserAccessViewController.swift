//
//  UserAccessViewController.swift
//  iParle
//
//  Created by Meshach Joshua on 4/22/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit


class UserAccessViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (PFUser.currentUser() == nil) {
            let fbButton : FBSDKLoginButton = FBSDKLoginButton()
            // User is not signed in yet, display Log In View
            var logInViewController:PFLogInViewController = PFLogInViewController()
            var signUpController:PFSignUpViewController = PFSignUpViewController()
            
            logInViewController.fields = (PFLogInFields.Facebook | PFLogInFields.LogInButton | PFLogInFields.PasswordForgotten | PFLogInFields.UsernameAndPassword | PFLogInFields.SignUpButton)
            logInViewController.delegate = self
            
            let loginImage = UIImage(named: "mainlogo")
            let loginImageView = UIImageView(image: loginImage)
            loginImageView.contentMode = UIViewContentMode.ScaleAspectFit
            logInViewController.logInView!.logo = loginImageView
            logInViewController.logInView?.backgroundColor = UIColor.blackColor()
            
            let signUpImage = UIImage(named: "mainlogo")
            let signUpImageView = UIImageView(image: signUpImage)
            signUpImageView.contentMode = UIViewContentMode.ScaleAspectFit
            logInViewController.signUpController?.signUpView?.logo = signUpImageView
            logInViewController.signUpController?.signUpView?.backgroundColor = UIColor.blackColor()
            
    
            self.navigationController?.presentViewController(logInViewController, animated:true, completion: nil)
        }
        else {
            // User is already signed in. Push the Group View
            
            self.pushHomeGroupView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func pushHomeGroupView() {
        
        println("User Access view is trying to get the Home group")
        
        // Try to get the Home group from Core Data
        CoreDataManager.sharedInstance.fetchGroups(forGroup: nil, completion: {
            (groups) -> Void in
            
            if let mgdHomeGroup = groups.first as ManagedGroup? {
                
                println("User Access found Home group in Core")
                
                // Found a ManagedGroup; this is what we want
                var gtView = GroupTableViewController(group: mgdHomeGroup)
                
                // Create a GroupTVC with the Home group and display it
                self.navigationController?.setViewControllers([gtView], animated: true)
            }
            else {
                // If that fails (first launch/installation?), then go check the Network
                NetworkManager.sharedInstance.fetchNewGroups("0", existingGroupIds: [], completion: {
                    (newGroups) -> Void in

                    if let pfHomeGroup = newGroups.first as Group? {
                        
                        println("User Access found Home group from Parse/Network")
                        
                        // Found a PFGroup, but this is not the format we want
                        
                        // Go save it to Core Data
                        CoreDataManager.sharedInstance.saveNewGroups([pfHomeGroup], completion: {
                            (newMgdGroups) -> Void in
                            
                            if let mgdHomeGroup = groups.first as ManagedGroup? {
                                
                                println("User Access saved the Network Home group in Core")
                                
                                // Found a ManagedGroup; this is what we want
                                var gtView = GroupTableViewController(group: mgdHomeGroup)
                                
                                // Create a GroupTVC with the Home group and display it
                                self.navigationController?.setViewControllers([gtView], animated: true)
                            }
                        })
                    }
                })
            }
        })
    }
    
    // MARK: - PFLogInViewControllerDelegate
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        
        println("Should begin login with username, password. Will return true")
        return true
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        println("logInViewController did log in user, dismiss this VC")
        
        if let fbSession = PFFacebookUtils.session() {

            println("PFFacebookUtils.session() exists")

            if !fbSession.isOpen {
                
                println("PFFacebookUtils.session() is closed. Calling handleDidBecomeActive")
                fbSession.handleDidBecomeActive()
            }
            
        }
        
        var request = FBRequest.requestForMe()
        request.startWithCompletionHandler() {
            (connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
            
            if error == nil {
                
                let parseUser = PFUser.currentUser()
                let userData = result as! NSDictionary
                println("\(userData)")
                
                let name = userData["name"] as! String
                let facebookID = userData["id"] as! String
                let avatar = "https://graph.facebook.com/\(facebookID)/picture"
                
                parseUser?.setObject(name, forKey: "username")
                parseUser?.setObject(facebookID, forKey: "fbId")
                parseUser?.setObject(avatar, forKey: "profilePicture")
                
                parseUser?.save()
                
            }
                
            else {
                println("Facebook Request \(error)")
                println("error.userInfo: \(error.userInfo)")
            }
        }
        
        logInController.dismissViewControllerAnimated(true, completion: nil)
        
        self.pushHomeGroupView()
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        
        println("Failed to log in user: \(error!.localizedDescription)")
    }
    
    // MARK: - PFSignUpViewControllerDelegate
    func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [NSObject : AnyObject]) -> Bool {
        println("Should beging signup")
        return true
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        
        println("Did sign up user")
        
        signUpController.dismissViewControllerAnimated(true, completion: nil)
        
        if self.navigationController?.presentedViewController != nil {
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        self.pushHomeGroupView()
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        println("Failed to sign up user \(error!.localizedDescription)")
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
