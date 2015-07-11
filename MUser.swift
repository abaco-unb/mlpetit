//
//  MUser.swift
//  mplango
//
//  Created by Carlos Wagner Pereira de Morais on 09/07/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import Foundation
import CoreData

class MUser: NSManagedObject {

    @NSManaged var email: String
    @NSManaged var gender: String
    @NSManaged var image: NSData
    @NSManaged var name: String
    @NSManaged var nationality: String
    @NSManaged var password: String

}
