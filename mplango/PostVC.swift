//
//  PostVC.swift
//  mplango
//
//  Created by Thomas Petit on 04/12/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import CoreData

//Esta tela será aberta a partir da preview do post no mapa.
//O pin abre a preview e a preview abre a tela de post.

class PostVC: UIViewController, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate {

    
    let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    //MARK: Properties
    
    var isTrackingPanLocation = false
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    var post: Annotation? = nil
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var exit: UIBarButtonItem!
    
    //Outlets do like
    @IBOutlet weak var likeBtn: UIButton!
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
        
        userPicture.layer.cornerRadius = 25
        userPicture.layer.masksToBounds = true
        
        likeView.hidden = true

        /*
        if item != nil {
            itemWordLabel.text = item?.word
            itemDescTxtView.text = item?.desc
            navigationItem.title = item!.word
            //itemPhoto.image = item?.photo
        }
        */
        
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
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panRecognized:")
        panGestureRecognizer.delegate = self
        scrollView.addGestureRecognizer(panGestureRecognizer)

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
            
            // determine offset of the pan from the start here.
            // When offset is far enough from table view top edge -
            // dismiss your view controller. Additionally you can
            // determine if pan goes in the wrong direction and
            // then reset flag isTrackingPanLocation to false
            
            let eligiblePanOffset = panOffset.y > 100
            if eligiblePanOffset
            {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            //// !!!UPDATED
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
        
        likeBtn.hidden = true
        likeView.hidden = false
        
        //likeBtn.setImage(UIImage(named: "like_btn"), forState: UIControlState.Normal)
        
        
        //aqui deve atualizar o label dos números de likes (likeNberLabel)
        
        //aqui deve tirar 1 ponto de participação do usuário que usa o botão
        
        //aqui o usuário do post deve ganhar 5 pontos de colaboração
        
        //aqui desativar o botão like quando o usuário for o autor do post
        
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



