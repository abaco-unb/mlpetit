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
    
    let baseURL:String = "http://server.maplango.com.br"
    
    func request(url: String, callback:(NSDictionary) -> ()) {
        let nsUrl = NSURL(string: url)
        let task = NSURLSession.sharedSession().dataTaskWithURL(nsUrl!) {
            (data, response, error) in
            NSLog("@sucesso %@", (data?.description)!)
            do {
                let response = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                print(response)
                
                callback(response)
                
            }
            catch let error as NSError {
                print("ERRO NA INTEGRACAO : ", error.localizedDescription, error.debugDescription ,  separator: " ")
            }
        }
        task.resume()
    }
    
    //    func makeHTTPPostRequest(path: String, body: [String: AnyObject], callback: ServiceResponse) {
    //        var err: NSError?
    //        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
    //
    //        // Set the method to POST
    //        request.HTTPMethod = "POST"
    //
    //        // Set the POST body for the request
    //        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: nil, error: &err)
    //        let session = NSURLSession.sharedSession()
    //
    //        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
    //            let json:JSON = JSON(data: data)
    //            onCompletion(json, err)
    //        })
    //        task.resume()
    //    }
    
    
    
    func getBaseURL()->String {
        return self.baseURL
    }
}