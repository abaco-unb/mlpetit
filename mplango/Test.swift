//
//  Task.swift
//  mplango
//
//  Created by Thomas Petit on 03/06/2016.
//  Copyright © 2016 unb.br. All rights reserved.
//

import Foundation

class Test: NSObject {
    var id:Int
    var desc:String
    var level:Int
    var ownerName: String
    var ownerId: Int
    var status: String
    
    init(id:Int, desc: String, level: Int, ownerName: String, ownerId: Int, status: String) {
        self.id = id
        self.desc = desc
        self.level = level
        self.ownerName = ownerName
        self.ownerId = ownerId
        self.status = status
    }

    static let LEVEL_2 = 1
    static let LEVEL_3 = 2
    static let LEVEL_4 = 3
    static let LEVEL_M = 4
    
    static let SENT = "Sent"
    static let SUCCESS = "Success"
    static let FAILED = "Failed"
    
}