//
//  Carnet.swift
//  mplango
//
//  Created by Bruno Ferreira on 11/05/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc(Carnet)
class Carnet: NSManagedObject {
    
    @NSManaged var word:String
    @NSManaged var desc:String
    @NSManaged var photo:NSData
    @NSManaged var type:NSInteger
    
}
