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
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    //MARK: Properties
    
    @IBOutlet weak var WordTextField: UITextField!
    @IBOutlet weak var WordDescriptionTextField: UITextField!
    @IBOutlet weak var WordImage: UIImageView!
    @IBOutlet weak var saveWordButton: UIBarButtonItem!
    
    @IBAction func saveWordButton(sender: AnyObject) {
        createItemCarnet()
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func cancelAddindWord(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func createItemCarnet() {
        let entityDescription = NSEntityDescription.entityForName("Carnet", inManagedObjectContext: managedObjectContext!)
        let item = Carnet(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        item.word = WordTextField.text
        managedObjectContext?.save(nil)
    
    }
    
    //var item = Word?()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        WordTextField.delegate = self
        WordDescriptionTextField.delegate = self
        
        /*
        if let item = item {
            navigationItem.title = item.word
            WordTextField.text = item.word
            WordDescriptionTextField.text = item.desc
            WordImage.image = item.photo
            
        }
        */
        
        // Enable the Save button only if the text field has a valid Word name
        checkValidWordName()
    
            
        
        // Custom the visual identity of Text Fields
        WordTextField.backgroundColor = UIColor.clearColor()
        WordTextField.layer.borderWidth = 1
        WordTextField.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        WordTextField.attributedPlaceholder =
            NSAttributedString(string: "Entrer un nom (obligatoire)", attributes:[NSForegroundColorAttributeName : UIColor.grayColor()])
        
        WordDescriptionTextField.backgroundColor = UIColor.clearColor()
        WordDescriptionTextField.layer.borderWidth = 1
        WordDescriptionTextField.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        WordDescriptionTextField.attributedPlaceholder =
            NSAttributedString(string: "Intégrer un commentaire (facultatif)", attributes:[NSForegroundColorAttributeName : UIColor.grayColor()])
        
        // Custom the visual identity of Image View
        WordImage.layer.borderWidth = 1
        WordImage.layer.borderColor = UIColor(hex: 0x3399CC).CGColor
        WordImage.layer.cornerRadius = 12
        WordImage.layer.masksToBounds = true
        
    
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
        let text = WordTextField.text ?? ""
        saveWordButton.enabled = !text.isEmpty
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidWordName()
        navigationItem.title = WordTextField.text
    }
    

    // MARK: - Navigation

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        /* código usado inicialmente quando tinha 3 telas (com uma de confirmação)
        
        var DestCarnetAddVC : CarnetViewController = segue.destinationViewController as! CarnetViewController
        
        DestCarnetAddVC.WordText = WordTextField.text
        DestCarnetAddVC.LabelText = WordDescriptionTextField.text
        DestCarnetAddVC.WordPhoto = WordImage.image!
        
        */
        
        /*
        if saveWordButton === sender {
            let word = WordTextField.text ?? ""
            let desc = WordDescriptionTextField.text ?? ""
            let photo = WordImage.image
            
            // Set the word to be passed to CarnetTVC after the unwind segue.
            item = Word(word: word, desc: desc, photo: photo)
            
        }
        */
        
    }
    
    //MARK: Actions
        
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        //Hide the keyboard
        WordTextField.resignFirstResponder()
        WordDescriptionTextField.resignFirstResponder()
        
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
        WordImage.image = selectedImage
        
        //Dismiss the picker
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    


    

}
