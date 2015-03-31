//
//  FirstViewController.swift
//  HonoursProject
//
//  Created by John Marsh on 2014-11-20.
//  Copyright (c) 2014 John Marsh. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class NoticeBoardViewController: UIViewController, SMManagerConnectionDelegate, UITableViewDelegate,UITableViewDataSource, SMPublicBoardDelegate {
    
    
    @IBOutlet var tableView: UITableView!
    
    var manager : SMManager!
    var board : SMPublicBoard!

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = SMManager.shared
        manager.connectionDelegate = self
        manager.start()
        board = manager.publicBoard
        board.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressPost(sender: AnyObject) {
        let alertController = UIAlertController(title: "Create Post", message: "", preferredStyle: .Alert)
        let postAction = UIAlertAction(title: "Post", style: .Default) { (_) in
            let postTextField = alertController.textFields![0] as UITextField
            self.board.postTextToBoard(postTextField.text)
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Text"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                postAction.enabled = textField.text != ""
            }
        }
        
        alertController.addAction(postAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func didReceivePrivateInvitationFromPeer(user : SMPeer!, invitationHandler: ((Bool) -> Void)!){
        let alertController = UIAlertController(title: "Invitation Received", message: "\(user.guid) woudl like to connect.", preferredStyle: .Alert)
        
        let inviteAction = UIAlertAction(title: "Accept", style: .Default) { (_) in
           invitationHandler(true)
        }
        
        let cancelAction = UIAlertAction(title: "Decline", style: .Default) { (_) in
            invitationHandler(false)
        }
        
        alertController.addAction(inviteAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
 
    }
    
    func startedAdvertisingSelf(){
        
    }
    func stoppedAdvertisingSelf(){
        
    }
    func startedBroswingForPeers(){
        
    }
    func stoppedBrowsingForPeers(){
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return board.posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("SMPostText", forIndexPath: indexPath) as UITableViewCell
        var post = board.posts[indexPath.row] as SMPost
        cell.textLabel?.text = post.textContent
        return cell
    }
    
    func receivedNewPost(post: SMPost) {
        ^{
            self.tableView.reloadData()
        }
    }


}

