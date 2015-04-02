//
//  SMUserProfile.swift
//  HonoursProject
//
//  Created by John Marsh on 2015-03-01.
//  Copyright (c) 2015 John Marsh. All rights reserved.
//

import Foundation
import CoreData


class SMUserProfile : NSManagedObject{
  
  @NSManaged  var guid : String
  @NSManaged  var username : String
  @NSManaged  var userDescription : String
  @NSManaged  var imageUrl : String?
    
    override func awakeFromInsert() {
        username = "";
        userDescription = "";
    }

}
