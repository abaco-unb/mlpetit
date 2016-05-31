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
    
    @IBOutlet weak var likeView: UIView!
    
    var indicator:ActivityIndicator = ActivityIndicator()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var exit: UIBarButtonItem!
    
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
    
    @IBOutlet weak var backgroundRecord: UIView!
    @IBOutlet weak var listenBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    
    
    //Outlets da AudioView (quando o Post inclui apenas um audio)
    @IBOutlet weak var AudioView: UIView!
    @IBOutlet weak var listenBtn2: UIButton!
    @IBOutlet weak var stopBtn2: UIButton!
    
    
    //Outlets do Video View (
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var previewVideo: UIImageView!
    @IBOutlet weak var playVideo: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.retrieveLoggedUser()
        
        if post != nil {
            //print("post")
            //print(post)
            userPicture.layer.borderWidth = 1
            userPicture.layer.borderColor = UIColor.greenColor().CGColor

            let image: UIImage = ImageUtils.instance.loadImageFromPath(post!.userImage)!
            userPicture.image = image
//            print(1)
            textPost.text = post!.text
            locationLabel.text = post!.locationName
            userName.text = post!.userName
            timeOfPost.text = post!.timestamp
            likeNberLabel.text = String(post!.likes)
            
//            let postVideo = false
//            let postAudio = false
//            print(2)
            
            if post!.image != "" {
                let postImage: UIImage = ImageUtils.instance.loadImageFromPath(post!.image)!
                itemPhoto.image = postImage
            }
//            print(3)
//            print("----***-----");
//            print(post!.image);
//            print(4)
            
            
            if post!.audio != "" {
                do {
                    
                    print(" inicializando o audio do post")
                    print(post!.audio)
                    
                    let audioURL = NSURL(string: post!.audio)
                    
                    print(audioURL)
                    
                    if let soundData = NSData(contentsOfURL: audioURL!) {
                        print("Loading audio from url path: \(audioURL)", terminator: "")
                        try audioPlayer = AVAudioPlayer(data: soundData, fileTypeHint: "m4a")
                    } else {
                        print("missing audio at: \(audioURL)", terminator: "")
                    }
                
                } catch {
                    fatalError("Failure to ...: \(error)")
                }
            }
            
            // FOTO SEM ÁUDIO:
            if (itemPhoto != nil && audioPlayer == nil){
                print("FOTO SEM ÁUDIO")
                photoAudioView.hidden = false
                audioInPhoto.hidden = true
                AudioView.hidden = true
                videoView.hidden = true

            }
                
            // FOTO + ÁUDIO:
            if (itemPhoto != nil && audioPlayer != nil) {
                print("FOTO COM ÁUDIO")
                photoAudioView.hidden = false
                audioInPhoto.hidden = false
                AudioView.hidden = true
            }
                
            // ÁUDIO SEM FOTO:
            if (audioPlayer != nil && itemPhoto == nil) {
                print("AUDIO SEM FOTO")
                photoAudioView.hidden = true
                audioInPhoto.hidden = true
                AudioView.hidden = false
            }
            
            // TEXTO SEM MÍDIA:
            if (itemPhoto == nil && (audioPlayer == nil && itemPhoto == nil)){
                print("SOMENTE TEXTO")
                photoAudioView.hidden = true
                audioInPhoto.hidden = true
                AudioView.hidden = true
                videoView.hidden = true
                mediaView.hidden = true
            }
            showLikes()
        }
        
        //Como vai aparecer a photoAudioView
        photoAudioView.layer.borderWidth = 1
        photoAudioView.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        photoAudioView.layer.cornerRadius = 10
        photoAudioView.layer.masksToBounds = true
        
        backgroundRecord.layer.backgroundColor = UIColor(hex: 0xFFFFFF).CGColor
        backgroundRecord.layer.masksToBounds = true
        
        
        //Como vai aparecer a AudioView
        AudioView.layer.borderWidth = 1
        AudioView.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        AudioView.layer.cornerRadius = 10
        AudioView.layer.masksToBounds = true
        
        
        //Como vai aparecer a videoView
        videoView.layer.borderWidth = 1
        videoView.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        videoView.layer.cornerRadius = 10
        videoView.layer.masksToBounds = true
        
        
        scrollView.bounces = false
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PostDetailViewController.panRecognized(_:)))
        panGestureRecognizer.delegate = self
        scrollView.addGestureRecognizer(panGestureRecognizer)

        enableCustomMenu()
        
    }
    
    func retrieveLoggedUser() {
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        
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

    
    //MARK Actions:
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    

    
    @IBAction func options(sender: AnyObject) {
        
        var popover:UIPopoverPresentationController? = nil
        
        let alert:UIAlertController=UIAlertController(title: "Options", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let modifyAction = UIAlertAction(title: "Modifier", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
//            self.openCamera()
        }
        let deleteAction = UIAlertAction(title: "Supprimer", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
//            self.openGallary()
        }
        
        let reportAction = UIAlertAction(title: "Signaler", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
        }
        
        let followAction = UIAlertAction(title: String("Suivre " + String(post!.userName)), style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
        }
        
        let cancelAction = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        
        if self.userId != post!.ownerId {
            alert.addAction(reportAction)
            alert.addAction(followAction)
            alert.addAction(cancelAction)
        }
        else {
            alert.addAction(modifyAction)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
        }
        
        // Present the controller
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            popover = UIPopoverPresentationController(presentedViewController: alert, presentingViewController: alert)
            popover?.sourceView = self.view
            popover?.sourceRect = likeBtn.frame
            popover?.permittedArrowDirections = .Any
        }
        
    }
    
    // MARK : like
    
    func showLikes() {
        
        //        self.indicator.showActivityIndicator(self.view)
        
        let params : [String: String] = [
            "post": String(post!.id),
            "user": String(self.userId)
        ]
        
        //Checagem remota
        Alamofire.request(.GET, EndpointUtils.LIKE, parameters: params)
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
            }.responseSwiftyJSON({ (request, response, json, error) in
                print("Request: \(request)")
                print("request: \(error)")
                
                //                self.indicator.hideActivityIndicator();
                if json["data"].array?.count > 0 {
                    
                    if let id = json["data"]["id"].int {
                        self.likedId = id
                    }
                    
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
                    
                    let total:Int = Int(self.post!.likes) + 1;
                    self.likeNberLabel.text = String(total)
                } else {
                    NSLog("@resultado : %@", "LIKE LOGIN !!!")
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        
                        //New Alert Ccontroller
                        let alertController = UIAlertController(title: "Oops!", message: "Tivemos um problema para registrar seu like!", preferredStyle: .Alert)
                        let agreeAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                            print("The user is okay about it.")
                        }
                        alertController.addAction(agreeAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                    }
                }
            })
        }
            //aqui deve atualizar o label dos números de likes (likeNberLabel)
            //aqui deve tirar 1 ponto de participação do usuário que usa o botão
            //aqui o usuário do post deve ganhar 5 pontos de colaboração
            //aqui desativar o botão like quando o usuário for o autor do post
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
                    
                    let total:Int = Int(self.post!.likes) - 1;
                    self.likeNberLabel.text = String(total)
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
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width:self.view.bounds.width, height: 600)


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

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "post_to_comments" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let commentController:CommentsVC = navigationController.viewControllers[0] as! CommentsVC
            commentController.comments = self.post?.comments
            commentController.postId = self.post?.id
            
        }
//        if segue.identifier == "copy_to_carnet" {
//            let navigationController = segue.destinationViewController as! UINavigationController
//            let carnetController:CarnetAddVC = navigationController.viewControllers[0] as! CarnetAddVC
//            let copyString = textPost.copy()
//            let pasteBoard = UIPasteboard.generalPasteboard()
//            pasteBoard.string = copyString as? String
//            carnetController.wordTextField.text = copyString as? String
//        }
    }

}



