//
//  PeerViewController.swift
//  HonoursProject
//
//  Created by John Marsh on 2014-12-15.
//  Copyright (c) 2014 John Marsh. All rights reserved.
//

import UIKit

class PeerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SMManagerPeerDelegate {
    
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        SMManager.shared.peerDeleagte = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "privateSessionSegue"){
            var controller = segue.destinationViewController as PrivateSessionViewController
            let indexPath : NSIndexPath = self.tableView.indexPathForSelectedRow()!
            var peer : SMPeer = SMManager.shared.privatePeerList[indexPath.row]
            controller.privateSession = SMManager.shared.privateSessions[peer]
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        let indexPath : NSIndexPath = self.tableView.indexPathForSelectedRow()!
        var peer : SMPeer = SMManager.shared.privatePeerList[indexPath.row]
        if var session = SMManager.shared.privateSessions[peer] {
            return true
        }else{
            let alertController = UIAlertController(title: "Invite to chat?", message: "", preferredStyle: .Alert)
            
            let inviteAction = UIAlertAction(title: "Invite", style: .Default) { (_) in
                SMManager.shared.invitePeerToPrivateSession(peer)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (_) in
            }
            
            alertController.addAction(inviteAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return false
        }
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SMManager.shared.privatePeerList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("SMPeerCell", forIndexPath: indexPath) as UITableViewCell
        var peer : SMPeer = SMManager.shared.privatePeerList[indexPath.row]
        cell.textLabel?.text = peer.peerID.displayName
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func foundNewPeer(peer: SMPeer) {
        ^{
            self.tableView.reloadData()
        }
    }
    
    func lostPeer(peer: SMPeer) {
        ^{
            self.tableView.reloadData()
        }
    }

}
