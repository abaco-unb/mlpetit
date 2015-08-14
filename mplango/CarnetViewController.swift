//
//  CarnetViewController.swift
//  mplango
//
//  Created by Thomas Petit on 06/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//


import UIKit
import CoreData

class CarnetViewController: UIViewController {
    
    
    //MARK: Properties
    
    @IBOutlet weak var WordNameLabel: UILabel!
    @IBOutlet weak var WordDescriptionLabel: UILabel!
    @IBOutlet weak var WordSelectedImage: UIImageView!

    
    var LabelText = String ()
    var WordText = String ()
    var WordPhoto = UIImage ()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WordNameLabel.text = WordText
        WordDescriptionLabel.text = LabelText
        WordSelectedImage.image = WordPhoto
        
        
        /*
        if let item = item {
            navigationItem.title = item.word
            WordNameLabel.text = item.word
            WordDescriptionLabel.text = item.desc
            WordSelectedImage.image = item.photo
            
        
        //Hides and disables Save Button in reading mode.
        navigationItem.rightBarButtonItem?.enabled = false
        navigationItem.rightBarButtonItem?.title = nil
            
        }
        */
        
        // Custom the visual identity of Image View
        WordSelectedImage.layer.borderWidth = 1
        WordSelectedImage.layer.borderColor = UIColor(hex: 0x3399CC).CGColor
        WordSelectedImage.layer.cornerRadius = 12
        WordSelectedImage.layer.masksToBounds = true
        }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if saveWord === sender {
            let word = WordNameLabel.text ?? ""
            let desc = WordDescriptionLabel.text ?? ""
            let photo = WordSelectedImage.image
            
            //Set the word to be passed to CarnetTVC after the unwind segue.
            item = Word(word: word, desc: desc, photo: photo)
            
        }

        
    }
    */

}

