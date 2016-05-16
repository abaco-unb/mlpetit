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
    
    init(id:Int, audio:String, text:String, image:String, postId: Int) {
        self.id = id
        self.audio = audio
        self.text = text
        self.image = image
        self.postId = postId
    }
}