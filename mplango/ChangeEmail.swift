//
//  ChangeEmail.swift
//  mplango
//
//  Created by Thomas Petit on 05/11/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit

class ChangeEmail: UIViewController, UITextFieldDelegate {
    
//    var user: User!
    
    @IBOutlet weak var currentEmail: UITextField!
    @IBOutlet weak var newEmail: UITextField!
    @IBOutlet weak var confNewEmail: UITextField!
    
    @IBOutlet weak var confirmBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveLoggedUser()
        
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
        
//        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//        let email: String = prefs.objectForKey("USEREMAIL") as! String
//        let fetchRequest = NSFetchRequest(entityName: "User")
//        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
//        
//        if let fetchResults = (try? moContext?.executeFetchRequest(fetchRequest)) as? [User] {
//            user = fetchResults[0];
//        }
        
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
