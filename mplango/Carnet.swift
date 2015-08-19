//
//  Carnet.swift
//  mplango
//
//  Created by Thomas Petit on 14/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import Foundation
import CoreData

class Carnet: NSManagedObject {
    @NSManaged var word:String
    @NSManaged var desc:String
    @NSManaged var photo:NSData
    @NSManaged var category:NSNumber
    @NSManaged var user:NSManagedObject
}
