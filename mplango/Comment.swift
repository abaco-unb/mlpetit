//
//  Comment.swift
//  mplango
//
//  Created by Bruno on 16/05/16.
//  Copyright © 2016 unb.br. All rights reserved.
//

import Foundation

class Comment: NSObject {
    let id : Int
    let audio : String
    let text : String
    let image : String
    let postId : Int
    let created: String
    let userId: Int
    let userName: String
    let likes: Int
    let liked: Bool
    
    init(id:Int, audio:String, text:String, image:String, postId: Int, created: String, userId: Int, userName: String, likes: Int, liked: Bool) {
        self.id = id
        self.audio = audio
        self.text = text
        self.image = image
        self.postId = postId
        self.created = created
        self.userId = userId
        self.userName = userName
        self.likes = likes
        self.liked = liked
    }
}