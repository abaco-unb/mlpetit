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
    
    
    var item: Carnet!
    
    var restPath = "http://server.maplango.com.br/note-rest"
    var userId:Int!
    
    var indicator:ActivityIndicator = ActivityIndicator()
    
    var imagePath: String = ""
    
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
    
    @IBOutlet weak var audioInPhotoView: UIView!
  
    //Outlets da AudioView (quando o item do Carnet inclui apenas uma mídia audio (sem imagem))
    
    @IBOutlet weak var AudioView: UIView!
    @IBOutlet weak var listenBtn2: UIButton!
    @IBOutlet weak var stopBtn2: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveLoggedUser()
        print("self.userId : ", self.userId)
        
        scrollView.contentSize.height = 300
        
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
        
        self.navigationItem.title = item.word

        //para mostrar os dados do item já carregados pela tableview
        itemWordTxtView.text = item.word
        itemDescTxtView.text = item.text
        let imgUtils:ImageUtils = ImageUtils()
        self.itemPhoto.image = imgUtils.loadImageFromPath(item.image)
        
        //falta o audio (criar no servidor)
        
        
        //Mostrar ou não as Media View em função do conteúdo no servidor (se tem imagem e/ou som)
        if (itemPhoto.image == nil) {
            photoAudioView.hidden = true
        } else {
            photoAudioView.hidden = false
        }
        
        if (itemPhoto.image != nil /* || audio != nil */) {
            photoAudioView.hidden = false
            audioInPhotoView.hidden = false
        }else {
            photoAudioView.hidden = true
            audioInPhotoView.hidden = true
        }
        
        //Com o audio na verdade tem que fazer a mesma coisa que com a imagem: se não tem audio no arquivo, a view não aparece
        AudioView.hidden = true
        
        if (AudioView.hidden == true || photoAudioView.hidden == true) {
            mediaView.hidden = true
        }
        
        removeImage.hidden = true
        
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
    
    
    func retrieveLoggedUser() {
        
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        NSLog("usuário logado: %ld", userId)
        
    }
    
    @IBAction func removeMedia(sender: AnyObject) {
        
        mediaView.hidden = true
        removeImage.hidden = true
        
    }

    
    func editItemCarnet() {
        
        //Coisas de interface
        
        itemWordTxtView.editable = true
        itemDescTxtView.editable = true
        
        if mediaView.hidden == false {
            removeImage.hidden = false
            removeImage.enabled = true
        }
        
        itemWordTxtView.textColor = UIColor.darkGrayColor()
        itemDescTxtView.textColor = UIColor.darkGrayColor()
        
        editBtn.title = "Confirmer"
        
        navigationItem.hidesBackButton = true
        
        
        //Alamofire PUT para editar
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userId:Int = prefs.integerForKey("id") as Int
        print("atualizando o item do carnet...")
        print(self.itemWordTxtView.text)
        print(self.itemDescTxtView.text)
        print(self.imagePath)
        print(userId)
        
        let params : [String: String] = [
            "word" : self.itemWordTxtView.text!,
            "text" : self.itemDescTxtView.text!,
            "image" : self.imagePath,
        ]
        
        //AQUI TEM QUE TROCAR O USER ID PELO ID DO NOTE??
        let urlEdit :String = restPath + "?id=" + String(userId)
        
        Alamofire.request(.PUT, urlEdit , parameters: params)
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                if (error == nil) {
                    self.indicator.hideActivityIndicator();
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("edit_carnet", sender: self)
                    }
                    
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //New Alert Ccontroller
                        let alertController = UIAlertController(title: "Oops", message: "Tivemos um problema ao tentar atualizar seu item. Favor tente novamente.", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            print("The carnet update is not okay.")
                            self.indicator.hideActivityIndicator();
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                
            })

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

