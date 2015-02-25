//
//  SMMessageHandlerProtocol.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-02-09.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation

protocol SMMessageReceiverProtocol {
    func handleMessage(message : SMMessage)
    func handlerMessageType() -> String
}
