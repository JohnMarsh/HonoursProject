//
//  SMMessageHandler.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-02-09.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation

class SMMessageHandlerDispatch: NSObject {
    
    class var shared : SMMessageHandlerDispatch {
        struct Static {
            static let instance : SMMessageHandlerDispatch = SMMessageHandlerDispatch()
        }
        return Static.instance
    }
    
    var handlers : [String: SMMessageHandlerProtocol]
    
    override init(){
        handlers = [:]
        super.init()
        self.registerHandler(SMHeartbeatHandler())
        self.registerHandler(SMProfileHandler())
        self.registerHandler(SMTextHandler())
        self.registerHandler(SMTypingHandler())
    }
    
    func dispatch(message : SMMessage, forDelegate delegate: SMMessageHandlerDelegate){
        //get the hanlder needed to process this message
        let handler : SMMessageHandlerProtocol = handlers[message.messageType.rawValue]!
        //send the handling to the background
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {handler.handleMessage(message, forDelegate: delegate)})
    }
    
    func registerHandler(handler : SMMessageHandlerProtocol){
            handlers.updateValue(handler, forKey: handler.handlerType())
    }
    
    func unregisterHandler(handler : SMMessageHandlerProtocol){
        handlers.removeValueForKey(handler.handlerType())
    }

}
