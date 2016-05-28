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
    var userId:Int!
    var noteId:Int!
    
    var indicator:ActivityIndicator = ActivityIndicator()
    
    var imagePath: String = ""
    var image: UIImage!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBOutlet weak var removeImage: UIButton!
    @IBOutlet weak var mediaView: UIView!
    
    
    //Outlets dos textos
    @IBOutlet weak var itemWordTxtView: UITextView!
    @IBOutlet weak var itemDescTxtView: UITextView!
    @IBOutlet weak var writeHereIndicator: UIImageView!
    
    
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
        
        writeHereIndicator.hidden = true
        
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
        removeImage.hidden = true
        
        print(item.word)
        print(item.text)
        print(item.image)
        
        itemWordTxtView.text = item.word
        itemDescTxtView.text = item.text
        
        print("----***-----");
            print(ImageUtils.instance.loadImageFromPath(item.image));
        print("----***-----");
        
        let image = ImageUtils.instance.loadImageFromPath(item.image)
//        let audio = 
        
        // FOTO SEM ÁUDIO:
        if (!item.image.isEmpty && image != nil /*|| audio == nil*/){
            print("image inneer")
            print(image)
            
            itemPhoto.image = image
            photoAudioView.hidden = false
            audioInPhotoView.hidden = true
            AudioView.hidden = true
        }
        
        // FOTO + ÁUDIO:
//        else if (!item.image.isEmpty && image != nil /*|| !item.audio.isEmpty && audio != nil*/) {
//            photoAudioView.hidden = false
//            audioInPhotoView.hidden = false
//            AudioView.hidden = true
//        }
        
        // ÁUDIO SEM FOTO:
//        else if (!item.audio.isEmpty && audio != nil || image == nil) {
//            photoAudioView.hidden = true
//            audioInPhotoView.hidden = true
//            AudioView.hidden = false
//        }
            
        // NEM FOTO NEM ÁUDIO:
        else if (image == nil /*|| audio == nil*/) {
            photoAudioView.hidden = true
            audioInPhotoView.hidden = true
            AudioView.hidden = true
            mediaView.hidden = true
        }
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CarnetViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        checkValidChange()
        
    }
    
    func retrieveLoggedUser() {
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        NSLog("usuário logado: %ld", userId)
        
    }
    
    
    // MARK : Actions
        
    @IBAction func edit(sender: AnyObject) {
        
        if editBtn.title == "Éditer" {
            
            itemWordTxtView.editable = true
            itemDescTxtView.editable = true
            itemWordTxtView.textColor = UIColor.darkGrayColor()
            itemDescTxtView.textColor = UIColor.darkGrayColor()
            
            let text = itemDescTxtView.text
            
            if text.characters.count >= 1 {
                writeHereIndicator.hidden = true
            } else {
                writeHereIndicator.hidden = false
            }
            
            if mediaView.hidden == false {
                removeImage.hidden = false
                removeImage.enabled = true
            }

            editBtn.title = "Confirmer"
            editBtn.enabled = false
            navigationItem.hidesBackButton = true
            let cancelBtn = UIBarButtonItem(title: "Annuler", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(cancelEdit))
            navigationItem.leftBarButtonItem = cancelBtn
        }
        
        else if editBtn.title == "Confirmer" {
            editItemCarnet()
        }
    }
    
    func cancelEdit(sender: UIBarButtonItem) {
        
        self.itemWordTxtView.editable = false
        self.itemDescTxtView.editable = false
        self.itemDescTxtView.textColor = UIColor(hex: 0x9E9E9E)
        self.itemWordTxtView.textColor = UIColor(hex: 0x9E9E9E)
        
        self.removeImage.hidden = true
        self.writeHereIndicator.hidden = true
        
        self.editBtn.title = "Éditer"
        self.editBtn.enabled = true
        self.navigationItem.hidesBackButton = false
        self.navigationItem.leftBarButtonItem = nil
        
        itemWordTxtView.text = item.word
        itemDescTxtView.text = item.text
    }
    
    @IBAction func removeMedia(sender: AnyObject) {

        //AQUI tem que implementar um DELETE da imagem
        self.image = nil

        mediaView.hidden = true
        removeImage.hidden = true
        editBtn.enabled = true
    }

    
    func editItemCarnet() {
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userId:Int = prefs.integerForKey("id") as Int
        print("atualizando o item do carnet...")
        print(self.itemWordTxtView.text)
        print(self.itemDescTxtView.text)
        print(self.imagePath)
        print(userId)
        
        let params : [String: String] = [
            "id" : String(item.id),
            "word" : self.itemWordTxtView.text!,
            "text" : self.itemDescTxtView.text!,
            "user": String(self.userId)
        ]
        
        if self.image != nil {
            self.saveNote(self.image, params: params)
        } else {
            self.saveNote(params)
        }
        
    }
    
    func saveNote(params: Dictionary<String, String>) {
        
        self.indicator.showActivityIndicator(self.view)
        
        Alamofire.request(.POST, EndpointUtils.CARNET, parameters: params)
            .responseString { response in
                print("Success POST: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }
            .responseSwiftyJSON({ (request, response, json, error) in
                print("Request POST: \(request)")
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
    
    func saveNote(image: UIImage, params: Dictionary<String, String>) {
        // example image data
        let imageData = image.lowestQualityJPEGNSData
        
        self.indicator.showActivityIndicator(self.view)
        
        // CREATE AND SEND REQUEST ----------
        let urlRequest = UrlRequestUtils.instance.urlRequestWithComponents(EndpointUtils.CARNET, parameters: params, imageData: imageData)
        
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                if (error == nil) {
                    self.indicator.hideActivityIndicator();
                    NSOperationQueue.mainQueue().addOperationWithBlock {
//                        self.checkValidChange()
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
    
    // MARK: TextView properties
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        
        let text = itemDescTxtView.text
        
        if text.characters.count >= 1 {
            writeHereIndicator.hidden = true
        } else {
            writeHereIndicator.hidden = false
        }
    }

    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n"  // Recognizes enter key in keyboard
        {
            itemWordTxtView.resignFirstResponder()
            itemDescTxtView.resignFirstResponder()
            return false
        }
        
        let limitLength = 149
        guard let text = textView.text else { return true }
        let newLength = text.characters.count - range.length
        
        return newLength <= limitLength
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        // Disable the Save button while editing.
        editBtn.enabled = false
        if textView == itemDescTxtView {
            writeHereIndicator.hidden = true
        }
    }
    
    func checkValidChange() {
        // Disable the Save button if the text field is empty.
        let text = itemWordTxtView.text ?? ""
        let text2 = itemDescTxtView.text ?? ""
        
        if (!text.isEmpty) {
            editBtn.enabled = true
            
        } else if (!text2.isEmpty) {
            editBtn.enabled = true
            
            
        } else {
            editBtn.enabled = false
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        checkValidChange()
    }
    
    // MARK: layout subviews
    
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
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "edit_carnet"){
            let tabVC = segue.destinationViewController as! UITabBarController
            tabVC.selectedIndex = 3
        }
    }



}

