//
//  GroupTableViewController.swift
//  iParle
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit
import CoreData

class GroupTableViewController: UITableViewController, UIAlertViewDelegate {

    var group: ManagedGroup?
    
    var mgdGroups = [ManagedGroup]()
    var mgdConvos = [ManagedConvo]()
    
    var groupActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var convoActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // MARK: - Initialization
    
    init(group: ManagedGroup?) {
        super.init(style: UITableViewStyle.Grouped)

        self.group = group
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Fetch Data
        self.fetchConvos()
        self.fetchGroups()
        
        // Logo on Navigation Bar
        let image = UIImage(named: "parlé-logo")
        let imageView = UIImageView(image: image)
        navigationItem.titleView = imageView
        
        // Bar button for New Group
        var addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addGroupButtonClicked")
        self.navigationItem.rightBarButtonItem = addButton
        
        //Changing the look of the view
        self.view.backgroundColor = UIColor.blackColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        //First time opening the app?
        let userDefaults = NSUserDefaults()
        if userDefaults.boolForKey("HasLaunchedOnce"){
            //Do nothing
        }
        else{
            userDefaults.setBool(true, forKey: "HasLaunchedOnce")
            userDefaults.synchronize()
            self.showFirstTimeAlert()
        }
    }
    
    func fetchConvos() {
        
        // Convos from Core Data
        self.convoActivityIndicator.startAnimating()
        CoreDataManager.sharedInstance.fetchConvos(forGroup: self.group) {
            (convos: [ManagedConvo]) in
            
            println("Received from CoreDataManager: \(convos.count) Convos")
            
            // Assign these convos and reload TableView
            self.mgdConvos = convos
            self.tableView.reloadData()
            
            
            // Build array of existing Convo Ids
            var existingConvoIds = [String]()
            if self.mgdConvos.count > 0 {
                println("mgdConvos.count is >0. Adding existing IDs")
                for convo in self.mgdConvos {
                    existingConvoIds.append(convo.pfId)
                }
            }
            
            // Look for new convos on the network (in the background)
            NetworkManager.sharedInstance.fetchNewConvos(forGroup: self.group, existingConvoIds: existingConvoIds, user: PFUser.currentUser()!, completion: {
                (convos: [Convo]) in
                
                // Received new convos from the network
                println("GroupTableView received \(convos.count) new Convos from network")
                
                // Save new Convos to Core Data
                CoreDataManager.sharedInstance.saveNewConvos(convos, completion: {
                    (newMgdConvos: [ManagedConvo]) -> Void in
                    
                    println("Finished saving new convos to Core Data. Now adding to TableView")
                    
                    // Add new *converted* Convos to the TableView Data Source
                    self.mgdConvos.extend(newMgdConvos)
                    self.tableView.reloadData()
                })
                
                self.convoActivityIndicator.stopAnimating()
            })
        }
    }
    
    func fetchGroups() {
        
        // Groups from Core Data
        self.groupActivityIndicator.startAnimating()
        CoreDataManager.sharedInstance.fetchGroups(forGroup: self.group) {
            (groups: [ManagedGroup]) in
            
            println("Received from CoreDataManager: \(groups.count) groups")
            
            // Assign these groups and reload TableView
            self.mgdGroups = groups
            self.tableView.reloadData()
            
            // Look for new Groups on the network (in the background)

            var groupId: String = "0"
            if let g = self.group {
                groupId = g.pfId
            }
            
            
            // Build array of existing Group Ids
            var existingGroupIds = [String]()
            if self.mgdGroups.count > 0 {
                println("mgdGroups.count is >0. Adding existing IDs")
                for group in self.mgdGroups {
                    existingGroupIds.append(group.pfId)
                }
            }
            
            println("Going to fetch new Groups from Network under groupId=\(groupId), ignoring existing groupIds=\(existingGroupIds)\n")
            NetworkManager.sharedInstance.fetchNewGroups(groupId, existingGroupIds: existingGroupIds, completion: {
                (groups: [Group]) in
                
                // Received new convos from the network
                println("GroupTableView received \(groups.count) new Groups from Network\nGoing to save in Core Data")
                
                // Save new Convos to Core Data
                CoreDataManager.sharedInstance.saveNewGroups(groups, completion: {
                    (newMgdGroups: [ManagedGroup]) -> Void in
                    
                    println("Saved \(newMgdGroups.count) new groups in Core Data")
                    // Add new *converted* Groups to the TableView Data Source
                    self.mgdGroups.extend(newMgdGroups)
                    self.tableView.reloadData()
                })
                
                self.groupActivityIndicator.stopAnimating()
            })
        }
    }
    
    // MARK: - Push Data
    
    func addGroupButtonClicked() {

        self.promptChooseGroupOrConvoCreation()
    }
    
    func promptChooseGroupOrConvoCreation() {
        
        // Prompt user to create a new convo or new group
        let alert = UIAlertController(title: "Start Something New", message: "Would you like to start a new Group or a new Convo?", preferredStyle: UIAlertControllerStyle.Alert)

        // Configure alert actions
        var newGroupAction = UIAlertAction(title: "New Group", style: .Default, handler: {(alertAction:UIAlertAction!) in
            self.promptGroupCreation()
        })
        
        var newConvoAction = UIAlertAction(title: "New Convo", style: .Default, handler: {(alertAction:UIAlertAction!) in
            self.promptConvoCreation()
        })
        
        var cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        // Add actions to alert
        alert.addAction(newGroupAction)
        alert.addAction(newConvoAction)
        alert.addAction(cancelAction)
        
        // Display alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func promptGroupCreation() {
        
        // Prompt user for name of new group
        let alert = UIAlertController(title: "Create New Group", message: "Enter a name for your group", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            
            textField.autocapitalizationType = .Words
            textField.autocorrectionType = .Yes
        
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler:{ (alertAction:UIAlertAction!) in
            let textField = alert.textFields![0] as! UITextField
            let groupname = textField.text
            println("User wants to create new group named: \(groupname)")

            // Build new Group
            var newGroup = Group()
            if let name = groupname,
                parentGroupId = self.group?.pfId {

                newGroup["name"] = name
                newGroup["parentGroupId"] = parentGroupId

                // Save it to the Network
                NetworkManager.sharedInstance.saveNewGroup(newGroup, completion: {
                    (group) -> Void in
                    
                    // On success, save it to Core Data
                    CoreDataManager.sharedInstance.saveNewGroups([group], completion: {
                        (newMgdGroups) -> Void in
                        
                        // Add the newly created Group to this view's list
                        self.mgdGroups.extend(newMgdGroups)
                        self.tableView.reloadData()
                    })
                })
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
  
    func promptConvoCreation() {
        
        // Prompt user for name of new convo
        let alert = UIAlertController(title: "Create New Convo", message: "Enter a name for your convo", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            
            textField.autocapitalizationType = .Words
            textField.autocorrectionType = .Yes
            
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler:{ (alertAction:UIAlertAction!) in
            let textField = alert.textFields![0] as! UITextField
            let convoName = textField.text
            println("User wants to create a convo named: \(convoName)")
            
            // Build new Convo
            var newConvo = Convo()
            if let name = convoName,
                parentGroupId = self.group?.pfId {
                    
                    newConvo["name"] = name
                    newConvo["parentGroupId"] = parentGroupId
                    var relation = newConvo.relationForKey("users")
                    relation.addObject(PFUser.currentUser()!)
                    
                    // Save it to the Network
                    NetworkManager.sharedInstance.saveNewConvo(newConvo, completion: {
                        (convo) -> Void in
                        
                        // On success, save it to Core Data
                        CoreDataManager.sharedInstance.saveNewConvos([convo], completion: {
                            (newMgdConvos) -> Void in
                            
                            // Add the newly created Group to this view's list
                            self.mgdConvos.extend(newMgdConvos)
                            self.tableView.reloadData()
                        })
                    })
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func sendPushToMembers() {
        var query = PFInstallation.query()
        query!.whereKey("deviceType", equalTo: "ios")
        var error = NSErrorPointer()
        PFPush.sendPushMessageToQuery(query, withMessage: "TEST MESSAGE", error: error)
        
        if error != nil {
            println("Error sending push to members")
        }
        else {
            println("Successfully sent push to members")
        }
        
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if section == GROUP_TABLE_VIEW_SECTION {
            
            return self.mgdGroups.count
        }

        if section == CONVO_TABLE_VIEW_SECTION {
            
            return self.mgdConvos.count
        }
        
        return 0
    }
    
    func isHomeGroup(group: ManagedGroup) -> Bool {
        
        return (group.name == "home" && group.parentGroupId == "0")
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        
        cell.backgroundColor = UIColor.blackColor()
        cell.selectionStyle = UITableViewCellSelectionStyle.Gray
        
        if indexPath.section == GROUP_TABLE_VIEW_SECTION {
            
            if let groupAtRow = self.mgdGroups[indexPath.row] as ManagedGroup? {
                
                cell.textLabel?.text = groupAtRow.name
                cell.textLabel?.textColor = UIColor(red: 165/255.0, green: 126/255.0, blue: 195/255.0, alpha: 1.0)
                cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
                cell.textLabel?.textAlignment = NSTextAlignment.Center
                
                
                // If at the root screen (containng only 'Home' group),
                // set the NavController's root view to be the group view with Home (displaying it's children)
                if self.isHomeGroup(groupAtRow) {
                    
                    var groupView = GroupTableViewController(group: groupAtRow)
                    self.navigationController!.pushViewController(groupView, animated: false)
                }
                
            }
        }
        
        else if indexPath.section == CONVO_TABLE_VIEW_SECTION {
            
            if let name = self.mgdConvos[indexPath.row].name {
                cell.textLabel?.text = name
                cell.textLabel?.textColor = UIColor(red: 165/255.0, green: 126/255.0, blue: 195/255.0, alpha: 1.0)
                cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
                cell.textLabel?.textAlignment = NSTextAlignment.Center
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == GROUP_TABLE_VIEW_SECTION {
            
            // Selected a Group
            
            var selectedGroup = self.mgdGroups[indexPath.row]
            
            var groupView = GroupTableViewController(group: selectedGroup)
            
            self.navigationController!.pushViewController(groupView, animated: true)
        }
        
        else if indexPath.section == CONVO_TABLE_VIEW_SECTION {
            
            // Seleted a Convo
            
            var selectedConvo = self.mgdConvos[indexPath.row]

            var convoView = BlurbTableViewController(convo: selectedConvo)
            
            self.navigationController!.pushViewController(convoView, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return TABLE_HEADER_HEIGHT
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, TABLE_HEADER_HEIGHT))
        var activityWidth = self.groupActivityIndicator.frame.width
        var activityFrame = CGRectMake(view.frame.width - activityWidth - 14, 0, activityWidth, view.frame.height)
        
        if section == GROUP_TABLE_VIEW_SECTION && self.mgdGroups.count > 0 {
            var label = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, TABLE_HEADER_HEIGHT))
            label.text = "Groups"
            label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            label.textColor = UIColor(red: 165/255.0, green: 126/255.0, blue: 195/255.0, alpha: 1.0)
            label.textAlignment = NSTextAlignment.Center
            view.addSubview(label)
            
            self.groupActivityIndicator.frame = activityFrame
            view.addSubview(self.groupActivityIndicator)
        }
        
        else if section == CONVO_TABLE_VIEW_SECTION && self.mgdConvos.count > 0 {
            
            var label = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, TABLE_HEADER_HEIGHT))
            label.text = "Convos"
            label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            label.textColor = UIColor(red: 165/255.0, green: 126/255.0, blue: 195/255.0, alpha: 1.0)
            label.textAlignment = NSTextAlignment.Center
            view.addSubview(label)
            
            self.convoActivityIndicator.frame = activityFrame
            view.addSubview(self.convoActivityIndicator)
        }
        
        return view
    }
    
    //MARK: User Friendly
    
    func showFirstTimeAlert(){
        // Prompt user to create a new convo or new group
        let alert = UIAlertController(title: "Start Something New", message: "Start by creating a new group!", preferredStyle: UIAlertControllerStyle.Alert)
        
        // Configure alert actions
        var newGroupAction = UIAlertAction(title: "New Group", style: .Default, handler: {(alertAction:UIAlertAction!) in
            self.promptGroupCreation()
        })
        
        var cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        // Add actions to alert
        alert.addAction(newGroupAction)
        alert.addAction(cancelAction)
        
        // Display alert
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
