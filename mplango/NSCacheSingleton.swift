//
//  CacheUtils.swift
//  mplango
//
//  Created by Bruno on 11/07/16.
//  Copyright © 2016 unb.br. All rights reserved.
//

import Foundation

extension NSCache {
    class var sharedInstance : NSCache {
        struct Static {
            static let instance : NSCache = NSCache()
        }
        return Static.instance
    }
}
