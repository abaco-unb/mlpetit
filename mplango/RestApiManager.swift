//
//  RestApiManager.swift
//  mplango
//
//  Created by Bruno on 13/11/15.
//  Copyright © 2015 unb.br. All rights reserved.
//

import Foundation


//typealias ServiceResponse = (JSON, NSError?) -> Void

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    
    let baseURL = "http://server.maplango.com.br"
    
    func makeHTTPGetRequest(url: String, callback:(NSDictionary) -> ()) {
        let nsUrl = NSURL(string: url)
        NSLog("@view URL %@", url)
        let task = NSURLSession.sharedSession().dataTaskWithURL(nsUrl!) {
            (data, response, error) in
            NSLog("@sucesso retorno HTTH %@", (response?.description)!)
            //NSLog("@sucesso DATA:  %@", (data)!)
            //print(response)
            
            do {
                let response = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                callback(response)
                
            }
            catch let error as NSError {
                print("ERRO NA INTEGRACAO : ", error.localizedDescription, error.debugDescription ,  separator: " ")
            }
        }
        task.resume()
    }
    
    func getBaseURL()->String {
        return self.baseURL
    }
}