//
//  UserRestService.swift
//  mplango
//
//  Created by Bruno on 13/11/15.
//  Copyright © 2015 unb.br. All rights reserved.
//

import Foundation

class EndpointUtils: AnyObject {
    
    static let instance = EndpointUtils()
    static let ENV = "dev"
    static let SERVER_BASE    = EndpointUtils.ENV == "prod" ? "http://server.maplango.com.br" : "http://localhost:10088/maplango/public"
    static let USER:String    = EndpointUtils.SERVER_BASE + "/user-rest"
    static let POST:String    = EndpointUtils.SERVER_BASE + "/post-rest"
    static let CARNET:String  = EndpointUtils.SERVER_BASE + "/note-rest"
    static let IMAGE:String   = EndpointUtils.SERVER_BASE + "/image-rest"
    static let LIKE:String    = EndpointUtils.SERVER_BASE + "/like-rest"
    static let COMMENT:String = EndpointUtils.SERVER_BASE + "/comment-rest"
    
}