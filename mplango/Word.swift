//
//  Word.swift
//  mplango
//
//  Created by Thomas Petit on 08/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit

class Word {
    
    //MARK Properties
    
    
    var name:String
    var description: String
    var photo: UIImage?
    
    
    
    //MARK: Initialization
    
    init?(name: String, description: String, photo: UIImage?) {
        
        //Initialize stored properties
        self.name = name
        self.photo = photo
        self.description = description
        
        // Initialization should fail if there is no name.
        if name.isEmpty {
            return nil
        }
        
    }
    
}
