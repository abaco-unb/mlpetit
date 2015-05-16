//
//  User.swift
//  mplango
//
//  Created by Carlos Wagner Pereira de Morais on 11/05/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

@objc(MUser)
class MUser: NSManagedObject {

    @NSManaged var email:String
    @NSManaged var gender:String
    @NSManaged var name:String
    @NSManaged var nationality:String
    @NSManaged var password:String
    
}
