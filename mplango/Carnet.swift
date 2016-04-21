//
//  Carnet.swift
//  mplango
//
//  Created by Thomas Petit on 14/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import Foundation

class Carnet {
    let word : String
    let text : String
    let image : String
    let audio : String
    let user : Int!
    
        init(dictionary : [String : AnyObject]) {
            word = dictionary["word"] as? String ?? ""
            text = dictionary["text"] as? String ?? ""
            image = dictionary["image"] as? String ?? ""
            audio = dictionary["audio"] as? String ?? ""
            user = dictionary["id"] as? Int
    }
}
