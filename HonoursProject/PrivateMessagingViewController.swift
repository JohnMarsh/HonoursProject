//
//  PrivateSessionViewController.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-03-11.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import UIKit

class PrivateMessagingViewController: JSQMessagesViewController, SMPrivateSessionDelagate, JSQMessagesCollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var navTitle: UINavigationItem!
    
    var privateSession : SMPrivateSession!
    var bubbleImageFactory : JSQMessagesBubbleImageFactory?
    var outgoingBubble : JSQMessagesBubbleImage?
    var incomingBubble : JSQMessagesBubbleImage?
    var picker:UIImagePickerController?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        privateSession.delegate = self
        bubbleImageFactory = JSQMessagesBubbleImageFactory()
        incomingBubble = bubbleImageFactory?.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        outgoingBubble = bubbleImageFactory?.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleOrangeColor())
        picker =  UIImagePickerController()
        picker?.delegate = self
        navTitle.title = privateSession.connectedPeer?.peerID!.displayName ?? "No Name"
        self.view.addSubview(navBar)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return privateSession.posts.count
    }
   
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let post : SMPost = privateSession.posts.objectAtIndex(indexPath.row) as SMPost
        var message : JSQMessage
        if(post.attachmentName != nil && post.attachmentName != ""){
            let image : UIImage = SMResourceManager.getImageForPost(post)
            let photoItem : JSQPhotoMediaItem = JSQPhotoMediaItem(image: image)
            message = JSQMessage(senderId: post.poster.peerID!.displayName, senderDisplayName: post.poster.peerID!.displayName, date: post.timestamp, media: photoItem)
        } else{
              message  = JSQMessage(senderId: post.poster.guid, senderDisplayName: post.poster.guid, date: post.timestamp, text: post.textContent)
        }
        return message
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        
    
        if(cell.textView != nil){
            let post : SMPost = privateSession.posts.objectAtIndex(indexPath.row) as SMPost
            if(post.poster.guid == SMUser.shared.guid){
               cell.textView.textColor = UIColor.whiteColor()
            } else{
                cell.textView.textColor = UIColor.blackColor()
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let post : SMPost = privateSession.posts.objectAtIndex(indexPath.row) as SMPost
        if(post.poster.guid == SMUser.shared.guid){
            return outgoingBubble
        } else{
            return incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    func senderDisplayName() -> String! {
       return SMUser.shared.profile.username
    }
    
    func senderId() -> String! {
       return  SMUser.shared.guid
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        privateSession.sendTextToPeer(text)
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        var alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openCamera()
                
        }
        var gallaryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openPhotoLibrary()
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
            {
                UIAlertAction in
                
        }
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the actionsheet
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(picker!, animated: true, completion: nil)
        }
    }
    
    func openPhotoLibrary(){
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(picker!, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!)
    {
        picker .dismissViewControllerAnimated(true, completion: nil)
       // let url : NSURL = info[UIImagePickerControllerReferenceURL] as NSURL
        let image : UIImage = info[UIImagePickerControllerOriginalImage] as UIImage
        privateSession.sendImageToPeer(image)
       // privateSession.sendResourceAtUrl(url)
        //sets the selected image to image view
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController!)
    {
        println("picker cancel.")
    }
   
    
    func receivedNewPost(post: SMPost) {
        ^{
            self.scrollToBottomAnimated(true)
            self.finishReceivingMessage()
        }
    }
    
    func userHasConnected() {
        
    }
    
    func userHasDisconnected() {
        
    }
    
    override func textViewDidBeginEditing(textView: UITextView) {
        super.textViewDidBeginEditing(textView)
        privateSession.userDidStartTyping()
    }
    
    override func textViewDidEndEditing(textView: UITextView) {
        super.textViewDidEndEditing(textView)
        privateSession.userDidStopTyping()
    }
    
    
    func peerDidStartTyping() {
        ^{
            self.showTypingIndicator = true;
            self.scrollToBottomAnimated(true)
        }
    }
    
    func peerDidStopTyping() {
        ^{
            self.showTypingIndicator = false;
            self.scrollToBottomAnimated(true)
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
