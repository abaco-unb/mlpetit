//
//  Carnet.swift
//  mplango
//
//  Created by Thomas Petit on 14/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import Foundation

class Carnet: NSObject {
    let id : Int!
    let word : String
    let text : String
    let image : String
    let audio : String
    
    init(id:Int, word:String, text:String, image:String, audio:String) {
            self.id = id
            self.word = word
            self.text = text
            self.image = image
            self.audio = audio
    }
}
