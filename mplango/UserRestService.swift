//
//  UserRestService.swift
//  mplango
//
//  Created by Bruno on 13/11/15.
//  Copyright © 2015 unb.br. All rights reserved.
//

import Foundation

class UserRestService: AnyObject {
    
    static let sharedInstance = UserRestService()
    
    let sufixURL = "/user-rest"
    var userCollection = [RUser]()
    
    func loadUser(users:NSArray) {
        
        for user in users {
            let id = Int(user["id"]!!.description)
            let name = user["name"]!!.description
            let email = user["email"]!!.description
            let password = user["password"]!!.description
            let gender = user["gender"]!!.description
            let nationality = user["nationality"]!!.description
            let image = user["image"]!!.description
            let levelId = Int(user["level"]!!["id"]!!.description)
            
            let rUser = RUser(id: id!, email: email, name: name, gender: gender, password: password, nationality: nationality, image: image, level: levelId!)
            userCollection.append(rUser);
            print(rUser.name)
        }
        
    }
    
    func getList() -> [RUser] {
        let url = RestApiManager.sharedInstance.getBaseURL() + self.sufixURL
        RestApiManager.sharedInstance.makeHTTPGetRequest(url , callback:{(response) in self.loadUser(response["data"] as! NSArray)})
        return userCollection;
    }
    
    func get(id: String) -> RUser {
        let url = RestApiManager.sharedInstance.getBaseURL() + self.sufixURL + "/" + id
        RestApiManager.sharedInstance.makeHTTPGetRequest(url , callback:{(response) in self.loadUser(response["data"] as! NSArray)})
        return userCollection[0];
    }
    
    func create() -> RUser {
        return userCollection[0];
    }
    
    func update() -> RUser {
        return userCollection[0];
    }
    
    func delete() -> RUser {
        return userCollection[0];
    }
}
