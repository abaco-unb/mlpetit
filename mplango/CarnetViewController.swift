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
    
    
    var item: Carnet? = nil
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    //Outlets dos textos
    
    @IBOutlet weak var itemWordLabel: UILabel!
    @IBOutlet weak var itemDescTxtView: UITextView!
    
    
    //Outlets da photoAudioView (quando o item do Carnet inclui uma foto e eventualmente, ao mesmo tempo, um audio)

    @IBOutlet weak var photoAudioView: UIView!
    @IBOutlet weak var itemPhoto: UIImageView!
    
    @IBOutlet weak var backgroundRecord: UIView!
    @IBOutlet weak var listenBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    
  
    //Outlets da AudioView (quando o item do Carnet inclui apenas um audio)
    
    @IBOutlet weak var AudioView: UIView!
    @IBOutlet weak var listenBtn2: UIButton!
    @IBOutlet weak var stopBtn2: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize.height = 300

        
        if item != nil {
            itemWordLabel.text = item?.word
            itemDescTxtView.text = item?.desc
            navigationItem.title = item!.word
            //itemPhoto.image = item?.photo
        }
        
        
        
        photoAudioView.layer.borderWidth = 1
        photoAudioView.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        photoAudioView.layer.cornerRadius = 10
        photoAudioView.layer.masksToBounds = true
        
        backgroundRecord.layer.backgroundColor = UIColor(hex: 0xFFFFFF).CGColor
        backgroundRecord.layer.masksToBounds = true
        
        
        
        AudioView.layer.borderWidth = 1
        AudioView.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        AudioView.layer.cornerRadius = 10
        AudioView.layer.masksToBounds = true
        
        /*
        
        //Hides and disables Save Button in reading mode.
        navigationItem.rightBarButtonItem?.enabled = false
        navigationItem.rightBarButtonItem?.title = nil
            
        }
        */
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()

        
        }


    override func viewDidAppear(animated: Bool) {

    }
    

    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        
        //To adjust the height of TextField to its content
        
        let contentSize = self.itemDescTxtView.sizeThatFits(self.itemDescTxtView.bounds.size)
        var frame = self.itemDescTxtView.frame
        frame.size.height = contentSize.height
        self.itemDescTxtView.frame = frame
        
        let aspectRatioTextViewConstraint = NSLayoutConstraint(item: self.itemDescTxtView, attribute: .Height, relatedBy: .Equal, toItem: self.itemDescTxtView, attribute: .Width, multiplier: itemDescTxtView.bounds.height/itemDescTxtView.bounds.width, constant: 1)
        self.itemDescTxtView.addConstraint(aspectRatioTextViewConstraint)
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

