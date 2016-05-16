//
//  User.swift
//  mplango
//
//  Created by Bruno Ferreira on 11/05/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//
import Foundation

class User: NSObject {
    let id : Int = 0
    let email:String = ""
    let gender:String = ""
    let name:String = ""
    let nationality:String = ""
    let password:String = ""
    let image:String = ""
    let profile:NSNumber = 0.0
    let posts:NSSet = []
    let users:NSSet = []
    
    static let BEGINNER = 1
    static let HIGH_BEGINNER = 2
    static let INTERMEDIATE = 3
    static let ADVANCED = 4
    static let MEDIATOR = 5
    
}