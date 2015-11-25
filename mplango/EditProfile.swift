//
//  EditProfile.swift
//  mplango
//
//  Created by Thomas Petit on 05/11/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class EditProfile: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    
    var user: User!
    

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
        print("user data")
        print(user.name)
        print(user.nationality)
        print(user.gender)
        
        
        //import data from user
        
        userName.attributedPlaceholder =
            NSAttributedString(string: user.name, attributes: [NSForegroundColorAttributeName : UIColor(hex: 0x9E9E9E)])
        
        userNation.attributedPlaceholder =
            NSAttributedString(string: user.nationality, attributes: [NSForegroundColorAttributeName : UIColor(hex: 0x9E9E9E)])
        
        //userGender.selectedSegmentIndex = NSAttributedString(string: user.gender)
        


        scroll.contentSize.height = 200

        
        
        // Keyboard stuff.
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        

        
        // Custom the visual identity of Image View
        
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
    
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        //Hide the keyboard
        //wordTextField.resignFirstResponder()
        //descTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library
        let imagePickerController = UIImagePickerController ()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .PhotoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
        
        
    }
    
    
    func retrieveLoggedUser() {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let email: String = prefs.objectForKey("USEREMAIL") as! String
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        if let fetchResults = (try? moContext?.executeFetchRequest(fetchRequest)) as? [User] {
            user = fetchResults[0];
            
        }
        
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
    
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        //Dismiss the picker if the user canceled
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //Set photoImageView to display the selected image
        profPicture.image = selectedImage
        
        //Dismiss the picker
        dismissViewControllerAnimated(true, completion: nil)
        
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

