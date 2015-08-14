//
//  CarnetAddVC.swift
//  mplango
//
//  Created by Thomas Petit on 06/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class CarnetAddVC: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    //MARK: Properties
    
    @IBOutlet var wordTextField: UITextField!
    @IBOutlet var descTextField: UITextField!
    @IBOutlet var photoImage: UIImageView!
    @IBOutlet weak var saveWordButton: UIBarButtonItem!
    
    
    var item: Carnet? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        wordTextField.delegate = self
        descTextField.delegate = self
        
        
        if item != nil {
            wordTextField.text = item?.word
            
        }
        
        
        // Enable the Save button only if the text field has a valid Word name
        checkValidWordName()
        
        
        
        // Custom the visual identity of Text Fields
        wordTextField.backgroundColor = UIColor.clearColor()
        wordTextField.layer.borderWidth = 1
        wordTextField.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        wordTextField.attributedPlaceholder =
            NSAttributedString(string: "Entrer un nom (obligatoire)", attributes:[NSForegroundColorAttributeName : UIColor.grayColor()])
        
        descTextField.backgroundColor = UIColor.clearColor()
        descTextField.layer.borderWidth = 1
        descTextField.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        descTextField.attributedPlaceholder =
            NSAttributedString(string: "Intégrer un commentaire (facultatif)", attributes:[NSForegroundColorAttributeName : UIColor.grayColor()])
        
        // Custom the visual identity of Image View
        photoImage.layer.borderWidth = 1
        photoImage.layer.borderColor = UIColor(hex: 0x3399CC).CGColor
        photoImage.layer.cornerRadius = 12
        photoImage.layer.masksToBounds = true
        
        
    }

    
    //MARK: Actions

    
    @IBAction func saveWordButton(sender: AnyObject) {
        if item != nil {
            editItemCarnet()
        } else {
            createItemCarnet()
        }
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        //Hide the keyboard
        wordTextField.resignFirstResponder()
        descTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library
        let imagePickerController = UIImagePickerController ()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .PhotoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
        
        
    }
    
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        //Dismiss the picker if the user canceled
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[NSObject : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //Set photoImageView to display the selected image
        photoImage.image = selectedImage
        
        //Dismiss the picker
        dismissViewControllerAnimated(true, completion: nil)
        
    }

    
    // MARK:- Create Item Carnet
    
    func createItemCarnet() {
        let entityDescription = NSEntityDescription.entityForName("Carnet", inManagedObjectContext: moContext!)
        let item = Carnet(entity: entityDescription!, insertIntoManagedObjectContext: moContext)
        item.word = wordTextField.text
        item.desc = descTextField.text
        //falta foto
        //falta som
        moContext?.save(nil)
    
    }
    
    // MARK:- Edit Item Carnet
    
    func editItemCarnet() {
        item?.word = wordTextField.text
        item?.desc = descTextField.text
        //falta foto
        //falta som
        moContext?.save(nil)
    }
    
    
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        saveWordButton.enabled = false
    }
    
    func checkValidWordName() {
        // Disable the Save button if the text field is empty.
        let text = wordTextField.text ?? ""
        saveWordButton.enabled = !text.isEmpty
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidWordName()
        navigationItem.title = wordTextField.text
    }
    

    // MARK: - Navigation

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if saveWordButton === sender {
            let word = wordTextField.text ?? ""
            let desc = descTextField.text ?? ""
            let photo = photoImage.image
            //falta som
            

            
        }
        
        
    }
    
    

}
