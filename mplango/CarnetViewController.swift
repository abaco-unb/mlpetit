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
    
    @IBOutlet weak var backgroundRecord: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var itemWordLabel: UILabel!
    @IBOutlet weak var itemPhoto: UIImageView!
    @IBOutlet weak var itemDescLabel: UITextView!
    @IBOutlet weak var listenBtn: UIButton!
    @IBOutlet weak var listenSlowBtn: UIButton!
    
    var item: Carnet? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize.height = 300

        
        if item != nil {
            itemWordLabel.text = item?.word
            itemDescLabel.text = item?.desc
            navigationItem.title = item!.word
            //itemPhoto.image = item?.photo
        }
        
        backgroundRecord.layer.borderWidth = 1
        backgroundRecord.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        backgroundRecord.layer.cornerRadius = 15
        backgroundRecord.layer.masksToBounds = true
        
        /*
        
        //Hides and disables Save Button in reading mode.
        navigationItem.rightBarButtonItem?.enabled = false
        navigationItem.rightBarButtonItem?.title = nil
            
        }
        */
        
        }


    override func viewDidAppear(animated: Bool) {
        
        
        

    }
    
    override func viewDidLayoutSubviews() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

