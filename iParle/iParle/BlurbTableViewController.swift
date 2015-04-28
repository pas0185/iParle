//
//  BlurbTableViewController.swift
//  ProCom
//
//  Created by Meshach Joshua on 2/22/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class BlurbTableViewController: JSQMessagesViewController {
    
    var mgdBlurbs = [ManagedBlurb]()
    var convo: ManagedConvo?

    var refreshControl:UIRefreshControl!
    var lastMessageTime: NSDate?
    var notificationTime = NSDate()
    
    var refreshTime = NSTimer()
    var avatars = [String: JSQMessagesAvatarImage]()

    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: 148/255, green: 34/255, blue: 50/255.0, alpha: 1))
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.grayColor())
    
    init(convo: ManagedConvo) {
        super.init(nibName: nil, bundle: nil)
        
        self.convo = convo
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Loading Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = PFUser.currentUser()!.objectId!
       
        self.automaticallyScrollsToMostRecentMessage = true
        collectionView.collectionViewLayout.springinessEnabled = true

        
        //refreshing the blurbs
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Getting Blurbs!")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)
        
        //Added a settings button to navbar
        var settingsImage = UIImage(named: "settingsicon.png")
        var settingButton: UIBarButtonItem = UIBarButtonItem(image: settingsImage, style: .Plain, target: self, action: "settingsButtonClicked")
        self.navigationItem.rightBarButtonItem = settingButton
        
        self.navigationItem.title = convo?.name
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.fetchBlurbs()
    }
    
    func didReceiveRemoteNotification(userInfo: [NSObject: AnyObject]) {
        self.fetchBlurbs()
    }
    
    //MARK: - User Controls
    
    func refresh(sender:AnyObject)
    {
        self.collectionView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func settingsButtonClicked(){
        // TODO: fix settings page configuration
        var settingsPage = ConvoSettingsViewController(convo: convo!)
        self.navigationController!.pushViewController(settingsPage, animated: true)
    }
    
    //MARK: - Blurb handling
    
    func fetchBlurbs() {
        if let convoId = self.convo?.pfId {
            
            // CoreData fetching blurbs
            CoreDataManager.sharedInstance.fetchBlurbs(convoId, completion: {
                (blurbs) -> Void in
                
                println("Fetched \(blurbs.count) Blurbs from Core Data")
                self.mgdBlurbs = blurbs
                
                
                var existingBlurbIds = [String]()
                for blurb in self.mgdBlurbs {
                    existingBlurbIds.append(blurb.pfId)
                }
            
                
                // Networking fetching Blurbs
                NetworkManager.sharedInstance.fetchNewBlurbs(convoId, existingBlurbIds: existingBlurbIds, completion: {
                    (blurbs: [Blurb]) in
                    
                    // Received new Blurbs from the network
                    println("BlurbTableView received \(blurbs.count) new Blurbs from Network")
                    
                    // Save new Blurbs to Core Data
                    CoreDataManager.sharedInstance.saveNewBlurbs(blurbs, completion: {
                        (newMgdBlurbs: [ManagedBlurb]) -> Void in
                        
                        println("Finished saving \(newMgdBlurbs.count) new Blurbs to Core Data. Now adding to TableView")
                        
                        // Add new *converted* Convos to the TableView Data Source
                        self.mgdBlurbs.extend(newMgdBlurbs)
                        
                        self.finishReceivingMessage()
                        self.collectionView.reloadData()
                        
                    })
                })
            })
        }
        
        
    }
    
    func sendMessage(text: String) {
        
        if let convoId = self.convo?.pfId {
            
            // Push new Blurb to the Network
            NetworkManager.sharedInstance.saveNewBlurb(text, convoId: convoId, completion: {
                (blurb: Blurb) -> Void in
                
                // Save it to Core Data
                CoreDataManager.sharedInstance.saveNewBlurbs([blurb], completion: {
                    (newMgdBlurbs: [ManagedBlurb]) -> Void in
                    
                    // Append to the current View
                    self.mgdBlurbs.extend(newMgdBlurbs)
                    self.finishSendingMessage()
                    self.collectionView.reloadData()

                })

                println("Notifying other members that new message was sent")
                self.pushNotifyOtherMembers(text)
            })
        }
    }
    
    func pushNotifyOtherMembers(message: String) {
        
        if let c = self.convo {
            
            if let channel = c.getChannelName() {
                let data = NSMutableDictionary()
                data.setObject(1, forKey: "content-available")
                data.setObject("Increment", forKey: "badge")
                data.setObject(PFUser.currentUser()!.username! + " in " + c.name + " says: " + message, forKey: "alert")
                data.setObject(PFUser.currentUser()!.objectId!, forKey: "senderObjectId")
                data.setObject(c.pfId, forKey: "convoObject" )
                data.setObject("default", forKey: "sound")
                
                println("Sending PFPush for new message: \(message)")
                
                let push = PFPush()
                push.setChannel(channel)
                push.setData(data as [NSObject : AnyObject])
                push.sendPushInBackgroundWithBlock {
                    (success, error) -> Void in
                    if (success) {
                        println("successfully notified other members")
                    }
                    else {
                        println("failed to send push notification to other members")
                    }
                }
            }
            else {
                println("failed to send push notification to other members; failed to get channel name for convo")
            }
        }
        else {
            println("Failed to push notify other members, Convo object not found for this view")
        }
    }

    //#MARK: - Setting up Blurbs
    
    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
        if let stringUrl = imageUrl {
            if let url = NSURL(string: stringUrl) {
                if let data = NSData(contentsOfURL: url) {
                    let image = UIImage(data: data)
                    let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
                    let avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: diameter)
                    avatars[name] = avatarImage
                    return
                }
            }
        }
        
        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
        setupAvatarColor(name, incoming: incoming)
    }
    
    func setupAvatarColor(name: String, incoming: Bool) {
        
        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        
        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        let nameLength = count(name)
        let initials : String? = name.substringToIndex(advance(PFUser.currentUser()!.username!.startIndex, min(2, nameLength)))
        let userImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
        
        avatars[name] = userImage
    }
    
    
    func receivedMessagePressed(sender: UIBarButtonItem) {
        
        // Simulate reciving message
        showTypingIndicator = !showTypingIndicator
        scrollToBottomAnimated(true)
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        println("Camera pressed!")
    }

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.sendMessage(text)
        finishSendingMessage()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return self.mgdBlurbs[indexPath.item]
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let blurb = self.mgdBlurbs[indexPath.item]
        
        if blurb.userId == PFUser.currentUser()!.objectId {
            return outgoingBubbleImageView
        }
        
        return incomingBubbleImageView
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let blurb = self.mgdBlurbs[indexPath.item]
        if let avatar = avatars[blurb.username]{
            return avatar
        }
        else {
            var picURL = blurb.userPic()
            println("Found facebook pic URL for blurb: \(picURL)")
            setupAvatarImage(blurb.username, imageUrl: picURL, incoming: true)
            return avatars[blurb.username]
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.mgdBlurbs.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView.textColor = UIColor.whiteColor()
        
        let blurb = self.mgdBlurbs[indexPath.row]
        
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        
        return cell
    }
    
    
    // View  usernames above bubbles
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let blurb = self.mgdBlurbs[indexPath.row];
        
        // Sent by me, skip
        if blurb.userId == PFUser.currentUser()!.objectId {
            return nil;
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousblurb = self.mgdBlurbs[indexPath.item - 1];
            if previousblurb.userId == blurb.userId {
                return nil;
            }
        }
        
        return NSAttributedString(string:blurb.username)
    }
    
    
    //Decideds where the blurb should be located ie. left or right side of the view
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {

        if let blurb = self.mgdBlurbs[indexPath.item] as ManagedBlurb? {
            
            // Sent by me, skip
            if blurb.userId == PFUser.currentUser()!.objectId {
                return CGFloat(0.0);
            }
            
            // Same as previous sender, skip
            if indexPath.item > 0 {
                if let previousblurb = self.mgdBlurbs[indexPath.item - 1] as ManagedBlurb? {
                    if previousblurb.userId == blurb.userId {
                        return CGFloat(0.0);
                    }
                }
            }
        
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}
