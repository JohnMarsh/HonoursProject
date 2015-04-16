//
//  SMMessageHandlerProtocol.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-02-09.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation
protocol SMMessageHandlerProtocol {
    func handleMessage(message : SMMessage, forDelegate delegate : SMMessageHandlerDelegate)
    func handlerType() -> String
}
