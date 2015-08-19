//
//  User.swift
//  mplango
//
//  Created by Bruno Ferreira on 11/05/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//
import CoreData
import Foundation

class Post: NSManagedObject {
    @NSManaged var text:String
    @NSManaged var audio:String
    @NSManaged var video:String
    @NSManaged var latitude:Double
    @NSManaged var longitude:Double
    @NSManaged var category:NSNumber
    @NSManaged var locationName:String
    @NSManaged var user:NSManagedObject
    
}