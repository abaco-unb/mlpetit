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

class PostDetailViewController: UIViewController, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate {

    var userId:Int!
    
    //MARK: Properties
    var post: PostAnnotation? = nil
    
    var isTrackingPanLocation = false
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    var liked:Bool = false
    var likedId:Int!
    
    var indicator:ActivityIndicator = ActivityIndicator()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var exit: UIBarButtonItem!
    
    //Outlets do like
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var likeView: UIImageView!
    @IBOutlet weak var likeNberLabel: UILabel!
    
    @IBOutlet weak var commentBtn: UIButton!
    
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
        
        scrollView.contentSize.height = 300
        
        likeView.hidden = false
        likeBtn.hidden = false

        userPicture.layer.cornerRadius = 25
        userPicture.layer.masksToBounds = true
        print("+++++++++++++++++++++++++")
        print(post!.userImage)
        
        self.retrieveLoggedUser()
        
        if post != nil {
            //print("post")
            //print(post)
            userPicture.layer.borderWidth = 1
            userPicture.layer.borderColor = UIColor.darkGrayColor().CGColor
            let image: UIImage = ImageUtils.instance.loadImageFromPath(post!.userImage)!
            userPicture.image = image
            textPost.text = post!.title
            locationLabel.text = post!.locationName
            userName.text = post!.userName
            timeOfPost.text = post!.timestamp
            likeNberLabel.text = String(post!.likes)
            
            // quando não houver nenhuma mídia (foto, áudio ou vídeo), a mediaView geral fica HIDDEN. Caso contrário ela aparece para mostrar a mídia integrada ao post.
            if (photoAudioView.hidden == true || AudioView.hidden == true || videoView.hidden == true) {
                mediaView.hidden = true
            }
            else {
                mediaView.hidden = false
            }
            
            // aqui chama a imagem do post a partir do que é importado no mapViewController
            
//            let image2: UIImage = ImageUtils.instance.loadImageFromPath(post!.postImage)!
//            itemPhoto.image = image2
//            if itemPhoto != nil {
//                photoAudioView.hidden = false
//            }
//            else {
//                photoAudioView.hidden = true
//            }
            
            // REPETIR o código acima com 1. o áudio, 2. o áudio+foto e 3. o vídeo. Por enquanto fica o seguinte cógido (hidden = true, por padrão):
            AudioView.hidden = true
            videoView.hidden = true
            
        }
        
//        showLikes()
        
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
        
        /*
        
        //Hides and disables Save Button in reading mode.
        navigationItem.rightBarButtonItem?.enabled = false
        navigationItem.rightBarButtonItem?.title = nil
        
        }
        */
        
        scrollView.bounces = false
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PostDetailViewController.panRecognized(_:)))
        panGestureRecognizer.delegate = self
        scrollView.addGestureRecognizer(panGestureRecognizer)

    }
    
    func retrieveLoggedUser() {
        // recupera os dados do usuário logado no app
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = prefs.integerForKey("id") as Int
        
    }
    
    func showLikes() {
        
        self.indicator.showActivityIndicator(self.view)
        
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
                
                self.indicator.hideActivityIndicator();
                if json["data"].array?.count > 0 {
                    
                    if let id = json["data"]["id"].int {
                        self.likedId = id
                    }
                    
                    self.likeNberLabel.textColor = UIColor.whiteColor()
                    self.dislikeBtn.hidden = false
                    self.likeBtn.hidden = true;
                    print("já laicou esse post")
                    self.liked = true
                } else {
                    
                    self.likeNberLabel.textColor = UIColor(hex: 0xFF5252)
                    self.dislikeBtn.hidden = true
                    self.likeBtn.hidden = false;
                    print("pode laicar!")
                }
            })
        
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
    
    @IBAction func like(sender: AnyObject) {
        
        // quando o botão like é clicado, ele é bloqueado e no lugar dele aparece uma image view com a mesma imagem, em vermelho
        
        //likeBtn.setImage(UIImage(named: "like_btn"), forState: UIControlState.Normal)
        self.indicator.showActivityIndicator(self.view)
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
                self.indicator.hideActivityIndicator();
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

        
        
            //aqui deve atualizar o label dos números de likes (likeNberLabel)
        
            //aqui deve tirar 1 ponto de participação do usuário que usa o botão
            
            //aqui o usuário do post deve ganhar 5 pontos de colaboração
            
            //aqui desativar o botão like quando o usuário for o autor do post
        
    }
    
    @IBAction func dislike(sender: AnyObject) {
        
        Alamofire.request(.DELETE, EndpointUtils.LIKE, parameters: ["id": String(self.likedId)])
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
    
    
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        //To adjust the height of TextField to its content
        let contentSize = self.textPost.sizeThatFits(self.textPost.bounds.size)
        var frame = self.textPost.frame
        frame.size.height = contentSize.height
        self.textPost.frame = frame
        
        let aspectRatioTextViewConstraint = NSLayoutConstraint(item: self.textPost, attribute: .Height, relatedBy: .Equal, toItem: self.textPost, attribute: .Width, multiplier: textPost.bounds.height/textPost.bounds.width, constant: 1)
        self.textPost.addConstraint(aspectRatioTextViewConstraint)
        
        
        //Os 3 ajustes seguintes permitem que a mediaView (que inicialmente tem uma altura = 0) se adapte à altura de uma das 3 subviews usadas. Permite que os botões "like" e "comentário" se situem sempre a 20px abaixo da mediaView, independentemente do tamanho dela.
        
        
        //To adjust the height of mediaView to photoAudioView
        
        if photoAudioView.hidden == false {
            
            let contentSize = mediaView.sizeThatFits(mediaView.bounds.size)
            var frame = photoAudioView.frame
            frame.size.height = contentSize.height
            mediaView.frame = frame
            
            let aspectRatioViewConstraint = NSLayoutConstraint(item: mediaView, attribute: .Height, relatedBy: .Equal, toItem: photoAudioView, attribute: .Width, multiplier: photoAudioView.bounds.height/photoAudioView.bounds.width, constant: 1)
            mediaView.addConstraint(aspectRatioViewConstraint)
            
        }
        
        //To adjust the height of mediaView to AudioView
        
        if AudioView.hidden == false {
            
            let contentSize = mediaView.sizeThatFits(mediaView.bounds.size)
            var frame = AudioView.frame
            frame.size.height = contentSize.height
            mediaView.frame = frame
            
            let aspectRatioViewConstraint = NSLayoutConstraint(item: mediaView, attribute: .Height, relatedBy: .Equal, toItem: AudioView, attribute: .Width, multiplier: AudioView.bounds.height/AudioView.bounds.width, constant: 1)
            mediaView.addConstraint(aspectRatioViewConstraint)
            
        }
        
        //To adjust the height of mediaView to videoView
        
        if videoView.hidden == false {
            
            let contentSize = mediaView.sizeThatFits(mediaView.bounds.size)
            var frame = videoView.frame
            frame.size.height = contentSize.height
            mediaView.frame = frame
            
            let aspectRatioViewConstraint = NSLayoutConstraint(item: mediaView, attribute: .Height, relatedBy: .Equal, toItem: videoView, attribute: .Width, multiplier: videoView.bounds.height/videoView.bounds.width, constant: 1)
            mediaView.addConstraint(aspectRatioViewConstraint)
        }
    }
    
    
    
    
}



