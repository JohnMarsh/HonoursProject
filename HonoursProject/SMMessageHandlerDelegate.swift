//
//  SMMessageHandlerDelegate.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-03-02.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation

@objc protocol SMMessageHandlerDelegate{
    func didReceivePost(post : SMPost)
    optional func didReceiveHeartbeat()
}