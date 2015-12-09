//
//  CarnetAddVC.swift
//  mplango
//
//  Created by Thomas Petit on 06/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class CarnetAddVC: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    //MARK: Properties
    
    var item: Carnet? = nil
    
    @IBOutlet weak var saveWordButton: UIBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    //Outlets para o texto
    
    @IBOutlet var wordTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var maxLenghtLabel: UILabel!
    
    
    //Outlets para o audio
    
    @IBOutlet weak var backgroundRecord: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    
    //Outlets para a foto
    
    @IBOutlet var photoImage: UIImageView!
    @IBOutlet weak var addPicture: UIButton!
    @IBOutlet weak var removeImage: UIButton!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize.height = 300
        
        removeImage.hidden = true
        
        // Enable the Save button only if the text field has a valid Word name
        checkValidWordName()
        
        
        // Handle the text field’s user input through delegate callbacks.
        wordTextField.delegate = self
        descTextView.delegate = self
        
        
        if item != nil {
            wordTextField.text = item?.word
        }
        
        
        // Custom the visual identity of Text Fields
        
        wordTextField.attributedPlaceholder =
            NSAttributedString(string: "Entrer un nom (obligatoire)", attributes:[NSForegroundColorAttributeName : UIColor.lightGrayColor()])
        
        
        // Custom the visual identity of Image View
    
        photoImage.layer.cornerRadius = 10
        photoImage.layer.masksToBounds = true
        
        
        // Custom the visual identity of audio player's background

        backgroundRecord.layer.borderWidth = 1
        backgroundRecord.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        backgroundRecord.layer.cornerRadius = 15
        backgroundRecord.layer.masksToBounds = true
        
        
    }
    
  
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        
        //Para determinar um número máximo de caracteres no textview
        
        let limitLength = 149
        guard let text = descTextView.text else { return true }
        let newLength = text.characters.count - range.length
        
        
        //label para contar os caracteres e mostrar em vermelho quando fica perto do limite
        
        maxLenghtLabel.text = String(newLength)
        
        if (newLength > 139)
        {
            maxLenghtLabel.textColor = UIColor.redColor()
        }
        
        
        // para aplicar o limite de caracteres
        return newLength <= limitLength
        
        
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
    
    
    //MARK: Actions Image
    
    
    @IBAction func selectImageFromPhotoLibrary(sender: UIButton) {
        //Hide the keyboard
        wordTextField.resignFirstResponder()
        descTextView.resignFirstResponder()
        
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //Set photoImageView to display the selected image
        photoImage.image = selectedImage
        
        //Dismiss the picker
        dismissViewControllerAnimated(true, completion: nil)
        
        addPicture.hidden = true
        removeImage.hidden = false
        removeImage.enabled = true
        
    }

    @IBAction func removeImage(sender: AnyObject) {
        
        photoImage.image = nil
        addPicture.hidden = false
        addPicture.enabled = true
        removeImage.hidden = true
        
    }
    
    // MARK:- Create and Edit Item Carnet
    
    func createItemCarnet() {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let email: String = prefs.objectForKey("USEREMAIL") as! String
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        if let fetchResults = (try? moContext?.executeFetchRequest(fetchRequest)) as? [User] {
            
            let user: User = fetchResults[0];
            let entityDescription = NSEntityDescription.entityForName("Carnet", inManagedObjectContext: moContext!)
            let item = Carnet(entity: entityDescription!, insertIntoManagedObjectContext: moContext)
            item.word = wordTextField.text!
            item.desc = descTextView.text!
            //item.photo = photoImage.image!
            //item.category = segment
            item.user = user
            do {
                //falta foto
                //falta som
                try moContext?.save()
            } catch _ {
            }

            
        }
    }
    
    func editItemCarnet() {
        item?.word = wordTextField.text!
        item?.desc = descTextView.text!
        do {
            //falta foto
            //falta som
            try moContext?.save()
        } catch _ {
        }
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
    
    /*
    @IBAction func segmentTapped(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            segment = 0
        case 1:
            segment = 1
        default:
            segment = 2
            break
        }
    }
    */
    

    // MARK: - Navigation
    



    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if saveWordButton === sender {
            let word = wordTextField.text ?? ""
            let desc = descTextView.text ?? ""
            let photo = photoImage.image
            //let category = segment
            //falta som
            
            
        }
        
        
    }
    
    

}
