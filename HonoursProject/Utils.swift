//
//  Utils.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-02-25.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation

prefix operator  ^ {}

prefix func ^ (uiUpdate : ()->()){
    dispatch_async(dispatch_get_main_queue(), uiUpdate)
}


prefix operator  ~ {}

prefix func ~ (backgroundTask : ()->()){
    dispatch_async(dispatch_get_global_queue(0, 0), backgroundTask)
}