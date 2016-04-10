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

class EditProfile: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate {
    
    
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
    @IBOutlet weak var userBio: UITextView!
    @IBOutlet weak var maxLenghtLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        print("self.userId : ", self.userId)
        self.upServerUser()

        scroll.contentSize.height = 200
        
        // Enable the Save button only if the screen has a valid change
        checkValidChange()
        
        // Keyboard stuff.
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: #selector(EditProfile.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(EditProfile.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        profPicture.layer.cornerRadius = 40
        profPicture.layer.masksToBounds = true
        
        userGender.layer.borderWidth = 3
        userGender.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        userGender.layer.cornerRadius = 20
        userGender.layer.masksToBounds = true
        
        userBio.delegate = self
        
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)

    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n"  // Recognizes enter key in keyboard
        {
            userBio.resignFirstResponder()
            return false
        }
        
        let limitLength = 149
        guard let text = userBio.text else { return true }
        let newLength = text.characters.count - range.length
        
        maxLenghtLabel.text = String(newLength)
        
        if (newLength > 139) {
            maxLenghtLabel.textColor = UIColor.redColor()
        }
            
        else if (newLength < 140) {
            maxLenghtLabel.textColor = UIColor.darkGrayColor()
        }
        
        return newLength <= limitLength
    }
    
    

    //MARK: Actions
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
 
    
    @IBAction func confirmEditProf(sender: AnyObject) {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userId:Int = prefs.integerForKey("id") as Int
        print("atualizando o perfil...")
        print(self.imagePath)
        print(self.userName.text)
        print(self.userNation.text)
        print(self.userBio.text)
        print(userId)
        
        let params : [String: String] = [
            "image" : self.imagePath,
            "name" : self.userName.text!,
            "nationality" : self.userNation.text!,
            "bio" : self.userBio.text!,
            "gender" : String(userGender.selectedSegmentIndex.description)
        ]
        
        let urlEdit :String = restPath + "?id=" + String(userId)
        
        Alamofire.request(.PUT, urlEdit , parameters: params)
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                if (error == nil) {
                    self.indicator.hideActivityIndicator();
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("edit_profile", sender: self)
                    }
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //New Alert Ccontroller
                        let alertController = UIAlertController(title: "Oops", message: "Tivemos um problema ao tentar atualizar seu perfil. Favor tente novamente.", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            print("The profile update is not okay.")
                            self.indicator.hideActivityIndicator();
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
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
        ]
        
        //Checagem remota
        Alamofire.request(.GET, self.restPath, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                self.indicator.hideActivityIndicator();
                let user = json["data"]
                print(user);
                 if let photo = user["image"].string {
                    print("photo de perfil : ", photo)
                    
                    let imgUtils:ImageUtils = ImageUtils()
                    self.profPicture.image = imgUtils.loadImageFromPath(photo)
                 }
                
                if let username = user["name"].string {
                    print("show name : ", username)
                    self.userName.attributedPlaceholder = NSAttributedString(string: username)
                }
                
                if let nat = user["nationality"].string {
                    print("show nationality : ", nat)
                    self.userNation.attributedPlaceholder = NSAttributedString(string: nat)
                }
                
                if let userBio = user["bio"].string {
                    print("show bio : ", userBio)
                    self.userBio.text = (userBio)
                    
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
        
//        var angle = 0.0;
//
//        if profPicture.image?.imageOrientation == UIImageOrientation.Up {
//            angle = 90.0
//        }
        
        // save image in directory
        let imgUtils:ImageUtils = ImageUtils()
        self.imagePath = imgUtils.fileInDocumentsDirectory("profile.png")
        imgUtils.saveImage(profPicture.image!, path: self.imagePath)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("picker cancel.")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    //MARK: enable confirm button
    
    func textViewDidBeginEditing(textView: UITextView) {
        // Disable the Save button while editing.
        confirmEditProf.enabled = false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        confirmEditProf.enabled = false
    }
    
    func checkValidChange() {
        // Disable the Save button if the text field is empty.
        let text = userName.text ?? ""
        let text2 = userNation.text ?? ""
        let text3 = userBio.text ?? ""
        let photo = profPicture.image ?? ""
        
        if (!text.isEmpty) {
            confirmEditProf.enabled = true
        
        } else if (!text2.isEmpty) {
            confirmEditProf.enabled = true

        } else if (!text3.isEmpty) {
            confirmEditProf.enabled = true
            
            
        //VER ISSO: fazer com que o btn confirmar seja operativo qdo for trocada a foto de perfil
        } else if (((photo?.didChangeValueForKey("image")) == nil)) {
            confirmEditProf.enabled = true
            
        } else {
            confirmEditProf.enabled = false
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidChange()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        checkValidChange()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(scroll, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(scroll, name: UIKeyboardWillHideNotification, object: nil)
    }
    
}

