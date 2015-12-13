//
//  LoginViewController.swift
//  mplango
//
//  Created by Bruno Ferreira on 12/05/15.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    
    var users = [User]()
    var restPath = "http://server.maplango.com.br/user-rest"
    var userCollection = [RUser]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldUsername.backgroundColor = UIColor.clearColor()
        textFieldUsername.layer.borderWidth = 3.0
        textFieldUsername.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        textFieldUsername.attributedPlaceholder =
            NSAttributedString(string: "Email ou nom d'utilisateur", attributes:[NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        textFieldPassword.backgroundColor = UIColor.clearColor()
        textFieldPassword.layer.borderWidth = 3.0
        textFieldPassword.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        textFieldPassword.attributedPlaceholder =
            NSAttributedString(string: "Mot de passe", attributes:[NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        
            }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        
    }
    
    //Text field delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
        
    
    override func viewDidAppear(animated: Bool) {
        //self.performSegueWithIdentifier("goto_map", sender: self)
        
    }
    
//    func getJsonDataUser() {
//        
//        var url = NSURL(string: urlPath)
//        
//        var session = NSURLSession.sharedSession()
//        var task = session.dataTaskWithURL(url!,
//            completionHandler: {
//                data,
//                response,
//                error -> Void in
//                
//                print("Task completed")
//                
//                if(error != nil) {
//                    print(error!.localizedDescription)
//                }
//                var err: NSError?
//                
//                var results = NSJSONSerialization.JSONObjectWithData(data!,
//                    options: NSJSONReadingOptions.MutableContainers) as NSArray
//                
//                if(err != nil) {
//                    print("JSON Error \(err!.localizedDescription)")
//                }
//                
//                println("\(results.count) JSON rows returned and parsed into an array")
//                
//                if (results.count != 0) {
//                    // For this example just spit out the first item "event" entry
//                    var rowData: NSDictionary = results[0] as NSDictionary
//                    var deviceValue = rowData["device"] as String;
//                    println("Got \(deviceValue) out")
//                } else {
//                    println("No rows returned")
//                }
//        })
//        
//        task.resume()
//    }
    func unwrap(any:Any) -> Any {
        
        let mi = Mirror(reflecting: any)
        if mi.displayStyle != .Optional {
            return any
        }
        
        if mi.children.count == 0 { return NSNull() }
        let (_, some) = mi.children.first!
        return some
        
    }
    
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
            print(userCollection)
        }
        
    }
    func getRemoteUser(callback:(NSDictionary)->()) {
        request(self.restPath, callback: callback)
    }
    
    func request(url: String, callback:(NSDictionary) -> ()) {
        let nsUrl = NSURL(string: url)
        let task = NSURLSession.sharedSession().dataTaskWithURL(nsUrl!) {
            (data, response, error) in
            //NSLog("@sucesso %@", (response?.description)!)
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
    
    @IBAction func loginTapped(sender: UIButton) {
        
        let username:String = textFieldUsername.text!
        let password:String = textFieldPassword.text!
        
        if ( username.isEmpty || password.isEmpty ) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Login falhou!"
            alertView.message = "É necessário inserir seu email e senha"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
        } else {
            
            let service = UserRestService()
            service.getList()
            var u:RUser?
            print(service.userCollection.count)
            for user in service.userCollection {
                if((user.name == username || user.email == username) && user.password == password){
                    u = user
                    print("achou os dados do cara")
                }
            }
            let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let contxt: NSManagedObjectContext = appDel.managedObjectContext!
            let fetchRequest = NSFetchRequest(entityName: "User")
            let predicate = NSPredicate(format: "name == %@ && password == %@", username, password)
            fetchRequest.predicate = predicate
            
            if let fetchResults = (try? contxt.executeFetchRequest(fetchRequest)) as? [User] {
                
                if (fetchResults.count > 0) {
                    
                    NSLog("@Id :  %@",fetchResults[0].id)
                    //let id = Int(fetchResults[0].id)
                    
                    
                    //let remoteUser:RUser = service.get(String(fetchResults[0].id))
                    
                    //print(remoteUser)
                    
                    let email: String = fetchResults[0].email
                    let pwd: String   = fetchResults[0].password
                    
                    NSLog("login autenticado: %ld", email)
                    NSLog("pwd autenticada: %ld", pwd)
                    
                    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    //prefs.setObject(fetchResults[0], forKey: "USER")
                    //prefs.setObject(fetchResults[0] as MUser, forKey: "USER")
                    prefs.setObject(fetchResults[0].name, forKey: "USERNAME")
                    prefs.setObject(fetchResults[0].email, forKey: "USEREMAIL")
                    prefs.setInteger(1, forKey: "ISLOGGEDIN")
                    prefs.synchronize()
                    
                    self.performSegueWithIdentifier("goto_map", sender: self)
                
                } else {
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "Login falhou!"
                    alertView.message = "Usuário ou senha inexistente no banco de dados!"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
                
            }
        }
    }
    
    func fetchUser() {
        let fetchRequest = NSFetchRequest(entityName: "User")
        let sortDescriptor = NSSortDescriptor(key: "email", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext!
        if let fetchResults = (try? contxt.executeFetchRequest(fetchRequest)) as? [User] {
            users = fetchResults
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
