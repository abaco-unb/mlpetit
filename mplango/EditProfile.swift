//
//  EditProfile.swift
//  mplango
//
//  Created by Thomas Petit on 05/11/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit

class EditProfile: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    
    
    var users = [User]()
    var restPath = "http://server.maplango.com.br/user-rest"
    var userId:Int!
    
    var imagePath: String = ""
    
    var indicator:ActivityIndicator = ActivityIndicator()

    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var profPicture: UIImageView!
    @IBOutlet weak var userGender: UISegmentedControl!
    @IBOutlet weak var confirmEditProf: UIBarButtonItem!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userNation: UITextField!
    @IBOutlet weak var userBio: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        print("self.userId : ", self.userId)
        self.upServerUser()

        
//        print("user data")
//        print(user.name)
//        print(user.nationality)
//        print(user.gender)
//        
//        userName.attributedPlaceholder =
//            NSAttributedString(string: user.name, attributes: [NSForegroundColorAttributeName : UIColor(hex: 0x9E9E9E)])
//        
//        userNation.attributedPlaceholder =
//            NSAttributedString(string: user.nationality, attributes: [NSForegroundColorAttributeName : UIColor(hex: 0x9E9E9E)])
        
//        userGender.selectedSegmentIndex = NSAttributedString(string: user.gender)

        scroll.contentSize.height = 200
        
        // Enable the Save button only if the screen has a valid change
        checkValidChange()
        
        // Keyboard stuff.
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        profPicture.layer.cornerRadius = 40
        profPicture.layer.masksToBounds = true
        
        userGender.layer.borderWidth = 3
        userGender.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        userGender.layer.cornerRadius = 20
        userGender.layer.masksToBounds = true
    }

    //MARK: Actions
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
 
    
    @IBAction func confirmEditProf(sender: AnyObject) {
//        dismissViewControllerAnimated(false, completion: nil)
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userId:Int = prefs.integerForKey("id") as Int
        
        let params : [String: String] = [
            "photo" : self.imagePath,
            "name" : self.userName.text!,
            "nationality" : self.userNation.text!,
            "bio" : self.userBio.text!,
            "user": String(userId)
//            "gender" : userGender.selectedSegmentIndex,
        ]
        
        Alamofire.request(.POST, self.restPath, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                if (error == nil) {
                    self.indicator.hideActivityIndicator();
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("go_to_profile", sender: self)
                    }
                }
            })
        
    }
    
    func retrieveLoggedUser() {
        
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        NSLog("usuário logado: %ld", userId)
        
    }
    
    
    //MARK: UIScrollView moves up (textField) when keyboard appears
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        
        var contentInset:UIEdgeInsets = self.scroll.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scroll.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsetsZero
        self.scroll.contentInset = contentInset
    }
    
    func upServerUser() {
        self.indicator.showActivityIndicator(self.view)
        
        let params : [String: Int] = [
            "id": self.userId,
            "name": self.userId,
            "gender": self.userId,
            "nationality": self.userId
        ]
        
        //Checagem remota
        Alamofire.request(.GET, self.restPath, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                self.indicator.hideActivityIndicator();
                let user = json["data"]
                print(user);
                //                if let photo = user["image"].string {
                //                    print("photo de perfil : ", photo)
                //                    let imgUtils:ImageUtils = ImageUtils()
                //                    self.profilePicture.image = imgUtils.loadImageFromPath(photo)!
                //                }
                
                if let username = user["name"].string {
                    print("show name : ", username)
                    self.userName.attributedPlaceholder = NSAttributedString(string: username)
                }
                
                if let nat = user["nationality"].string {
                    print("show nationality : ", nat)
                    self.userNation.attributedPlaceholder = NSAttributedString(string: nat)
                }
                
                if let gen = user["gender"].string {
                    print("show gender : ", gen)
                    if gen == "Homme" {
                        self.userGender.selectedSegmentIndex = 0
                    }
                    else if gen == "Femme" {
                        self.userGender.selectedSegmentIndex = 1
                    }
                }
                
            });
        
    }

    
    
    // MARK : Image Picker Process
    
    var picker:UIImagePickerController? = UIImagePickerController()
    var popover:UIPopoverPresentationController? = nil

    
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        
        //Hide the keyboard
        userName.resignFirstResponder()
        userNation.resignFirstResponder()
        userBio.resignFirstResponder()
        
        let alert:UIAlertController=UIAlertController(title: "Choisir une image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cameraAction = UIAlertAction(title: "Caméra", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallerie", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Cancel)
            {
                UIAlertAction in
        }
        
        // Add the actions
        picker?.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            popover = UIPopoverPresentationController(presentedViewController: alert, presentingViewController: alert)
            popover?.sourceView = self.view
            popover?.barButtonItem = navigationItem.rightBarButtonItem
            popover?.permittedArrowDirections = .Any
            
        }
        
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            openGallary()
        }
    }
    
    func openGallary() {
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            popover = UIPopoverPresentationController(presentedViewController: picker!, presentingViewController: picker!)
            
            popover?.sourceView = self.view
            popover?.barButtonItem = navigationItem.rightBarButtonItem
            popover?.permittedArrowDirections = .Any
            
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        profPicture.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("picker cancel.")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: enable confirm button
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        confirmEditProf.enabled = false
    }
    
    func checkValidChange() {
        // Disable the Save button if the text field is empty.
        let text = userName.text ?? ""
        let text2 = userNation.text ?? ""
        let text3 = userBio.text ?? ""
        
        if (!text.isEmpty) {
            confirmEditProf.enabled = true
        
        } else if (!text2.isEmpty) {
            confirmEditProf.enabled = true

        } else if (!text3.isEmpty) {
            confirmEditProf.enabled = true
            
        } else {
            confirmEditProf.enabled = false
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidChange()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(scroll, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(scroll, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if confirmEditProf === sender {
            //let word = wordTextField.text ?? ""
            //let desc = descTextField.text ?? ""
            let photo = profPicture.image
            //let category = segment
            //falta som
            
            
        }
        
        
    }
    */
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}

