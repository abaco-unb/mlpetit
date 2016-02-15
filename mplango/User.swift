//
//  User.swift
//  mplango
//
//  Created by Bruno Ferreira on 11/05/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//
import CoreData
import Foundation

class User: NSManagedObject {
    
    @NSManaged var id:NSNumber
    @NSManaged var email:String
    @NSManaged var gender:String
    @NSManaged var name:String
    @NSManaged var nationality:String
    @NSManaged var password:String
    @NSManaged var image:String
    @NSManaged var profile:NSNumber
    @NSManaged var posts:NSSet
    @NSManaged var users:NSSet
    
}
