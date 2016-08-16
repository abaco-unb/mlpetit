//
//  PostVC.swift
//  mplango
//
//  Created by Thomas Petit on 04/12/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON


//Esta tela será aberta a partir da preview do post no mapa.
//O pin abre a preview e a preview abre a tela de post.

class PostDetailViewController: UIViewController, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, UIAlertViewDelegate {
    
    //MARK: Properties

    var user: RUser!
    var userId:Int!
    var post: PostAnnotation? = nil
    
    var isTrackingPanLocation = false
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    var liked:Bool = false
    var likedId:Int!
    
    var audioPlayer: AVAudioPlayer!
    var image:UIImage!
    var imagePath: String = ""
    
    @IBOutlet weak var likeView: UIView!
    
    var indicator:ActivityIndicator = ActivityIndicator()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var exit: UIBarButtonItem!
    
    @IBOutlet weak var optionsBtn: UIBarButtonItem!
    //Outlets do like
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var likeNberLabel: UILabel!
    
    @IBOutlet weak var commentBtn: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mediaView: UIView!
    
    //Outlets dos elementos que identificam o post (localização, usuário, data/hora da publicação)
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeOfPost: UILabel!
    
    //Outlet do texto do post
    @IBOutlet weak var textPost: UITextView!
    
    //Outlets da photoAudioView (quando o Post inclui uma foto e eventualmente, ao mesmo tempo, um audio)
    @IBOutlet weak var photoAudioView: UIView!
    @IBOutlet weak var itemPhoto: UIImageView!
    @IBOutlet weak var audioInPhoto: UIView!

    @IBOutlet weak var bgPlayerAudioInPhoto: UIView!
    
    //Outlets da AudioView (quando o Post inclui apenas um audio)
    @IBOutlet weak var AudioView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
//        let playButton = UIButton(type: .RoundedRect)
//        let image = UIImage(named: "listen_btn") as UIImage?
//        playButton.setImage(image, forState: UIControlState.Normal)
//        playButton.frame = CGRectMake(0, 0, 300, 700)
//        playButton.addTarget(self, action: #selector(self.testep), forControlEvents: .TouchUpInside)
//        playButton.tag = 98;
//        playButton.enabled = true
//        playButton.userInteractionEnabled = true
//        likeView.addSubview(playButton)
//        playButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        let horizontalConstraint = NSLayoutConstraint(item: playButton, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: likeView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 10)
//        likeView.addConstraint(horizontalConstraint)
//        
//        let verticalConstraint = NSLayoutConstraint(item: playButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: likeView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
//        likeView.addConstraint(verticalConstraint)
//        
//        let widthConstraint = NSLayoutConstraint(item: playButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 20)
//        likeView.addConstraint(widthConstraint)
//        
//        let heightConstraint = NSLayoutConstraint(item: playButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 20)
//        likeView.addConstraint(heightConstraint)
        
        //scrollView.delaysContentTouches = false;
        
        self.navigationItem.title = String(post?.category)
        
        if (post?.category) == Optional(1) {
            let defi = UIImage(named: "cat_defi_bar")
            let imageView = UIImageView(image:defi)
            self.navigationItem.titleView = imageView
            self.locationLabel.textColor = UIColor(hex: 0x9C27B0)

        } else if (post?.category) == Optional(2) {
            let question = UIImage(named: "cat_question_bar")
            let imageView = UIImageView(image:question)
            self.navigationItem.titleView = imageView
            self.locationLabel.textColor = UIColor(hex: 0x41A047)

        } else if (post?.category) == Optional(3) {
            let astuce = UIImage(named: "cat_astuce_bar")
            let imageView = UIImageView(image:astuce)
            self.navigationItem.titleView = imageView
            self.locationLabel.textColor = UIColor(hex: 0x2DB4E4)

        } else if (post?.category) == Optional(4) {
            let evenement = UIImage(named: "cat_evenement_bar")
            let imageView = UIImageView(image:evenement)
            self.navigationItem.titleView = imageView
            self.locationLabel.textColor = UIColor(hex: 0xEF5555)
            
        }
        
        userPicture.layer.cornerRadius = 25
        userPicture.layer.masksToBounds = true
        
        //Como vai aparecer a photoAudioView
        photoAudioView.layer.cornerRadius = 10
        photoAudioView.layer.masksToBounds = true
        
        bgPlayerAudioInPhoto.layer.backgroundColor = UIColor(hex: 0xFFFFFF).CGColor
        bgPlayerAudioInPhoto.layer.masksToBounds = true
        
        
        //Como vai aparecer a AudioView
        AudioView.layer.cornerRadius = 10
        AudioView.layer.masksToBounds = true
        
        
        scrollView.bounces = false
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PostDetailViewController.panRecognized(_:)))
        panGestureRecognizer.delegate = self
        scrollView.addGestureRecognizer(panGestureRecognizer)
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostDetailViewController.cancelEdit))
        view.addGestureRecognizer(tap)
        
        
//        enableCustomMenu()
        
        self.retrieveLoggedUser()
        
        if post != nil {
            
//            userPicture.layer.borderWidth = 1
//            userPicture.layer.borderColor = UIColor.greenColor().CGColor
            
            var hasAudio = false
            var hasImage = false
            
            userPicture.image  = post!.getOwnerImage()
            textPost.text      = post!.text
            locationLabel.text = post!.locationName
            userName.text      = post!.title
            timeOfPost.text    = post!.time
            
            ActivityIndicator.instance.showActivityIndicator(self.view)
            Alamofire.request(.GET, EndpointUtils.POST, parameters: ["id" : (post?.id)!])
                .responseSwiftyJSON({ (request, response, json, error) in
                    ActivityIndicator.instance.hideActivityIndicator()
                    let postComplete = json["data"]
                    var postId = 0
                    
                    if let tLikes = postComplete["likes"].array {
                        self.likeNberLabel.text = String(tLikes.count)
                    }
                    
                    if let id = postComplete["id"].int {
                        postId = id
                    }
                    
                    //            let postVideo = false
                    //            let postAudio = false

                    if let images = postComplete["images"].array {
                        if ((postComplete["images"].array?.count) > 0) {
                            hasImage = true
                            if let imageId = images[0]["id"].int {
                                print("aqui dentro da imagem")
                                self.itemPhoto.image = self.post!.getImage(imageId)
                            }
                        }
                    }
                    
                    if postComplete["audio"].stringValue != "" {
                        hasAudio = true
                    }
                    
                    // FOTO SEM ÁUDIO:
                    if (hasImage && !hasAudio){
                        print("FOTO SEM ÁUDIO")
                        self.photoAudioView.hidden = false
                        self.audioInPhoto.hidden = true
                        self.AudioView.hidden = true
                        
                    }
                    
                    // FOTO + ÁUDIO:
                    if (hasImage && hasAudio) {
                        print("FOTO COM ÁUDIO")
                        self.photoAudioView.hidden = false
                        self.audioInPhoto.hidden = false
                        self.AudioView.hidden = true
                        
                        self.photoAudioView.layer.borderWidth = 1
                        self.photoAudioView.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
                        
                        AudioHelper.instance._init(self.audioInPhoto, audioPath: EndpointUtils.POST + "?id=" + String(postId) + "&audio=true")

                        print("passou do botão 2")

//
                    }
                    
                    // ÁUDIO SEM FOTO:
                    if (!hasImage && hasAudio) {
                        print("AUDIO SEM FOTO")
                        self.photoAudioView.hidden = true
                        self.audioInPhoto.hidden = true
                        self.AudioView.hidden = false
                        
                        self.AudioView.layer.borderWidth = 1
                        self.AudioView.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
                        
                        print(self.AudioView)
                        
                        
                        AudioHelper.instance._init(self.AudioView, audioPath: EndpointUtils.POST + "?id=" + String(postId) + "&audio=true")
                        
                        print("passou do botão 3")
                    }
                    
                    // TEXTO SEM MÍDIA:
                    if (!hasImage && !hasAudio){
                        print("SOMENTE TEXTO")
                        self.photoAudioView.hidden = true
                        self.audioInPhoto.hidden = true
                        self.AudioView.hidden = true
                    }
                    
                    print("antes dos likes");
                    
                    self.showLikes()
                    
                    print("depois dos likes");
                });
        }
        
        //Like desativado quando o usuário for o autor do post
        if self.userId != post!.owner {
            likeBtn.enabled = true
            self.navigationItem.rightBarButtonItem = nil

        }
        else {
            likeBtn.enabled = false
        }

        
    }
    
    @IBAction func teste(sender: UIButton) {
        print("Tapped now")
    }
    
    func testep() {
        print("Tapped addTarget now")
    }
    
    func retrieveLoggedUser() {
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        
    }
    
    // MARK: TextView properties
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
                
        self.textPost.textColor = UIColor(hex: 0x9E9E9E)

    }
    
    
    // MARK: UiMenuItem
    
    func enableCustomMenu() {
        let lookup = UIMenuItem(title: "Copier dans le Carnet", action: #selector(copyToCarnet))
        UIMenuController.sharedMenuController().menuItems = [lookup]
    }

    func disableCustomMenu() {
        UIMenuController.sharedMenuController().menuItems = nil
    }
    
    func copyToCarnet() {
        self.performSegueWithIdentifier("copy_to_carnet", sender: self)
        let copyString = textPost.text
        let pasteBoard = UIPasteboard.generalPasteboard()
        pasteBoard.string = copyString
    }
    
    //MARK: Pan Gesture to dismiss post view
    
    internal func panRecognized(recognizer:UIPanGestureRecognizer)
    {
        if recognizer.state == .Began && scrollView.contentOffset.y == 0
        {
            recognizer.setTranslation(CGPointZero, inView : scrollView)
            
            isTrackingPanLocation = true
        }
        else if recognizer.state != .Ended && recognizer.state != .Cancelled &&
            recognizer.state != .Failed && isTrackingPanLocation
        {
            let panOffset = recognizer.translationInView(scrollView)
            
            let eligiblePanOffset = panOffset.y > 100
            if eligiblePanOffset
            {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            if panOffset.y < 0
            {
                isTrackingPanLocation = false
            }
        }
        else
        {
            isTrackingPanLocation = false
        }
    }
    
    internal func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer
        otherGestureRecognizer : UIGestureRecognizer)->Bool
    {
        return true
    }
    
    
    
    // MARK: Edição do texto do post
    
    func cancelEdit(sender: UIBarButtonItem) {
        
        self.textPost.editable = false
        self.textPost.textColor = UIColor(hex: 0x9E9E9E)
        
        self.optionsBtn.enabled = true
        self.optionsBtn.title = "Modifier"
        
        textPost.text = post?.text
        
        dismissKeyboard()
    }
    
    
    func editPost() {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userId:Int = prefs.integerForKey("id") as Int
        let text = (textPost.text != nil || textPost.text != "") ? textPost.text : ""
        
        print("atualizando o texto do post...")
        print(self.textPost.text)
        print(userId)
        
        var params : [String: String] = [
            "text" : text,
            "id" : String(post!.id),
            "user": String(self.userId),
        ]
        
        if self.image != nil {
            self.saveNewText(self.image, params: params)
        } else {
            params["photo"] = ""
            self.saveNewText(params)
        }

    }
    
    func saveNewText(params: Dictionary<String, String>) {
        
        self.indicator.showActivityIndicator(self.view)
        
        Alamofire.request(.POST, EndpointUtils.POST, parameters: params)
            .responseString { response in
                print("Success POST: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }
            .responseSwiftyJSON({ (request, response, json, error) in
                print("Request POST: \(request)")
                if (error == nil) {
                    self.indicator.hideActivityIndicator();
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("editPost_to_map", sender: self)
                    }
                    
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //New Alert Controller
                        let alertController = UIAlertController(title: "Oups", message: "Ton post n'a pas pu être édité. Essaie à nouveau", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "D'accord", style: .Default) { (action) -> Void in
                            print("The post is not okay.")
                            self.indicator.hideActivityIndicator();
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            })
    }
    
    func saveNewText(image: UIImage, params: Dictionary<String, String>) {
        // example image data
        let imageData = image.lowestQualityJPEGNSData
        
        self.indicator.showActivityIndicator(self.view)
        
        // CREATE AND SEND REQUEST ----------
        let urlRequest = UrlRequestUtils.instance.urlRequestWithComponents(EndpointUtils.POST, parameters: params, imageData: imageData)
        
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                ActivityIndicator.instance.hideActivityIndicator();
                if (error == nil) {
                    self.indicator.hideActivityIndicator();
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("editPost_to_map", sender: self)
                    }
                } else {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        //New Alert Controller
                        let alertController = UIAlertController(title: "Oups", message: "Ton post n'a pas pu être édité. Essaie à nouveau", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "D'accord", style: .Default) { (action) -> Void in
                            print("The post update is not okay.")
                            self.indicator.hideActivityIndicator();
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            })
    }
    
    //MARK Actions:
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func options(sender: AnyObject) {
        
        if self.optionsBtn.title == "Modifier" {        
        
            self.textPost.editable = true
            self.textPost.textColor = UIColor.darkGrayColor()
        
            self.optionsBtn.title = "Confirmer"
            self.optionsBtn.enabled = true
        
        }
    
        else if self.optionsBtn.title == "Confirmer" {
            self.editPost()
        }
    
    
//        var popover:UIPopoverPresentationController? = nil
//        
//        let alert:UIAlertController=UIAlertController(title: "Options", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
//        
//        let modifyAction = UIAlertAction(title: "Modifier", style: UIAlertActionStyle.Default)
//        {
//            UIAlertAction in
        
//        let deleteAction = UIAlertAction(title: "Supprimer", style: UIAlertActionStyle.Default)
//        {
//            UIAlertAction in
////            self.openGallary()
//        }
        
//        let reportAction = UIAlertAction(title: "Signaler", style: UIAlertActionStyle.Default)
//        {
//            UIAlertAction in
//        }
//        
//        let followAction = UIAlertAction(title: String("Suivre " + String(self.post!.getOwnerName())), style: UIAlertActionStyle.Default)
//        {
//            UIAlertAction in
//        }
//        
//        let cancelAction = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Cancel)
//        {
//            UIAlertAction in
//        }
//        
//        // Add the actions
//        
//        if self.userId != post!.owner {
//            alert.addAction(reportAction)
//            alert.addAction(followAction)
//            alert.addAction(cancelAction)
//        }
//        else {
//            alert.addAction(modifyAction)
////            alert.addAction(deleteAction)
//            alert.addAction(cancelAction)
//        }
//        
//        // Present the controller
//        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
//        {
//            self.presentViewController(alert, animated: true, completion: nil)
//        }
//        else
//        {
//            popover = UIPopoverPresentationController(presentedViewController: alert, presentingViewController: alert)
//            popover?.sourceView = self.view
//            popover?.sourceRect = likeBtn.frame
//            popover?.permittedArrowDirections = .Any
//        }
    
    }
    
    // MARK : like
    
    func showLikes() {
        
//                self.indicator.showActivityIndicator(self.view)
        
        let params : [String: String] = [
            "post": String(post!.id),
            "user": String(self.userId)
        ]
        
        //Checagem remota
//        ActivityIndicator.instance.showActivityIndicator(self.view)
        Alamofire.request(.GET, EndpointUtils.LIKE, parameters: params)
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                print("Request: \(request)")
                print("request: \(error)")
                
//                ActivityIndicator.instance.hideActivityIndicator();
                if json["data"].array?.count > 0 {
                    
                    if let id = json["data"]["id"].int {
                        self.likedId = id
                    }
                    
                    let total:Int = Int((json["data"].array?.count)!);
                    self.likeNberLabel.text = String(total)
                    
                    self.likeNberLabel.textColor = UIColor.whiteColor()
                    self.dislikeBtn.hidden = false
                    self.likeBtn.hidden = true;
                    //print("já laicou esse post")
                    self.liked = true
                    
                } else {
                    
                    self.likeNberLabel.textColor = UIColor(hex: 0xFF5252)
                    self.dislikeBtn.hidden = true
                    self.likeBtn.hidden = false;
                    self.liked = false
                    //print("pode laicar!")
                }
            })
    }
    
    @IBAction func like(sender: AnyObject) {
        
        //likeBtn.setImage(UIImage(named: "like_btn"), forState: UIControlState.Normal)
        print("String(self.post!.id)")
        print(String(self.post!.id))
        
        if self.liked == false {
        
//        self.indicator.showActivityIndicator(self.view)
        let params : [String: String] = [
            "user" : String(self.userId),
            "post" : String(self.post!.id),
            ]
        Alamofire.request(.POST, EndpointUtils.LIKE, parameters: params)
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                print("Request: \(request)")
                print("request: \(error)")
//                self.indicator.hideActivityIndicator();
                if (error == nil) {
                    self.liked = true
                    if let insertedId: Int = json["data"].int {
                        self.likedId = insertedId
                    }
                    self.likeNberLabel.textColor = UIColor.whiteColor()
                    self.dislikeBtn.hidden = false
                    self.dislikeBtn.enabled = true
                    self.likeBtn.hidden = true
                    self.likeBtn.enabled = false
                    //TODO  RETORNAR O TOTAL NO METODO DO SERVER (no DATA)
                    let total:Int = Int(self.likeNberLabel.text!)! + 1;
                    self.likeNberLabel.text = String(total)
                    
//                    NSOperationQueue.mainQueue().addOperationWithBlock {
//                        self.performSegueWithIdentifier("to_like_notif", sender: self)
//                    }
                    
                } else {
                    NSLog("@resultado : %@", "LIKE LOGIN !!!")
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        
                        //New Alert Ccontroller
                        let alertController = UIAlertController(title: "Oops!", message: "Ton coup de coeur n'a pas pu être partagé", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            print("The user is okay about it.")
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                    }
                }
            })
        }

    }
    
    @IBAction func dislike(sender: AnyObject) {
        
        if self.liked == true {
            
        self.indicator.showActivityIndicator(self.view)
        let params : [String: String] = [
            "user" : String(self.userId),
            "post" : String(self.post!.id),
            "id": String(self.likedId)
            ]
        
        Alamofire.request(.DELETE, EndpointUtils.LIKE, parameters: params)
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                print("Request: \(request)")
                print("request: \(error)")
                self.indicator.hideActivityIndicator();
                if (error == nil) {
                    self.liked = false
                    self.likeNberLabel.textColor = UIColor(hex: 0xFF5252)
                    self.dislikeBtn.hidden = true
                    self.dislikeBtn.enabled = false
                    self.likeBtn.hidden = false
                    self.likeBtn.enabled = true
                    
                    //let total:Int = Int(self.post!.likes) - 1;
                    //self.likeNberLabel.text = String(total)
                } else {
                    NSLog("@resultado : %@", "UNLIKE LOGIN !!!")
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        
                        //New Alert Ccontroller
                        let alertController = UIAlertController(title: "Oops!", message: "Tivemos um problema para retirar seu like!", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            print("The user is okay about it.")
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                    }
                }
            })
        }
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews();
        self.scrollView.contentSize.height = 700;
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()

        //To adjust the height of TextField to its content
        let contentSize = self.textPost.sizeThatFits(self.textPost.bounds.size)
        var frame = self.textPost.frame
        frame.size.height = contentSize.height
        self.textPost.frame = frame
        
        let aspectRatioTextViewConstraint = NSLayoutConstraint(item: self.textPost, attribute: .Height, relatedBy: .Equal, toItem: self.textPost, attribute: .Width, multiplier: textPost.bounds.height/textPost.bounds.width, constant: 1)
        self.textPost.addConstraint(aspectRatioTextViewConstraint)
        
    }
        
//        //Os 3 ajustes seguintes permitem que a mediaView (que inicialmente tem uma altura = 0) se adapte à altura de uma das 3 subviews usadas. Permite que os botões "like" e "comentário" se situem sempre a 20px abaixo da mediaView, independentemente do tamanho dela.
//        
//        
//        //To adjust the height of mediaView to photoAudioView
//        
//        if photoAudioView.hidden == false {
//            
//            let contentSize = mediaView.sizeThatFits(mediaView.bounds.size)
//            var frame = photoAudioView.frame
//            frame.size.height = contentSize.height
//            mediaView.frame = frame
//            
//            let aspectRatioViewConstraint = NSLayoutConstraint(item: mediaView, attribute: .Height, relatedBy: .Equal, toItem: photoAudioView, attribute: .Width, multiplier: photoAudioView.bounds.height/photoAudioView.bounds.width, constant: 1)
//            mediaView.addConstraint(aspectRatioViewConstraint)
//            
//        }
//        
//        //To adjust the height of mediaView to AudioView
//        
//        if AudioView.hidden == false {
//            
//            let contentSize = mediaView.sizeThatFits(mediaView.bounds.size)
//            var frame = AudioView.frame
//            frame.size.height = contentSize.height
//            mediaView.frame = frame
//            
//            let aspectRatioViewConstraint = NSLayoutConstraint(item: mediaView, attribute: .Height, relatedBy: .Equal, toItem: AudioView, attribute: .Width, multiplier: AudioView.bounds.height/AudioView.bounds.width, constant: 1)
//            mediaView.addConstraint(aspectRatioViewConstraint)
//            
//        }
//        
//        //To adjust the height of mediaView to videoView
//        
//        if videoView.hidden == false {
//            
//            let contentSize = mediaView.sizeThatFits(mediaView.bounds.size)
//            var frame = videoView.frame
//            frame.size.height = contentSize.height
//            mediaView.frame = frame
//            
//            let aspectRatioViewConstraint = NSLayoutConstraint(item: mediaView, attribute: .Height, relatedBy: .Equal, toItem: videoView, attribute: .Width, multiplier: videoView.bounds.height/videoView.bounds.width, constant: 1)
//            mediaView.addConstraint(aspectRatioViewConstraint)
//        }
//    }
    
    
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "post_to_comments" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let commentController:CommentsVC = navigationController.viewControllers[0] as! CommentsVC
            print(self.post?.id)
            commentController.postId = (self.post?.id)!
            
        }
        
        if(segue.identifier == "editPost_to_map"){
            let mapVC = segue.destinationViewController as! UITabBarController
            mapVC.selectedIndex = 0
            
        }
        
//        if(segue.identifier == "to_like_notif"){
//            let navigationController = segue.destinationViewController as! UINavigationController
//            let likeController:LikeViewController = navigationController.viewControllers[0] as! LikeViewController
//           
//            likeController.likedUser.image = post!.getOwnerImage()
//            self.user.id = userId
//            likeController.likingUser.image = UIImage(contentsOfFile: self.user.image)
//            
//        }
        
    }

}



