//
//  RUser.swift
//  mplango
//
//  Created by Bruno on 12/11/15.
//  Copyright © 2015 unb.br. All rights reserved.
//

import Foundation

class RUser {
    
    var id:Int
    var email:String
    var gender:String
    var name:String
    var nationality:String
    var password:String
    var image:String
    var level:Int
    
    init(id:Int, email: String, name: String, gender: String, password: String, nationality: String, image: String, level: Int) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.gender = gender
        self.nationality = nationality
        self.image = image
        self.level = level
        
    }
    
    func toJSON() {
        
    }
}