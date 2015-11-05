//
//  EditProfile.swift
//  mplango
//
//  Created by Thomas Petit on 05/11/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

class EditProfile: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    
    @IBOutlet weak var profPicture: UIImageView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var confirmEditProf: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Custom the visual identity of Image View
        profPicture.layer.borderWidth = 3
        profPicture.layer.borderColor = UIColor(hex: 0xFFFFFF).CGColor
        profPicture.layer.cornerRadius = 40
        profPicture.layer.masksToBounds = true

        
        segmentControl.layer.borderWidth = 3
        segmentControl.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        segmentControl.layer.cornerRadius = 20
        segmentControl.layer.masksToBounds = true
        
        
        
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

