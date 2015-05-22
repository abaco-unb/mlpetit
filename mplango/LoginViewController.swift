//
//  LoginViewController.swift
//  mplango
//
//  Created by Bruno Ferreira on 12/05/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {

    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.performSegueWithIdentifier("goto_map", sender: self)
    }
    
    @IBAction func loginTapped(sender: UIButton) {
        
        var username:String = textFieldUsername.text
        var password:String = textFieldPassword.text
        
        if ( username.isEmpty || password.isEmpty ) {
            
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Login falhou!"
            alertView.message = "É necessário inserir seu email e senha"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else {
            
            let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let contxt: NSManagedObjectContext = appDel.managedObjectContext!
            let fetchRequest = NSFetchRequest(entityName: "User")
            let predicate = NSPredicate(format: "name == %@ && password == %@", username, password)
            fetchRequest.predicate = predicate
            
            if let fetchResults = contxt.executeFetchRequest(fetchRequest, error: nil) as? [MUser] {
                
                if (fetchResults.count > 0) {
                    
                    var email: String = fetchResults[0].email
                    var pwd: String   = fetchResults[0].password
                    
                    NSLog("login autenticado: %ld", email)
                    NSLog("pwd autenticada: %ld", pwd)
                    
                    var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    //prefs.setObject(fetchResults[0], forKey: "USER")
                    prefs.setObject(fetchResults[0].name, forKey: "USERNAME")
                    prefs.setInteger(1, forKey: "ISLOGGEDIN")
                    prefs.synchronize()
                    
                    self.performSegueWithIdentifier("goto_map", sender: self)
                
                } else {
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "Login falhou!"
                    alertView.message = "Usuário ou senha inexistente no banco de dados!"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
                
            }
        }
    }
    
    var users = [MUser]()
    
    func fetchUser() {
        let fetchRequest = NSFetchRequest(entityName: "User")
        let sortDescriptor = NSSortDescriptor(key: "email", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext!
        if let fetchResults = contxt.executeFetchRequest(fetchRequest, error: nil) as? [MUser] {
            users = fetchResults
        }
    }
    
    func remoteSynch (sender: UIButton) {
        /*
        var username: String = textFieldUsername.text
        var password: String = textFieldPassword.text
        
        var post:NSString = "username=\(username)&password=\(password)"
        
        NSLog("PostData: %@",post);
        
        var url:NSURL = NSURL(string: "http://service.maplango.com/login")!
        
        var postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        
        var postLength:String = String( postData.length )
        
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        
        var reponseError: NSError?
        var response: NSURLResponse?
        
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        
        if ( urlData != nil ) {
        let res = response as! NSHTTPURLResponse!;
        
        NSLog("Response code: %ld", res.statusCode);
        
        if (res.statusCode >= 200 && res.statusCode < 300)
        {
        var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
        
        NSLog("Response ==> %@", responseData);
        
        var error: NSError?
        
        let jsonData:Dictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as NSDictionary
        
        
        let success:NSInteger = jsonData.valueForKey("success") as NSInteger
        
        //[jsonData[@"success"] integerValue];
        
        NSLog("Success: %ld", success);
        
        if(success == 1)
        {
        NSLog("Login SUCCESS");
        
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        prefs.setObject(username, forKey: "USERNAME")
        prefs.setInteger(1, forKey: "ISLOGGEDIN")
        prefs.synchronize()
        
        self.dismissViewControllerAnimated(true, completion: nil)
        } else {
        var error_msg:String
        
        if jsonData["error_message"] as? String != nil {
        error_msg = jsonData["error_message"] as String
        } else {
        error_msg = "Unknown Error"
        }
        var alertView:UIAlertView = UIAlertView()
        alertView.title = "Sign in Failed!"
        alertView.message = error_msg
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
        
        }
        
        } else {
        var alertView:UIAlertView = UIAlertView()
        alertView.title = "Sign in Failed!"
        alertView.message = "Connection Failed"
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
        }
        } else {
        var alertView:UIAlertView = UIAlertView()
        alertView.title = "Sign in Failed!"
        alertView.message = "Connection Failure"
        if let error = reponseError {
        alertView.message = (error.localizedDescription)
        }
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
        }*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
