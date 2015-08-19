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
    
    
    var users = [User]()
    
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
            
            if let fetchResults = contxt.executeFetchRequest(fetchRequest, error: nil) as? [User] {
                
                if (fetchResults.count > 0) {
                    
                    var email: String = fetchResults[0].email
                    var pwd: String   = fetchResults[0].password
                    
                    NSLog("login autenticado: %ld", email)
                    NSLog("pwd autenticada: %ld", pwd)
                    
                    var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    //prefs.setObject(fetchResults[0], forKey: "USER")
                    //prefs.setObject(fetchResults[0] as MUser, forKey: "USER")
                    prefs.setObject(fetchResults[0].name, forKey: "USERNAME")
                    prefs.setObject(fetchResults[0].email, forKey: "USEREMAIL")
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
    
    func fetchUser() {
        let fetchRequest = NSFetchRequest(entityName: "User")
        let sortDescriptor = NSSortDescriptor(key: "email", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext!
        if let fetchResults = contxt.executeFetchRequest(fetchRequest, error: nil) as? [User] {
            users = fetchResults
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
