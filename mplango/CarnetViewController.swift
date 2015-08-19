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
    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    //MARK: Properties
    
    @IBOutlet weak var itemWordLabel: UILabel!
    @IBOutlet weak var itemDescLabel: UILabel!
    @IBOutlet weak var itemPhoto: UIImageView!
    
    var item: Carnet? = nil


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if item != nil {
            itemWordLabel.text = item?.word
            itemDescLabel.text = item?.desc
            navigationItem.title = item!.word
        }
        
        /*
        
        //Hides and disables Save Button in reading mode.
        navigationItem.rightBarButtonItem?.enabled = false
        navigationItem.rightBarButtonItem?.title = nil
            
        }
        */
        
        // Custom the visual identity of Image View
        itemPhoto.layer.borderWidth = 1
        itemPhoto.layer.borderColor = UIColor(hex: 0x3399CC).CGColor
        itemPhoto.layer.cornerRadius = 12
        itemPhoto.layer.masksToBounds = true
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

