//
//  RUser.swift
//  mplango
//
//  Created by Bruno on 12/11/15.
//  Copyright © 2015 unb.br. All rights reserved.
//

import Foundation

class RUser: NSObject {
    
    var id:Int
    var email:String
    var gender:String
    var name:String
    var nationality:String
    var password:String
    var image:String
    var level:Int
    var bio:String
    var badge:Int
    var category: String
    var followers: Int
    var following: Int

    
    init(id:Int, email: String, name: String, gender: String, password: String, nationality: String, image: String, level: Int, bio: String, category: String, followers: Int, following: Int, badge: Int) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.gender = gender
        self.nationality = nationality
        self.image = image
        self.level = level
        self.bio = bio
        self.category = category
        self.followers = followers
        self.following = following
        self.badge = badge
    }
    
//    func toJSON() {
//        
//    }
}
