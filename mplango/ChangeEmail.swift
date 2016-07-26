//
//  ChangeEmail.swift
//  mplango
//
//  Created by Thomas Petit on 05/11/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit

class ChangeEmail: UIViewController, UITextFieldDelegate {
    
    var users = [User]()
    var restPath = "http://server.maplango.com.br/user-rest"
    var userId:Int!
    
    var indicator:ActivityIndicator = ActivityIndicator()
    
    @IBOutlet weak var currentEmail: UITextField!
    @IBOutlet weak var newEmail: UITextField!
    @IBOutlet weak var confNewEmail: UITextField!
    
    @IBOutlet weak var confirmBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        print("self.userId : ", self.userId)
        self.upServerUser()
        
        // Enable the Save button only if the screen has a valid change
        checkValidChange()
        
    }
    
    //MARK: Actions
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func confNewEmail(sender: AnyObject) {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userId:Int = prefs.integerForKey("id") as Int
        print("atualizando o email...")
        print(userId)
        
        let email: String = newEmail.text! as String
        let confEmail: String = confNewEmail.text! as String
        
        
        if ( email.isEmpty ) {
            
            //New Alert Ccontroller
            let alertController = UIAlertController(title: "Erro ao tentar Registrar os Dados!", message: "Campo email obrigatório", preferredStyle: .Alert)
            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                print("The user is okay.")
            }
            alertController.addAction(agreeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else if (!email.isEmail()) {
            
            //New Alert Ccontroller
            let alertController = UIAlertController(title: "Erro ao tentar Registrar os Dados!", message: "Por favor, insira um email válido", preferredStyle: .Alert)
            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                print("The user is okay.")
            }
            alertController.addAction(agreeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
            
        } else if (!email.isEmpty  && confEmail.isEmpty) {
            
            //New Alert Ccontroller
            let alertController = UIAlertController(title: "Erro ao tentar Registrar os Dados!", message: "É necessário confirmar sua senha", preferredStyle: .Alert)
            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                print("The user is okay.")
            }
            alertController.addAction(agreeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
        } else if (email != confEmail) {
            
            //New Alert Ccontroller
            let alertController = UIAlertController(title: "Erro ao tentar Registrar os Dados!", message: "O e-mail não confere com a confirmação", preferredStyle: .Alert)
            let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                print("The user is okay.")
            }
            alertController.addAction(agreeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {

        
        let params : [String: String] = [
            "id" : String(userId),
            "email" : self.confNewEmail.text!,
        ]
            
        Alamofire.request(.POST, EndpointUtils.USER, parameters: params)
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                print("Retorno: \(json)")
                if (error == nil) {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        
                        //New Alert Ccontroller
                        let alertController = UIAlertController(title: "Félicitations", message: "Email changé avec succès", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            print("The user is okay.")
                            self.indicator.hideActivityIndicator();
                            self.performSegueWithIdentifier("change_email", sender: self)
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                    }
                
                    
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //New Alert Ccontroller
                        let alertController = UIAlertController(title: "Oops", message: "Tivemos um problema ao tentar atualizar seu e-mail. Favor tente novamente.", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            print("The email update is not okay.")
                            self.indicator.hideActivityIndicator();
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                
            })
            
        }
        
    }
    
    func retrieveLoggedUser() {
        
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        NSLog("usuário logado: %ld", userId)
        
    }
    
    func upServerUser() {
        self.indicator.showActivityIndicator(self.view)
        
        let params : [String: Int] = [
            "id": self.userId,
            ]
        
        //Checagem remota
        Alamofire.request(.GET, EndpointUtils.USER, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                self.indicator.hideActivityIndicator();
                let user = json["data"]
                print(user);
                
                if let email = user["email"].string {
                    print("show email : ", email)
                    self.currentEmail.attributedPlaceholder = NSAttributedString(string: email)
                }
                
            });
        
    }

    
    //MARK: enable confirm button
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        confirmBtn.enabled = false
    }
    
    func checkValidChange() {
        // Disable the Save button if the text field is empty.
        let text = newEmail.text ?? ""
        let text2 = confNewEmail.text ?? ""
        
        confirmBtn.enabled = !text.isEmpty
        confirmBtn.enabled = !text2.isEmpty
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidChange()
    }
    
    
}
