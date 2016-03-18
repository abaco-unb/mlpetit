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

//        print(user.email)
        
//        currentEmail.attributedPlaceholder =
//            NSAttributedString(string: user.email, attributes: [NSForegroundColorAttributeName : UIColor(hex: 0x9E9E9E)])
    }
    
    //MARK: Actions
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func confNewEmail(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
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
        Alamofire.request(.GET, self.restPath, parameters: params)
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
