//
//  CarnetViewController.swift
//  mplango
//
//  Created by Thomas Petit on 06/08/2015.
//  Copyright (c) 2015 unb.br. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON

class CarnetViewController: UIViewController, UITextViewDelegate {
    
    
    //MARK: Properties
    
    
    var item: Carnet? = nil
    
    var restPath = "http://server.maplango.com.br/note-rest"
    var indicator:ActivityIndicator = ActivityIndicator()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBOutlet weak var removeImage: UIButton!
    @IBOutlet weak var mediaView: UIView!
    
    
    //Outlets dos textos
    @IBOutlet weak var itemWordTxtView: UITextView!
    @IBOutlet weak var itemDescTxtView: UITextView!
    
    
    //Outlets da photoAudioView (quando o item do Carnet inclui uma foto e eventualmente, ao mesmo tempo, um audio)

    @IBOutlet weak var photoAudioView: UIView!
    @IBOutlet weak var itemPhoto: UIImageView!
    
    @IBOutlet weak var backgroundRecord: UIView!
    @IBOutlet weak var listenBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var audioTimerLabel: UILabel!
    
  
    //Outlets da AudioView (quando o item do Carnet inclui apenas um audio)
    
    @IBOutlet weak var AudioView: UIView!
    @IBOutlet weak var listenBtn2: UIButton!
    @IBOutlet weak var stopBtn2: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize.height = 300
        
        if item != nil {
            itemWordTxtView.text = item?.word
            itemDescTxtView.text = item?.desc
            navigationItem.title = item!.word
            //itemPhoto.image = item?.photo
        }
        
        itemDescTxtView.delegate = self
        itemWordTxtView.delegate = self
        
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
        
        removeImage.hidden = true
        
        self.indicator.showActivityIndicator(self.view)
        let params : [String: AnyObject] = [
            "word" : "",
            "desc" : "",
            "photo" : ""
        ]
        Alamofire.request(.GET, self.restPath, parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                if (error == nil) {
                    self.indicator.hideActivityIndicator();
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("seeItem", sender: self)
                    }
                }
            })

    }
    
    // MARK : Actions
        
        
    @IBAction func edit(sender: AnyObject) {
        
        if editBtn.title == "Confirmer" {
            
            itemWordTxtView.editable = false
            itemDescTxtView.editable = false
            removeImage.hidden = true
            editBtn.title = "Éditer"
            itemDescTxtView.textColor = UIColor(hex: 0x9E9E9E)
            itemWordTxtView.textColor = UIColor(hex: 0x9E9E9E)
            navigationItem.hidesBackButton = false
            navigationItem.title = "Carnet"
            
        } else {
            
            editItemCarnet()
        }
        
    }
    
    
    @IBAction func removeMedia(sender: AnyObject) {
        
        mediaView.hidden = true
        removeImage.hidden = true
        
    }

    
    func editItemCarnet() {
        
        item?.word = itemWordTxtView.text!
        item?.desc = itemDescTxtView.text!
        
        itemWordTxtView.editable = true
        itemDescTxtView.editable = true
        
        if mediaView.hidden == false {
            removeImage.hidden = false
            removeImage.enabled = true
        }
        
        itemWordTxtView.textColor = UIColor.darkGrayColor()
        itemDescTxtView.textColor = UIColor.darkGrayColor()
        
        //falta poder modificar foto
        //falta poder modificar som
        
        editBtn.title = "Confirmer"
        
        navigationItem.hidesBackButton = true
        
//        do {
//            
//            try moContext?.save()
//            
//        } catch _ {
//        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        editItemCarnet()
        
        let limitLength = 149
        guard let text = textView.text else { return true }
        let newLength = text.characters.count - range.length
        
        return newLength <= limitLength
        
    }

    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        //To adjust the height of TextView to its content
        
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

