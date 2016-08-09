//
//  CommentCell.swift
//  mplango
//
//  Created by Thomas Petit on 10/12/2015.
//  Copyright © 2015 unb.br. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

class CommentCell: UITableViewCell {
    
    var comment: Comment? = nil
    
    var liked:Bool = false
    var likedId:Int!
    
    var user: RUser!
    var userId:Int!
    var postId:Int = 0
    
    
    // MARK: Properties
    
    // para todas as cells

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var checkPointsLabel: UILabel!
    @IBOutlet weak var likeNberLabel: UILabel!

    // para a BasicCell 
    @IBOutlet weak var comTxtView: UILabel!
    @IBOutlet weak var comPicture: UIImageView!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var bgPlayerAudioInPhoto: UIView!


    
    override func layoutSubviews() {

        //userName.text = user.name
        
        profilePicture.layer.cornerRadius = 15
        profilePicture.layer.masksToBounds = true
        
        //Como vai aparecer a AudioView
        
        /*
        audioView.layer.borderWidth = 1
        audioView.layer.borderColor = UIColor(hex: 0x2C98D4).CGColor
        audioView.layer.cornerRadius = 10
        audioView.layer.masksToBounds = true
        */
        
    }
//    
//    func textViewDidChange(textView: UITextView) {
//        
//        let contentSize = self.sizeThatFits(self.comTxtView.bounds.size)
//        var frame = self.comTxtView.frame
//        frame.size.height = contentSize.height
//        self.comTxtView.frame = frame
//        
//        let aspectRatioTextViewConstraint = NSLayoutConstraint(item: self.comTxtView, attribute: .Height, relatedBy: .Equal, toItem: self.comTxtView, attribute: .Width, multiplier: comTxtView.bounds.height/comTxtView.bounds.width, constant: 1)
//        self.comTxtView.addConstraint(aspectRatioTextViewConstraint)
//        
//    }
    
    
    
    // MARK : like
    
//    func showLikes() {
//        
//        //                self.indicator.showActivityIndicator(self.view)
//        
//        let params : [String: String] = [
//            "comment": String(comment!.id),
//            "user": String(self.userId)
//        ]
//        
//        //Checagem remota
//        //        ActivityIndicator.instance.showActivityIndicator(self.view)
//        Alamofire.request(.GET, EndpointUtils.LIKE_COMMENT, parameters: params)
//            .responseString { response in
//                print("Success: \(response.result.isSuccess)")
//                print("Response String: \(response.result.value)")
//            }.responseSwiftyJSON({ (request, response, json, error) in
//                print("Request: \(request)")
//                print("request: \(error)")
//                
//                //                ActivityIndicator.instance.hideActivityIndicator();
//                if json["data"].array?.count > 0 {
//                    
//                    if let id = json["data"]["id"].int {
//                        self.likedId = id
//                    }
//                    
//                    let total:Int = Int((json["data"].array?.count)!);
//                    self.likeNberLabel.text = String(total)
//                    
//                    self.likeNberLabel.textColor = UIColor.whiteColor()
//                    self.likeBtn.hidden = true;
//                    //print("já laicou esse post")
//                    self.liked = true
//                    
//                } else {
//                    
//                    self.likeNberLabel.textColor = UIColor(hex: 0xFF5252)
//                    self.likeBtn.hidden = false;
//                    self.liked = false
//                    //print("pode laicar!")
//                }
//            })
//    }
    
    @IBAction func like(sender: AnyObject) {
        
        //likeBtn.setImage(UIImage(named: "like_btn"), forState: UIControlState.Normal)
        print("String(comment!.id)")
        print(String(self.comment))
        
        if self.liked == false {
            
            //ActivityIndicator.instance.showActivityIndicator(self.view)
            let params : [String: String] = [
                "user" : String(self.userId),
                "comment" : String(self.comment!.id),
                ]
            Alamofire.request(.POST, EndpointUtils.LIKE_COMMENT, parameters: params)
                .responseString { response in
                    print("Success: \(response.result.isSuccess)")
                    print("Response String: \(response.result.value)")
                }.responseSwiftyJSON({ (request, response, json, error) in
                    print("Request: \(request)")
                    print("request: \(error)")
                    //                ActivityIndicator.instance.indicator.hideActivityIndicator();
                    if (error == nil) {
                        self.liked = true
                        if let insertedId: Int = json["data"].int {
                            self.likedId = insertedId
                        }
                        self.likeNberLabel.textColor = UIColor.blackColor()
                        self.likeBtn.hidden = false
                        self.likeBtn.enabled = false
                        //TODO  RETORNAR O TOTAL NO METODO DO SERVER (no DATA)
                        let total:Int = Int(self.likeNberLabel.text!)! + 1;
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
//                            self.presentViewController(alertController, animated: true, completion: nil)
                            
                        }
                    }
                })
        }
        //aqui deve atualizar o label dos números de likes (likeNberLabel)
        //aqui deve tirar 1 ponto de participação do usuário que usa o botão
        //aqui o usuário do post deve ganhar 5 pontos de colaboração
        //aqui desativar o botão like quando o usuário for o autor do post
    }

    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
