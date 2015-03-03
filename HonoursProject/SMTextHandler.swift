//
//  SMTextHandler.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-02-25.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import UIKit

class SMTextHandler: SMMessageHandlerProtocol {
    
    func handlerType() -> String {
        return   SMMessageType.Text.rawValue
    }
    
    func handleMessage(message: SMMessage, forDelegate delegate : SMMessageHandlerDelegate) {
        println("Handling text with value: ",message.content.objectForKey("text"))
        let post : SMPost = SMPost()
        
    }}
