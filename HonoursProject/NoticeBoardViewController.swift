//
//  FirstViewController.swift
//  HonoursProject
//
//  Created by John Marsh on 2014-11-20.
//  Copyright (c) 2014 John Marsh. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class NoticeBoardViewController: UIViewController, SMManagerDelegate {
    
    var manager : SMManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = SMManager(delegate: self)
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceivePrivateInvitationFromPeer(user : SMPeer!, invitationHandler: ((Bool) -> Void)!){
        
    }


}

